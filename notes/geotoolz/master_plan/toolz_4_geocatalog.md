---
title: "Report 6 — `geocatalog`: standalone spatiotemporal index"
subject: geotoolz master plan
short_title: "R6 — geocatalog"
authors:
  - name: J. Emmanuel Johnson
    affiliations:
      - UNEP
      - IMEO
      - MARS
    orcid: 0000-0002-6739-0053
    email: jemanjohnson34@gmail.com
license: CC-BY-4.0
keywords: geotoolz, geocatalog, spatiotemporal-index, STAC, GeoParquet, GeoSlice
---

# Report 6 — `geocatalog`: standalone spatiotemporal-index package

|                       |                                                                                                                                                                      |
|-----------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|**Status**             |Scoping proposal — committed                                                                                                                                          |
|**Reading time**       |~15 min                                                                                                                                                               |
|**Decisions locked in**|`GeoSlice` lives in `geocatalog` (it’s the catalog’s wire format). The whole ecosystem develops in one monorepo (uv/hatch workspaces), publishes as separate packages.|
|**Audience**           |Anyone reviewing the catalog split before code moves                                                                                                                  |
|**Companion reports**  |Reports 1–5 (pipekit stack), Report 7 (geopatcher)                                                                                                                    |
|**Inputs**             |`jejjohnson/geotoolz` @ main (rescraped 2026-05-16), specifically `geotoolz.catalog` (~3,600 LOC) and `geotoolz.types.GeoSlice` (~200 LOC)                            |

> **STAC background.** For the standards `geocatalog` builds on, see the
> tutorial group: [STAC primer](../tutorials/stac/stac_primer.md),
> [REST API primer](../tutorials/stac/rest_api_primer.md),
> [Storing STAC catalogs](../tutorials/stac/stac_catalog.md) (GeoJSON /
> GeoParquet / PostGIS), [pystac](../tutorials/stac/stac_pystac.md) and
> [rustac](../tutorials/stac/stac_rustac.md) clients, and a
> [curated catalog survey](../tutorials/stac/stac_survey.md).

## Part 1 — Where `geocatalog` sits in the stack

The full ecosystem after all proposed splits:

```
   ┌──────────────────────────────────────────────────────────┐
   │ georeader  (GeoTensor, GeoData Protocol, RasterioReader, │
   │             AsyncGeoTIFFReader — the I/O substrate)      │
   └──────────────────────────────────────────────────────────┘
                                ▲
              ┌─────────────────┼─────────────────┐
              │                 │                 │
   ┌──────────┴───────┐  ┌──────┴──────┐  ┌──────┴──────────┐
   │   geocatalog     │  │   pipekit   │  │   geopatcher    │
   │  (this report)   │  │  (framework)│  │ (sibling report)│
   │  — GeoSlice      │  │             │  │  — Field /      │
   │  — GeoCatalog    │  │             │  │    Domain       │
   │  — backends      │  │             │  │  — Patchers     │
   │  — builders      │  │             │  │  — Aggregations │
   │  — loaders       │  │             │  │                 │
   └──────────────────┘  └─────────────┘  └─────────────────┘
              ▲                 ▲                 ▲
              └─────────────────┼─────────────────┘
                                │
              ┌─────────────────┴─────────────────┐
              │           geotoolz                │
              │   (GeoTensor domain operators:    │
              │   radiometry, indices, cloud,     │
              │   spectral, viz, plume, readers,  │
              │   presets, …)                     │
              │                                   │
              │   Also: xr_toolz on the           │
              │   xarray-flavoured side           │
              └───────────────────────────────────┘
```

Three observations from this picture:

1. **`geocatalog` sits at the same level as `pipekit` and `geopatcher`.** None depend on each other. All three sit above `georeader` (catalog uses `GeoTensor` as one of several loader return types; patcher uses `GeoData` Protocol via `RasterField`). All three are consumed by `geotoolz` and `xr_toolz`.
2. **`geocatalog` is a peer library, not a framework subdivision.** It owns the spatiotemporal-index domain end-to-end: Protocol, backends, builders, loaders, set algebra, GeoParquet round-trip.
3. **`georeader` is the substrate.** Catalog’s loaders return `GeoTensor` (raster path); patcher’s `RasterField` wraps any `GeoData`. `geocatalog` and `geopatcher` are both georeader consumers, not georeader replacements.

## Part 2 — What’s in `geocatalog`

From the rescrape: 11 files, ~3,600 LOC, fully implemented Phase 1 + part of Phase 2.

