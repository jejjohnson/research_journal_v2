---
title: "REST APIs — a background primer"
subject: geotoolz tutorial
short_title: "REST primer"
authors:
  - name: J. Emmanuel Johnson
    affiliations:
      - UNEP
      - IMEO
      - MARS
    orcid: 0000-0002-6739-0053
    email: jemanjohnson34@gmail.com
license: CC-BY-4.0
keywords: tutorial, REST, HTTP, API, geotoolz, STAC
---

# REST APIs: A Background Primer

*A companion to the STAC primer. STAC API is itself a REST API, so this document is both the foundation under STAC and the broader framework that explains why some catalogs aren’t STAC-compliant — and what you do when they aren’t.*

-----

# Part 1 — ELI5: What is a REST API?

## The restaurant analogy

You walk into a restaurant. You sit down. The waiter comes over with a menu. You point at “burger, medium rare, fries.” A while later the waiter brings the burger. You eat, you pay, you leave.

That entire interaction is a REST exchange:

- The **menu** is the **API documentation** — it tells you what you can order.
- Your **order** is the **request**.
- The **dish** is the **response**.
- The **waiter** is the **HTTP protocol** that carries your order to the kitchen and brings food back.
- Crucially, the waiter **doesn’t remember you between visits**. If you come back tomorrow, you order from scratch. Each meal is independent. This is *statelessness*, the most important property of REST.

If you wanted dessert, you’d make a new order (“brownie”). If you wanted to change your burger to well-done halfway through, you’d issue a new request. The waiter doesn’t carry mental notes about your preferences from yesterday — every request must say everything the kitchen needs to know to make the dish.

That’s REST. **It’s a way to interact with a server where every request is self-contained and the server’s job is to look at the request, do the work, and return a response.** No memory, no session, no implicit state.

## You already use REST every day

When you load a webpage, your browser sends a request like “GET this URL” to the server, the server responds with HTML, and your browser renders it. When you click a link, that’s another request. When you fill out a form and click submit, that’s a request with form data attached.

The web *is* REST. The HTTP protocol that makes browsers work is the same protocol that makes REST APIs work. The only difference between “the web” and “a REST API” is who’s on the other end of the response — a human reading HTML, or a program parsing JSON.

This is the deep reason REST won: it didn’t invent anything. It just said “use HTTP the way HTTP was designed to be used.” Everything else (servers, caches, load balancers, proxies, browsers, debuggers) already worked.

## A simpler analogy: filing requests at a government office

You fill out a form (the request). You hand it to the clerk at window 3 (the URL endpoint). The clerk does what the form says — registers your car, issues a permit, looks up a record (the operation, determined by the form type — GET, POST, PUT, DELETE). They hand you back paperwork (the response) with a stamp showing it worked (status code 200) or a rejection slip (status code 400 or 500).

If you need to file another request, you fill out another form. The clerk doesn’t remember you from earlier. Every interaction is one form, one outcome.

## What REST is *not*

- **Not a protocol.** HTTP is the protocol; REST is a *style* of using HTTP.
- **Not a specification you can validate against.** It’s a set of architectural constraints (we’ll get to them).
- **Not specific to JSON.** REST APIs can return XML, HTML, binary, anything. JSON happens to have won as the default.
- **Not specific to web servers.** Any program that listens on a port and speaks HTTP can be a REST API.
- **Not exclusive of state.** Servers absolutely have databases. *Requests* are stateless — meaning the server doesn’t need to remember anything from previous requests to handle the current one.

-----

# Part 2 — The shape of REST

## The four moving parts of every REST interaction

```
       ┌──────────────────────────────────────┐
       │                                      │
       │            REQUEST                   │
       │                                      │
       │   ┌────────┐                         │
       │   │ VERB   │  GET                    │   "What action?"
       │   └────────┘                         │
       │   ┌────────┐                         │
       │   │ URL    │  /collections/sentinel-2-l2a/items/S2A_...
       │   └────────┘                         │   "What resource?"
       │   ┌────────┐                         │
       │   │HEADERS │  Authorization: Bearer eyJ...
       │   │        │  Accept: application/json
       │   └────────┘                         │   "Auth, format, etc."
       │   ┌────────┐                         │
       │   │ BODY   │  (empty for GET)        │   "Payload, for writes"
       │   └────────┘                         │
       │                                      │
       └──────────────────────────────────────┘
                          │
                          ▼
       ┌──────────────────────────────────────┐
       │                                      │
       │            RESPONSE                  │
       │                                      │
       │   ┌────────┐                         │
       │   │ STATUS │  200 OK                 │   "Did it work?"
       │   └────────┘                         │
       │   ┌────────┐                         │
       │   │HEADERS │  Content-Type: application/json
       │   │        │  X-RateLimit-Remaining: 99
       │   └────────┘                         │
       │   ┌────────┐                         │
       │   │ BODY   │  { "id": "S2A_...", ... }
       │   └────────┘                         │   "The actual data"
       │                                      │
       └──────────────────────────────────────┘
```

