---
title: "Storing STAC catalogs — GeoJSON, GeoParquet, PostGIS"
subject: geotoolz tutorial
short_title: "STAC storage"
authors:
  - name: J. Emmanuel Johnson
    affiliations:
      - UNEP
      - IMEO
      - MARS
    orcid: 0000-0002-6739-0053
    email: jemanjohnson34@gmail.com
license: CC-BY-4.0
keywords: tutorial, STAC, GeoJSON, GeoParquet, PostGIS, storage, geocatalog
---

# Storing STAC Catalogs: GeoJSON, GeoParquet, PostGIS

*Three places a STAC catalog can live, plus `stac-pydantic` as the validation layer that connects them.*

-----

## The three places

A STAC Item is just a GeoJSON Feature with a known schema. Once you have one (from a search, from your own pipeline, from a static catalog crawl), you need to put it somewhere. Three realistic targets, in order of increasing infrastructure cost:

|              |Format            |Storage  |Query                              |Updates          |
|--------------|------------------|---------|-----------------------------------|-----------------|
|**GeoJSON**   |text JSON         |flat file|full scan only                     |rewrite the file |
|**GeoParquet**|columnar binary   |flat file|predicate pushdown, spatial pruning|rewrite or append|
|**PostGIS**   |relational + JSONB|database |full SQL + spatial indexes         |ACID transactions|

The data model is the same across all three — STAC’s Item/Collection structure doesn’t change. Only the *encoding* and the *access pattern* change. The same validated Pydantic object can be written to any of them.

-----

## The cross-cutting layer: `stac-pydantic`

Before talking about storage, the in-memory representation. `stac-pydantic` provides Pydantic v2 models for every STAC object — `Item`, `Collection`, `Catalog`, `Asset`, `ItemCollection`, `Link`. They validate on construction, produce typed Python attributes, and serialize cleanly back to STAC-compliant JSON.

```python
from stac_pydantic import Item, ItemCollection

# Validate raw STAC JSON → typed object
with open("scene.json") as f:
    item = Item.model_validate_json(f.read())

# Typed attribute access
item.id                            # str
item.properties.datetime           # datetime
item.geometry                      # GeoJSON model (Point/Polygon/etc.)
item.assets["B04"].href            # HttpUrl
item.assets["B04"].roles           # list[str]

# Serialize back
item.model_dump()                  # dict
item.model_dump_json(indent=2)     # str

# Custom validation for your own extensions
from stac_pydantic.item import ItemProperties

class MARSProperties(ItemProperties):
    """Project-specific extension fields."""
    mars_facility_id: str | None = None
    mars_flux_kg_hr: float | None = None
    mars_detection_confidence: float | None = None

class MARSItem(Item):
    properties: MARSProperties
```

The validated object then flows into any of the three storage backends. The same `item.model_dump()` call produces GeoJSON, the same `item` object can be serialized to a row in a Parquet file, and the same object can be inserted into PostGIS. **Pydantic is the validation seam; storage is downstream.**

A second package worth knowing: `stac-fastapi` is built on `stac-pydantic`. If you ever serve a STAC API from your own database, `stac-fastapi`’s request/response handlers will use these same models. So the Pydantic models you validate against here are byte-compatible with the API layer you might add later.

-----

## 1. GeoJSON storage

The naive baseline. A STAC `ItemCollection` is literally a GeoJSON `FeatureCollection`, so writing it to disk is one line.

### Write

```python
import json
from stac_pydantic import ItemCollection

# Build a collection from validated items
items = [Item.model_validate(d) for d in raw_dicts]
collection = ItemCollection(features=items)

# Write as a single GeoJSON file
with open("catalog.geojson", "w") as f:
    f.write(collection.model_dump_json(indent=2))
```

For larger result sets, **NDJSON** (newline-delimited JSON, one item per line) is the streaming-friendly variant — also what `pgstac` ingests:

```python
with open("items.ndjson", "w") as f:
    for item in items:
        f.write(item.model_dump_json() + "\n")
```

### Read

```python
# Whole file
with open("catalog.geojson") as f:
    collection = ItemCollection.model_validate_json(f.read())

# Streaming NDJSON
def stream_items(path):
    with open(path) as f:
        for line in f:
            yield Item.model_validate_json(line)
```

