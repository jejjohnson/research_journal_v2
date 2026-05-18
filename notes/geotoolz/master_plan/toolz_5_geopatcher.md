---
title: "Report 7 — `geopatcher`: four-axis patcher package"
subject: geotoolz master plan
short_title: "R7 — geopatcher"
authors:
  - name: J. Emmanuel Johnson
    affiliations:
      - UNEP
      - IMEO
      - MARS
    orcid: 0000-0002-6739-0053
    email: jemanjohnson34@gmail.com
license: CC-BY-4.0
keywords: geotoolz, geopatcher, patcher, four-axis, sampling
---

# Report 7 — `geopatcher`: standalone four-axis patcher package

|                       |                                                                                                                                                                                                            |
|-----------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|**Status**             |Scoping proposal — committed                                                                                                                                                                                |
|**Reading time**       |~20 min                                                                                                                                                                                                     |
|**Decisions locked in**|Develop in the `pipekit-ecosystem` monorepo (uv / hatch workspaces); publish as separate packages. `geopatcher` core has no pipekit dependency — the 125-LOC Operator integration is an extras-gated module.|
|**Audience**           |Anyone reviewing the patcher split before code moves                                                                                                                                                        |
|**Companion reports**  |Reports 1–5 (pipekit stack), Report 6 (geocatalog)                                                                                                                                                          |
|**Inputs**             |`jejjohnson/geotoolz` @ main (rescraped 2026-05-16), specifically `geotoolz.patch` (~6,800 LOC across ~20 files)                                                                                            |

## Part 1 — Where `geopatcher` sits in the stack

After the full series of splits:

```
   ┌────────────────────────────────────────────────────────────┐
   │ georeader  (GeoTensor, GeoData Protocol, RasterioReader,   │
   │             AsyncGeoTIFFReader — the I/O substrate)        │
   └────────────────────────────────────────────────────────────┘
                                ▲
              ┌─────────────────┼──────────────────┐
              │                 │                  │
   ┌──────────┴───────┐  ┌──────┴──────┐  ┌────────┴───────┐
   │   geocatalog     │  │   pipekit   │  │   geopatcher   │
   │  (Report 6)      │  │ (framework) │  │  (this report) │
   │  — GeoSlice      │  │             │  │  — Field /     │
   │  — GeoCatalog    │  │             │  │    Domain      │
   │  — backends      │  │             │  │  — Patchers    │
   │  — builders      │  │             │  │  — Aggregations│
   │  — loaders       │  │             │  │  — Fields      │
   └──────────────────┘  └─────────────┘  └────────┬───────┘
              ▲                 ▲                  │
              │                 │     ┌────────────┘
              │                 │     │ optional [pipekit] extra
              │                 │     ▼
              │                 │  ┌────────────────────────────┐
              │                 └──┤ geopatcher.integrations    │
              │                    │   .pipekit                 │
              │                    │ — GridSampler              │
              │                    │ — ApplyToChips             │
              │                    │ — Stitch                   │
              │                    └────────────────────────────┘
              │                              ▲
              └──────────────┬───────────────┘
                             │
              ┌──────────────┴──────────────────┐
              │           geotoolz              │
              │   GeoTensor domain operators    │
              │   + xr_toolz on xarray side     │
              └─────────────────────────────────┘
```

Key shape observations:

1. **`geopatcher` core has no dependencies on `pipekit`, `geocatalog`, or `georeader`.** The Field/Domain Protocol model means the patcher consumes anything that satisfies the Protocol — `RasterField` wraps a `GeoData` (from georeader), but `geopatcher` only imports `georeader` from one extras-gated module (`fields/raster.py`).
2. **The pipekit integration is a 125-LOC sliver** — `GridSampler`, `ApplyToChips`, `Stitch` are Operator wrappers that depend on `pipekit.Operator`. They live in `geopatcher.integrations.pipekit` and are gated behind the `[pipekit]` optional extra.
3. **`geopatcher` is sibling-level with `geocatalog` and `pipekit`.** Not a substrate, not a subdivision — peer infrastructure that geotoolz and xr_toolz consume.

## Part 2 — What’s in `geopatcher`

