---
title: "Report 15 — Benchmarking as first-class infrastructure"
subject: geotoolz supporting info
short_title: "R15 — Benchmarks"
authors:
  - name: J. Emmanuel Johnson
    affiliations:
      - UNEP
      - IMEO
      - MARS
    orcid: 0000-0002-6739-0053
    email: jemanjohnson34@gmail.com
license: CC-BY-4.0
keywords: geotoolz, benchmarks, evaluation, infrastructure
---

# Report 15 — Benchmarking as first-class infrastructure

|                       |                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
|-----------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|**Status**             |Scoping proposal — committed (framework only; gallery in `benchmark_gallery.md`)                                                                                                                                                                                                                                                                                                                                                                              |
|**Reading time**       |~25 min                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
|**Decisions locked in**|A benchmark is structurally distinct from an evaluation campaign — it’s a *content-addressed contract*, not just a scored run. Carrier-transformation taxonomy (Discretization / Gap-Filling / Analysis / Reanalysis / Forecast / Representation) replaces the flat task list. Five missing infrastructure pieces are scoped as extensions to existing packages. The framework provides substrate; *running* benchmarks is organisational, not framework, work.|
|**Audience**           |Anyone considering benchmark design as a deliverable: paper authors, benchmark curators, would-be OceanBench / WeatherBench adopters                                                                                                                                                                                                                                                                                                                           |
|**Companion reports**  |Report 14 (`pipekit-evaluate`), Reports 6/13 (catalogs), Reports 11/12 (train + experiment); plus `benchmark_gallery.md` for worked examples                                                                                                                                                                                                                                                                                                                  |
|**Source material**    |External scientific writing on ocean ML benchmarks: benchmarkable challenges (interpolation / state estimation / forecasting / representation), logistics-fairness-orchestration, mitigating metric hacking, OceanBench’s multi-track pattern                                                                                                                                                                                                                  |

## What this report does

The source presents a four-fold task taxonomy and a list of design considerations. The framework as written is sound, but underspecified in several places that matter operationally:

- The task list doesn’t pin down carrier shapes (what’s the input? what’s the output?)
- Deterministic and probabilistic variants are conflated
- The leakage discussion focuses on global statistics but misses the more dangerous spatiotemporal-correlation problem
- The “logistics / orchestration” section is hand-wavy about what artifact actually constitutes the benchmark
- Pre-registration as a mitigation strategy is absent
- The framework-vs-operational distinction is implicit

This report sharpens each of these and proposes five concrete infrastructure pieces that the GeoStack would need to ship to support honest benchmarking. It does *not* propose a new package — most of the work extends `pipekit-evaluate` (Report 14), `pipekit-train` (Report 11), and the catalogs (Reports 6, 13).

-----

## Part 1 — Benchmark vs. evaluation: a structural distinction

The source treats benchmark and evaluation as near-synonyms. They aren’t:

|                  |Evaluation                |Benchmark                                   |
|------------------|--------------------------|--------------------------------------------|
|**What it is**    |The act of scoring a model|A shared, pre-registered evaluation contract|
|**Scope**         |Per-project, per-run      |Cross-project, cross-team                   |
|**Permanence**    |Ephemeral artifact        |Versioned, immutable                        |
|**Reference data**|Whatever’s at hand        |Curated, frozen, content-addressed          |
|**Preprocessing** |Per-team choices          |Locked, distributed as code                 |
|**Metric set**    |Whatever the team picks   |Pre-registered before submissions open      |
|**Splits**        |Per-team choices          |Distributed as part of the contract         |
|**Baselines**     |Optional                  |Mandatory, shared implementation            |

**The benchmark is the contract**; evaluation is the machinery that runs the contract. Pipekit-evaluate (Report 14) provides the machinery. The benchmark contract is a *separate artifact* on top.

This distinction matters because most “ML benchmark” failures aren’t failures of metrics — they’re failures of contracts:

- Two teams use different preprocessing → results aren’t comparable
- Random splits introduce spatiotemporal leakage → leaderboard rewards memorization
- One team has access to the test set; another doesn’t → unfair iteration count
- Different baselines used → “10% improvement over baseline” is meaningless

All of these are contract failures. Better metrics don’t fix them; better contracts do.

-----

## Part 2 — The task taxonomy as carrier transformations

The source lists four tasks: interpolation, state estimation, forecasting, representation learning. These are fine as conceptual categories but underspecified for benchmarking. What’s the input? What’s the output? Where does a particular model’s responsibility start and stop?

