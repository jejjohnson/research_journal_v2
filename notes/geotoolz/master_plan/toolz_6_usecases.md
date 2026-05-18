---
title: "Report 9 — Use-case revisit with the full library structure"
subject: geotoolz master plan
short_title: "R9 — Use cases"
authors:
  - name: J. Emmanuel Johnson
    affiliations:
      - UNEP
      - IMEO
      - MARS
    orcid: 0000-0002-6739-0053
    email: jemanjohnson34@gmail.com
license: CC-BY-4.0
keywords: geotoolz, use-cases, library-structure, gallery
---

# Report 9 — Use-case revisit with the full library structure

|                                |                                                                                                                                                                                                                              |
| ------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Status**                     | Use-case mapping (supersedes Report 4)                                                                                                                                                                                       |
| **Reading time**               | ~30 min                                                                                                                                                                                                                      |
| **Audience**                   | Anyone pressure-testing the full library structure (pipekit + pipekit-array + geocatalog + geopatcher + geotoolz + xr_toolz, with georeader as substrate and pipekit-jax as future direction) against real deployment shapes |
| **Companion reports**          | Reports 1–8 (the full stack)                                                                                                                                                                                                 |
| **Reference**                  | [`usecases.md`](https://github.com/jejjohnson/research_journal_v2/blob/main/notes/geotoolz/plans/geotoolz/examples/usecases.md)                                                                                              |
| **What changed from Report 4** | Catalog and patcher are now standalone packages; `GeoSlice` lives in `geocatalog`; `georeader` is explicit as the substrate; pipekit-jax is named where it would help (without being required)                               |

## The library shape we’re mapping against

```
              ┌──────────┐  ┌──────────┐
              │ geotoolz │  │ xr_toolz │            Domain operators
              └────┬─────┘  └────┬─────┘
                   │             │
        ┌──────────┼─────────────┼────────────┐
        │          │             │            │
   ┌────┴───┐  ┌───┴──────┐  ┌───┴───────┐  ┌─┴─────────┐
   │pipekit │  │pipekit-  │  │geocatalog │  │geopatcher │ Framework + infra
   │        │  │array     │  │           │  │           │
   └────────┘  └──────────┘  └───────────┘  └───────────┘
        ▲                                       ▲
        │                                       │
   ┌────┴────────┐                       ┌──────┴───────────────┐
   │pipekit-jax  │ ← deferred            │ georeader / xarray   │   Substrate
   │(future)     │   future direction    │ (I/O + carriers)     │
   └─────────────┘                       └──────────────────────┘
```

For each use case below: **imports** (where the symbols come from), **pseudocode** (revised for the new structure), **library map** (which packages this case touches), and **notes** (what improved or got harder).

## Case 1 — Notebook exploration

**Imports.** `pipekit` (observers) + `geotoolz` (domain).

```python
import pipekit as pk
import geotoolz as gz
import matplotlib.pyplot as plt
import numpy as np

viz = pk.Sequential([
    gz.cloud.MaskClouds(qa_band=-1, bits=[10, 11]),
    pk.Tap(lambda gt: print(f"after mask: {np.isnan(gt).mean():.1%} NaN")),
    gz.radiometry.PercentileClip(p_min=2, p_max=98),
    gz.indices.NDVI(red_idx=2, nir_idx=3),
])

ndvi_gt = viz(scene_gt)
plt.imshow(ndvi_gt.values, cmap="RdYlGn")
```

**Library map.** `pipekit` (framework) + `geotoolz` (domain). No catalog, no patcher, no array, no substrate touched directly — `scene_gt` arrived from somewhere else (an earlier reader call). The slimmest possible deployment shape.

**Notes.** Unchanged from Report 4. `gz.Tap` and `pk.Tap` are the same object — `geotoolz` re-exports.

## Case 2 — ETL pipelines

**Imports.** `pipekit` (YAML loader, parallelism) + `geocatalog` (catalog) + `geotoolz` (`CatalogPipeline` driver + operators inside the YAML) + `georeader` (transitive, used by `geocatalog.load_raster`).

```python
import pipekit as pk
import geocatalog as gc
import geotoolz as gz

catalog = gc.open_catalog("s3://bucket/s2_eu.parquet")
etl = pk.loads_yaml(open("pipelines/ndvi_etl.yaml").read())

gz.catalog_ops.CatalogPipeline(
    catalog=catalog,
    op=etl,
    parallel=pk.parallel.ProcessMap(n_workers=8, on_error="log_and_continue"),
    loader=gc.load_raster,   # injection: geocatalog's loader
).run()
```

**Library map.** Four packages touched. `geocatalog` produces the iteration; `pipekit` provides the framework + parallelism; `geotoolz.catalog_ops.CatalogPipeline` is the glue (it ties pipekit’s `Operator` to geocatalog’s catalog because both deps need to be present); the YAML inside references `geotoolz.cloud.*`, `geotoolz.correction.*`, `geotoolz.indices.*`, `geotoolz.io.WriteCOG`. `georeader` is the substrate underneath `gc.load_raster`.

**Notes.**

- `CatalogPipeline` is a *geotoolz-side glue class* — not in geocatalog (which has no pipekit dep) and not in pipekit (which has no geocatalog dep). It composes both, so it lives in the consumer.
- `pk.parallel.ProcessMap` is now a building block injected into `CatalogPipeline`, rather than a hardcoded inside.
- The pickleability discipline (Group J of Report 2) is the load-bearing constraint: every operator, every reader, every loader must pickle.

## Case 3 — ML training and inference

**Imports.** `pipekit` (framework, parallel) + `pipekit-array` (`ModelOp`) + `geocatalog` (catalog + slices) + `geopatcher` (patches via `RasterField` + `SpatialPatcher`) + `geotoolz` (domain ops + readers).

```python
import pipekit as pk
import pipekit_array as pa
import geocatalog as gc
import geopatcher as gp
from geopatcher.integrations.pipekit import GridSampler, ApplyToChips, Stitch
import geotoolz as gz
import torch
import numpy as np

# Shared preprocessing — same Sequential in both paths
preprocess = pk.Sequential([
    gz.radiometry.ToFloat32(),
    gz.radiometry.PercentileClip(p_min=2, p_max=98, axis=(-2, -1)),
    gz.cloud.ApplyMask(gz.cloud.MaskFromQABits(qa_band=-1, bits=[10, 11])),
])

augment = pk.Sequential([
    gz.augment.RandomFlip(p=0.5),
    gz.augment.RandomRotate90(),
])

# === Training: catalog → sampler → preprocess → augment ===
class GeoDataset(torch.utils.data.IterableDataset):
    def __init__(self, catalog, preprocess, augment):
        self.cat, self.pre, self.aug = catalog, preprocess, augment

    def __iter__(self):
        for sl in self.cat.iter_random_slices(chip_size=(256, 256), n=10_000):
            gt = gc.load_raster(sl)
            x = self.aug(self.pre(gt))
            yield torch.from_numpy(np.asarray(x))

# === Inference: patcher (geopatcher) → preprocess → ModelOp (pipekit-array) → stitch ===
patcher = gp.SpatialPatcher(
    geometry=gp.SpatialRectangular((256, 256)),
    sampler=gp.SpatialRegularStride((224, 224)),
    window=gp.SpatialHann(),
    aggregation=gp.SpatialOverlapAdd(),
)

infer = pk.Sequential([
    GridSampler(patcher),
    ApplyToChips(pk.Sequential([
        preprocess,                               # same object as training
        pa.ModelOp(model, batch_size=8),         # multi-backend (numpy/JAX/torch)
    ])),
    Stitch(gp.SpatialOverlapAdd()),
])
pred_gt = infer(gp.RasterField(scene_reader))
```

**Library map.** Five packages touched (plus georeader transitively). This is the most layered case.

**Notes.**

- `GridSampler`, `ApplyToChips`, `Stitch` come from `geopatcher.integrations.pipekit` — extras-gated. The user opts into the integration by installing `geopatcher[pipekit]`.
- `gp.RasterField(scene_reader)` wraps any `GeoData`-shaped reader (RasterioReader, GeoTensor itself, …). The Field/Domain Protocol decouples the patcher from any specific reader library.
- The “same preprocess object on both paths” property — the train/serve-skew guarantee that’s the whole point of the framework — is preserved.
- `pa.ModelOp` is multi-backend; same operator works on numpy, JAX, torch models (just supply a different `model` argument).

**Where pipekit-jax could help (deferred).** If the model and `preprocess` were both JAX-traceable, the entire `infer` pipeline could be `eqx.filter_jit`-wrapped for 5-50× inference speedup. `geopatcher.integrations.pipekit_jax` would slot in (Report 5). But that’s a v0.3+ concern.

## Case 4 — Lightning / LitServe inference API

**Imports.** `pipekit` (YAML loader, `config_hash`) + `geotoolz` (the operators inside the YAML) + `georeader` (inline reads at request time).

```python
import litserve as ls
import pipekit as pk
import geotoolz as gz
import georeader

class MethanePipelineAPI(ls.LitAPI):
    def setup(self, device):
        self.pipeline = pk.loads_yaml(open("pipelines/methane_v3.yaml").read())
        self.config_hash = pk.config_hash(self.pipeline)

    def decode_request(self, req):
        return georeader.read_from_url(req["url"], bounds=tuple(req["bbox"]))

    def predict(self, gt):
        return self.pipeline(gt)

    def encode_response(self, gt_out):
        return {
            "cog_b64":     gt_out.to_cog_bytes_b64(),
            "stats":       gt_out.summary_stats(),
            "config_hash": self.config_hash,
        }

ls.LitServer(MethanePipelineAPI(), accelerator="gpu").run(port=8000)
```

**Library map.** Three packages — `pipekit` for framework, `geotoolz` for operators in the YAML, `georeader` directly for the inline request-time read. Note: this is a *non-catalog* shape — the URL is in the request, not from a pre-built index.

**Notes.**

- `georeader.read_from_url` is the direct-read pattern. Not `geocatalog.load_raster` because there’s no catalog — each request stands alone.
- Cold-start optimisation (heavy state in `setup`, never per-`predict`) is operational discipline; no framework involvement.
- `pk.config_hash(pipeline)` is a small helper in pipekit core (~30 LOC) that canonicalises `pipeline.state` and SHA-256s it. Lives in pipekit because it’s framework-level.

**Where pipekit-jax could help.** If the `methane_v3` pipeline were JAX-traceable, the `predict` body becomes a JIT-compiled XLA kernel — substantial throughput win for operational MARS deployment. This is exactly the “use case that drives pipekit-jax to v0.3” headline from Report 5.

## Case 5 — Backend API (FastAPI, multi-pipeline)

**Imports.** `pipekit` (loader, registry, config_hash) + `geotoolz` (operators) + `georeader` (inline reads).

```python
from fastapi import FastAPI
from pydantic import BaseModel
from uuid import uuid4
import pipekit as pk
import geotoolz as gz
import georeader

app = FastAPI()

PIPELINE_REGISTRY = {
    "methane_v3": "pipelines/methane_v3.yaml",
    "methane_v4": "pipelines/methane_v4_candidate.yaml",
    "ndvi_etl":   "pipelines/ndvi_etl.yaml",
}
PIPELINES = {
    name: pk.loads_yaml(open(path).read())
    for name, path in PIPELINE_REGISTRY.items()
}

class ProcessRequest(BaseModel):
    url:  str
    bbox: tuple[float, float, float, float]

@app.post("/process/{name}")
def process(name: str, req: ProcessRequest):
    pipe = PIPELINES[name]
    gt = georeader.read_from_url(req.url, bounds=req.bbox)
    out_gt = pipe(gt)
    cog_url = georeader.save_cog(out_gt, f"s3://outputs/{uuid4()}.tif")
    return {"cog_url": cog_url, "config_hash": pk.config_hash(pipe)}

@app.get("/pipelines/{name}")
def describe(name: str):
    return PIPELINES[name].get_config()

@app.get("/pipelines")
def list_pipelines():
    return {name: pk.config_hash(pipe) for name, pipe in PIPELINES.items()}
```

**Library map.** Same three packages as Case 4. The registry pattern is pipekit-level (any operator graph can be registered); no extra libraries required.

**Notes.**

- `ConfigMixin` from pipekit makes `pipeline.get_config()` work out of the box. Used in `/pipelines/{name}` to make the API self-document.
- `georeader.save_cog` is the canonical write path — substrate-level.

## Case 6 — User-uploaded pipelines (sandboxed)

**Imports.** `pipekit` (sandboxed loader, registry, error types) + `geotoolz` (the operators the user is allowed to invoke).

```python
import streamlit as st
import pipekit as pk
import geotoolz as gz   # noqa: F401 — triggers Operator registration via __init_subclass__

# Public registry built at startup by introspecting modules
ALLOWED = pk.registry.public_operators(
    include_modules=["geotoolz", "pipekit"],
    exclude_classes=["Lambda", "Sink", "ModelOp"],  # closure-bearing
)

yaml_text = st.text_area("Pipeline YAML", height=300)

if st.button("Run"):
    try:
        pipe = pk.loads_yaml_sandboxed(yaml_text, allowed=ALLOWED)
    except pk.UntrustedTargetError as e:
        st.error(f"Operator not allowed: `{e.target}`")
    except Exception as e:
        st.error(f"YAML error: {e}")
    else:
        scene = read_demo_scene(st.text_input("Bounds"))
        result = pipe(scene)
        st.image(result.to_rgb_array())
        st.json(pipe.get_config())
```

**Library map.** `pipekit` + `geotoolz`. The sandboxed loader lives in pipekit core (it’s a framework concern: walk the config tree, check each `_target_` against a registry). The allowed-list is built by introspecting *which Operator subclasses exist*, which is enabled by pipekit’s `__init_subclass__` registration.

**Notes.**

- The `forbid_in_yaml` discipline from pipekit (auto-flagged on `Lambda`, `Tap`, `Sink`, `ModelOp`, etc.) directly enables this use case. The registry filter just queries that flag.
- Resource-exhaustion attacks (huge intermediates, million-step Sequential) are *not* addressed by the loader. They’re a deployment-layer concern (per-request CPU/memory limits).
- If user pipelines need to reach catalog or patcher, the registry includes `geocatalog` and `geopatcher` modules — but probably you don’t want untrusted users instantiating `CatalogPipeline` with arbitrary S3 URIs. Keep the registry tight.

## Case 7 — Tile server (z/x/y → PNG)

**Imports.** `pipekit` (registry-style YAML loading) + `geotoolz` (cloud, indices, viz, presets) + `georeader` (catalog-or-direct reads inside `read_tile`).

```python
from fastapi import FastAPI, Response
import mercantile
import pipekit as pk
import geotoolz as gz

app = FastAPI()
LAYERS = pk.loads_yaml_dict(open("pipelines/tile_layers.yaml").read())

@app.get("/tiles/{layer}/{z}/{x}/{y}.png")
def tile(layer: str, z: int, x: int, y: int):
    bbox = mercantile.xy_bounds(x, y, z)
    gt = catalog.read_tile(bbox, target_size=(256, 256), crs="EPSG:3857")
    rgb_gt = LAYERS[layer](gt)
    return Response(rgb_gt.to_png_bytes(), media_type="image/png")
```

**Library map.** `pipekit` (loader) + `geotoolz` (viz operators inside layer YAMLs). The `catalog.read_tile` call is `geocatalog` if the data is indexed; or `georeader` direct for static datasets.

**Notes.**

- The hot-loop performance discipline (load LUT once in `__init__`, no allocations in `_apply`) is operator-design responsibility, not framework.
- A tile cache (Redis, CloudFront, on-disk) usually matters more than Python-level performance — caching is operations-layer.

## Case 8 — Data validation / QC as operators

**Imports.** All three layers. `pipekit` (carrier-agnostic asserts) + `pipekit-array` (array-shaped asserts) + `geotoolz` (geo-specific asserts).

```python
import pipekit as pk
import pipekit_array as pa
import geotoolz as gz

qc = pk.Sequential([
    # pipekit: carrier-agnostic
    pk.qc.AssertShape((-1, -1, -1)),                         # 3-D check
    pk.qc.AssertHasAttribute("crs"),

    # geotoolz: GeoTensor-specific (need .crs, .transform, sensor metadata)
    gz.qa.AssertCRSEquals("EPSG:32630"),
    gz.qa.AssertResolutionWithin((9.5, 10.5)),
    gz.qa.AssertSchema(bands=["B02", "B03", "B04", "B08", "QA60"]),

    # pipekit-array: array reductions (works on numpy / JAX / etc.)
    pa.qc.AssertValidFraction(min_valid=0.5),
    pa.qc.AssertValueRange(min_val=0, max_val=10_000, on_fail="warn"),
])

etl = pk.Sequential([
    gz.cloud.MaskClouds(qa_band=-1, bits=[10, 11]),
    qc,                                                       # halts on first hard failure
    gz.correction.TOAToBOA(sun_zenith_band=-2),
    qc,                                                       # post-correction sweep
    gz.indices.NDVI(red_idx=2, nir_idx=3),
])
```

**Library map.** Three packages, three QC tiers:

|QC tier         |Lives in          |Examples                                                            |
|----------------|------------------|--------------------------------------------------------------------|
|Carrier-agnostic|`pipekit.qc`      |`AssertShape`, `AssertHasAttribute`, `AssertCallable`, `AssertDType`|
|Array-shaped    |`pipekit_array.qc`|`AssertValueRange`, `AssertNoNaN`, `AssertValidFraction`            |
|Geo-specific    |`geotoolz.qa`     |`AssertCRSEquals`, `AssertResolutionWithin`, `AssertSchema`         |

**Notes.** The split-into-three is the clean answer to the “where does each QC check go?” question. Carrier-agnostic checks need no library import beyond pipekit. Array reductions go via the Array API. GeoTensor / xarray-specific checks live with their carrier library. Same `on_fail="warn"`/`"raise"` policy across all three.

## Case 9 — Pinned / hashed regulatory artifact

**Imports.** `pipekit` only.

```python
import pipekit as pk

# === At publication time ===
pipeline = pk.loads_yaml(open("pipelines/methane_v3.yaml").read())
artifact = pk.repro.freeze(
    pipeline,
    inputs={
        "scene_uri":    "s3://imeo/emit/2024Q3/EMIT_L2A_RFL_...nc",
        "scene_sha256": "ab12cd34ef56...",
    },
    deps_lock="poetry.lock",
    metadata={"author": "ej", "date": "2024-09-15", "doi": "10.xxxx/mars-2024Q3"},
)
artifact.save("/regulatory/mars_methane_2024Q3.gtar")

# === Years later ===
art = pk.repro.load("/regulatory/mars_methane_2024Q3.gtar")
assert art.pipeline_hash == "expected-hash-from-paper"
print(art.config_yaml)
result = art.rerun()
```

**Library map.** Pure framework. The artifact stores `pipeline.state` (the serialised graph) + input hashes + deps lockfile + metadata. None of this is carrier-specific.

**Notes.**

- `pk.repro` is ~150 LOC in pipekit core. Worth shipping in the framework because regulatory reproducibility is a framework-level concern that the rest of the ecosystem inherits.
- True bit-exactness needs a Docker image hash; the artifact aspires but doesn’t guarantee numerical reproducibility.
- The operators *inside* the pipeline can be from any package (geotoolz, xr_toolz, etc.). The artifact records their fully-qualified class paths via `Operator.state`.

## Case 10 — Active learning / uncertainty-driven sampling

**Imports.** `pipekit` (Sequential) + `pipekit-array` (ModelOp, MeanScalar) + `geopatcher` (sampler) + `geotoolz` (`ActiveSampler` glue).

```python
import pipekit as pk
import pipekit_array as pa
import geopatcher as gp
import geotoolz as gz

# Score every chip by predictive uncertainty
score_pipeline = pk.Sequential([
    preprocess,
    pa.ModelOp(uq_model, method="predict_with_uncertainty"),
    pa.MeanScalar(field="sigma"),                              # GeoTensor → scalar
])

# Codified version
top_k = gz.patch_ops.ActiveSampler(
    base=gp.SpatialPatcher(
        geometry=gp.SpatialRectangular((256, 256)),
        sampler=gp.SpatialRegularStride((256, 256)),
        window=gp.SpatialBoxcar(),
        aggregation=gp.SpatialByIndex(),
    ),
    score_op=score_pipeline,
    k=100,
    mode="top",
)(catalog)
```

**Library map.** Five packages. `ActiveSampler` lives in geotoolz (it ties together geopatcher + pipekit + a domain-specific scoring loop).

**Notes.**

- The patcher framework’s `SpatialByIndex` aggregation is the right choice here — we’re computing per-chip scores, not stitching back to a global field.
- The dirty secret of active learning (scoring is itself expensive) is operational, not framework.
- The score op returns a scalar — `pa.MeanScalar(field="sigma")` is array-shaped and lives in pipekit-array.

## Case 11 — Cross-sensor fusion (the `Graph` case)

**Imports.** `pipekit` (Graph) + `pipekit-array` (ModelOp) + `geotoolz` (SAR ops, fusion, cloud).

```python
import pipekit as pk
import pipekit_array as pa
import geotoolz as gz

opt = pk.Input("optical")
sar = pk.Input("sar")
dem = pk.Input("dem")

opt_clean = gz.cloud.MaskClouds(qa_band=-1, bits=[10, 11])(opt)
sar_db    = gz.sar.LinearToDB()(gz.sar.LeeSpeckle(window=7)(sar))
fused     = gz.fusion.AlignAndStack(target_grid="optical")(opt_clean, sar_db, dem)
classify  = pa.ModelOp(crop_classifier)(fused)

g = pk.Graph(
    inputs={"optical": opt, "sar": sar, "dem": dem},
    outputs={
        "crop_map":    classify,
        "fused_stack": fused,
    },
)

out = g(optical=s2_gt, sar=s1_gt, dem=dem_gt)
```

**Library map.** Three packages. `pipekit` for Graph; `pipekit-array` for the cross-backend ModelOp; `geotoolz` for the SAR / cloud / fusion operators.

**Notes.**

- The Graph topology is pipekit-level — carrier-agnostic.
- `AlignAndStack(target_grid="optical")` is a load-bearing operator: which input defines the target grid determines what information gets discarded. Stays a domain (geotoolz) decision.
- Multi-input arity complicates Operator validation — a `Graph` with a missing input fails at runtime, not construction time. `Graph.summary()` from pipekit (Group I) catches it at construction.

## Case 12 — Workflow orchestrator task units

**Imports.** `pipekit` (loader) + `geocatalog` (catalog) + `geotoolz` (operators in YAML) + `georeader` (substrate write). Orchestrator-specific imports (`prefect`, `dagster`) are user-side.

```python
from prefect import flow, task
import pipekit as pk
import geocatalog as gc
import geotoolz as gz
import georeader

@task(retries=3, retry_delay_seconds=60)
def run_op(op_yaml: str, slice_dict: dict) -> dict:
    op = pk.loads_yaml(open(op_yaml).read())
    sl = gc.GeoSlice.from_dict(slice_dict)
    gt = gc.load_raster(sl)
    out = op(gt)
    out_uri = georeader.save_cog(out, f"s3://daily/{slice_dict['hash']}.tif")
    return {"out_uri": out_uri, "stats": out.summary_stats()}

@flow
def daily_methane_flow(date: str):
    catalog = gc.open_catalog("s3://...")
    op_yaml = "pipelines/methane_v3.yaml"
    futures = [
        run_op.submit(op_yaml, sl.to_dict())
        for sl in catalog.iter_slices_for_date(date)
    ]
    return [f.result() for f in futures]
```

**Library map.** Four packages. The orchestrator owns retry / parallelism / monitoring; the pipekit/geocatalog/geotoolz/georeader stack owns *what to compute*. Clean separation.

**Notes.**

- `gc.GeoSlice.from_dict` round-trips the slice through JSON — the dataclass is frozen and JSON-friendly. Worth being explicit that this works.
- Pickleability discipline (Group J, Report 2) applies — every operator in the YAML must be pickleable for `run_op.submit` to ship it to a worker.
- Retries must be idempotent: the `out_uri` is deterministic from `slice_dict["hash"]`, not from `uuid4()`. Operator-level discipline.

## Case 13 — Pipeline diffing / A-B regression

**Imports.** `pipekit` (loader, diff, A-B) + `pipekit-array` (RMSE metric) + the libraries the YAMLs reference.

```python
import pipekit as pk
import pipekit_array as pa

old = pk.loads_yaml(open("pipelines/methane_v3.yaml").read())
new = pk.loads_yaml(open("pipelines/methane_v4_candidate.yaml").read())

print(pk.diff.config_diff(old, new))
# - DarkObjectSubtraction.percentile: 1
# + DarkObjectSubtraction.percentile: 2
# + LeeSpeckle (added before MatchedFilter): {window: 5}

reg = pk.diff.AB(old, new, metric=pa.metrics.RMSE())
report = reg.run(catalog.sample(100))
report.summary()
```

**Library map.** `pipekit` for the framework concerns (loader, `config_diff`, `AB` harness); `pipekit-array` for the carrier-neutral RMSE; the YAMLs’ operators come from whatever ecosystem they reference.

**Notes.**

- `pk.diff` (~200 LOC) is framework-level — it doesn’t care what the operators do, it just compares configs and runs two pipelines side-by-side.
- `pa.metrics.RMSE()` is the carrier-neutral version (works on numpy / JAX / etc.). For xarray-flavoured A-B testing, use `xr_toolz.metrics.RMSE()` which handles dim-aware comparison.
- Mean RMSE alone hides bimodal regressions — pair config-diff with per-tile distribution analysis. That’s report-design, not framework.

## Cross-case matrix — which library does each case need?

The full 7-column matrix:

|Case                           |pipekit|pipekit-array|geocatalog|geopatcher|geotoolz|xr_toolz|georeader   |
|-------------------------------|:-----:|:-----------:|:--------:|:--------:|:------:|:------:|:----------:|
|1. Notebook exploration        |✓      |             |          |          |✓       |        |(transitive)|
|2. ETL pipelines               |✓      |             |✓         |          |✓       |        |(transitive)|
|3. ML training and inference   |✓      |✓            |✓         |✓         |✓       |        |(transitive)|
|4. LitServe inference API      |✓      |             |          |          |✓       |        |✓           |
|5. FastAPI multi-pipeline      |✓      |             |          |          |✓       |        |✓           |
|6. User-uploaded pipelines     |✓      |             |          |          |✓       |        |            |
|7. Tile server                 |✓      |             |(✓)       |          |✓       |        |(transitive)|
|8. Data validation / QC        |✓      |✓            |          |          |✓       |        |            |
|9. Regulatory artifact         |✓      |             |          |          |        |        |            |
|10. Active learning            |✓      |✓            |✓         |✓         |✓       |        |(transitive)|
|11. Cross-sensor fusion (Graph)|✓      |✓            |          |          |✓       |        |            |
|12. Orchestrator task units    |✓      |             |✓         |          |✓       |        |✓           |
|13. Pipeline diffing / A-B     |✓      |✓            |          |          |✓       |        |            |

**Observations.**

1. **Every case uses pipekit.** As in Report 4 — confirms the framework belongs in its own library.
2. **`geocatalog` shows up in 4 cases** (ETL, ML, tile-server cached, orchestrator). Genuinely earned its independent slot.
3. **`geopatcher` shows up in 2 cases** (ML training/inference, active learning). Fewer cases but they’re the *most layered* — patch extraction is irreducibly its own concern.
4. **`pipekit-array` shows up in 6 cases.** Validates the split — array-shaped operations are common across deployment shapes.
5. **`georeader` shows up explicitly in 3 cases** (LitServe, FastAPI, orchestrator). These are the *direct-read* patterns where users call `read_from_url` or `save_cog` outside of a catalog flow.
6. **`xr_toolz` shows up in 0 cases.** Reflects the methane-focused bias of the 13 cases (see §xr-toolz-flavoured-gallery below).
7. **Case 9 (regulatory artifact) is pure pipekit.** Proves the framework alone is enough for some workflows — pipekit isn’t just “the substrate for the others.”

## Patterns reinforced by the new structure

Five patterns the full library shape makes obvious:

### Pattern 1 — pipekit owns deployment infrastructure; sister libraries own substrate-bound concerns

- YAML loading, config-hashing, A-B diffing, repro freeze/load, registry, sandboxed loader → pipekit
- Spatiotemporal index, queryable catalog, GeoSlice → geocatalog
- Patch-and-stitch, Field/Domain Protocols, four-axis framework → geopatcher
- GeoTensor I/O, RasterioReader, GeoData Protocol → georeader
- GeoTensor domain operators → geotoolz
- xarray domain operators → xr_toolz
- Carrier-neutral array ops → pipekit-array

Each concern has exactly one library it lives in. No duplication. No “which package do I import this from?” confusion.

### Pattern 2 — `geocatalog` + `geopatcher` are *peer infrastructure*, not “geotoolz internals”

The cases that use catalog (ETL, ML training/inference, active learning, orchestrator) interact with `geocatalog` directly, not through `geotoolz.catalog.*`. Same for patcher in Cases 3 and 10. The infrastructure is reachable as peers.

This matters more in cross-library workflows — if a user wants to combine xr_toolz processing with a catalog-driven iteration, they can `import geocatalog`; they don’t have to pull in `geotoolz`.

### Pattern 3 — three roles for `georeader`

The substrate library appears in three distinct ways across the 13 cases:

|Role                                         |Cases         |Pattern                                                           |
|---------------------------------------------|--------------|------------------------------------------------------------------|
|Transitive (through `geocatalog.load_raster`)|1, 2, 3, 7, 10|User never imports `georeader`; geocatalog calls it under the hood|
|Direct read (request-driven)                 |4, 5          |User calls `georeader.read_from_url` inline — no catalog          |
|Direct write (deliberate output path)        |5, 9, 12      |User calls `georeader.save_cog` to persist a result               |

The transitive case is most common. The direct cases are real but small.

### Pattern 4 — parallelism story changes per deployment

The four pipekit parallelism primitives (Group J) cover the deployment shapes that show up:

|Deployment                   |Primitive                  |Case|
|-----------------------------|---------------------------|----|
|Catalog-driven ETL           |`ProcessMap`               |2   |
|Single-threaded GPU inference|(none)                     |4   |
|Async I/O FastAPI            |`AsyncMap`                 |5, 7|
|Distributed across workers   |(orchestrator owns this)   |12  |
|In-pipeline batch inference  |`BatchedMap` / `pa.ModelOp`|3   |

Pipekit ships the primitives; the deployment composes them. No “auto-parallelism” anywhere.

### Pattern 5 — YAML is the lingua franca

8 of 13 cases (2, 4, 5, 6, 7, 9, 12, 13) load operator graphs from YAML. The serialisation discipline in pipekit core (`state`, `from_state`, `ConfigMixin`, `forbid_in_yaml`, `Operator.__init_subclass__` registry) is what makes this work *cross-package*. A pipeline YAML can reference `geotoolz.cloud.MaskClouds`, `pipekit_array.qc.AssertValueRange`, `geocatalog.GeoSlice` — all reconstructible because every library’s operators subclass `pipekit.Operator`.

## Where `pipekit-jax` would help (without being required)

None of the 13 cases require `pipekit-jax`. But several would benefit if it existed:

|Case                        |Benefit                                                                 |
|----------------------------|------------------------------------------------------------------------|
|3. ML training and inference|JIT-compile the inference pipeline for 5-50× speedup; vmap-batch chips  |
|4. LitServe inference API   |JIT-compile the operational pipeline; differentiable retrieval if needed|
|10. Active learning         |vmap-batched uncertainty scoring across patches                         |
|11. Cross-sensor fusion     |Differentiable fusion (e.g., learnable alignment)                       |

The substantive headline from Report 5: **pipekit-jax doesn’t change how use cases are written; it changes how fast they run** for the inference-heavy paths. It’s a v0.3+ optimisation, not a v0.1 architectural requirement.

## What an xr_toolz-flavoured gallery would look like

The 13 cases in `usecases.md` are heavily methane / MARS / RS-flavoured. An equivalent gallery for ocean / atmosphere workflows would have very different shape:

|Hypothetical xr_toolz case                        |Libraries needed                                                            |
|--------------------------------------------------|----------------------------------------------------------------------------|
|Reanalysis evaluation against in-situ             |pipekit + xr_toolz.metrics + xr_toolz.geo + geocatalog (for in-situ catalog)|
|Climatology / anomaly notebooks                   |pipekit + xr_toolz.detrend                                                  |
|Ocean kinematics on regional reanalysis           |pipekit + xr_toolz.ocn + xr_toolz.calc                                      |
|Forecast skill against analysis                   |pipekit + xr_toolz.metrics + xr_toolz.geo                                   |
|Atmospheric chemistry transport diagnostics       |pipekit + xr_toolz.atm + xr_toolz.calc                                      |
|Multi-source data fusion (ERA5 + reanalysis + obs)|pipekit + xr_toolz.transforms + xr_toolz.geo + geocatalog                   |
|Ice-sheet / cryosphere analysis                   |pipekit + xr_toolz.ice                                                      |
|Spectral analysis (PSD, wavenumber)               |pipekit + xr_toolz.transforms (xrft-backed)                                 |
|Patch-based ML on Earth System Data Cubes         |pipekit + pipekit-array + geopatcher (XarrayField) + xr_toolz               |
|Regulatory / reproducible analysis                |pipekit (same as Case 9)                                                    |

The big shift: **`xr_toolz` dominates where `geotoolz` does in the methane gallery; everything else is structurally the same.** Same pipekit, same pipekit-array, same geocatalog, same geopatcher (with `XarrayField` instead of `RasterField`). Same regulatory / orchestrator / A-B-diff patterns.

This is the strongest validation of the split: **the framework + infrastructure layer is genuinely substrate-neutral.** Swap geotoolz for xr_toolz and most of the gallery moves intact.

## Risks reconfirmed

Two risks from Report 4 + one new one from the splits:

### Risk 1 — `pipekit-array` is bigger than 12 operators look

Same as Report 4. Backend testing across numpy / JAX / CuPy / PyTorch is real work; NaN handling differs across backends. Mitigation: ship `pipekit-array[numpy]` as v0.1; add `[jax]` / `[cupy]` / `[torch]` extras as tested.

### Risk 2 — pipekit accretes infrastructure code

Repro artifacts (Case 9), config-diff + A-B (Case 13), sandboxed loader (Case 6), `loads_yaml` (most cases), `config_hash` (Cases 4, 5), registry — all live in pipekit. Total ~600-800 LOC of “framework infrastructure.” Each piece is small but together they can balloon. Mitigation: each in its own module (`pipekit.repro`, `pipekit.diff`, `pipekit.registry`, `pipekit.serialization`); thin v0.1; grow on demand.

### Risk 3 — `CatalogPipeline`-style glue accumulates in geotoolz/xr_toolz (NEW)

Several cases (2, 10, 12) need glue classes that compose pipekit + geocatalog (+ geopatcher) — `CatalogPipeline`, `ActiveSampler`, etc. These can’t live in pipekit (no geocatalog dep) or geocatalog (no pipekit dep). They live in the consumer (geotoolz or xr_toolz).

The risk: each consumer library reinvents the same glue. `geotoolz.catalog_ops.CatalogPipeline` and `xr_toolz.catalog_ops.CatalogPipeline` would be near-identical.

Mitigation options:

1. Accept the duplication. Each consumer is responsible for ~150 LOC of glue.
2. A small `pipekit-catalog` extras package: `pipekit + geocatalog` glue. Ships `CatalogPipeline`, `CatalogReader`, etc. Both geotoolz and xr_toolz depend on it.
3. Put the glue in geocatalog with an optional `geocatalog[pipekit]` extra.

Lean: **option 3** — geocatalog ships `geocatalog.integrations.pipekit.CatalogPipeline` (parallel to `geopatcher.integrations.pipekit.GridSampler`). Same pattern across both infra packages: core is framework-free; integration is extras-gated. Worth adding to Report 6’s design.

## Recommendation summary

Across 13 deployment cases, the proposed full library structure is:

- **Necessary**: every package is used by multiple cases; no package can be merged into another without forcing carrier-specific code into the wrong place.
- **Sufficient**: no case needs operators that don’t fit one of the seven libraries.
- **Clean**: each case’s import list reflects its actual scope; no awkward cross-imports; the patterns of “pipekit owns infra, sisters own substrate-bound work” hold across all 13.
- **Layered**: the typical case touches 3-4 libraries; the most complex case (3, ML inference) touches 5. None require all 7.
- **Future-ready**: pipekit-jax can be added later for inference-heavy cases without rewriting the use cases — it’s an optimisation layer, not a structural requirement.

One refinement vs Report 6: **add `geocatalog.integrations.pipekit` as a 150-LOC extras module** (`CatalogPipeline`, possibly `CatalogReader`). Parallels `geopatcher.integrations.pipekit`. Means geotoolz and xr_toolz don’t reinvent the glue.

The structure is ready. Design docs are the next step.