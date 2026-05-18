---
title: "STAC catalogs for remote sensing — a curated index"
subject: geotoolz tutorial
short_title: "STAC catalog survey"
authors:
  - name: J. Emmanuel Johnson
    affiliations:
      - UNEP
      - IMEO
      - MARS
    orcid: 0000-0002-6739-0053
    email: jemanjohnson34@gmail.com
license: CC-BY-4.0
keywords: tutorial, STAC, remote-sensing, survey, catalog-index, EO
---

# STAC catalogs for remote sensing — curated index

Organized by category. For each catalog: **endpoint** (when stable), **what’s in it**, **auth**, and **notes** relevant to scientific ML / methane / ocean / atmospheric work. The truly comprehensive list is at **[stacindex.org](https://stacindex.org)** (machine-readable mirror: [opengeos/stac-index-catalogs](https://github.com/opengeos/stac-index-catalogs)) — this document is the high-signal subset.

Legend:  🟢 public search · 🔑 auth required for search · 🌐 public assets · 🔒 auth for assets · 💰 commercial · 🧪 mostly Zarr/NetCDF (not COGs) · 🛰️ optical · 📡 SAR · 🌫️ atmosphere · 🌊 ocean · 🌈 hyperspectral

-----

## 1. Major aggregator catalogs

These are the catalogs that index data from many missions in one place. If you don’t know where to start, start here.

### Microsoft Planetary Computer

- **STAC API:** `https://planetarycomputer.microsoft.com/api/stac/v1` 🟢 🔒
- **What’s in it:** ~130+ collections. Sentinel-1/2/3/5P, Landsat 4–9, MODIS, NAIP, HLS, Copernicus DEM, ALOS PALSAR, ESA WorldCover, ERA5, GOES, Daymet, GBIF, GPM IMERG, JRC Global Surface Water, NASA-ISRO NISAR (planned). Methane-relevant: Sentinel-5P (L2 + L3), GOES CMI for plume context.
- **Auth:** Public search; SAS-tokened Azure Blob for asset reads (`planetary-computer.sign()` or obstore `PlanetaryComputerCredentialProvider`).
- **Notes:** The single most production-ready STAC API. Most ARCO Zarr collections (ERA5, Daymet) also exposed alongside COGs.

### Element 84 Earth Search

- **STAC API:** `https://earth-search.aws.element84.com/v1` 🟢 🌐
- **What’s in it:** Sentinel-2 L2A (COG), Sentinel-2 L1C, Sentinel-1 GRD, Landsat Collection 2 L2, NAIP, Copernicus DEM (GLO-30, GLO-90).
- **Auth:** None; assets are public S3 (`sentinel-cogs`, `usgs-landsat`) in us-west-2.
- **Notes:** Lightest-weight option for Sentinel-2 COGs. No SAS tokens, no OAuth, no fuss.

### USGS Landsatlook

- **STAC API:** `https://landsatlook.usgs.gov/stac-server` 🟢 🌐
- **What’s in it:** Landsat Collection 2 Level-1 and Level-2 (surface reflectance, surface temperature), Landsat ARD.
- **Auth:** Public search; assets are in requester-pays S3 (`usgs-landsat`) — you pay egress unless in us-west-2.
- **Notes:** Authoritative source for Landsat. Identical collections also mirrored on PC and Earth Search.

### Copernicus Data Space Ecosystem (CDSE)

- **STAC API:** `https://stac.dataspace.copernicus.eu/v1` 🟢 🔒
- **What’s in it:** All Sentinel missions (S1, S2, S3, S5P, S6), Copernicus Contributing Missions (PRISMA among others), Copernicus DEM, Global Land Cover.
- **Auth:** Public STAC search; CDSE-issued S3 keys for direct object access via `eodata.dataspace.copernicus.eu`.
- **Notes:** EU-hosted alternative to PC for Sentinel data. Separate `sh.dataspace.copernicus.eu/catalog/v1` (Sentinel Hub Catalog) requires OAuth and is the gateway to the Process API.

### NASA VEDA

- **STAC API:** `https://openveda.cloud/api/stac` (prod), `https://staging.openveda.cloud/api/stac` (staging) 🟢 🌐
- **What’s in it:** Curated ARCO datasets for NASA science storytelling — heat, fire, sea level, snow, urban heat islands, COVID-19 environmental indicators, plus most US Greenhouse Gas Center datasets.
- **Auth:** Public.
- **Notes:** Heavy on derived/L3/L4 products, including ML-ready Zarr stores. Backed by eoAPI + pgstac.

### NASA US Greenhouse Gas (GHG) Center

- **STAC API:** Built on VEDA infrastructure (`earth.gov/ghgcenter` portal) 🟢 🌐
- **What’s in it:** EPA GHG Inventory, NIST urban methane, NOAA flask network, MethaneAIR retrievals, EMIT methane plume catalog, OCO-2/3 XCO₂, CarbonTracker, GOSAT. **Especially relevant for plumax.**
- **Auth:** Public.
- **Notes:** Datasets are FAIR + cloud-optimized; this is the cleanest entry point for cross-sensor GHG inversions.

-----

## 2. NASA CMR-STAC (per-DAAC catalogs)

NASA’s CMR exposes STAC per-provider. The root is `https://cmr.earthdata.nasa.gov/stac/` and you pick a provider sub-catalog. All require Earthdata Login for asset access; search is public.

|Provider                   |Endpoint suffix|Holdings of note                                                                                             |
|---------------------------|---------------|-------------------------------------------------------------------------------------------------------------|
|**LPCLOUD** (LP DAAC cloud)|`/LPCLOUD`     |**EMIT** (L1B RAD, L2A RFL, L2B CH4ENH, L2B CH4PLM, L2B CO2ENH), HLS Landsat/Sentinel-2, ECOSTRESS, ASTER GED|
|**POCLOUD** (PO.DAAC)      |`/POCLOUD`     |**SWOT** L2/L3, MUR SST, MEaSUREs SSH, OISSS, AVHRR, ASCAT, OSCAR — 🌊 core ocean                             |
|**GES_DISC**               |`/GES_DISC`    |GPM IMERG, MERRA-2, MLS ozone, AIRS, OMI/OMPS — atmospheric chem 🌫️                                           |
|**NSIDC_CPRD**             |`/NSIDC_CPRD`  |ICESat-2, IceBridge, AMSR2, sea-ice products                                                                 |
|**ORNL_CLOUD**             |`/ORNL_CLOUD`  |GEDI L1B/L2A/L2B/L4A (canopy/biomass), Daymet, FLUXNET                                                       |
|**ASF**                    |`/ASF`         |Sentinel-1, ALOS PALSAR, NISAR (when launched) 📡                                                             |
|**OB_DAAC**                |`/OB_CLOUD`    |MODIS Aqua/Terra ocean color, VIIRS, SeaWiFS chlorophyll 🌊                                                   |
|**LARC_CLOUD**             |`/LARC_CLOUD`  |CERES, MOPITT, MISR, TES, CALIPSO 🌫️                                                                          |
|**GHRC_CLOUD**             |`/GHRSC_DAAC`  |Hurricane Hunter, AMPR, hydro precipitation                                                                  |

**Auth pattern across all of these:** Earthdata Login → `/s3credentials` endpoint per-DAAC → temporary STS keys → obstore `S3Store` in us-west-2. Use the `obstore.auth.earthdata.NasaEarthdataCredentialProvider` with the per-DAAC credentials URL.

-----

## 3. ESA / European catalogs

### DLR EOC Geoservice (Germany)

- **STAC API:** `https://geoservice.dlr.de/eoc/ogc/stac/v1` 🟢 🔒
- **Collections of note:** `ENMAP_HSI_L2A` (CEOS-ARD hyperspectral) 🌈, `ENMAP_HSI_L1B`, `ENMAP_HSI_L1C`, `ENMAP_HSI_L0_QL`. Also TanDEM-X DEM, Sentinel-1 floodmasks (Data4Human), German forest structure, SoilSuite.
- **Auth:** Public search; DLR UMS (HTTP Basic) for downloads from `download.geoservice.dlr.de`.

### S5P-PAL (Sentinel-5P Products Algorithm Laboratory)

- **STAC browser:** `https://data-portal.s5p-pal.com/` 🟢 🌐
- **What’s in it:** Reprocessed Sentinel-5P L2 products (NO₂, CH₄, CO, O₃, HCHO, SO₂, AOT, cloud), including the **PAL_S5P_L2__CH4____HiR** high-resolution methane reprocessing. **Directly relevant for plumax.**
- **Auth:** Public.
- **Notes:** Algorithm reprocessing pipeline — better-quality CH₄ retrievals than operational stream. Endpoint is the canonical scientific archive.

### ASI (Italian Space Agency) — PRISMA

- **STAC catalog:** static catalog within the ASI Open Data portal; current path: `https://prisma.asi.it/missionselect/`
- **What’s in it:** PRISMA L1/L2B/L2C/L2D hyperspectral (VNIR + SWIR, 240 bands) 🌈.
- **Auth:** Registration required.
- **Notes:** Complement to EnMAP. Often used for methane/CO₂ plume retrievals in the literature.

### EUMETSAT Data Store

- **STAC API:** `https://api.eumetsat.int/data/browse/1.0.0/` (custom dialect, partially STAC-compliant) 🔑 🔒
- **What’s in it:** Meteosat (MSG, MTG), Metop, Sentinel-3 SLSTR/OLCI/SRAL marine, Jason-CS — 🌊 ocean and 🌫️ atmospheric.
- **Auth:** EUMETSAT account + OAuth.

### Swiss Data Cube

- **STAC API:** `https://explorer.swissdatacube.org/stac` 🟢 🌐
- **What’s in it:** Sentinel-1/2, Landsat 5–9 over Switzerland, plus derived products.
- **Auth:** Public.

-----

## 4. Regional Open Data Cubes

### Digital Earth Africa

- **STAC API:** `https://explorer.digitalearth.africa/stac` 🟢 🌐
- **What’s in it:** Sentinel-1/2, Landsat 5–9, geomedian composites, water observations, cropland extent over Africa.
- **Auth:** Public; assets in `s3://deafrica-*` buckets (us-west-2 and af-south-1).

### Digital Earth Australia

- **STAC API:** `https://explorer.dea.ga.gov.au/stac` 🟢 🌐
- **What’s in it:** Sentinel-1/2, Landsat 5–9 over Australia, geomedian, water observations, intertidal.
- **Auth:** Public.

### Digital Earth Pacific

- **STAC API:** `https://stac.staging.digitalearthpacific.io` 🟢 🌐
- **What’s in it:** Pacific-island regional products, Sentinel-2 over Pacific SIDS.

### Brazil Data Cube (INPE)

- **STAC API:** `https://data.inpe.br/bdc/stac/v1/` 🟢 🌐
- **What’s in it:** CBERS-4/4A, Landsat over Brazil, Amazon-focused derived products, time-series LCCS land cover.
- **Auth:** Public.

### Sentinel Asia / JAXA Earth-graphy

- Various per-mission catalogs; JAXA exposes ALOS-2 PALSAR-2 and GCOM-W/AMSR-2 through different gateways, increasingly STAC-compliant.

-----

## 5. Open commercial data (free tiers)

### Maxar Open Data Program

- **STAC catalog (static):** `https://maxar-opendata.s3.amazonaws.com/events/catalog.json` 🟢 🌐
- **What’s in it:** Sub-meter optical (WorldView-1/2/3, GeoEye-1) over natural disasters and humanitarian events.
- **Auth:** Public S3.

### Capella Space Open SAR Data

- **STAC catalog (static):** `https://capella-open-data.s3.us-west-2.amazonaws.com/stac/catalog.json` 🟢 🌐 📡
- **What’s in it:** ~100+ X-band SAR scenes (Spotlight/Stripmap/Sliding Spotlight), SLC + GEO + GEC + SICD.

### Umbra Open SAR Data

- **STAC catalog (static):** `https://s3.us-west-2.amazonaws.com/umbra-open-data-catalog/stac/catalog.json` 🟢 🌐 📡
- **What’s in it:** Sub-meter X-band SAR, GEC + SICD, expanding archive.

### Planet Open Data (limited)

- Planet’s open datasets (e.g. wildfire response imagery) are typically distributed as static STAC catalogs from S3, advertised per-release on `planet.com/disasterdata/`.

### NICFI Satellite Data Program (Planet basemaps)

- Norway’s International Climate & Forests Initiative provides Planet monthly tropical basemaps free for non-commercial use; available via Planet’s STAC API with NICFI account.

-----

## 6. Commercial STAC APIs (paid / tasking)

These require a paid account and an access token. All are STAC-compliant for search.

|Provider            |Endpoint                                           |Notes                                                                                                |
|--------------------|---------------------------------------------------|-----------------------------------------------------------------------------------------------------|
|**Planet Data API** |`https://api.planet.com/data/v1`                   |PlanetScope (3m daily), SkySat (sub-m), RapidEye archive. STAC-flavored, not strict spec. 💰 🛰️        |
|**Maxar eAPI**      |`https://eapi.maxar.com/...`                       |WorldView, GeoEye, plus third-party (BlackSky, SkySat, ICEYE, Capella, Umbra) under one search. 💰 🛰️ 📡|
|**ICEYE**           |`https://api.iceye.com/v1/catalog`                 |60k+ X-band SAR archive, daily-to-sub-daily revisit. 💰 📡                                             |
|**Capella Space**   |`https://api.capellaspace.com/catalog/`            |Tasking + archive X-band SAR. 💰 📡                                                                    |
|**Umbra**           |`https://api.canopy.umbra.space/...`               |Highest-resolution commercial SAR (~16cm). 💰 📡                                                       |
|**BlackSky Spectra**|`https://api.spectra.earth/v1`                     |High-revisit (~hourly) sub-m optical. 💰 🛰️                                                            |
|**Airbus OneAtlas** |`https://search.foundation.api.oneatlas.airbus.com`|Pleiades, SPOT, Pleiades Neo. 💰 🛰️                                                                    |
|**Satellogic**      |`https://api.satellogic.com`                       |Sub-m optical + hyperspectral. 💰 🛰️ 🌈                                                                 |

-----

## 7. Atmospheric / Greenhouse Gas catalogs (high relevance for plumax)

In addition to S5P-PAL, GHG Center, EMIT (LPCLOUD), and Sentinel-5P on PC, the methane-specific catalogs to know:

### Carbon Mapper Data Portal

- **STAC catalog:** `https://api.carbonmapper.org/` (custom STAC dialect) 🔑 🔒
- **What’s in it:** Methane and CO₂ plume detections from GAO/AVIRIS-NG airborne campaigns + Tanager satellite mission, with retrieved enhancements and source attribution. **Directly competitive with EMIT for plume work.**
- **Auth:** Free account + API key.

### MethaneSAT (EDF)

- Data release through EDF / Google Earth Engine; STAC distribution in progress as of early 2026. Watch `methanesat.org/data`.

### GHGSat

- Commercial point-source CH₄ detections; STAC-style API to paying customers; some plume aggregates published openly.

### IMEO MARS (UNEP International Methane Emissions Observatory)

- The Methane Alert and Response System publishes notifications and (selectively) plume imagery via the UNEP IMEO portal. STAC publication in progress.
- Your work on the MARS satellite constellation database is downstream of this.

### TROPOMI archives (additional to S5P-PAL)

- KNMI: `https://maps.s5p-pal.com/` (visualization + STAC)
- ESA Sentinel-5P PRE-OPS: operational catalog under CDSE.

-----

## 8. Ocean catalogs (high relevance for somax)

### PO.DAAC (NASA — see CMR-STAC POCLOUD above)

- SWOT L2/L3 (SSH, KaRIn), MUR SST L4 (1km daily blended), GHRSST, MEaSUREs altimetry, AVHRR Pathfinder, ASCAT scatterometer winds, OSCAR currents.
- 🌊 The single most important catalog for ocean modeling/DA work.

### Copernicus Marine Service (CMEMS)

- **STAC:** partial; primary access is via the CMEMS toolbox + `copernicusmarine` Python library. STAC endpoint is rolling out.
- **What’s in it:** Global Ocean Reanalysis (GLORYS), Mediterranean / Black Sea / Baltic regional products, OSTIA SST, in-situ thermosalinograph, biogeochemistry.

### NOAA Open Data Dissemination (NODD)

- Multiple STAC catalogs per dataset on AWS Open Data, including GOES-16/17/18 ABI L2 (atmosphere + ocean), HRRR, NEXRAD, NWM, OISST.
- Static catalogs at `noaa-*` S3 buckets.

### Pangeo Forge / Pangeo Datastore STAC

- **Static catalog:** `pangeo-data/pangeo-datastore-stac` on GitHub 🧪
- **What’s in it:** Cloud-optimized Zarr versions of CMIP6, ERA5, ECCO, LLC4320, MEaSUREs, satellite ocean color. **Most relevant Zarr-STAC bridge for ocean models.**

-----

## 9. Climate / reanalysis (mostly Zarr-backed STAC)

- **ERA5** — Via PC (`era5-pds` collection) and Pangeo Forge. Hourly atmospheric reanalysis 1940–present.
- **MERRA-2** — Via CMR-STAC GES_DISC.
- **CMIP6** — Pangeo CMIP6 cloud archive cataloged in pangeo-datastore-stac.
- **Daymet** — North America daily climate; via PC.
- **CHIRPS** — Rainfall climatology; via various community STAC mirrors.
- **GPM IMERG** — Precipitation; via PC and CMR-STAC GES_DISC.

-----

## 10. Specialty / scientific catalogs

### CEDA Archive (UK Centre for Environmental Data Analysis)

- **STAC API:** `https://api.stac.ceda.ac.uk/` 🟢 🔒
- **What’s in it:** ~20 PB of atmospheric and EO data — aircraft campaigns, climate model output, satellite L1/L2, weather station data. NetCDF-heavy 🧪.

### Radiant MLHub (ML-ready labeled datasets)

- **STAC API:** `https://api.radiant.earth/mlhub/v1` 🔑 🔒
- **What’s in it:** Labeled training datasets (crop type, building footprints, flood, land cover) co-located with imagery, all STAC-compliant with the `label` extension.
- **Auth:** Free API key.
- **Notes:** Mostly absorbed into Source Cooperative as of 2024 — check there for newer releases.

### Source Cooperative (Radiant Earth)

- **Browser:** `https://source.coop/` 🟢 🌐
- Many static STAC catalogs hosted here (e.g. Microsoft Building Footprints, Overture Maps, Speckle SAR datasets, several open methane datasets). Not one unified API but a strong directory of static catalogs.

### OpenAerialMap

- **STAC API:** `https://api.openaerialmap.org/` 🟢 🌐
- Citizen-contributed drone and aerial imagery, often disaster-response.

### LINZ Data Service (New Zealand)

- **STAC API:** `https://nz-imagery.s3-ap-southeast-2.amazonaws.com/catalog.json` and others. NZ aerial imagery, hydrography, elevation.

### Buildings on Cloud (Microsoft / Google)

- Static STAC catalogs for the Microsoft Buildings and Google Open Buildings datasets, hosted on Source Cooperative.

### CIESIN STAC

- **Static catalog:** `https://ciesin.github.io/sci-apps-stac/stac/catalog.json` 🟢 🌐
- Population, hazards, GRID3 demographics.

### Pleiades Archive Open Data — IGN France

- Selected open Pleiades scenes over France, static STAC.

-----

## 11. STAC bridges to non-STAC archives

These aren’t STAC catalogs proper but let you query non-STAC archives with STAC tools:

- **`eodag`** — Python framework that wraps ~30 EO providers (USGS M2M, PEPS, Theia, ASF, Sobloo, Creodias, etc.) behind a unified STAC-style client.
- **`stactools`** — Many packages convert non-STAC catalogs into static STAC on-the-fly: `stactools-landsat`, `stactools-sentinel2`, `stactools-modis`, `stactools-gpm-imerg`, etc.
- **`pangeo-forge-recipes`** — Build ARCO Zarr from NetCDF archives, with STAC publication as part of the recipe.
- **`earthaccess`** — NASA CMR client; complement to CMR-STAC. Use earthaccess for auth+granules, CMR-STAC for catalog queries.

-----

## 12. Tooling to discover / list all of them

- **stacindex.org** — Web UI + JSON dump of every registered catalog/API in the ecosystem. Mirror: `opengeos/stac-index-catalogs`.
- **stac-browser** — Web frontend (`radiantearth/stac-browser`) that points at any STAC endpoint. Public deployments at `https://radiantearth.github.io/stac-browser/` and many provider-specific instances.
- **pystac-client** / **rustac** — Programmatic clients. For a quick “what collections does this API expose?”, `await rustac.collections("...")` or `pystac_client.Client.open(url).get_collections()`.

-----

## Cheat-sheet: which catalog for which task

|If you want…                                     |Start with                                                  |
|-------------------------------------------------|------------------------------------------------------------|
|Sentinel-2 L2A COGs, easiest path                |Earth Search                                                |
|Sentinel-2 + every other public mission, one API |Planetary Computer                                          |
|EU-hosted Sentinel data with S3 access           |CDSE STAC                                                   |
|Landsat archive, authoritative                   |USGS Landsatlook                                            |
|**EMIT methane**                                 |CMR-STAC LPCLOUD + GHG Center                               |
|**Hyperspectral (EnMAP)**                        |DLR EOC Geoservice                                          |
|**Hyperspectral (PRISMA)**                       |ASI portal                                                  |
|**Best CH₄ retrievals (Sentinel-5P reprocessed)**|S5P-PAL                                                     |
|**Plume detections (airborne + Tanager)**        |Carbon Mapper                                               |
|**GHG cross-sensor / inventories**               |NASA GHG Center / VEDA                                      |
|**Ocean (SWOT, MUR SST, altimetry)**             |CMR-STAC POCLOUD                                            |
|**Ocean reanalysis / CMIP**                      |Pangeo Datastore STAC                                       |
|**Climate (ERA5, MERRA-2)**                      |Planetary Computer + CMR-STAC GES_DISC                      |
|**SAR archive (free)**                           |Sentinel-1 on PC/Earth Search/CDSE, Capella Open, Umbra Open|
|**SAR (paid, high-res)**                         |ICEYE, Capella, Umbra, Maxar eAPI                           |
|**High-res optical archive (paid)**              |Maxar eAPI, Planet, Airbus OneAtlas                         |
|**GEDI / canopy biomass**                        |CMR-STAC ORNL_CLOUD                                         |
|**Africa-focused ARD**                           |Digital Earth Africa                                        |
|**Australia-focused ARD**                        |Digital Earth Australia                                     |
|**Trained labels for ML**                        |Source Cooperative (formerly Radiant MLHub)                 |
|**Anything not above**                           |stacindex.org                                               |

-----

## A few realistic caveats

- **“STAC-compliant” is a spectrum.** Planet’s Data API and Maxar’s eAPI are STAC-flavored but have provider-specific extensions; PySTAC-Client and rustac will work but you may hit edge cases on filtering/pagination.
- **Static vs. dynamic.** Many of the open commercial datasets (Maxar Open Data, Capella Open, Umbra Open) are *static* STAC catalogs — a tree of JSON files on S3. rustac handles these via `rustac.read("...catalog.json")`, but you can’t do bbox/datetime queries server-side; you crawl the tree or rebuild it as geoparquet first.
- **Zarr/NetCDF catalogs need different array readers.** STAC catalogs that point at Zarr stores (Pangeo, VEDA, parts of PC) don’t yield COGs — you read them with `xarray.open_dataset(..., engine="zarr")`, not rioxarray.
- **The methane / atmospheric ecosystem is moving fast.** MethaneSAT (publicly released late-2024), Tanager-1 (Carbon Mapper), and Sentinel-5 (operational successor to S5P, post-2025 launches) are reshaping what’s catalogued. Re-check the CarbonMapper and GHG Center endpoints quarterly.
- **Don’t confuse Sentinel Hub Catalog with CDSE STAC.** Same parent (CDSE) but different APIs, different auth, and different intended use. STAC v1 endpoint = catalog browsing; Sentinel Hub = on-the-fly processing.