That’s every REST call. The whole protocol fits in this box.

## The verbs (HTTP methods)

REST inherits HTTP’s verbs and assigns them meaning:

|Verb     |Means                                             |Idempotent?|Has body?|
|---------|--------------------------------------------------|-----------|---------|
|`GET`    |Read a resource. Should have no side effects.     |Yes        |No       |
|`POST`   |Create a new resource, or trigger an action.      |No         |Yes      |
|`PUT`    |Replace a resource entirely with the request body.|Yes        |Yes      |
|`PATCH`  |Partially modify a resource.                      |Usually    |Yes      |
|`DELETE` |Remove a resource.                                |Yes        |No       |
|`HEAD`   |Like GET, but only return headers.                |Yes        |No       |
|`OPTIONS`|Ask what verbs/headers an endpoint supports.      |Yes        |No       |

*Idempotent* means: making the same request twice has the same effect as making it once. `GET /scenes/123` returns the same scene whether you call it 1 time or 100 times. `POST /scenes` creates a new scene every time you call it — not idempotent.

In remote sensing APIs, you’ll see ~95% GETs (reading catalog data) and ~5% POSTs (submitting search queries with bodies too big for a URL, or triggering processing jobs). PUT/PATCH/DELETE are rare unless you’re publishing to a catalog you own.

## URLs as resource identifiers

The core REST idea about URLs is that **a URL identifies a “thing” (a resource), not an “action.”**

Good REST URL structure:

```
GET    /collections                              → list of collections
GET    /collections/sentinel-2-l2a               → one specific collection
GET    /collections/sentinel-2-l2a/items         → list of items in that collection
GET    /collections/sentinel-2-l2a/items/S2A_... → one specific item
POST   /collections/sentinel-2-l2a/items         → create a new item
DELETE /collections/sentinel-2-l2a/items/S2A_... → delete that item
```

Notice that the URL describes *what*, not *how*. The verb describes the *how*. This is the “REST way.” There’s no `/getSentinel2Items` or `/createNewItem` URL — those would be RPC-style (“call this function”), not REST-style (“act on this resource”).

In practice, many real APIs blend styles. CMR’s `/search/granules.json` is RPC-flavored. Sentinel Hub’s `/process` endpoint is action-oriented. Don’t let the purity discussion distract you — the practical question is always “does this endpoint do what I need,” not “is it pure REST.”

## Status codes

The response status code tells you how it went. Categories:

- **1xx** — Informational. You rarely see these in user code.
- **2xx** — Success. `200 OK` is the standard. `201 Created` for new resources. `204 No Content` for successful deletes.
- **3xx** — Redirect. `301 Moved Permanently`, `302 Found`, `307 Temporary Redirect`. Your HTTP client usually follows these automatically.
- **4xx** — Client error. *You* did something wrong. `400 Bad Request`, `401 Unauthorized` (you didn’t authenticate), `403 Forbidden` (you authenticated but can’t access this), `404 Not Found`, `429 Too Many Requests` (rate limited).
- **5xx** — Server error. *They* did something wrong. `500 Internal Server Error`, `502 Bad Gateway`, `503 Service Unavailable`, `504 Gateway Timeout`.

The 401/403 distinction is genuinely useful and often misused. 401 means “I don’t know who you are” — your token is missing, expired, or malformed. 403 means “I know who you are, but you don’t have permission for this” — your token is valid but lacks the scope. If you’re debugging an auth issue and you see 403, don’t go regenerating tokens — your problem is permissions, not credentials.

The 429 case matters for catalogs: nearly every public STAC API will rate-limit you if you hammer it. Look for `Retry-After` and `X-RateLimit-*` headers in the response and back off accordingly.

## Headers

Headers carry metadata about the request or response. The ones you’ll see constantly:

**Request headers you send:**

- `Authorization` — your credential (`Bearer eyJ...`, `Basic base64(...)`, etc.)
- `Accept` — what content type you want back (`application/json`, `application/geo+json`)
- `Accept-Encoding` — `gzip, deflate, br` — let the server compress responses
- `Content-Type` — what’s in your request body (for POST/PUT)
- `User-Agent` — identifies your client; some APIs blocklist generic ones like `python-requests/2.28.0`
- `If-None-Match` / `If-Modified-Since` — for cache validation

**Response headers you receive:**