### Comparison comments

**Strengths:** trivial to produce, human-readable, opens in QGIS / kepler.gl / leaflet / anything GeoJSON-aware. Zero dependencies beyond Python stdlib. Diff-able in git.

**Weaknesses:** full-file parse for any query. No spatial index — to find “items intersecting this polygon,” you parse every Item and run the test yourself. Disk size is 5–20× larger than GeoParquet for the same content. Slow for anything past ~10k items.

**Use it when:** the catalog is small (hundreds to a few thousand items), it’s a one-off snapshot, you want QGIS to open it directly, or you’re handing it to someone outside the Python ecosystem.

**Don’t use it when:** you’ll re-query, the catalog grows over time, or you care about disk space.

-----

## 2. GeoParquet storage

The format that actually wins for snapshots. Columnar, compressed, spatially indexed at the row-group level. The `stac-geoparquet` package handles the STAC → Arrow → Parquet conversion.

### Write

```python
import stac_geoparquet

# From a list of dicts (raw STAC JSON)
record_batch_reader = stac_geoparquet.arrow.parse_stac_items_to_arrow(item_dicts)
stac_geoparquet.arrow.to_parquet(record_batch_reader, "catalog.parquet")

# From pydantic items — dump first
item_dicts = [item.model_dump(mode="json") for item in items]
rbr = stac_geoparquet.arrow.parse_stac_items_to_arrow(item_dicts)
stac_geoparquet.arrow.to_parquet(rbr, "catalog.parquet")

# Or with rustac, write straight from a search — no Python-side materialization
import rustac
await rustac.search_to(
    "catalog.parquet",
    "https://earth-search.aws.element84.com/v1",
    collections="sentinel-2-l2a",
    bbox=[-122.5, 37.5, -122.0, 38.0],
    datetime="2024-06-01/2024-06-30",
)
```

### Read

```python
# Back to STAC items (lazy iterator)
import stac_geoparquet
import pyarrow.parquet as pq

table = pq.read_table("catalog.parquet")
for item_dict in stac_geoparquet.arrow.stac_table_to_items(table):
    item = Item.model_validate(item_dict)
    ...

# As a GeoPandas DataFrame (for ad-hoc analysis)
import geopandas as gpd
gdf = gpd.read_parquet("catalog.parquet")
gdf[gdf["eo:cloud_cover"] < 20].plot()
```

### Query directly with DuckDB

This is where GeoParquet earns its keep. DuckDB reads the file with predicate pushdown — only the row groups whose statistics match the filter get touched.

```python
import duckdb

con = duckdb.connect()
con.execute("INSTALL spatial; LOAD spatial;")
con.execute("INSTALL httpfs; LOAD httpfs;")   # for s3:// or https:// parquet

# Filter on properties and geometry without loading the whole file
result = con.execute("""
    SELECT id, datetime, assets
    FROM 'catalog.parquet'
    WHERE properties['eo:cloud_cover'] < 20
      AND datetime BETWEEN '2024-06-01' AND '2024-06-30'
      AND ST_Intersects(
          geometry,
          ST_GeomFromText('POLYGON((-122.5 37.5, -122.0 37.5,
                                    -122.0 38.0, -122.5 38.0,
                                    -122.5 37.5))')
      )
""").fetchall()
```

Polars works similarly via `pl.scan_parquet(...).filter(...)` with lazy evaluation.

### Comparison comments

**Strengths:** 10–50× smaller than GeoJSON. Columnar projection (read only the fields you need). Predicate pushdown at the storage layer. Spatial pruning via bbox row-group statistics. Works on local files, S3, HTTPS without any database. DuckDB and Polars make queries feel like SQL on a file.

**Weaknesses:** not human-readable. Append is awkward (Parquet is write-once per file; “append” really means writing a new file in the same directory and treating the directory as a partitioned dataset). Schema is fixed at write time, so mixing items from collections with different `properties` keys produces sparse columns.

**Use it when:** you want a *reproducible snapshot* of a catalog query. Frozen training sets. Catalog mirrors. Anything where the data is read many times and written rarely.

**Don’t use it when:** the catalog needs continuous writes from multiple processes, or when you need a live STAC API endpoint on top.

-----

## 3. PostGIS storage