The user’s sketch resolves this by framing tasks as **carrier transformations** — each task is a specific input-carrier → output-carrier transformation, and a model is anything that performs the transformation. This is the operator-graph framing applied to benchmarks.

### 2.1 — The carrier-transformation chain

```
   Task              Input carrier              Output carrier         Stack mapping
   ──────────────────────────────────────────────────────────────────────────────────
   Discretization    Obs (points)        →      Obs (sparse grid)      xr_toolz.interpolate
                                                                       (point-to-grid binning)
   
   Gap-Filling       Obs (sparse grid)   →      Obs (dense grid)       xr_toolz.interpolate
                     OR Obs (points)            (gridded, gap-free)    (kriging, GP, DINEOF)
                                                                       pyrox-gp, gaussx
   
   Analysis          Obs (any)           →      State (dense grid)     pipekit-cycle.DACycle
                     + prior State              (one-time-snapshot)    (single-step assimilation)
   
   Reanalysis        Obs (window)        →      State trajectory       pipekit-cycle.SmootherCycle
                     + prior State              (window-smoothed)      (4D-Var-shaped)
   
   Forecast          State (dense grid)  →      State (future)         pipekit-cycle.Cycle
                                                                       with ForwardModel
   
   Representation    State (dense)       →      Latent + reconstruction pipekit-train
                                                of state                Encoder/Decoder
```

Each row is a benchmarkable task. A model that performs more than one row is implicitly entered into multiple sub-benchmarks. A model that performs only one row is benchmarkable in isolation.

### 2.2 — Why this is better than the source’s framing

Three things this framing makes explicit that the source’s doesn’t:

1. **The carrier shapes pin down the task.** “Interpolation” is ambiguous; “Discretization (points → sparse grid)” is not. The benchmark contract specifies the input and output carrier shapes; a model is anything that maps one to the other.
2. **Composable benchmarks.** A user can submit to Discretization alone, or to “Discretization + Gap-Filling” composed as a chain. The benchmark for the chain is the same as the benchmark for the individual steps — same carriers, same references — just evaluated end-to-end.
3. **Stack mapping is direct.** Every task corresponds to specific pipekit pieces. Implementors know which pieces of the stack they’re building on.

### 2.3 — Deterministic vs. probabilistic as a first-class axis

The source mentions probabilistic verification but doesn’t make it a structural distinction. **It should be.** A deterministic forecast and an ensemble forecast are different benchmarkable artifacts:

|                      |Deterministic          |Probabilistic                     |
|----------------------|-----------------------|----------------------------------|
|**Carrier**           |Single state field     |Ensemble of state fields          |
|**Reference**         |Single reference field |Distribution / ensemble reference |
|**Metric class**      |RMSE, MAE, NSE         |CRPS, Energy Score, Rank Histogram|
|**Leakage rule**      |Standard train/val/test|Plus ensemble-member disjoint     |
|**Computational cost**|Baseline               |N× ensemble baseline              |

Every carrier-transformation task above has both variants. The benchmark contract must declare which it accepts. **A deterministic model submitting to a probabilistic benchmark is a category error.** The framework should refuse to score it; pipekit-evaluate’s `Metric.differentiable` + `stage_compatibility` fields extend cleanly to a `Metric.variant ∈ {deterministic, probabilistic}` field.

-----

## Part 3 — The three-track pattern

The OceanBench multi-track framing (model-to-reanalysis / model-to-analysis / model-to-observations, CLASS-4 style) is the source’s strongest single contribution. Worth being explicit about why each track exists and what failure mode it exposes:

```
   ┌─────────────────────────────────────────────────────────────────────┐
   │                                                                     │
   │   Reference data:    Reanalysis        Analysis         Observations│
   │                      (smoothed,         (high-res,        (raw,      │
   │                       full coverage,    operational,      sparse,    │
   │                       inherits          state-of-art)     noisy)     │
   │                       assumptions)                                   │
   │                                                                     │
   │   What it exposes:                                                  │
   │     Reanalysis    →  overfitting to training distribution           │
   │     Analysis      →  generalization to higher resolution            │
   │     Observations  →  what the assimilation smoothed away;            │
   │                       true sparse-sampling skill                    │
   │                                                                     │
   │   Cost:                                                             │
   │     Reanalysis    →  cheap (dense grid; same shape as training)     │
   │     Analysis      →  moderate (dense grid; different distribution)  │
   │     Observations  →  expensive (matchup, observation operator       │
   │                       application, sparse evaluation)               │
   │                                                                     │
   └─────────────────────────────────────────────────────────────────────┘
```