- `Content-Type` — what’s in the body
- `Content-Length` — size in bytes
- `ETag` — opaque identifier for the response; lets you cache and validate
- `Cache-Control` — how long this response can be cached
- `Location` — for 201 Created or 3xx redirects
- `Retry-After` — for 429/503, how many seconds to wait
- `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset` — non-standard but ubiquitous rate limit info
- `Link` — pagination, related resources (used by GitHub, some STAC APIs)

-----

# Part 3 — The constraints that make something “REST”

REST is short for **Re**presentational **S**tate **T**ransfer, coined by Roy Fielding in his 2000 PhD dissertation. Fielding wasn’t inventing a protocol; he was *describing* the architectural style behind the web that had already won. He named six constraints. If your API follows all six, it’s “RESTful.”

In practice, most APIs follow ~4 of them. The community has stopped policing this.

## The six constraints

1. **Client-server.** The client (your code) and server (the catalog) are separate. Either can evolve independently as long as the interface stays compatible.
2. **Stateless.** Every request contains everything the server needs to handle it. The server doesn’t store session state. If you need to authenticate, you send the auth on every request — not once at the start.
3. **Cacheable.** Responses must mark themselves cacheable or not. Caches (browsers, CDNs, intermediate proxies) can store responses and serve them again without bothering the server. This is why CDN-fronted catalogs (Planetary Computer, Earth Search) are fast even under heavy load.
4. **Uniform interface.** Everyone uses the same verbs, the same URL conventions, the same status codes. You can use the same HTTP client (curl, requests, httpx) against any REST API. This constraint is the reason REST won — uniformity at the protocol level meant infrastructure could be shared.
5. **Layered system.** Between you and the actual server there might be caches, load balancers, authentication proxies, rate limiters. You can’t tell. As far as your code is concerned, you’re talking to one server.
6. **Code on demand (optional).** The server can send code (JavaScript) that the client executes. Browsers do this; REST APIs rarely do. Often ignored.

## HATEOAS — the constraint everyone skips

There’s a seventh idea inside “uniform interface” that’s important enough to break out: **HATEOAS** (Hypermedia As The Engine Of Application State). It says: **the server should tell the client what it can do next by including links in its responses.**

A response from a “true” REST API doesn’t just give you data; it gives you data plus links to related resources and available actions:

```json
{
  "id": "S2A_10SEG_20240615_0_L2A",
  "datetime": "2024-06-15T18:42:13Z",
  "links": [
    {"rel": "self",       "href": "https://.../items/S2A_..."},
    {"rel": "parent",     "href": "https://.../collections/sentinel-2-l2a"},
    {"rel": "thumbnail",  "href": "https://.../thumbnail.jpg"},
    {"rel": "next",       "href": "https://.../items?token=abc"}
  ]
}
```

The client can follow `parent` to navigate up, `next` for pagination, `thumbnail` for the preview — without knowing the URL structure ahead of time. The server tells you what’s possible by handing you the URLs.

**STAC takes HATEOAS seriously.** Every STAC object has a `links` array, and a well-behaved STAC client crawls links rather than constructing URLs by hand. This is why static STAC catalogs work — you give a client a root URL and it can discover everything by following links.

Most non-STAC REST APIs ignore HATEOAS and require you to read documentation and build URLs by hand. This is *fine* in practice but means the client has to know more about the API ahead of time.

## The Richardson Maturity Model

A useful (informal) way to grade how “RESTful” an API is:

- **Level 0** — One URL, one verb, everything is a tunnelled POST. SOAP and legacy XML-RPC live here.
- **Level 1** — Multiple URLs (resources), but only one verb. “RPC over HTTP.”
- **Level 2** — Multiple URLs and proper use of HTTP verbs and status codes. This is where most real-world REST APIs live, including most geospatial ones.
- **Level 3** — Level 2 + HATEOAS. The “ideal” REST. STAC is Level 3.

Nobody actually cares about the level — the model is just useful for diagnosing what your API is missing. Level 2 is good enough for almost everything.

-----

# Part 4 — REST APIs in remote sensing

The geospatial world is full of REST APIs. Some are STAC-compliant; many aren’t. Roughly four categories of what they do:

## 4a. Data search / discovery APIs

These find scenes matching your query. Examples:

- **NASA CMR** (`https://cmr.earthdata.nasa.gov/search/`) — non-STAC REST, but exposes a STAC view alongside. Endpoints like `/granules.json?collection_concept_id=...&bounding_box=...`. The native CMR API predates STAC and is still the canonical NASA search interface.
- **Copernicus DataSpace OData** (`https://catalogue.dataspace.copernicus.eu/odata/v1/Products`) — OData-flavored REST (OData is a Microsoft-derived REST convention with its own filter syntax). CDSE also exposes a STAC API alongside.
- **Planet Data API** — REST-but-not-quite-STAC. Their search uses POST with a JSON filter body that has its own schema.
- **Maxar eAPI** — REST, STAC-flavored, with extensions for tasking and ordering.
- **USGS M2M (Machine to Machine)** — JSON-RPC over HTTP (technically not REST — it’s RPC). Used for Landsat ordering and bulk download.

