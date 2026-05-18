---
title: "STAC — a background primer"
subject: geotoolz tutorial
short_title: "STAC primer"
authors:
  - name: J. Emmanuel Johnson
    affiliations:
      - UNEP
      - IMEO
      - MARS
    orcid: 0000-0002-6739-0053
    email: jemanjohnson34@gmail.com
license: CC-BY-4.0
keywords: tutorial, geotoolz, STAC, spatiotemporal-asset-catalog, geocatalog
---

# STAC: A Background Primer

*A precursor to the rustac and pystac catalog recipes. Read this first if STAC is new; skim it for the technical sections if it isn’t.*

-----

# Part 1 — ELI5: What problem does STAC solve?

## The pre-STAC world

Before 2018, every organization that hosted satellite data invented their own way to describe it.

USGS had one format for Landsat scenes. ESA had a different one for Sentinel. NASA had a third for MODIS, a fourth for ASTER, a fifth for GEDI. Planet had their own. DigitalGlobe (now Maxar) had their own. Every research data center had a custom CSV or a custom REST API or a custom FTP directory layout.

If you wrote code to search Landsat by date and bounding box, none of that code worked for Sentinel-2. You’d write it again. And again for MODIS. And again for the next provider. The fields had different names: one provider called it `cloud_cover`, another `cloudCoverPercentage`, a third `cloud_%`, a fourth had no cloud field at all and you had to compute it from a quality mask. Some providers expressed time as ISO strings, some as Unix timestamps, some as day-of-year + year. Bounding boxes were `[west, south, east, north]` for some, `[north, south, east, west]` for others.

The result: every team that worked with multi-source EO data spent a depressing percentage of their time on **metadata plumbing** — translating between provider conventions just to get to the point where they could actually look at pixels.

## The analogy: library card catalogs

Imagine you walk into a library. The books exist — they’re on shelves. But to find a specific book by Hemingway from 1952, you don’t walk through every aisle reading spines. You go to the card catalog, look up “Hemingway, Ernest”, find the cards for his books, see the call number, and walk straight to the shelf.

The card catalog isn’t the books. The card catalog is **metadata about the books** — title, author, year, subject, and crucially, the call number that tells you where to physically find each one.

**STAC is the card catalog for satellite data.** Each card (a STAC *Item*) tells you what the scene is (sensor, date, footprint, cloud cover), and the call number on the card (the asset *hrefs*) tells you where to find the actual pixel files. The pixels live somewhere on S3 or Azure Blob or wherever; the STAC catalog tells you what’s available and where to fetch it.

The genius of card catalogs wasn’t that they were beautiful — they were ugly drawers of typed index cards. The genius was that **every library used the same card format**. Once you knew how to read a Dewey Decimal card, you could use any library in the country. STAC is the same idea: agree on a card format for Earth observation, and anyone who follows the format becomes searchable with the same tools.

## Another analogy: Airbnb listings

Every Airbnb property in the world is described with the same fields: location, available dates, price per night, photos, amenities checkbox list, reviews. The properties themselves are wildly different — castles in France, surf shacks in Bali, suburban guesthouses in Ohio — but the *description schema* is identical.

That’s why Airbnb’s search works. You can ask “show me 2-bedroom places near Lisbon under €100/night, available next weekend” and the engine doesn’t care that one property is a castle and another is a houseboat. The schema is uniform.

STAC items are like Airbnb listings for satellite scenes. The scenes themselves are wildly different — multispectral optical, SAR, hyperspectral, lidar point clouds — but the description schema is identical. You can ask “show me all scenes intersecting this polygon, between these dates, with less than 20% cloud cover” and the engine doesn’t care whether the scenes are Sentinel-2 or EMIT or PRISMA.

## What STAC actually is, in one sentence

> STAC is a JSON specification that says: a satellite scene is described as a GeoJSON Feature with these required fields (id, datetime, geometry, bbox, assets), and you organize scenes into Collections, and Collections into Catalogs, and if you want to serve them over HTTP there’s a small REST API spec for that too.

That’s it. STAC isn’t a database, it isn’t a file format for pixels, it isn’t a processing engine. **It’s a metadata convention.** Everything else in the ecosystem (rustac, pystac, planetary-computer, stackstac, the catalogs themselves) is built around that one convention.

## Why this is more than convenience

The deep reason STAC matters isn’t that it saves you typing. It’s that **it decouples discovery from access**.

