---
title: "Report 14 — `pipekit-evaluate`: multidimensional evaluation"
subject: geotoolz master plan
short_title: "R14 — pipekit-evaluate"
authors:
  - name: J. Emmanuel Johnson
    affiliations:
      - UNEP
      - IMEO
      - MARS
    orcid: 0000-0002-6739-0053
    email: jemanjohnson34@gmail.com
license: CC-BY-4.0
keywords: geotoolz, pipekit-evaluate, evaluation, metrics, multidimensional
---

# Report 14 — `pipekit-evaluate`: multidimensional evaluation as first-class infrastructure

|                       |                                                                                                                                                                                                                                                                                                                       |
|-----------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|**Status**             |Scoping proposal — committed (two-part: framework + package)                                                                                                                                                                                                                                                           |
|**Reading time**       |~30 min                                                                                                                                                                                                                                                                                                                |
|**Decisions locked in**|A dedicated evaluation package, not a submodule. Three orthogonal axes (Unit × Lens × Stage), not the source’s flat five-axis list. Lagrangian and event-based evaluation need supporting infrastructure (`xr_toolz.lagrangian`, `xr_toolz.events`, `EventCatalog`) which are scoped as siblings. Monorepo development.|
|**Audience**           |Anyone reviewing how the GeoStack assesses ML / hybrid models against physical-fidelity requirements                                                                                                                                                                                                                   |
|**Companion reports**  |Reports 1–13 (existing stack), `../supporting_info/geodata_lifecycle.md` (data lifecycle companion), `../supporting_info/geostack_vision.md`                                                                                                                                                                                                                       |
|**Source material**    |External scientific writing on multi-dimensional ocean ML evaluation: scales, data representation, physical representation, process consistency, phenomena-based verification                                                                                                                                          |

## What this report does

Two-part structure, because the framework framing is generalisable while the package proposal is one specific implementation:

- **Part 1** — The evaluation framework. A taxonomy with three orthogonal axes (Unit × Lens × Stage), a matrix view, and a mapping onto existing and missing pieces of the stack. Generalisable beyond ocean.
- **Part 2** — The `pipekit-evaluate` package proposal. Concrete scoping in the style of Reports 6, 7, 10, 11, 12, 13.
- **Part 3** — Supporting infrastructure gaps. The package alone isn’t enough; three other pieces (`xr_toolz.lagrangian`, `xr_toolz.events`, `EventCatalog`) need to ship in parallel.
- **Part 4** — Recommendations and tradeoffs.

The framework framing (Part 1) is what should be adopted into v2; the package proposal (Part 2) is one structurally honest way to implement it.

-----

# Part 1 — The Evaluation Framework

## 1.1 — Why evaluation is multidimensional

A single scalar metric on a held-out set is structurally insufficient for geophysical ML. Three concrete failure modes motivate the framework:

1. **The double-penalty trap.** An L2 loss penalises a correctly-shaped feature that’s spatially displaced *twice* — once for being missing where it should be, once for being present where it shouldn’t. Gradient descent learns to predict a flat mean state rather than risk spatial phase errors. The model can achieve low loss while producing physically meaningless output.
2. **Scale-blind aggregation.** Standard losses preferentially weight large-amplitude, low-wavenumber structures because that’s where the variance lives. Submesoscale and high-frequency features — often the scientifically interesting bits — get smoothed out, the spectral slope steepens artificially, and the model’s “skill” is dominated by features that were always going to be easy.
3. **Eulerian-only blindness.** A model can have excellent agreement on gridded fields (the Eulerian frame) while completely misrepresenting how fluid parcels move through those fields (the Lagrangian frame). Small phase errors in velocity integrate into large trajectory divergence. Transport-relevant skill is invisible in standard scores.

Three failure modes that **good aggregate metrics actively hide**. Honest evaluation has to decompose along the dimensions where these failures live.

## 1.2 — Three orthogonal axes, not five flat categories

The source presents five categories — Scales, Data Representation, Physical Representation, Process Evaluation, Phenomena-Based — as if they were coequal. They aren’t. Some are about *where* you evaluate; some are about *what mathematical form* the metric takes; some are about *frame of reference*; some are about *what’s being scored*. Mixing these creates apparent overlap (the Lagrangian content appears in two of the five) and obscures the real structure.

The clean decomposition is **three orthogonal axes**:

```
   UNIT                        LENS                          STAGE
   (what's being scored)       (what kind of critique)       (when in lifecycle)
   ┌──────────────────────┐   ┌──────────────────────┐      ┌──────────────────────┐
   │ Field                │   │ Point-wise           │      │ Training             │
   │ Statistic            │   │ Probabilistic        │      │ (differentiable,     │
   │ Trajectory           │ × │ Spectral             │  ×   │  fast)               │
   │ Event                │   │ Structural           │      │ Validation           │
   │ Budget               │   │ Detection            │      │ (cheap, frequent)    │
   │                      │   │ Physical-constraint  │      │ Final eval           │
   │                      │   │                      │      │ (comprehensive)      │
   │                      │   │                      │      │ Monitoring           │
   │                      │   │                      │      │ (continuous, light)  │
   └──────────────────────┘   └──────────────────────┘      └──────────────────────┘
```