The key thing to internalize: **STAC API is one of many ways to do data discovery over REST.** A provider that offers STAC almost always has a non-STAC native API as well (often older), and the non-STAC API often has features the STAC view doesn’t expose (e.g., ordering, processing options, provider-specific metadata).

## 4b. Processing APIs (compute on demand)

These don’t just find data — they process it server-side and return results.

- **Sentinel Hub Process API** (`https://services.sentinel-hub.com/api/v1/process`) — POST a JSON describing inputs (bbox, time, collection), an “evalscript” (small JavaScript that runs on the server to define the output), and you get back a GeoTIFF or PNG of exactly the bands/indices you asked for. Lets you compute NDVI, mosaic, reproject, all server-side.
- **OpenEO** (`https://openeo.cloud`, several backends) — a federated REST API standard for *processing* EO data. You POST a “process graph” (a DAG of operations), the backend executes it on its compute cluster, and you download results. Used by ESA, Copernicus, EODC, several others.
- **Google Earth Engine REST API** — wraps the GEE Code Editor’s capabilities in REST endpoints. Heavyweight, requires Earth Engine project setup.

Processing APIs trade flexibility for convenience. If you just need NDVI over a small AOI, Sentinel Hub Process returns it in one HTTP call. If you need to do something they don’t support (e.g., your own retrieval algorithm), you fall back to downloading data and processing locally.

For methane work, processing APIs are usually *not* the right fit — your algorithms are too specialized and the providers don’t host the dependencies (PyTorch, JAX, your specific NumPyro models). Discovery + local processing is the standard pattern.

## 4c. Tasking APIs (commercial satellites)

For commercial constellations (Planet, Maxar, ICEYE, Capella, Umbra, BlackSky), you can *order* new acquisitions over their REST API. You POST a JSON describing the target area, acquisition window, quality requirements, and you get back an order ID. You poll for status. Eventually the imagery shows up in their catalog.

These are POST-heavy APIs with complex state machines (order placed → accepted → scheduled → acquired → processed → delivered). They almost always include async notification mechanisms (webhooks, polling endpoints) since tasking can take hours to days.

## 4d. Tile / serving APIs (visualization)

For rendering imagery on web maps:

- **WMTS REST** — `GET /tile/{z}/{x}/{y}.png` — the OGC standard for tiled imagery, REST flavor.
- **XYZ tiles** — same idea, looser convention (`{z}/{x}/{y}.png`).
- **TiTiler** (`https://titiler.xyz`) — open-source dynamic tile server that serves any COG or STAC item as tiles on-demand.

These exist in the ecosystem but rarely matter for scientific ML work — you’d use them in a dashboard, not in a training pipeline.

## How REST compares to OGC’s older standards

Before REST won, the OGC (Open Geospatial Consortium) had its own family of standards that did similar things in different ways:

- **WMS** (Web Map Service) — XML-based, returns map images. Predates REST.
- **WFS** (Web Feature Service) — XML-based, returns vector features.
- **WCS** (Web Coverage Service) — XML-based, returns raster coverages.

These services use HTTP but in a more verbose, XML-heavy, less idiomatic way (often everything is GET with KVP query strings, response is GML/XML). They’re still widely deployed in government GIS infrastructure but are gradually being replaced by:

- **OGC API Features** — REST/JSON version of WFS.
- **OGC API Coverages** — REST/JSON version of WCS.
- **OGC API Maps** — REST/JSON version of WMS.
- **STAC API** — built on top of OGC API Features (as covered in the STAC primer).

If you see XML-based WMS/WFS/WCS in the wild today, it’s usually legacy government infrastructure. Modern catalogs go REST/JSON.

-----

# Part 5 — Authentication: where the practical pain lives

REST authentication is where 80% of the operational complexity in EO pipelines actually lives. The recipe files you have already touch on this; this section gives the systematic view.

## 5a. No authentication

Some catalogs are fully public: Element 84 Earth Search, NASA CMR-STAC (for *search* — assets need auth), VEDA, Digital Earth Africa/Australia, Maxar Open Data, Capella Open, Umbra Open. You just hit the URL.

```python
import httpx
response = httpx.get("https://earth-search.aws.element84.com/v1/collections")
```

When this works, life is easy. When it doesn’t, you fall into one of the patterns below.