In the pre-STAC world, “search” and “download” were welded together. To find Landsat scenes, you used USGS’s interface, which knew how to talk to USGS’s data store. To find Sentinel-2 scenes, you used Copernicus’s interface, which knew about Copernicus’s data store. The search was tied to the storage.

With STAC, search returns *hrefs* — URLs to files. Those files can live anywhere. Same STAC catalog can point to assets on AWS, on Azure, on the local filesystem, on a USGS server. **The catalog and the bytes are independent.**

This matters because it means:

- You can mirror a catalog to a new cloud provider without breaking clients.
- You can build a derived catalog (e.g., “all Sentinel-2 scenes that intersect my study area, with my own cloud mask appended”) without re-hosting the pixels.
- You can persist a catalog snapshot for reproducibility (stac-geoparquet) without copying terabytes of imagery.
- You can serve the same metadata to different audiences (a public catalog and a paywalled one) with different asset hrefs.

The pixels are heavy. The metadata is light. STAC makes the metadata move freely while the pixels stay put. That separation is the load-bearing idea of the whole ecosystem.

-----

# Part 2 — The shape of STAC

## The three objects

STAC has exactly three core object types. You’ll see them everywhere.

```
            ┌─────────────────────┐
            │       Catalog       │   "Here's what I have"
            │   (a directory)     │
            └──────────┬──────────┘
                       │
            ┌──────────┴──────────┐
            │     Collection      │   "A homogeneous dataset"
            │  (Sentinel-2 L2A)   │
            └──────────┬──────────┘
                       │
                ┌──────┴──────┐
                │             │
        ┌───────┴──────┐   ┌──┴──────────┐
        │     Item     │   │     Item    │   "A single scene"
        │ (one scene)  │   │ (one scene) │
        └──────┬───────┘   └─────────────┘
               │
       ┌───────┼───────┐
       │       │       │
   ┌───┴──┐ ┌──┴──┐ ┌──┴────┐
   │Asset │ │Asset│ │ Asset │              "A single file"
   │ B04  │ │ B08 │ │  TCI  │
   └──────┘ └─────┘ └───────┘
```

**Catalog** — A grouping container. It has an `id`, a `description`, and a list of `links` to children (other Catalogs, or Collections, or Items). That’s all a Catalog *must* have. It’s basically a folder.

**Collection** — A Catalog with more fields. Adds spatial/temporal extents, license, providers, keywords, and (importantly) a description of what fields and assets every Item in the Collection will have. “Sentinel-2 L2A” is a Collection. “Landsat Collection 2 Level-2 Surface Reflectance” is a Collection. A Collection is the unit at which datasets are advertised and licensed.

**Item** — A GeoJSON Feature representing one observation: one Sentinel-2 scene from one orbit, one EMIT granule, one Landsat tile from one date. The Item has a geometry (the scene footprint), a datetime, properties (cloud cover, sun angle, processing version, whatever), and `assets` — a dict of file references.

**Asset** — Not a top-level object, but a sub-component of an Item. An Asset is one file: a single band, a thumbnail, a metadata XML, a processing JSON. Each Asset has an `href`, a `type` (MIME type), `roles` (semantic tags like `data`, `thumbnail`, `overview`), and optional metadata like `eo:bands` or `raster:bands`.

## A real Item, annotated

Here’s a (lightly simplified) Sentinel-2 L2A Item from Element 84’s Earth Search:

```json
{
  "type": "Feature",                                     // GeoJSON Feature type
  "stac_version": "1.0.0",                              // STAC spec version
  "stac_extensions": [                                   // Optional extensions in use
    "https://stac-extensions.github.io/eo/v1.1.0/schema.json",
    "https://stac-extensions.github.io/projection/v1.1.0/schema.json"
  ],
  "id": "S2A_10SEG_20240615_0_L2A",                     // Unique within its Collection
  "collection": "sentinel-2-l2a",                       // Which Collection this Item belongs to

  "geometry": {                                          // Footprint as GeoJSON geometry
    "type": "Polygon",
    "coordinates": [[[ -122.5, 37.5 ], [ -122.0, 37.5 ],
                     [ -122.0, 38.0 ], [ -122.5, 38.0 ],
                     [ -122.5, 37.5 ]]]
  },
  "bbox": [-122.5, 37.5, -122.0, 38.0],                 // [west, south, east, north]

  "properties": {
    "datetime": "2024-06-15T18:42:13Z",                 // Acquisition time, ISO 8601
    "eo:cloud_cover": 4.2,                              // From the EO extension
    "proj:epsg": 32610,                                 // From the projection extension
    "proj:shape": [10980, 10980],
    "proj:transform": [10, 0, 499980, 0, -10, 4200000, 0, 0, 1],
    "platform": "sentinel-2a",
    "instruments": ["msi"],
    "gsd": 10
  },

  "assets": {                                            // Files this Item points to
    "red": {
      "href": "s3://sentinel-cogs/sentinel-s2-l2a-cogs/.../B04.tif",
      "type": "image/tiff; application=geotiff; profile=cloud-optimized",
      "title": "Red - 10m",
      "roles": ["data", "reflectance"],
      "eo:bands": [{"name": "B04", "center_wavelength": 0.665}],
      "gsd": 10
    },
    "nir": {
      "href": "s3://sentinel-cogs/.../B08.tif",
      "type": "image/tiff; application=geotiff; profile=cloud-optimized",
      "roles": ["data", "reflectance"],
      "eo:bands": [{"name": "B08", "center_wavelength": 0.842}]
    },
    "thumbnail": {
      "href": "https://.../thumbnail.jpg",
      "type": "image/jpeg",
      "roles": ["thumbnail"]
    }
  },

  "links": [                                             // Relationships to other STAC objects
    {"rel": "self",       "href": "https://earth-search.../items/S2A_10SEG_..."},
    {"rel": "parent",     "href": "https://earth-search.../collections/sentinel-2-l2a"},
    {"rel": "collection", "href": "https://earth-search.../collections/sentinel-2-l2a"},
    {"rel": "root",       "href": "https://earth-search.aws.element84.com/v1"}
  ]
}
```

Look at this carefully. Everything STAC does is in this object:

- It’s literally a GeoJSON Feature (the `type: "Feature"` at the top is the GeoJSON discriminator) — which means QGIS, Leaflet, and every GeoJSON-aware tool already understands the geometry without knowing what STAC is.
- The `properties` dict carries scene-level metadata.
- The `assets` dict is the bridge to the actual data.
- The `links` array makes the catalog crawlable: from any Item you can walk back up to its Collection and Catalog.

## Static vs dynamic catalogs

There are two ways to host a STAC catalog, and the distinction has real operational consequences.

**Static catalog** — Just a tree of JSON files on a filesystem or object store. The Catalog JSON has links to Collection JSONs, which have links to Item JSONs. Crawling = following links and reading files. There’s no server, no database, no search.

```
s3://my-bucket/catalog.json
                 └── points to: collection-1/collection.json
                                   ├── item-001.json
                                   ├── item-002.json
                                   └── item-003.json
```

Static catalogs are trivial to publish — `aws s3 sync` and you’re done. They’re great for small, stable datasets. The downside is you can’t *query* them server-side; to find “items intersecting my AOI” you have to crawl every Item file (or build a sidecar index, which is what stac-geoparquet does).

**Dynamic catalog** — A REST API backed by a real database, exposing `/collections`, `/search`, `/items`, etc. You send query parameters; the server runs SQL or a spatial index and returns matching Items. Planetary Computer, Earth Search, CDSE STAC, CMR-STAC: all dynamic. All ~6 catalogs in the recipe files are dynamic.

```
GET https://my-api.example.com/search?bbox=-122.5,37.5,-122.0,38.0&datetime=2024-06-01/2024-06-30
```

Both flavors implement the same Item/Collection JSON spec. The dynamic API spec is a separate document that says “if you want to serve STAC over HTTP, here are the endpoints and the parameters they accept.” Most production catalogs are dynamic; many open-data catalogs (Capella Open, Umbra Open, Maxar Open Data) are static.

-----

# Part 3 — The technical details, pedantically

## The four specifications

STAC is not one specification. It’s four, layered:

1. **STAC Item spec** — defines the Item JSON object (the “card” in our library catalog analogy).
2. **STAC Catalog spec** — defines the Catalog JSON object (the directory structure).
3. **STAC Collection spec** — defines the Collection JSON object (a Catalog with dataset-level metadata).
4. **STAC API spec** — defines the REST API for serving the above objects dynamically.

The first three are tiny documents — each is roughly 5–10 pages of markdown defining required and optional fields. The fourth is bigger because REST APIs have more surface area (pagination, filtering, conformance, OpenAPI schemas).