**Why this matters.** Three axes cross to give a 3D space of evaluation operations, not five competing lists. Concretely:

- “Eulerian field × point-wise × at submesoscale” → PSD comparison (the source’s Scales decomposition applied to Data Representation)
- “Lagrangian trajectory × probabilistic × at climate scale” → ensemble dispersion CRPS
- “Event × detection × by region” → marine-heatwave POD/FAR by basin
- “Budget × physical-constraint × continuously during long rollout” → mass conservation drift over time

This reframes the source’s five categories as *combinations* of axis choices rather than competing taxonomies. Cleaner; also matches how evaluation actually composes in practice.

## 1.3 — The Unit axis: what gets scored

Five things you can score. Each one demands its own carrier type.

|Unit          |What it is                                                          |Existing stack support                                                 |
|--------------|--------------------------------------------------------------------|-----------------------------------------------------------------------|
|**Field**     |Continuous gridded prediction vs. reference. The default ML case.   |`xr.Dataset` / `GeoTensor` — fully supported                           |
|**Statistic** |Derived summary: PSD, histogram, structure function, moments        |Partial — `xr_toolz.transforms` has FFT/wavelets but not comparison ops|
|**Trajectory**|Particle path or drifter track in a velocity field                  |**Missing** — needs `xr_toolz.lagrangian` (Part 3)                     |
|**Event**     |Discrete phenomenon (eddy, marine heatwave, atmospheric river)      |**Missing** — needs `xr_toolz.events` + `EventCatalog` (Part 3)        |
|**Budget**    |Conservation closure: mass, energy, tracer, PV over a control volume|Partial — `xr_toolz.budgets` exists; not evaluation-shaped             |

**The point:** the operator shape for scoring a Field is `(prediction, reference) → scalar`. The shape for scoring an Event is `(predicted_events, reference_events) → ContingencyTable + AttributeErrors`. The shape for scoring a Trajectory is `(predicted_velocity_field, reference_drifters) → dispersion_statistics`. These are different operator signatures and they need different supporting infrastructure.

## 1.4 — The Lens axis: what kind of critique

Six lenses, each targeting a specific failure mode. The Lens axis is **what makes a metric a critique**, not just a distance.

|Lens                   |Targets                   |Examples                                                        |Differentiable?        |
|-----------------------|--------------------------|----------------------------------------------------------------|-----------------------|
|**Point-wise**         |Magnitude bias            |RMSE, MAE, NSE, IoA                                             |Yes                    |
|**Probabilistic**      |Calibration of uncertainty|CRPS, Energy Score, Brier, Rank Histogram                       |Yes (CRPS, Brier)      |
|**Spectral**           |Scale-dependent variance  |PSD comparison, spectral slope fitting, KE spectrum             |Yes (in spectral space)|
|**Structural**         |Spatial coherence         |SSIM, perceptual loss, FSS                                      |Yes                    |
|**Detection**          |Event presence / absence  |POD, FAR, CSI, IoU, contingency table                           |No (counts)            |
|**Physical-constraint**|Conservation / balance    |Geostrophic balance, stratification, PV invariance, mass closure|Sometimes              |

**Five tiers of critique strength.** Honest practice picks a lens that *can detect* the failure modes that matter for the use case, not just whichever lens is cheapest. The source’s “double-penalty” example is point-wise lens hiding what structural or spectral would catch; “spectral blurring” is point-wise hiding what spectral catches; “Eulerian blindness” is field-unit hiding what trajectory-unit catches.

## 1.5 — The Stage axis: when in the lifecycle

The third axis the source underdevelops. A metric’s operational role determines what’s acceptable for cost and differentiability:

|Stage         |Constraints                                |Examples                                             |
|--------------|-------------------------------------------|-----------------------------------------------------|
|**Training**  |Must be differentiable; fast (per batch)   |Point-wise, CRPS, spectral-band MSE, simple FSS      |
|**Validation**|Fast; computed every epoch or every N steps|Same as training + cheap structural / detection      |
|**Final eval**|Can be expensive; computed once on test set|All lenses; full LCS computation; full event matching|
|**Monitoring**|Continuous in production; lightweight      |Drift detection on a small selection of metrics      |

**Why this matters operationally.** Perceptual losses with deep-feature comparison cost ~100ms per batch — fine for validation, too expensive for training. LCS computation requires advecting millions of particles — final-eval only. Conservation budget closure needs full forecast trajectories — final-eval only. Without the Stage axis, the catalogue of metrics is a flat list with no operational guidance.

## 1.6 — The Lens × Unit matrix

The two main axes cross. Not every cell is populated; the populated cells are the operationally useful metrics:

```
                        UNITS  (what's being scored)
                Field    Statistic   Trajectory   Event    Budget
              ╤════════╤═══════════╤════════════╤════════╤═════════╕
   Point-wise │ RMSE   │           │ TrajRMSE   │CentDisp│         │
              │ MAE    │     —     │ Endpoint   │ Area   │    —    │
              │ NSE    │           │ separation │ error  │         │
              ├────────┼───────────┼────────────┼────────┼─────────┤
   Probabil-  │ CRPS   │ EnergyScr │ Dispersion │ Brier  │         │
   istic      │ EnsRMSE│ RankHist  │ CRPS       │ Reliab │    —    │
              ├────────┼───────────┼────────────┼────────┼─────────┤
LE Spectral   │ PSDcmp │ Slope fit │            │        │         │
NS            │ KE spec│ Struct fn │     —      │   —    │    —    │
              ├────────┼───────────┼────────────┼────────┼─────────┤
   Structural │ SSIM   │           │ LCS overlap│ IoU    │         │
              │ FSS    │     —     │ Filament   │ Hauss- │    —    │
              │ Percept│           │ stats      │ dorff  │         │
              ├────────┼───────────┼────────────┼────────┼─────────┤
   Detection  │        │           │            │ POD    │         │
              │   —    │     —     │     —      │ FAR    │    —    │
              │        │           │            │ CSI    │         │
              ├────────┼───────────┼────────────┼────────┼─────────┤
   Physical-  │ Geostr │           │ PV         │        │ Mass    │
   constraint │ balance│     —     │ conserv    │   —    │ Energy  │
              │ Strat  │           │ FTLE       │        │ Tracer  │
              ╘════════╧═══════════╧════════════╧════════╧═════════╛
```

**Reading the matrix:**

- Empty cells are honest gaps where the (unit, lens) combination doesn’t yield a useful metric
- The Field × Point-wise corner is where 90% of current ML evaluation happens; the rest of the matrix is what good practice opens up
- Each populated cell is a concrete operator class to ship in `pipekit-evaluate`

## 1.7 — The Reference Frame is a sub-decomposition of Unit

The source treats Eulerian / Lagrangian as a top-level axis. I’d argue it’s actually a **sub-decomposition of the Unit axis**: Eulerian Fields and Lagrangian Trajectories are different *units*. Conflating frame and unit is what produces the source’s Section 6.3 / 6.4 duplication, where Lagrangian content appears in both Physical Representation and Process Evaluation.

Cleaner restatement: the Field unit is implicitly Eulerian (state at fixed coordinates); the Trajectory unit is implicitly Lagrangian (state following parcels). Both are needed; both are first-class.

## 1.8 — Decomposition is a separate operation: the Scale axis revisited

The source’s “Scales of Evaluation” mixes two different operations:

- **Regional partitioning** — evaluate on coastal vs. open ocean vs. polar separately. The data is decomposed; the metric is unchanged.
- **Scale partitioning** — evaluate at $k^{-3}$ submesoscale vs. mesoscale separately. The metric is computed *in scale-space*; the input is unchanged.

These are different operations on different axes. In the package design they become different operator families:

- `ByRegion(regions: dict[str, mask])` — applies a metric separately per region; aggregates results
- `ByScale(decomposition: SpectralDecomp | WaveletDecomp)` — computes metric in scale-decomposed space
- `ByLeadTime(...)` — applies a metric separately per forecast lead
- `ByEvent(detector)` — restricts evaluation to event-occupied regions

Both are *evaluation lenses* applied **on top of** metrics. They don’t replace metrics; they compose with them. This is what the source’s “scale partitioning” should have been: not a coequal category, but a wrapping operation.

## 1.9 — How this maps to the existing stack

|Framework piece                     |Current stack                                                             |
|------------------------------------|--------------------------------------------------------------------------|
|Field-unit, point-wise metrics      |`xr_toolz.metrics` (good coverage); `pipekit-array.metrics`               |
|Statistic-unit derivation           |`xr_toolz.transforms` (FFT, wavelets) — derivation only, no comparison ops|
|Trajectory-unit                     |**Missing entirely** — no particle advection in the stack                 |
|Event-unit                          |**Missing entirely** — no event detection or matching                     |
|Budget-unit                         |`xr_toolz.budgets` — exists but isn’t evaluation-shaped                   |
|Probabilistic lens                  |Partial — `xskillscore` integration in `xr_toolz.metrics`                 |
|Spectral lens (compare PSDs)        |**Missing** — building blocks in transforms but no comparison ops         |
|Structural lens (SSIM, FSS)         |**Missing**                                                               |
|Detection lens (POD, FAR, CSI)      |**Missing** — likely belongs in `pipekit-array.metrics.classification`    |
|Physical-constraint lens            |Partial — `xr_toolz.calc` has gradient ops but no balance-check evaluation|
|Lens composition (ByRegion, ByScale)|**Missing** — no decomposition wrappers                                   |
|Stage discipline                    |**Missing** — no annotation of which metrics suit which stage             |

This is the gap analysis. The current stack has the bottom-left corner of the matrix (Field × Point-wise) covered well, and very little of the rest. **The framework’s value is making the gaps visible.**

-----

# Part 2 — The `pipekit-evaluate` Package

## 2.1 — Where it sits in the stack

