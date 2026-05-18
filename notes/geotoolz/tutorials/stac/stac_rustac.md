---
title: "STAC + rustac — async clients in the GeoStack"
subject: geotoolz tutorial
short_title: "rustac"
authors:
  - name: J. Emmanuel Johnson
    affiliations:
      - UNEP
      - IMEO
      - MARS
    orcid: 0000-0002-6739-0053
    email: jemanjohnson34@gmail.com
license: CC-BY-4.0
keywords: tutorial, STAC, rustac, Rust, async, geocatalog
---

# Background: STAC, rustac, and where async fits in the GeoStack

## What STAC is, and why it matters

**STAC** (SpatioTemporal Asset Catalog) is a small, deliberately boring JSON specification for describing geospatial assets — satellite scenes, derived products, model outputs, whatever — in a way that’s identical across providers. Three nested objects do all the work: a **Catalog** points to **Collections**, each Collection holds a set of **Items**, and each Item is a GeoJSON Feature whose `assets` field lists the actual files (COGs, NetCDFs, Zarrs) with hrefs and roles. A **STAC API** is just a STAC catalog served over HTTP with a `/search` endpoint that supports filtering by bbox, datetime, collection, and CQL2 property expressions.

The reason STAC matters operationally is that it collapses what used to be N bespoke search clients — one per DAAC, per ESA hub, per commercial provider — into one pattern. Search Sentinel-2 from Element 84, search EMIT methane from NASA, search EnMAP from DLR, search Planetary Computer’s full archive: same query shape, same response shape, same downstream code. The auth and the bucket backends still differ (and that’s exactly what these recipes wrestle with), but the catalog interface is uniform.

For scientific ML workflows the practical upshot is that **STAC is the metadata layer that lets you decouple “which scenes do I want?” from “how do I read pixels?”**. You can build the scene list once, persist it as stac-geoparquet, and then re-run the array loading step many times against the same frozen set of items — important for reproducibility and for the inference→retrain cycles common in plume / retrieval work.

## What rustac is

**rustac** is a set of Rust crates implementing the STAC spec, with a Python binding (`rustac-py`) exposed as the `rustac` PyPI package. It plays the same role that `pystac` + `pystac-client` play in the pure-Python world, but with three properties that change what’s possible:

1. **stac-geoparquet is a first-class output format.** Instead of materializing thousands of Item dicts in Python memory, `rustac.search_to(path, ...)` streams results from the API directly into a columnar parquet file. That file is then queryable from DuckDB, Polars, GeoPandas, or `rustac.read()` itself. For a 10k-scene query this is the difference between a 4 GB Python heap and a 200 MB file on disk.
2. **Arrow is the in-memory interchange.** `rustac.to_arrow(items)` and `rustac.from_arrow(table)` give zero-copy bridges to anything in the Arrow ecosystem — Polars, DuckDB, GeoPandas, Lance — without round-tripping through JSON.
3. **The hot path is Rust + async.** Searches, paginations, and parquet I/O all happen in Rust on a tokio runtime, with Python only seeing the eventual result.

## Why everything is `async` / `await`

rustac’s Python API is async because the work it does is **I/O-bound**: it makes HTTP requests, paginates through results, writes to object storage, fetches bytes. While one request is in flight, the runtime can be issuing the next one rather than blocking a thread. For a STAC search that walks 20 pages of results, this is roughly 20× faster than the synchronous equivalent without using any more cores.

The mechanics, briefly:

- `async def foo():` declares a **coroutine** — a function that returns a paused computation, not a value.
- `await something` says “suspend here until `something` is done, and let other coroutines run in the meantime.”
- `asyncio.run(main())` starts an event loop, runs `main()` to completion, and tears the loop down.
- In Jupyter, the loop is already running, so you can just `await rustac.search(...)` at the top level of a cell.