From the rescrape: ~20 files, ~6,800 LOC, fully implemented. **The single biggest module in the entire ecosystem.**

### 2.1 Source layout

|File / dir                   |LOC|Purpose                                                    |
|-----------------------------|---|-----------------------------------------------------------|
|`_src/protocols.py`          |73 |`Field`, `AsyncField`, `Domain` Protocols (the contract)   |
|`_src/domains.py`            |92 |`RasterDomain`, `GridDomain`, `VectorDomain`, `PointDomain`|
|`_src/patch.py`              |71 |`Patch`, `TemporalPatch`, `SpatioTemporalPatch` carriers   |
|`_src/spatial_time.py`       |148|`SpatioTemporalPatcher` (composes spatial × temporal)      |
|`_src/spatial/patcher.py`    |152|`SpatialPatcher`, `AsyncSpatialPatcher`                    |
|`_src/spatial/geometry.py`   |302|`SpatialGeometry` base + 5 concretes                       |
|`_src/spatial/sampler.py`    |363|`SpatialSampler` base + 6 concretes                        |
|`_src/spatial/window.py`     |153|`SpatialWindow` base + 5 concretes                         |
|`_src/spatial/aggregation.py`|663|`SpatialAggregation` base + ~15 concretes                  |
|`_src/time/patcher.py`       |95 |`TemporalPatcher`                                          |
|`_src/time/geometry.py`      |120|`TemporalGeometry` + concretes                             |
|`_src/time/sampler.py`       |141|`TemporalSampler` + concretes                              |
|`_src/time/window.py`        |103|`TemporalWindow` + concretes                               |
|`_src/time/aggregation.py`   |154|`TemporalAggregation` + concretes                          |
|`_src/fields/raster.py`      |86 |`RasterField`, `AsyncRasterField` (georeader bridge)       |
|`_src/fields/xarray.py`      |56 |`XarrayField` (xarray DataArray)                           |
|`_src/fields/rio_xarray.py`  |82 |`RioXarrayField` (rasterio-via-xarray)                     |
|`_src/fields/xvec.py`        |62 |`XvecField` (xvec point cubes)                             |
|`_src/fields/geopandas.py`   |79 |`GeoPandasField` (vector geometries)                       |
|`_src/fields/_extras.py`     |11 |Friendly errors for missing extras                         |
|`_src/ops.py`                |125|**The pipekit-coupled file — moves to `integrations/`**    |

Total: ~3,130 LOC of pure framework + ~365 LOC of Field adapters + 125 LOC of pipekit integration.

### 2.2 The four-axis framework — what it actually contains

**Spatial axes** (~1,500 LOC across 4 files):

|Axis       |Base class          |Concrete classes (sample)                                                                                                                                                                                                                                                                                                   |
|-----------|--------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|Geometry   |`SpatialGeometry`   |`SpatialRectangular`, `SpatialSphericalCap`, `SpatialKNNGraph`, `SpatialRadiusGraph`, `SpatialPolygonIntersection`                                                                                                                                                                                                          |
|Sampler    |`SpatialSampler`    |`SpatialRegularStride`, `SpatialJitteredStride`, `SpatialRandom`, `SpatialPoissonDisk`, `SpatialReservoir`, `SpatialExplicit`                                                                                                                                                                                               |
|Window     |`SpatialWindow`     |`SpatialBoxcar`, `SpatialHann`, `SpatialTukey`, `SpatialGaussian`, `SpatialCustom`                                                                                                                                                                                                                                          |
|Aggregation|`SpatialAggregation`|`SpatialOverlapAdd`, `SpatialMean`, `SpatialWeightedSum`, `SpatialInvVarWeightedMean`, `SpatialHardVote`, `SpatialSoftVote`, `SpatialByIndex`, `SpatialMedian`, `SpatialMode`, `SpatialApproxMode`, `SpatialApproxQuantile`, `SpatialApproxCardinality`, `SpatialStreamingHistogram`, `SpatialLearned`, `SpatialVariance`, …|

**Temporal axes** (~620 LOC):