```
   Domain libraries           geotoolz │ xr_toolz
                                  ▲
                                  │
   Infrastructure        ┌─ pipekit-cycle ─┐
                         │  pipekit-train  │
                         │  pipekit-evaluate ◄── (this report)
                         │  pipekit-experiment │
                         │  statecatalog   │
                         └─────────────────┘
                                  ▲
                                  │
   Framework                  pipekit ◄── pipekit-array
```

`pipekit-evaluate` is a **framework-layer sibling** of `pipekit-cycle`, `pipekit-train`, `pipekit-experiment`. Three observations:

1. **Carrier-agnostic core**, carrier-specific operators. The Protocols don’t know what’s flowing through; concrete metrics for `Field` are domain-shaped (xarray vs. GeoTensor) and live with their carrier in `xr_toolz` / `geotoolz`.
2. **Cross-package dependency profile**. It reads from observation catalogs (`geocatalog`) and state catalogs (`statecatalog`); produces artifacts that flow to `pipekit-experiment.ModelRegistry` for tracking; integrates with `pipekit-train` so the same metric can be a loss in training and an evaluator in validation.
3. **Composable with `pipekit-cycle`**. Evaluating a forecast pipeline isn’t “run the forecast then evaluate”; it can be “instrument the forecast cycle with evaluation hooks at each step.” The same lens machinery that decomposes a final-eval report can be used to log per-step diagnostics during a long rollout.

## 2.2 — Why a dedicated package, not spread across existing ones

The honest alternative is “put metrics in each domain library.” That’s where they live today (`xr_toolz.metrics`, etc.). Three reasons for consolidation:

1. **The Protocols are framework-level.** `Metric`, `EvaluationLens`, `EvaluationReport` are abstractions that all domain libraries need to satisfy. Putting them in pipekit core bloats core; putting them in one domain library inverts dependencies.
2. **The matrix view is structurally coherent.** A user wanting “probabilistic spectral evaluation of a forecast” is touching the Probabilistic lens, the Spectral lens composition, and the Field unit. These spread across three packages today. A dedicated home makes the coherent surface discoverable.
3. **`EvaluationReport` is a registry artifact.** Like `pipekit-experiment.TrainingArtifact`, it’s a content-addressed serialisable thing. It belongs alongside other artifact types in a peer infrastructure package.

The alternative (spread across existing packages) is acceptable for v0.1 — much of `pipekit-evaluate`’s content is moving symbols around — but the **Protocols + Report + Lens composition** are new framework code that needs a home. Pragmatic recommendation: start the package, even if v0.1 is mostly re-exports from `xr_toolz.metrics` + a few new operators.

## 2.3 — Source layout

```
pipekit-evaluate/
  __init__.py                # public re-exports
  _src/
    protocols.py             # Metric, EvaluationLens, EvaluationUnit Protocols
    units.py                 # Field, Statistic, Trajectory, Event, Budget carrier types
    report.py                # EvaluationReport, ReportEntry, content-addressed serialisation
    
    metrics/
      pointwise.py           # RMSE, MAE, NSE, IoA, NormalisedBias
      probabilistic.py       # CRPS, EnergyScore, BrierScore, RankHistogram
      spectral.py            # PSDCompare, SpectralSlopeFit, KineticEnergySpectrum, StructureFunction
      structural.py          # SSIM, FSS, PerceptualLoss
      detection.py           # POD, FAR, CSI, IoU, Hausdorff, ContingencyTable
      physical.py            # GeostrophicBalance, StaticStability, MassClosure, PVConservation
    
    lenses/
      regional.py            # ByRegion
      scale.py               # ByScale (spectral, wavelet)
      temporal.py            # ByLeadTime, ByMonth, BySeason
      event.py               # ByEvent (restrict to event-occupied)
      ensemble.py            # ByMember (per-member stats), Aggregated (ensemble-mean)
    
    aggregations.py          # Mean, StratifiedMean, ReportTable
    
    adapters/
      xr_toolz.py            # Bridges to xr_toolz.metrics (extras-gated)
      geotoolz.py            # Bridges to geotoolz.metrics
      xskillscore.py         # xskillscore integration
      properscoring.py       # properscoring integration
      train.py               # pipekit-train integration: any Metric as a Loss
      experiment.py          # pipekit-experiment integration: log Reports
```

Total estimate: ~1500 LOC of framework + ~800 LOC of metric implementations (much re-using existing code).

## 2.4 — The Protocols

