---
title: "Report 0 — The GeoStack: an introduction"
subject: geotoolz master plan
short_title: "R0 — Overview"
authors:
  - name: J. Emmanuel Johnson
    affiliations:
      - UNEP
      - IMEO
      - MARS
    orcid: 0000-0002-6739-0053
    email: jemanjohnson34@gmail.com
license: CC-BY-4.0
keywords: geotoolz, geostack, pipekit, overview, master-plan
---

# Report 0 — The GeoStack: an introduction

|                  |                                                                                                                         |
| ---------------- | ----------------------------------------------------------------------------------------------------------------------- |
| **Status**       | Entry document — start here                                                                                             |
| **Reading time** | ~45 min if you read everything; ~15 min if you skim the diagrams and code snippets                                      |
| **Audience**     | Anyone trying to understand the full stack: what it is, why it exists, how the pieces fit, what’s built, what’s planned |
| **Position**     | Sits above all other reports. Use this to navigate to the deep dives.                                                   |
| **References**   | All 16 numbered reports + `../supporting_info/geostack_vision.md` + `../supporting_info/geodata_lifecycle.md` + `../supporting_info/benchmark_gallery.md`                             |

## What this document is

A synthesis. The vision document (`../supporting_info/geostack_vision.md`) is the manifesto; the numbered reports (1–16) are scoping deep-dives for each piece; this document weaves them together into a single readable starting point. Lots of diagrams, lots of code snippets, lots of cross-references. Open questions and a plan at the end.

If you only have time for one document, this is the one. Otherwise, this is the map.

-----

## 1. The elevator pitch

> A vertically integrated, JAX-native research software stack for geophysical modeling, inference, and data assimilation — from structured linear algebra primitives through composable operator graphs to indexed multi-tier data products, with ML pluggable at every level.

In one sentence: **the operator-graph abstraction extended from numerical primitives all the way up to end-to-end pipelines, with content-addressed data and models throughout**.

In one paragraph: this stack solves a specific problem — there’s no Keras-equivalent for geophysical work. You can build great JAX numerics (gaussX, lineax, equinox), and you can build great xarray pipelines, but there’s no connective tissue between them. The GeoStack fills that gap with a:
- carrier-agnostic framework (`pipekit`)
- peer infrastructure for indexing observations and model states (`geocatalog`, `statecatalog`, `geopatcher`)
- training and evaluation machinery (`pipekit-train`, `pipekit-evaluate`, `pipekit-experiment`)
- domain libraries for the carriers people actually use (`geotoolz` for GeoTensor, `xr-toolz` for xarray)
- clean adapter pattern so existing algorithm libraries (filterX, vardaX, plumax, pyrox-gp, gaussFlowX) plug in without coupling.

-----

## 2. The shape of the problem

Five gaps motivate everything below. The first four are old; the fifth has only become visible recently.

1. **Scattered numerics.** Same linear algebra, kernel methods, filtering routines reimplemented in every project. No shared primitives.
2. **ML tooling doesn’t serve classical numerics.** Keras/PyTorch layers assume supervised learning on tensors. They don’t naturally express linear operators, PDE solvers, state estimation, uncertainty propagation.
3. **Monolithic domain software.** Ocean models, retrieval algorithms, DA systems are dense, tightly coupled, hard to recombine.
4. **No connective tissue.** Even with good numerics and good ML, there’s no Keras-like pipeline to compose them for real geophysical work.
5. **No indexed model-state tier.** Observations are catalogable (STAC, GeoParquet). Model outputs (forecasts, analyses, reanalysis) aren’t — they’re scattered files with bespoke conventions. The L3–L4 half of the lifecycle has no equivalent of the catalogs that organise L0–L2.

The stack addresses all five.

-----

## 3. Three organising axes

Three axes structure the whole framework. They’re orthogonal: every operation happens *somewhere* on all three. Axis 1 is the research loop. Axis 2 is the data lifecycle. Axis 3 is the research-to-production journey.

### 3.1 The modeling cycle (axis 1)

```
        Real-World System
              │
              ▼
     ┌─── Abstract ───┐
     │                 │
     ▼                 ▼
  Equations         Code
  (analysis)     (simulation)
     │                 │
     └──► Predictions ◄┘
              │
              ▼
     Validate against
       observations
              │
              ▼
         Refine model
```

**Start simple. Add complexity only when validation demands it.** This is the research loop. Every package in the stack exists to make one or more steps of this cycle composable.

### 3.2 The L0–L4 data tier (axis 2)

```
   L0 — Unstructured Obs       Raw instrument output
        │
        ▼   sensor reader (georeader)
   L1 — Structured Obs         Calibrated, georeferenced swaths
        │
        ▼   retrieval (geotoolz, plumax, RTMX)
   L2 — Gap-Filled Obs         Per-pixel geophysical retrievals
        │                       (gaps where retrieval fails)
        ▼   analysis (xr_toolz.interpolate, pyrox-gp, filterX, vardaX)
   L3 — Analysis               Regular grid; gap-filled
        │                       (the "world right now")
        ▼   forward model (somax, plumax, neural emulators)
   L4 — Reanalysis / Forecast  Dynamical model output
                                (analysis = data-constrained;
                                 reanalysis = model+data fusion;
                                 forecast = model projection)
```

**The data lifecycle.** L0–L2 lives in observation catalogs (`geocatalog`). L3–L4 lives in state catalogs (`statecatalog`). ML enters at every transition.

Eman’s Comments
- So technically, I think georeader is designed to read L0, L1, and L2 Data
- xrreader (a new package) should be for L3,L4 Data
- it would be nice to see the geosciences fan out from the structured obs
	- retrieval: radiances —> ocn, atm, land, ice

### 3.3 The two-stream convergence

L0–L4 isn’t one chain. It’s two chains converging at L2/L3 via matchup:

```
   Satellite (top-down)              In-situ (bottom-up)
   
   L0  Raw telemetry                 ──    (not applicable)
        │
        ▼  cal + geoloc
   L1  Calibrated radiances          ──    (not applicable)
        │
        ▼  retrieval
   L2  Geophysical variables  ◄──┐    Argo, CTD, moorings,
                                  │    gliders, drifters
        │                         │    (calibrated, depth axis,
        ▼ gridding + composite    │     sparse coverage)
                                  │              │
   L3  Gridded products ◄─────────┴──────────────┘
                                  │  spatiotemporal matchup
        │                            (the convergence operation)
        ▼ DA + fusion
                              
   L4  Analysed / fused fields       (in-situ enters via assimilation)
```