|Axis       |Base class           |Concrete classes (sample)                                                                                                   |
|-----------|---------------------|----------------------------------------------------------------------------------------------------------------------------|
|Geometry   |`TemporalGeometry`   |`TemporalLookbackHorizon`, `TemporalForecast`, `TemporalPhaseWindow`, `TemporalMultiScale`, `TemporalFold`                  |
|Sampler    |`TemporalSampler`    |`TemporalRegularStride`, `TemporalRandom`, `TemporalEventTriggered`, `TemporalPeriodic`, `TemporalExplicit`                 |
|Window     |`TemporalWindow`     |`TemporalCausalBoxcar`, `TemporalCausalRolling`, `TemporalExponentialDecay`, `TemporalFixedLookback`, `TemporalTaperedTukey`|
|Aggregation|`TemporalAggregation`|`TemporalMean`, `TemporalHierarchicalCombine`                                                                               |

**60+ classes**. The `SpatialAggregation` family alone (663 LOC, ~15 classes) is genuine research-grade work — `OverlapAdd`, `InvVarWeightedMean`, `StreamingHistogram`, `ApproxMode`, `Learned` aren’t textbook; they’re the operator-merge strategies that real sliding-window inference needs.

### 2.3 The Field/Domain Protocol — why this is the key abstraction

The whole framework rests on two tiny Protocols (73 LOC for `protocols.py`):

```python
@runtime_checkable
class Domain(Protocol):
    """Metadata view — bounds, CRS, no I/O."""
    @property
    def crs(self) -> Any: ...
    @property
    def bounds(self) -> Any: ...

@runtime_checkable
class Field(Protocol):
    """A substrate the Patcher reads patches out of."""
    @property
    def domain(self) -> Domain: ...
    def select(self, indexer: Any) -> Any: ...
    def with_data(self, array: Any) -> Any: ...
```

**Six concrete fields already implemented**, each ~60-90 LOC:

|Field             |Wraps                                             |Carrier returned       |Indexer type             |
|------------------|--------------------------------------------------|-----------------------|-------------------------|
|`RasterField`     |`georeader.GeoData` (RasterioReader, GeoTensor, …)|`GeoTensor`            |`rasterio.windows.Window`|
|`AsyncRasterField`|`georeader.AsyncGeoData`                          |`GeoTensor` (awaitable)|`rasterio.windows.Window`|
|`RioXarrayField`  |rioxarray `DataArray`                             |`xarray.DataArray`     |`dict[str, slice]`       |
|`XarrayField`     |`xarray.DataArray`                                |`xarray.DataArray`     |`dict[str, slice]`       |
|`XvecField`       |`xvec.Dataset`                                    |`xarray.Dataset`       |row indices              |
|`GeoPandasField`  |`geopandas.GeoDataFrame`                          |`gpd.GeoDataFrame`     |row indices              |

This is **the duck-typed multi-carrier story already implemented**, before pipekit-array exists, before pipekit exists. The patcher framework doesn’t care what carrier you use; you wrap once at the boundary and the four-axis machinery does the rest.

### 2.4 Public surface