The serious-infrastructure option. PostgreSQL + PostGIS gives you concurrent writes, ACID transactions, real spatial indexes (GIST), and the ability to expose a live STAC API via `stac-fastapi`. Two paths.

### Path A: `pgstac` (the recommended default)

`pgstac` is a PostgreSQL extension that defines the schema for you — items table partitioned by collection, GIST index on geometry, btree on datetime, GIN on JSONB properties, plus stored functions implementing STAC API semantics (`/search`, `/collections`, CQL2 filtering). It backs Planetary Computer, CDSE STAC, and most production deployments.

```bash
# Install the extension into your database
pip install "pypgstac[psycopg]"
pypgstac migrate --dsn postgres://user:pw@localhost:5432/stac

# Load collections and items from NDJSON (the format we wrote in §1)
pypgstac load collections collections.ndjson --dsn postgres://... --method insert_ignore
pypgstac load items items.ndjson --dsn postgres://... --method upsert
```

Or from Python:

```python
from pypgstac.db import PgstacDB
from pypgstac.load import Loader, Methods

with PgstacDB(dsn="postgres://...") as db:
    loader = Loader(db=db)
    loader.load_items("items.ndjson", insert_mode=Methods.upsert)
```

To expose a STAC API on top (so `pystac-client` and `rustac` can query it):

```python
# stac-fastapi-pgstac wires pgstac to a FastAPI app using stac-pydantic models
from stac_fastapi.api.app import StacApi
from stac_fastapi.pgstac.config import Settings
from stac_fastapi.pgstac.core import CoreCrudClient

api = StacApi(
    settings=Settings(),
    client=CoreCrudClient(),
)
app = api.app   # standard FastAPI app, run with uvicorn
```

Now you have a real STAC API at `http://localhost:8000/search` that any STAC client can hit. `stac-pydantic` is doing the request/response validation behind the scenes.

### Path B: SQLAlchemy Core + GeoAlchemy2 (the custom path)

When you want your own schema — typically because you’re attaching STAC items to existing domain entities (e.g., your MARS plume/source/facility tables) and don’t want pgstac’s partitioning scheme — drop the ORM and use **Core**.

#### Define the table

```python
from sqlalchemy import MetaData, Table, Column, String, DateTime, Index
from sqlalchemy.dialects.postgresql import JSONB
from geoalchemy2 import Geometry

metadata = MetaData()

items_table = Table(
    "items", metadata,
    Column("id", String, primary_key=True),
    Column("collection", String, primary_key=True, index=True),
    Column("datetime", DateTime(timezone=True), nullable=True, index=True),
    Column("start_datetime", DateTime(timezone=True), nullable=True),
    Column("end_datetime", DateTime(timezone=True), nullable=True),
    Column("geometry", Geometry("GEOMETRY", srid=4326), nullable=False),
    Column("bbox", JSONB, nullable=False),
    Column("properties", JSONB, nullable=False),
    Column("assets", JSONB, nullable=False),
    Column("links", JSONB, nullable=False),
    Column("stac_version", String, nullable=False),
    Column("stac_extensions", JSONB, nullable=False, server_default="[]"),
)

# Spatial index (GIST) on geometry
Index("idx_items_geometry", items_table.c.geometry, postgresql_using="gist")
# JSONB GIN index for property queries
Index("idx_items_properties", items_table.c.properties, postgresql_using="gin")
```

Five “real” columns for the things you’ll filter on at scale (id, collection, datetime, geometry, bbox) and four JSONB columns for everything else. This mirrors pgstac’s design philosophy.

#### Ingest with Pydantic validation

The pattern: validate dict → Pydantic Item → extract fields → insert. Pydantic is the validation gate; the database never sees an invalid item.

```python
from sqlalchemy import create_engine, insert
from geoalchemy2.shape import from_shape
from shapely.geometry import shape
from stac_pydantic import Item

engine = create_engine("postgresql://user:pw@localhost:5432/stac")
metadata.create_all(engine)

def ingest_item(raw: dict) -> None:
    # 1. Validate with stac-pydantic — raises if malformed
    item = Item.model_validate(raw)

    # 2. Convert geometry to PostGIS WKB
    geom = from_shape(shape(item.geometry.model_dump()), srid=4326)

    # 3. Insert via Core
    stmt = insert(items_table).values(
        id=item.id,
        collection=item.collection,
        datetime=item.properties.datetime,
        start_datetime=item.properties.start_datetime,
        end_datetime=item.properties.end_datetime,
        geometry=geom,
        bbox=list(item.bbox),
        properties=item.properties.model_dump(mode="json", exclude_none=True),
        assets={k: v.model_dump(mode="json") for k, v in item.assets.items()},
        links=[l.model_dump(mode="json") for l in item.links],
        stac_version=item.stac_version,
        stac_extensions=item.stac_extensions or [],
    )
    with engine.begin() as conn:
        conn.execute(stmt)
```