```python
@runtime_checkable
class EvaluationUnit(Protocol):
    """Type marker for things that can be scored.
    
    Concrete implementations: Field (Dataset / GeoTensor), Statistic
    (1D distribution / spectrum), Trajectory, Event, Budget.
    """
    @property
    def unit_kind(self) -> Literal["field", "statistic", "trajectory", "event", "budget"]: ...


@runtime_checkable
class Metric(Protocol):
    """The evaluation operator. Takes prediction + reference, returns score(s)."""
    @property
    def lens(self) -> Literal["pointwise", "probabilistic", "spectral", 
                              "structural", "detection", "physical_constraint"]: ...
    @property
    def differentiable(self) -> bool: ...
    @property
    def stage_compatibility(self) -> set[Literal["training", "validation", 
                                                  "final", "monitoring"]]: ...
    def __call__(self, prediction: EvaluationUnit, reference: EvaluationUnit) -> Any: ...


@runtime_checkable
class EvaluationLens(Protocol):
    """A decomposition wrapper. Applies a metric in a structured way.
    
    ByRegion, ByScale, ByLeadTime, ByEvent, ByMember are concretes.
    """
    def __call__(self, metric: Metric, prediction: EvaluationUnit, 
                 reference: EvaluationUnit) -> "ReportEntry": ...
```

Three Protocols. Runtime-checkable. Other packages (xr_toolz, geotoolz) satisfy them structurally.

## 2.5 — The EvaluationReport artifact

The output of an evaluation campaign. Sibling of `TrainingArtifact` from Report 12.

```python
@dataclass
class ReportEntry:
    """One row in an evaluation report."""
    metric_name: str
    lens_path: tuple[str, ...]   # e.g., ("ByRegion", "atlantic", "ByLeadTime", "24h")
    value: float | np.ndarray | dict
    unit: str                     # the EvaluationUnit kind
    stage: str                    # at which lifecycle stage this was computed


@dataclass  
class EvaluationReport:
    """Composable evaluation artifact.
    
    Aggregates results across lenses, metrics, units, stages.
    Content-addressed: hash(entries, model_hash, dataset_hash, config).
    Serializable, diffable, registrable in pipekit-experiment.
    """
    entries: list[ReportEntry]
    model_ref: str               # hash from ModelRegistry
    dataset_ref: str             # content_hash of evaluation dataset
    pipeline_config: dict        # the evaluation pipeline YAML
    timestamp: datetime
    
    def to_pandas(self) -> pd.DataFrame: ...
    def to_dict(self) -> dict: ...
    def content_hash(self) -> str: ...
    def diff(self, other: "EvaluationReport") -> "ReportDiff": ...
    def filter(self, **selectors) -> "EvaluationReport": ...
```

Two operations that matter:

- **`.diff(other)`** — compare two reports (e.g., v3 vs. v4 of a model) across all dimensions
- **`.filter(lens="ByRegion", region="atlantic")`** — slice the report along the matrix

`EvaluationReport` is content-addressable. Registered in `pipekit-experiment.ModelRegistry` alongside the model it evaluated. **Provenance closes**: model → training artifact → trained-model hash → evaluation artifact → score, all traceable.

## 2.6 — Worked example: comprehensive forecast evaluation

```python
import pipekit_evaluate as pe
import pipekit_experiment as px

# Pull a forecast and its verifying analyses from statecatalog
state_cat = sc.DuckDBStateCatalog.open("s3://reanalysis/methane_v3/states.parquet")
forecasts = state_cat.queries.forecast_chain(run_time=t0, model_config_hash=H)
truth_chain = [state_cat.queries.latest_analysis(before=f.valid_time) for f in forecasts]

# Define the evaluation pipeline as composable operators
evaluation = pe.Pipeline([
    # Point-wise on the Field unit, decomposed by lead time and region
    pe.ByLeadTime(
        pe.ByRegion(
            regions={"arctic": arctic_mask, "tropics": tropics_mask, "global": None},
            metric=pe.metrics.pointwise.RMSE(),
        ),
    ),
    # Spectral evaluation: does the model preserve the kinetic-energy spectrum?
    pe.metrics.spectral.PSDCompare(
        spatial_dims=("lat", "lon"),
        expected_slope=-3.0,
        tolerance=0.5,
    ),
    # Probabilistic: if the forecast is ensemble, score ensemble calibration
    pe.metrics.probabilistic.CRPS(ensemble_dim="member"),
    # Physical constraint: did mass conservation close over the forecast window?
    pe.metrics.physical.MassClosure(tolerance=0.01),
    # Phenomena: did predicted marine heatwaves match observed?
    pe.ByEvent(
        detector=pe.events.MarineHeatwaveDetector(
            percentile=90, min_duration=5,
        ),
        metric=pe.metrics.detection.CSI(),
    ),
])

# Run the evaluation
report = evaluation.run(predictions=forecasts, reference=truth_chain)

# The report aggregates everything
print(report.to_pandas())
#   metric           lens_path                       value       unit
#   ─────────────────────────────────────────────────────────────────
#   RMSE             ByLeadTime=24h, ByRegion=arctic    0.42  field
#   RMSE             ByLeadTime=24h, ByRegion=tropics   0.18  field
#   RMSE             ByLeadTime=48h, ByRegion=arctic    0.61  field
#   ...
#   PSDCompare       (none)                              {slope: -2.7, error: 0.30}  field
#   CRPS             (none)                              0.082  field
#   MassClosure      (none)                              {drift: 1.2e-5}  budget
#   CSI              ByEvent=MarineHeatwave              0.71  event

# Register the report — content-addressed alongside the model
registry = px.S3ModelRegistry(...)
registry.attach_evaluation(model_hash=H, report=report)
```

