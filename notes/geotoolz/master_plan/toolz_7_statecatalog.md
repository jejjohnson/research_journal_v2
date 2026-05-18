---
title: "Report 13 — `statecatalog`: catalog for model states"
subject: geotoolz master plan
short_title: "R13 — statecatalog"
authors:
  - name: J. Emmanuel Johnson
    affiliations:
      - UNEP
      - IMEO
      - MARS
    orcid: 0000-0002-6739-0053
    email: jemanjohnson34@gmail.com
license: CC-BY-4.0
keywords: geotoolz, statecatalog, model-states, L3, L4, catalog
---

# Report 13 — `statecatalog`: catalog for model states

|                       |                                                                                                                                                                                      |
|-----------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|**Status**             |Scoping proposal — committed                                                                                                                                                          |
|**Reading time**       |~20 min                                                                                                                                                                               |
|**Decisions locked in**|Sibling of `geocatalog`, not subclass of it. `StateSlice` (the wire format) lives in `statecatalog`. Ensemble + lineage support is in v0.1, not bolted on later. Monorepo development.|
|**Audience**           |Anyone reviewing how model outputs (forecasts, analyses, reanalysis) get indexed                                                                                                      |
|**Companion reports**  |Report 6 (`geocatalog`), Report 10 (`pipekit-cycle`); the other Reports 1–9 for ecosystem context                                                                                     |

## Part 1 — The problem `statecatalog` solves

`geocatalog` indexes **observations**: “this S3 URI is a scene covering this bbox at this time.” That’s correct for L0–L2 where data has one timestamp and one place.

Model outputs are different. A forecast has:

- **`valid_time`** — the time the forecast predicts about (“what does the atmosphere look like at noon UTC?”)
- **`run_time`** (a.k.a. initialisation time) — when the forecast was launched
- **`lead_time = valid_time - run_time`** — how far ahead the forecast looks
- **`ensemble_member`** — which realization, or `None` for deterministic runs
- **`model_config_hash`** — which model + config produced it
- **`parent_state_uri`** — the analysis (or earlier forecast) it was launched from

The “what time is this data” question has two answers (valid_time, run_time), plus an ensemble dimension, plus lineage. None of this fits `geocatalog.GeoSlice` cleanly. **Forcing it into geocatalog would corrupt the abstraction**; a `GeoSlice` extended with model-state semantics stops being “a bounded request for observation data.”

The honest answer: a parallel catalog for model states, with its own wire format. `statecatalog` parallels `geocatalog` in shape, but with the model-state dimensions baked in from day one.

## Part 2 — Where `statecatalog` sits in the stack

```
   Domain libraries           geotoolz │ xr_toolz
                                  ▲
                                  │
   Infrastructure        ┌─ pipekit-cycle ─┐    Reads/writes
                         │  (Report 10)   │  ──▶ statecatalog  ◄── (this report)
                         └────────────────┘
                                  ▲                  ▲
                                  │                  │
   Framework                  pipekit          ┌─ georeader ─┐
                                                │   (reads     │
                                                │   state data) │
                                                └──────────────┘
```

Three observations:

1. **Sibling of `geocatalog`**, not a subclass. They share the Protocol-shaped design pattern but their wire formats and query semantics differ enough that subclassing would be confusing.
2. **Primary writer is `pipekit-cycle`.** When a `DACycle` or `Cycle` writes its history of analysed/forecast states, it writes through `statecatalog`. Primary reader is also `pipekit-cycle` (when loading initial conditions for cycles) and ML training (`pipekit-train.SimulationDataset` may consume state trajectories as training data).
3. **No pipekit dependency in core.** `statecatalog` is a queryable index. It does not import pipekit; pipekit-cycle imports statecatalog when needed.

## Part 3 — What’s in `statecatalog`

Five conceptual pieces, ~700 LOC plus an extras-gated DuckDB backend at ~400 LOC.

### 3.1 Source layout

```
statecatalog/
  __init__.py             # public re-exports
  _src/
    slice.py              # StateSlice — the wire format (the headline)
    base.py               # StateRow, StateCatalog Protocol
    memory.py             # InMemoryStateCatalog (in-memory pandas-backed)
    duckdb_backend.py     # DuckDBStateCatalog (extras-gated)
    queries.py            # Common query patterns: at_time, lead_window, lineage, ensemble
    streaming.py          # Streaming-write infrastructure (parallel to geocatalog's)
    parquet.py            # GeoParquet round-trip (with state-extension fields)
    integrations/
      pipekit.py          # CatalogReader / CatalogWriter Operators (extras-gated)
      cycle.py            # Direct integration with pipekit-cycle (extras-gated)
```