```python
# Protocols (the contract)
from geopatcher import Field, AsyncField, Domain

# Patch carriers (the wire format)
from geopatcher import Patch, TemporalPatch, SpatioTemporalPatch

# Domains
from geopatcher import RasterDomain, GridDomain, VectorDomain, PointDomain

# Patchers (top-level orchestrators)
from geopatcher import (
    SpatialPatcher,
    AsyncSpatialPatcher,
    TemporalPatcher,
    SpatioTemporalPatcher,
)

# Spatial axes
from geopatcher.spatial import (
    # Geometry
    SpatialRectangular, SpatialSphericalCap, SpatialKNNGraph,
    SpatialRadiusGraph, SpatialPolygonIntersection,
    # Sampler
    SpatialRegularStride, SpatialJitteredStride, SpatialRandom,
    SpatialPoissonDisk, SpatialReservoir, SpatialExplicit,
    # Window
    SpatialBoxcar, SpatialHann, SpatialTukey, SpatialGaussian, SpatialCustom,
    # Aggregation
    SpatialOverlapAdd, SpatialMean, SpatialWeightedSum,
    SpatialInvVarWeightedMean, SpatialHardVote, SpatialSoftVote,
    SpatialByIndex, SpatialMedian, SpatialMode, SpatialApproxMode,
    SpatialApproxQuantile, SpatialApproxCardinality,
    SpatialStreamingHistogram, SpatialLearned, SpatialVariance,
    # …
)

# Temporal axes
from geopatcher.time import (
    TemporalRegularStride, TemporalCausalBoxcar, TemporalExponentialDecay,
    TemporalLookbackHorizon, TemporalForecast, TemporalPhaseWindow,
    TemporalPeriodic, TemporalMultiScale, TemporalHierarchicalCombine,
    TemporalEventTriggered, TemporalFold, TemporalRandom,
    TemporalCausalRolling, TemporalFixedLookback, TemporalTaperedTukey,
    TemporalMean,
    # …
)

# Field adapters (extras-gated)
from geopatcher.fields import (
    RasterField, AsyncRasterField,    # [raster] extra
    RioXarrayField,                    # [xarray-raster] extra
    XarrayField,                       # [grid] extra
    XvecField,                         # [point] extra
    GeoPandasField,                    # [vector] extra
)

# Optional pipekit integration (extras-gated)
from geopatcher.integrations.pipekit import (
    GridSampler, ApplyToChips, Stitch,  # requires [pipekit] extra
)
```

## Part 3 — The pipekit integration in detail

The single piece of `geotoolz.patch` that depends on pipekit: `_src/ops.py`, 125 LOC, three Operator wrappers.

### 3.1 What lives here

```python
# geopatcher/integrations/pipekit.py
from pipekit import Operator
from geopatcher import SpatialPatcher, SpatialAggregation, Patch

class GridSampler(Operator):
    """Operator that yields patches from a Field via a SpatialPatcher.
    
    Composes inside Sequential / Graph so a sliding-window inference
    pipeline reads cleanly:
        Sequential([GridSampler(patcher), ApplyToChips(model), Stitch(agg)])
    """

class ApplyToChips(Operator):
    """Operator that applies a chip-op to each patch in an iterable."""

class Stitch(Operator):
    """Operator that merges patches via a SpatialAggregation back to a field."""
```

These three classes are the only thing tying `geopatcher` to `pipekit`. By isolating them in `integrations/pipekit.py` and gating them behind the `[pipekit]` extra, the core patcher framework stays framework-free.

### 3.2 Why this is the right factoring

Three reasons to keep the integration in `geopatcher` (rather than moving it to `geotoolz`):

1. **The classes are about the patcher.** `GridSampler(patcher)` takes a patcher; `Stitch(aggregation)` takes an aggregation. Their natural home is alongside what they’re wrapping.
2. **xr_toolz wants them too.** xr_toolz also has Operator-shaped pipelines that benefit from `GridSampler` / `Stitch` for xarray fields. Putting them in `geopatcher.integrations.pipekit` makes them reachable from both `geotoolz` and `xr_toolz`.
3. **Optional dep stays opt-in.** The user who installs `geopatcher` without `[pipekit]` gets the framework without the wrapper classes — and without pulling in pipekit. The user who wants Operator-graph composition adds `[pipekit]` and gets the wrappers.

### 3.3 Why `integrations/` (plural)

Naming the subpackage `integrations/` (not just `pipekit_ops.py`) signals that **more integrations are possible**:

```
geopatcher/integrations/
├── __init__.py
├── pipekit.py        # GridSampler, ApplyToChips, Stitch
├── pipekit_jax.py    # eventual: JaxGridSampler, JaxApplyToChips, JaxStitch
└── dask.py           # eventual: dask-aware streaming patcher
```

Future integrations (pipekit-jax for vmap-batched patches, dask for distributed streaming) live alongside as sibling modules. The framework stays untouched; integrations are bolted on.

## Part 4 — Dependencies and optional extras

### 4.1 Base install

```toml
[project]
name = "geopatcher"
version = "0.1.0"
dependencies = [
    "numpy>=2.0",
    "scipy>=1.10",       # used by some Window functions (Tukey, Gaussian) and Aggregations
]
```

Base install gives:

- The four-axis framework — Geometry / Sampler / Window / Aggregation, spatial + temporal
- The three patcher orchestrators — `SpatialPatcher`, `TemporalPatcher`, `SpatioTemporalPatcher`
- The four concrete domains — `RasterDomain`, `GridDomain`, `VectorDomain`, `PointDomain`
- The Field / Domain Protocols
- Patch carriers — `Patch`, `TemporalPatch`, `SpatioTemporalPatch`

**No field adapters, no pipekit integration.** The framework works against any user-defined Field; bring your own adapter.

### 4.2 Optional extras

```toml
[project.optional-dependencies]
raster        = ["georeader>=0.4"]                      # RasterField, AsyncRasterField
xarray-raster = ["xarray>=2024.1", "rioxarray>=0.15"]   # RioXarrayField
grid          = ["xarray>=2024.1"]                      # XarrayField (generic xarray)
point         = ["xvec>=0.3", "xarray>=2024.1"]         # XvecField
vector        = ["geopandas>=1.0", "shapely>=2.0"]      # GeoPandasField
pipekit       = ["pipekit>=0.1"]                        # GridSampler, ApplyToChips, Stitch
all           = ["geopatcher[raster,xarray-raster,grid,point,vector,pipekit]"]
```

Use-case-driven install patterns:

|User                           |Install                                           |
|-------------------------------|--------------------------------------------------|
|Researcher patching custom data|`pip install geopatcher` (bring own Field adapter)|
|Raster-only ML inference user  |`pip install geopatcher[raster,pipekit]`          |
|Xarray reanalysis user         |`pip install geopatcher[grid,xarray-raster]`      |
|Vector / station-data user     |`pip install geopatcher[vector,point]`            |
|Full kitchen sink              |`pip install geopatcher[all]`                     |

### 4.3 No `geocatalog` dependency in core

`geopatcher` core does not import `geocatalog`. The bridge works the other direction: `geocatalog` ships a `CatalogDomain` adapter that satisfies `geopatcher.Domain` Protocol (see Report 6 §7). Runtime Protocol satisfaction; no import cycle.

The result: you can use `geopatcher` over your own data without `geocatalog` installed. You can use `geocatalog` to find files without `geopatcher` installed. Compose them when you want both.

## Part 5 — Migration from `geotoolz.patch`

### 5.1 What moves

|Currently                                                    |Becomes                            |
|-------------------------------------------------------------|-----------------------------------|
|`geotoolz.patch.*` (everything except `_src/ops.py`)         |`geopatcher.*`                     |
|`geotoolz.patch._src.protocols.*`                            |`geopatcher._src.protocols.*`      |
|`geotoolz.patch._src.spatial.*`                              |`geopatcher._src.spatial.*`        |
|`geotoolz.patch._src.time.*`                                 |`geopatcher._src.time.*`           |
|`geotoolz.patch._src.fields.*`                               |`geopatcher._src.fields.*`         |
|`geotoolz.patch._src.domains.*`                              |`geopatcher._src.domains.*`        |
|`geotoolz.patch._src.ops.GridSampler / ApplyToChips / Stitch`|`geopatcher.integrations.pipekit.*`|

### 5.2 Backwards compatibility in geotoolz

```python
# geotoolz/__init__.py — re-exports for continuity
from geopatcher import (
    # Protocols
    Field, AsyncField, Domain,
    # Domains
    RasterDomain, GridDomain, VectorDomain, PointDomain,
    # Patch carriers
    Patch, TemporalPatch, SpatioTemporalPatch,
    # Patchers
    SpatialPatcher, AsyncSpatialPatcher,
    TemporalPatcher, SpatioTemporalPatcher,
    # Common shortcuts
    RasterField, AsyncRasterField,
    SpatialRectangular, SpatialRegularStride, SpatialHann, SpatialOverlapAdd,
    # …
)
import geopatcher as patch         # alias so `gz.patch.*` keeps working
import geopatcher.spatial as patch_spatial  # if existing code uses gz.patch.spatial.*
import geopatcher.time as patch_time

# Conditional pipekit integration
try:
    from geopatcher.integrations.pipekit import (
        GridSampler, ApplyToChips, Stitch,
    )
except ImportError:
    pass
```

Existing user code works unchanged:

```python
import geotoolz as gz

patcher = gz.SpatialPatcher(
    geometry=gz.SpatialRectangular((256, 256)),
    sampler=gz.SpatialRegularStride((192, 192)),
    window=gz.SpatialHann(),
    aggregation=gz.SpatialOverlapAdd(),
)
field = gz.RasterField(reader)
for p in patcher.split(field):
    ...
```

The deprecation path is two minor versions of re-exports + `DeprecationWarning`, then removal in v2.0. Encourages users to migrate to `import geopatcher as gp` cleanly.

### 5.3 What stays in `geotoolz`

After the move, **nothing patcher-shaped remains in geotoolz core**. The chip-op variants that compose into pipelines (e.g., a `ChipFilter` operator that wraps a chip-level predicate) stay in `geotoolz` because they’re domain-specific (GeoTensor-aware) and pipekit-shaped.

Sketch:

```python
# geotoolz/patch_ops.py (post-split, ~150 LOC of geotoolz-specific patcher integration)
from pipekit import Operator
from geopatcher import RasterField, SpatialPatcher
import geotoolz as gz

class ReadFromCatalogAsPatches(Operator):
    """Convenience: take a GeoSlice, read with georeader, wrap as RasterField, patch."""
    ...

class GeoTensorChipFilter(Operator):
    """Filter patches by GeoTensor-aware predicate (e.g., cloud fraction)."""
    ...
```

These live in geotoolz because they coordinate three peer libraries (geocatalog + geopatcher + pipekit + georeader). The peer libraries themselves stay decoupled.

## Part 6 — Cross-library composition this enables

### 6.1 Patcher works against xarray data with no glue

```python
import xarray as xr
import geopatcher as gp

ds = xr.open_dataset("reanalysis.nc")
field = gp.XarrayField(ds["sst"])

patcher = gp.SpatialPatcher(
    geometry=gp.SpatialRectangular((32, 32)),
    sampler=gp.SpatialRegularStride((16, 16)),
    window=gp.SpatialBoxcar(),
    aggregation=gp.SpatialMean(),
)
for patch in patcher.split(field):
    # patch.data is an xr.DataArray
    ...
```

Currently this requires importing through `geotoolz.patch.XarrayField`, which is awkward when you’re working purely in xarray land. After the split, xr_toolz can re-export geopatcher symbols natively.

### 6.2 Patcher inside a pipekit Sequential

```python
import pipekit as pk
import geopatcher as gp
from geopatcher.integrations.pipekit import GridSampler, ApplyToChips, Stitch

patcher = gp.SpatialPatcher(
    geometry=gp.SpatialRectangular((256, 256)),
    sampler=gp.SpatialRegularStride((192, 192)),
    window=gp.SpatialHann(),
    aggregation=gp.SpatialOverlapAdd(),
)

pipeline = pk.Sequential([
    GridSampler(patcher),
    ApplyToChips(model_op),
    Stitch(gp.SpatialOverlapAdd()),
])
result = pipeline(field)
```

The same shape works for raster (`RasterField`), xarray grid (`XarrayField`), vector (`GeoPandasField`) — pick the right Field adapter at the boundary.

### 6.3 Catalog → patcher composition via Protocols

```python
import geocatalog as gc
import geopatcher as gp

cat = gc.open_catalog("s3://emit/2024/*.parquet")
dom = gc.CatalogDomain(cat)  # satisfies gp.Domain Protocol

patcher = gp.SpatialPatcher(
    geometry=gp.SpatialPolygonIntersection(aoi),
    sampler=gp.SpatialExplicit(anchors),
    window=gp.SpatialBoxcar(),
    aggregation=gp.SpatialByIndex(),
)

# The patcher walks the catalog via Protocol satisfaction
for patch in patcher.split(dom):
    ...
```

Neither library imports the other. The contract is the `Domain` Protocol. Cross-library composition without coupling.

### 6.4 Future: patcher feeding pipekit-jax

When `pipekit-jax` lands (Report 5), the patcher runs in Python at build time and produces JAX-compatible patches:

```python
import jax.numpy as jnp
import geopatcher as gp
import equinox as eqx
import pipekit_jax as pj

# Build patches eagerly (patcher iteration is Python, not traced)
field = gp.RasterField(gt)
patches = list(spatial_patcher.split(field))
patch_arr = jnp.stack([jnp.asarray(p.data) for p in patches])

# Pipeline is jit-able
@eqx.filter_jit
def process_all(patches):
    return eqx.filter_vmap(jax_pipeline)(patches)

result = process_all(patch_arr)
```

Patcher runs in Python; pipeline runs in JAX. Clean separation, both libraries happy. A future `geopatcher.integrations.pipekit_jax` would wrap this pattern.

## Part 7 — Monorepo development model (patcher-specific notes)

Decision locked in: develop in `pipekit-ecosystem` monorepo with uv/hatch workspaces; publish as separate packages.

### 7.1 Why this works especially well for geopatcher

`geopatcher` has more cross-package interaction surface than `geocatalog`:

- 6 Field adapters, each touching a different optional ecosystem (georeader, xarray, rioxarray, xvec, geopandas)
- 60+ classes that need integration testing across all those backends
- The pipekit integration that needs cross-package test coverage

Monorepo benefits this list directly:

1. **Single integration test suite.** “Does `SpatialOverlapAdd` work on `RasterField(GeoTensor)`, `XarrayField`, `RioXarrayField` all alike?” — one CI matrix in one place.
2. **Shared fixtures.** Test rasters, test xarray datasets, test vector layers — defined once in `shared/fixtures/`, used across all geopatcher Field adapter tests.
3. **Coordinated bumps.** When `xarray` releases a breaking change to `.isel`, `XarrayField` needs updating — the monorepo PR can fix `geopatcher.XarrayField`, update the fixture, and bump the geopatcher version in one commit.
4. **Cross-package types.** When eventually `pipekit-jax` lands, the patcher’s existing types (Patch, Domain, Field) just work — no version-mismatch friction.

### 7.2 Per-package CI

Each package in `packages/` has its own job; an integration job pins all packages to HEAD and runs cross-package tests.

```yaml
# .github/workflows/ci.yml (sketch)
jobs:
  pipekit:           # runs pipekit's tests
    uses: ./shared/ci/python-tests.yml
    with: { package: pipekit }
  geocatalog:        # runs geocatalog's tests
    uses: ./shared/ci/python-tests.yml
    with: { package: geocatalog }
  geopatcher:        # runs geopatcher's tests
    uses: ./shared/ci/python-tests.yml
    with: { package: geopatcher }
  # …
  integration:       # cross-package smoke tests
    needs: [pipekit, geocatalog, geopatcher, geotoolz, xr_toolz]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: astral-sh/setup-uv@v3
      - run: uv sync --all-packages
      - run: pytest tests/integration/
```

### 7.3 Per-package release

Tag `geopatcher-v0.1.0` → CI publishes only `packages/geopatcher` to PyPI. Geotoolz keeps depending on `geopatcher>=0.1,<0.2` until it updates its compat ranges.

## Part 8 — Effort and timing

### 8.1 Effort

The patcher extraction is **slightly more work than the catalog extraction** because of (a) the integration module being a deliberate factoring, and (b) the test surface being broader (6 Field adapters to verify).

- **Day 1**: Set up `packages/geopatcher/` in the monorepo. Move source files (excluding `_src/ops.py`). Set `pyproject.toml` with current deps.
- **Day 2**: Create `geopatcher/integrations/pipekit.py` with the three Operator wrappers from `_src/ops.py`. Gate behind `[pipekit]` extra. Smoke-test.
- **Day 3**: Set `geotoolz` to depend on `geopatcher`; ship backwards-compat re-exports from `geotoolz.patch.*`. Existing geotoolz tests should pass unchanged.
- **Day 4**: Set `xr_toolz` to depend on `geopatcher`; expose patcher symbols natively. Add xr_toolz-specific integration tests.
- **Day 5–6**: Migrate test suite. Most tests move directly; some need fixture path updates.
- **Day 7**: Documentation, cross-linking, migration guide.

**Total: ~1.5 weeks of focused work.**

### 8.2 Timing

Same as `geocatalog`: ship **alongside** the pipekit extraction, not before or after. One coordinated v1.0 reshape of the ecosystem.

