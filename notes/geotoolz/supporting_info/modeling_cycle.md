---
title: "Report 16 — Data-driven modeling cycle & benchmark-gated L0–L4 refinement"
subject: geotoolz supporting info
short_title: "R16 — Modeling cycle"
authors:
  - name: J. Emmanuel Johnson
    affiliations:
      - UNEP
      - IMEO
      - MARS
    orcid: 0000-0002-6739-0053
    email: jemanjohnson34@gmail.com
license: CC-BY-4.0
keywords: geotoolz, modeling-cycle, L0-L4, benchmarks, six-step-cycle
---

# Report 16 — The data-driven modeling cycle and benchmark-gated L0–L4 refinement

|                       |                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
|-----------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|**Status**             |Scoping proposal — committed                                                                                                                                                                                                                                                                                                                                                                                                                      |
|**Reading time**       |~25 min                                                                                                                                                                                                                                                                                                                                                                                                                                           |
|**Decisions locked in**|The six-step cycle is the third organising axis (alongside the modeling cycle and L0–L4). Step 2 (model-based inference) is structurally promoted to *oracle* — classical DA stays alive forever as ground-truth generator, not as legacy code. Benchmarks are formalised understanding, not just competitive scoring. A new `CycleStageBenchmark` pattern in pipekit-evaluate v0.2. Both physics-first and data-first entry points are supported.|
|**Audience**           |Anyone trying to understand how research-to-production iteration works in the stack — and how benchmarking at every L0–L4 step is what closes the loop                                                                                                                                                                                                                                                                                            |
|**Companion reports**  |`geostack_vision.md`, Report 0 (intro), Reports 10/11/12/14/15, `benchmark_gallery.md`                                                                                                                                                                                                                                                                                                                                                                 |

## What this report does

The vision document has two organising axes — the modeling cycle (research loop) and the L0–L4 data tier (data lifecycle). The reports we’ve written assume a third axis without naming it: **the data-driven modeling cycle that takes a research idea from “we have a forward model” to “we have a deployed amortized predictor.”** This report names that axis, maps each step to stack pieces, and articulates how *benchmarking each step transition* is what makes the L0–L4 chain operationally improvable.

The deeper claim — the one this report is built around — is **benchmarks as formalised understanding**. Designing a benchmark is the act of saying what you know about a problem: what carriers it has, what reference data is meaningful, what metrics distinguish real progress from gaming, what failure modes you expect. If you can write the contract, you’ve formalised your understanding; if you can’t, you don’t yet understand the problem.

These two pieces — the six-step cycle and benchmark-gated refinement — are duals of the same loop. Both rest on content-addressing. Both need oracles. Both make every component independently upgradeable.

-----

## Part 1 — The six-step cycle, named

Faithful to the framing already used in `plumax`:

```
   ┌─────────────────────────────────────────────────────────────┐
   │                                                             │
   │   (1)  Simple Model                                         │
   │         │   a generative story; a known mathematical        │
   │         │   structure you can simulate from                 │
   │         ▼                                                   │
   │   (2)  Model-Based Inference          ◄── ORACLE for 3,4,5  │
   │         │   slow but exact; the gold standard against       │
   │         │   which everything downstream is validated        │
   │         ▼                                                   │
   │   (3)  Model Emulator       (skip if forward model is cheap)│
   │         │   neural surrogate trained on Step 1 simulations  │
   │         │   100-1000× speedup; differentiable               │
   │         ▼                                                   │
   │   (4)  Emulator-Based Inference                             │
   │         │   Step 2 again, but seconds instead of hours      │
   │         │   tractable at operational scale                  │
   │         ▼                                                   │
   │   (5)  Amortized Inference (Predictor)                      │
   │         │   collapse the inference loop entirely; predictor │
   │         │   learns the posterior map directly: obs → params │
   │         ▼                                                   │
   │   (6)  Improve  ──────────────────────────────────────────┐ │
   │         ↑    upgrade model / data / emulator / predictor  │ │
   │         │    with previous step as ground truth           │ │
   │         └────────────────────────────────────────────────-┘ │
   │                                                             │
   └─────────────────────────────────────────────────────────────┘
```

### 1.1 Mapping to stack pieces

Each step has a concrete home in the stack:

|Step                           |What it produces                                                        |Where it lives                                                                                                        |
|-------------------------------|------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------|
|**1. Simple Model**            |A `ForwardModel`-shaped operator that integrates physics forward in time|**Tier 3 — Domain Models** (`somax`, `plumax`, `RTMX`, etc.) plus `pipekit-cycle.ForwardModel` Protocol               |
|**2. Model-Based Inference**   |A complete DA / inversion pipeline producing posterior distributions    |**`pipekit-cycle.DACycle`** with classical analysis steps from `filterX` (EnKF) or `vardaX` (4D-Var)                  |
|**3. Model Emulator**          |A neural surrogate of the Step 1 forward model                          |**`pipekit-train.SimulationDataset`** + `TrainingLoop` → emulator registered in **`pipekit-experiment.ModelRegistry`**|
|**4. Emulator-Based Inference**|Step 2 with the emulator swapped in                                     |**`pipekit-cycle.DACycle`** with `NeuralForward(model_op=registry.load(...))` — same cycle shape, different forward   |
|**5. Amortized Inference**     |A direct predictor: observations → posterior parameters                 |**`pipekit-train`** with `pyrox-nn` or `gaussFlowX` conditional density estimators registered in `ModelRegistry`      |
|**6. Improve**                 |Identify what failed; upgrade the relevant component                    |**`pipekit-evaluate.EvaluationReport`** diffs + **`pipekit-experiment`** lineage tracking                             |

The stack already supports every step. What’s been missing is **naming the cycle as the organising research-to-production loop** and committing to the structural implications.

### 1.2 The code already exists — here’s how the steps compose

```python
import pipekit as pk
import pipekit_cycle as pc
import pipekit_train as pt
import pipekit_experiment as px

# ─── STEP 1: Simple Model ──────────────────────────────────────
# Already in plumax / somax / RTMX
from plumax import PlumeForward
forward = PlumeForward(species="CH4", dt=3600.0)

# ─── STEP 2: Model-Based Inference (the ORACLE) ────────────────
# Classical DA using the forward model
from filterx.adapters.pipekit import EnKFAnalysis
from plumax.adapters.pipekit import ColumnObs

oracle_da = pc.DACycle(
    forward_model=forward,
    obs_op=ColumnObs(instrument="TROPOMI"),
    analysis_step=EnKFAnalysis(inflation=1.05),
    n_steps=24,
)
# Register the oracle artifact — it's the ground truth for downstream
registry = px.S3ModelRegistry(...)
oracle_hash = registry.store(
    oracle_da, 
    name="methane_da_oracle_v1",
    tags={"role": "oracle", "cycle_step": 2},
)

# ─── STEP 3: Model Emulator ────────────────────────────────────
# Train a neural surrogate of the forward model
emulator_dataset = pt.SimulationDataset(
    forward_model=forward,
    prior=AtmosphericPrior(distribution="climatology"),
    n_samples=10_000,
)
emulator_loop = pt.TrainingLoop(
    model_op=pa.ModelOp(ChemistryEmulatorNet()),
    dataset=pt.CachedDataset(source=emulator_dataset, cache_dir="..."),
    loss=pt.MSE(),
    n_epochs=100,
    backend="lightning",
)
emulator_op = emulator_loop.run()
emulator_hash = registry.store(
    emulator_op,
    name="methane_emulator_v3",
    tags={
        "role": "emulator", 
        "cycle_step": 3,
        "oracle_ref": oracle_hash,           # ← lineage
    },
)

# ─── STEP 4: Emulator-Based Inference ──────────────────────────
# Same DACycle structure as Step 2, with emulator forward model
fast_da = pc.DACycle(
    forward_model=pc.NeuralForward(           # ← swapped
        model_op=registry.load("methane_emulator_v3"),
        dt=3600.0,
    ),
    obs_op=ColumnObs(instrument="TROPOMI"),   # same
    analysis_step=EnKFAnalysis(inflation=1.05), # same
    n_steps=24,
)
fast_da_hash = registry.store(
    fast_da,
    name="methane_fast_da_v3",
    tags={
        "role": "production",
        "cycle_step": 4,
        "oracle_ref": oracle_hash,           # still evaluated against Step 2
    },
)

# ─── STEP 5: Amortized Inference (Predictor) ───────────────────
# Direct posterior predictor: observations → source parameters
from pyrox_nn.adapters.pipekit_train import ConditionalNormalizingFlow

amortized_loop = pt.TrainingLoop(
    model_op=ConditionalNormalizingFlow(
        n_dim=4,                              # 4 source parameters
        condition_dim=...,
        flow_type="masked_autoregressive",
    ),
    dataset=emulator_dataset,                 # same simulator data
    loss=pt.NLL(),
    n_epochs=200,
    backend="equinox",
)
predictor_op = amortized_loop.run()
predictor_hash = registry.store(
    predictor_op,
    name="methane_predictor_v3",
    tags={
        "role": "predictor",
        "cycle_step": 5,
        "oracle_ref": oracle_hash,
    },
)

# ─── STEP 6: Improve ───────────────────────────────────────────
# Compare predictor (Step 5) against oracle (Step 2)
import pipekit_evaluate as pe

eval_v3 = pe.MultiTrackEvaluation(
    evaluation_pipeline=evaluation,
    references={"oracle": oracle_artifact, ...},
)
report_v3 = eval_v3.run(predictions=predictor_op_outputs)

# Did the predictor match the oracle? If not, where did it fail?
diff = report_v3.diff(report_v2)
# Use the diff to decide what to upgrade — emulator? training data? predictor architecture?
```