Current version as of early 2026: **STAC core 1.1.0**, **STAC API 1.0.0**. The specs have been stable for several years; breaking changes are rare and well-telegraphed.

## Required fields, pedantically

**Item** required fields:

- `type`: must be the string `"Feature"`. Inherited from GeoJSON.
- `stac_version`: e.g. `"1.0.0"` or `"1.1.0"`. Lets clients negotiate compatibility.
- `id`: A string unique within the parent Collection. Often the scene/granule identifier.
- `geometry`: A GeoJSON geometry. May be `null` only if `bbox` is also null (rare).
- `bbox`: 4 or 6 numbers (`[west, south, east, north]` or with elevation). Always required if `geometry` is non-null.
- `properties`: An object containing at minimum a `datetime` (ISO 8601 string) or both `start_datetime` and `end_datetime`. `datetime` may be `null` *only* if the range fields are provided.
- `assets`: A dict mapping asset keys to asset objects.
- `links`: An array of link objects. At minimum should include `self`, `root`, and ideally `parent` and `collection`.

**Collection** required fields (a Collection is also a Catalog, so it inherits Catalog requirements):

- `type`: `"Collection"`
- `stac_version`
- `id`: unique within its parent Catalog
- `description`: human-readable text
- `license`: SPDX identifier (e.g. `"CC-BY-4.0"`) or `"proprietary"`
- `extent`: an object with `spatial` and `temporal` sub-objects defining the bounding extents of all Items.
- `links`: array. Should include `self`, `root`, `parent`, and `items` (pointing to where the items live).

**Catalog** required fields:

- `type`: `"Catalog"`
- `stac_version`
- `id`
- `description`
- `links`

That’s it. Everything else (sensor name, cloud cover, processing chain, sun angle, CRS, all of it) is either in `properties` as ad-hoc keys or formalized via extensions.

## The datetime/bbox/geometry triad — common gotchas

**Datetime semantics:**

- A scalar `datetime` is a *single instant* — the acquisition time, typically the start of the integration.
- For datasets that aggregate over a window (e.g. monthly composites, multi-day mosaics), the convention is `datetime: null` plus `start_datetime` and `end_datetime`. Clients filter on the range.
- Both styles can coexist in one Item (`datetime` = nominal acquisition, `start_datetime`/`end_datetime` = full integration window).
- Timezone is required: ISO 8601 with `Z` (UTC) or an explicit offset. Naive timestamps are non-conformant.

**Geometry vs bbox:**

- `geometry` is the *exact* footprint, often a polygon with many vertices.
- `bbox` is the *axis-aligned bounding box* of the geometry — strictly redundant, but required because spatial indexes work on bboxes and many clients filter on bbox before geometry.
- They can disagree in pathological cases (Item authors should keep them consistent; many do not).
- Geometry coordinates are always WGS84 longitude/latitude regardless of the underlying raster CRS. This is a GeoJSON inheritance, not a STAC choice.
- The `proj` extension carries the *raster* CRS (via `proj:epsg`, `proj:wkt2`, etc.), which is different from and usually not WGS84.

**Antimeridian:**

- Items that cross the 180° meridian require `bbox` that uses `> 180` longitudes by convention, or the geometry split into two polygons. Few clients handle this consistently. EMIT and some polar Landsat scenes are common offenders.

## Assets — the part everyone gets wrong

Assets have four standard sub-fields and a lot of optional ones.

```json
"B04": {
  "href": "s3://...",         // Where the file lives. Required.
  "type": "image/tiff; ...",  // MIME type. Helps clients pick a reader.
  "title": "Red band",        // Optional human-readable name.
  "roles": ["data"]           // Semantic tags. Critical and underused.
}
```

**Roles** vs **type** is the confusion point. The `type` is the *file format* (GeoTIFF, JPEG, NetCDF, JSON). The `roles` is the *semantic purpose*. Both are needed because the same MIME type can have different semantic roles: a GeoTIFF can be `data`, `thumbnail`, `overview`, `metadata`, or `mask`.

Standard role conventions (not strictly enforced but widely used):

- `data` — the actual scientific measurement
- `thumbnail` — small preview image
- `overview` — medium-resolution preview
- `metadata` — supporting metadata file (XML, JSON, MTL)
- `visual` — RGB visualization (Sentinel-2 TCI)
- `reflectance`, `temperature`, `saturation`, `cloud`, `cloud-shadow`, `snow-ice` — semantic tags about measurement type
- `mask` — boolean or categorical mask raster

