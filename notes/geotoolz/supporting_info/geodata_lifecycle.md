---
title: "Companion — Data and ML lifecycle"
subject: geotoolz supporting info
short_title: "Data + ML lifecycle"
authors:
  - name: J. Emmanuel Johnson
    affiliations:
      - UNEP
      - IMEO
      - MARS
    orcid: 0000-0002-6739-0053
    email: jemanjohnson34@gmail.com
license: CC-BY-4.0
keywords: geotoolz, data-lifecycle, ML-lifecycle, L0-L4, matchup, depth-axis
---

# Companion: Data and ML Lifecycle

|                         |                                                                                                                                                                                                    |
|-------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|**Status**               |Companion document to `geostack_vision.md`                                                                                                                                                                |
|**Reading time**         |~25 min                                                                                                                                                                                             |
|**Audience**             |Anyone trying to integrate external scientific framings of the data + ML lifecycle with the GeoStack architecture                                                                                   |
|**Source material**      |External scientific writing on ocean data products: the Scientific-Data / ML-Ready / Embedding three-layer model, the L0–L4 processing hierarchy, satellite (top-down) + in-situ (bottom-up) streams|
|**What this does**       |Maps the external framings onto our stack, identifies the depth axis and matchup pattern as missing pieces, and proposes specific revisions to v2 vision + geocatalog + pipekit-train scope         |
|**What this does NOT do**|Replace v2; introduce new packages without justification; oceanography-specific operators (those go in xr-toolz.ocn)                                                                                |

-----

## Why this document exists

The source material presents a self-consistent three-layer model of the data + ML lifecycle:

1. **Scientific-Data Layer** — the L0→L4 physical-product hierarchy, fed by satellite (top-down) and in-situ (bottom-up) streams
2. **ML-Ready Layer** — versioned tensors, CF-compliant metadata, quality masks, train/val/test splits, reproducible preprocessing
3. **Embedding Layer** — physically-informed latent spaces; ROMs, autoencoders, DA-ready state embeddings

Connected by two pipelines: **ML processing** (harmonisation, tensorisation) between layers 1 and 2, and **representation learning** (compression, latent mapping) between layers 2 and 3.

This is a clean conceptual model and it deserves first-class treatment in our framework. The v2 vision doc has the L0–L4 axis but doesn’t make the three-layer / two-pipeline structure explicit. This companion fills that gap and proposes concrete edits to v2.

Three honest observations up front:

1. **The three-layer model is generalisable beyond ocean.** Satellite + in-situ + matchup, depth axis, ROMs — these examples are oceanographic but the structure applies to atmospheric chemistry (TROPOMI + sondes), cryosphere (altimetry + IceBridge), terrestrial (Sentinel-2 + flux towers). Treat the framework points as generalisable; treat the oceanographic specifics as domain examples.
2. **The framework points expose real gaps in our stack** — the depth `z` axis isn’t in `GeoSlice`; spatiotemporal matchup has no clean home; the Embedding Layer maps onto pipekit-cycle + pipekit-experiment in a way that’s structurally implicit but not yet operationally documented.
3. **The three-layer model is complementary to v2’s framing, not competing with it.** The L0–L4 axis describes *data maturity*; the three-layer model describes *data transformations*; the modeling cycle describes *the research loop*. Together they give a complete picture.

-----

## The three-layer model

Rendered as ASCII, faithful to the source diagram:

```
   ┌─────────────────────────────────────────────────────────────────┐
   │                   SCIENTIFIC-DATA LAYER                         │
   │                                                                 │
   │   L0 → L1 → L2 → L3 → L4   physical-product hierarchy           │
   │                                                                 │
   │   Two complementary streams:                                    │
   │     • Satellite  (top-down)    L0 → L1 → L2 → L3 → L4           │
   │     • In-situ    (bottom-up)   Enter at L2-equivalent           │
   │                                  with depth (z) axis            │
   │                                                                 │
   │   Core role: preserve measurement provenance, physical meaning, │
   │   and uncertainty structure across levels and observation types │
   └──────────────────────────┬──────────────────────────────────────┘
                              │
                              │  ML Processing Pipeline
                              │  (harmonisation, tensorisation)
                              ▼
   ┌─────────────────────────────────────────────────────────────────┐
   │                       ML-READY LAYER                            │
   │                                                                 │
   │   Standardised tensors consumable by training loops             │
   │   • CF-compliant metadata                                       │
   │   • Quality masks                                               │
   │   • Train/val/test splits                                       │
   │   • Versioned, reproducible preprocessing recipes               │
   │                                                                 │
   │   Core outputs: versioned tensors + provenance                  │
   └──────────────────────────┬──────────────────────────────────────┘
                              │
                              │  Representation Learning Pipeline
                              │  (compression, latent mapping)
                              ▼
   ┌─────────────────────────────────────────────────────────────────┐
   │                       EMBEDDING LAYER                           │
   │                                                                 │
   │   Physically-informed latent spaces                             │
   │   • Reduced-order models (ROMs)                                 │
   │   • Autoencoders (AEs)                                          │
   │   • DA-ready state embeddings                                   │
   │   • Latent evolution operators                                  │
   │   • Reconstruction mappings back to physical variables          │
   │                                                                 │
   │   Core outputs: compact state vectors with decoders             │
   └─────────────────────────────────────────────────────────────────┘
```

Each layer is a **transformation target**: data enters from below, gets transformed, exits into the layer above. The pipelines between layers are themselves operator-graph constructs in our stack.

-----

## How the three layers map onto our stack

This is the load-bearing section. Each external layer maps to specific packages in the GeoStack.

### Scientific-Data Layer → georeader + geocatalog + geotoolz/xr-toolz + statecatalog

The L0–L4 hierarchy is owned by the bottom half of our pipeline-infrastructure tier. Each level is catalogable, content-addressed, and reproducible.

|L-level                        |Owned by                                                                                                                                                                                                 |
|-------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|**L0** (raw telemetry)         |`georeader` raw readers; not typically catalogued (engineering-only)                                                                                                                                     |
|**L1** (calibrated, geolocated)|`georeader` + sensor-specific readers in `geotoolz.readers.<sensor>`; `geocatalog` indexes the L1 outputs                                                                                                |
|**L2** (retrievals)            |`geotoolz` retrieval operators (matched filter, BAEMR, cloud-aware) for raster; `xr-toolz` retrieval helpers for gridded; both can be classical or ML (via `pipekit-array.ModelOp`); `geocatalog` indexes|
|**L3** (gridded composites)    |`xr-toolz.interpolate` + `xr-toolz.calc` + `pyrox-gp` for gap-fill / kriging; `pipekit-cycle.DACycle` for objective analysis; `statecatalog` indexes                                                     |
|**L4** (analysed / fused)      |`somax` / `PlumeX` / `RTMX` forward models composed via `pipekit-cycle.Cycle`; classical DA via `filterX` / `vardaX`; neural emulators via `pipekit-cycle.NeuralForward`; `statecatalog` indexes         |

### ML Processing Pipeline → pipekit-train.{CatalogDataset, SimulationDataset, CachedDataset}

The transformation from Scientific-Data to ML-Ready is a `pipekit-train.TrainingDataset`. Three concrete sub-paths:

- **Direct supervised** — `CatalogDataset` pulls from a `geocatalog` of labelled scenes, applies preprocessing, yields `(x, y)` pairs
- **Emulator training** — `SimulationDataset` wraps a `ForwardModel`, samples a prior, evaluates, yields `(params, simulated_output)` pairs
- **Amortized inference** — `SimulationDataset` again, but the network learns the inverse mapping

All three deploy the **offline / online preprocessing split** the source recommends (see §“ML-Ready transformation” below).

### ML-Ready Layer → CachedDataset artifacts + CF-compliant metadata + content-addressed versioning

The ML-Ready Layer’s outputs (versioned tensors, CF metadata, splits, recipes) map directly onto:

- **Versioned tensors** — `pipekit-train.CachedDataset` writes content-hashed cache; cache key is `hash(dataset_config, preprocessing_config, seed)`
- **CF-compliant metadata** — `xr-toolz.geo.validation` produces it; `xr-toolz.atm` / `.ocn` / `.ice` operators preserve it
- **Quality masks** — `xr-toolz.geo.masks` and `geotoolz.cloud.*` produce, propagate, attach
- **Train/val/test splits** — `TrainingDataset.with_split(...)` + stable seed
- **Reproducible preprocessing recipes** — the YAML for the preprocessing pipeline + the dataset’s `content_hash()`

The ML-Ready Layer in our stack is therefore not a *package* — it’s the **artifact produced when a pipekit-train TrainingDataset is materialised**. The contract is enforced at the framework level via `CachedDataset` discipline.

### Representation Learning Pipeline → pipekit-train.TrainingLoop with encoder-decoder architectures

The path from ML-Ready to Embedding is a training run. Concretely:

- **Encoder training** — `TrainingLoop` with a `pa.ModelOp(Encoder)` and a reconstruction loss (autoencoder), or a contrastive loss (foundation model), or a variational loss (VAE)
- **Latent dynamics** — separately trained or jointly: a `pipekit-cycle.NeuralForward` operating in latent space
- **Decoder** — separate `pa.ModelOp(Decoder)` mapping latent state back to physical variables

All three trained operators end up in `pipekit-experiment.ModelRegistry`, content-addressed by hash, retrievable as composable `Operator`s.

### Embedding Layer → trained encoder-decoder operators + pipekit-cycle latent dynamics + ModelRegistry

This is where the Core Representations table from v2 closes the loop. The Encoders-Decoders row was abstract in v2; here it’s concrete:

```python
encoder = registry.load("ocean_state_encoder_v3")     # physical → latent
latent_dyn = registry.load("ocean_latent_dynamics_v3") # latent → latent over time
decoder = registry.load("ocean_state_decoder_v3")     # latent → physical

# A ROM as a pipekit pipeline
rom = pk.Sequential([
    encoder,
    pc.Cycle(step_op=latent_dyn, n_steps=72),         # latent evolution
    decoder,
])

# DA in the latent space
da_in_latent = pc.DACycle(
    forward_model=latent_dyn,                          # latent forward
    obs_op=ObservedFromLatent(encoder=encoder, ...),  # H = decoder ∘ obs_extract
    analysis_step=filterX_adapter.EnKFAnalysis(),
    n_steps=24,
)
```

The Embedding Layer is therefore **operationally identical to any other operator pipeline**, with the constraint that the operators in it were trained via `pipekit-train` and live in `pipekit-experiment.ModelRegistry`.

-----

## The two-stream convergence (satellite + in-situ)

The source makes a structural point that v2 underspecifies: **the L0–L4 chain is not a single linear progression — it’s two streams converging at L2/L3 via matchup.**

```
   Satellite (top-down)              In-situ (bottom-up)
                                                  
   L0  Raw telemetry                  ──    (not applicable)
        │                                              
        ▼  cal + geoloc                                  
   L1  Calibrated radiances           ──    (not applicable)
        │                                              
        ▼  retrieval                                       
   L2  Geophysical variables  ◄──┐      Argo profiles, CTD casts,
                                  │      moorings, gliders, drifters
        │                         │      (calibrated physical units;
        ▼ gridding + composite    │       depth axis z; sparse coverage)
                                  │              │
   L3  Gridded products ◄─────────┴──────────────┘
                                  │  spatiotemporal matchup
        │                            (the convergence operation)
        ▼ DA + fusion 
                              
   L4  Analysed / fused fields        (in-situ enters via assimilation)
```

Three implications:

1. **In-situ catalogs are first-class.** Argo (via argopy), World Ocean Database, ICOADS, SOCAT, drifters, gliders, moorings — these are catalogable data sources with their own slice semantics. `geocatalog` needs to support them, not just raster scenes.
2. **The depth `z` axis is structural for in-situ data**, and our `GeoSlice` (Report 6) doesn’t carry it. Argo profiles go to 2000m (core) or 6000m (deep); CTD casts go to local seafloor; moorings have fixed depth arrays. **`GeoSlice` is implicitly surface-only**, which is wrong for half the ocean and climate workflows.
3. **Spatiotemporal matchup is the convergence operator.** It’s a cross-catalog join with tolerances (e.g., ±3h, ±25km). It produces matched pairs that are themselves a new data product. It has no clean home in the current stack.

These three implications drive most of the recommendations below.

-----

## The depth axis (z): what GeoSlice is missing

`GeoSlice` from Report 6 carries `(bbox, crs, time, target_resolution, source_uri)`. This is implicitly 2D-spatial. For in-situ data with vertical structure, it’s incomplete.

### Three design options

**Option A — Extend `GeoSlice` with optional vertical fields.**

```python
@dataclass(frozen=True)
class GeoSlice:
    bbox: tuple[float, float, float, float]
    crs: str
    time: datetime | tuple[datetime, datetime]
    target_resolution: float | None = None
    source_uri: str = ""
    # NEW
    z_range: tuple[float, float] | None = None
    vertical_crs: str | None = None     # "depth_below_sea_surface", "pressure_dbar", etc.
```

Pros: backwards compatible; one slice type. Cons: 2D queries against catalogs with depth-aware slices need to ignore `z_range`; semantics blur.

**Option B — Sibling slice type `ProfileSlice`.**

```python
@dataclass(frozen=True)
class ProfileSlice:
    """For column / profile data: a single horizontal position with a depth profile."""
    lat: float
    lon: float
    crs: str
    time: datetime
    z_profile: tuple[float, ...]
    vertical_crs: str
    source_uri: str
```

Plus `TrajectorySlice` for moving platforms (gliders, drifters):

```python
@dataclass(frozen=True)
class TrajectorySlice:
    """For along-track data: (lat[t], lon[t], z[t], time[t])."""
    track: np.ndarray   # shape (N, 4) — lon, lat, z, time
    crs: str
    vertical_crs: str
    source_uri: str
```

Pros: each type clean. Cons: catalogs need to handle multiple slice types; queries become polymorphic.

**Option C — Generic `Slice` Protocol with concrete implementations.**

```python
@runtime_checkable
class Slice(Protocol):
    """Wire-format Protocol. Concrete implementations: GeoSlice (raster),
    ProfileSlice (column), TrajectorySlice (along-track).
    """
    @property
    def source_uri(self) -> str: ...
    @property
    def time(self) -> datetime | tuple[datetime, datetime]: ...
    def spatial_intersects(self, bbox) -> bool: ...
    def to_dict(self) -> dict: ...
```

Concrete implementations all live in `geocatalog._src.slices.*`. Catalogs parameterise on slice type. Existing `GeoSlice` becomes one implementation.

**My lean: Option C with backward compat.** It’s the structurally honest answer: each observation modality has its own natural wire format, and a Protocol unifies them at the framework level. The migration cost is real but the alternative (forcing column data into a 2D abstraction, or maintaining parallel APIs for each slice type) is worse.

Estimated effort: ~1 week to refactor `GeoSlice` into one of several `Slice` implementations, update `geocatalog` backends, add `ProfileSlice` and `TrajectorySlice` as concrete sibling types. Should be done in geocatalog v0.2.

-----

## The matchup pattern: a missing operator family

Spatiotemporal matchup is a cross-catalog join with tolerances. It produces matched pairs as a new data product. It’s canonical preprocessing for satellite-validation, label-generation, and hybrid model training. It has no clean home in our stack today.

### What matchup looks like