Batch ingestion is faster — collect rows into a list and use `conn.execute(insert(items_table), rows)` for a single round-trip.

#### Query with Core + GeoAlchemy2

```python
from sqlalchemy import select, cast, Float
from geoalchemy2.functions import ST_Intersects, ST_GeomFromText

stmt = (
    select(
        items_table.c.id,
        items_table.c.datetime,
        items_table.c.assets,
    )
    .where(items_table.c.collection == "sentinel-2-l2a")
    .where(items_table.c.datetime.between("2024-06-01", "2024-06-30"))
    .where(
        cast(items_table.c.properties["eo:cloud_cover"].astext, Float) < 20
    )
    .where(
        ST_Intersects(
            items_table.c.geometry,
            ST_GeomFromText(
                "POLYGON((-122.5 37.5, -122.0 37.5, "
                "-122.0 38.0, -122.5 38.0, -122.5 37.5))",
                4326,
            ),
        )
    )
    .order_by(items_table.c.datetime.desc())
    .limit(100)
)

with engine.connect() as conn:
    rows = conn.execute(stmt).all()
```

#### Reconstruct Pydantic items on read

If you want to hand the results back as validated STAC items (e.g., to a downstream consumer expecting STAC JSON):

```python
def row_to_item(row, engine) -> Item:
    """Reconstruct a STAC Item from a database row."""
    # Fetch geometry as GeoJSON via PostGIS
    from geoalchemy2.shape import to_shape
    from shapely.geometry import mapping

    raw = {
        "type": "Feature",
        "stac_version": row.stac_version,
        "stac_extensions": row.stac_extensions,
        "id": row.id,
        "collection": row.collection,
        "geometry": mapping(to_shape(row.geometry)),
        "bbox": row.bbox,
        "properties": row.properties,
        "assets": row.assets,
        "links": row.links,
    }
    return Item.model_validate(raw)
```

Now the same Pydantic `Item` shape comes out the other end of the round-trip. If you mounted this behind FastAPI, the response model would be `ItemCollection` and FastAPI + stac-pydantic would handle serialization to STAC-compliant JSON automatically:

```python
from fastapi import FastAPI
from stac_pydantic import ItemCollection

app = FastAPI()

@app.get("/search", response_model=ItemCollection)
def search(collection: str, bbox: str, datetime: str) -> ItemCollection:
    # ... run the Core query as above ...
    items = [row_to_item(row, engine) for row in rows]
    return ItemCollection(features=items)
```

That’s a custom STAC API endpoint in ~30 lines. The Pydantic models guarantee the output is STAC-conformant; clients like `pystac-client` and `rustac` can query it without knowing it’s custom.

### Comparison comments

**Strengths of pgstac:** production-ready, partitioned schema, stored functions implementing CQL2, drop-in `stac-fastapi-pgstac` for serving. If you need a STAC API on your own data, this is the path.

**Weaknesses of pgstac:** opinionated schema. Hard to extend with your own non-STAC columns without diverging from upstream. The partitioning model assumes one table per collection, which can become a lot of partitions if you have many small collections.

**Strengths of Core + GeoAlchemy2:** your schema, your foreign keys. The items table can reference your existing domain tables (`plumes.detected_in_item_id → items.id`) cleanly. Pydantic at the boundary keeps STAC validation rigorous without forcing ORM ceremony on every row. Works alongside your existing SQLAlchemy ORM models.

**Weaknesses of Core + GeoAlchemy2:** you implement the API yourself if you want one. CQL2 filtering becomes your problem. Indexes, partitioning, vacuuming, all hand-tuned.

**Use pgstac when:** you want a public-or-internal STAC API on your data, you have many items per collection, and you don’t have strong opinions about the schema.