The whole cycle is six trained / registered artifacts with explicit lineage. Each artifact knows what produced it; each knows its oracle.

-----

## Part 2 — Step 2 as oracle: a structural commitment

This is the load-bearing claim. Worth being explicit about its implications.

### 2.1 The commitment

**Step 2 (classical model-based inference) is not legacy code to be replaced by neural emulators.** It is the *ground-truth generator* against which Steps 3, 4, and 5 are validated. The classical path stays alive forever; it gets promoted to oracle status.

This means:

- `filterX`, `vardaX`, `pyrox-gp` (the classical algorithm libraries) are **never deprecated**. They are the only thing that can validate the neural alternatives.
- Classical DA pipelines (Step 2) must remain runnable on production data, not just historical archives. The oracle has to be able to score new submissions.
- Compute budget for oracle runs is a permanent operational cost, not a one-time validation expense.

### 2.2 Why this is non-obvious

The temptation in ML-driven geoscience is to treat classical methods as the thing being replaced. **This framing is wrong.** Classical methods produce posteriors with known approximation errors and known computational cost. Neural surrogates produce posteriors with unknown approximation errors and low computational cost. **You cannot validate the latter without the former.** A neural emulator that “matches the data” without matching the classical oracle has only learned the data’s correlations, not the underlying physics.

The honest formulation: classical methods become **slow, expensive, validated, trustworthy**. Neural methods become **fast, cheap, fast-to-iterate, validated against the classical oracle**. Both are needed; neither replaces the other.

### 2.3 Implementation: oracle tagging in the model registry

Concrete change to `pipekit-experiment.ModelRegistry`: artifacts get a `role` tag.

```python
class ModelRole(str, Enum):
    ORACLE = "oracle"           # ground-truth generator (Step 2)
    EMULATOR = "emulator"       # surrogate of Step 1 (Step 3)
    PRODUCTION = "production"   # operational path (Step 4)
    PREDICTOR = "predictor"     # amortized (Step 5)
    BASELINE = "baseline"       # benchmark baseline (separate axis)
```

Plus a small `lineage` field tracking which oracle each non-oracle artifact was validated against:

```python
@dataclass
class ArtifactLineage:
    oracle_hash: str | None       # the oracle this was validated against
    parent_hashes: list[str]      # earlier-step artifacts in the cycle
    training_artifact: str | None # the training run that produced this
    benchmark_results: list[str]  # EvaluationReport hashes
```

This makes “which oracle was this benchmarked against?” a one-line registry query. Lineage closes.

-----

## Part 3 — Benchmarks as formalised understanding

The deeper epistemic claim. Worth treating as a first-class principle of the stack.

### 3.1 The claim

**Writing a benchmark contract is the act of formalising what you understand about a problem.** Specifically, the contract declares:

- What the **carriers** are (input shape, output shape) — formalises *what the problem operates on*
- What the **reference data** is — formalises *what truth means*
- What the **metrics** are — formalises *what counts as success*
- What the **splits** are — formalises *what generalisation means*
- What the **baselines** are — formalises *what’s already known*
- What the **failure modes** are — formalises *what’s been seen to go wrong*

If you can write all six, you understand the problem. If you can’t write any one of them, you don’t yet — and the gap shows you exactly what to learn.

### 3.2 The implication

This reframes benchmarks from “competitive scoring of methods” to **operationalised hypotheses about a problem domain**. The audience for a benchmark contract isn’t only other ML teams — it’s:

- **Your future self** when you forget why you chose what you chose
- **Anyone trying to understand the problem you understood**
- **Domain scientists** reviewing whether you’re measuring the right thing
- **Auditors** verifying that reported scores match the contract
- **Reviewers** of your scientific output