```python
import geocatalog as gc

satellite_cat = gc.open_catalog("s3://copernicus/sst_l3/2024/*.parquet")
argo_cat = gc.open_catalog("s3://argo/2024/*.parquet")

# Find all Argo surface measurements paired with co-located satellite SST
matches = gc.queries.matchup(
    primary=argo_cat,                # the "label" source (sparse, accurate)
    secondary=satellite_cat,         # the "feature" source (dense, less accurate)
    time_tolerance=timedelta(hours=3),
    space_tolerance_km=25.0,
    z_constraint="surface",          # restrict Argo to surface measurements
)

# matches is an iterable of MatchupPair objects
for pair in matches:
    print(pair.primary_slice)         # ProfileSlice — the Argo cast
    print(pair.secondary_slice)       # GeoSlice — the satellite scene
    print(pair.tolerance_used)        # actual ∆t, ∆x for this pair
    print(pair.representativeness_uncertainty)  # estimated
```

### Where it lives

Three options:

- **Option A**: `geocatalog.queries.matchup()` as a framework function (the join). Carrier-specific helpers in `xr-toolz.matchup` and `geotoolz.matchup` (the data extraction once you have a match).
- **Option B**: a small `pipekit-matchup` sibling package. Independent. Probably overkill.
- **Option C**: embed in `pipekit-train` as `MatchupDataset` (the primary use case is training data generation).

**My lean: Option A.** The fundamental operation is a cross-catalog join, which belongs in `geocatalog`. Carrier-specific helpers in the domain libraries handle the “now extract the data” step. `pipekit-train.MatchupDataset` then becomes a thin wrapper that consumes `geocatalog.queries.matchup()`.

### What matchup must record

The source is explicit: **“Maintaining provenance records that document the matchup tolerances adopted is therefore as important as any downstream normalization choice.”** Implication: `MatchupPair` is not just a tuple of two slices — it’s a record carrying:

```python
@dataclass(frozen=True)
class MatchupPair:
    primary_slice: Slice
    secondary_slice: Slice
    # Tolerances *requested*
    time_tolerance: timedelta
    space_tolerance_km: float
    # Actual values *for this pair*
    actual_dt: timedelta
    actual_dx_km: float
    # Estimated representativeness uncertainty
    # (the implicit averaging baked into the match)
    representativeness_uncertainty: float | None = None
    # Pair-specific metadata
    metadata: dict = field(default_factory=dict)
```

This pair is itself a serialisable artifact. A “matchup catalog” — a collection of `MatchupPair`s — is a new kind of derived catalog product.

### Estimated effort

- `geocatalog.queries.matchup` core function: ~3 days
- `MatchupPair` + matchup catalog as a sibling type: ~2 days
- `xr-toolz.matchup` and `geotoolz.matchup` helper modules: ~1 day each
- `pipekit-train.MatchupDataset`: ~1 day

Total: ~1 week of work, sitting in geocatalog v0.3 / pipekit-train v0.2.

-----

## The ML-Ready transformation in detail

The source’s offline/online preprocessing split maps directly onto `pipekit-train`:

### Offline (heavy, non-invertible, run once)

|Operation              |Why offline                                                    |
|-----------------------|---------------------------------------------------------------|
|Regridding             |Non-invertible; changes native geometry                        |
|Masking                |Discards data; can’t be reversed                               |
|Cadence harmonisation  |Temporal binning; loses sub-bin info                           |
|Matchup                |The join is the unit-of-data-creation; cache the result        |
|Climatology subtraction|Removes a learned signal; the climatology is itself an artifact|
|Co-registration        |Resamples to a common grid                                     |

Implementation: `pipekit-train.CachedDataset(source=Sequential([...offline_ops...]), cache_dir=...)`. The cache is content-addressed by `hash(source_dataset, preprocessing_config, seed)`. Persists across runs.

### Online (light, invertible, run per batch)

|Operation                 |Why online                         |
|--------------------------|-----------------------------------|
|Patch / tile extraction   |Cheap; depends on batch composition|
|Z-score / standard scaling|Trivially invertible               |
|Log / sqrt transforms     |Invertible                         |
|Random augmentation       |Per-batch randomness; can’t cache  |
|Per-batch normalization   |Stats are batch-dependent          |

Implementation: operators inside the `TrainingLoop` that run per-batch.

### Why this discipline matters

