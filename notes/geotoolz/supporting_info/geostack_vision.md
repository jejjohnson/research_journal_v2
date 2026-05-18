---
title: "The Idea (v3) — GeoStack vision"
subject: geotoolz supporting info
short_title: "Vision (v3)"
authors:
  - name: J. Emmanuel Johnson
    affiliations:
      - UNEP
      - IMEO
      - MARS
    orcid: 0000-0002-6739-0053
    email: jemanjohnson34@gmail.com
license: CC-BY-4.0
keywords: geotoolz, geostack, vision, manifesto, principles
abstract: JAX-native numerics with carrier-agnostic pipeline infrastructure — for geophysical modeling, inference, and data assimilation — organised around three orthogonal axes (research, data, production) with benchmarks at every step.
---

## The problem

Five gaps shape why this stack exists.

1. **Scattered numerics.** The same linear algebra, kernel methods, filtering routines get rewritten in every project. No shared, tested, composable primitives.
2. **ML tooling doesn’t serve classical numerical problems.** Keras and PyTorch assume supervised learning on tensors. They don’t naturally express linear operators, PDE solvers, state estimation, or uncertainty propagation.
3. **Monolithic domain software.** Specialized codes (ocean models, retrieval algorithms, DA systems) are dense, tightly coupled, and hard to recombine.
4. **No connective tissue.** Even with good numerics and good ML, there is no Keras-like pipeline framework to compose them for real geophysical work — taking raw observations through interpolation, assimilation, forecasting, and post-processing.
5. **No indexed model-state tier.** Observation data is catalogable (STAC, GeoParquet). Model outputs (forecasts, analyses, reanalysis, emulator predictions) are not — they’re scattered files with bespoke naming conventions. The L3–L4 half of the data lifecycle has no equivalent of the catalogs that organise L0–L2.

The first three are problems the broader scientific Python community shares. The last two are the connective-tissue gaps this stack is built to fill.

-----

## What this stack is

A two-halves architecture:

**JAX-native numerics.** Composable primitives, algorithms, and domain models — all `eqx.Module`-shaped, all jittable, all differentiable within JAX. From structured linear algebra (gaussX) through inference algorithms (filterX, vardaX, pyrox-gp, gaussFlowX) to domain models (somax, plumax, RTMX, methanex). This is where the gradients live.

**Carrier-agnostic pipeline infrastructure.** A composition framework (pipekit) plus peer infrastructure (geocatalog, geopatcher, statecatalog) plus ML loops (pipekit-cycle, pipekit-train, pipekit-evaluate, pipekit-experiment) plus domain pipeline libraries (geotoolz for raster, xr-toolz for xarray). None of these depend on JAX. They compose operators over any carrier — numpy, JAX, xarray, GeoTensor, point clouds — and they’re how the JAX-native numerics get plumbed into real workflows.

The two halves meet via adapter modules: each algorithm library (filterX, vardaX, etc.) ships a thin `adapters/pipekit.py` that exposes its algorithm core through pipekit’s Protocols, without coupling the core to pipekit.

**This is the structural claim:** the JAX numerics are at the bottom doing the math, the pipeline infrastructure is in the middle doing the composition, and the domain pipeline libraries are at the top doing the domain-specific work. Both halves are first-class. Neither is subordinate to the other.

-----

## Three organising axes

Every operation in the stack sits somewhere on three orthogonal axes. They form a structural cube.

### Axis 1 — The modeling cycle (research)

The research loop. Start simple, simulate, validate, refine.

(fig-modeling-cycle)=

:::{include} ../diagrams/10_modeling_cycle.html
:::