The benchmark contract is **documentation in the strongest sense** — executable documentation that any submission can be tested against. It’s the closest thing to a falsifiable claim that ML practice produces.

### 3.3 Connection to the cycle

The two are duals. The data-driven modeling cycle improves the *method*; the benchmark refinement cycle improves the *understanding*. Both are recursive; both rest on content-addressing; both need oracles:

```
   ┌──────────────────────────────────────────────────────────────┐
   │             Modeling cycle           │     Benchmark cycle   │
   │            (research)                │    (validation)       │
   │            ─────────                 │    ──────────         │
   │   1.  Simple model                   │  Initial contract     │
   │   2.  Model-based inference (oracle) │  Reference baselines  │
   │   3.  Model emulator                 │  Updated metrics      │
   │   4.  Emulator-based inference       │  Iteration-1 leaders  │
   │   5.  Amortized inference            │  Pre-registered v2    │
   │   6.  Improve  ← previous as truth   │  Improve ← prev as    │
   │                                      │      backward-compat  │
   └──────────────────────────────────────────────────────────────┘
```

**The act of designing a Step-N→Step-N+1 transition forces the design of a Step-N-vs-Step-N+1 benchmark.** They co-evolve. This is what makes the L0–L4 chain operationally improvable.

-----

## Part 4 — Applying the cycle across L0–L4: the matrix

The crucial move: **the six-step cycle applies at every L0–L4 transition.** Each L0–L4 step is itself a research-to-production loop with six stages.

```
   ┌────────────────────────────────────────────────────────────────────┐
   │                Step 1     Step 2     Step 3     Step 4    Step 5  │
   │                Simple     Model      Emulator   Emulator  Amortzd │
   │                Model      Inference  (skip if   Inference Inferen.│
   │                                       cheap)                       │
   │  ──────────────────────────────────────────────────────────────────│
   │                                                                    │
   │  L0→L1         Cal +      Cross-     Learned    Fast      Direct   │
   │  (cal/geo)     geoloc     calib      cal        cal       cal      │
   │                model      model      emulator   inference predict. │
   │                                                                    │
   │  L1→L2         RT         Matched    Neural     Fast      Direct   │
   │  (retrieval)   model      filter,    RT         retrieval retrieval│
   │                           BAEMR      emulator             model    │
   │                                                                    │
   │  L2→L3         GP         Kriging,   Neural     Fast      Neural   │
   │  (gap-fill,    prior;     DINEOF,    mapping    gap-fill  gap-fill │
   │   gridding)    interp.    objective  emulator             posterior│
   │                model      analysis                                 │
   │                                                                    │
   │  L3→L3         Forward    EnKF,      Neural     Neural    Direct   │
   │  (analysis)    model +    4D-Var     forward,   DA        analysis │
   │                priors                neural               predict. │
   │                                      obs op                        │
   │                                                                    │
   │  L3→L4         PDE        Forward    Neural     Emulator  Neural   │
   │  (forecast)    forward    integ-     forward    forecast  fore-    │
   │                           ration                          caster   │
   │                                                                    │
   └────────────────────────────────────────────────────────────────────┘
```

That’s a 5×5 matrix (Step 6 is the meta-step “improve”). **Each cell is a concrete benchmarkable artifact.** Each cell uses the previous column as oracle.

### 4.1 Worked example: the L1→L2 retrieval row

The methane retrieval case, fleshed out:

|Cell                       |Artifact                                                                         |Stack mapping                                                                      |
|---------------------------|---------------------------------------------------------------------------------|-----------------------------------------------------------------------------------|
|**L1→L2, Step 1**          |Radiative transfer forward model (radiance = f(state))                           |`RTMX.RTM` or external `pyMieScatt` / LBLRTM wrapper, exposed as `ForwardModel`    |
|**L1→L2, Step 2**          |Matched-filter or BAEMR retrieval (classical inverse, the oracle)                |`geotoolz.matched_filter.CH4MatchedFilter`; produces retrieved L2 with known biases|
|**L1→L2, Step 3**          |Neural RT emulator (radiance = NN(state); 100× faster than Step 1)               |`pipekit-train.SimulationDataset(forward=RTM)` → trained ModelOp                   |
|**L1→L2, Step 4**          |Inverse retrieval using the emulator (differentiable; tractable at scale)        |`pipekit-cycle.Recurrence` for iterative LM retrieval using NeuralForward          |
|**L1→L2, Step 5**          |Direct retrieval network (radiance → L2 in one forward pass; no explicit inverse)|`pipekit-train.TrainingLoop` with a regression network; trained on Step 4 outputs  |
|**L1→L2, Step 6 (improve)**|Compare Step 5 against Step 2 oracle; identify regime where they diverge; retrain|`pipekit-evaluate.MultiTrackEvaluation` + lineage diff                             |