The same pipeline serves training validation (`evaluation.run(...)` during validation with a smaller subset) and final-eval (with the full test catalog). The Stage axis is what distinguishes them: differentiable metrics get exposed as training losses; expensive metrics run only at final-eval.

## 2.7 — Cross-package integration

### 2.7.1 — With `pipekit-train`

Any `Metric` can be a training loss:

```python
# Use the same RMSE as both training loss AND validation metric
metric = pe.metrics.pointwise.RMSE()

loop = pt.TrainingLoop(
    model_op=...,
    dataset=...,
    loss=pe.adapters.train.MetricAsLoss(metric),   # the same metric
    val_dataset=...,
    callbacks=[
        pt.LogToExperiment(...),
        pe.adapters.train.EvaluationCallback(      # runs evaluation pipeline
            pipeline=evaluation_pipeline,
            every_n_epochs=5,
        ),
    ],
)
```

`MetricAsLoss` checks `metric.differentiable` and refuses if not. Stage discipline enforced.

### 2.7.2 — With `pipekit-cycle`

Per-step evaluation during long rollouts:

```python
forecast_with_eval = pc.Cycle(
    step_op=pk.Sequential([
        forward_model,
        pe.MetricObserver(metric=pe.metrics.physical.MassClosure(), report_to=report),
    ]),
    n_steps=72,
)
```

`MetricObserver` is a `pipekit.Operator` that’s a no-op on the carrier but appends a `ReportEntry` to a side channel. Lets you monitor conservation drift, spectral degradation, etc., per-step during long rollouts.

### 2.7.3 — With catalogs

Evaluation is fundamentally cross-catalog: predictions live in `statecatalog`, references live in either `statecatalog` (model-vs-model) or `geocatalog` (model-vs-obs). The matchup pattern from `../supporting_info/geodata_lifecycle.md` is exactly the right substrate:

```python
matched = gc.queries.matchup(
    primary=state_cat.queries.forecast_chain(...),
    secondary=obs_cat,
    time_tolerance=timedelta(hours=3),
    space_tolerance_km=25.0,
)
report = evaluation.run_on_matched(matched)
```

This is the cleanest version of “verify forecasts against in-situ observations”: the matchup produces co-located pairs; the evaluation pipeline scores each pair.

## 2.8 — Dependencies and optional extras

```toml
[project]
name = "pipekit-evaluate"
version = "0.1.0"
dependencies = [
    "pipekit>=0.1",
    "numpy>=2.0",
    "scipy>=1.10",
]

[project.optional-dependencies]
# Carrier-specific integrations
xarray  = ["xr-toolz>=0.1"]
geo     = ["geotoolz>=0.1"]

# External scoring libraries
xskill  = ["xskillscore>=0.0.26"]
proper  = ["properscoring>=0.1"]

# Lagrangian evaluation (Part 3)
lagrangian = ["xr-toolz[lagrangian]>=0.1"]

# Event detection (Part 3)
events  = ["xr-toolz[events]>=0.1"]

# Cross-package integration
catalog = ["geocatalog>=0.1", "statecatalog>=0.1"]
train   = ["pipekit-train>=0.1"]
experiment = ["pipekit-experiment>=0.1"]

# Deep-feature perceptual losses
perceptual = ["torch>=2.0"]   # for pretrained feature extractors

all = ["pipekit-evaluate[xarray,geo,xskill,proper,lagrangian,events,catalog,train,experiment]"]
```

-----

# Part 3 — Supporting Infrastructure Gaps

`pipekit-evaluate` alone isn’t enough. Three pieces of supporting infrastructure need to land in parallel — they’re prerequisites for several of the matrix cells.

## 3.1 — `xr_toolz.lagrangian` (particle tracking)

**What’s missing:** Particle advection through a velocity field. Required for the Trajectory unit and most Lagrangian-frame evaluation.

**What it ships:**

```python
xr_toolz.lagrangian/
  particles.py             # Particle, ParticleSet — carrier types
  advection.py             # AdvectParticles (operator wrapping diffrax integration)
  dispersion.py            # SingleParticleDispersion, PairDispersion, RelativeDispersion
  ftle.py                  # FiniteTimeLyapunovExponent operator
  lcs.py                   # LagrangianCoherentStructures (variational, hyperbolic)
  filaments.py             # TracerFilamentStatistics
```

**Dependencies:** `xarray`, `diffrax` (for ODE integration), `scipy` (for sparse linalg in FTLE).

**Why xr_toolz, not somax:** Particle tracking is *evaluation infrastructure*, not a forward model. It consumes a velocity field (xarray) and produces trajectory statistics; somax is for ocean dynamics simulation. Worth being clear about this — there’s a temptation to put particle tracking in somax because it’s “ocean-y,” but it’s used at evaluation time on any velocity field including ones the somax forward model didn’t produce.

**Effort:** ~2 weeks. The hardest part is FTLE/LCS implementation; the rest is wrapping `diffrax`.