obstore is async-first for the same reason: object stores are network resources, and the throughput gain from concurrent GETs (e.g. fetching 200 COG tiles in parallel) is enormous. The pattern across these recipes — `await rustac.search_to(...)` then `await obstore.get_async(store, key)` — is async end-to-end so that the I/O concurrency compounds.

If you’re calling this from synchronous code (a script, a CLI, a training loop) the bridge is just `asyncio.run(main())`. If you’re already inside an async framework (FastAPI, a Prefect/Dagster async task, a Jupyter cell), you await directly.

## Where rustac sits in the GeoStack

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
                          │   obstore     ·     fsspec               │
                          │   (S3 / Azure / GCS / HTTPS, with auth)  │
                          └──────────────────▲───────────────────────┘
                                             │  signed hrefs / credentials
                          ┌──────────────────┴───────────────────────┐
                          │       CATALOG / METADATA LAYER           │
                          │   rustac  ·  pystac  ·  pystac-client    │
                          │   stac-geoparquet  ·  Arrow / DuckDB     │
                          └──────────────────▲───────────────────────┘
                                             │  STAC API HTTP queries
                          ┌──────────────────┴───────────────────────┐
                          │              STAC API LAYER              │
                          │   Planetary Computer  ·  Earth Search    │
                          │   CMR-STAC (EMIT)     ·  CDSE STAC       │
                          │   DLR Geoservice (EnMAP)  ·  ...         │
                          └──────────────────────────────────────────┘
```

Each layer is replaceable. You can swap rustac for pystac-client at the catalog layer without touching the array layer; you can swap obstore for fsspec without touching the science layer. The job of the recipes below is to wire up the bottom three layers correctly for each provider — once that’s done, everything above is the same code regardless of where the data came from.

A useful mental model: **rustac picks the scenes, obstore moves the bytes, rioxarray/xarray shape them into labeled arrays, and JAX does the math.** The async/await sprinkled through the recipes is what lets the bottom two layers run their network I/O concurrently instead of in sequence.

-----

# rustac + obstore/fsspec: per-catalog recipes

Each recipe follows the same three-stage pattern:

1. **Search** the STAC catalog with `rustac` → either an in-memory item collection or a stac-geoparquet file
2. **Build an obstore (or fsspec) store** with the right credentials for that provider’s blob backend
3. **Hand off** the signed/auth’d asset hrefs to rioxarray / odc-stac / xarray for array loading

Common imports across all recipes:

```python
import asyncio
import rustac
import obstore
from obstore.store import S3Store, AzureStore, HTTPStore
```

-----

## 1. Microsoft Planetary Computer

**Search endpoint:** `https://planetarycomputer.microsoft.com/api/stac/v1` (public)
**Asset backend:** Azure Blob Storage, requires SAS-token signing per-asset
**Region constraint:** None for browsing; cheaper if you compute in West Europe / East US

```python
from obstore.auth.planetary_computer import PlanetaryComputerCredentialProvider

async def pc_recipe():
    # 1. Search — fully public, no auth needed
    items = await rustac.search(
        "https://planetarycomputer.microsoft.com/api/stac/v1",
        collections="sentinel-2-l2a",
        bbox=[-122.5, 37.5, -122.0, 38.0],
        datetime="2024-06-01/2024-06-30",
        query={"eo:cloud_cover": {"lt": 20}},
        max_items=200,
    )

    # OR stream straight to geoparquet (preferred for many items)
    await rustac.search_to(
        "data/s2_sf.parquet",
        "https://planetarycomputer.microsoft.com/api/stac/v1",
        collections="sentinel-2-l2a",
        bbox=[-122.5, 37.5, -122.0, 38.0],
        datetime="2024-06-01/2024-06-30",
        max_items=200,
    )

    # 2. Build a per-asset credential provider for Azure
    # The provider hits the PC SAS endpoint and refreshes tokens automatically
    asset = items["features"][0]["assets"]["B04"]  # red band
    cp = PlanetaryComputerCredentialProvider.from_asset(asset)
    store = AzureStore(
        account_name="sentinel2l2a01",   # parsed from the asset href
        container_name="sentinel2-l2",
        credential_provider=cp,
    )

    # 3. Read bytes / hand off to xarray
    data = await obstore.get_async(store, "path/within/container/B04.tif")
    # ... or use the signed href directly with rioxarray:
    # import planetary_computer as pc
    # signed_items = [pc.sign(item) for item in items["features"]]
    # ds = odc.stac.load(signed_items, bands=["B04","B03","B02"])
```

