---
title: "STAC + pystac — the classic Python client in the GeoStack"
subject: geotoolz tutorial
short_title: "pystac"
authors:
  - name: J. Emmanuel Johnson
    affiliations:
      - UNEP
      - IMEO
      - MARS
    orcid: 0000-0002-6739-0053
    email: jemanjohnson34@gmail.com
license: CC-BY-4.0
keywords: tutorial, STAC, pystac, Python, geocatalog
---

# Background: STAC, pystac, and where the classic Python client fits in the GeoStack

## What STAC is, and why it matters

**STAC** (SpatioTemporal Asset Catalog) is a small, deliberately boring JSON specification for describing geospatial assets — satellite scenes, derived products, model outputs, whatever — in a way that’s identical across providers. Three nested objects do all the work: a **Catalog** points to **Collections**, each Collection holds a set of **Items**, and each Item is a GeoJSON Feature whose `assets` field lists the actual files (COGs, NetCDFs, Zarrs) with hrefs and roles. A **STAC API** is just a STAC catalog served over HTTP with a `/search` endpoint that supports filtering by bbox, datetime, collection, and CQL2 property expressions.

The reason STAC matters operationally is that it collapses what used to be N bespoke search clients — one per DAAC, per ESA hub, per commercial provider — into one pattern. Search Sentinel-2 from Element 84, search EMIT methane from NASA, search EnMAP from DLR, search Planetary Computer’s full archive: same query shape, same response shape, same downstream code. The auth and the bucket backends still differ (and that’s exactly what these recipes wrestle with), but the catalog interface is uniform.

For scientific ML workflows the practical upshot is that **STAC is the metadata layer that lets you decouple “which scenes do I want?” from “how do I read pixels?”**. You can build the scene list once, persist it, and then re-run the array loading step many times against the same frozen set of items — important for reproducibility and for the inference→retrain cycles common in plume / retrieval work.

## What pystac and pystac-client are

**pystac** is the canonical Python implementation of the STAC object model. It gives you Python classes — `Catalog`, `Collection`, `Item`, `Asset`, `ItemCollection` — that wrap the underlying JSON with type hints, validation, link resolution, and helpers (CRS lookups, bbox geometry, extension accessors for `eo`, `proj`, `raster`, `sat`, `view`, etc.). If rustac is “metadata Arrow with a Rust hot path,” pystac is “STAC as living Python objects you can introspect and modify.”

**pystac-client** is the companion library that speaks the STAC API protocol. It handles the HTTP for `/collections`, `/search`, conformance discovery, automatic pagination, CQL2 filter encoding, and request signing. It’s what 95% of users actually import day-to-day. The typical entrypoint is one line:

```python
catalog = pystac_client.Client.open("https://...stac.../v1")
```

and from there you call `catalog.search(...)` which returns an `ItemSearch`. The search is **lazy** — no HTTP request fires until you iterate items via `search.items()`, materialize them via `search.item_collection()`, or count them via `search.matched()`. Pagination is transparent: `for item in search.items()` walks through every page until it hits the result limit.

These libraries have been the reference Python STAC implementation since 2018; the entire ecosystem (stackstac, odc-stac, planetary-computer, sat-search and so on) sits on top of them.

## Why pystac is synchronous (and when that bites)

Unlike rustac, **pystac and pystac-client are synchronous**. There’s no `async`/`await`; calls block until the HTTP round-trip returns. This is the right default for most interactive work — Jupyter cells, scripts, debugging in a REPL — because it’s simpler: results come back from a function call, exceptions propagate normally, no event loop to think about.

The cost shows up at scale. A search that paginates through 50 pages of results does 50 sequential HTTP requests; on a 200 ms-latency link that’s 10 seconds of mostly-idle waiting. rustac issues those requests concurrently on a tokio runtime and gets it done in 1–2 seconds. For typical exploratory queries (hundreds to low thousands of items) this gap is invisible; for catalog-spanning queries (50k+ items) it’s the reason rustac exists.

The mitigations within pystac-client are mostly knobs that change how much you fetch:

- `max_items=` caps the total result count up front.
- `limit=` controls per-page size (most APIs cap this at 100–1000).
- The `pgstac` extension on some APIs supports token-based pagination that’s slightly faster than offset pagination.