A model that does well on reanalysis but poorly on observations has *learned the assimilation*, not the physics. A model that does well on observations but poorly on reanalysis is probably right and the reanalysis is wrong. Both signals are useful; neither alone is sufficient.

**Recommendation:** the benchmark contract should require all three tracks when references are available. Single-track benchmarks should be marked as such.

The pipekit-evaluate package gets a `MultiTrackEvaluation` operator that:

```python
class MultiTrackEvaluation(Operator):
    """Run the same evaluation pipeline against multiple reference catalogs.
    
    Produces a single MultiTrackReport that compares scores across tracks.
    Tracks with no reference catalog are reported as unavailable, not skipped.
    """
    evaluation_pipeline: pe.Pipeline
    references: dict[str, Catalog]   # {"reanalysis": cat1, "analysis": cat2, "obs": cat3}
```

-----

## Part 4 — Leakage: more dangerous than the source implies

The source correctly identifies that global statistics computed on the whole dataset and then applied to all splits is leakage. But this is the *easier* form to detect. The dangerous form is **spatiotemporal correlation leakage**, which can occur even with no global statistics in sight.

### 4.1 — The problem

Geophysical data is autocorrelated in space and time. A snapshot at 06Z is not independent of the snapshot at 12Z. A pixel at one location shares atmospheric state with pixels 100km away. A random train/val/test split treats these as IID, which they aren’t.

Concretely:

- Random temporal split → training and test sets are interleaved hourly → model memorises diurnal cycle persistence
- Random spatial split → training and test pixels are neighbors → model interpolates rather than learns
- Random platform split → training and test include the same ARGO float at different times → model exploits float-specific drift

In all three cases, the model can achieve high held-out skill without learning anything that generalizes. **The leaderboard rewards memorization disguised as skill.**

### 4.2 — The fix: block discipline

The honest split rule:

> **The block size for splitting must exceed the integral spatial/temporal scale of the variable being predicted.**

For SSH: mesoscale decorrelation is ~100km / ~30 days → spatial blocks ≥ 200km, temporal blocks ≥ 60 days. For methane plumes: ~10km / ~hours → smaller blocks acceptable. For seasonal forecasts: ~1000km / ~3 months → very large blocks.

These aren’t tunable parameters; they’re properties of the physical system. The benchmark contract must specify them, and the splitter must enforce them.

### 4.3 — Infrastructure piece #1: leakage-aware splitters

In `pipekit-train`, add to v0.1 a small splitter family:

```python
# pipekit_train.splitters
class SpatioTemporalBlockSplit(Splitter):
    """Block-based split with explicit spatial and temporal block sizes.
    
    Refuses to split if blocks don't fit within the catalog domain
    (e.g., a 200-km block applied to a 100-km catalog).
    """
    spatial_block_km: float
    temporal_block_days: float
    test_fraction: float = 0.2
    val_fraction: float = 0.1
    
class LeaveOnePlatformOut(Splitter):
    """Use one platform's observations as test, others as train.
    
    For benchmarks against in-situ data: a true held-out platform
    is the strongest generalization test.
    """
    platform_field: str = "platform_id"

class CausalTemporalSplit(Splitter):
    """Strict causal split for forecasting: test data is later in time
    than any training data. No future-information leakage possible.
    """
    train_end: datetime
    val_end: datetime

class LeaveOneRegionOut(Splitter):
    """Use one geographic region as test, others as train.
    
    For benchmarks of spatial generalization: a true held-out region
    tests whether the model learned a transferable mapping or just
    memorized the spatial training distribution.
    """
    regions: dict[str, Polygon]
```

Each splitter refuses to be applied incorrectly. `SpatioTemporalBlockSplit` with block sizes smaller than the catalog’s expressed correlation scale raises an error.

This is **~1 week of work in pipekit-train v0.2**. The implementation is small; the discipline is what matters.

-----

## Part 5 — The five missing infrastructure pieces

Beyond leakage-aware splitters, four more pieces of infrastructure are needed before benchmarking-as-shared-practice works in the GeoStack.

### 5.1 — The benchmark contract artifact

A `BenchmarkContract` is a content-addressed bundle defining:

```python
@dataclass(frozen=True)
class BenchmarkContract:
    """A pre-registered benchmark contract.
    
    Content-addressed by hash(task, references, splits, metrics, baselines).
    Distributed as a single YAML/JSON. Registrable in pipekit-experiment.
    """
    name: str
    version: str                              # semver
    
    # The task
    task: Literal["discretization", "gap_filling", "analysis", 
                  "reanalysis", "forecast", "representation"]
    input_carrier_spec: dict                  # shape, dims, units
    output_carrier_spec: dict
    variant: Literal["deterministic", "probabilistic"]
    
    # The data (references for each track)
    reference_catalogs: dict[str, str]        # {"reanalysis": cat_uri, ...}
    train_catalog_uri: str
    val_catalog_uri: str
    test_catalog_uri: str                     # may be "blind" → access-gated
    
    # The splits (locked)
    splitter_config: dict                     # serialised Splitter
    block_size_spatial_km: float
    block_size_temporal_days: float
    
    # The metrics (pre-registered)
    metric_configs: list[dict]                # serialised Metrics from pipekit-evaluate
    
    # The baselines (mandatory shared implementations)
    baselines: list[str]                      # operator paths in registry
    
    # Submission rules
    submission_format: str                    # "pipekit_artifact_v1" or "yaml_pipeline_v1"
    max_test_evaluations: int = 1             # anti-hacking: limit test-set runs
    
    def content_hash(self) -> str: ...
    def to_yaml(self) -> str: ...
    @classmethod
    def from_yaml(cls, text: str) -> "BenchmarkContract": ...
```

This is a small artifact (~50 KB YAML when filled in) that fully specifies a benchmark. Anyone with the contract hash can verify they’re scoring against the same thing.

Lives in **`pipekit-evaluate.benchmark`** as a submodule. ~250 LOC. **This is the load-bearing piece** — without it, “benchmarks” are just informal evaluation pacts.

### 5.2 — The baseline registry pattern

Benchmarks need baselines. Currently every team rolls their own. The variation introduces silent bias: “10% improvement over persistence” depends on which persistence implementation.

```python
# pipekit_evaluate.baselines
class PersistenceBaseline(Operator):
    """Forecast = last observed state. Decay-free.
    
    Subtle: 'persistence' for what lead time, from what reference time,
    with what gap-handling. All these are config.
    """
    lead_time_hours: float
    reference_choice: Literal["last_available", "latest_analysis"]
    gap_handling: Literal["nan", "carry_forward", "climatology_fill"]

class ClimatologyBaseline(Operator):
    """Forecast = climatological mean from training set.
    
    Subtle: which climatology window, what averaging period,
    leap-year handling.
    """
    window_years: tuple[int, int]
    averaging_period: Literal["daily", "weekly", "monthly", "annual"]

class LinearTrendBaseline(Operator):
    """Trend extrapolation from recent N samples."""
    n_recent: int

class OptimalInterpolationBaseline(Operator):
    """OI with specified correlation scale.
    
    A standard baseline for gap-filling tasks. The choice of
    correlation length is a real assumption.
    """
    decorr_length_km: float
    decorr_time_days: float
```

All baselines are `pipekit.Operator` subclasses with explicit config. The benchmark contract pins the *exact* baseline config; every submission scores against the same implementation. Lives in **`pipekit-evaluate.baselines`** as a submodule. ~400 LOC.

### 5.3 — Pre-registration via content addressing

The mitigation the source misses. Pre-registration works in our stack because of content-addressing:

1. The benchmark contract is content-hashed
2. The hash is published before the leaderboard opens
3. Any submission must reference the contract hash
4. After-the-fact contract edits change the hash → can’t be conflated with pre-registered version

This requires no new infrastructure beyond the existing `pipekit-experiment.ModelRegistry` extended to store benchmark contracts as content-addressed artifacts:

```python
registry.register_contract(contract)   # content-hashed, immutable
hash = contract.content_hash()
# Publish: "Benchmark v1.0 contract: hash ab12cd..."

# Any submission carries the hash
@dataclass
class BenchmarkSubmission:
    contract_hash: str
    model_hash: str
    evaluation_report: EvaluationReport
    
    def verify(self) -> bool:
        contract = registry.load_contract(self.contract_hash)
        return self.evaluation_report.was_produced_from(contract)
```

The verification step is structural: if the report’s `pipeline_config` doesn’t match the contract, the submission is invalid. **No trust required.** ~100 LOC addition to pipekit-experiment.

