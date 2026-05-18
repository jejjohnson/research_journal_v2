---
title: "Report 10 — `pipekit-cycle`: time-stepping, DA, observation operators"
subject: geotoolz master plan
short_title: "R10 — pipekit-cycle"
authors:
  - name: J. Emmanuel Johnson
    affiliations:
      - UNEP
      - IMEO
      - MARS
    orcid: 0000-0002-6739-0053
    email: jemanjohnson34@gmail.com
license: CC-BY-4.0
keywords: geotoolz, pipekit-cycle, time-stepping, data-assimilation, observation-operator
---

# Report 10 — `pipekit-cycle`: time-stepping, DA, and observation operators

|                       |                                                                                                                                                                                                    |
|-----------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|**Status**             |Scoping proposal — committed                                                                                                                                                                        |
|**Reading time**       |~20 min                                                                                                                                                                                             |
|**Decisions locked in**|Monorepo development (`packages/pipekit-cycle/`). Builds on `pipekit.state` primitives (Group M of Report 2). DA, forward simulation, and iterative inference all unify under the cycle abstraction.|
|**Audience**           |Anyone reviewing the L3–L4 pipeline machinery                                                                                                                                                       |
|**Companion reports**  |Reports 1–9 (existing stack), Report 11 (`pipekit-train`), Report 12 (`pipekit-experiment`), Report 13 (`statecatalog`)                                                                             |

## Part 1 — Where `pipekit-cycle` sits in the stack

After the full series of splits:

```
   Domain libraries           geotoolz │ xr_toolz
                                  ▲
                                  │
   Infrastructure         pipekit-cycle (this report)
                                  ▲
                                  │ depends on pipekit.state
                                  │
   Framework                   pipekit ◄── pipekit-array
                                  ▲
                                  │
   Substrate              georeader │ xarray ecosystem
```

`pipekit-cycle` is a **framework-layer sibling** of `pipekit-array`. It builds on `pipekit.state` (the `StatefulOperator` + `CarryState` primitives from Report 2 Group M) and ships time-stepping abstractions that the existing `Sequential` and `Graph` can’t express.

Three observations:

1. **Carrier-agnostic.** Like pipekit itself, pipekit-cycle doesn’t know what’s flowing through. A `Cycle` over GeoTensors works the same as a `Cycle` over xarray Datasets or NumPy arrays. The carrier is decided by the operators inside the cycle.
2. **Domain-neutral.** The DA cycle structure is the same whether you’re doing atmospheric chemistry transport (chemistry forward model + IR retrievals) or plume dispersion (FLEXPART forward + concentration obs) or ocean state estimation (MOM forward + altimetry obs). Pipekit-cycle ships the structure; the algorithm libraries (`filterx`, `vardax`, `plumax`) ship the concrete forward models, observation operators, and analysis steps via adapter modules.
3. **No JAX coupling in core.** The cycle abstractions work in pure Python over any carrier. `pipekit-jax` (Report 5, deferred) will add `JaxCycle` / `ScanCycle` that compile to `jax.lax.scan` for performance, but those are extensions, not the core.

## Part 2 — What’s in `pipekit-cycle`

Five conceptual pieces, each in its own module. Total ~600 LOC of framework code, plus ~200 LOC of adapters per algorithm library that wants to plug in.

### 2.1 Source layout

```
pipekit-cycle/
  __init__.py             # public re-exports
  _src/
    cycle.py              # Cycle, EnsembleCycle, WindowedCycle, Recurrence
    protocols.py          # ForwardModel, ObservationOperator, AnalysisStep
    da.py                 # DACycle, EnsembleDACycle, SmootherCycle
    obs.py                # IdentityObs, LinearObs, CallableObs, CompositeObs
    forward.py            # CompositeForward, CallableForward, NeuralForward (stub)
```

### 2.2 The cycle abstractions (`cycle.py`)

These are the time-stepping wrappers. They take an existing `StatefulOperator` (the per-step transition) and lift it to operate over time. The patterns mirror what `jax.lax.scan` and `jax.lax.while_loop` do; the operator-graph version makes them composable and serializable.