_Figure — The modeling cycle ([](#fig-modeling-cycle)). The conceptual model fans out into two complementary representations (equations for analysis, code for simulation), which both produce predictions; predictions are validated against observations and the comparison drives model refinement._

Start simple. Add complexity only when validation demands it. All models are wrong; the goal is the model most suited to its purpose.

### Axis 2 — The L0–L4 data tier (data lifecycle)

The data maturity progression. Raw signals at L0; analysed/fused fields at L4. Two streams (satellite top-down, in-situ bottom-up) converging at L2/L3 via matchup.

```
   L0 — Raw telemetry
        │   ▲
        ▼   │  satellite stream      in-situ stream
   L1 — Calibrated radiances          (Argo, CTD, moorings,
        │                              gliders, drifters —
        ▼   retrieval                  enters at L2-equivalent
   L2 — Geophysical variables ◄────── with depth axis z)
        │
        ▼   gridding + composite
   L3 — Analysis                      ◄── matchup convergence
        │
        ▼   DA + fusion
   L4 — Reanalysis / Forecast
```

L0–L2 lives in observation catalogs (`geocatalog`). L3–L4 lives in state catalogs (`statecatalog`). The depth axis is structural for in-situ data and demands first-class slice types (ProfileSlice, TrajectorySlice).

### Axis 3 — The six-step cycle (research-to-production)

The journey from “we have a forward model” to “we have a deployed amortized predictor.”

```
   (1) Simple Model                        a generative story
        ▼
   (2) Model-Based Inference  ◄── ORACLE   slow, exact, classical DA
        ▼
   (3) Model Emulator                      neural surrogate
        ▼
   (4) Emulator-Based Inference            Step 2 made fast
        ▼
   (5) Amortized Inference                 direct posterior predictor
        ▼
   (6) Improve  ──────────────────────────┐
        ↑    previous step is ground truth│
        └─────────────────────────────────┘
```

Step 2 (classical DA) is not legacy code to be replaced. It is *promoted to oracle*: ground-truth generator against which Steps 3, 4, 5 are validated. Classical methods stay alive forever.

### How the axes relate

Every cell of (L0–L4 transition × six-step cycle) is a concrete benchmarkable artifact. The whole L0–L4 chain is a nested set of six-step cycles. The modeling cycle (Axis 1) is what happens *within* each cell — abstract, simulate, validate, refine. Three axes, one architecture.

-----

## Design principles

The structural commitments. These are non-negotiable.

### 1. Carrier-agnostic at the pipeline tier

Pipekit doesn’t know what’s flowing through. The same operator graph composes GeoTensors, xarray Datasets, numpy arrays, or point clouds. Carrier choice is a domain decision (geotoolz uses GeoTensor; xr-toolz uses xarray; future libraries can use other carriers). The framework doesn’t pick a winner.

### 2. JAX-native at the algorithm tier

The numerical foundation, inference algorithms, and domain forward models are JAX-native. `eqx.Module`-shaped. Jittable. Differentiable. Composable via the JAX transforms. This is non-negotiable for the algorithms because gradients are how they earn their keep.

### 3. Differentiability within JAX, not across pipelines

End-to-end gradients live in the JAX-level composition (you can differentiate through a somax PDE + filterX assimilation step). The pipekit / xr-toolz / geotoolz layer is **gradient-free orchestration**. Pretending otherwise leads to leaky abstractions. If you need gradients, drop into JAX.

`pipekit-jax` (deferred) adds a JAX-traceable subset for cases where you want jit/vmap/grad through pipeline composition, but the default framework is Python control flow.

### 4. No universal Operator base class

Each layer defines its own operator protocol appropriate to its domain:

```
gaussX:        lineax.AbstractLinearOperator  — mv(v) → v
filterX:       FilterStep                     — __call__(state, obs) → state
pyrox-gp:      GPModel                        — __call__(x_new, data) → distribution
somax:         DynamicalModel                 — __call__(t, state) → tendency
pipekit-cycle: ForwardModel, ObsOp, Analysis  — Protocols
pipekit:       Operator                       — Carrier → Carrier (with state variants)
geotoolz:      Operator                       — GeoTensor → GeoTensor
xr-toolz:      Operator                       — Dataset → Dataset
```

Pipekit’s `Operator` is the composition framework’s operator. Algorithm libraries are not forced into it; they expose adapters.

### 5. Backend choice is local

Keras 3 and Equinox+Optax and Lightning are equal-status backends for ML algorithms. fairkl uses Keras 3. pyrox-nn uses Equinox+NumPyro. Some users prefer PyTorch. All of them produce trained operators that load through the same `ModelOp` slot in pipekit-array. The framework doesn’t pick a winner. Backend choice is per-algorithm, per-team, per-task.

### 6. Step 2 as oracle

Classical methods (filterX, vardaX, pyrox-gp) are not legacy code to be replaced by neural emulators. They are *ground-truth generators*. Every neural emulator (Step 3), every emulator-based inference (Step 4), every amortized predictor (Step 5) is validated against the classical Step 2 oracle. The classical path stays alive forever, promoted to permanent operational status.

This is the structural commitment that makes the six-step cycle work. Without an oracle, downstream steps have no ground truth and the cycle reduces to “we built something neural and it seems to work.”

### 7. Benchmarks as formalised understanding

A benchmark is not a leaderboard. It is an **operationalised hypothesis** about a problem.

Writing a benchmark contract — declaring the carriers, the references, the metrics, the splits, the baselines, the expected failure modes — is the act of formalising what you understand about the problem. If you can write all six, you understand the problem. If you can’t write any one of them, you don’t yet — and the gap shows you exactly what to learn.

The audience for a benchmark contract isn’t only other ML teams. It’s your future self, domain scientists, reviewers, auditors, anyone trying to understand the problem you understood. Benchmark contracts are documentation in the strongest sense.

This reframes evaluation from postscript to first-class research output.

### 8. Content-addressing throughout

Every artifact in the stack is content-addressed: data slices, model artifacts, evaluation reports, benchmark contracts, training pipelines, reproducibility freezes, cycle-step lineage. Names are tags over hashes; hashes don’t drift; lineage is mechanical not narrative.

This is what makes the train→eval→benchmark→deploy loops close honestly. You can’t conflate v3 with v4 if their hashes differ. You can’t claim a method beat a benchmark if the contract hash isn’t verified.

### 9. ML at every L0–L4 transition

ML is not “a different way to do science.” It is an implementation choice at every operator slot. At L0–L1 (calibration), L1–L2 (retrieval), L2–L3 (gap-filling), L3–L3 (analysis), L3–L4 (forecasting) — every transition has both a classical implementation and an ML implementation, and both load through the same Operator interface. The framework doesn’t privilege one over the other.

### 10. Math-first documentation, code IS the paper

Every function documents its mathematical operation in unicode. Each package has its own docs site with API reference and worked examples. One cross-cutting research journal (JupyterBook) spans all packages: theory, end-to-end workflows, capstone applications.

A reviewer in 2030 can read the journal, find the operator, run it, and get the same answer. That’s the reproducibility commitment. Most scientific software treats documentation as afterthought; this stack treats the journal as the primary deliverable and the code as the implementation of papers.

### 11. Scope discipline

The full stack is intentionally large. Each phase produces usable, standalone packages. The numerical foundation works without algorithms; algorithms work without pipelines; pipelines work without catalogs.

This is the operating constraint that makes a solo-maintained ecosystem tractable. New infrastructure is added when concrete projects demand it, not speculatively.

-----

## What this enables

What becomes possible once the principles are kept. Concrete outcomes, not abstract aspirations.

### An L0–L4 chain that’s operationally improvable

Every L0–L4 transition is its own six-step cycle. Improve the physical model → re-run the emulator → re-run amortized inference. Each artifact knows its lineage. Each cycle-step transition is benchmarked against the previous step as oracle. Nothing is opaque; everything is traceable.

### Swap-the-forward-model as a one-line change

Same DA cycle, classical or neural forward model:

```python
da = pc.DACycle(
    forward_model=PlumeForward(...),         # classical Step 2
    obs_op=ColumnObs(...),
    analysis_step=EnKFAnalysis(...),
)
# Train an emulator offline, register it
da_fast = pc.DACycle(
    forward_model=pc.NeuralForward(           # Step 4, 100× faster
        model_op=registry.load("methane_emulator_v3"),
    ),
    obs_op=ColumnObs(...),                    # unchanged
    analysis_step=EnKFAnalysis(...),          # unchanged
)
```

The same pattern at every L0–L4 transition.

### Benchmarks as content-addressable contracts

Pre-register an evaluation contract. Publish its hash. Any submission carries the hash. Verification is mechanical. No trust required. Pipekit-evaluate provides the substrate; existing benchmark efforts (OceanBench, WeatherBench) can adopt the contract format.

### Multi-dimensional evaluation as routine

Every model gets evaluated along three orthogonal axes (Unit × Lens × Stage): not just RMSE on a holdout set, but spectral preservation, event detection, physical-constraint closure, Lagrangian dispersion, probabilistic calibration. The matrix structure makes the gaps visible. “Field × point-wise” is the corner most ML papers occupy; honest evaluation populates the rest.

### Reproducibility artifacts that actually replay

A trained model + the pipeline that produced it + the dataset content hash + the deps lockfile = a content-addressed artifact that any researcher can replay years later. Regulatory submissions, paper supplements, audit trails — all the same artifact type.

### A train → serve loop that closes

Trained models drop into inference pipelines via the registry. Promotion from candidate to production is one atomic tag-move. Deployment hosts (FastAPI, LitServe, Fused) consume the same Operator graph that ran in the notebook.

### Indexed model state at L4

Forecasts, analyses, reanalysis become queryable artifacts in `statecatalog` — with valid_time, run_time, ensemble member, model config hash, lineage. Forecast verification becomes a query: “give me the forecast that valid at this time from this model, give me the verifying analysis, compute RMSE.”

-----

## What’s locked in vs. what’s open

Honest at the close. The architecture is designed. What’s settled and what isn’t.

### Locked in (won’t change without serious cause)

- **Two-halves architecture**: JAX-native numerics + carrier-agnostic pipeline infrastructure as equal-status complementary halves
- **Three organising axes**: modeling cycle, L0–L4, six-step cycle
- **Pipekit as composition framework** with `Operator` + `Sequential` + `Graph` + observers + control flow + state primitives + serialisation
- **Per-layer operator protocols**, no universal base class
- **Carriers**: GeoTensor (raster) + xarray (gridded) + point/profile/trajectory slices; each has its own sibling domain library
- **Catalogs**: `geocatalog` for L0–L2 observations, `statecatalog` for L3–L4 model states, sibling Protocols not subclass relationships
- **Step 2 as oracle** as a structural commitment
- **Benchmarks as content-addressable contracts**
- **JAX-only differentiability**; pipekit is gradient-free orchestration
- **Backend choice is local**: Keras 3, Equinox+Optax, Lightning all equal-status
- **Math-first documentation, journal as primary deliverable**
- **Monorepo development** for pipekit ecosystem with per-package PyPI releases

### Open (genuinely undecided)

- **`pipekit-jax` timing.** Currently deferred to v0.3+. The six-step cycle surfaces a concrete driver: differentiable Step 3 emulators are exactly what enables tractable Step 4 inverse problems. If a project demands this at scale, the timing accelerates.
- **Slice Protocol refactor.** Currently `GeoSlice` is the only slice type. Splitting into a Slice Protocol with `GeoSlice` + `ProfileSlice` + `TrajectorySlice` siblings is the right structural move but it’s 2 weeks of cross-package work. Decision deferred until first in-situ-heavy project.
- **Matchup catalog as separate type.** `geocatalog.queries.matchup()` is scoped; whether matchup outputs deserve their own catalog type (a `MatchupCatalog`) is open.
- **In-situ catalog backend priority.** Argo first via `argopy`? ICOADS? SOCAT? World Ocean Database? One per quarter realistically; choice is project-driven.
- **Blind test set substrate.** `AccessGatedGeoCatalog` is scoped but real operational deployment (running a scoring service) is organisational not framework work. Open whether to build the framework piece without operational adoption.
- **Where exactly `EventCatalog` lives.** Currently scoped as a submodule of `xr_toolz.events`; could promote to sibling package if it grows.
- **Community adoption strategy.** Does the framework reach out actively to OceanBench / WeatherBench efforts, or just ship and let adoption happen organically? Probably the latter early, the former once Phase 4–5 ships and the substrate proves itself.

### What’s not in scope

- **Replacement for orchestration tools.** Pipekit-experiment ships adapters for MLflow, W&B, DVC, Hydra, Metaflow. The orchestrators themselves are not owned.
- **Replacement for deployment hosts.** FastAPI, LitServe, Fused, Modal stay external; pipekit deploy adapters bridge to them.
- **Replacement for benchmark efforts.** The framework provides contract infrastructure; running benchmarks (curation, scoring service, dispute adjudication) is organisational work.
- **Replacement for CUDA / XLA.** JAX/XLA handles Level 0 compilation; the stack lives at Levels 1–2.
- **General-purpose ML evaluation.** Pipekit-evaluate is geophysics-shaped — gridded fields, particle trajectories, conservation budgets. NLP, image classification have their own ecosystems.

-----

## Where to next

Concrete next steps in the architectural surface:

- **`../master_plan/toolz_0_overview.md`** — full architectural detail: all 16 reports synthesised, ASCII diagrams at four scales, code patterns, plan
- **The 16 numbered reports** — scoping deep-dives per package or framework piece
- **Companion documents** — `geodata_lifecycle.md` (three-layer model + two-stream convergence + depth axis + matchup), `benchmark_gallery.md` (23 worked benchmark designs across 6 domains)

If you’re trying to understand a specific piece, use Report 0’s navigation table. If you’re trying to understand the operational discipline, read Report 16 (the six-step cycle). If you’re trying to understand the data lifecycle, read `geodata_lifecycle.md`. If you want concrete benchmark designs, read `benchmark_gallery.md`.

This document is the manifesto. The architecture lives elsewhere. The execution is the remaining work.

-----

## What v3 commits to

The structural shifts from v2, summarised:

1. **The “JAX-native” framing is precise**: JAX-native numerics + carrier-agnostic pipeline infrastructure as two halves, not a single thing. The pipeline infrastructure does not depend on JAX.
2. **Three organising axes**: modeling cycle, L0–L4 data lifecycle, six-step research-to-production cycle. Every operation sits on all three.
3. **Step 2 as oracle**: classical methods are permanently promoted to ground-truth generators, not legacy code.
4. **Benchmarks as formalised understanding**: evaluation contracts are operationalised hypotheses, not leaderboards.
5. **ML at every L0–L4 transition** is a structural feature, not an optional sub-claim.
6. **Eleven design principles** as explicit non-negotiables.
7. **Architectural detail moved to Report 0**: v3 is manifesto + principles + outcomes; v2’s dual role as both manifesto and architectural summary is dropped.
8. **Build order dropped**: live in Report 0’s plan section, where it belongs.
9. **Locked-in vs open vs not-in-scope** as the closing section: honest about what’s settled and what isn’t.

The numerical foundation, the algorithms, the domain models, the modeling cycle, the math-first principle, the carrier-typed pipeline siblings — all unchanged. What v3 adds is the explicit articulation of *what the stack is structurally committed to*, separate from *how the architecture is laid out*. Two documents now do the work that v2 tried to do alone.