## 3.2 — `xr_toolz.events` (event detection)

**What’s missing:** Detect discrete phenomena in a Dataset (marine heatwaves, mesoscale eddies, atmospheric rivers, plume detections) and produce a structured `Event` artifact.

**What it ships:**

```python
xr_toolz.events/
  protocols.py             # Event, EventDetector, EventCatalog
  detectors/
    threshold.py           # ThresholdDetector (climatological percentile)
    closed_contour.py      # ClosedContourDetector (e.g., for eddies via SSH)
    object.py              # ObjectDetector (connected components in masks)
  matching.py              # match_events(predicted, reference, tolerances)
  attributes.py            # Centroid, Area, Duration, Intensity, Trajectory
```

**Effort:** ~2 weeks. Detectors are bespoke per phenomenon; the framework is small.

## 3.3 — `EventCatalog` — a new catalog type

**What’s missing:** Events need their own catalog. Once you detect marine heatwaves over 30 years, you have a *catalog* of events — each with bounds, duration, attributes, lineage to the source field. This is structurally a third catalog type alongside `geocatalog` (observations) and `statecatalog` (model states).

```python
# Lives in xr_toolz.events.catalog or as a sibling package eventcatalog
class EventCatalog:
    """Indexed catalog of detected events.
    
    Wire format: EventSlice with bbox + time_window + event_id + attributes.
    Backends: InMemoryEventCatalog (pandas), DuckDBEventCatalog (extras-gated).
    """
    ...
```

This is analogous to `statecatalog` (Report 13): different wire format from observations, different query semantics, parallel Protocol design. Three-catalog model (`geocatalog` for observations, `statecatalog` for model states, `EventCatalog` for events) becomes the full data substrate.

**Lean: ship initially as a submodule of `xr_toolz.events`**, promote to sibling package only if it grows. Avoids creating a fourth catalog package speculatively.

## 3.4 — `pipekit-array.metrics.classification`

**What’s missing:** Detection lens metrics (POD, FAR, CSI, IoU, Brier) are *classification* metrics, not regression. They’re array-shaped, not domain-specific. They belong in `pipekit-array.metrics.classification` alongside the existing regression metrics.

**What it ships:** A small module, ~150 LOC, with the canonical detection metrics implemented multi-backend (numpy / JAX / etc.) via the Array API.

**Effort:** ~3 days.

## 3.5 — Updates to `xr_toolz.transforms` for spectral comparison

**What’s missing:** `xr_toolz.transforms` has FFT and wavelet *derivation* operators. It doesn’t have *comparison* operators (compare two PSDs, fit a spectral slope and test against expected exponent, compute KE spectrum at multiple latitudes and stratify).

**What gets added:** ~5 new operators in `xr_toolz.transforms.spectral_compare` or — better — `pipekit-evaluate.metrics.spectral` (since these are evaluation operators, not transforms).

-----

# Part 4 — Recommendations & Tradeoffs

## 4.1 — v2 vision document edits

Three additions to make v2 fully integrate the evaluation framework:

1. **Add the three-axis framework** (Unit × Lens × Stage) to the v2 Geo-Task Taxonomy section. The current taxonomy has Time / Space / Variables / Representation / Tier — these are about *data*. The evaluation framework adds three about *assessing models*.
2. **Add a section on Multi-dimensional Evaluation** between “The L0–L4 Pipeline” and the design principles, citing the three failure modes (double-penalty, scale-blind aggregation, Eulerian blindness). This is the operational counterpart to the data-tier framing.
3. **Strengthen the “ML at every level” principle** by noting that evaluation is also at every level — different metrics suit L0–L2 retrievals (point-wise field) vs. L3–L4 forecasts (probabilistic + physical-constraint + phenomena).

## 4.2 — Build order

Realistic sequencing:

```
v0.1 of pipekit-evaluate (3-4 weeks)
  • Protocols (Metric, EvaluationLens, EvaluationUnit)
  • EvaluationReport artifact + content-addressing
  • Point-wise + probabilistic metrics (re-export from xr_toolz + xskillscore)
  • ByRegion, ByLeadTime lenses
  • Basic adapters to pipekit-train and pipekit-experiment

v0.2 of pipekit-evaluate + xr_toolz.lagrangian (4-6 weeks)
  • Lagrangian operators in xr_toolz
  • Trajectory unit + dispersion metrics in pipekit-evaluate
  • Spectral comparison operators
  • Structural metrics (SSIM, FSS)

v0.3 of pipekit-evaluate + xr_toolz.events (4-6 weeks)
  • Event detection in xr_toolz
  • Event unit + detection metrics in pipekit-evaluate
  • EventCatalog (initially as submodule)
  • Physical-constraint metrics (conservation budgets, balance checks)

v0.4 of pipekit-evaluate (2-3 weeks)
  • Per-step evaluation in pipekit-cycle (MetricObserver)
  • Perceptual losses (deep-feature-based)
  • Report diff and visualization helpers
```

Total: ~3-4 months of focused work to land the full framework. v0.1 is enough to be useful on its own (covers ~70% of practical use cases); the later versions close the matrix completely.