```python
class Cycle(StatefulOperator):
    """Apply step_op for n_steps, threading state through.
    
    Equivalent shape to jax.lax.scan but works on any carrier.
    Outputs: (final_carrier, final_state, history) where history is
    an optional sequence of intermediate states.
    
    `step_op` may be any `StatefulOperator`, or a `ForwardModel` —
    a ForwardModel is wrapped on construction via the
    `ForwardModel → StatefulOperator` shim, so domain libraries can
    pass their `ForwardModel` adapters directly without importing
    pipekit-cycle internals.
    """
    step_op: StatefulOperator | ForwardModel
    n_steps: int
    save_history: bool = False
    history_stride: int = 1   # save every nth step

class EnsembleCycle(StatefulOperator):
    """Run Cycle over an ensemble of initial states in parallel.
    
    The carrier is a stacked ensemble (leading axis = ensemble member).
    Operators inside step_op see one member at a time — vectorisation
    is delegated to the user's operator (e.g., pipekit-array's BatchedMap,
    or pipekit-jax's filter_vmap).
    """
    step_op: StatefulOperator
    n_steps: int
    n_members: int

class WindowedCycle(StatefulOperator):
    """Sliding-window analysis. Apply step_op over rolling windows
    of an input stream, advancing by stride.
    
    Used for windowed reanalysis (4D-Var over fixed assimilation windows).
    """
    step_op: StatefulOperator
    window: int
    stride: int

class Recurrence(StatefulOperator):
    """Apply step_op repeatedly until convergence condition is met.
    
    For iterative inference: fixed-point methods, Newton iteration,
    EM, variational inference. The condition_op is itself an Operator
    that returns a bool from the current state.
    """
    step_op: StatefulOperator
    condition_op: Operator   # state → bool
    max_iters: int = 1000
```

These are operator wrappers, not new operators themselves. The per-step transition is supplied as `step_op` and can be any `StatefulOperator` — including a complex one built from a `Sequential` of stateful and stateless operators.

### 2.3 The three protocols (`protocols.py`)

The structural decomposition of data assimilation, lifted into pipekit’s Protocol-shaped style. Mirror the `Field` / `Domain` pattern from `geopatcher`.

```python
@runtime_checkable
class ForwardModel(Protocol):
    """Advance state forward in time by dt.
    
    Implementations: plumax.PlumeForward, somax.OceanForward, neural
    emulators, hybrid physics+ML models.
    """
    def step(self, state: Any, dt: float) -> Any: ...
    @property
    def dt(self) -> float: ...
    @property  
    def state_signature(self) -> Signature | None: ...

@runtime_checkable
class ObservationOperator(Protocol):
    """Map model state to predicted observations (the H operator in DA).
    
    H(x) gives 'what would the observations look like if the state were x?'.
    Critical for innovation = obs - H(forecast).
    """
    def __call__(self, state: Any) -> Any: ...   # state → predicted_obs
    def linearize(self, state: Any) -> Any: ...   # tangent linear, optional

@runtime_checkable
class AnalysisStep(Protocol):
    """Combine forecast state with observations to produce analysis state.
    
    Implementations: filterx.EnKFAnalysis, vardax.FourDVarAnalysis,
    particle filter, ensemble Kalman smoother.
    """
    def __call__(self, forecast: Any, obs: Any, *, obs_op: ObservationOperator, 
                 obs_err_cov: Any) -> Any: ...
```

The three Protocols decompose DA into its standard form: predict (`ForwardModel`), compare (`ObservationOperator`), update (`AnalysisStep`). Each algorithm library ships adapter classes that satisfy these protocols, **without importing pipekit-cycle**. The protocols are runtime-checked.

### 2.4 The DA cycle (`da.py`)

The headline composable: a stateful operator that runs the predict-compare-update cycle.