## 5b. API keys

The simplest authenticated pattern: you sign up, get a long string, send it on every request. Two common placements:

```python
# As a header (most common)
httpx.get(url, headers={"Authorization": f"ApiKey {API_KEY}"})
httpx.get(url, headers={"X-API-Key": API_KEY})

# As a query parameter (less secure — keys end up in logs)
httpx.get(f"{url}?api_key={API_KEY}")
```

Used by: Radiant MLHub, Carbon Mapper, many smaller providers. Trivial to use, no token refresh, no expiry handling. Just don’t commit them to git.

## 5c. HTTP Basic Auth

You send a username and password (base64-encoded) on every request.

```python
import httpx
response = httpx.get(url, auth=(username, password))
# Sends: Authorization: Basic base64(username:password)
```

Used by: DLR Geoservice (UMS), some legacy archives, the THREDDS data server. Simple but inflexible — no scoping, no expiry, no revocation without changing the password.

## 5d. Bearer tokens (the OAuth 2.0 family)

You first authenticate to an *authorization server* (often a different host) and get a *token*. Then you send that token on every subsequent request to the resource server.

```python
# Step 1: Get token
token_response = httpx.post(
    "https://auth.example.com/token",
    data={"grant_type": "...", ...},
).json()
access_token = token_response["access_token"]

# Step 2: Use token on data requests
httpx.get(
    "https://data.example.com/items",
    headers={"Authorization": f"Bearer {access_token}"},
)
```

The differences between OAuth flows are in *how step 1 works*:

**Client Credentials flow** — for machine-to-machine. You have a `client_id` and `client_secret` (issued by the provider). You POST them to the token endpoint. Used by: Copernicus Data Space (CDSE) for Sentinel Hub, Planet for some operations, most commercial APIs for backend services.

**Authorization Code flow** — for user-facing applications. The user is redirected to the provider’s login page, authorizes your app, and you receive a code that you exchange for a token. Used when an app acts on behalf of a logged-in user. Rare in scientific pipelines but common in web UIs.

**Device Code flow** — for headless devices. You display a code to the user, they log in on their phone, your device polls for completion. Used by NASA Earthdata Login in headless contexts.

**Refresh tokens** — most OAuth flows give you both an `access_token` (short-lived, ~1 hour) and a `refresh_token` (long-lived, days to months). When the access token expires you use the refresh token to get a new one without re-authenticating. A robust client handles this automatically — manually re-authenticating every hour is the most common bug in OAuth code.

## 5e. NASA Earthdata Login (a specific story)

EDL is OAuth 2.0 + bespoke conventions. You log in once (browser or `.netrc`), get a bearer token, and use it against any NASA DAAC. For S3 direct access you need an extra step:

1. Authenticate to EDL → bearer token.
2. Use the bearer token to hit `/s3credentials` on the relevant DAAC.
3. That endpoint returns *temporary AWS STS credentials* (access key, secret, session token, expiry).
4. Use those STS credentials with boto3/obstore/fsspec for S3 access.
5. Refresh ~hourly.

This is why `earthaccess` and `obstore.auth.earthdata.NasaEarthdataCredentialProvider` exist — they automate the whole loop. Don’t do it by hand if you can avoid it.

## 5f. AWS SigV4 (when REST meets cloud auth)

S3 and many AWS-flavored services authenticate with **Signature Version 4** — a signature derived from your AWS access key, secret, the request method, URL, headers, body, and a timestamp. The signature goes in the `Authorization` header.

You almost never sign by hand. boto3, obstore, fsspec’s `s3fs`, and rasterio’s GDAL all do it for you. But you’ll see SigV4 errors in the wild, and recognizing what they mean (“the timestamp on your request is too skewed from the server’s clock,” “your credentials are valid but you don’t have permission to read this bucket”) is useful.

CDSE’s S3-compatible endpoint at `eodata.dataspace.copernicus.eu` uses SigV4 with CDSE-issued keys.

## 5g. mTLS (mutual TLS)

In some government and security-sensitive APIs, the *client* presents a certificate, not just the server. Your code holds a `.pem` file with a private key, and HTTPS handshake validates you on both sides.

```python
httpx.get(url, cert=("client.pem", "client-key.pem"))
```

Rare in commercial EO but appears in some defense / national-archive APIs.

## The auth decision tree

When approaching a new provider:

1. **Is search public?** Yes → just hit it. No → find the auth docs.
2. **Is asset access public?** Yes → use HTTPS hrefs directly. No → continue.
3. **What pattern do they use?** Look for keywords: “API key” = §5b. “Basic auth” or `.netrc` = §5c. “OAuth,” “client_id,” “Bearer” = §5d. “Earthdata Login” = §5e. “STS,” “AWS credentials” = §5f.
4. **Is there a Python library that handles it?** Almost always yes. `earthaccess` for NASA, `planetary-computer` for PC, `sentinelhub-py` for Sentinel Hub, `requests_oauthlib` for generic OAuth. Use it.