For asset I/O (the second I/O-heavy step), pystac itself doesn’t load bytes — it hands you hrefs and you choose the loader. rasterio, rioxarray, stackstac, odc-stac, fsspec, obstore are all options, and **all of those can be made concurrent independent of pystac** (Dask parallelism in stackstac, asyncio in obstore, ThreadPoolExecutor by hand). So the sync-vs-async distinction really only constrains the search step, not the array loading.

## Where pystac sits in the GeoStack

```
                          ┌──────────────────────────────────────────┐
                          │              SCIENCE / ML LAYER          │
                          │   JAX  ·  PyTorch  ·  scikit-learn       │
                          │   plumax  ·  somax  ·  gpyroX  ·  gaussx │
                          └──────────────────▲───────────────────────┘
                                             │  jnp.ndarray / tensors
                          ┌──────────────────┴───────────────────────┐
                          │            ARRAY / LABELED-ARRAY         │
                          │     xarray  ·  rioxarray  ·  dask        │
                          │     odc-stac  ·  stackstac  ·  zarr      │
                          └──────────────────▲───────────────────────┘
                                             │  lazy dask-backed DataArrays
                          ┌──────────────────┴───────────────────────┐
                          │              RASTER I/O                  │
                          │   rasterio (GDAL)  ·  kerchunk  ·  h5py  │
                          └──────────────────▲───────────────────────┘
                                             │  byte streams / file handles
                          ┌──────────────────┴───────────────────────┐
                          │           OBJECT-STORE LAYER             │
                          │   fsspec   ·   obstore                   │
                          │   (S3 / Azure / GCS / HTTPS, with auth)  │
                          └──────────────────▲───────────────────────┘
                                             │  signed hrefs / credentials
                          ┌──────────────────┴───────────────────────┐
                          │       CATALOG / METADATA LAYER           │
                          │   pystac  ·  pystac-client               │
                          │   (planetary-computer signing modifier)  │
                          │   stac-geoparquet (optional sidecar)     │
                          └──────────────────▲───────────────────────┘
                                             │  STAC API HTTP queries
                          ┌──────────────────┴───────────────────────┐
                          │              STAC API LAYER              │
                          │   Planetary Computer  ·  Earth Search    │
                          │   CMR-STAC (EMIT)     ·  CDSE STAC       │
                          │   DLR Geoservice (EnMAP)  ·  ...         │
                          └──────────────────────────────────────────┘
```

Each layer is replaceable. You can swap pystac-client for rustac at the catalog layer without touching the array layer; you can swap fsspec for obstore without touching the science layer. The job of the recipes below is to wire up the bottom three layers correctly for each provider — once that’s done, everything above is the same code regardless of where the data came from.

A useful mental model: **pystac-client picks the scenes, fsspec/obstore move the bytes, rioxarray/xarray shape them into labeled arrays, and JAX does the math.** Compared to the rustac path: same shape, fewer awaits, items come back as rich Python objects you can introspect with `item.assets["B04"].extra_fields` rather than dict lookups.

-----

# pystac + obstore/fsspec: per-catalog recipes

Each recipe follows the same three-stage pattern:

1. **Search** the STAC catalog with `pystac-client` → an `ItemSearch`, iterated to get `pystac.Item` objects
2. **Build an obstore (or fsspec) store** with the right credentials for that provider’s blob backend (or for some providers, let pystac sign hrefs directly)
3. **Hand off** the signed/auth’d asset hrefs to rioxarray / odc-stac / xarray for array loading

Common imports across all recipes:

```python
import pystac_client
import pystac
import obstore
from obstore.store import S3Store, AzureStore
```

-----

## 1. Microsoft Planetary Computer

**Search endpoint:** `https://planetarycomputer.microsoft.com/api/stac/v1` (public)
**Asset backend:** Azure Blob Storage, requires SAS-token signing per-asset
**Region constraint:** None for browsing; cheaper if you compute in West Europe / East US

The idiomatic pystac pattern for PC is **the `modifier` argument on `Client.open`**, which signs every Item as it comes back from the API. This is cleaner than building an obstore credential provider for most use cases.

