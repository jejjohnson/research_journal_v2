---
title: "Report 3 — Sister libraries on top of pipekit"
subject: geotoolz master plan
short_title: "R3 — Sister libs"
authors:
  - name: J. Emmanuel Johnson
    affiliations:
      - UNEP
      - IMEO
      - MARS
    orcid: 0000-0002-6739-0053
    email: jemanjohnson34@gmail.com
license: CC-BY-4.0
keywords: geotoolz, pipekit, pipekit-array, sister-libraries, xr-toolz
---

# Report 3 — Sister libraries on top of pipekit

|                     |                                                                           |
|---------------------|---------------------------------------------------------------------------|
|**Status**           |Surface proposal                                                           |
|**Reading time**     |~20 min                                                                    |
|**Audience**         |Anyone scoping the layered library ecosystem on top of pipekit             |
|**Companion reports**|Report 1 (background), Report 2 (pipekit core), Report 4 (use-case revisit)|

This report describes the **three sister libraries that sit on pipekit and together cover the practical carrier surface**: arrays (duck-typed via Array API), `GeoTensor` (geotoolz), and xarray DataArrays/Datasets (xr_toolz). Each library is a thin layer over pipekit with carrier-specific operators.

The diagram:

```
┌────────────────────────────────────────────────────┐
│                  Domain libraries                  │
│                                                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────┐  │
│  │  geotoolz    │  │   xr_toolz   │  │  others  │  │
│  │ (GeoTensor)  │  │   (xarray)   │  │   ...    │  │
│  └──────────────┘  └──────────────┘  └──────────┘  │
│         │                  │              │        │
│         └────────┬─────────┴──────────────┘        │
│                  ▼                                 │
│         ┌─────────────────┐                        │
│         │  pipekit-array  │  ← duck-typed arrays   │
│         │   (Array API)   │     (numpy, JAX, etc.) │
│         └─────────────────┘                        │
│                  │                                 │
│                  ▼                                 │
│         ┌─────────────────┐                        │
│         │     pipekit     │  ← carrier-agnostic    │
│         │     (core)      │     framework          │
│         └─────────────────┘                        │
└────────────────────────────────────────────────────┘
```

## The three layers above pipekit

### Layer 1 — `pipekit-array`: duck-typed array operators