-----

# Part 6 — STAC API as a REST API

Now we can be precise about how STAC fits in.

**STAC API is a REST API with a specific schema and specific endpoints.** Specifically, it’s:

- REST (Level 2-3 on the Richardson model) — uses HTTP verbs and status codes correctly.
- JSON-only — no XML, no MessagePack, no Avro.
- A profile of OGC API Features — inherits `/collections`, `/collections/{id}`, `/collections/{id}/items` from that standard.
- Plus the STAC-specific `/search` endpoint for cross-collection queries.
- Plus a defined JSON schema for what the responses must look like (Catalog, Collection, Item objects).
- Plus a conformance mechanism (`/conformance`) so clients can discover what’s supported.

In Richardson Maturity Model terms, STAC is unusual in actually implementing **Level 3 (HATEOAS)** — every Item has a `links` array, every search response has `next`/`prev` links, every Collection links to its items. Most REST APIs you’ll encounter don’t bother.

So: **everything in this primer applies to STAC API.** The auth patterns, the status codes, the headers, the pagination styles — STAC inherits all of it. STAC just adds:

1. A *schema* (Items must look like a GeoJSON Feature with specific fields).
2. A *vocabulary* (specific extensions for `eo`, `proj`, `raster`, etc.).
3. A *capability* (full cross-collection search via `/search`).
4. *Discoverability* (conformance classes + HATEOAS).

If a provider’s REST API doesn’t follow STAC, it’s not because STAC is impossible — it’s usually because the provider’s API predates STAC (CMR, Planet Data API, Sentinel Hub Catalog v1) and the cost of migrating is high. Most providers now offer STAC alongside their legacy API.

-----

# Part 7 — When you’d use a non-STAC REST API

In your day-to-day work, you’ll occasionally hit cases where STAC isn’t enough or isn’t available:

**Processing services.** If you want server-side NDVI computation, mosaicking, or compositing, you need a Process API (Sentinel Hub, OpenEO). STAC has no concept of “compute on this data.”

**Tasking.** Ordering new acquisitions from Planet, Maxar, ICEYE, Capella, Umbra — these all use provider-specific REST APIs. STAC doesn’t have tasking.

**Provider-specific archives that haven’t adopted STAC.** Some research data centers (CEDA, some EUMETSAT services) still expose primarily legacy REST or OData. You either use their native API or wait for the STAC view.

**Auth and credential exchanges.** EDL token endpoints, CDSE OAuth endpoints, AWS STS endpoints — these are all REST but not STAC. You hit them as part of auth setup before doing STAC work.

**Internal/private APIs.** Your team’s internal “list of processed scenes” API is probably non-STAC REST unless someone built it to be STAC-compliant.

**Granule-level operations on NASA data.** CMR’s native API exposes things STAC-CMR doesn’t always surface (collection metadata, variable subsetting via Harmony, OPeNDAP links).

**For your work specifically** (methane, hyperspectral, ocean): the MARS system you’ve worked on, the IMEO operational pipeline, and most plume-detection databases are non-STAC REST. Even when there’s a STAC view, it usually doesn’t cover all of the operational metadata.

-----

# Part 8 — Python tooling for REST

The Python REST ecosystem is mature. The libraries you’ll actually use:

## requests — the default

```python
import requests
r = requests.get("https://earth-search.aws.element84.com/v1")
r.json()
```

Synchronous, blocking, the default in nearly every Python tutorial since 2011. Has session objects for connection pooling and persistent auth:

```python
session = requests.Session()
session.headers.update({"Authorization": f"Bearer {token}"})
r = session.get(url)
```

Good for: scripts, notebooks, anywhere you don’t care about concurrency.

## httpx — the modern default

```python
import httpx

# Sync usage — drop-in replacement for requests
r = httpx.get(url)

# Async usage
async with httpx.AsyncClient() as client:
    r = await client.get(url)
```

Drop-in replacement API, plus async support, plus HTTP/2 support. **Use this for new code.** It’s what rustac and most modern async tooling expects to interoperate with.

## aiohttp — when you need pure async

```python
import aiohttp
async with aiohttp.ClientSession() as session:
    async with session.get(url) as response:
        data = await response.json()
```

More verbose API than httpx but slightly faster at high concurrency. Use if you’re benchmarking 10k concurrent requests and httpx isn’t keeping up; otherwise prefer httpx.

## urllib3 — the low level