```python
import planetary_computer
import pystac_client

# 1. Open the catalog with the auto-signing modifier
catalog = pystac_client.Client.open(
    "https://planetarycomputer.microsoft.com/api/stac/v1",
    modifier=planetary_computer.sign_inplace,
)

# 2. Search — returns an ItemSearch (lazy, no HTTP yet)
search = catalog.search(
    collections=["sentinel-2-l2a"],
    bbox=[-122.5, 37.5, -122.0, 38.0],
    datetime="2024-06-01/2024-06-30",
    query={"eo:cloud_cover": {"lt": 20}},
    max_items=200,
)

# 3. Materialize — these are all real HTTP calls
matched_count = search.matched()              # int, total available
items = list(search.items())                  # list[pystac.Item], paginated
item_collection = search.item_collection()    # pystac.ItemCollection

# Persist as JSON (canonical pystac format)
item_collection.save_object("data/s2_sf.json")

# Persist as stac-geoparquet (optional sidecar package, not native to pystac)
import stac_geoparquet
stac_geoparquet.arrow.to_parquet(
    stac_geoparquet.arrow.parse_stac_items_to_arrow(items),
    "data/s2_sf.parquet",
)

# 4. Hrefs are already SAS-signed thanks to the modifier — hand directly to rioxarray
import rioxarray
item = items[0]
da_red = rioxarray.open_rasterio(item.assets["B04"].href, chunks=True)
da_nir = rioxarray.open_rasterio(item.assets["B08"].href, chunks=True)

# Or use obstore for byte-level control (alternative to the modifier)
from obstore.auth.planetary_computer import PlanetaryComputerCredentialProvider
asset = item.assets["B04"]
cp = PlanetaryComputerCredentialProvider.from_asset(asset)
store = AzureStore(
    account_name="sentinel2l2a01",
    container_name="sentinel2-l2",
    credential_provider=cp,
)
data = obstore.get(store, "path/within/container/B04.tif")
```

**When to use which signing path:** the `modifier=` argument is the simplest and what odc-stac/stackstac integrations expect. The obstore `PlanetaryComputerCredentialProvider` is preferable when you want explicit byte-range streaming, or when running outside the rioxarray ecosystem (e.g., feeding raw bytes into a custom decoder).

-----

## 2. Element 84 Earth Search (AWS Open Data)

**Search endpoint:** `https://earth-search.aws.element84.com/v1` (public)
**Asset backend:** S3 (us-west-2, public buckets like `sentinel-cogs`, `usgs-landsat`)
**Region constraint:** Free egress from us-west-2; otherwise standard S3 egress costs

```python
import pystac_client
import rioxarray

# 1. Open + search — fully public
catalog = pystac_client.Client.open(
    "https://earth-search.aws.element84.com/v1"
)

search = catalog.search(
    collections=["sentinel-2-l2a"],
    bbox=[-122.5, 37.5, -122.0, 38.0],
    datetime="2024-06-01/2024-06-30",
    query={"eo:cloud_cover": {"lt": 20}},
    max_items=200,
)
items = list(search.items())

# 2. Easiest path: rioxarray on the HTTPS hrefs (anonymous works for these buckets)
da = rioxarray.open_rasterio(items[0].assets["red"].href, chunks=True)

# 3. Or via obstore with anonymous S3 access if you want byte-level control
from obstore.store import S3Store
store = S3Store(
    bucket="sentinel-cogs",
    region="us-west-2",
    skip_signature=True,   # anonymous access
)

# The href is s3://sentinel-cogs/sentinel-s2-l2a-cogs/.../B04.tif — strip the s3://bucket/ prefix
import obstore
href = items[0].assets["red"].href
key = href.replace("s3://sentinel-cogs/", "")
data = obstore.get(store, key)

# 4. For a full multi-scene stack, stackstac or odc-stac is the standard hand-off
import stackstac
stack = stackstac.stack(items, assets=["red", "green", "blue", "nir"])
# returns a dask-backed xarray.DataArray with dims (time, band, y, x)
```

-----

## 3. Copernicus Data Space Ecosystem (CDSE)

**Search endpoint:** `https://stac.dataspace.copernicus.eu/v1` (public for the catalog itself)
**Asset backend:** S3-compatible (CloudFerro/OTC); requires CDSE-issued S3 keys
**Region constraint:** Best from EU regions; in-region access via CDSE compute