The matchup pattern is canonical and deserves a real operator family. Covered in `../supporting_info/geodata_lifecycle.md`.

### 3.4 The three-layer model (transformations along the lifecycle)

The cycle and the L0–L4 axis are joined by a third lens — what we *do* to the data:

```
   ┌─────────────────────────────────────────────┐
   │  SCIENTIFIC-DATA LAYER  (L0→L4, two streams)│
   │  Owned by: georeader + geocatalog +         │
   │            geotoolz/xr-toolz + statecatalog │
   └─────────────────────┬───────────────────────┘
                         │  ML processing pipeline
                         │  (harmonisation, tensorisation)
                         ▼
   ┌─────────────────────────────────────────────┐
   │  ML-READY LAYER                             │
   │  Owned by: pipekit-train.CachedDataset      │
   │            + CF-compliant Datasets          │
   │            + content-addressed splits       │
   └─────────────────────┬───────────────────────┘
                         │  representation learning
                         │  (compression, latent mapping)
                         ▼
   ┌─────────────────────────────────────────────┐
   │  EMBEDDING LAYER                            │
   │  Owned by: pipekit-train + pipekit-cycle    │
   │            (encoder/decoder/latent dynamics │
   │             in pipekit-experiment registry) │
   └─────────────────────────────────────────────┘
```

### 3.5 The six-step data-driven cycle (axis 3)

The research-to-production journey. **Every domain library implicitly follows this cycle**; the framework makes it composable.

```
   ┌─────────────────────────────────────────────────────────────┐
   │                                                             │
   │   (1)  Simple Model                                         │
   │         │   a generative story; physics you can simulate    │
   │         ▼                                                   │
   │   (2)  Model-Based Inference          ◄── ORACLE for 3,4,5  │
   │         │   slow but exact; classical DA / inversion        │
   │         ▼                                                   │
   │   (3)  Model Emulator       (skip if forward model is cheap)│
   │         │   neural surrogate trained on Step 1 simulations  │
   │         ▼                                                   │
   │   (4)  Emulator-Based Inference                             │
   │         │   Step 2 again, but seconds instead of hours      │
   │         ▼                                                   │
   │   (5)  Amortized Inference (Predictor)                      │
   │         │   direct map: observations → posterior params     │
   │         ▼                                                   │
   │   (6)  Improve  ──────────────────────────────────────────┐ │
   │         ↑    upgrade model / data / emulator / predictor  │ │
   │         │    with previous step as ground truth           │ │
   │         └────────────────────────────────────────────────-┘ │
   │                                                             │
   └─────────────────────────────────────────────────────────────┘
```

**Two structural commitments fall out:**

1. **Step 2 as oracle.** Classical methods (`filterX`, `vardaX`, `pyrox-gp`) are not legacy code to be replaced by neural emulators. They become *ground-truth generators* against which Steps 3–5 are validated. The classical path stays alive forever, promoted to oracle status.
2. **Benchmarks as formalised understanding.** The act of writing a benchmark contract (carriers, references, metrics, splits, baselines, expected failure modes) is the act of formalising what you understand about the problem. Each cycle-step transition is itself a benchmarkable contract. Covered in Report 16 and `../supporting_info/benchmark_gallery.md`.

The cycle maps directly onto stack pieces: 
- Step 1 → Tier 3 domain libraries (`somax`, `plumax`)
- Step 2 → `pipekit-cycle.DACycle` with classical analysis steps
- Step 3 → `pipekit-train.SimulationDataset` + emulator in `pipekit-experiment.ModelRegistry`
- Step 4 → `pipekit-cycle.DACycle` with `NeuralForward`
- Step 5 → `pipekit-train` with `gaussFlowX` / `pyrox-nn`
- Step 6 → `pipekit-evaluate.EvaluationReport` diffs.

### 3.6 How the three axes relate

The three axes form a cube of operations: at any point in the framework you’re somewhere on the modeling cycle (research stage), somewhere on the L0–L4 axis (data maturity), and somewhere on the six-step cycle (production maturity).

```
                  Axis 3: six-step cycle (production maturity)
                  ────────────────────────────────────────►
                  Step 1   Step 2   Step 3   Step 4   Step 5

   Axis 2: L0→L4 (data maturity)
   ▲
   │  L3→L4 │ PDE   │ EnKF   │ Neural │ Fast   │ Direct │
   │  fcst  │ frwd  │ 4DVar  │ frwd   │ DA     │ fcst   │
   │  ──────┼───────┼────────┼────────┼────────┼────────┤
   │  L3→L3 │ Frwd  │ Class. │ Neural │ Neural │ Direct │
   │  anal  │ + pri │ DA     │ frwd   │ DA     │ anal   │
   │  ──────┼───────┼────────┼────────┼────────┼────────┤
   │  L2→L3 │ GP    │ Krig./ │ Neural │ Fast   │ Neural │
   │  fill  │ prior │ DINEOF │ map    │ gap-fil│ post.  │
   │  ──────┼───────┼────────┼────────┼────────┼────────┤
   │  L1→L2 │ RT    │ Match  │ Neural │ Fast   │ Direct │
   │  retr  │ model │ filter │ RT     │ retr   │ retr   │
   │  ──────┼───────┼────────┼────────┼────────┼────────┤
   │  L0→L1 │ Cal   │ Class. │ Neural │ Fast   │ Direct │
   │  cal   │ model │ cal    │ cal    │ cal    │ cal    │
   │
   (Axis 1: the modeling cycle runs perpendicular —
    every cell can be "abstracted, simulated, validated, refined")
```

**Every cell is a concrete benchmarkable artifact.** Every cell uses the previous column as oracle. The whole L0–L4 chain is a nested set of six-step cycles, each gated by benchmarks. This is what makes the framework operationally improvable: improving any cell triggers re-running its downstream column; lineage is content-addressed; nothing is opaque.

-----

## 4. The big picture stack

Two granularities. First the high-level (six tiers), then the package map (~20 packages).

### 4.1 High-level — six tiers