```python
class DACycle(StatefulOperator):
    """Standard forecast-analysis cycle.
    
    Each call:
        1. Forecast: state → forward_model.step(state, dt) → forecast_state
        2. Read observations for this time window from obs_source
        3. Analyse: analysis_step(forecast_state, obs, obs_op, err_cov) → analysis_state
        4. Carry analysis_state forward as the new state
    """
    forward_model: ForwardModel
    obs_op: ObservationOperator
    analysis_step: AnalysisStep
    obs_source: Operator | None = None   # observation injection (typically a catalog reader)
    n_steps: int
    save_history: bool = True

class EnsembleDACycle(StatefulOperator):
    """Ensemble-based DA — EnKF, ETKF, LETKF, etc.
    
    State is a stack of ensemble members. Analysis step is the ensemble
    update. Concrete analysis_step implementations come from filterx.
    """
    forward_model: ForwardModel
    obs_op: ObservationOperator
    analysis_step: AnalysisStep   # an ensemble analysis (filterx.EnKFAnalysis)
    obs_source: Operator | None
    n_steps: int
    n_members: int

class SmootherCycle(StatefulOperator):
    """4D-Var-shaped: forward pass over window, backward adjoint pass.
    
    Useful for variational analysis where the full window is solved
    jointly. analysis_step here is a 4D-Var solver from vardax.
    """
    forward_model: ForwardModel
    obs_op: ObservationOperator
    analysis_step: AnalysisStep   # a smoother (vardax.FourDVarSolver)
    window: int
    stride: int
```

### 2.5 The observation operators (`obs.py`)

Concrete `ObservationOperator` implementations for the common cases. Each is a `pipekit.Operator` so they can be composed inside Sequential / Graph as well as used directly via Protocol satisfaction.

```python
class IdentityObs(Operator):
    """Direct measurement: H = I. The state is observable as-is."""

class LinearObs(Operator):
    """H is a linear matrix. Useful when state and obs differ in dimension
    via a fixed linear map (e.g., subsampling, channel-mixing).
    """
    H: ndarray   # array-shaped, multi-backend via array_namespace

class CallableObs(Operator):
    """H is an arbitrary callable. Catch-all for nonlinear observation
    operators (radiative-transfer-style: state to radiances).
    
    The callable might itself be a pipekit pipeline (e.g., a forward
    radiative transfer model wrapped as an Operator).
    """
    fn: Callable
    forbid_in_yaml: ClassVar[bool] = True

class CompositeObs(Operator):
    """H = h2 ∘ h1. Compose observation operators when the obs path
    has multiple stages (e.g., chemistry transport → column integrator
    → satellite-instrument-response convolution).
    """
    components: tuple[ObservationOperator, ...]
```

### 2.6 The forward model helpers (`forward.py`)

Generic `ForwardModel` adapters, paralleling the obs side.

```python
class CallableForward(Operator):
    """Wrap any callable as a ForwardModel. The escape hatch."""
    fn: Callable
    dt: float

class CompositeForward(Operator):
    """Compose multiple forward models — e.g., advection ∘ chemistry ∘ deposition.
    
    Each component advances state by its own dt; CompositeForward enforces
    consistent total dt across components.
    """
    components: tuple[ForwardModel, ...]

class NeuralForward(Operator):
    """Stub for neural emulator forward models. Wraps a pipekit-array
    ModelOp or pipekit-jax JaxModelOp into the ForwardModel protocol.
    
    The actual neural model is trained via pipekit-train (Report 11)
    and stored in the model registry (Report 12).
    """
    model_op: Operator   # ModelOp or JaxModelOp
    dt: float
```

## Part 3 — How algorithm libraries plug in

Each algorithm library ships an adapter module that satisfies the protocols **without importing pipekit-cycle**. Same pattern as `geopatcher.integrations.pipekit` — algorithm core stays framework-free; thin adapter ties it to the protocols.

### 3.1 `filterx.adapters` (sketch)

```python
# In filterx — your Kalman / particle filter library
# Pure algorithm code; no pipekit dependency in the core.

# filterx.adapters.pipekit (new, ~150 LOC, extras-gated via filterx[pipekit])
class EnKFAnalysis:
    """Ensemble Kalman analysis step. Satisfies pipekit_cycle.AnalysisStep
    protocol via structural typing.
    """
    inflation: float = 1.0
    localization: Any = None
    
    def __call__(self, forecast_ensemble, obs, *, obs_op, obs_err_cov):
        # Wrap filterx's EnKF math in the AnalysisStep signature
        ...

class ParticleFilterAnalysis:
    """Particle filter / sequential Monte Carlo. Same protocol."""
    ...
```