**Note:** For odc-stac/stackstac workflows, the simpler path is `planetary_computer.sign(item)` on each item before loading. Use obstore directly when you want fine-grained streaming or async control.

-----

## 2. Element 84 Earth Search (AWS Open Data)

**Search endpoint:** `https://earth-search.aws.element84.com/v1` (public)
**Asset backend:** S3 (us-west-2, public buckets like `sentinel-cogs`, `usgs-landsat`)
**Region constraint:** Free egress from us-west-2; otherwise standard S3 egress costs

```python
async def earthsearch_recipe():
    # 1. Search — fully public
    await rustac.search_to(
        "data/s2_cogs.parquet",
        "https://earth-search.aws.element84.com/v1",
        collections="sentinel-2-l2a",          # COG version
        bbox=[-122.5, 37.5, -122.0, 38.0],
        datetime="2024-06-01/2024-06-30",
        query={"eo:cloud_cover": {"lt": 20}},
        max_items=200,
    )

    # 2. Build an anonymous S3 store (these buckets are public)
    store = S3Store(
        bucket="sentinel-cogs",
        region="us-west-2",
        skip_signature=True,   # anonymous access
    )

    # 3. Stream a band
    # Asset hrefs are like s3://sentinel-cogs/sentinel-s2-l2a-cogs/.../B04.tif
    result = await obstore.get_async(
        store,
        "sentinel-s2-l2a-cogs/10/S/EG/2024/6/S2A_10SEG_20240615_0_L2A/B04.tif",
    )

    # For xarray: rioxarray works directly on the https hrefs without obstore
    # since the buckets allow anonymous HTTPS GET:
    # import rioxarray
    # da = rioxarray.open_rasterio(item["assets"]["red"]["href"])
```

-----

## 3. Copernicus Data Space Ecosystem (CDSE)

**Search endpoint:** `https://stac.dataspace.copernicus.eu/v1` (public for the catalog itself)
**Asset backend:** S3-compatible (CloudFerro/OTC); requires CDSE-issued S3 keys
**Region constraint:** Best from EU regions; in-region access via CDSE compute

```python
import os
from requests_oauthlib import OAuth2Session
from oauthlib.oauth2 import BackendApplicationClient

async def cdse_recipe():
    # 1. Search — public STAC API, no token needed
    await rustac.search_to(
        "data/s2_cdse.parquet",
        "https://stac.dataspace.copernicus.eu/v1",
        collections="sentinel-2-l2a",
        bbox=[10.0, 45.0, 11.0, 46.0],
        datetime="2024-06-01/2024-06-30",
        filter_lang="cql2-json",
        filter={"op": "<=", "args": [{"property": "eo:cloud_cover"}, 20]},
        max_items=200,
    )

    # 2a. For Sentinel Hub Process/Catalog API endpoints (which DO require OAuth),
    #     get a token first. Note: not needed for stac.dataspace.copernicus.eu/v1
    client = BackendApplicationClient(client_id=os.environ["CDSE_CLIENT_ID"])
    oauth = OAuth2Session(client=client)
    token = oauth.fetch_token(
        token_url="https://identity.dataspace.copernicus.eu/auth/realms/CDSE/protocol/openid-connect/token",
        client_secret=os.environ["CDSE_CLIENT_SECRET"],
        include_client_id=True,
    )

    # 2b. For S3 direct access, you need CDSE S3 keys (generated separately
    #     in the CDSE dashboard, NOT the OAuth token).
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
    items = await rustac.read("data/s2_cdse.parquet")
    href = items["features"][0]["assets"]["B04"]["href"]  # s3://eodata/...
    key = href.replace("s3://eodata/", "")
    data = await obstore.get_async(store, key)
```