```
   ┌────────────────────────────────────────────────────────────────┐
   │ Tier 6 — Serving (external)                                    │
   │   FastAPI │ LitServe │ Fused │ Modal                           │
   └────────────────────────────────────────────────────────────────┘
                                ▲
   ┌────────────────────────────────────────────────────────────────┐
   │ Tier 5 — Orchestration (external)                              │
   │   Prefect │ MLflow │ DVC │ Hydra │ Metaflow │ W&B              │
   └────────────────────────────────────────────────────────────────┘
                                ▲
   ┌────────────────────────────────────────────────────────────────┐
   │ Tier 4 — Pipeline Infrastructure  (carrier-neutral, OWNED)     │
   │   Framework:    pipekit │ pipekit-array │ pipekit-jax          │
   │   ML loops:     pipekit-cycle │ pipekit-train │ pipekit-eval   │
   │                 pipekit-experiment                             │
   │   Infra:        georeader (substrate) │ geocatalog │           │
   │                 geopatcher │ xrpatcher │ statecatalog          │
   └────────────────────────────────────────────────────────────────┘
                                ▲
   ┌────────────────────────────────────────────────────────────────┐
   │ Tier 3 — Domain Libraries  (carrier-specific, OWNED)           │
   │   geotoolz (GeoTensor) │ xrtoolz (xarray) │ geopandas (vector) │
   └────────────────────────────────────────────────────────────────┘
                                ▲
   ┌────────────────────────────────────────────────────────────────┐
   │ Tier 2 — Algorithms  (JAX-native, OWNED)                       │
   │   pyrox-gp │ pyrox-nn │ filterX │ vardaX │ gaussFlowX          │
   └────────────────────────────────────────────────────────────────┘
                                ▲
   ┌────────────────────────────────────────────────────────────────┐
   │ Tier 1 — Numerical Foundation  (JAX-native, OWNED)             │
   │   gaussX │ spectralDiffX │ finiteVolX │ optax-bayes │          │
   │   eqx-trainer                                                  │
   └────────────────────────────────────────────────────────────────┘
                                ▲
   ┌────────────────────────────────────────────────────────────────┐
   │ Tier 0 — Ecosystem (external)                                  │
   │   JAX │ equinox │ lineax │ optax │ diffrax │ numpyro │         │
   │   xarray │ pandas │ rasterio │ scipy │ ...                     │
   └────────────────────────────────────────────────────────────────┘
```

### 4.2 The package map — Tier 4 zoomed in

The framework + infrastructure tier is where most current work happens. Detailed view:

```
                              ┌──────────────────┐
                              │     pipekit      │
                              │   (framework)    │
                              └────────┬─────────┘
                                       │
            ┌──────────────────────────┼──────────────────────────┐
            │                          │                          │
   ┌────────┴────────┐        ┌────────┴────────┐       ┌─────────┴────────┐
   │  pipekit-array  │        │  pipekit-jax    │       │  pipekit-cycle   │
   │  (Array API     │        │  (Equinox-      │       │  (DA, time-step, │
   │   ops; multi-   │        │   backed,       │       │   iterative      │
   │   backend)      │        │   deferred)     │       │   inference)     │
   └─────────────────┘        └─────────────────┘       └──────────────────┘
            
            ┌──────────────────┐         ┌──────────────────┐
            │  pipekit-train   │         │ pipekit-experiment│
            │  (training loops │         │  (model registry, │
            │   for emulators, │         │   tracker adapters│
            │   amortized inf) │         │   MLflow, W&B)    │
            └──────────────────┘         └──────────────────┘

            ┌──────────────────┐         ┌──────────────────┐
            │ pipekit-evaluate │         │  benchmarks      │
            │  (multidim eval, │         │  (in pipekit-    │
            │   reports,       │         │   evaluate;      │
            │   3-axis matrix) │         │   contracts)     │
            └──────────────────┘         └──────────────────┘

                        Infrastructure peers:
            
   ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐
   │  georeader   │  │  geocatalog  │  │  geopatcher  │  │ statecatalog │
   │  (GeoTensor, │  │  (obs index, │  │  (4-axis     │  │  (L3-L4 model│
   │   readers,   │  │   GeoSlice,  │  │   patcher,   │  │   states,    │
   │   I/O)       │  │   L0-L2)     │  │   Field/Dom) │  │   StateSlice)│
   └──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘
```

### 4.3 The dependency graph

How they import each other:

```
            geotoolz                xr-toolz
                ▲                       ▲
                │                       │
                └──────┬─────────┬──────┘
                       │         │
                       ▼         ▼
              pipekit-cycle    pipekit-train ◄── pipekit-experiment
                       │              │                  │
                       └──────┬───────┘                  │
                              ▼                          │
                          pipekit-evaluate ◄─────────────┘
                              │
                              ▼
                       ┌──────┴──────┐
                       │             │
                  pipekit-array  pipekit-jax
                       │             │
                       └──────┬──────┘
                              ▼
                           pipekit
                              ▲
                              │
                       ┌──────┴──────┐
                       │             │
                  geocatalog    geopatcher
                       │             │
                       └──────┬──────┘
                              ▼
                          georeader  +  xarray ecosystem
```

**No circular dependencies.** Each layer only depends on layers below it. Domain libraries (geotoolz, xr-toolz) re-export common framework symbols so user code typically only imports one package.

-----

## 5. End-to-end walkthrough: methane attribution

The canonical example. Builds a complete L0→L4 pipeline from satellite scenes to source emission estimates, with ML at multiple stages.

```
   Step 1: Catalog the scenes  ───────────────────────► geocatalog
                                                       │
                                                       ▼
   Step 2: Read + retrieve     ───────────────────────► georeader + geotoolz
            (L1 → L2)                                  │
                                                       ▼
   Step 3: Match with in-situ  ───────────────────────► geocatalog.matchup
                                                       │
                                                       ▼
   Step 4: Grid + gap-fill     ───────────────────────► pyrox-gp via pipekit
            (L2 → L3)                                  │
                                                       ▼
   Step 5: DA cycle            ───────────────────────► pipekit-cycle.DACycle
            (L3 → L4)                                  │  (uses filterX +
                                                       │   plumax adapters)
                                                       ▼
   Step 6: Index outputs       ───────────────────────► statecatalog
                                                       │
                                                       ▼
   Step 7: Evaluate            ───────────────────────► pipekit-evaluate
            (multi-track)                              │  (vs CAMS, vs aircraft)
                                                       ▼
   Step 8: Register + serve    ───────────────────────► pipekit-experiment
                                                          + (FastAPI / LitServe)
```

Code:

```python
import pipekit as pk
import pipekit_array as pa
import pipekit_cycle as pc
import pipekit_train as pt
import pipekit_evaluate as pe
import pipekit_experiment as px

import geocatalog as gc
import geopatcher as gp
import statecatalog as sc

import geotoolz as gz
from filterx.adapters.pipekit import EnKFAnalysis
from plumax.adapters.pipekit import PlumeForward, ColumnObs

# ───── Step 1: Catalog the scenes ─────
emit_cat = gc.open_catalog("s3://imeo/emit/2024/*.parquet")
in_situ_cat = gc.open_catalog("s3://imeo/tccon/2024/*.parquet")

# ───── Step 2 + 3: Per-scene retrieval pipeline ─────
retrieval = pk.Sequential([
    gz.cloud.MaskClouds(qa_band=-1, bits=[10, 11]),
    gz.radiometry.PercentileClip(p_min=2, p_max=98),
    gz.matched_filter.CH4MatchedFilter(target_spectrum=ch4_template),
])

# Or: a trained emulator instead of classical matched filter
registry = px.S3ModelRegistry(bucket="imeo-models")
neural_retrieval = registry.load("ch4_retrieval_v3")
retrieval_ml = pk.Sequential([
    gz.cloud.MaskClouds(qa_band=-1, bits=[10, 11]),
    pa.ModelOp(neural_retrieval),
])

# ───── Step 4: Gap-filling with UQ ─────
from pyrox_gp.adapters.pipekit import KrigingOperator

gap_fill = KrigingOperator(
    kernel="matern52",
    length_scale_km=50.0,
    return_uncertainty=True,
)

# ───── Step 5: DA cycle ─────
da = pc.DACycle(
    forward_model=PlumeForward(species="CH4", dt=3600.0),
    obs_op=ColumnObs(instrument="TROPOMI"),
    analysis_step=EnKFAnalysis(inflation=1.05, localization="gaspari-cohn"),
    obs_source=pk.Sequential([
        gc.CatalogTimeQuery(window="hourly"),
        retrieval,
    ]),
    n_steps=24,
)

# ───── Step 6: State catalog output ─────
state_cat = sc.DuckDBStateCatalog.open("s3://imeo/methane_da_v3/states.parquet")
writer = sc.integrations.cycle.CycleStateWriter(
    state_catalog=state_cat,
    model_config_hash=pk.config_hash(da),
)

# Full forecasting pipeline
forecast_pipeline = pk.Sequential([da, writer])

# Run it
final_state, history = forecast_pipeline(initial_state, initial_carry_state)

# ───── Step 7: Multi-track evaluation ─────
evaluation = pe.Pipeline([
    pe.ByLeadTime(
        pe.ByRegion(
            regions={"permian": permian, "bakken": bakken, "global": None},
            metric=pe.metrics.pointwise.RMSE(),
        ),
    ),
    pe.metrics.probabilistic.CRPS(ensemble_dim="member"),
    pe.metrics.physical.MassClosure(tolerance=0.01),
    pe.ByEvent(
        detector=pe.events.MethanePlumeDetector(threshold_kg_h=100),
        metric=pe.metrics.detection.CSI(),
    ),
])

multitrack = pe.MultiTrackEvaluation(
    evaluation_pipeline=evaluation,
    references={
        "cams":     gc.open_catalog("s3://cams/methane_reanalysis/"),
        "aircraft": gc.open_catalog("s3://methaneair/2024/"),
        "tccon":    in_situ_cat,
    },
)

report = multitrack.run(predictions=history)

# ───── Step 8: Register everything ─────
registry.attach_evaluation(model_hash=pk.config_hash(da), report=report)
```

The same pipeline, written as a YAML, becomes the regulatory artifact (per Report 9 use case 9). The same operators run in a notebook (Case 1), an ETL job (Case 2), a FastAPI endpoint (Case 5), or a Fused UDF (Reports 15 + the Fused integration design).

-----

## 6. Per-tier briefs

A compact summary per package. The deep dives are in the numbered reports.

### 6.1 — Tier 0: Substrate

**georeader** (external, but central). Owns `GeoTensor` (the raster carrier) and the reader infrastructure (`RasterioReader`, `AsyncGeoTIFFReader`). The bottom of the stack everything raster-shaped builds on.

**xarray ecosystem** (external). `DataArray` / `Dataset` / `DataTree` carriers plus rioxarray / xvec / cf-xarray / regionmask / xskillscore / dask / intake. Broad, community-standard.

### 6.2 — Tier 1: Numerical Foundation

```
   gaussX           Structured linear algebra; Gaussian primitives;
                    exponential family. Wraps lineax, matfree.

   spectralDiffX    Pseudospectral differentiation, filters, PDE solvers.

   finiteVolX       Arakawa C-grid finite-volume operators.

   optax-bayes      Bayesian learning rule as optax GradientTransformations.

   eqx-trainer      Minimal JAX/equinox training loop.
```

Each is pure math. No domain knowledge. All `eqx.Module`-based; all jittable; all JAX-traceable.

```python
# Example: gaussX kernel matrix
from gaussx.kernels import Matern52
from gaussx.linalg import cholesky_solve

k = Matern52(length_scale=10.0, variance=1.0)
K = k.gram(x)                          # ←  Gram matrix as lineax operator
y_pred_mean = K @ cholesky_solve(K + sigma2 * I, y_train)
```

### 6.3 — Tier 2: Algorithms

Inference / learning / model families. Domain-agnostic but problem-structure-aware.

```
   pyrox-gp         GP building blocks for NumPyro hierarchical models.

   pyrox-nn         Bayesian deep learning with equinox + NumPyro.

   filterX          Differentiable ensemble Kalman methods.

   vardaX           Learnable variational data assimilation (3D/4D-Var).

   gaussFlowX       Rotation-based Gaussianization, normalizing flows.

   fairkl           Fairness-constrained kernel learning (Keras 3).

   keras-nerf       Neural fields for state estimation (Keras 3).

   keras-flows      Normalizing flows (Keras 3).
```

Keras 3 and Equinox are **equal-status backends**. Each algorithm’s adapter (`*.adapters.pipekit`) makes it composable into pipekit pipelines.

```python
# Example: filterX adapter as a DA analysis step
from filterx.adapters.pipekit import EnKFAnalysis

analysis = EnKFAnalysis(
    inflation=1.05,
    localization="gaspari-cohn",
    localization_radius_km=500.0,
)
# Satisfies pipekit_cycle.AnalysisStep Protocol via structural typing
```

### 6.4 — Tier 3: Domain Models

Geophysical forward models and parameterizations.

```
   somax            Ocean/atmosphere model zoo.

   xtremax          Extreme value modeling.

   methanex         End-to-end methane remote sensing.

   plumax           Atmospheric plume transport simulation.

   RTMX             Radiative transfer operators.
```

Each has a thin `adapters/pipekit.py` exposing the operator surface (`ForwardModel`, `ObservationOperator`, etc.) without polluting the algorithmic core.