**Asset keys** (`"B04"` in the example above) are *not* standardized. One catalog might call the Sentinel-2 red band `"B04"`, another `"red"`, another `"sentinel2-red-10m"`. This is a real interoperability pain. The `item-assets` extension on the Collection level helps by declaring “every Item in this Collection has these asset keys with these meanings” — read the Collection’s `item_assets` field before assuming key names.

## Links — STAC’s hypermedia layer

STAC borrows from HATEOAS (Hypermedia As The Engine Of Application State): every object carries a `links` array that lets you navigate to related objects without knowing URL structure ahead of time.

Standard link relations:

- `self` — canonical URL of this object
- `root` — top of the catalog tree
- `parent` — one level up
- `child` — points to a child Catalog or Collection (from a parent)
- `item` — points to an Item (from a Collection)
- `collection` — points to the Collection (from an Item)
- `search` — points to the API search endpoint (from the root)
- `next`, `prev` — pagination
- `derived_from` — provenance: this Item was derived from another Item
- `via` — points to the source of the metadata (e.g. provider’s original page)

The practical upshot: any client can crawl any STAC catalog by following links, starting from one URL. You don’t need provider-specific knowledge of URL patterns. This is why static catalogs work — you give a client the root catalog.json URL and it can recursively discover everything.

-----

# Part 4 — The STAC API

The first three specs define static JSON. The fourth — STAC API — defines how to serve that JSON dynamically.

## The endpoint shape

A minimal STAC API exposes:

```
GET /                          → Landing page (root Catalog with links)
GET /conformance               → List of conformance classes the API implements
GET /collections               → All Collections
GET /collections/{id}          → One Collection
GET /collections/{id}/items    → Items in that Collection (with filters)
GET /collections/{id}/items/{id} → One Item
GET /search                    → Cross-collection search (POST also supported)
POST /search                   → Same, with JSON body for complex queries
```

The `/search` endpoint is the workhorse. Query parameters:

|Param                   |Meaning                                                                                             |
|------------------------|----------------------------------------------------------------------------------------------------|
|`collections`           |List of collection IDs to restrict to                                                               |
|`ids`                   |Specific item IDs to fetch                                                                          |
|`bbox`                  |`west,south,east,north`                                                                             |
|`datetime`              |Single instant `2024-06-15T00:00:00Z` or range `2024-06-01/2024-06-30` or open range `2024-06-01/..`|
|`intersects`            |GeoJSON geometry (POST only — too big for query string)                                             |
|`limit`                 |Items per page (typically capped at 100–1000)                                                       |
|`query`                 |Property filter (older syntax: `{"eo:cloud_cover": {"lt": 20}}`)                                    |
|`filter` + `filter-lang`|CQL2 filter (newer, more expressive)                                                                |
|`sortby`                |e.g. `-properties.datetime` for descending by date                                                  |
|`fields`                |Subset which fields to return (faster, smaller responses)                                           |

## OGC API Features lineage

STAC API is a *profile* of OGC API Features, the OGC’s standard for serving Feature data over HTTP. Specifically:

- `/collections`, `/collections/{id}`, `/collections/{id}/items` are OGC API Features endpoints.
- `/search` is the STAC-specific addition (OGC API Features doesn’t have cross-collection search).

This matters because tools built for OGC API Features (some GIS clients, MapServer/GeoServer integrations) work against STAC APIs out of the box at the per-collection level. STAC just adds capability rather than replacing.

## Conformance classes

An API advertises what it supports by returning a list of *conformance class* URIs at `/conformance` and in the root landing page:

```json
{
  "conformsTo": [
    "https://api.stacspec.org/v1.0.0/core",
    "https://api.stacspec.org/v1.0.0/collections",
    "https://api.stacspec.org/v1.0.0/ogcapi-features",
    "https://api.stacspec.org/v1.0.0/item-search",
    "https://api.stacspec.org/v1.0.0/item-search#filter",
    "https://api.stacspec.org/v1.0.0/item-search#sort",
    "https://api.stacspec.org/v1.0.0/item-search#fields",
    "http://www.opengis.net/spec/cql2/1.0/conf/cql2-text",
    "http://www.opengis.net/spec/cql2/1.0/conf/cql2-json"
  ]
}
```