**Use Core + GeoAlchemy2 when:** STAC items are part of a larger domain database (MARS), you need foreign keys from your tables to items, or you need columns and indexes pgstac doesn’t provide.

-----

## Side-by-side comparison

|                        |GeoJSON                 |GeoParquet                   |PostGIS (pgstac)               |PostGIS (Core)            |
|------------------------|------------------------|-----------------------------|-------------------------------|--------------------------|
|**Setup cost**          |none                    |`pip install stac-geoparquet`|PostgreSQL + extension + ingest|PostgreSQL + custom schema|
|**Write cost**          |trivial                 |one-shot batch               |streaming via pypgstac         |custom ingestion code     |
|**Read cost**           |full parse              |predicate pushdown           |indexed SQL                    |indexed SQL               |
|**Disk size (relative)**|1×                      |0.05–0.10×                   |~0.30× (in DB)                 |~0.30× (in DB)            |
|**Spatial index**       |none                    |row-group bbox               |GIST                           |GIST (you add it)         |
|**Concurrent writes**   |no                      |no (rewrite)                 |yes (ACID)                     |yes (ACID)                |
|**Query language**      |Python                  |DuckDB/Polars/SQL            |CQL2 + SQL                     |SQL (you build CQL2)      |
|**API on top**          |none                    |TiTiler-pgstac partial       |`stac-fastapi-pgstac`          |hand-rolled FastAPI       |
|**Pydantic integration**|direct (read/write JSON)|dump-then-write              |validation at boundary         |validation at boundary    |
|**Human-readable**      |yes                     |no                           |via SQL                        |via SQL                   |
|**QGIS-compatible**     |yes                     |yes (recent versions)        |yes (PostGIS connection)       |yes (PostGIS connection)  |
|**Best for**            |quick exports, debugging|snapshots, batch ML          |live multi-tenant catalog      |catalog tied to domain DB |

-----

## A decision guide

**“I just need to dump the result of one search and move on”** → GeoJSON.

**“I’m building a reproducible training set for plumax / methane retrievals”** → GeoParquet. Snapshot the search, version the file, query with DuckDB during training. No database needed.

**“I want to expose a STAC API for my organization, mirroring an external catalog or hosting our own scenes”** → pgstac + `stac-fastapi-pgstac`. Don’t reinvent the schema.

**“MARS already has plumes, sources, facilities in PostgreSQL via SQLAlchemy ORM, and I want a STAC items table alongside them with foreign keys both ways”** → SQLAlchemy Core + GeoAlchemy2 with the table shown above. Keep your existing ORM for domain entities, add Core-only access for the items table, and put stac-pydantic at the validation boundary. If you later want a STAC API, build a thin FastAPI endpoint that returns `ItemCollection` Pydantic models.

**“I’m not sure yet”** → start with GeoParquet. It’s the lowest-commitment option that actually scales. Move to PostGIS only when you need concurrent writes, a live API, or foreign keys.

-----

## The pattern that emerges

Across all three storage backends, the same shape recurs:

```
                       ┌──────────────────────┐
                       │   stac-pydantic      │   validation layer
                       │   Item / Collection  │   typed, validated, serializable
                       │   ItemCollection     │
                       └──────────┬───────────┘
                                  │
        ┌─────────────────────────┼─────────────────────────┐
        ▼                         ▼                         ▼
  ┌──────────┐             ┌──────────────┐         ┌─────────────────┐
  │ GeoJSON  │             │ GeoParquet   │         │   PostGIS       │
  │  *.json  │             │  *.parquet   │         │  items table    │
  │  *.ndjson│             │              │         │  (pgstac or     │
  │          │             │              │         │   Core+GeoAl.)  │
  └──────────┘             └──────────────┘         └─────────────────┘
```

The Pydantic layer is what keeps the backends interchangeable. Validate once on ingest, dump to whichever format you need on output, validate again on read. The catalog data model never changes; only the *substrate* changes underneath it.

For your specific stack: MARS gets Core + GeoAlchemy2 with stac-pydantic at the boundary. Plumax training snapshots get GeoParquet via rustac. GeoJSON is for the rare “open this in QGIS for a sanity check” moment. All three coexist; nothing competes; the Pydantic models stitch them together.