The benchmark contract for this row exists at every column transition:

- **Step 1→2 contract**: “Does classical retrieval recover known plumes from controlled releases (METEC)?” — fully physics-grounded.
- **Step 2→3 contract**: “Does the emulator reproduce the physical RT model’s output spectra within tolerance?” — pure simulation match.
- **Step 3→4 contract**: “Does emulator-based retrieval produce the same column values as Step 2 retrieval?” — oracle comparison.
- **Step 4→5 contract**: “Does the direct predictor match Step 4 retrieval outputs across the operating distribution?” — amortization match.

Each contract is a `CycleStageBenchmark` (see Part 6 below). Each is pre-registerable. Each tracks lineage automatically.

### 4.2 The same matrix for the L3→L4 forecast row

|Cell             |Artifact                                                                             |
|-----------------|-------------------------------------------------------------------------------------|
|**L3→L4, Step 1**|Physical forward model (PDE solver: plumax / somax)                                  |
|**L3→L4, Step 2**|DA cycle using the physical forward as ground-truth analysis path                    |
|**L3→L4, Step 3**|Neural emulator of the PDE forward (the GraphCast / FourCastNet pattern)             |
|**L3→L4, Step 4**|DA cycle using the neural emulator as forward model                                  |
|**L3→L4, Step 5**|Direct forecast network (initial state → forecast, no DA loop)                       |
|**L3→L4, Step 6**|Compare emulator forecast against PDE forecast; compare predictor against emulator-DA|

Same structure. Different scientific domain. Same six steps. Same benchmark cycle.

### 4.3 What this matrix implies for the framework

**Every cell is independently improvable.** Improving Step 1 (better physics) → re-run Steps 2-5. Improving Step 3 (better emulator) → re-run Steps 4-5. Improving Step 5 (better predictor) → just retrain.

**Each improvement is content-addressed.** A new emulator gets a new hash; downstream artifacts that depended on the old one are tagged as stale; the lineage graph shows what needs re-running.

**The matrix is not idealised theory** — it’s how every real ocean / atmospheric / chemistry ML pipeline already works informally. The framework’s contribution is making the informal structure explicit, executable, and content-addressed.

-----

## Part 5 — Physics-first vs data-first entry points

Honest pushback: the cycle as described assumes you *have* a Step 1 forward model. Many real benchmarks don’t. The framework needs to support both entry points.

### 5.1 Physics-first (the textbook case)

- **Step 1**: A known forward model (PDE, RT, dispersion).
- **Step 2**: Classical inverse using Step 1.
- **Steps 3–5**: Neural surrogates and amortized predictors.

Examples from the gallery:

- L3→L4 forecast (somax / plumax PDE forward)
- L1→L2 retrieval (RTM forward)
- L3→L3 analysis (forward + obs op + analysis)

### 5.2 Data-first (the modern ML case)

- **Step 1**: A labelled dataset (the “generative story” is whatever produced the labels — often unobserved).
- **Step 2**: A classical supervised baseline (logistic regression, classical features, OI).
- **Steps 3–5**: Better representations, finetuned models, end-to-end predictors.

Examples from the gallery:

- Cloud-mask classification (labelled cloud masks, no clean forward model)
- Multispectral-hyperspectral fusion (paired observations, no underlying physics process)
- Satellite operator emulation (pre-launch characterisation + on-orbit calibration data)

### 5.3 The asymmetry

In physics-first, Step 2 is the *oracle in the strong sense*: it has well-characterised approximation errors and known asymptotic behaviour. Neural surrogates can be validated against it confidently.

In data-first, Step 2 is the *oracle in the weak sense*: it’s the best classical method on the data, but the labels themselves may be uncertain (cloud masks have annotator disagreement; matchup labels have representativeness errors). Neural alternatives can match the oracle and still be wrong because the oracle is wrong.

**Both flows benefit from the cycle and the benchmark discipline**, but the strength of the validation claim differs. The framework should support both — and be explicit when oracle-strength is weak.

### 5.4 How the framework handles both