Two reasons the source emphasises:

1. **Non-invertible steps embed modeling assumptions.** Regridding picks a target grid; matchup picks tolerances; cadence harmonisation picks a temporal bin. These are scientific choices and should be auditable as separate artifacts (the offline cache), not buried inside per-batch logic.
2. **Caching the offline output is what makes training tractable.** Generating 100K plume simulations is hours. Doing it once and caching the resulting tensors is the difference between “we trained the emulator” and “we couldn’t afford to.”

### CF-compliant metadata as ML-Ready output

The source lists “CF-compliant metadata” as a core output of the ML-Ready Layer. In our stack:

- `xr-toolz.geo.validation` produces CF-compliant Datasets
- `xr-toolz.atm` / `.ocn` / `.ice` operators preserve CF conventions
- `pipekit.qc` should grow a `AssertCFCompliant` operator that validates a Dataset against CF conventions at preprocessing boundaries

CF-compliance lets downstream consumers interpret physical units, vertical CRS, time encoding, and uncertainty conventions without ad-hoc parsing.

-----

## The Embedding Layer in detail

The source’s framing: “physically-informed latent spaces used by reduced-order models (ROMs), autoencoders (AEs), and data assimilation (DA) workflows.”

The Embedding Layer is **operationally identical to any other operator pipeline** in our stack — the constraint is that the operators in it were trained via `pipekit-train` and registered in `pipekit-experiment.ModelRegistry`.

### The three Embedding Layer artifacts

For a typical ROM / latent-DA workflow, three trained operators must coexist in the model registry:

1. **Encoder** `e: physical → latent`. Compresses high-dimensional ocean state into a compact latent vector.
2. **Latent dynamics** `f_latent: latent → latent` (over time `Δt`). A learned forward model in latent space.
3. **Decoder** `d: latent → physical`. Reconstructs physical state from latent.

These are independent `Operator`s registered with related but distinct hashes. They share a *latent contract* (latent dim, conditioning vars) but are otherwise independent.

### The ROM as a pipekit pipeline

```python
import pipekit as pk
import pipekit_cycle as pc
import pipekit_experiment as pe

registry = pe.S3ModelRegistry(...)
encoder = registry.load("ocean_state_encoder_v3")
latent_dyn = registry.load("ocean_latent_dynamics_v3")
decoder = registry.load("ocean_state_decoder_v3")

# ROM: physical → latent → evolve → latent → physical
rom = pk.Sequential([
    encoder,
    pc.Cycle(step_op=latent_dyn, n_steps=72),
    decoder,
])

# A ROM as a forecast operator in the same shape as a physical forecast
forecast = rom(initial_physical_state)
```

### DA in latent space

```python
# Build the observation operator in latent space
class LatentObservationOp(Operator):
    """H in latent space: H_latent(z) = H_physical(decoder(z))"""
    decoder: Operator
    physical_obs_op: Operator
    
    def _apply(self, latent_state):
        physical = self.decoder(latent_state)
        return self.physical_obs_op(physical)

# Run DA in latent space — the headline ROM-DA pattern
latent_da = pc.DACycle(
    forward_model=latent_dyn,
    obs_op=LatentObservationOp(decoder=decoder, physical_obs_op=ColumnObs(...)),
    analysis_step=filterx_adapter.EnKFAnalysis(),
    n_steps=24,
    n_members=40,
)
```

This is precisely the source’s “DA-ready state embeddings” use case: a compact state vector with a decoder that bridges to physical observations, used inside a DA cycle. It’s also exactly the pattern that closes the ROM + DA loop without changing any other pipeline machinery.

### Latent space continuum

The source’s previous section framed ML-readiness as a continuum from standardised tensors → learned embeddings → foundation-model internal spaces. In our stack:

|Continuum point                 |Stack representation                                             |
|--------------------------------|-----------------------------------------------------------------|
|Standardised physical tensors   |Output of `pipekit-train.CachedDataset` (ML-Ready Layer)         |
|Compact learned embeddings      |Output of `pipekit-train.TrainingLoop` (Embedding Layer, low-dim)|
|Foundation-model internal spaces|Same as above, just higher-dim and less interpretable            |