### 2.1 Source layout

|File                    |LOC |Purpose                                                        |
|------------------------|----|---------------------------------------------------------------|
|`_src/base.py`          |236 |`CatalogRow`, `GeoCatalog` Protocol                            |
|`_src/slice.py`         |~200|`GeoSlice` (moves here from `geotoolz.types`)                  |
|`_src/memory.py`        |378 |`InMemoryGeoCatalog` — GeoDataFrame + R-tree + IntervalIndex   |
|`_src/duckdb_backend.py`|803 |`DuckDBGeoCatalog` — lazy SQL over GeoParquet 1.1              |
|`_src/raster.py`        |444 |`build_raster_catalog`, `load_raster`, `load_raster_timeseries`|
|`_src/xarray_backend.py`|377 |`build_xarray_catalog`, `load_xarray`                          |
|`_src/vector.py`        |414 |`build_vector_catalog`, `load_vector`                          |
|`_src/streaming.py`     |626 |Streaming-write infrastructure for large catalogs              |
|`_src/parquet.py`       |112 |`to_geoparquet` / `from_geoparquet` round-trip                 |
|`_src/ops.py`           |103 |`query`, `intersect`, `union` set algebra                      |
|`_src/domain.py`        |109 |`CatalogDomain` adapter (bridges to `geopatcher`)              |

### 2.2 Public surface

```python
# Core
from geocatalog import (
    GeoCatalog,       # Protocol
    CatalogRow,       # backend-neutral row view
    GeoSlice,         # bounded request for data
)

# Backends
from geocatalog import (
    InMemoryGeoCatalog,   # GeoDataFrame backend, Phase 1
    DuckDBGeoCatalog,     # SQL backend, Phase 2 (extras-gated)
)

# Factory
from geocatalog import open_catalog  # picks a backend for a GeoParquet artifact

# Builders (extras-gated by carrier)
from geocatalog import (
    build_raster_catalog,
    build_xarray_catalog,
    build_vector_catalog,
)

# Loaders (extras-gated by carrier)
from geocatalog import (
    load_raster,
    load_raster_timeseries,
    load_xarray,
    load_vector,
)

# Set algebra
from geocatalog import query, intersect, union

# Artifact round-trip
from geocatalog import to_geoparquet, from_geoparquet

# Patcher bridge
from geocatalog import CatalogDomain  # adapter for geopatcher.SpatialPatcher
```

### 2.3 Why `GeoSlice` lives here

`GeoSlice` is **the catalog’s wire format** — the bounded request for data that catalogs produce and loaders consume. The dataclass header in the current code is explicit: “the unit of work between catalog, sampler, loader, operator.”

Three reasons it belongs in `geocatalog`:

1. **Catalog is the primary producer.** `catalog.iter_slices()` returns `Iterator[GeoSlice]`. The shape and semantics of `GeoSlice` are determined by what the catalog can answer about.
2. **Patcher doesn’t use `GeoSlice` directly.** The patcher’s wire format is `Patch` (data + anchor + neighborhood), not `GeoSlice` (bounded request). Different abstraction, different package.
3. **Splitting it out would over-engineer.** A 200-LOC frozen dataclass with five accessor properties doesn’t justify its own package.

Consumers of `GeoSlice`:

|Consumer           |Imports as                                                                                                     |
|-------------------|---------------------------------------------------------------------------------------------------------------|
|`geocatalog` (self)|`from geocatalog._src.slice import GeoSlice`                                                                   |
|`geotoolz`         |`from geocatalog import GeoSlice` (used in catalog-aware operators, samplers, the `CatalogPipeline` ETL driver)|
|`xr_toolz`         |`from geocatalog import GeoSlice` (used in catalog-aware xarray loaders)                                       |
|`geopatcher`       |does NOT import `GeoSlice` — uses `Patch`                                                                      |
|User code          |`from geocatalog import GeoSlice`                                                                              |

### 2.4 Why the loaders live here, not in `georeader` or `geotoolz`

The loaders (`load_raster`, `load_xarray`, `load_vector`) consume a `GeoSlice` and return a backend-specific carrier (`GeoTensor`, `xr.Dataset`, `gpd.GeoDataFrame`). They’re catalog-shaped functions that happen to call out to the I/O substrate.

Two reasons they live in `geocatalog`:

1. **They’re catalog API.** The natural pattern is `catalog.iter_slices(...)` → `load_raster(slice, reader_cls=...)`. The catalog produces the slices; the catalog ships the loaders.
2. **They keep the I/O substrate (`georeader`) independent.** `georeader` is a reader / writer / `GeoTensor` library. It doesn’t know about catalogs. Putting catalog-aware loaders in `geocatalog` keeps the substrate clean.

The loaders are **extras-gated** so users who only want the index don’t pull in heavy I/O dependencies. See §3.

## Part 3 — Dependencies and optional extras

### 3.1 Base install

```toml
[project]
name = "geocatalog"
version = "0.1.0"
dependencies = [
    "pandas>=2.0",
    "geopandas>=1.0",
    "pyproj>=3.6",
    "shapely>=2.0",
    "rasterio>=1.4",        # GeoSlice uses rasterio.Affine + rasterio.windows
]
```

Base install gives:

- `GeoCatalog` Protocol, `CatalogRow`, `GeoSlice`
- `InMemoryGeoCatalog` (GeoDataFrame-backed)
- Set algebra (`query`, `intersect`, `union`)
- `to_geoparquet` / `from_geoparquet`
- `CatalogDomain` (the patcher bridge — Protocol-shaped, no patcher import)

No loaders, no DuckDB backend. The index works; you bring your own reader.

### 3.2 Optional extras

```toml
[project.optional-dependencies]
duckdb   = ["duckdb>=1.0"]                          # DuckDBGeoCatalog
raster   = ["georeader>=0.4"]                       # build_raster_catalog, load_raster, load_raster_timeseries
xarray   = ["xarray>=2024.1", "rioxarray>=0.15"]    # build_xarray_catalog, load_xarray
vector   = ["pyogrio>=0.8"]                         # build_vector_catalog, load_vector
streaming = ["pyarrow>=17.0"]                       # streaming-write infrastructure
all      = ["geocatalog[duckdb,raster,xarray,vector,streaming]"]
```

The patterns this enables:

- **Someone who only needs the index over their own files**: `pip install geocatalog`. ~5 MB install. No GDAL, no rasterio overhead beyond what shapely already needs.
- **Operational MARS ETL**: `pip install geocatalog[duckdb,raster,streaming]`. Big catalogs over remote GeoParquet, raster loaders, streaming writes.
- **Xarray climate workflows**: `pip install geocatalog[xarray]`. Catalogs over reanalysis NetCDFs.
- **Vector / GIS workflows**: `pip install geocatalog[vector]`. Catalogs over GeoJSON, FlatGeobuf, layered GeoPackages.

### 3.3 No pipekit dependency

`geocatalog` does not import from `pipekit`. The catalog isn’t an `Operator`; it’s a queryable index. The framework-vs-data-source distinction is clean:

- **`pipekit`** says how to compose operators that transform a carrier
- **`geocatalog`** says how to find which files match a spatiotemporal query

These are orthogonal concerns. A user can `from geocatalog import open_catalog` without ever using pipekit. A pipekit pipeline can read from a non-catalog source. The two compose at the application layer (in `geotoolz` and `xr_toolz`), not at the library layer.

### 3.4 The `CatalogDomain` patcher bridge — important detail

`CatalogDomain` (109 LOC) is an adapter that lets a `geopatcher.SpatialPatcher` iterate over a catalog’s rows. It satisfies `geopatcher.Domain` Protocol (`crs`, `bounds`) — but **does not import `geopatcher`**. It implements the Protocol structurally; `geopatcher` only knows about it via Protocol satisfaction at runtime.

This is the right factoring. `geocatalog` produces something that quacks like a `Domain`; `geopatcher` accepts anything that quacks like a `Domain`. No import either direction.

## Part 4 — Migration from `geotoolz.catalog`

### 4.1 What moves

|Currently                |Becomes                          |
|-------------------------|---------------------------------|
|`geotoolz.catalog.*`     |`geocatalog.*`                   |
|`geotoolz.catalog._src.*`|`geocatalog._src.*`              |
|`geotoolz.types.GeoSlice`|`geocatalog.GeoSlice` (canonical)|

### 4.2 Backwards compatibility in geotoolz

`geotoolz` re-exports for transitional compatibility:

```python
# geotoolz/__init__.py
from geocatalog import (
    GeoCatalog,
    CatalogRow,
    InMemoryGeoCatalog,
    DuckDBGeoCatalog,
    GeoSlice,
    open_catalog,
    build_raster_catalog,
    build_raster_timeseries,
    load_raster,
    load_raster_timeseries,
    query,
    intersect,
    union,
    to_geoparquet,
    from_geoparquet,
    CatalogDomain,
)
import geocatalog as catalog   # alias so `gz.catalog.*` keeps working

# geotoolz/types/__init__.py
# Keep GeoSlice re-export here too so old `from geotoolz.types import GeoSlice` works
from geocatalog import GeoSlice
```

Existing user code works unchanged:

```python
import geotoolz as gz
cat = gz.open_catalog("s3://bucket/scenes.parquet")
for sl in cat.iter_slices(...):
    gt = gz.load_raster(sl)
```

Plan: ship the re-exports for two minor versions (v1.1, v1.2), then deprecate with a `DeprecationWarning`, remove in v2.0. Users who follow the deprecation cleanly migrate `from geotoolz.catalog import ...` → `from geocatalog import ...`.

### 4.3 What stays in `geotoolz`

After the move, `geotoolz.catalog` keeps **only** the catalog-aware operators that compose into pipekit pipelines — `CatalogPipeline` for ETL, `CatalogReader` for inline reads, etc. These depend on both `geocatalog` and `pipekit`, so they belong in the consumer (`geotoolz`), not the substrate (`geocatalog`).

Sketch:

```python
# geotoolz/catalog_ops.py (NEW, ~200 LOC)
from pipekit import Operator
from geocatalog import GeoCatalog, GeoSlice
import georeader

class CatalogPipeline(Operator):
    """ETL driver: iterate a catalog, apply an op to each scene, optionally parallel."""
    def __init__(self, catalog: GeoCatalog, op: Operator, *, n_workers: int = 1, ...):
        ...

class CatalogReader(Operator):
    """Read a single GeoSlice into a GeoTensor inline in a Sequential."""
    def __init__(self, reader_cls=None):
        ...
```

The `Operator`-shaped wrappers stay in `geotoolz` because they require both `pipekit` and `geocatalog`. Putting them in `geocatalog` would force a pipekit dep on every catalog user — wrong shape.

## Part 5 — Cross-library composition this enables

### 5.1 Same catalog, multiple consumer libraries

```python
# Build once
import geocatalog as gc
cat = gc.build_raster_catalog("s3://emit/2024/*.nc")

# Use from geotoolz
import geotoolz as gz
for sl in cat.iter_slices(bounds=aoi, time=(t0, t1)):
    gt = gc.load_raster(sl)
    result = gz.methane_pipeline(gt)
    # ...

# Use from xr_toolz
import xr_toolz as xrt
for sl in cat.iter_slices(bounds=aoi, time=(t0, t1)):
    ds = gc.load_xarray(sl)
    result = xrt.skill_score_pipeline(ds)
    # ...
```

Currently impossible — catalog is locked inside `geotoolz`, so xr_toolz can’t reach it without weird imports. After the split, the same catalog object feeds either domain library.

### 5.2 Catalog → patcher chains

```python
import geocatalog as gc
import geopatcher as gp

# Catalog drives the iteration; patcher drives the per-scene slicing
for sl in cat.iter_slices(...):
    gt = gc.load_raster(sl)
    field = gp.RasterField(gt)
    for patch in gp.SpatialPatcher(
        geometry=gp.SpatialRectangular((256, 256)),
        sampler=gp.SpatialRegularStride((224, 224)),
    ).split(field):
        # process each 256×256 patch
        ...
```

Both libraries are infrastructure-level; geotoolz is the consumer that ties them together.

### 5.3 Catalog over xarray data, processed with pipekit

```python
import geocatalog as gc
import pipekit as pk
import xr_toolz as xrt

cat = gc.build_xarray_catalog("s3://reanalysis/era5/")
pipeline = pk.Sequential([
    xrt.validation.ValidateCoords(),
    xrt.detrend.RemoveClimatology(clim),
    xrt.metrics.RMSE(reference=ref),
])

for sl in cat.iter_slices(bounds=aoi, time=(t0, t1)):
    ds = gc.load_xarray(sl)
    score = pipeline(ds)
```

The lego pieces compose because they all sit at peer-library levels, not inside one monolith.

## Part 6 — Monorepo development model

Decision: **develop in a single `pipekit-ecosystem` monorepo with uv / hatch workspaces; publish as separate packages.**

### 6.1 Why this works for `geocatalog` specifically