### 3.2 `StateSlice` — the wire format (`slice.py`)

The headline class. Frozen dataclass. Carries everything needed to identify and load a model state.

```python
@dataclass(frozen=True)
class StateSlice:
    """A bounded model-state request.
    
    Parallel to geocatalog.GeoSlice but for model outputs rather than
    observations. Carries the additional dimensions that model state
    requires.
    """
    # Spatial
    bbox: tuple[float, float, float, float]
    crs: str
    
    # Temporal — the key asymmetry vs GeoSlice
    valid_time: datetime              # what time the state is "about"
    run_time: datetime                # when the model run was launched
    
    # Model identity
    model_config_hash: str            # identifies the producing model + config
    model_name: str | None = None     # human-readable convenience tag
    
    # Ensemble
    ensemble_member: int | None = None        # None for deterministic runs
    ensemble_total: int | None = None         # total members in this ensemble
    
    # Lineage — the second key asymmetry
    parent_state_uri: str | None = None        # the state this run was launched from
    
    # Storage
    state_uri: str                    # where the actual state lives
    
    # Free-form metadata
    metadata: dict = field(default_factory=dict)
    
    @property
    def lead_time(self) -> timedelta:
        return self.valid_time - self.run_time
    
    @property
    def is_analysis(self) -> bool:
        """Analysis = valid_time == run_time (zero lead)."""
        return self.lead_time == timedelta(0)
    
    @property
    def is_forecast(self) -> bool:
        return self.lead_time > timedelta(0)
    
    @property
    def is_ensemble(self) -> bool:
        return self.ensemble_member is not None
    
    def to_dict(self) -> dict: ...
    @classmethod
    def from_dict(cls, d) -> "StateSlice": ...
```

The properties (`lead_time`, `is_analysis`, `is_forecast`, `is_ensemble`) make common queries readable. The structure makes ensemble + lineage support first-class, not bolted on later (per the “scoping cautions” from earlier).

### 3.3 The catalog Protocol (`base.py`)

```python
@dataclass(frozen=True)
class StateRow:
    """Backend-neutral row view. Carries enough to construct a StateSlice."""
    bbox: tuple
    crs: str
    valid_time: datetime
    run_time: datetime
    model_config_hash: str
    state_uri: str
    ensemble_member: int | None
    parent_state_uri: str | None
    metadata: dict

@runtime_checkable
class StateCatalog(Protocol):
    """Queryable index over model states.
    
    Implementations: InMemoryStateCatalog, DuckDBStateCatalog.
    Parallel to geocatalog.GeoCatalog Protocol.
    """
    @property
    def crs(self) -> str: ...
    @property
    def n_states(self) -> int: ...
    
    def iter_slices(self, **filters) -> Iterator[StateSlice]: ...
    def query(self, **filters) -> "StateCatalog": ...   # returns a subset catalog
    def to_pandas(self) -> pd.DataFrame: ...
```

### 3.4 The common query patterns (`queries.py`)

This is where state-catalog-specific querying lives. Each is a function that takes a `StateCatalog` and filter args, returning either a filtered `StateCatalog` or an iterator of `StateSlice`.

```python
def at_time(cat: StateCatalog, valid_time: datetime, *, 
            model_config_hash: str | None = None,
            ensemble_member: int | None = None) -> StateCatalog:
    """All states valid at this time. Picks across forecast lead times."""

def latest_analysis(cat: StateCatalog, *, 
                    before: datetime | None = None) -> StateSlice | None:
    """The most recent analysis (lead_time=0) before a given time."""

def forecast_chain(cat: StateCatalog, run_time: datetime, *,
                   model_config_hash: str,
                   ensemble_member: int | None = None) -> list[StateSlice]:
    """All forecast states from a given run, ordered by lead time."""

def lead_window(cat: StateCatalog, run_time: datetime, 
                lead_range: tuple[timedelta, timedelta], **filters) -> StateCatalog:
    """Forecasts with lead in [lead_min, lead_max]."""

def ensemble_at(cat: StateCatalog, valid_time: datetime, run_time: datetime,
                model_config_hash: str) -> list[StateSlice]:
    """All ensemble members for a given (valid_time, run_time) pair."""

def lineage(cat: StateCatalog, state_uri: str, *, 
            depth: int = -1) -> list[StateSlice]:
    """Trace the ancestral chain back through parent_state_uri.
    
    depth=-1 means trace to the root.
    Used to answer 'what observations / earlier states contributed to this?'
    """

def assimilation_window(cat: StateCatalog, run_time: datetime,
                        obs_catalog: "GeoCatalog",
                        window: timedelta) -> "GeoCatalog":
    """Given a model run, return the observation catalog filtered to the
    obs that were assimilated. Bridges statecatalog ↔ geocatalog.
    """
```