Reading this list tells you what queries the API will accept. Common conformance classes:

- `core` — minimum (just a landing page and conformance)
- `collections` — `/collections` listing works
- `ogcapi-features` — full per-collection items endpoint
- `item-search` — cross-collection `/search`
- `item-search#filter` — supports CQL2 filtering
- `item-search#sort` — supports `sortby`
- `item-search#fields` — supports field subsetting
- `item-search#query` — supports the older `query` parameter

`pystac-client` reads conformance classes at `Client.open()` time and uses them to decide how to construct requests. If you ask for a `filter=` query against an API that doesn’t conform to `item-search#filter`, the client either falls back to client-side filtering or errors out (depending on version).

## CQL2 — the filter language

The newer, more expressive filter syntax is **CQL2** (Common Query Language 2), an OGC standard. Two encodings:

**CQL2-text:**

```
eo:cloud_cover <= 10 AND datetime >= TIMESTAMP('2024-06-01T00:00:00Z')
```

**CQL2-JSON:**

```json
{
  "op": "and",
  "args": [
    {"op": "<=", "args": [{"property": "eo:cloud_cover"}, 10]},
    {"op": ">=", "args": [{"property": "datetime"},
                          {"timestamp": "2024-06-01T00:00:00Z"}]}
  ]
}
```

The JSON form is what you build programmatically; the text form is what you’d type in a URL or paste into a browser. They’re isomorphic and most APIs accept both via the `filter-lang` parameter.

Supported operators usually include: comparison (`=`, `<>`, `<`, `<=`, `>`, `>=`), logical (`and`, `or`, `not`), pattern matching (`like`), set (`in`), spatial (`s_intersects`, `s_within`, `s_contains`), and temporal (`t_after`, `t_before`, `t_during`).

CQL2 is much more expressive than the legacy `query` parameter — you can do nested boolean logic, spatial predicates against arbitrary geometries, mixed temporal/spatial/attribute queries. Worth learning if you’re doing anything beyond bbox + date.

-----

# Part 5 — Extensions: how STAC stays small

The STAC core is intentionally minimal. It barely cares about EO. The geometry could be any geographic asset — a building footprint, a weather station location, a sensor track. To keep core simple, domain-specific metadata is **opt-in via extensions**.

An extension is a separately versioned schema that adds new fields with a namespace prefix. An Item that uses the `eo` extension declares it in `stac_extensions` and adds `eo:cloud_cover`, `eo:bands`, etc.

## Extensions worth knowing

|Extension                       |Adds                                                                                   |Used by                                               |
|--------------------------------|---------------------------------------------------------------------------------------|------------------------------------------------------|
|`eo` (electro-optical)          |`eo:cloud_cover`, `eo:bands` (name, center_wavelength, fwhm), `eo:snow_cover`          |Every optical sensor                                  |
|`proj` (projection)             |`proj:epsg`, `proj:wkt2`, `proj:transform`, `proj:shape`                               |Anything that’s a raster                              |
|`raster`                        |`raster:bands` with data type, nodata, scale/offset, unit, histogram                   |Modern COG-based catalogs                             |
|`sat`                           |`sat:orbit_state`, `sat:relative_orbit`, `sat:platform_international_designator`       |All satellites                                        |
|`view`                          |`view:sun_azimuth`, `view:sun_elevation`, `view:off_nadir`, `view:incidence_angle`     |Solar/viewing geometry                                |
|`sar`                           |`sar:polarizations`, `sar:frequency_band`, `sar:instrument_mode`, `sar:product_type`   |All SAR sensors                                       |
|`item-assets` (Collection-level)|`item_assets` dict declaring “all my Items have these assets”                          |Most production catalogs                              |
|`processing`                    |`processing:level`, `processing:software`, `processing:datetime`, `processing:facility`|Provenance                                            |
|`scientific`                    |`sci:doi`, `sci:citation`, `sci:publications`                                          |Research datasets                                     |
|`label` (ML)                    |`label:properties`, `label:classes`, `label:methods`, `label:overviews`                |Labeled training datasets                             |
|`mlm` (Machine Learning Model)  |`mlm:framework`, `mlm:architecture`, `mlm:tasks`, `mlm:hyperparameters`                |Model artifact catalogs                               |
|`version`                       |`version`, `deprecated`                                                                |Versioned products                                    |
|`classification`                |`classification:classes`, `classification:bitfields`                                   |Categorical rasters (Sentinel-2 SCL, MODIS land cover)|
|`electro_optical` legacy        |(now part of `eo`)                                                                     |Older catalogs                                        |
|`datacube`                      |`cube:dimensions`, `cube:variables`                                                    |Multi-dimensional Zarr-backed assets                  |