`CycleStageBenchmark` carries an `oracle_strength` field:

```python
class OracleStrength(str, Enum):
    PHYSICS_DERIVED = "physics_derived"      # Step 1 is a known forward model
    CLASSICAL_METHOD = "classical_method"    # Step 2 is well-validated; e.g., OI
    HUMAN_LABELS = "human_labels"            # labels have annotator uncertainty
    HEURISTIC = "heuristic"                  # the oracle itself is approximate
```

Benchmark contracts report this honestly. A `HEURISTIC` oracle is a useful reference but not ground truth. Submissions that match the oracle still need physical-plausibility checks. This is just the source’s section on “process evaluation” applied at the cycle level.

-----

## Part 6 — The new pattern: `CycleStageBenchmark`

A small extension to `pipekit-evaluate.benchmark` (added to Report 15’s scope). v0.2.

### 6.1 The class

```python
@dataclass(frozen=True)
class CycleStageBenchmark(BenchmarkContract):
    """A benchmark contract for a specific cycle-step transition.
    
    Extends BenchmarkContract with cycle-step lineage.
    """
    # Cycle position
    target_step: Literal[1, 2, 3, 4, 5]    # which step is being evaluated
    oracle_step: Literal[1, 2, 3, 4]       # which step provides ground truth
    
    # Where in the L0-L4 chain
    l_transition: Literal["L0_L1", "L1_L2", "L2_L3", "L3_L3", "L3_L4"]
    
    # Oracle artifact (the previous step's output)
    oracle_artifact_hash: str              # ModelRegistry hash
    oracle_strength: OracleStrength
    
    # Inherited from BenchmarkContract
    # name, version, task, carrier specs, references, splits, metrics, ...
    
    def verify_lineage(self, registry: ModelRegistry) -> bool:
        """Verify the oracle artifact still exists and is reachable."""
    
    def required_metrics(self) -> list[Metric]:
        """The metrics that MUST be reported for this cycle stage."""
        # Step 3 evaluation requires emulator-vs-oracle PSD comparison
        # Step 4 evaluation requires posterior coverage tests
        # Step 5 evaluation requires amortization-error bounds
```

### 6.2 The MultiStageCycleBenchmark composition

A higher-order pattern: one benchmark per cycle step, composed into a complete cycle benchmark:

```python
@dataclass
class CycleBenchmark:
    """A complete six-step cycle benchmark.
    
    Links the per-step benchmarks via shared lineage.
    """
    name: str
    domain: str                            # e.g., "methane_l1_l2"
    stages: list[CycleStageBenchmark]      # one per Step 2-5
    
    def run_full_cycle(self, candidate_artifacts: dict[int, str]) -> CycleReport:
        """Score a candidate against all stages of the cycle.
        
        candidate_artifacts maps step_number → artifact_hash.
        Each is benchmarked against its declared oracle.
        """
```

### 6.3 Example usage

```python
methane_retrieval_cycle = pe.CycleBenchmark(
    name="methane_retrieval_l1_l2",
    domain="methane_l1_l2",
    stages=[
        pe.CycleStageBenchmark(
            name="rt_emulator",
            target_step=3,
            oracle_step=1,                  # neural emulator vs physical RTM
            l_transition="L1_L2",
            oracle_artifact_hash="...physical_rtm_hash...",
            oracle_strength=OracleStrength.PHYSICS_DERIVED,
            ...
        ),
        pe.CycleStageBenchmark(
            name="emulator_inverse",
            target_step=4,
            oracle_step=2,                  # emulator inverse vs classical matched filter
            l_transition="L1_L2",
            oracle_artifact_hash="...matched_filter_oracle_hash...",
            oracle_strength=OracleStrength.CLASSICAL_METHOD,
            ...
        ),
        pe.CycleStageBenchmark(
            name="direct_retrieval",
            target_step=5,
            oracle_step=4,                  # direct predictor vs emulator inverse
            l_transition="L1_L2",
            oracle_artifact_hash="...emulator_inverse_hash...",
            oracle_strength=OracleStrength.CLASSICAL_METHOD,
            ...
        ),
    ],
)

# Score a complete set of candidate artifacts
cycle_report = methane_retrieval_cycle.run_full_cycle(
    candidate_artifacts={
        3: emulator_hash,
        4: emulator_inverse_hash,
        5: predictor_hash,
    }
)
```

Estimated effort: **~1 week** of work added to `pipekit-evaluate.benchmark` v0.2. Composes existing pieces; no new infrastructure beyond the cycle-step lineage fields.