-----

## 4. NASA CMR-STAC — EMIT (and other Earthdata Cloud collections)

**Search endpoint:** `https://cmr.earthdata.nasa.gov/stac/LPCLOUD` (public)
**Asset backend:** S3 in us-west-2; requires Earthdata Login → temporary STS credentials
**Region constraint:** Direct S3 ONLY works from us-west-2. From anywhere else, fall back to HTTPS download links.

```python
from obstore.auth.earthdata import NasaEarthdataCredentialProvider
import earthaccess  # for login/.netrc bootstrapping only

# EMIT collection IDs (LP DAAC):
#   EMITL1BRAD.v001          - radiance
#   EMITL2ARFL.v001          - reflectance
#   EMITL2BCH4ENH.v002       - methane enhancement
#   EMITL2BCH4PLM.v002       - methane plume complexes

async def emit_recipe():
    # 0. Bootstrap Earthdata Login credentials into ~/.netrc
    earthaccess.login(strategy="netrc")   # or "interactive" first time

    # 1. Search — CMR-STAC is fully public
    await rustac.search_to(
        "data/emit_ch4.parquet",
        "https://cmr.earthdata.nasa.gov/stac/LPCLOUD",
        collections="EMITL2BCH4ENH.v002",
        bbox=[-105.0, 31.0, -103.0, 33.0],   # Permian basin
        datetime="2024-01-01/2024-12-31",
        max_items=500,
    )

    # 2. Build an S3 store with auto-refreshing EDL → STS credentials.
    #    The LP DAAC credentials endpoint is the right one for EMIT.
    cp = NasaEarthdataCredentialProvider(
        "https://data.lpdaac.earthdatacloud.nasa.gov/s3credentials"
    )
    # Assets in CMR-STAC items have s3://lp-prod-protected/... hrefs
    store = S3Store(
        bucket="lp-prod-protected",
        region="us-west-2",
        credential_provider=cp,
    )

    # 3. Read
    items = await rustac.read("data/emit_ch4.parquet")
    for item in items["features"][:5]:
        href = item["assets"]["data"]["href"]  # e.g. s3://lp-prod-protected/EMITL2BCH4ENH.002/...
        key = href.split("lp-prod-protected/")[-1]
        data = await obstore.get_async(store, key)
        # hand to rioxarray.open_rasterio via a BytesIO or to a tempfile
```

**Fallback for outside us-west-2:** the same items also have HTTPS hrefs like
`https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/...`. Use those with
fsspec + EDL bearer auth, or with `earthaccess.open(results)` which returns fsspec file objects.

-----

## 5. NASA earthaccess — companion pattern (not STAC, but related)

`earthaccess` is a **CMR** client (not STAC). The most useful pairing with rustac is to let earthaccess handle the painful EDL/S3 credential dance, then either (a) feed its results to rustac for geoparquet I/O, or (b) just use it for auth and let rustac talk to CMR-STAC.

```python
import earthaccess
import fsspec

def earthaccess_then_rustac():
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
    # `files` are fsspec OpenFile-like; rioxarray/h5py/netCDF4 can consume them

    # 2b. Pattern B: use earthaccess only to set up netrc, then drive rustac
    #     against CMR-STAC + obstore as in recipe #4. This is the path that
    #     gives you stac-geoparquet output.

    # 3. fsspec → xarray
    import xarray as xr
    ds = xr.open_dataset(files[0], engine="h5netcdf")  # or rioxarray for COG
```

**When to pick which:** earthaccess is more ergonomic for “give me the files for this granule query” and handles auth fully. rustac is better when you want **stac-geoparquet output** for downstream Arrow/Polars/DuckDB pipelines, or when you need a single tool that hits multiple non-NASA STAC APIs the same way.