### 3.2 `vardax.adapters` (sketch)

```python
# vardax.adapters.pipekit
class FourDVarAnalysis:
    """4D-Var solver as an AnalysisStep. Wraps vardax's variational
    solver in the cycle-friendly interface.
    """
    background_cov: Any
    inner_iters: int = 50
    outer_iters: int = 3
    
    def __call__(self, background_state, obs_window, *, obs_op, obs_err_cov):
        ...
```

### 3.3 `plumax.adapters` (sketch)

```python
# plumax.adapters.pipekit
class PlumeForward:
    """Plume dispersion forward model as a pipekit_cycle.ForwardModel.
    Wraps plumax's plume math in the step(state, dt) interface.
    """
    dispersion_params: Any
    
    def step(self, plume_state, dt):
        ...

class PlumeObservationOp:
    """Map plume state → predicted column-integrated concentrations.
    
    Specific to satellite-observable plume products. Domain-specific
    observation operator; satisfies pipekit_cycle.ObservationOperator.
    """
    instrument_response: Any
    
    def __call__(self, plume_state):
        ...
```

The pattern: each algorithm library has its own `adapters/pipekit.py` module, gated behind `[pipekit]` extra. When the user wants their library plumbed into a cycle, they install `[pipekit]` and import the adapter. Algorithm cores stay clean.

## Part 4 — Worked examples

### 4.1 Atmospheric chemistry DA cycle

```python
import pipekit as pk
import pipekit_cycle as pc
import geocatalog as gc
import geotoolz as gz
from filterx.adapters.pipekit import EnKFAnalysis
from plumax.adapters.pipekit import ChemistryForward, ColumnObs
from statecatalog import StateCatalog

# Pieces from the algorithm + domain libraries
forward = ChemistryForward(species=["CH4", "NH3"], dt=3600.0)
obs_op  = ColumnObs(instrument="TROPOMI")
analysis = EnKFAnalysis(inflation=1.05, localization="gaspari-cohn")

# Catalog source for observations at each cycle step
obs_catalog = gc.open_catalog("s3://tropomi/2024/*.parquet")
obs_source = pk.Sequential([
    gc.CatalogTimeQuery(window="hourly"),   # custom op: pick obs for current cycle time
    gz.tropomi.LoadL2(),
    gz.qa.AssertValidFraction(min_valid=0.3),
])

# The cycle itself
da = pc.EnsembleDACycle(
    forward_model=forward,
    obs_op=obs_op,
    analysis_step=analysis,
    obs_source=obs_source,
    n_steps=24,         # one day
    n_members=40,
    save_history=True,
)

# Run from an initial state, write outputs to the state catalog
state_cat = StateCatalog.open("s3://reanalysis/methane_2024/")
final_state, history = da(initial_state, initial_carry_state)
state_cat.write(history, model_config_hash=pk.config_hash(da))
```

### 4.2 Forward simulation only (no DA)

```python
# Just a forecast — no observations, no analysis.
forecast = pc.Cycle(
    step_op=forward,         # the ChemistryForward from above
    n_steps=72,              # 3-day forecast
    save_history=True,
    history_stride=1,        # save every hour
)

trajectory = forecast(analysis_state, initial_carry_state)
state_cat.write(trajectory, model_config_hash=pk.config_hash(forecast))
```

### 4.3 Iterative inference (e.g., Levenberg-Marquardt retrieval)

```python
# Convergence-driven recurrence — not time-stepping.
retrieval = pc.Recurrence(
    step_op=LMStep(jacobian_fn=...),       # one LM update
    condition_op=pk.qc.AssertCallable(
        predicate=lambda state: state.residual_norm < 1e-6 or state.iter >= 100
    ),
    max_iters=100,
)

retrieved_state = retrieval(initial_guess, initial_iter_state)
```