### 6.5 — Tier 4: Pipeline Infrastructure (the headline of this work)

**pipekit** — the framework. ~2,150 LOC. Twelve semantic groups (Reports 1, 2):

```
   Foundations:    Operator, Sequential, Graph, Input, Node, ConfigMixin
   Convenience:    pipe, compose, juxt, complement
   Building blocks: Identity, Const, Lambda, Sink
   Control flow:   Branch, Switch, Try, Coalesce, Retry
   Observers:      Tap, Snapshot, ShapeTrace, Profile, Histogram
   Combination:    Fanout
   Caching:        Cache, Memoize
   QC:             Quarantine, AssertShape, AssertDType, AssertCallable
   Shape inference: Signature, compute_output_signature
   Parallelism:    ThreadMap, ProcessMap, AsyncMap, BatchedMap
   Serialisation:  dumps, loads, sandboxed loader
   State primitives: StatefulOperator, CarryState
```

**pipekit-array** — Array API operators. Multi-backend (numpy/JAX/CuPy/PyTorch). `ModelOp`, `Histogram`, `AssertValueRange`, etc. (Report 3)

**pipekit-jax** — Equinox-backed, JAX-traceable operators. Deferred to v0.3+. (Report 5)

**pipekit-cycle** — Time-stepping and DA. `Cycle`, `EnsembleCycle`, `DACycle`, three Protocols (`ForwardModel`, `ObservationOperator`, `AnalysisStep`). (Report 10)

**pipekit-train** — Training pipelines for emulators and amortized inference. Thin adapter over Lightning / Equinox+Optax / Keras 3. (Report 11)

**pipekit-experiment** — Tracker adapters (MLflow, W&B, DVC, Hydra) + content-addressed `ModelRegistry`. (Report 12)

**pipekit-evaluate** — Multidimensional evaluation framework. Three-axis matrix (Unit × Lens × Stage). Benchmark contracts as content-addressed artifacts. (Reports 14, 15)

**georeader** — substrate; covered above.

**geocatalog** — Spatiotemporal index for L0–L2 observations. Two backends (InMemory + DuckDB). `GeoSlice` as wire format. (Report 6)

**geopatcher** — Four-axis patcher framework. `Field` / `Domain` Protocols. ~60 classes for Geometry × Sampler × Window × Aggregation. (Report 7)

**statecatalog** — Spatiotemporal index for L3–L4 model states. `StateSlice` with valid_time/run_time/ensemble/lineage. (Report 13)

### 6.6 — Tier 3 (siblings): Domain Pipeline Libraries

**geotoolz** — GeoTensor-flavoured operators. Remote-sensing focus: sensor readers, retrieval, cloud, radiometry, indices, spectral, viz, plume, presets. (Reports 3, 8)

**xr-toolz** — xarray-flavoured operators. Ocean/atmosphere/reanalysis focus: validation, CRS, subset, masks, detrend, interpolate, metrics, kinematics, viz, calc, data sources, atm/ocn/ice. (Report 8)

Both consume the same Layer 4 peers. The substrate differs (georeader vs xarray ecosystem); the operator algebra is identical.

-----

## 7. Key code patterns

The essentials, with full working-looking snippets.

### 7.1 — Define an operator

```python
from pipekit import Operator
from typing import ClassVar

class PercentileClip(Operator):
    """Clip a GeoTensor to [p_min, p_max] percentiles per band."""
    
    forbid_in_yaml: ClassVar[bool] = False
    p_min: float = 2.0
    p_max: float = 98.0
    axis: tuple = (-2, -1)
    
    def _apply(self, gt):
        import numpy as np
        lo = np.quantile(gt.data, self.p_min / 100, axis=self.axis, keepdims=True)
        hi = np.quantile(gt.data, self.p_max / 100, axis=self.axis, keepdims=True)
        return gt.with_data(np.clip(gt.data, lo, hi))
```

That’s it. `ConfigMixin` (inherited from Operator) auto-derives `get_config()` from the dataclass-like fields. The operator is pickleable, serialisable to YAML, registrable in the sandboxed loader, composable via `|`.

### 7.2 — Compose pipelines

```python
# Linear: Sequential
preprocess = pk.Sequential([
    gz.radiometry.ToFloat32(),
    gz.radiometry.PercentileClip(p_min=2, p_max=98),
    gz.cloud.MaskClouds(qa_band=-1, bits=[10, 11]),
])

# Pipe syntax (equivalent)
preprocess = (
    gz.radiometry.ToFloat32() 
    | gz.radiometry.PercentileClip(p_min=2, p_max=98)
    | gz.cloud.MaskClouds(qa_band=-1, bits=[10, 11])
)

# DAG: Graph
opt = pk.Input("optical")
sar = pk.Input("sar")
dem = pk.Input("dem")

opt_clean = gz.cloud.MaskClouds(qa_band=-1, bits=[10, 11])(opt)
sar_db    = gz.sar.LinearToDB()(gz.sar.LeeSpeckle(window=7)(sar))
fused     = gz.fusion.AlignAndStack(target_grid="optical")(opt_clean, sar_db, dem)
classify  = pa.ModelOp(crop_classifier)(fused)

g = pk.Graph(
    inputs={"optical": opt, "sar": sar, "dem": dem},
    outputs={"crop_map": classify, "fused_stack": fused},
)

result = g(optical=s2_gt, sar=s1_gt, dem=dem_gt)
# result["crop_map"], result["fused_stack"]
```

### 7.3 — Catalogs

```python
# Build a catalog from a directory of GeoTIFFs
import geocatalog as gc

cat = gc.build_raster_catalog(
    "s3://imeo/sentinel2/2024/*.tif",
    backend="duckdb",
    out_uri="s3://imeo/sentinel2_index_2024.parquet",
)

# Or load an existing one
cat = gc.open_catalog("s3://imeo/sentinel2_index_2024.parquet")

# Iterate slices for a query
for slice in cat.iter_slices(bbox=aoi, time=(t0, t1)):
    gt = gc.load_raster(slice)
    result = preprocess(gt)
    # ...

# Matchup with in-situ
in_situ_cat = gc.open_catalog("s3://imeo/tccon_index.parquet")

matched = gc.queries.matchup(
    primary=in_situ_cat,             # the sparse / accurate stream
    secondary=cat,                    # the dense satellite stream
    time_tolerance=pd.Timedelta(hours=3),
    space_tolerance_km=25.0,
)
for pair in matched:
    obs = gc.load_in_situ(pair.primary_slice)
    sat = gc.load_raster(pair.secondary_slice)
    # ... use as (label, feature) pairs
```