## 4.3 — Honest tradeoffs

**What gets better:**

1. **Evaluation becomes a first-class concern, not a postscript.** The framework forces honest assessment along multiple dimensions.
2. **Cross-package coherence.** Same metric in training (as loss), validation (as score), final eval (as report entry). No duplicated implementations.
3. **Provenance closes.** Model → training artifact → trained model → evaluation report. All content-addressed, all traceable.
4. **Phenomena and Lagrangian skill become routine** instead of bespoke research code per evaluation.
5. **The matrix view exposes gaps.** Hard to ignore “we never evaluate the spectral slope of our predictions” when the matrix has an empty cell labeled “Spectral × Field” staring at you.

**What gets harder:**

1. **More moving pieces.** Five new packages worth of effort in this report (the main one plus supporting infrastructure). Mitigation: phased build order; v0.1 ships only the framework + cheap metrics.
2. **The matrix is daunting.** A user faced with 30+ metrics across 6 lenses across 5 units may pick paralysed. Mitigation: ship sensible defaults (e.g., `pipekit_evaluate.presets.weatherbench()`, `pipekit_evaluate.presets.oceanbench()`) that pre-compose appropriate metrics for common evaluation cases.
3. **Lagrangian evaluation is computationally expensive.** Advecting 100K particles for 72 hours is real compute. Mitigation: clear documentation that this is final-eval-only; provide downsampled variants.
4. **Event detection is domain-specific.** Marine heatwaves, mesoscale eddies, atmospheric rivers each have their own detection algorithm. The framework provides the structure (`Event`, `EventDetector`, matching, attributes); concrete detectors live in domain modules. Mitigation: ship 2-3 reference detectors as exemplars; treat the rest as user-contributed.
5. **Spectral metrics have edge cases.** PSD comparison is sensitive to windowing, detrending, sampling. Get this wrong and the metric is misleading. Mitigation: thorough documentation; sensible defaults; cite the relevant references in operator docstrings.

## 4.4 — What this doesn’t try to be

Three things explicitly **not** in scope:

1. **A general-purpose model evaluation framework** (like `evaluate` or `lm-eval`). Pipekit-evaluate is geophysics-shaped: it understands gridded fields, particle trajectories, conservation budgets. NLP / image-classification evaluation has its own ecosystem.
2. **An interpretability framework.** Why does the model fail? is a different question from how does the model fail? Interpretability (SHAP, attention rollout, etc.) is downstream.
3. **A benchmarking framework.** WeatherBench, OceanBench, etc. define *which* metrics on *which* datasets constitute the canonical benchmark. Pipekit-evaluate provides the operators; the benchmark choice is per-project.

## 4.5 — Recommendation

**Ship `pipekit-evaluate` as a separate sister package** with two supporting infrastructure additions (`xr_toolz.lagrangian`, `xr_toolz.events`). Signals:

- Distinct conceptual surface (the three-axis framework) deserves its own home
- Cross-package integration concerns argue against putting it in any one domain library
- The `EvaluationReport` artifact type is structurally analogous to `TrainingArtifact` — peer infrastructure
- Lagrangian and event-detection prerequisites are substantial enough to be their own work

The framework framing (Part 1) should be adopted into v2 *regardless of whether the package gets built*. The package proposal (Part 2) is one structurally honest implementation; alternative implementations are possible. **Don’t conflate adopting the framework with committing to the package.**

The headline win for the GeoStack: **evaluation goes from “RMSE on validation” to a structured multidimensional assessment with first-class artifacts, traceable provenance, and the same operator-graph machinery as training and inference**. This is what the L4 / forecast / DA story needs. Without it, “ML at every level” remains a research claim; with it, it becomes operational discipline.

-----

## Summary

The source’s five-axis evaluation framework reorganises cleanly into three orthogonal axes — **Unit** (what’s scored: Field, Statistic, Trajectory, Event, Budget) × **Lens** (what kind of critique: point-wise, probabilistic, spectral, structural, detection, physical-constraint) × **Stage** (when in the lifecycle: training, validation, final, monitoring). The Lens × Unit matrix exposes both the metrics worth implementing and the gaps in the current stack.

`pipekit-evaluate` is a sibling package that owns this surface: Protocols (`Metric`, `EvaluationLens`, `EvaluationUnit`), concrete operators across the matrix cells, the `EvaluationReport` artifact, and integration with the rest of the GeoStack (`pipekit-cycle`, `pipekit-train`, `pipekit-experiment`, catalogs). Three supporting infrastructure additions — `xr_toolz.lagrangian` for particle tracking, `xr_toolz.events` for event detection, and `pipekit-array.metrics.classification` for detection metrics — are scoped as parallel work.

Realistic timeline: 3-4 weeks for v0.1 (framework + cheap metrics), 3-4 months for the full v0.4 surface across all matrix cells. The framework framing should be adopted into v2 regardless of package timing — multidimensional evaluation isn’t optional for honest geophysical ML, and the source’s argument for that is the strongest single point in the document.