-----

## 6. DLR EOC Geoservice — EnMAP

**Search endpoint:** `https://geoservice.dlr.de/eoc/ogc/stac/v1` (public)
**Asset backend:** HTTPS from `download.geoservice.dlr.de`, requires DLR UMS (User Management System) HTTP Basic Auth
**Region constraint:** None, but downloads can be slow outside Europe

The relevant collection is `ENMAP_HSI_L2A` (CEOS-ARD L2A); there are also `ENMAP_HSI_L1B`, `ENMAP_HSI_L1C`, and `ENMAP_HSI_L0_QL` (quicklooks).

```python
import os
import fsspec
from aiohttp import BasicAuth

async def enmap_recipe():
    # 1. Search — public
    await rustac.search_to(
        "data/enmap.parquet",
        "https://geoservice.dlr.de/eoc/ogc/stac/v1",
        collections="ENMAP_HSI_L2A",
        bbox=[10.0, 45.0, 11.0, 46.0],
        datetime="2024-01-01/2024-12-31",
        max_items=100,
    )

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
    items = await rustac.read("data/enmap.parquet")
    href = items["features"][0]["assets"]["HSI_L2A"]["href"]
    with fs.open(href, "rb") as f:
        import rioxarray
        da = rioxarray.open_rasterio(f)

    # Alternative: write a custom obstore HTTP credential provider that
    # injects the Authorization header. Or use httpx.AsyncClient directly
    # with auth=(user, password) for raw byte access.
```

-----

## Cross-cutting hand-off pattern for JAX/`plumax`

Once you have asset bytes or signed hrefs, the path into your JAX pipelines is the same shape across all six recipes:

```python
import rioxarray
import xarray as xr
import jax.numpy as jnp

def items_to_jax_stack(item_collection, band_keys):
    # Resolve hrefs (signed if needed - PC), open via rioxarray, stack
    arrs = []
    for item in item_collection["features"]:
        bands = [rioxarray.open_rasterio(item["assets"][k]["href"], chunks=True)
                 for k in band_keys]
        arrs.append(xr.concat(bands, dim="band"))
    ds = xr.concat(arrs, dim="time")
    return jnp.asarray(ds.values)  # or use jax.tree to lazy-load tiles
```

For very large item sets, the natural path is:

1. `rustac.search_to(...)` → stac-geoparquet on disk
2. `rustac.read(...)` or DuckDB / Polars over the parquet for filtering
3. Iterate the surviving items, open with obstore (auth) → rioxarray → JAX

This keeps catalog browsing fully decoupled from auth and from the IO stack you eventually use for arrays.

-----

## Quick auth cheat sheet

|Catalog                     |Search auth        |Asset auth               |obstore provider                         |
|----------------------------|-------------------|-------------------------|-----------------------------------------|
|Planetary Computer          |none               |SAS token (per-container)|`PlanetaryComputerCredentialProvider`    |
|Earth Search (Element 84)   |none               |none (anon S3)           |`S3Store(skip_signature=True)`           |
|CDSE STAC v1                |none               |CDSE S3 keys             |`S3Store` + `endpoint=`                  |
|Sentinel Hub Catalog (CDSE) |OAuth2 client creds|n/a (Process API)        |n/a — use pystac-client                  |
|CMR-STAC LPCLOUD (EMIT etc.)|none               |EDL → STS (us-west-2)    |`NasaEarthdataCredentialProvider`        |
|DLR Geoservice (EnMAP)      |none               |UMS Basic Auth (HTTPS)   |use `fsspec` `https` with `BasicAuth`    |
|earthaccess (CMR, not STAC) |EDL                |EDL → STS or EDL bearer  |`earthaccess.get_s3fs_session()` (fsspec)|

All search calls are async (`await rustac.search(...)`). Wrap in `asyncio.run(main())` from a script, or `await` directly in a Jupyter cell.



---


https://stacindex.org/