-----

## Part 7 — Recommended edits to existing docs

The six-step cycle and benchmark-as-understanding framing are structurally important enough that several existing docs need updates.

### 7.1 — `geostack_vision.md`

Add **a third organising axis** to the existing two (modeling cycle, L0–L4):

- New section after “Data Tiers: The L0–L4 Axis” titled **“The Six-Step Cycle: From Simple Model to Amortized Predictor”**
- Include the ASCII cycle diagram from Part 1
- Note that the modeling cycle, the L0–L4 axis, and the six-step cycle are three orthogonal lenses on the same architecture
- Add a “Benchmarks as Formalised Understanding” callout in the design principles section

### 7.2 — `../master_plan/toolz_0_overview.md`

Section 3 (“Two organising axes”) becomes **“Three organising axes”**:

1. Modeling cycle (research loop) — unchanged
2. L0–L4 data tier (data lifecycle) — unchanged
3. **Six-step cycle (research-to-production)** — new

This makes the introduction document reflect the full structure of the framework. Adds ~30 lines.

### 7.3 — `../master_plan/toolz_9_pipekit_train.md`

Explicitly name that the three training shapes already covered (direct supervised, emulator, amortized inference) **are Steps 3 and 5 of the modeling cycle**. Adds a small section “Where Training Fits in the Six-Step Cycle” linking the existing content to the cycle framework. ~50 lines.

### 7.4 — `../master_plan/toolz_11_pipekit_evaluate.md`

Add a section “Evaluation as Cycle-Stage Validation” — each step transition is a benchmarkable contract; pipekit-evaluate is what makes them executable. Connects the Unit × Lens × Stage matrix to the cycle-step matrix. ~80 lines.

### 7.5 — `benchmark.md`

Update Part 9 (“Effort and timing”) to add the `CycleStageBenchmark` extension as a v0.2 deliverable. Update Part 8 (tradeoffs) to note that the cycle framing strengthens the case for pre-registration — because each cycle-step transition is a hypothesis, and pre-registration is what makes hypotheses falsifiable. ~30 lines.

### 7.6 — `benchmark_gallery.md`

The gallery already implicitly uses the cycle structure (each benchmark has classical baselines + neural variants). Add a cross-reference: **the 23 benchmarks instantiate cells in the 5×5 cycle matrix**. A new appendix section that maps each gallery entry to its (transition, step) coordinates. ~100 lines.

-----

## Part 8 — Honest tradeoffs

### 8.1 What gets better

1. **The research-to-production journey is named and structured.** “We have a forward model” → “we have a deployed predictor” is a six-step path with concrete artifacts at each step. No more “we hope this works.”
2. **Classical methods are first-class citizens.** Step 2 as oracle reframes “classical vs ML” from competition to collaboration. Both are needed.
3. **Every step transition is benchmarkable.** No more “we built an emulator and it seems to work.” Now there’s a contract: does the emulator match the oracle within tolerance?
4. **Improvement is targeted.** When the amortized predictor (Step 5) fails on a region, the lineage tells you whether to retrain the predictor (Step 5), retrain the emulator (Step 3), or improve the physical model (Step 1). No more guessing.
5. **The benchmark-as-formalised-understanding framing changes what benchmarks are for.** They become operationalised hypotheses, not just leaderboards.

### 8.2 What gets harder

1. **More artifacts to track.** A complete cycle for one L0–L4 transition is 5 artifacts (Steps 1–5), each with lineage to the previous. Across all 5 L0–L4 transitions, that’s 25 artifacts per domain. Mitigation: `pipekit-experiment.ModelRegistry` already handles content-addressing; the lineage graph is small (linear chain per cycle, fan-out across transitions).
2. **Step 2 as permanent oracle is a real operational cost.** Classical DA runs cost compute. Maintaining a runnable oracle for every production deployment is non-trivial. Mitigation: amortize over multiple downstream evaluations; oracle runs are typically lower-frequency than production inference.
3. **The matrix view is daunting.** A 5×5 matrix per domain across multiple domains is a lot. Mitigation: start with one domain (methane), prove the pattern works, then replicate.
4. **The data-first vs physics-first asymmetry is real.** Many benchmarks don’t have strong oracles. The framework supports both, but oracle-weak benchmarks need additional physical-plausibility checks. Mitigation: `oracle_strength` field forces honest declaration; process-evaluation lens from Report 14 provides the additional checks.

### 8.3 What this doesn’t try to be