### 4.4 Neural-emulator forecast

```python
# Same cycle structure, but the forward model is a learned emulator
# loaded from the model registry.

import pipekit_experiment as pe

registry = pe.S3ModelRegistry("s3://models/")
neural_forward = pc.NeuralForward(
    model_op=registry.load("methane_emulator_v3"),   # content-addressed
    dt=3600.0,
)

# Same DACycle structure — only the forward model changed
da_emulated = pc.EnsembleDACycle(
    forward_model=neural_forward,          # ← swapped
    obs_op=obs_op,                          # same
    analysis_step=analysis,                 # same
    obs_source=obs_source,                  # same
    n_steps=24,
    n_members=40,
)
```

This swap-the-forward-model pattern is the whole point. Train an emulator (Report 11), register it (Report 12), drop it into the same DA cycle. Same code, 100× faster forecasts.

## Part 5 — Dependencies and optional extras

### 5.1 Base install

```toml
[project]
name = "pipekit-cycle"
version = "0.1.0"
dependencies = [
    "pipekit>=0.1",
    "numpy>=2.0",
]
```

Base install: the cycle abstractions, the three protocols, the generic observation/forward operators. No domain-specific code.

### 5.2 Optional extras

```toml
[project.optional-dependencies]
array  = ["pipekit-array>=0.1"]    # for NeuralForward / NeuralObservation via ModelOp
jax    = ["pipekit-jax>=0.1"]      # for ScanCycle, JaxDACycle (deferred)
catalog = ["statecatalog>=0.1"]    # for state-aware cycles that read/write state catalogs
all    = ["pipekit-cycle[array,catalog]"]
```

`pipekit-jax` is deferred — when it lands it will add JAX-traceable cycle variants compiling to `lax.scan`.

### 5.3 No domain dependencies

`pipekit-cycle` does not depend on `geotoolz`, `xr_toolz`, `filterx`, `vardax`, `plumax`, or any domain / algorithm package. Those packages depend on `pipekit-cycle` only via their own optional `[pipekit]` adapter extras.

## Part 6 — The state-threading discipline

Worth being explicit: how `Sequential` and `Graph` interact with `StatefulOperator` (the primitive in pipekit core, Report 2 Group M).

### 6.1 Sequential threads state automatically

```python
sub = pk.Sequential([
    StatelessOpA(),     # carrier → carrier
    StatefulOpB(),       # (carrier, state) → (carrier, state)
    StatelessOpC(),
    StatefulOpD(),
])
```

`Sequential.__call__` detects when any step is stateful and threads state through. Stateless steps pass state unchanged. This is the same dispatch logic as the eager-vs-symbolic check in pipekit core, generalised.

### 6.2 The carry state is the user’s

Pipekit-cycle doesn’t dictate what `CarryState` contains. A `Cycle` is parameterised by an initial state (any object) and threads it through. Concrete `CarryState` subclasses:

- `DAState(background_state, ensemble_members, t, cycle_count)` for `DACycle`
- `IterationState(residual_norm, iter, lr, history)` for `Recurrence`
- `WindowState(window_obs, window_states, last_analysis)` for `SmootherCycle`

Each lives where it’s defined — usually in the algorithm library’s adapter module.

### 6.3 Serialisation

Stateful operators serialize via the same `state` / `from_state` discipline as stateless ones. The `CarryState` is NOT part of the operator’s config — it’s runtime data — but checkpointing a cycle in progress means saving (operator_state, carry_state) as a pair. Pipekit-cycle ships a small `Checkpoint(cycle_op)` operator that wraps this pattern.

## Part 7 — Honest tradeoffs

### 7.1 What gets better

1. **DA pipelines become first-class composable artifacts.** Currently they live in research code; after pipekit-cycle they’re YAML-serializable graphs.
2. **Algorithm libraries (`filterx`, `vardax`, `plumax`) stay clean.** They expose adapters; their cores don’t import pipekit.
3. **Swap-the-forward-model becomes trivial.** Trained emulators replace physical forward models with a one-line change.
4. **Iterative inference unifies with time-stepping.** Same `StatefulOperator` substrate, different cycle shape (`Recurrence` vs `Cycle`).
5. **Future JAX support is structural.** When `pipekit-jax` lands, `JaxCycle` / `ScanCycle` are drop-in fast paths.