### 7.4 — Patcher (geopatcher)

```python
import geopatcher as gp
from geopatcher.integrations.pipekit import GridSampler, ApplyToChips, Stitch

# Four-axis patcher: geometry × sampler × window × aggregation
patcher = gp.SpatialPatcher(
    geometry=gp.SpatialRectangular((256, 256)),
    sampler=gp.SpatialRegularStride((224, 224)),
    window=gp.SpatialHann(),
    aggregation=gp.SpatialOverlapAdd(),
)

# Composed into a Sequential
inference = pk.Sequential([
    GridSampler(patcher),
    ApplyToChips(pk.Sequential([
        preprocess,
        pa.ModelOp(model, batch_size=8),
    ])),
    Stitch(gp.SpatialOverlapAdd()),
])

# Field adapter for whatever carrier you have
field = gp.RasterField(scene_reader)        # for GeoTensor
field = gp.XarrayField(scene_ds)             # for xarray Dataset
field = gp.XvecField(stations_ds)            # for point cubes
field = gp.GeoPandasField(zones_gdf)         # for vector

result = inference(field)
```

### 7.5 — Data assimilation cycle

```python
import pipekit_cycle as pc
from filterx.adapters.pipekit import EnKFAnalysis
from plumax.adapters.pipekit import PlumeForward, ColumnObs

# All ingredients are Protocol-satisfying
forward = PlumeForward(species="CH4", dt=3600.0)         # ForwardModel
obs_op  = ColumnObs(instrument="TROPOMI")                # ObservationOperator
analysis = EnKFAnalysis(inflation=1.05)                   # AnalysisStep

# Compose into a DA cycle
da = pc.EnsembleDACycle(
    forward_model=forward,
    obs_op=obs_op,
    analysis_step=analysis,
    obs_source=obs_sequential,                            # pulls obs each step
    n_steps=24,
    n_members=40,
    save_history=True,
)

# State carry is explicit
initial_carry = pc.DAState(
    background_state=initial_state,
    ensemble_members=initial_ensemble,
    t=t0,
    cycle_count=0,
)

final_state, history = da(initial_state, initial_carry)
```

### 7.6 — Swap classical forward model for a neural emulator

The key win of the architecture. Same DA cycle, different forward model. **This pattern is Steps 3→4 of the six-step cycle (§3.5)**: train an emulator from Step 1 simulations, then run Step 2’s inference loop with the emulator swapped in. Step 2 stays alive as the oracle that validated the emulator.

```python
# Train an emulator offline
emulator_loop = pt.TrainingLoop(
    model_op=pa.ModelOp(ChemistryEmulatorNet()),
    dataset=pt.SimulationDataset(
        forward_model=PlumeForward(species="CH4", dt=3600.0),
        prior=AtmosphericPrior(distribution="climatology"),
        n_samples=10_000,
    ),
    loss=pt.MSE(),
    optimizer_config={"name": "adam", "lr": 1e-3},
    n_epochs=100,
    backend="lightning",
    callbacks=[pt.LogToExperiment(tracker=mlflow_tracker)],
)
emulator_op = emulator_loop.run()
registry.store(emulator_op, name="methane_emulator_v3")

# Later: use it in DA cycle
neural_forward = pc.NeuralForward(
    model_op=registry.load("methane_emulator_v3"),
    dt=3600.0,
)

# Same DA cycle, just swap the forward model
da_emulated = pc.EnsembleDACycle(
    forward_model=neural_forward,              # ← swapped
    obs_op=obs_op,                              # same
    analysis_step=analysis,                     # same
    obs_source=obs_sequential,                  # same
    n_steps=24,
    n_members=40,
)
# 100× faster forecasts; same composability
```

### 7.7 — Evaluation pipeline

```python
import pipekit_evaluate as pe

evaluation = pe.Pipeline([
    # Field × Point-wise, decomposed by region and lead time
    pe.ByLeadTime(
        pe.ByRegion(
            regions={"permian": permian_mask, "global": None},
            metric=pe.metrics.pointwise.RMSE(),
        ),
    ),
    # Field × Spectral
    pe.metrics.spectral.PSDCompare(
        spatial_dims=("lat", "lon"),
        expected_slope=-3.0,
    ),
    # Field × Probabilistic
    pe.metrics.probabilistic.CRPS(ensemble_dim="member"),
    # Event × Detection
    pe.ByEvent(
        detector=pe.events.MethanePlumeDetector(threshold_kg_h=100),
        metric=pe.metrics.detection.CSI(),
    ),
    # Budget × Physical-constraint
    pe.metrics.physical.MassClosure(tolerance=0.01),
])

# Multi-track: vs reanalysis, vs analysis, vs observations
multitrack = pe.MultiTrackEvaluation(
    evaluation_pipeline=evaluation,
    references={
        "cams": cams_cat,
        "tccon": tccon_cat,
        "aircraft": methaneair_cat,
    },
)
report = multitrack.run(predictions=forecast_history)

# Result is a content-addressed artifact
print(report.to_pandas())
report.save("s3://imeo/eval/methane_v3_2024Q3.report")

# Diff against the previous version
old = pe.EvaluationReport.load("s3://imeo/eval/methane_v2_2024Q3.report")
diff = report.diff(old)
```

### 7.8 — Benchmark contract

```python
from pipekit_evaluate.benchmark import BenchmarkContract

contract = BenchmarkContract(
    name="oceanbench_ssh_2025",
    version="1.0.0",
    task="gap_filling",
    input_carrier_spec={"shape": ("time", "lat", "lon"), "dtype": "float32"},
    output_carrier_spec={"shape": ("time", "lat", "lon"), "dtype": "float32"},
    variant="deterministic",
    reference_catalogs={
        "reanalysis": "s3://glorys/2023/index.parquet",
        "analysis": "s3://duacs/2023/index.parquet",
        "observations": "s3://altimetry/2023/index.parquet",
    },
    train_catalog_uri="s3://oceanbench/train.parquet",
    val_catalog_uri="s3://oceanbench/val.parquet",
    test_catalog_uri="s3://oceanbench/test.parquet",
    splitter_config={
        "_target_": "pipekit_train.splitters.SpatioTemporalBlockSplit",
        "spatial_block_km": 200,
        "temporal_block_days": 60,
    },
    block_size_spatial_km=200,
    block_size_temporal_days=60,
    metric_configs=[...],
    baselines=["pipekit_evaluate.baselines.OptimalInterpolationBaseline"],
    max_test_evaluations=1,
)

# Content-addressed, pre-registerable
hash = contract.content_hash()
contract.to_yaml().save("s3://oceanbench/contracts/v1.0.0.yaml")
```