The last one (`assimilation_window`) is the **catalog-to-catalog bridge** that lets DA cycles record their provenance: “this analysis at this time pulled from this obs catalog over this window.”

### 3.5 Backends

Two backends, parallel to `geocatalog`:

```python
class InMemoryStateCatalog:
    """pandas-backed. Suitable for small-to-medium catalogs (< 1M rows).
    Used for testing, dev, and small research workflows.
    """
    df: pd.DataFrame
    
    def __init__(self, df: pd.DataFrame): ...
    @classmethod
    def empty(cls) -> "InMemoryStateCatalog": ...
    
    def append(self, slice: StateSlice): ...
    def append_many(self, slices: list[StateSlice]): ...

class DuckDBStateCatalog:
    """SQL-backed via DuckDB + GeoParquet. Suitable for very large catalogs
    (10M+ rows). Extras-gated: pip install statecatalog[duckdb].
    
    The schema includes a state_extension namespace in the GeoParquet
    metadata, parallel to geocatalog's catalog-extension.
    """
    parquet_uri: str
    
    def __init__(self, parquet_uri: str): ...
    @classmethod
    def open(cls, parquet_uri: str) -> "DuckDBStateCatalog": ...
```

### 3.6 Integration with `pipekit-cycle` (`integrations/cycle.py`)

The bridge module. Extras-gated behind `statecatalog[pipekit]` since it imports `pipekit-cycle`.

```python
class CycleStateWriter(StatefulOperator):
    """Write each step of a Cycle's history to a StateCatalog.
    
    Used as a callback inside DACycle / Cycle to persist state outputs.
    """
    state_catalog: StateCatalog
    model_config_hash: str

class CycleStateReader(Operator):
    """Read initial state for a cycle from a StateCatalog.
    
    Common pattern: 'start my cycle from the latest analysis before 06Z.'
    """
    state_catalog: StateCatalog
    query: Callable[[StateCatalog], StateSlice]
```

## Part 4 — Worked examples

### 4.1 Writing forecast outputs from a cycle

```python
import statecatalog as sc
import pipekit_cycle as pc

cat = sc.DuckDBStateCatalog.open("s3://reanalysis/methane_v3/states.parquet")
writer = sc.integrations.cycle.CycleStateWriter(
    state_catalog=cat,
    model_config_hash=pk.config_hash(forecast_op),
)

# A 72-hour ensemble forecast — each step writes to the catalog
forecast = pc.EnsembleCycle(
    step_op=pc.Sequential([
        chemistry_forward,
        writer,                       # ← writes each step's state
    ]),
    n_steps=72,
    n_members=40,
)

trajectory = forecast(initial_state, initial_carry_state)
# state catalog now has 72 × 40 = 2880 new StateSlice rows
```

### 4.2 Querying for the latest analysis

```python
import statecatalog.queries as q
from datetime import datetime

# What's the most recent analysis state available before 06Z today?
slice = q.latest_analysis(
    cat,
    before=datetime(2026, 5, 17, 6),
)

# Load the actual state through whatever reader is appropriate
state = georeader.read_from_url(slice.state_uri)
```

### 4.3 Spinning up a new cycle from the latest analysis

```python
reader = sc.integrations.cycle.CycleStateReader(
    state_catalog=cat,
    query=lambda c: q.latest_analysis(c, before=datetime.now()),
)

forecast = pc.Sequential([
    reader,                           # load initial state from catalog
    chemistry_forward,
    pc.Cycle(step_op=chemistry_forward, n_steps=72),
    writer,                           # write forecast states back
])

forecast(carrier=None)
```

### 4.4 Computing forecast verification metrics

```python
# For each forecast step in a run, find the verifying analysis and compute RMSE
forecasts = q.forecast_chain(cat, run_time=datetime(2026, 5, 17, 0), 
                              model_config_hash=H)

for fcst in forecasts:
    # Find the analysis valid at the forecast's valid_time
    truth = q.latest_analysis(cat, before=fcst.valid_time)
    if truth is None: continue
    
    fcst_state = georeader.read_from_url(fcst.state_uri)
    truth_state = georeader.read_from_url(truth.state_uri)
    rmse = compute_rmse(fcst_state, truth_state)
    print(f"Lead {fcst.lead_time}: RMSE = {rmse}")
```