### 7.2 What gets harder

1. **Stateful pipelines are harder to debug.** Threading state means a bug at step 47 may have its root cause at step 3. Mitigations: `save_history=True` by default in cycles; `Snapshot` taps work at any step; `Profile` per-step timing.
2. **`StatefulOperator` subclasses can’t be casually composed with stateless ones.** A user mixing them needs to understand the threading. Mitigation: clear documentation, explicit class hierarchy.
3. **The `CarryState` design is non-trivial.** Different cycle patterns need different state. Mitigation: `CarryState` is a protocol/base, not a fixed schema; concrete state types live where they’re used.

### 7.3 What doesn’t fit and isn’t tried

- **Asynchronous DA (continuous data streams).** Pipekit-cycle assumes batched windows; continuous-DA is a different beast.
- **Adjoint-based gradient propagation through the cycle.** That’s pipekit-jax territory once it lands.
- **Distributed-ensemble DA across machines.** Single-machine ensembles only. Distributed scale-out is the orchestrator’s job.

## Part 8 — Effort and timing

### 8.1 Effort

- **Day 1-2**: `cycle.py` — `Cycle`, `EnsembleCycle`, `WindowedCycle`, `Recurrence`. Plus the `StatefulOperator` / `Sequential` integration in pipekit core.
- **Day 3**: `protocols.py` — three Protocols, runtime-checkable.
- **Day 4-5**: `da.py` — `DACycle`, `EnsembleDACycle`, `SmootherCycle`.
- **Day 6**: `obs.py` + `forward.py` — generic adapter operators.
- **Day 7-8**: First adapter (filterx.adapters.pipekit). Smoke-test with a toy Kalman filter on a 1-D model. Validate that the abstraction actually fits.
- **Day 9-10**: Documentation, second adapter (plumax). Migration guide.

**Total: ~2 weeks of focused work** for the core. Each additional algorithm library adapter is ~1-2 days.

### 8.2 Timing

Ship **after** pipekit v0.1 is stable. Pipekit-cycle depends on `StatefulOperator` being in pipekit core (Group M), which means pipekit v0.1 needs to land first with that addition. Realistically this is v0.2 of the ecosystem — alongside `pipekit-array`, `geocatalog`, `geopatcher` extractions.

### 8.3 What this unblocks

1. **Forward simulation as a pipeline.** Currently the simulation libraries (`plumax`, `somax`) produce trajectories in their own idioms. After pipekit-cycle they produce trajectories as pipekit operators — checkpointable, diffable, serializable.
2. **DA at all.** Currently your DA capability is “we have filterx and vardax.” After pipekit-cycle you have actual DA pipelines that compose with the catalog / patcher / observation stack.
3. **Emulator training data generation.** `pipekit-train.SimulationDataset` (Report 11) uses `Cycle` to generate training trajectories from a forward model.
4. **The L3→L4 step.** This is the bridge piece. Without it, L3 → L4 is research code; with it, it’s a pipekit pipeline like everything else.

## Part 9 — Recommendation

**Ship `pipekit-cycle` as a separate sister package.** Signals:

- It’s substantial (~600 LOC + per-domain adapters) — submodule-of-pipekit would bloat the core
- It introduces conceptually different primitives (state threading, cycle structure) that some users won’t need
- It has heavier algorithm-library dependencies than pipekit core wants to take on (transitively via the protocols)
- Algorithm libraries plug in via their own `[pipekit]` extras — same pattern as `geopatcher.integrations.pipekit`

The package belongs in the same monorepo: `packages/pipekit-cycle/`. Sibling of `pipekit-array`. Builds on the `pipekit.state` primitives shipped in pipekit core.

This is the headline missing piece for the L3-L4 story. Without it, your stack can’t do DA / forward-simulation / iterative-inference as first-class pipelines. With it, the L0-L4 cycle becomes composable end-to-end.