All three live in the same model registry, accessed through the same `Operator` interface, composed with the same pipekit machinery. The continuum is in the data; the framework is the same throughout.

-----

## Recommended changes to the framework

Concrete edits, organised by document / package.

### A. v2 vision document edits

Five additions to make v2 fully integrate the three-layer + two-stream framing:

1. **Add the three-layer model as a new section** between “Data Tiers: The L0–L4 Axis” and “The Vision”. Use the ASCII diagram from §“The three-layer model” above.
2. **Update the L0–L4 ASCII diagram** to show the satellite (top-down) and in-situ (bottom-up) streams converging at L2/L3 via matchup. The single linear chain is wrong.
3. **Add depth `z` to the Geo-Task Taxonomy** as an explicit sub-axis of Space, with a note about the satellite/in-situ asymmetry.
4. **Add a note in the L0–L4 Pipeline section** identifying matchup (step 2.5: matchup between satellite L2 and in-situ profiles) as a canonical operation.
5. **Strengthen the Encoders–Decoders row in Core Representations** to explicitly reference the Embedding Layer and the registry-based composition pattern.

### B. geocatalog roadmap (Report 6)

Three additions to the geocatalog scope:

- **v0.2** — Refactor `GeoSlice` into a `Slice` Protocol with concrete implementations. Add `ProfileSlice` (column / vertical data) and `TrajectorySlice` (along-track moving platforms). Existing `GeoSlice` becomes one of several siblings.
- **v0.2** — Add in-situ catalog backends: at minimum Argo (via `argopy`) and ICOADS / SOCAT readers. Document the Slice-type / backend matrix.
- **v0.3** — Ship `geocatalog.queries.matchup()` as a first-class cross-catalog operation. Add `MatchupPair` and matchup-catalog as a sibling catalog type.

### C. pipekit-train roadmap (Report 11)

Two additions:

- **v0.1 explicit discipline** — `CachedDataset` documents the offline / online preprocessing split. Non-invertible operations belong in the source pipeline (cached); invertible operations belong in the TrainingLoop (per-batch). Document this in the v0.1 README, not as a v0.2 feature.
- **v0.2** — `MatchupDataset` wraps `geocatalog.queries.matchup()` and yields matched-pair training data. Bridges satellite + in-situ to pipekit-train.

### D. xr-toolz and geotoolz domain additions

- **`xr-toolz.matchup`** — spatiotemporal matchup helpers for xarray-flavoured data; extracts data once `geocatalog.queries.matchup()` returns matched pairs.
- **`xr-toolz.profile`** — column / vertical-axis operators: depth interpolation, mixed-layer-depth diagnostics, vertical integration. Used by ocean / atmospheric domain modules.
- **`geotoolz.matchup`** — same role for `GeoTensor`-flavoured data.
- **Both libraries** — `AssertCFCompliant` as a QC operator that validates a Dataset / GeoTensor against CF metadata conventions at preprocessing boundaries.

### E. A new minor package question: `pipekit-embedding`?

The Embedding Layer is consequential enough to merit considering a dedicated package — but probably doesn’t need one. The three operations it owns (encoder/decoder co-training, latent dynamics learning, ROM composition) are all expressible via existing pipekit + pipekit-train + pipekit-cycle + pipekit-experiment. What’s missing is a **patterns library**: documentation, worked examples, the right architectural primitives in pipekit-train.

**My lean: no new package; ship a `pipekit-train.embedding` submodule with helper functions** like `train_autoencoder_pair`, `train_latent_dynamics`, `build_rom_pipeline`. ~150 LOC of patterns, in pipekit-train v0.2. Worth a small report eventually if the design space grows.

-----

## What doesn’t change

Honestly, most of v2 holds. The three-layer model and two-stream framing **complement** rather than replace the existing architecture:

|v2 commitment                                      |Does it change?                                                                                                                       |
|---------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------|
|L0–L4 axis                                         |No — the source confirms it; v2 only needs to make the two-stream convergence explicit                                                |
|pipekit + sister libraries architecture            |No — the three layers map cleanly onto Layer 4 + Layer 5                                                                              |
|Modeling cycle as organising principle             |No — still the right mental model                                                                                                     |
|Carrier-agnostic Layer 4 + carrier-specific Layer 5|No — in-situ data just adds new `Slice` types and Field adapters; the architecture absorbs it                                         |
|ML at every level                                  |No — the three-layer model makes this more operationally concrete but doesn’t change the principle                                    |
|Per-layer operator protocols                       |No — `Slice` becomes one more Protocol, sibling to `Field`/`Domain`/`ForwardModel` etc.                                               |
|Math-first documentation                           |No — the embedding layer is exactly where math-first docs earn their keep                                                             |
|Scope discipline / phased delivery                 |No — these additions are scoped: a v0.2 refactor of GeoSlice, a v0.3 matchup feature, a documentation discipline in pipekit-train v0.1|

The structural shifts (Slice Protocol, matchup as canonical operation, depth axis, embedding-as-registry-pipeline) are additions, not replacements. They sit cleanly inside the framework v2 establishes.

-----

## What I’d push on before committing

Three honest concerns before treating any of this as decided:

1. **The Slice Protocol refactor is more disruptive than it looks.** Currently `GeoSlice` is used directly across geocatalog + geotoolz + xr-toolz + pipekit-train. Changing it to a Protocol with concrete subtypes ripples through every loader, every catalog backend, every domain operator that consumes a slice. Estimated 1 week of refactoring is probably optimistic; 2 weeks is more honest. Worth doing, but worth budgeting properly.
2. **Matchup uncertainty quantification is its own research problem.** The `representativeness_uncertainty` field in `MatchupPair` is easy to declare and hard to compute. Satellite footprint averaging + temporal-mismatch error + spatial-mismatch error is a real estimation problem. v0.1 of matchup should probably ship without this field, or with a placeholder that documents the assumption. Real uncertainty quantification is a follow-on research effort.
3. **In-situ catalog backends are heterogeneous.** Argo (`argopy`), ICOADS, SOCAT, World Ocean Database, GLODAP, EN4 — each has its own access protocol, time encoding, QC flag conventions, vertical CRS. The `geocatalog` v0.2 work on in-situ backends is realistically *one backend per quarter* of focused work, not “ship them all in v0.2.” Prioritise based on which projects actually need them. Argo first is probably the right call.

-----

## Summary

The source’s three-layer model (Scientific-Data / ML-Ready / Embedding) and the two-stream framing (satellite + in-situ converging at L2/L3 via matchup) are valuable structural additions to the v2 vision. They map cleanly onto our stack with three concrete gaps to fill:

1. **The depth `z` axis is missing from `GeoSlice`.** Fix via Slice Protocol refactor + `ProfileSlice` / `TrajectorySlice` siblings in geocatalog v0.2.
2. **Matchup has no clean home.** Fix via `geocatalog.queries.matchup()` + `MatchupPair` artifact + `xr-toolz.matchup` / `geotoolz.matchup` carrier helpers + `pipekit-train.MatchupDataset`. v0.2/v0.3.
3. **The Embedding Layer is structurally implicit.** Make it explicit via pipekit-train.embedding patterns submodule + documentation of the encoder + latent dynamics + decoder triad as standard registry artifacts.

The three-layer model is best framed as **complementary to v2**, not a replacement. The L0–L4 axis describes maturity; the three-layer model describes transformations; the modeling cycle describes the research loop. All three lenses, on the same architecture.

The recommended changes are scoped, sequenced, and additive. Nothing in the existing v2 framework is invalidated. The work is real but bounded — roughly 3–4 weeks of focused effort across geocatalog v0.2/v0.3, pipekit-train v0.2, and the documentation refresh — and it brings the framework into honest alignment with how ocean (and other multi-modal observation) data lifecycles actually run.