1. **Cross-package changes during early development are common.** Adding a new `CatalogRow` field affects all backends, all loaders, all geotoolz consumers. One PR is much easier than three coordinated PRs.
2. **`GeoSlice` evolution is rare but cross-cutting.** When `GeoSlice` grows (e.g., add `target_dtype`), it ripples through every loader and every consumer. Monorepo PR > three-way release dance.
3. **Shared test infrastructure.** Catalog tests want a small sample of raster fixtures, xarray fixtures, vector fixtures. Sharing fixtures across packages (catalog + patcher + geotoolz) avoids triplication.
4. **CI runs the integration matrix in one place.** A monorepo CI can verify “geocatalog 0.2 + geotoolz 0.5 + xr_toolz 0.3 still works together” automatically.

### 6.2 Layout

```
pipekit-ecosystem/                # monorepo root
├── pyproject.toml                # workspace config
├── packages/
│   ├── pipekit/
│   │   ├── pyproject.toml
│   │   └── src/pipekit/...
│   ├── pipekit-array/
│   │   ├── pyproject.toml
│   │   └── src/pipekit_array/...
│   ├── geocatalog/               # ← this report
│   │   ├── pyproject.toml
│   │   └── src/geocatalog/...
│   ├── geopatcher/               # ← Report 7
│   │   ├── pyproject.toml
│   │   └── src/geopatcher/...
│   ├── geotoolz/
│   │   ├── pyproject.toml
│   │   └── src/geotoolz/...
│   └── xr_toolz/
│       ├── pyproject.toml
│       └── src/xr_toolz/...
├── shared/
│   ├── fixtures/                 # cross-package test fixtures
│   └── ci/                       # reusable GH Actions workflows
└── docs/                         # one Sphinx site spanning everything
```

### 6.3 Operational pattern

- **Develop locally** with `uv sync` resolving cross-package deps to the local workspace paths. Cross-package edits work without `pip install -e` dance.
- **CI** matrix: each package gets its own job + an integration job that pins all packages to their HEAD and runs end-to-end tests.
- **Release per-package** independently. Each `packages/*/pyproject.toml` carries its own version. Tags like `geocatalog-v0.2.0` trigger publish for that package only.
- **Pinned cross-package versions** in published metadata: `geotoolz==0.5.x` declares `geocatalog>=0.2,<0.3`, `geopatcher>=0.1,<0.2`. Users who install only `geotoolz` get the right pinned versions automatically.

This is the same pattern as `huggingface_hub` / `transformers` / `datasets`, `xarray` / `xarray-spatial` / `xvec`, `jax` / `flax` / `optax` / `equinox`, and many others. Well-trodden.

## Part 7 — The `CatalogDomain` ↔ `geopatcher.Domain` bridge in detail

Worth dwelling on because it’s the cleanest example of the Protocol-based decoupling that makes the whole split work.

### 7.1 What `CatalogDomain` is

A small adapter (109 LOC) that wraps a `GeoCatalog` and exposes the `geopatcher.Domain` Protocol (`crs`, `bounds`, plus a method for getting the relevant rows).

```python
# In geocatalog._src.domain
from typing import Protocol

class _DomainProtocol(Protocol):
    """Structural type matching geopatcher.Domain, redeclared locally."""
    @property
    def crs(self) -> Any: ...
    @property
    def bounds(self) -> Any: ...

class CatalogDomain:
    """A catalog presented as a Domain for the patcher to walk."""
    def __init__(self, catalog: GeoCatalog):
        self.catalog = catalog
    
    @property
    def crs(self):
        return self.catalog.crs
    
    @property
    def bounds(self):
        return self.catalog.bounds
    
    def rows_for(self, anchor) -> Iterator[CatalogRow]:
        return self.catalog.query(...)
```

### 7.2 Why this works without imports

`geopatcher.Domain` is a `runtime_checkable Protocol`. `CatalogDomain` doesn’t inherit from it — it just happens to have the right shape. `geopatcher` accepts any `Domain`-shaped thing at runtime via `isinstance(x, Domain)`.

Result: `geocatalog` doesn’t import `geopatcher`; `geopatcher` doesn’t import `geocatalog`. The Protocol is the contract.

### 7.3 The user-facing pattern

```python
import geocatalog as gc
import geopatcher as gp

cat = gc.open_catalog("...")
dom = gc.CatalogDomain(cat)

# The patcher walks the catalog via the Domain Protocol
patcher = gp.SpatialPatcher(
    geometry=gp.SpatialPolygonIntersection(...),
    sampler=gp.SpatialExplicit(...),
)
for patch in patcher.split(dom):
    # patch.data is loaded on-demand via the catalog's loader
    ...
```