### 4.5 Tracing the lineage of a state

```python
# What contributed to this analysis?
ancestors = q.lineage(cat, state_uri="s3://.../analysis_2026-05-17_06Z.nc",
                       depth=-1)

# 'ancestors' is a chain back through previous forecasts and analyses
for s in ancestors:
    print(f"{s.run_time}+{s.lead_time}: {s.state_uri}")

# Also: what obs went into the analysis step?
obs_used = q.assimilation_window(
    cat=cat,
    run_time=datetime(2026, 5, 17, 6),
    obs_catalog=obs_cat,
    window=timedelta(hours=3),
)
# 'obs_used' is a filtered geocatalog.GeoCatalog
```

### 4.6 Training an emulator on simulated trajectories

```python
import pipekit_train as pt

# Pull historical forecasts (a year's worth of methane forecasts) for emulator training
training_slices = list(q.lead_window(
    cat,
    run_time=datetime(2025, 1, 1),
    lead_range=(timedelta(0), timedelta(hours=72)),
    model_config_hash=H,
).iter_slices())

# Build a TrainingDataset over them
dataset = pt.SimulationDataset(
    forward_model=NullForward(),    # we're reading pre-computed trajectories
    prior=None,
    n_samples=len(training_slices),
    cycle=None,
    # custom mode: iterate state catalog rather than re-simulate
)
# (Or: add a `pt.StateCatalogDataset(state_catalog=cat, ...)` to pipekit-train)
```

## Part 5 — Cross-catalog bridges

The two-catalog model (`geocatalog` + `statecatalog`) needs explicit bridges. Three matter:

### 5.1 `state ← geocatalog`

DA cycles need observations. The `assimilation_window` query (in `queries.py`) lets a state catalog refer back to the observation catalog that produced its analyses.

```python
obs_assimilated = q.assimilation_window(state_cat, run_time, obs_cat, window)
```

This is implemented by joining `state_cat.metadata["obs_catalog_uri"]` with `obs_cat`’s slice domain. Each state slice records which obs catalog and which window of observations were assimilated.

### 5.2 `geocatalog → state`

Going the other way: “find me the analysis that assimilated this specific observation.” Less common, but useful for forensics (“did this obs cause an analysis to drift?”). Implemented via metadata indexing in the state catalog:

```python
def states_that_used(state_cat: StateCatalog, obs_slice: "GeoSlice") -> list[StateSlice]:
    """Find analyses whose assimilation window contained this obs."""
```

### 5.3 `state → state` (lineage)

Already covered: `lineage(cat, state_uri)` traces the ancestral chain.

## Part 6 — Dependencies and optional extras

```toml
[project]
name = "statecatalog"
version = "0.1.0"
dependencies = [
    "pandas>=2.0",
    "pyarrow>=17.0",
    "pyproj>=3.6",
]

[project.optional-dependencies]
duckdb  = ["duckdb>=1.0"]                       # DuckDBStateCatalog
pipekit = ["pipekit>=0.1", "pipekit-cycle>=0.1"]  # cycle integration
geocatalog = ["geocatalog>=0.1"]               # cross-catalog bridges
streaming  = ["pyarrow>=17.0"]
all     = ["statecatalog[duckdb,pipekit,geocatalog]"]
```

Minimum install: in-memory catalog, parquet round-trip, common queries. No pipekit dependency. No DuckDB dependency.

## Part 7 — Honest tradeoffs

### 7.1 What gets better

1. **L4 outputs (forecasts, analyses, reanalysis) are catalogable.** Until now your only catalog was for observations. Adding a state catalog makes model outputs first-class indexable artifacts.
2. **Ensemble support is structural.** `ensemble_member` is a top-level dimension; queries like `ensemble_at` are first-class.
3. **Lineage is first-class.** `parent_state_uri` chains analyses → forecasts → reanalyses, traceable.
4. **DA cycles record their own provenance.** Each state slice knows what obs catalog and what window it used.
5. **Forecast verification becomes a query, not a hand-rolled join.** `forecast_chain` + `latest_analysis` + a metric op is the full verification pipeline.
6. **Emulator training data is a query.** Pull a year’s worth of states from the catalog; train.

### 7.2 What gets harder