```python
import os
import pystac_client
from oauthlib.oauth2 import BackendApplicationClient
from requests_oauthlib import OAuth2Session

# 1. Search — public STAC API, no token needed for browsing
catalog = pystac_client.Client.open(
    "https://stac.dataspace.copernicus.eu/v1"
)

search = catalog.search(
    collections=["sentinel-2-l2a"],
    bbox=[10.0, 45.0, 11.0, 46.0],
    datetime="2024-06-01/2024-06-30",
    filter_lang="cql2-json",
    filter={"op": "<=", "args": [{"property": "eo:cloud_cover"}, 20]},
    max_items=200,
)
items = list(search.items())

# 2a. For Sentinel Hub Process/Catalog API endpoints (which DO require OAuth),
#     get a token and pass it via headers on the Client. Not needed for stac.dataspace.copernicus.eu/v1
client = BackendApplicationClient(client_id=os.environ["CDSE_CLIENT_ID"])
oauth = OAuth2Session(client=client)
token = oauth.fetch_token(
    token_url="https://identity.dataspace.copernicus.eu/auth/realms/CDSE/protocol/openid-connect/token",
    client_secret=os.environ["CDSE_CLIENT_SECRET"],
    include_client_id=True,
)

# If you do need to hit a protected STAC endpoint, inject the bearer token at Client.open time:
sh_catalog = pystac_client.Client.open(
    "https://sh.dataspace.copernicus.eu/api/v1/catalog/1.0.0/",
    headers={"Authorization": f"Bearer {token['access_token']}"},
)

# 2b. For S3 direct access on the public STAC catalog, use CDSE S3 keys (NOT the OAuth token)
from obstore.store import S3Store
store = S3Store(
    bucket="eodata",
    endpoint="https://eodata.dataspace.copernicus.eu",
    region="default",
    access_key_id=os.environ["CDSE_S3_ACCESS_KEY"],
    secret_access_key=os.environ["CDSE_S3_SECRET_KEY"],
    virtual_hosted_style_request=False,   # path-style
)

# 3. Asset hrefs follow the form
#    s3://eodata/Sentinel-2/MSI/L2A/2024/06/15/S2A_MSIL2A_....SAFE/...
import obstore
href = items[0].assets["B04"].href
key = href.replace("s3://eodata/", "")
data = obstore.get(store, key)
```

-----

## 4. NASA CMR-STAC — EMIT (and other Earthdata Cloud collections)

**Search endpoint:** `https://cmr.earthdata.nasa.gov/stac/LPCLOUD` (public)
**Asset backend:** S3 in us-west-2; requires Earthdata Login → temporary STS credentials
**Region constraint:** Direct S3 ONLY works from us-west-2. From anywhere else, fall back to HTTPS download links.

```python
import pystac_client
import earthaccess
from obstore.auth.earthdata import NasaEarthdataCredentialProvider
from obstore.store import S3Store

# EMIT collection IDs (LP DAAC):
#   EMITL1BRAD.v001          - radiance
#   EMITL2ARFL.v001          - reflectance
#   EMITL2BCH4ENH.v002       - methane enhancement
#   EMITL2BCH4PLM.v002       - methane plume complexes

# 0. Bootstrap Earthdata Login credentials into ~/.netrc
earthaccess.login(strategy="netrc")   # or "interactive" first time

# 1. Open + search — CMR-STAC is fully public
catalog = pystac_client.Client.open(
    "https://cmr.earthdata.nasa.gov/stac/LPCLOUD"
)

search = catalog.search(
    collections=["EMITL2BCH4ENH.v002"],
    bbox=[-105.0, 31.0, -103.0, 33.0],   # Permian basin
    datetime="2024-01-01/2024-12-31",
    max_items=500,
)
items = list(search.items())
print(f"Found {len(items)} CH4 enhancement scenes")

# 2. Build an S3 store with auto-refreshing EDL → STS credentials.
#    The LP DAAC credentials endpoint is the right one for EMIT.
cp = NasaEarthdataCredentialProvider(
    "https://data.lpdaac.earthdatacloud.nasa.gov/s3credentials"
)
store = S3Store(
    bucket="lp-prod-protected",
    region="us-west-2",
    credential_provider=cp,
)

# 3. Read
import obstore
for item in items[:5]:
    href = item.assets["data"].href  # s3://lp-prod-protected/EMITL2BCH4ENH.002/...
    key = href.split("lp-prod-protected/")[-1]
    data = obstore.get(store, key)
    # hand to rioxarray.open_rasterio via BytesIO or a tempfile
```