Catalog-driven iteration meets patch-driven iteration. The two libraries co-design via Protocol, not via shared imports.

## Part 8 — Effort and timing

### 8.1 Effort

- **Day 1**: Set up `packages/geocatalog/` in the monorepo. Move source files. Set `pyproject.toml` with current Phase 1 deps.
- **Day 2**: Move `GeoSlice` from `geotoolz.types` → `geocatalog._src.slice`. Update intra-catalog imports. Set up extras-gated re-exports.
- **Day 3**: Set `geotoolz` to depend on `geocatalog`; ship backwards-compat re-exports from `geotoolz.catalog.*` and `geotoolz.types.GeoSlice`. Run existing geotoolz test suite — it should pass unchanged.
- **Day 4**: Set `xr_toolz` to depend on `geocatalog`; expose `xr_toolz.catalog_ops.*` for xarray-flavoured catalog ops if not already there.
- **Day 5**: Set up CI per-package + integration. Write migration guide. Cross-link docs.

**Total: ~1 week of focused work.**

### 8.2 Timing

Do this **alongside the pipekit extraction**, not before or after.

Reasoning: both refactors touch `geotoolz/__init__.py`. Doing them in one combined PR (pipekit extraction + geocatalog extraction + geopatcher extraction) means **one breaking change for users to absorb**, not three. The deprecation banner says “v1.0 reshaped the ecosystem; here’s the migration guide” once.

### 8.3 What this unblocks

After `geocatalog` is a separate package:

1. **`xr_toolz` can adopt catalog natively** without weird cross-imports from geotoolz.
2. **`pipekit-jax` (future) can build JAX-traceable catalog drivers** by depending on geocatalog directly.
3. **The patcher’s `CatalogDomain` bridge becomes meaningful** — currently it’s an `geotoolz.catalog._src.domain` artifact; after the split it’s a proper cross-package Protocol contract.
4. **Catalog releases independently.** Phase 2 DuckDB work, GeoParquet 1.1 spec updates, streaming improvements all ship without coordinating with geotoolz’s release cycle.

## Part 9 — Honest tradeoffs (catalog-specific)

### 9.1 What gets better

1. **Catalog discoverability.** Right now someone searching PyPI for “spatiotemporal catalog python” doesn’t find `geotoolz.catalog`. They’d find `geocatalog`. Real outreach win.
2. **Minimal install for narrow use cases.** A user who wants only the index doesn’t pull in georeader / rasterio / GDAL.
3. **`GeoSlice` becomes a meaningful cross-library type.** Currently it’s “that thing in `geotoolz.types`”; after the split it’s `geocatalog.GeoSlice`, the catalog’s wire format, importable in any consumer.
4. **Phase 2 (DuckDB / GeoParquet 1.1) work** can land in `geocatalog` without bumping geotoolz.

### 9.2 What gets worse (and the mitigations)

1. **One more package to release.** Mitigation: monorepo + per-package release tags; the operational overhead is one `git tag geocatalog-v0.2.0`-style command.
2. **Version pinning between geocatalog and geotoolz.** Mitigation: geotoolz declares `geocatalog>=0.2,<0.3` ranges; users get correct combos automatically.
3. **Documentation has to live somewhere.** Mitigation: one Sphinx site at the monorepo level with sections for each package, OR mkdocs per-package with cross-links. Either works.
4. **The `CatalogDomain` Protocol bridge is implicit.** Mitigation: a one-paragraph note in geocatalog’s docs pointing at geopatcher’s Domain Protocol with examples.

## Recommendation

**Ship `geocatalog` as a standalone package.** It satisfies every signal for warranting one:

- Self-contained scope (own Phase 1 / Phase 2 design at `notes/geotoolz/plans/geodatabase/`)
- Real size (~3,600 LOC)
- Already carrier-neutral (works with raster, xarray, vector loaders)
- No pipekit dependency (it’s not an Operator-shaped library; it’s a data-source-shaped library)
- Cross-library value (xr_toolz, future pipekit-jax both benefit)
- Independent backend evolution (InMemory + DuckDB + future Postgres-PostGIS?)

`GeoSlice` lives in `geocatalog` — it’s the catalog’s wire format, full stop.

Monorepo development is fine — it’s the standard pattern, well-supported by uv / hatch.

The whole thing is a one-week extraction job, done alongside the pipekit + geopatcher extractions as one coordinated v1.0 release.