The full registry is at **stac-extensions.github.io**. Treat extensions like Python packages — pin the version (e.g. `https://stac-extensions.github.io/eo/v1.1.0/schema.json`) and check release notes when upgrading catalogs you publish.

## Why this design wins

If STAC put `eo:cloud_cover` in the core, every non-optical catalog (SAR, lidar, point clouds, building footprints, weather stations) would carry a meaningless field. By making it an extension, optical catalogs opt in, SAR catalogs use the `sar` extension instead, and the core stays universal.

The cost is a small ceremony: clients have to check `stac_extensions` and consult the schema. In practice, most clients ignore this and treat all `properties` keys as opaque — which works fine as long as you know which fields you expect from a given Collection.

-----

# Part 6 — stac-geoparquet: the columnar future

JSON is great for individual Items and small catalogs. It falls over for *large* catalogs. A Sentinel-2 archive with 50 million Items is hundreds of GB of JSON; parsing it to filter for “scenes over Europe in 2024 with <10% cloud” is hours of work.

**stac-geoparquet** is a relatively new convention (~2022, formalized 2024) that stores STAC Items as rows in a [GeoParquet](https://geoparquet.org/) file. Each Item becomes one row; properties become columns; geometry uses GeoParquet’s WKB encoding; assets are stored as a nested struct column.

The benefits:

- **Columnar projection.** Need just `id` and `datetime`? Read only those columns. JSON forces you to parse the whole document.
- **Spatial indexing.** GeoParquet uses bbox columns and row-group statistics; spatial filters can prune entire row groups without reading them.
- **Predicate pushdown.** `WHERE eo:cloud_cover < 20` evaluated by DuckDB or Polars on the parquet file is orders of magnitude faster than the equivalent JSON scan.
- **Compression.** Items repeat a lot of metadata; columnar storage with dictionary encoding crushes the size 10–50×.

It does *not* replace the STAC API. The API is for live querying; stac-geoparquet is for **snapshots**: a frozen point-in-time export of a catalog (or a search result) that’s queryable offline.

The workflow looks like:

1. Run a STAC search → get items.
2. Persist them as stac-geoparquet.
3. Months later, re-run analysis against that exact frozen catalog.
4. Use DuckDB/Polars/GeoPandas to filter the parquet without hitting any API.

This is the reason rustac exists in the form it does — its core proposition is “do STAC search and dump straight to stac-geoparquet, all in Rust, all async, all fast.” pystac-client can do the search; the [stac-geoparquet](https://github.com/stac-utils/stac-geoparquet) Python package handles the write step.

-----

# Part 7 — STAC’s role in the GeoStack

## What it replaced

Before STAC, large EO analysis pipelines had a recurring shape:

```
[per-provider bespoke search code]
                ↓
[provider-specific download tooling]
                ↓
[normalize filenames + metadata into a local schema]
                ↓
[your actual analysis]
```

The first three boxes were typically half the code. They had to be rewritten for every new data source.

STAC collapses the first three into one box:

```
[STAC API client] → [object store reader] → [your actual analysis]
```

The client is the same for every provider that follows the spec. The object store reader handles auth (which is still per-provider — see the recipe files). The normalization step disappears because every Item already follows the same schema.

## Where STAC ends

STAC is **strictly a metadata layer**. It deliberately doesn’t:

- **Define how pixels are stored.** That’s COG, Zarr, NetCDF, HDF5 — file formats. STAC only points at them.
- **Define how to read pixels.** That’s GDAL, rasterio, rioxarray, xarray, zarr-python.
- **Handle authentication.** STAC says “here’s an href”; getting the bytes is your problem.
- **Do reprojection, mosaicking, or compositing.** That’s stackstac, odc-stac, rio-tiler.
- **Do scientific processing.** That’s your code.

A common beginner confusion: “I have a STAC API, so I have a data pipeline.” No — you have a *discovery* layer. The actual work (auth, byte fetching, decoding, reprojection, scientific processing) sits above STAC and is independent of it.

## The clean separation

The right mental model is:

```
SCIENCE     →  what to do with pixels         (your code)
ARRAY       →  pixels as labeled arrays        (xarray, dask)
RASTER I/O  →  bytes to pixels                 (rasterio, zarr)
OBJECT STORE→  hrefs to bytes (with auth)      (obstore, fsspec)
CATALOG     →  query to hrefs                  (pystac-client, rustac)
STAC API    →  REST interface for catalogs     (the providers)
```

Each layer talks to the one below it via a narrow contract. STAC’s contract upward is “give me a list of Items”; its contract downward is “give me the JSON for a search query.” The narrowness is the feature — you can swap any layer without disturbing the others.

For a JAX-based plume retrieval pipeline (plumax) this means: the STAC search is a tiny part of the system. The Items you get back drive object-store reads, which produce arrays, which feed JAX. The same JAX code works regardless of whether the Items came from EMIT, PRISMA, EnMAP, or your own derived catalog — because the STAC layer normalized the metadata.

-----

# Part 8 — Common confusions and gotchas

**1. ItemCollection ≠ Collection.**
A STAC *Collection* is a metadata object describing a dataset. A STAC *ItemCollection* is a GeoJSON FeatureCollection of Items — a search result. The names look similar but they’re different objects with different schemas. Search returns ItemCollections; catalogs contain Collections.

**2. The `links` array is not optional in spirit.**
The spec allows minimal links, but APIs that omit `self` or `parent` links break crawlers. If you’re publishing a catalog, populate links generously.

**3. Asset hrefs can be relative.**
In a static catalog, hrefs are often relative paths like `./B04.tif`. Clients have to resolve them against the Item’s `self` link. pystac does this automatically; raw JSON parsing doesn’t.

**4. The `datetime` field is required *or* the range fields are required.**
Setting all three to null is non-conformant. Many ad-hoc catalogs do this anyway and it causes silent client failures.

**5. CRS != geometry.**
Item geometry is always WGS84 lon/lat. The *asset raster* CRS (from the `proj` extension) is usually something else (UTM, sinusoidal, polar stereographic). When you load a band and reproject, you reproject from the proj-extension CRS, not from the Item geometry’s CRS.

**6. Conformance doesn’t equal capability.**
An API can advertise `item-search#filter` but have a half-broken CQL2 parser. Sentinel Hub Catalog, CMR-STAC, and CDSE STAC all have minor quirks that the spec doesn’t capture. When weird errors happen, test with the simplest possible query first.

**7. Static catalogs can’t be `/search`-ed server-side.**
This is the biggest operational difference between static and dynamic. With a static catalog (Capella Open, Umbra Open, Maxar Open Data) you either crawl the whole tree or load the entire thing as stac-geoparquet first.

**8. Asset keys aren’t standardized.**
Sentinel-2 red band is `B04` on PC, `red` on Earth Search, `B04` on CDSE STAC. Always inspect the Collection’s `item_assets` field or the first Item’s `assets` dict before hardcoding keys.

**9. `bbox` is not the same as `geometry`.**
They’re related but redundant. Most catalogs keep them consistent; some don’t. If you need precise footprints (e.g. for masking), use geometry; if you need fast indexing, use bbox.

**10. STAC versioning.**
The spec version (`stac_version: "1.0.0"`) is *not* the extension version. An Item conforming to STAC 1.0.0 can use eo extension v1.1.0. Clients should check both.

-----

## Where to go from here

- **For the official spec:** [stacspec.org](https://stacspec.org), [github.com/radiantearth/stac-spec](https://github.com/radiantearth/stac-spec), [github.com/radiantearth/stac-api-spec](https://github.com/radiantearth/stac-api-spec).
- **For a list of every catalog in the wild:** [stacindex.org](https://stacindex.org).
- **For client libraries:** `pystac-client` (Python, sync), `rustac` (Python+Rust, async), `pystac` (object model), `stackstac` and `odc-stac` (Items → DataArrays).
- **For the catalog recipes** (with auth, with obstore/fsspec): see the companion files `rustac_catalog_recipes.md` and `pystac_catalog_recipes.md`.

STAC’s value is unglamorous — it just makes metadata uniform — but that uniformity is the load-bearing wall that lets the rest of the modern GeoStack stay loosely coupled. Once you’ve internalized the Item/Collection/Catalog shape and the static/dynamic split, every catalog in the ecosystem is essentially the same problem with different auth flavors.