**Fallback for outside us-west-2:** the same items also have HTTPS hrefs like
`https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/...`. Use those with
fsspec + EDL bearer auth, or with `earthaccess.open(results)` which returns fsspec file objects.

-----

## 5. NASA earthaccess — companion pattern (not STAC, but related)

`earthaccess` is a **CMR** client (not STAC). The most useful pairing with pystac is to let earthaccess handle the painful EDL/S3 credential dance, then either (a) use its results directly to open files, or (b) use it for auth and let pystac talk to CMR-STAC.

```python
import earthaccess
import pystac_client
import xarray as xr

# 1. Auth — same as before
auth = earthaccess.login(strategy="netrc", persist=True)

# 2a. Pattern A: search with CMR (granule-level), open with fsspec
results = earthaccess.search_data(
    short_name="EMITL2BCH4ENH",
    version="002",
    bounding_box=(-105.0, 31.0, -103.0, 33.0),
    temporal=("2024-01-01", "2024-12-31"),
)

# In us-west-2: returns s3fs file objects with STS creds pre-applied
# Outside us-west-2: returns HTTPS file objects with EDL bearer pre-applied
files = earthaccess.open(results)
ds = xr.open_dataset(files[0], engine="h5netcdf")

# 2b. Pattern B: use earthaccess only to set up netrc, then drive pystac-client
#     against CMR-STAC + obstore as in recipe #4. Either path works once netrc is set.
catalog = pystac_client.Client.open("https://cmr.earthdata.nasa.gov/stac/LPCLOUD")
# ... same as recipe 4
```

**When to pick which:** earthaccess is more ergonomic for “give me the files for this granule query” and handles auth fully. pystac-client is better when you want a uniform interface across NASA *and* non-NASA STAC APIs, or when you need STAC’s rich Item/Asset model (with the `eo`, `proj`, `raster` extensions parsed) rather than CMR’s granule view.

-----

## 6. DLR EOC Geoservice — EnMAP

**Search endpoint:** `https://geoservice.dlr.de/eoc/ogc/stac/v1` (public)
**Asset backend:** HTTPS from `download.geoservice.dlr.de`, requires DLR UMS (User Management System) HTTP Basic Auth
**Region constraint:** None, but downloads can be slow outside Europe

The relevant collection is `ENMAP_HSI_L2A` (CEOS-ARD L2A); there are also `ENMAP_HSI_L1B`, `ENMAP_HSI_L1C`, and `ENMAP_HSI_L0_QL` (quicklooks).

```python
import os
import pystac_client
import fsspec
from aiohttp import BasicAuth

# 1. Search — public
catalog = pystac_client.Client.open(
    "https://geoservice.dlr.de/eoc/ogc/stac/v1"
)

search = catalog.search(
    collections=["ENMAP_HSI_L2A"],
    bbox=[10.0, 45.0, 11.0, 46.0],
    datetime="2024-01-01/2024-12-31",
    max_items=100,
)
items = list(search.items())

# 2. Assets have hrefs like
#    https://download.geoservice.dlr.de/ENMAP/files/L2A/2023/06/29/.../...SPECTRAL_IMAGE.TIF
#    which require DLR UMS Basic Auth on the download server.
#
# obstore HTTPStore doesn't support Basic Auth natively, so use fsspec here:
fs = fsspec.filesystem(
    "https",
    client_kwargs={
        "auth": BasicAuth(
            os.environ["DLR_UMS_USER"],
            os.environ["DLR_UMS_PASSWORD"],
        ),
    },
)

# 3. Stream into rioxarray
import rioxarray
href = items[0].assets["HSI_L2A"].href
with fs.open(href, "rb") as f:
    da = rioxarray.open_rasterio(f)

# Alternative: use requests with auth=(user, password) for raw byte access,
# or write a custom HTTPStore credential provider in obstore.
```

-----

## Cross-cutting hand-off pattern for JAX/`plumax`

Once you have items, the path into your JAX pipelines is the same across all six recipes — and the pystac side actually has a small advantage here: stackstac and odc-stac are both written with pystac.Item input in mind, so the lazy dask DataArray you get back is “free”.