### 5.4 — Blind test substrate via catalog access control

A blind test set is one users can submit against but can’t iterate against. Operationally this means the data is gated — you can submit a model to be scored, but you can’t read the data directly.

In the GeoStack this needs catalog-level access control:

```python
# geocatalog v0.3 — access-gated catalog
class AccessGatedGeoCatalog:
    """Catalog with public metadata but gated data access.
    
    iter_slices() returns slice metadata.
    load_data(slice) requires a submission token; loads data into a
    sandboxed scoring environment but doesn't return it to the user.
    """
    public_metadata: GeoCatalog
    data_access_endpoint: str         # the scoring service URL
    
    def iter_slices(self) -> Iterator[GeoSlice]:
        # Returns slice metadata, no data
        ...
    
    def submit_for_scoring(self, model: Operator, 
                          contract: BenchmarkContract) -> SubmissionToken:
        # Send the model to the scoring service; get a token
        # The service runs the eval and returns a report
        # The user never sees raw data
        ...
```

This is **real operational infrastructure**, not just framework code. Running a scoring service requires a server, compute budget, queue management. **The framework can specify the contract; running the service is organisational work.** ~300 LOC of framework code; multiples of that in operational scaffolding.

The honest version for v0.1: ship the contract + verification + result publication; defer the scoring-service infrastructure to projects that actually run benchmarks (OceanBench, etc.).

### 5.5 — Multi-track evaluation as built-in pattern

Already sketched in Part 3. Ships as `pipekit-evaluate.tracks.MultiTrackEvaluation`. ~150 LOC. Composes existing pieces; no new infrastructure.

-----

## Part 6 — How this fits into pipekit-evaluate

All five pieces extend `pipekit-evaluate` (Report 14) without changing its core. Updated package layout:

```
pipekit-evaluate/
  _src/
    protocols.py             (existing)
    units.py                 (existing)
    report.py                (existing)
    metrics/                 (existing)
    lenses/                  (existing)
    aggregations.py          (existing)
    adapters/                (existing)
    
    # NEW additions for benchmarking
    benchmark/
      contract.py            # BenchmarkContract
      submission.py          # BenchmarkSubmission, verification
      registry.py            # contract registration in pipekit-experiment
    tracks.py                # MultiTrackEvaluation
    baselines/
      persistence.py
      climatology.py
      trend.py
      optimal_interpolation.py
```

Plus in `pipekit-train`:

```
pipekit-train/
  _src/
    splitters/               # NEW
      block.py               # SpatioTemporalBlockSplit
      platform.py            # LeaveOnePlatformOut
      causal.py              # CausalTemporalSplit
      region.py              # LeaveOneRegionOut
```

Plus in `geocatalog` v0.3:

```
geocatalog/
  _src/
    access_gated.py          # NEW — AccessGatedGeoCatalog
```

Total new code estimate: ~1500 LOC across packages. Lower than it sounds because most pieces are small.

-----

## Part 7 — What the framework does NOT try to be

Worth being explicit about scope limits.

**Not a benchmark catalog.** We don’t ship a list of “the GeoStack-approved benchmarks.” Different communities own different benchmarks (OceanBench, WeatherBench, etc.). The framework provides infrastructure; benchmark *curation* is community work.

**Not a leaderboard service.** Running submissions, maintaining queues, publishing rankings, handling disputes — all organisational work. Pipekit-evaluate provides scoring; running a hosted service is a project, not a library.

**Not a substitute for domain expertise.** The framework can enforce that a split respects a declared block size; it can’t tell you what block size is right for your variable. That’s a scientific decision the benchmark designer must make and justify.

**Not a replacement for OceanBench / WeatherBench.** The right framing is “build the framework so OceanBench / WeatherBench can adopt it.” If the infrastructure is good, existing benchmarks migrate to it; the framework doesn’t need to compete.

-----

## Part 8 — Honest tradeoffs

### What gets better

1. **Benchmarks become content-addressable artifacts.** Hash a contract; publish the hash; verify any submission against it. No trust required.
2. **Leakage discipline is enforced by the framework.** A user can’t accidentally do a random split on autocorrelated data; the splitter refuses.
3. **Baselines are standard.** Every team scores against the same persistence implementation; comparisons are honest.
4. **Multi-track evaluation is routine.** Three reference comparisons in one pipeline; no per-project glue.
5. **Pre-registration is structural.** Content-addressing means the contract can’t drift after publication.
6. **Reproducibility audits are mechanical.** Anyone can re-run a submission given the model artifact + contract hash + reference data.