1. **Two catalogs instead of one is more moving parts.** Mitigation: the two are parallel in design; learning one prepares you for the other.
2. **State storage is more diverse than scene storage.** A forecast state might be a Zarr cube, a NetCDF file, a Parquet of point samples, or a raw float32 binary dump. Mitigation: `state_uri` is opaque to the catalog; readers are pluggable.
3. **Ensemble storage is expensive.** A 40-member ensemble at 0.25° hourly is hundreds of GB per run. Mitigation: ensembles get aggressive storage policies (zstd compression, chunk-aligned writes); not a catalog concern but worth knowing.
4. **The lineage chain can be deep.** Tracing 6-hourly analyses over a year is ~1500 parent links. Mitigation: depth-limited traversal; cache derived chains.

### 7.3 What doesn’t fit and isn’t tried

- **Continuous (streaming) DA outputs.** statecatalog assumes discrete writes; continuous-DA needs a different model.
- **Probabilistic state representations beyond ensembles.** GP-shaped state with full posterior covariance doesn’t fit cleanly. Mitigation: stored as opaque blobs with rich metadata.
- **State catalog as a queryable backend for visualisation UIs.** statecatalog is for catalog queries, not for serving rendered state to a UI. The state-rendering use case is downstream.
- **Cross-model alignment.** When two different models (`config_hash_A`, `config_hash_B`) produce states for the same time, the catalog stores both; aligning their state spaces is a separate concern (and almost always domain-specific).

## Part 8 — Effort and timing

### 8.1 Effort

- **Day 1-2**: `slice.py`, `base.py` — `StateSlice`, `StateRow`, `StateCatalog` Protocol. The data class needs careful design since changing it later is painful.
- **Day 3-4**: `memory.py` — `InMemoryStateCatalog`. Includes pandas-shaped append + query operations.
- **Day 5-6**: `queries.py` — the common query patterns. Test each on a synthetic catalog.
- **Day 7-8**: `parquet.py` — GeoParquet round-trip with the state-extension namespace.
- **Day 9-10**: `duckdb_backend.py` — `DuckDBStateCatalog`. Extras-gated. Hardest piece; modeled on geocatalog’s DuckDB backend.
- **Day 11**: `integrations/pipekit.py`, `integrations/cycle.py` — Operator wrappers.
- **Day 12-13**: Documentation, smoke tests, integration with pipekit-cycle.

**Total: ~2.5-3 weeks** of focused work. The DuckDB backend is the largest single piece.

### 8.2 Timing

Ship **alongside or shortly after** `pipekit-cycle` (Report 10). The two are mutually useful but neither blocks the other: pipekit-cycle can write state to filesystem without statecatalog; statecatalog can index pre-existing state outputs without pipekit-cycle.

Realistic timeline: v0.3-v0.4 of the ecosystem.

### 8.3 What this unblocks

1. **L4 becomes a queryable, first-class data tier.** Without statecatalog, model outputs are scattered files. With it, they’re indexed artifacts.
2. **DA cycles get a proper output destination.** `CycleStateWriter` makes the “DA cycle that records its history” pattern trivial.
3. **Forecast verification becomes routine.** Query forecasts, query analyses, compute metrics; no bespoke pipeline per evaluation.
4. **Emulator training data is queryable.** SimulationDataset for the (params, simulated_state) case is one query.
5. **Reanalysis becomes a buildable artifact.** A reanalysis is just a state catalog with a coherent set of analyses; statecatalog gives you the substrate.

## Part 9 — Recommendation

**Ship `statecatalog` as a separate sister package.** Signals:

- Distinct data model from `geocatalog` (model outputs vs observations)
- Sufficient size (~700-1100 LOC depending on extras) to warrant its own package
- Different optional extras (DuckDB-state, ensemble streaming, pipekit-cycle integration) than geocatalog has
- Cross-domain reusability: oceanography reanalysis, atmospheric chemistry forecasts, ML emulator outputs all benefit

The package lives in the same monorepo: `packages/statecatalog/`. Sibling of `geocatalog`, `geopatcher`, `pipekit-cycle`, `pipekit-train`, `pipekit-experiment`.

This is the **L4 data tier** that observations alone can’t reach. Without it, model outputs are second-class citizens in your stack. With it, the full L0-L4 chain has consistent indexing semantics: `geocatalog` for L0-L2 observations, `statecatalog` for L3-L4 model states, both queryable, both catalogable, both composable into the same operator-graph pipelines.

The headline win: **forecasts, analyses, and reanalyses become routinely queryable artifacts**, not bespoke per-project file conventions. That’s the structural shift the L4 story needs.