What requests is built on. Use directly only when you need control over the underlying connection pool (custom SSL contexts, connection-level retry policies, raw socket access). Rare.

## The auth helper libraries

- **`requests_oauthlib`** — OAuth 1.0/2.0 for requests. The standard.
- **`authlib`** — OAuth + OIDC + JWT, more modern than `requests_oauthlib`. Works with httpx.
- **`earthaccess`** — NASA EDL specifically. Handles netrc bootstrap, token refresh, S3 STS exchange.
- **`planetary-computer`** — PC SAS signing for assets. Just `planetary_computer.sign(item)`.
- **`sentinelhub-py`** — official SDK for Sentinel Hub APIs (Process, Catalog, Statistical).

## Pagination helpers

REST APIs paginate in several styles; clients must handle them:

**Link header pagination** (RFC 5988):

```
Link: <https://.../page2>; rel="next", <https://.../page10>; rel="last"
```

Parse the `Link` header, follow `rel="next"` until it’s missing.

**Cursor/token pagination:**
Response includes `"next_page_token": "abc123"`. Pass it as `?page_token=abc123` in the next request.

**Offset/limit pagination:**
Response includes `"total": 1000`, you request `?offset=0&limit=100`, then `?offset=100&limit=100`, etc.

**STAC’s pagination:**
Links array in the response includes a `rel: "next"` link with a fully-formed URL. Just follow it. pystac-client and rustac handle this automatically.

A common gotcha: don’t assume the page size you request is what you get. Most APIs cap it at 100 or 1000. Always look at what the server actually returned.

-----

# Part 9 — Common gotchas

**1. Pagination is silent.**
If you call a search endpoint without pagination handling, you’ll get the first page (often 10 or 100 items) and not realize you missed the rest. STAC has 50,000 matching items? You get 10 unless you iterate. pystac-client and rustac handle this; manual `requests.get(url).json()["features"]` does not.

**2. Status codes lie sometimes.**
Some APIs return `200 OK` with an error message in the body. Always check both the status code *and* the response body shape. Look for `error` or `errors` keys before assuming success.

**3. Rate limiting is unforgiving.**
Hit a STAC API with `for i in range(10000): requests.get(...)` and you’ll get banned for an hour. Look at `X-RateLimit-Remaining` headers; back off when it gets low. Better: use a library that does this for you (`httpx` with retry transport, `tenacity` for exponential backoff).

**4. Tokens expire silently mid-pipeline.**
You start a long-running analysis with a fresh token, three hours later your access token has expired, and suddenly every request returns 401. Robust pipelines refresh tokens proactively or wrap requests in retry-with-refresh logic. The provider’s SDK usually does this; hand-rolled clients usually don’t.

**5. Stateless means stateless.**
“I logged in earlier in this script” is meaningless to the server. Every request must carry auth. (HTTP cookies are a session-mimicking layer, but most APIs use bearer tokens and require them on every request.)

**6. Error response shapes are inconsistent.**
Provider A returns `{"error": "..."}`. Provider B returns `{"errors": [{"code": "...", "message": "..."}]}`. Provider C returns a free-text message. Standardize at the client boundary.

**7. Idempotency matters for retries.**
If a POST fails, can you safely retry it? Maybe — depends on whether the server treats it idempotently. Some APIs support `Idempotency-Key` headers (Stripe-style); most don’t. Retrying POSTs on timeouts can create duplicate orders / duplicate jobs.

**8. Content negotiation pitfalls.**
A server might return JSON if you send `Accept: application/json` and XML if you send `Accept: application/xml`. Most modern APIs default to JSON if you don’t specify, but the safe move is always to explicitly set `Accept`.

**9. URL construction footguns.**
Trailing slashes matter on some servers (`/items` ≠ `/items/`). Query string ordering doesn’t matter logically but can affect caching (CDNs sometimes cache by exact URL). When in doubt, copy the URL from the docs.

**10. The “REST” label tells you almost nothing.**
“Our API is RESTful” can mean anything from Level 1 RPC-over-HTTP to a fully HATEOAS-compliant Level 3 API. Always read the docs, never assume conventions.

**11. Sync vs async mismatch in libraries.**
`requests.get()` blocks. `httpx.AsyncClient().get()` returns a coroutine. Mixing them in the same code is the most common cause of “why is my async code synchronous” confusion. Pick one for a given module.

**12. Compression is on by default but worth checking.**
Servers will gzip responses if you send `Accept-Encoding: gzip` (httpx and requests both do this automatically). If you’re piping raw responses through middleware, make sure the middleware doesn’t strip the encoding header without decompressing.

-----

# Part 10 — REST in the GeoStack