- **A replacement for the modeling cycle.** The six-step cycle is *added to* the existing modeling cycle, not in place of it. Both are needed: the modeling cycle is the research loop; the six-step cycle is the production loop.
- **A workflow tool.** It doesn’t tell you how to do science. It tells you how to package science into composable, benchmarkable, improvable artifacts.
- **A guarantee.** Following the cycle doesn’t guarantee good results. It guarantees *traceable* results.

-----

## Part 9 — Open questions

1. **How strict should “oracle_strength” enforcement be?** Should `pipekit-evaluate` refuse to run a Step 5 vs Step 2 comparison if the oracle is `HEURISTIC`? Or just warn? Lean: warn, don’t refuse — informed users may have legitimate reasons.
2. **Can the cycle be entered mid-way?** What if you’re handed a trained emulator without access to the underlying Step 1 model? You can run Steps 3–5 against the emulator as oracle, but lineage to physics is lost. Lean: support this with a `synthetic_oracle` flag; mark all downstream as physics-unverified.
3. **What about cycles that skip Step 3 (cheap forward models)?** The text explicitly notes “skip if model is cheap”. The framework should treat Step 3 as optional but not Step 2. Lean: yes, optional; `CycleBenchmark` allows omitting Step 3 with explicit declaration.
4. **Cross-domain cycles.** Some real workflows mix domains (e.g., methane retrieval feeds into ocean carbon-cycle DA). The cycle is per-domain; how do composite workflows handle it? Lean: each domain has its own cycle; cross-domain integration happens at the pipeline composition level, not inside the cycle.
5. **How does this interact with `pipekit-jax` (deferred)?** Step 3 emulators are often the things that most benefit from JAX-traceability (differentiable forward models enable gradient-based inverse problems at Step 4). Pipekit-jax timing may be project-driven by exactly this need. Worth flagging in the planning.

-----

## Part 10 — Where this lands in the plan

The cycle framework itself is **mostly documentation and small extensions**, not new infrastructure. It’s lower-cost than most of the other work because the underlying packages (`pipekit-cycle`, `pipekit-train`, `pipekit-experiment`, `pipekit-evaluate`) already support the cycle without naming it.

|Deliverable                                                             |Effort  |Phase                             |
|------------------------------------------------------------------------|--------|----------------------------------|
|Updates to `geostack_vision.md`, Report 0, Reports 11/14/15, gallery          |~3 days |Now (documentation refresh)       |
|`ModelRole` enum and `ArtifactLineage` in `pipekit-experiment`          |~1 week |Phase 4, alongside experiment v0.1|
|`CycleStageBenchmark` + `CycleBenchmark` in `pipekit-evaluate.benchmark`|~1 week |Phase 5, alongside evaluate v0.2  |
|First worked cycle (probably methane L1→L2) end-to-end                  |~2 weeks|Phase 5, demonstration            |
|Documentation: cycle patterns guide                                     |~3 days |Phase 5, alongside above          |

**Total: ~5 weeks** of work spread across Phases 4-5. Most of it is documentation and small framework additions; the substantive infrastructure is already scoped in earlier reports.

-----

## Closing summary

The data-driven modeling cycle and benchmark-gated L0–L4 refinement are **the missing organising principle for the research-to-production journey** in the GeoStack. The six-step cycle (Simple Model → Model-Based Inference → Emulator → Emulator-Based Inference → Amortized Inference → Improve) is what every domain library implicitly follows; making it explicit gives the stack operational discipline.

**Step 2 as oracle** is the structural commitment that makes the cycle work — classical methods stay alive forever as ground-truth generators, not as legacy code to be replaced. **Benchmarks as formalised understanding** is the epistemic claim that makes the benchmark cycle a research tool, not just a leaderboard. Together, they make the L0–L4 chain operationally improvable: every step transition is a contract, every contract has an oracle, every artifact has lineage.

The framework changes are small: a `ModelRole` enum, an `ArtifactLineage` field, a `CycleStageBenchmark` extension, and documentation updates across five existing docs. The infrastructure was already scoped. What this report adds is the *naming* of the cycle as the third organising axis of the stack — alongside the modeling cycle (research) and the L0–L4 axis (data) — and the recognition that **every L0–L4 transition is its own six-step cycle**, with the whole chain forming a nested set of improvable, benchmarkable, content-addressed loops.

This is what completes the framework’s epistemic story. The vision document said “build the substrate so the cycle is composable.” The reports scoped the substrate. This report names the cycle and shows it was already there.