### What gets harder

1. **The benchmark contract is verbose.** A full YAML with task spec, carrier shapes, splitter config, metric configs, baseline configs, submission rules is hundreds of lines. Mitigation: ship templates (`pipekit_evaluate.benchmark.templates.{forecast,gap_filling,...}`).
2. **Block-discipline can over-restrict small catalogs.** A 100-km catalog can’t host a 200-km spatial-block split. Mitigation: smaller benchmarks declare smaller blocks honestly; the framework refuses dishonest configurations.
3. **Blind test substrate is real operational work.** The framework code is small; running a scoring service is not. Mitigation: ship the contract + verification in v0.1; defer scoring-service infrastructure to projects that need it.
4. **Pre-registration requires discipline.** A team that wants to iterate fast won’t pre-register; benchmarks that don’t enforce pre-registration get gamed. Mitigation: mark contracts as “pre-registered” or “exploratory”; only pre-registered benchmarks have authoritative status.
5. **Multi-track requires multiple references.** Many domains have only one reference (e.g., methane has CAMS reanalysis but limited model-to-obs). Mitigation: tracks with no reference are reported as unavailable rather than skipped silently.

### What doesn’t fit

- **Continuous benchmarks (live data streams).** The framework assumes immutable references. Continuous-data benchmarks need different infrastructure.
- **Benchmarks over private data.** The contract format assumes references are at least metadata-accessible. Fully-private benchmarks (e.g., commercial datasets) need their own access protocols.
- **Cross-domain leaderboards.** Comparing “method A on ocean” to “method B on land” is meaningless. Benchmarks are scoped per-domain.

-----

## Part 9 — Effort and timing

Realistic sequencing:

**v0.1 of benchmark infrastructure (3-4 weeks)**, alongside pipekit-evaluate v0.1:

- `BenchmarkContract` artifact + serialisation
- Pre-registration via content addressing
- `MultiTrackEvaluation`
- `SpatioTemporalBlockSplit`, `CausalTemporalSplit` (in pipekit-train)
- Standard baselines: `PersistenceBaseline`, `ClimatologyBaseline`

**v0.2 (2-3 weeks)**, alongside pipekit-evaluate v0.2:

- Remaining splitters (`LeaveOnePlatformOut`, `LeaveOneRegionOut`)
- Additional baselines (`OptimalInterpolation`, `LinearTrend`)
- Templates (`pipekit_evaluate.benchmark.templates.*`)

**v0.3 (longer, organisational)**, only if a project demands it:

- `AccessGatedGeoCatalog` for blind test sets
- Scoring service infrastructure (separate project, not framework)

The first phase is what makes the existing examples (Report 4/9 use cases) into proper benchmarks. The second phase covers the cases the worked examples in `benchmark_gallery.md` will need. The third phase is operational and probably won’t happen inside the framework — it’ll happen inside specific benchmark projects.

-----

## Part 10 — Recommendation

**Ship benchmarking as infrastructure inside pipekit-evaluate, not as a separate package.** Signals:

- The Protocols, contracts, and reports all share substrate with pipekit-evaluate
- Splitters belong in pipekit-train (next to other data-pipeline concerns)
- Baselines are evaluation operators (next to other metrics)
- Multi-track evaluation is one more lens
- No new top-level package; ~5 extensions across 3 existing packages

The framework framing (Parts 1-6) should be adopted into v2 regardless of when the code lands, because **honest benchmark contracts matter even without infrastructure to verify them**. A pre-registered YAML contract is useful immediately; the verification machinery makes it enforceable.

The gallery in `benchmark_gallery.md` makes the framework concrete by instantiating it for six domains: Ocean (SSH, SST, SSS, OC, BGC), Land (T2m, precip, wind, pressure), Atmosphere (gases, wind, pressure), Remote Sensing (multispectral-hyperspectral, polar-geo, RTM, sensor ops, multi-satellite fusion), and Mathematical Models (the multi-stage emission-estimation chain). Each entry follows the same template: carrier transformation, reference data, tracks, baselines, metric set, splits, known failure modes, stack mapping.

The bones are right. Without benchmarks-as-contracts, the rest of the stack delivers individually-useful pieces but no operational way to compare progress. With them, the train→eval→benchmark→deploy loop closes — and the GeoStack becomes the infrastructure that benchmark projects (existing or new) can adopt rather than re-implement.