### 7.9 — Reproducibility artifact (regulatory)

```python
import pipekit as pk

# Freeze a pipeline + its inputs + lockfile
artifact = pk.repro.freeze(
    pipeline=da_emulated,
    inputs={
        "scene_catalog_uri": "s3://imeo/emit/2024_Q3_frozen/",
        "scene_catalog_sha256": "ab12cd34...",
    },
    deps_lock="uv.lock",
    metadata={"author": "ej", "doi": "10.xxxx/mars-2024Q3"},
)
artifact.save("/regulatory/mars_methane_2024Q3.gtar")

# Years later
art = pk.repro.load("/regulatory/mars_methane_2024Q3.gtar")
assert art.pipeline_hash == "expected-hash-from-paper"
result = art.rerun()                # cold-rerun, no cloud accounts needed
```

-----

## 8. Open questions

Honest list. None are blockers; all deserve thought before committing to specific decisions.

### 8.1 — Sequencing

- **Does pipekit-jax really need to wait until v0.3+?** Report 5 says yes. But the six-step cycle (§3.5) surfaces a concrete driver: differentiable Step 3 emulators are exactly what makes Step 4 (gradient-based inverse problems) tractable at scale. If a project demands amortized inference (Step 5) with end-to-end differentiability, that becomes the trigger for pipekit-jax — earlier than the v0.3+ default. Open until there’s a concrete project driver.
- **In-situ catalog backends — which one first?** Report 6 leans Argo (via argopy) but ICOADS, SOCAT, World Ocean Database all matter for different domains. One per quarter realistically. Choice is driven by project needs.

### 8.2 — Design

- **The Slice Protocol refactor.** Currently `GeoSlice` is the only slice type. Adding `ProfileSlice` and `TrajectorySlice` (per `../supporting_info/geodata_lifecycle.md`) is the right structural move but the refactor is 2 weeks of work that ripples across geocatalog + geotoolz + xr-toolz + pipekit-train. Worth doing before too much code commits to the current GeoSlice.
- **Where matchup lives.** `geocatalog.queries.matchup()` is the framework function; carrier-specific helpers in `xr_toolz.matchup` / `geotoolz.matchup`. But does matchup need its own catalog type (a “matchup catalog”)? Probably yes; not yet scoped.
- **Backend choice in pipekit-train.** Lightning / Equinox+Optax / Keras 3 are all supported. Are they truly equal-status or does one become the “blessed” choice for most use cases? Honest answer: Lightning is most likely to be the default for PyTorch models; Equinox+Optax for JAX-traceable / differentiable pipelines; Keras 3 for multi-backend. Worth being explicit per use case.

### 8.3 — Operational

- **Monorepo vs polyrepo.** Decision is monorepo (`pipekit-ecosystem` with uv/hatch workspaces); but the JAX-native algorithm libraries (gaussX, filterX, vardaX, plumax) are *outside* the monorepo. Where’s the line? Lean: framework + infrastructure in monorepo; algorithm + domain libraries are separate repos that ship adapter modules.
- **Documentation: one site or per-package sites?** Lean: one Sphinx (or mkdocs) site for the monorepo packages; separate sites for the JAX-native algorithm libraries (they have their own audiences). Plus a single JupyterBook research journal cross-cutting everything.
- **CI: per-package or per-monorepo?** Lean: per-package CI inside the monorepo + a single integration matrix that pins all packages to HEAD weekly. Releases via git tags (`geocatalog-v0.2.0`).

### 8.4 — Open scientific questions

- **Matchup uncertainty quantification.** `MatchupPair.representativeness_uncertainty` is easy to declare and hard to compute. Real estimation is its own research problem; v0.1 ships with a placeholder.
- **Cascade-uncertainty in multi-stage benchmarks.** The 5-stage emission estimation chain accumulates uncertainty across stages. Predicting this honestly is open research.
- **Probabilistic event detection.** Detecting “a plume happened” is binary; saying “there’s a 73% chance a plume happened” is much harder. Current event-detection metrics assume binary; probabilistic variants matter operationally but aren’t standard.

### 8.5 — Sustainability

- **Solo-maintainer feasibility.** ~20 packages, even with monorepo discipline, is a lot. The “scope discipline” principle in vision_v2 §7 is the operating constraint: each phase produces standalone value; the full stack doesn’t need to exist for individual layers to deliver.
- **Community adoption.** If `oceanbench` adopts pipekit-evaluate’s benchmark contracts, the framework is validated. If not, it stays personal infrastructure. Open question: at what point do you start actively reaching out to existing benchmark efforts?

-----

## 9. A plan

Concrete sequencing. Each phase produces usable, valuable packages on its own.

### Phase 1 — Numerical Foundation (done in part)

```
   gaussX (v0.0.6, done)
   spectralDiffX (draft)
   finiteVolX (draft)
   optax-bayes (draft)
   eqx-trainer (draft)
```

Time: ongoing.

### Phase 2 — Algorithms (in progress)

```
   pyrox-gp
   pyrox-nn  
   filterX
   vardaX
   gaussFlowX
```

Time: ongoing, each at its own pace.

### Phase 3 — Domain Models (some done, some in progress)

```
   somax (PDE solver zoo)
   plumax (atmospheric plume transport)
   xtremax (extreme value)
   methanex (end-to-end methane)
   RTMX (radiative transfer)
```

Time: project-driven; each tied to a specific science question.

### Phase 4 — Pipeline Framework (load-bearing, current focus) — ~3-4 months

```
   Month 1:
     • pipekit v0.1 (framework core, 12 groups + state primitives)
     • pipekit-array v0.1 (Array API operators)
     • Setup pipekit-ecosystem monorepo with uv/hatch workspaces
   
   Month 2:
     • geocatalog v0.1 (InMemory + DuckDB backends; basic queries)
     • geopatcher v0.1 (four-axis framework; 5 Field adapters)
     • Refactor geotoolz and xr_toolz to depend on the new framework
   
   Month 3:
     • statecatalog v0.1
     • pipekit-cycle v0.1 (Cycle, DACycle, three Protocols)
     • Adapter modules in filterX, vardaX, plumax
   
   Month 4:
     • pipekit-train v0.1 (Lightning + Equinox backends)
     • pipekit-experiment v0.1 (MLflow + S3 registry adapters)
     • Initial integration testing across all packages
```

After Phase 4: the L0–L4 inference loop is structurally complete. ML training and serving still need work but the pipelines exist.