The three extractions (pipekit, geocatalog, geopatcher) together take ~3-4 weeks of focused work. Worth investing in once.

### 8.3 What this unblocks

After `geopatcher` is a separate package:

1. **`xr_toolz` adopts patcher natively.** No more “patch lives in geotoolz, awkwardly imported into xr_toolz.” First-class access.
2. **Patcher releases independently.** Phase 2 additions to the Aggregation family, new Field adapters (e.g., `ZarrField` for chunked Zarr datasets), new Sampler strategies all ship without geotoolz coordination.
3. **The pipekit integration is a real artifact** — not 125 lines buried inside geotoolz, but a deliberate, documented, extras-gated module that future contributors can extend.
4. **Future `pipekit-jax` integration is natural.** `geopatcher.integrations.pipekit_jax` slots in alongside `geopatcher.integrations.pipekit` when the JAX library lands.
5. **Bigger discovery surface.** “Sliding-window inference patcher Python” → `geopatcher` is findable on PyPI in its own right. Real outreach value for what’s a sophisticated framework.

## Part 9 — Honest tradeoffs (patcher-specific)

### 9.1 What gets better

1. **The patcher framework gets its own first-class billing.** Currently it’s buried as `geotoolz.patch`; after the split it’s `geopatcher` — the four-axis framework as a peer library.
2. **The Field/Domain Protocol gets visibility.** It’s the most carrier-agnostic piece of the whole ecosystem; surfacing it as `geopatcher.Field` makes its Protocol-shaped contract obvious.
3. **Sophisticated aggregations get their own roadmap.** `SpatialLearned`, `SpatialApproxMode`, `SpatialStreamingHistogram` are real research contributions; releasing them inside `geopatcher` lets them be cited and adopted independently.
4. **Async patcher gets a clean story.** `AsyncSpatialPatcher` + `AsyncRasterField` for remote-tile inference is a natural fit for distributed deployments; keeping it inside geotoolz hides the async story.

### 9.2 What gets worse (and the mitigations)

1. **Tests are bigger than catalog’s.** ~70 classes worth of test surface. Mitigation: most tests move directly; share fixtures across the monorepo; CI matrix is already in place.
2. **More Field adapter extras to coordinate.** Mitigation: each extra is independent (`[raster]` vs `[xarray-raster]` vs `[grid]` etc.); users only install what they need.
3. **Documentation has more surface area.** Mitigation: dedicated docs site (or section of the monorepo docs) for `geopatcher` specifically; the four-axis framework deserves its own tutorial-grade docs anyway.
4. **The pipekit integration risk: people forget to install `[pipekit]`.** Mitigation: clear error message in `geopatcher.integrations.pipekit.__init__` if pipekit is missing, pointing at the install command.

## Recommendation

**Ship `geopatcher` as a standalone package.** The signals are even stronger than for `geocatalog`:

- Much larger size (~6,800 LOC, 60+ classes — the biggest module in the ecosystem)
- More obviously carrier-agnostic (6 Field adapters across 5 ecosystems already)
- Single-file pipekit coupling (125 LOC, easy to factor)
- Genuine research contributions (the Aggregation family) deserving independent visibility
- Multiple future integrations (`pipekit_jax`, `dask`, etc.) fit naturally as `integrations/` siblings
- xr_toolz wants this almost as much as geotoolz does

The pipekit integration becomes `geopatcher.integrations.pipekit` — a 125-LOC extras-gated module. The patcher framework core stays framework-free, depends only on numpy + scipy. Six optional extras for Field adapters; one for pipekit integration.

Monorepo development is the right pattern (shared fixtures, single CI matrix, coordinated cross-package changes). Per-package release tags drive PyPI publishes independently.

The whole thing is a ~1.5-week extraction, done alongside the pipekit and geocatalog extractions as one coordinated v1.0 reshape of the ecosystem.

This is genuinely better infrastructure for everyone — geotoolz users keep their existing code working (via re-exports); xr_toolz users get a first-class patcher; new users find a sophisticated four-axis patcher framework as an independent library; future pipekit-jax / dask integrations slot in cleanly. **Ship it.**