```python
import rioxarray
import xarray as xr
import jax.numpy as jnp

def items_to_jax_stack(items, band_keys):
    """Bare-metal path — works for any provider."""
    arrs = []
    for item in items:
        bands = [
            rioxarray.open_rasterio(item.assets[k].href, chunks=True)
            for k in band_keys
        ]
        arrs.append(xr.concat(bands, dim="band"))
    ds = xr.concat(arrs, dim="time")
    return jnp.asarray(ds.values)

def items_to_jax_stack_stackstac(items, band_keys):
    """Higher-level path using stackstac — handles reprojection, mosaicking."""
    import stackstac
    stack = stackstac.stack(items, assets=band_keys, chunksize=2048)
    return jnp.asarray(stack.compute().values)

def items_to_jax_stack_odcstac(items, band_keys):
    """Or odc-stac — generally more flexible for multi-resolution products."""
    import odc.stac
    ds = odc.stac.load(items, bands=band_keys, chunks={"x": 2048, "y": 2048})
    return jnp.asarray(ds.to_array().values)
```

For very large item sets, the natural path is:

1. `catalog.search(...).item_collection().save_object("items.json")` → JSON on disk
   *(or via the stac-geoparquet sidecar package → parquet on disk)*
2. Reload later with `pystac.ItemCollection.from_file("items.json")` for reproducibility
3. Iterate the items, open with obstore/fsspec (auth) → rioxarray → JAX

This keeps catalog browsing fully decoupled from auth and from the IO stack you eventually use for arrays.

-----

## Quick auth cheat sheet

|Catalog                     |Search auth        |Asset auth               |Idiomatic pystac approach                                        |
|----------------------------|-------------------|-------------------------|-----------------------------------------------------------------|
|Planetary Computer          |none               |SAS token (per-container)|`Client.open(modifier=planetary_computer.sign_inplace)`          |
|Earth Search (Element 84)   |none               |none (anon S3)           |direct rioxarray on HTTPS hrefs                                  |
|CDSE STAC v1                |none               |CDSE S3 keys             |`obstore.store.S3Store(endpoint=..., access_key_id=...)`         |
|Sentinel Hub Catalog (CDSE) |OAuth2 client creds|n/a (Process API)        |`Client.open(headers={"Authorization": f"Bearer {token}"})`      |
|CMR-STAC LPCLOUD (EMIT etc.)|none               |EDL → STS (us-west-2)    |`earthaccess.login()` + obstore `NasaEarthdataCredentialProvider`|
|DLR Geoservice (EnMAP)      |none               |UMS Basic Auth (HTTPS)   |fsspec `https` filesystem with `BasicAuth`                       |
|earthaccess (CMR, not STAC) |EDL                |EDL → STS or EDL bearer  |`earthaccess.search_data()` + `earthaccess.open()`               |

All search calls are synchronous (no `await`). For Jupyter, just call `list(search.items())` directly in a cell. For scripts, the same — pystac-client doesn’t impose an async event loop on you.

-----

## When to prefer pystac over rustac (and vice versa)

**Prefer pystac/pystac-client when:**

- You’re building interactively in a notebook and want simple synchronous control flow
- You need rich Python introspection — `item.assets["B04"].extra_fields`, extension accessors for `eo`, `proj`, `raster`, `sat`, `view`, etc.
- You’re feeding directly into stackstac, odc-stac, or planetary-computer’s modifier idiom
- Your queries return hundreds to a few thousand items (sync pagination is fast enough)
- You want the most documented, most battle-tested path with the largest StackOverflow corpus

**Prefer rustac when:**

- You want stac-geoparquet as your persistence layer for catalog snapshots
- Your queries return tens of thousands of items and you want concurrent pagination
- You’re building a service or pipeline where async I/O composes with other async work (FastAPI, async Dagster/Prefect tasks)
- You need Arrow-native interop for DuckDB / Polars filtering of catalog metadata
- You’re moving toward a Rust-anchored pipeline regardless

In practice, many real workflows use **both**: pystac-client for interactive exploration and small queries, rustac/stac-geoparquet for the large frozen catalog snapshots that feed reproducible batch processing. The two libraries operate on the same STAC objects under the hood, so an `ItemCollection` written by one is readable by the other.