A sister package on top of pipekit’s framework, implementing **array-shaped operators against the [Python Array API standard](https://data-apis.org/array-api/)**. The Array API is the modern, formal answer to “duck arrays” — it gives you a single `array_namespace(x)` dispatch that returns a numpy-shaped namespace regardless of whether `x` is numpy, JAX, CuPy, PyTorch, or dask.

### Layer 2 — `geotoolz`: `GeoTensor` operators

Thin domain layer on top of pipekit, with operators that consume and return `GeoTensor` (the numpy-subclass with geographic metadata). Most array math delegates to `pipekit-array`; what `geotoolz` adds is the geo-specific work (sensor presets, CRS-aware operators, etc).

### Layer 3 — `xr_toolz`: `xarray` operators

Thin domain layer on top of pipekit, with operators that consume and return `xr.DataArray` / `xr.Dataset` / `xr.DataTree`. Array math that’s not xarray-specific can also delegate to `pipekit-array`.

Three modules, three primitives, each in its own sweet spot. Let me cover each in detail.

## Part 1 — `pipekit-array`: duck-typed arrays via Array API

### 1.1 What the Array API gives us

The [Python Array API standard](https://data-apis.org/array-api/) is a specification that’s been adopted by:

|Library      |Conformance                           |
|-------------|--------------------------------------|
|numpy ≥ 2.0  |Full (via `numpy.array_api` namespace)|
|jax.numpy    |Full (since JAX 0.4.20)               |
|cupy         |Full                                  |
|pytorch ≥ 2.0|Full (via `torch.array_api`)          |
|dask.array   |Partial                               |
|sparse       |Partial                               |

The mechanism: every conforming array implements `__array_namespace__()`, which returns a module-like object with `mean`, `sum`, `where`, `reshape`, etc. as functions. The user’s pattern:

```python
def my_operator(x):
    xp = array_namespace(x)  # returns numpy / jax / cupy / etc.
    return xp.mean(x, axis=-1, keepdims=True)
```

One function works on five backends. **This is exactly the “duck-array” idea formalised.**

### 1.2 What ships in `pipekit-array`

The carrier-specific operators that v1 / v2 scoping flagged as “numpy-flavoured” — rewritten against the Array API namespace so they work cross-backend.

|Operator                                            |Purpose                                                |Module                     |
|----------------------------------------------------|-------------------------------------------------------|---------------------------|
|`ApplyToBands(inner, axis=0)`                       |Split-apply-stack over an axis                         |`pipekit_array.combinators`|
|`Subsample(stride=10)`                              |Stride-decimate the last two axes                      |`pipekit_array.geom`       |
|`Histogram(bins=10)` (controller + `.at(key)`)      |Capture distributions per tap site                     |`pipekit_array.observe`    |
|`Diff(reference, atol=1e-6)`                        |Compare against a stored reference; raise on drift     |`pipekit_array.qc`         |
|`AssertValueRange(min, max, on_fail="raise"|"warn")`|Pass-through; raise / warn on out-of-range             |`pipekit_array.qc`         |
|`AssertNoNaN()`                                     |Pass-through; raise on any NaN                         |`pipekit_array.qc`         |
|`AssertValidFraction(min_valid=0.5)`                |Pass-through; raise if `< 50%` non-NaN                 |`pipekit_array.qc`         |
|`ModelOp(model, method="__call__", batch_size=None)`|Framework-agnostic inference; numpy / JAX / torch model|`pipekit_array.inference`  |
|`BatchedMap(op, batch_size=8)`                      |Split along axis 0, apply, concatenate                 |`pipekit_array.parallel`   |
|`MeanScalar(field=None)`                            |Reduce to scalar via `xp.mean`                         |`pipekit_array.reduce`     |
|`StackAlong(axis)`                                  |Stack list-of-arrays along an axis                     |`pipekit_array.combinators`|
|`ConcatenateAlong(axis)`                            |Concatenate along an axis                              |`pipekit_array.combinators`|

12 operators, ~400 LOC. All implemented against `array_namespace(x)`.

### 1.3 The trade-offs and honest constraints

**What works.**

- Numpy code: bog-standard.
- JAX code: array math just works; `jax.jit` does **not** integrate (see Report 2 — JAX `@jit` compatibility is a pipekit non-goal because of the dual-mode dispatch).
- CuPy code: GPU-resident arrays move through the pipeline transparently.
- PyTorch tensors: gradient tracking is preserved (so you *could* differentiate through a `pipekit-array` pipeline if you stay inside an autograd context).
- Mixed-backend pipelines: same operator works on numpy or JAX without changes; the backend is decided by the input array’s namespace.

**What doesn’t.**

- **NaN handling.** numpy’s `nan_to_num` and JAX’s equivalent behave differently in some edge cases. Operators that use NaN as a fill value need careful per-backend testing.
- **In-place operations.** JAX is immutable; numpy is mutable. Operators that mutate inputs will break on JAX. Discipline: pipekit-array operators are always pure-functional.
- **Operations missing from the Array API.** Some specialised ops (FFTs, linear algebra beyond basics) aren’t in the spec. Need backend-specific fallbacks via `array_namespace(x).__name__`.
- **Dask laziness.** dask-array supports the Array API but its operations are lazy; pipelines need explicit `.compute()` calls at the end.

### 1.4 Recommended dependency surface

```toml
[project]
name = "pipekit-array"
dependencies = ["pipekit>=0.1"]

[project.optional-dependencies]
numpy = ["numpy>=2.0"]
jax   = ["jax>=0.4.20"]
torch = ["torch>=2.0"]
cupy  = ["cupy>=13"]
dask  = ["dask[array]>=2024"]
```

The minimum install is dep-free (pipekit only) but operators raise `ImportError` if no Array-API-conforming backend is available. The recommended user install is `pipekit-array[numpy]`.

### 1.5 Migration of existing geotoolz / xr_toolz numpy operators

The eight or so carrier-specific operators currently sitting in `geotoolz.pipeline_idioms` BYO and in `xr_toolz` array-flavoured code migrate to `pipekit-array`. Both `geotoolz` and `xr_toolz` then re-export them from `pipekit-array` with carrier-specific defaults baked in:

```python
# geotoolz/qc.py
from pipekit_array.qc import AssertValueRange as _AssertValueRange

class AssertValueRange(_AssertValueRange):
    """GeoTensor-aware value-range assertion. Same logic, but reads
    GeoTensor's fill_value as default min/max bounds if not provided."""
    def __init__(self, min_val=None, max_val=None, on_fail="raise"):
        super().__init__(min_val=min_val, max_val=max_val, on_fail=on_fail)
```

One implementation; three places it’s used.

## Part 2 — `geotoolz`: `GeoTensor` operators

### 2.1 Scope after pipekit extraction

`geotoolz` becomes a thinner library focused on its actual domain value: **remote sensing on top of `georeader.GeoTensor`**. The framework code that used to live in `geotoolz.core` becomes a compatibility shim that re-exports from `pipekit`.

```
geotoolz/
  __init__.py             # re-exports pipekit + array + geo ops
  core/                   # compatibility shim → re-exports from pipekit
  io/                     # GeoTensor-specific I/O: ReadBounds, WriteCOG
  geom/                   # CRS-aware geometric ops: BowtieCorrection, GeostationaryParallaxCorrect, ...
  radiometry/             # TOAToBOA, DarkObjectSubtraction, RadianceToReflectance, BTFromRadiance
  indices/                # NDVI, NDWI, EVI, ... (sensor-aware band-index lookups)
  spectral/               # MatchedFilter, ACE, LinearUnmixing
  cloud/                  # MaskFromQABits, MaskFromSCL, ApplyMask
  qa/                     # AssertCRSEquals, AssertResolutionWithin, AssertSchema (carrier-specific)
  mask/                   # PolygonMask, AOI clipping
  patch/                  # ExtractPatches, StitchPatches (with per-patch metadata)
  catalog/                # GeoCatalog, CatalogPipeline (the domain-specific iteration)
  readers/                # gz.readers.<sensor> per the 8 sensor design docs
  viz/                    # Colormap, TrueColor, FalseColor, StretchToUint8
  compositing/            # MedianComposite, MaxNDVIComposite, CloudFreeComposite
  augment/                # RandomFlip, RandomRotate90 (training-only)
  presets/                # Sensor presets bundling reader + ops
```

### 2.2 What geotoolz uniquely owns

|Concern                                                      |Why it stays in geotoolz                               |
|-------------------------------------------------------------|-------------------------------------------------------|
|`GeoTensor` reading / writing                                |Tightly coupled to `georeader` and rasterio            |
|CRS-aware geometric ops                                      |`crs`, `transform`, `bounds` are `GeoTensor` properties|
|Sensor presets (readers + ops bundles)                       |All 8 sensor design docs from earlier                  |
|`GeoCatalog` / `CatalogPipeline`                             |Multi-scene iteration over a parquet catalog           |
|`ExtractPatches` with per-patch metadata                     |Each patch carries its own `transform`                 |
|Geo-specific QC (`AssertCRSEquals`, `AssertResolutionWithin`)|Need `GeoTensor` attributes                            |
|Sensor-specific calibration tables                           |Per-sensor `data/` directories                         |

### 2.3 What geotoolz delegates upward

|Now in geotoolz                                              |Migrates to                                                             |
|-------------------------------------------------------------|------------------------------------------------------------------------|
|`geotoolz.core.*` (Operator, Sequential, etc.)               |`pipekit`                                                               |
|`geotoolz.qc.AssertValueRange` / `AssertNoNaN` (numpy-shaped)|`pipekit-array` (geotoolz re-exports)                                   |
|`geotoolz.spectral.MatchedFilter` array math                 |`pipekit-array` (geotoolz wraps with GeoTensor-aware default targets)   |
|`geotoolz.augment.*` array transforms                        |`pipekit-array` (geotoolz wraps with GeoTensor-aware coordinate updates)|

The result: `geotoolz` is now ~30% smaller (the framework code is gone) and clearly focused on geo-specific semantics.

### 2.4 What new in geotoolz from the sensor design docs

From earlier work, `geotoolz.readers.<sensor>` ships the 8 sensor reader modules:

|Module                     |Sensor                                 |
|---------------------------|---------------------------------------|
|`geotoolz.readers.modis`   |MODIS L1B + L2 (stretch — pyhdf gating)|
|`geotoolz.readers.viirs`   |VIIRS SDR + EDR                        |
|`geotoolz.readers.goes`    |GOES-R ABI                             |
|`geotoolz.readers.seviri`  |MSG SEVIRI (NAT + xRIT)                |
|`geotoolz.readers.mtg`     |MTG-FCI                                |
|`geotoolz.readers.himawari`|Himawari AHI (HSD)                     |
|`geotoolz.readers.tropomi` |TROPOMI L2                             |
|`geotoolz.readers.s3`      |Sentinel-3 OLCI / SLSTR                |

Each module bundles reader + sensor-specific operators + zero-arg presets. Reader plans + per-sensor design docs already exist in the sensor-integration outputs.

### 2.5 Cross-cutting modules `geotoolz` adds on top of pipekit + pipekit-array

|Module                   |What’s new vs pipekit / pipekit-array                                        |
|-------------------------|-----------------------------------------------------------------------------|
|`geotoolz.compositing`   |`BAPComposite`, `MaxNDVIComposite`, `MedianComposite` with QA-aware behaviour|
|`geotoolz.normalize`     |Scene-statistics-based normalisation (stateful)                              |
|`geotoolz.restore`       |Despeckle, gap-fill, super-resolution wrappers                               |
|`geotoolz.plume`         |`PlumeMask`, `PlumeFootprint`, point-source attribution                      |
|`geotoolz.matched_filter`|CH4 / NH3 / N2O matched filtering for hyperspectral plume retrieval          |

## Part 3 — `xr_toolz`: xarray operators

### 3.1 Scope after pipekit extraction

`xr_toolz` becomes a focused xarray-domain library. The framework code in `xr_toolz.core` becomes a compatibility shim. What stays:

```
xr_toolz/
  __init__.py             # re-exports pipekit + array + xr ops
  core/                   # compatibility shim → re-exports from pipekit; PLUS Augment, ApplyToEach
  validation/             # ValidateCoords, RenameCoords, SortCoords (xarray coord/attr manip)
  crs/                    # AssignCRS, Reproject, GetCRS (rioxarray-backed)
  subset/                 # SubsetBBox, SubsetTime, SubsetWhere
  masks/                  # AddLandMask, AddOceanMask, AddCountryMask (via regionmask)
  detrend/                # CalculateClimatology, RemoveClimatology, ComputeAnomaly
  interpolate/            # Regrid, GapFill, Smooth, Resample (D12)
  transforms/             # Encoders (one-hot, cyclical, ...) and decompositions (PSD, wavelet)
  metrics/                # RMSE, PSDScore, NashSutcliffe (D7)
  kinematics/             # OkuboWeiss, RelativeVorticity, KineticEnergy (D9)
  ocn/                    # Domain-specific: oceanography quantities
  atm/                    # Domain-specific: atmospheric quantities
  rs/                     # Remote-sensing-flavoured xarray ops (DataArray-on-disk)
  viz/                    # Matplotlib-based plot operators (D10)
  inference/              # SklearnModelOp, JaxModelOp (sample_dim aware)
  data/                   # CMEMS, CDS, AEMET data-source presets
```

### 3.2 What xr_toolz uniquely owns

|Concern                                                             |Why it stays in xr_toolz                          |
|--------------------------------------------------------------------|--------------------------------------------------|
|Coordinate validation / harmonization                               |`xr.Dataset` coord + attr manipulation            |
|CRS embedding via `rioxarray`                                       |xarray-specific accessor                          |
|Climatology / anomaly / detrend                                     |Time-axis aware, xarray-native via `groupby`      |
|Regridding, gap-fill, smoothing                                     |xarray’s `interp` + scipy backends                |
|`Augment` / `ApplyToEach` combinators                               |Use `xr.merge` — fundamentally xarray-specific    |
|Skill-score metrics (RMSE, PSD, NSE)                                |Compute over named dims, return xarray            |
|Domain-specific quantities (ocean kinematics, atmospheric chemistry)|Lives on `xr.DataArray` natively                  |
|Visualisation operators returning `matplotlib.Figure`               |xarray-flavoured plotting                         |
|Data-source presets (CMEMS, CDS, AEMET, …)                          |Opening + standardising specific provider datasets|

### 3.3 What xr_toolz delegates upward

|Now in xr_toolz                                    |Migrates to                                   |
|---------------------------------------------------|----------------------------------------------|
|`xr_toolz.core.*` (Operator, Sequential, Graph, …) |`pipekit`                                     |
|`xr_toolz.core.combinators.Augment` / `ApplyToEach`|**Stays** — uses `xr.merge`; not a pipekit fit|
|`xr_toolz.core.combinators.Tap`                    |`pipekit` (unified with geotoolz’s Tap)       |
|Array-shaped pieces of `xr_toolz` operators        |`pipekit-array` (e.g., the reduce inside RMSE)|

### 3.4 The xarray-specific combinators worth preserving

Three combinators from `xr_toolz.core.combinators` that are too valuable to remove:

- **`Augment(inner)`**: run `inner(ds)` and merge its output back into the input via `xr.merge(compat="no_conflicts")`. This is the canonical “compute derived columns and append them” pattern. Used heavily in the kinematics example (`Augment(RelativeVorticity()) → Augment(KineticEnergy()) → Augment(OkuboWeiss())`).
- **`ApplyToEach(prototype, kwarg, values)`**: re-instantiate the prototype once per value, apply each, merge all. The xarray-shaped analogue of `Fanout` but with auto-merge.
- **`Tap(side_effect)`**: identity-with-side-effect — pipekit ships the canonical version; xr_toolz can re-export.

The first two stay in xr_toolz because they use `xr.merge`. Worth a clear note in their docstrings that the merge semantics differ from pipekit’s framework-level combinators.

## Part 4 — Where each library’s `Tap`, `Sequential`, etc. lives after migration

A quick reference table because this is the most common confusion point:

| Symbol                                                   | Lives in                    | Re-exported from                            |
| -------------------------------------------------------- | --------------------------- | ------------------------------------------- |
| `Operator`                                               | `pipekit._base.operator`    | `pipekit`, `geotoolz.core`, `xr_toolz.core` |
| `Sequential`                                             | `pipekit._base.sequential`  | `pipekit`, `geotoolz.core`, `xr_toolz.core` |
| `Graph`, `Input`, `Node`                                 | `pipekit._base.graph`       | `pipekit`, `geotoolz.core`, `xr_toolz.core` |
| `Fanout`                                                 | `pipekit.combine`           | `pipekit`, `geotoolz.core`, `xr_toolz.core` |
| `Identity`, `Const`, `Lambda`, `Sink`                    | `pipekit.blocks`            | `pipekit`, both libraries                   |
| `Tap`                                                    | `pipekit.observe`           | both libraries                              |
| `Branch`, `Switch`, `Try`, `Coalesce`, `Retry`           | `pipekit.control`           | both libraries                              |
| `Snapshot`, `ShapeTrace`, `Profile`                      | `pipekit.observe`           | both libraries                              |
| `Cache`                                                  | `pipekit.cache`             | both libraries                              |
| `Quarantine`, `AssertShape`, `AssertDType`               | `pipekit.qc`                | both libraries                              |
| `Signature`, `compute_output_signature`                  | `pipekit.signature`         | both libraries                              |
| `ThreadMap`, `ProcessMap`, `AsyncMap`, `BatchedMap`      | `pipekit.parallel`          | both libraries                              |
| `pipe`, `compose`, `juxt`, `complement`                  | `pipekit.compose`           | both libraries                              |
| `ApplyToBands`, `Subsample`, `Diff`                      | `pipekit_array.*`           | geotoolz + xr_toolz                         |
| `Histogram` controller                                   | `pipekit_array.observe`     | both libraries                              |
| `AssertValueRange`, `AssertNoNaN`, `AssertValidFraction` | `pipekit_array.qc`          | both libraries (with sensor-aware defaults) |
| `ModelOp`                                                | `pipekit_array.inference`   | both libraries                              |
| `Augment`, `ApplyToEach`                                 | `xr_toolz.core.combinators` | xr_toolz only                               |
| `GeoCatalog`, `CatalogPipeline`                          | `geotoolz.catalog`          | geotoolz only                               |
| `ExtractPatches`, `StitchPatches` (with metadata)        | `geotoolz.patch`            | geotoolz only                               |
| Sensor readers / presets                                 | `geotoolz.readers.<sensor>` | geotoolz only                               |
| `Reproject`, `CRS` ops                                   | `xr_toolz.crs`              | xr_toolz only                               |
| Climatology / detrend                                    | `xr_toolz.detrend`          | xr_toolz only                               |

## Part 5 — Other libraries that could fit on top

You asked whether there should be libraries for numpy / JAX / numba / duck-array. Here’s my honest answer for each:

### 5.1 `pipekit-array` — yes, the answer for numpy / JAX / CuPy / PyTorch

Covered above. Array API is the right abstraction. One library covers all four backends.

### 5.2 `pipekit-numba` — probably not a separate library

Numba is a JIT compiler, not a separate carrier type. Numba-jitted operators are still numpy-flavoured at the carrier level; what’s different is that their inner kernels are `@njit`. The right pattern: **`pipekit-array` operators can have numba-jitted inner kernels**, decided per-operator. Adding a separate `pipekit-numba` library duplicates surface for no real abstraction benefit.

If you want a fast-path: `pipekit-array[fast]` extra pulls in numba and a couple of operators have `@njit`-decorated inner kernels. The Operator class itself is unchanged.

### 5.3 `pipekit-jax-traceable` — separate library, deferred

JAX-specific compatibility (`jax.jit`, `jax.vmap`, `jax.grad` working through a pipekit pipeline) is genuinely a different problem from “JAX as one of the Array API backends.” It requires:

- Carrier-typing operators on JAX PyTrees with static metadata (à la `equinox.Module`)
- Reworking `__call__` dispatch to not break tracing
- Static-method `_apply` that’s pure and side-effect-free

This is **a separate library**, probably `pipekit-jax` or `jax_geotoolz`. Defer until a concrete project (differentiable retrievals, learnable corrections) demands it.

### 5.4 `pipekit-dask` — out of scope

Distributed parallelism via dask requires every operator to be pickleable + scheduler-aware. That’s an orchestrator concern, not a framework concern. Pipekit operators are pickleable (Group J discipline); how they get distributed is downstream tooling. dask users can compose pipekit `Operator`s inside `dask.bag.map` or `dask.delayed` themselves.

### 5.5 `pipekit-cuda` — covered by `pipekit-array` with CuPy

CuPy is an Array API conformant backend. `pipekit-array[cupy]` is the answer; CUDA-specific operators don’t need their own library.

### 5.6 What about specific carriers — pandas DataFrames, polars, dicts?

`pipekit` is `Carrier = Any`. You **can** write Operator subclasses that consume DataFrames — there’s nothing in the framework that prevents it. Whether a `pipekit-pandas` library is worth its own existence depends on whether your community has DataFrame-shaped pipelines. My honest read: probably not for the methane / MARS / atmospheric-chemistry use cases that drive your work. Defer.

## Part 6 — How to think about adding a new sister library

Three questions to ask:

1. **Is there a clearly-typed carrier?** If yes → potential sister library. If no → it belongs in an existing library or in pipekit core.
2. **Are there ≥ 8 operators that would consume this carrier natively?** If yes → worth its own library. If no → contribute the operators to the closest existing library.
3. **Does the carrier already have a wide-enough standard?** Array API has this for arrays. `xarray.Dataset` is its own de facto standard. Pandas / polars don’t fit cleanly. If the carrier has a coherent standard, sister-library is easy; if not, you’re inventing the standard along with the operators.

By those criteria:

- **`pipekit-array` clearly passes.** Array API exists, multi-backend, ~12 operators.
- **`geotoolz` clearly passes.** GeoTensor is the de facto standard for the methane workflow; dozens of operators.
- **`xr_toolz` clearly passes.** xarray DataArrays / Datasets are the standard; many operators.
- **JAX-traceable sister: passes once a project drives it.** Deferred.
- **numba / dask / pandas: don’t pass.** Numba is an implementation detail; dask is orchestration; pandas doesn’t have a wide-enough community-of-yours.

## Summary

|Layer       |Library                                          |What it owns                                                                           |Status               |
|------------|-------------------------------------------------|---------------------------------------------------------------------------------------|---------------------|
|Core        |`pipekit`                                        |Framework: Operator, Sequential, Graph, observe, control, qc, parallel                 |New                  |
|Array       |`pipekit-array`                                  |Array API operators: ApplyToBands, Subsample, ModelOp, Diff, AssertValueRange, …       |New                  |
|Geo         |`geotoolz`                                       |GeoTensor operators: io, geom, radiometry, indices, cloud, presets, readers, …         |Existing (refactored)|
|xarray      |`xr_toolz`                                       |xarray operators: validation, crs, subset, detrend, interpolate, metrics, ocn, atm, viz|Existing (refactored)|
|Future      |`pipekit-jax`                                    |JAX-traceable operators with static metadata                                           |Deferred             |
|Out of scope|`pipekit-dask`, `pipekit-numba`, `pipekit-pandas`|Different problems; not framework concerns                                             |Not planned          |

The honest takeaway: **two new packages (`pipekit`, `pipekit-array`) plus refactoring two existing ones (`geotoolz`, `xr_toolz`).** Everything else either doesn’t justify a separate library, doesn’t have a clear carrier standard, or is solving a different problem entirely.