Where REST sits in the overall picture:

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
                          │   obstore  ·  fsspec  ·  boto3           │
                          │   (auth via REST token endpoints!)       │
                          └──────────────────▲───────────────────────┘
                                             │  signed hrefs / credentials
                          ┌──────────────────┴───────────────────────┐
                          │       CATALOG / METADATA LAYER           │
                          │   rustac  ·  pystac  ·  pystac-client    │
                          │   stac-geoparquet  ·  Arrow / DuckDB     │
                          │                                          │
                          │   Non-STAC alternatives:                 │
                          │   earthaccess (CMR)  ·  sentinelhub-py   │
                          │   planet-sdk  ·  raw httpx/requests      │
                          └──────────────────▲───────────────────────┘
                                             │  REST API calls
                          ┌──────────────────┴───────────────────────┐
                          │              REST API LAYER              │
                          │                                          │
                          │   STAC APIs:                             │
                          │     Planetary Computer · Earth Search    │
                          │     CMR-STAC · CDSE STAC                 │
                          │     DLR Geoservice · ...                 │
                          │                                          │
                          │   Non-STAC REST APIs:                    │
                          │     NASA CMR native · CDSE OData         │
                          │     Sentinel Hub Process · OpenEO        │
                          │     Planet Data · Maxar eAPI             │
                          │     EUMETSAT Data Store · ...            │
                          │                                          │
                          │   Auth endpoints (also REST):            │
                          │     EDL · CDSE OAuth · AWS STS · ...     │
                          └──────────────────────────────────────────┘
```

REST is **everywhere in the lower half of the stack**. It’s the foundation under STAC, under auth, under object stores’ credential exchanges. Every arrow between layers that crosses a network boundary is almost certainly a REST call.

The mental model that matters: **STAC is a specific kind of REST. The auth flow is a different specific kind of REST. Object store APIs are yet another kind of REST. Different schemas, same underlying protocol.** Once you can read HTTP requests fluently — verb, URL, headers, body, status, response body — you can debug anything in this layer of the stack.

-----

# Part 11 — REST vs STAC: a direct comparison

|Aspect               |Generic REST API       |STAC API                                      |
|---------------------|-----------------------|----------------------------------------------|
|Protocol             |HTTP                   |HTTP                                          |
|Format               |Anything (usually JSON)|JSON only                                     |
|Schema               |Provider-specific      |Strictly specified (Catalog, Collection, Item)|
|Endpoints            |Provider-specific      |Standardized (`/collections`, `/search`, etc.)|
|Filter language      |Provider-specific      |CQL2 (standardized)                           |
|Pagination           |Multiple styles        |Link-based (HATEOAS)                          |
|Conformance discovery|Usually none           |`/conformance` endpoint                       |
|Cross-API tooling    |Custom per provider    |Universal (`pystac-client`, `rustac`)         |
|HATEOAS              |Rarely                 |Yes                                           |
|Versioning           |Provider-specific      |STAC version negotiated via `stac_version`    |
|Asset descriptions   |Free-form              |Standardized `assets` dict with roles, types  |
|Spatial query        |Provider-specific      |`bbox`, `intersects`                          |
|Temporal query       |Provider-specific      |`datetime` (ISO 8601, range syntax)           |

**When STAC wins:** multi-provider workflows, reproducible pipelines, scripting against many catalogs, anything where uniform tooling pays off.

**When generic REST wins:** provider-specific features (tasking, processing, ordering, provenance details), legacy catalogs that haven’t adopted STAC, internal/private APIs, anything that needs functionality outside STAC’s metadata-only scope.

**In practice:** most modern EO workflows are mostly-STAC with a few non-STAC REST calls for auth and for provider-specific operations. Your `plumax` pipeline will likely look like: STAC for discovery, EDL REST for auth, S3 (REST-flavored) for byte access, your code for everything above that.

-----

# Where to go from here

- **For HTTP itself:** Mozilla Developer Network’s HTTP docs are the canonical free reference.
- **For REST architectural theory:** Roy Fielding’s 2000 dissertation (yes, really — chapter 5 is the REST chapter). For a friendlier version: Mark Masse’s *REST API Design Rulebook*.
- **For Python tooling:** `httpx` docs, `requests` docs, `authlib` docs.
- **For OAuth specifically:** `oauth.com` is a clear walk-through. RFC 6749 is the spec.
- **For OpenAPI** (a specification for *describing* REST APIs in YAML/JSON): `swagger.io` for tooling.

REST is a less glamorous foundation than STAC — it predates the modern geospatial stack and has no special connection to it. But that’s exactly the point: REST won because it’s general, and STAC inherits its universality. Once REST is comfortable, everything in the catalog and auth layers stops feeling like mystery and starts feeling like variations on one theme.