### Phase 5 — Evaluation + Benchmarks + Cycle Discipline — ~2 months

```
   Month 5:
     • pipekit-evaluate v0.1 (framework + cheap metrics + EvaluationReport)
     • Leakage-aware splitters in pipekit-train
     • Standard baselines (Persistence, Climatology, OI)
     • ModelRole enum + ArtifactLineage in pipekit-experiment
       (the six-step cycle's content-addressed lineage tracking)
   
   Month 6:
     • xr_toolz.lagrangian (particle tracking)
     • xr_toolz.events (event detection)
     • BenchmarkContract + CycleStageBenchmark artifacts
     • MultiTrackEvaluation built-in pattern
     • First worked cycle (probably methane L1→L2 retrieval, end-to-end Steps 1-5)
     • First worked benchmark instantiation (SSH from benchmarks_gallery)
```

After Phase 5: evaluation is first-class, benchmarks are content-addressable contracts, the full L0–L4 cycle has multidimensional eval discipline, **and the six-step research-to-production cycle is operationally tractable end-to-end**.

### Phase 6 — Deferred (when projects demand)

```
   pipekit-jax (Equinox-backed, JAX-traceable operators)
     Trigger: first project needing differentiable retrievals at scale or
              JIT-compiled inference paths
   
   Deployment adapters (pipekit.deploy.fused, .litserve, .modal)
     Trigger: first deployment use case beyond hand-shimming
   
   Slice Protocol refactor (GeoSlice → Protocol + ProfileSlice + TrajectorySlice)
     Trigger: first project needing first-class in-situ catalog support
              (probably BGC benchmark from gallery)
   
   Additional in-situ catalog backends (Argo, ICOADS, SOCAT, ...)
     Trigger: one per quarter, project-driven
```

### Phase 7 — Polish + community

```
   Comprehensive documentation site (Sphinx-based)
   Research journal as JupyterBook (cross-cutting narrative)
   First external benchmark adoption (OceanBench? WeatherBench-Ocean?)
   Capstone tutorials per domain
```

### Reality check on the plan

Three honest pushbacks on my own sequencing:

1. **6 months for Phase 4-5 is optimistic for solo work.** Realistically 8-12 months. Mitigation: each month produces usable artifacts; nothing requires the full plan to finish to be valuable.
2. **Phase 6 might come earlier than planned.** If a project demands pipekit-jax or in-situ catalogs first, jump phases. The sequence is a default, not a contract.
3. **Phase 7 is open-ended.** Community adoption is years not months. Plan for the substrate to be useful even without external adoption; treat adoption as upside.

-----

## 10. Where to read next

Depending on what you’re trying to understand:

|If you want to understand…      |Read                                                                        |
|--------------------------------|----------------------------------------------------------------------------|
|**The big picture vision**      |`../supporting_info/geostack_vision.md`                                                              |
|**Why pipekit exists**          |Report 1 (toolz lineage, background)                                        |
|**What pipekit actually ships** |Report 2 (12 semantic groups, ~2150 LOC)                                    |
|**The sister-library structure**|Report 3 (pipekit-array, geotoolz, xr-toolz refactor)                       |
|**Concrete use cases**          |Report 9 (13 cases mapped to the full stack)                                |
|**The JAX-native future**       |Report 5 (pipekit-jax, Equinox backend)                                     |
|**Spatiotemporal catalogs**     |Report 6 (geocatalog)                                                       |
|**The patcher framework**       |Report 7 (geopatcher, four-axis, 60+ classes)                               |
|**xr-toolz’s role**             |Report 8 (substrate asymmetry vs geotoolz)                                  |
|**Time-stepping + DA**          |Report 10 (pipekit-cycle)                                                   |
|**Training pipelines**          |Report 11 (pipekit-train)                                                   |
|**Model registry + tracking**   |Report 12 (pipekit-experiment)                                              |
|**L3-L4 indexing**              |Report 13 (statecatalog)                                                    |
|**Multidimensional evaluation** |Report 14 (pipekit-evaluate, three-axis matrix)                             |
|**Benchmark infrastructure**    |Report 15 (benchmark contracts, leakage, baselines)                         |
|**The six-step modeling cycle** |Report 16 (cycle + Step 2 as oracle + benchmarks as understanding)          |
|**The data lifecycle in detail**|`../supporting_info/geodata_lifecycle.md` (three-layer model, two streams, depth axis, matchup)|
|**Concrete benchmarks**         |`../supporting_info/benchmark_gallery.md` (23 benchmarks across 6 domains)                    |

-----

## 11. Closing summary

The GeoStack is **a vertically integrated, JAX-native research software stack with operator-graph composition extending from structured linear algebra through pipeline infrastructure to indexed multi-tier data products** — structured by three orthogonal axes (the modeling cycle, the L0–L4 data lifecycle, and the six-step research-to-production cycle).

What makes it specific:

- **Three organising axes** — the research loop (modeling cycle), the data lifecycle (L0–L4 with two-stream convergence), and the production journey (six-step cycle from Simple Model to Amortized Predictor)
- **Operator algebra at every level**, with appropriate Protocols per layer (no universal base class)
- **Carrier-agnostic framework** (pipekit) bridging JAX-native numerics and xarray/GeoTensor data
- **Content-addressed everything** — data slices, model artifacts, evaluation reports, benchmark contracts, reproducibility artifacts, cycle-step lineage
- **ML pluggable at every L0–L4 transition** via the same training + registry + inference machinery
- **Step 2 as oracle** — classical methods (filterX, vardaX, pyrox-gp) stay alive forever as ground-truth generators, not as legacy code to be replaced
- **Benchmarks as formalised understanding** — contracts are operationalised hypotheses, not just leaderboards
- **Two-stream data lifecycle** (satellite + in-situ converging via matchup) with depth-axis support
- **Multidimensional evaluation** as first-class infrastructure, not an afterthought
- **Pre-registerable benchmarks** as content-addressable contracts
- **JAX-only differentiability** (gradients live in the JAX-level packages; xarray/pipekit/geotoolz are gradient-free orchestration)
- **Math-first documentation, code IS the paper** — every operator documented in unicode with theory

The vision document is the manifesto. The 16 reports are the scoping deep-dives. This document is the entry point. The plan above is a default sequence; project demands will modify it. The bones are right; what remains is execution at scope-disciplined pace.

If a specific use case is pulling you toward this stack: pick the relevant deep-dive from §10, read it, and come back with questions. The structure is intentionally modular — you don’t need to internalise everything to use any part.