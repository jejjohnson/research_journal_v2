---
title: "Benchmarks Gallery"
subject: geotoolz supporting info
short_title: "Benchmarks gallery"
authors:
  - name: J. Emmanuel Johnson
    affiliations:
      - UNEP
      - IMEO
      - MARS
    orcid: 0000-0002-6739-0053
    email: jemanjohnson34@gmail.com
license: CC-BY-4.0
keywords: geotoolz, benchmarks, gallery, ocean, atmosphere, remote-sensing
---

# Benchmarks Gallery

|                |                                                                                                                                                                      |
|----------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|**Status**      |Companion gallery to `benchmark.md`                                                                                                              |
|**Reading time**|~35 min                                                                                                                                                               |
|**Audience**    |Anyone wanting concrete benchmark designs across Ocean, Land, Atmosphere, Remote Sensing, and Mathematical Models domains, instantiated against the GeoStack framework|
|**Companion**   |Report 15 (framework), Report 14 (`pipekit-evaluate`), `geodata_lifecycle.md` (data lifecycle), `geostack_vision.md`                                                        |

## What this document is

Worked examples. The framework in Report 15 specifies what makes a benchmark benchmarkable; this gallery instantiates the framework across six domains:

1. **Ocean** — SSH, SST, SSS, Ocean Colour, BGC
2. **Land** — Temperature, Precipitation, Wind, Surface Pressure
3. **Atmosphere** — Gases, 3D Wind, Pressure
4. **Remote Sensing** — Multispectral-Hyperspectral, Polar-Geo, RTM, Sensor Ops, Multi-Satellite Fusion
5. **Mathematical Models** — Emission Estimation (a multi-stage inverse problem)

Each entry follows a consistent template so they’re scannable and comparable:

```
### Task name

**Carrier transformation.** Which row of the task taxonomy
**Variant.** Deterministic / probabilistic / both
**Why this matters.** Scientific or operational significance
**Reference data.** What's used as truth, by track
**Tracks.** Model-to-reanalysis / -analysis / -observations as applicable
**Baselines.** Mandatory shared baselines
**Metric set.** Across Lens × Unit matrix cells
**Splits.** Block discipline, leakage rules
**Known failure modes.** What models typically get wrong
**Stack mapping.** Which GeoStack pieces implement which part
```

Read each entry as a draft benchmark contract — not yet pre-registered, but specified concretely enough that it could be.

-----

## Domain 1 — Ocean

The most operationally mature domain for ML benchmarking. Strong existing community infrastructure (OceanBench), good reference products (GLORYS, DUACS, OSTIA, ISAS, CCI), but **persistent gaps in 3D subsurface, coastal/shelf regimes, and biogeochemistry** that the source’s gap analysis identified. Each benchmark below names which gap it addresses.

### 1.1 — Sea Surface Height (SSH)

**Carrier transformation.** Gap-filling: Obs (along-track points + SWOT swaths) → Obs (dense grid). Or, for forecast variants, State → State (future).

**Variant.** Both deterministic (DUACS-style L4 product) and probabilistic (ensemble reconstructions are increasingly common; SWOT calibration introduces honest spread).

**Why this matters.** SSH drives the surface geostrophic flow; mesoscale eddies dominate ocean variability; SWOT’s wide-swath altimetry has changed the data-sparsity assumptions that decades of OI-based reconstruction were built on. The canonical ML-ocean benchmark — if you can’t do this, the rest is in trouble.

**Reference data.**

- Reanalysis track: **GLORYS12** (1/12° global ocean reanalysis)
- Analysis track: **DUACS L4** (Copernicus operational maps)
- Observations track: **along-track Jason / Sentinel-3 / Sentinel-6**, **SWOT 1-day repeat** (where in mission phase)

**Tracks.** All three available. The observations track is the strongest test because the L4 products were *built from* the same observations — model-to-L4 measures “did you learn the OI”; model-to-obs measures “did you learn the underlying SSH field.”

**Baselines.**

- `OptimalInterpolationBaseline(decorr_length_km=100, decorr_time_days=15)` — the operational standard
- `PersistenceBaseline(lead_time_hours=24)` for forecast variants
- `ClimatologyBaseline(window_years=(1993, 2020), averaging_period="weekly")`

**Metric set.**

- *Field × Point-wise*: SSH RMSE (m), geostrophic velocity RMSE (m/s)
- *Field × Spectral*: kinetic-energy spectrum slope (target ≈ $k^{-3}$ at mesoscale), wavenumber-resolved RMSE
- *Event × Detection*: mesoscale eddy POD/FAR (using py-eddy-tracker on both predicted and reference fields)
- *Field × Physical-constraint*: geostrophic balance closure ($u_g = -g/f \cdot \partial \eta/\partial y$, $v_g = g/f \cdot \partial \eta/\partial x$); SSH-vorticity consistency
- *Probabilistic*: CRPS (where ensemble); spread-skill ratio

**Splits.** Mesoscale decorrelation ~100 km / ~30 days → `SpatioTemporalBlockSplit(spatial_block_km=200, temporal_block_days=60)`. Test set is held-out year. **Critical**: SWOT and traditional altimetry must be split by mission, not pooled, because they have different sampling characteristics.

**Known failure modes.**

- Double-penalty for mesoscale eddies → RMSE rewards flat smoothed predictions
- Spectral slope artificially steep ($k^{-5}$ or steeper) when training with L2 only
- Western boundary currents (Gulf Stream, Kuroshio) under-resolved
- Coastal regions consistently worst — bathymetry gradients are hard
- SWOT artifacts mistaken for real signal in the cross-track direction

**Stack mapping.**

- Carriers: `geocatalog` for altimetry tracks (point data via `TrajectorySlice`); `geocatalog` for SWOT swath data (raster `GeoSlice` with swath geometry); `statecatalog` for GLORYS reanalysis
- Pipeline: `xr_toolz.interpolate` for the gap-fill operator; optional `gaussx.KrigingOperator` for OI-style baselines
- Evaluation: `pipekit-evaluate.MultiTrackEvaluation` with three references; `xr_toolz.events.eddy_tracker` for the event detection lens
- Splits: `pipekit_train.splitters.SpatioTemporalBlockSplit`

**Gap addressed.** The classical ocean benchmark; OceanBench SSH Edition is the canonical instance. Our contribution would be a *content-addressed contract* version of OceanBench-SSH that’s pre-registrable.

-----

### 1.2 — Sea Surface Temperature (SST)

**Carrier transformation.** Gap-filling: Obs (cloud-affected sparse grid + in-situ points) → Obs (dense, gap-free grid).

**Variant.** Primarily deterministic; ensemble L4 products exist but are less standard than for SSH.

**Why this matters.** SST is the most-observed ocean variable, used everywhere from weather forecasting to ENSO monitoring. Cloud-affected gaps and diurnal variability are the hard problems; the field is “easy” compared to SSH but high-stakes because everyone uses the L4 products downstream.

**Reference data.**

- L4 fusion track: **OSTIA** (operational, 0.05°), **ESA CCI SST**, **MUR** (multi-scale 1-km), **OISST**
- Observations track: drogued **drifter measurements**, **Argo near-surface temperature**, ship cruise lines
- Multi-platform: **VIIRS L3**, **Sentinel-3 SLSTR**, **AVHRR PathFinder**

**Tracks.** Model-to-L4 (OSTIA / CCI), model-to-observations (drifters, Argo), no clean model-to-analysis distinction (L4 *is* the analysis).

**Baselines.**

- `OptimalInterpolationBaseline(decorr_length_km=50, decorr_time_days=5)` — close to OSTIA-OI
- `PersistenceBaseline(lead_time_hours=24, gap_handling="climatology_fill")`
- `ClimatologyBaseline` from Reynolds OISST

**Metric set.**

- *Field × Point-wise*: SST RMSE (°C), bias (°C)
- *Field × Spectral*: PSD comparison to reference; submesoscale variance preservation
- *Field × Structural*: SSIM for spatial patterns; FSS at multiple scales
- *Event × Detection*: marine heatwave detection (Hobday et al. definition: 90th percentile, ≥5 days)
- *Field × Physical-constraint*: gradient magnitude reasonableness near fronts; no spurious diurnal artifacts in daily-mean products

**Splits.** Mesoscale + sub-mesoscale → `SpatioTemporalBlockSplit(spatial_block_km=100, temporal_block_days=30)`. **Diurnal-cycle splits**: time-of-day must be balanced across train/val/test to avoid the model learning “test set is mostly 06Z.”

**Known failure modes.**

- Cloud-bias: training on cloud-clear pixels means test-time gap-filling extrapolates from biased samples
- Diurnal cycle aliasing: polar-orbiting samples are at fixed local times; model can’t learn full diurnal without geostationary input
- Strong-gradient front regions (Gulf Stream wall, Kuroshio extension) systematically smoothed
- Coastal regions: tide-driven SST variability not captured

**Stack mapping.**

- Carriers: `geocatalog` for L2 swath SST; `statecatalog` for L4 products; `geocatalog` with `ProfileSlice` for Argo near-surface T
- Pipeline: `xr_toolz.interpolate` for grid-grid gap fill; `pyrox-gp` for Bayesian variants
- Evaluation: `pipekit-evaluate` with event-detection lens for marine heatwaves; `xr_toolz.events.marine_heatwave_detector`
- Splits: temporal block + diurnal-balanced via `pipekit_train.splitters.SpatioTemporalBlockSplit` + a new `DiurnalBalanced` flag

**Gap addressed.** Standard L4 fusion benchmark. The marine-heatwave event detection track is underdeveloped in current benchmarks; this is where the framework’s event-unit + detection-lens combination adds value.

-----

### 1.3 — Sea Surface Salinity (SSS)

**Carrier transformation.** Gap-filling + retrieval: very sparse satellite (SMOS / SMAP / Aquarius) + ARGO points → dense grid.

**Variant.** Primarily deterministic, but uncertainty quantification matters more than for SST because of low signal-to-noise.

**Why this matters.** SSS drives the haline component of ocean circulation; river plumes, ice melt, and precipitation patterns drive variability; satellite SSS is *very* low S/N (calibration errors comparable to natural variability in some regions). The hard data-scarcity benchmark in ocean ML.

**Reference data.**

- L4 fusion track: **CCI SSS**, **CMEMS L4 SSS**
- Analysis track: **ISAS** (objective analysis from ARGO; multi-decadal)
- Observations track: **ARGO near-surface salinity** (top 10m), **TSG ship lines** (thermosalinograph)

**Tracks.** Model-to-CCI (L4), model-to-ISAS (analysis), model-to-Argo (observations). The Argo track is critical because the L4 products are heavily smoothed.

**Baselines.**

- `ClimatologyBaseline` from World Ocean Atlas (WOA)
- `OptimalInterpolationBaseline(decorr_length_km=200, decorr_time_days=30)` — slower than SST
- `PersistenceBaseline(lead_time_hours=168)` (weekly, because SSS varies slowly)

**Metric set.**

- *Field × Point-wise*: SSS RMSE (psu), bias
- *Event × Detection*: river-plume detection (low-salinity tongues at major river mouths)
- *Field × Probabilistic*: CRPS (SSS uncertainty is a real concern)
- *Field × Physical-constraint*: T-S diagram consistency (extreme outliers in T-S space are unphysical)
- *Statistic × Point-wise*: regional-mean comparison with ISAS

**Splits.** Long correlation scales → `SpatioTemporalBlockSplit(spatial_block_km=300, temporal_block_days=90)`. **By river system**: leave-one-major-river-out (Amazon, Mississippi, Ganges-Brahmaputra) tests whether the model learned regional patterns or transferable physics.

**Known failure modes.**

- Satellite SSS retrieval errors persistent and spatially structured (RFI in radio bands, sea-state corrections) — model can’t fix what’s not in the data
- Argo near-surface gradient (within top 10m) often poorly resolved
- River plume edges are tide- and wind-driven, sub-diurnal variability matters
- Polar regions: ice contamination, low SST corrections amplifies retrieval errors

**Stack mapping.**

- Carriers: `geocatalog` with multi-mission satellite SSS; `geocatalog` with `ProfileSlice` for Argo salinity
- Pipeline: `pyrox-gp` (Bayesian gap-fill with explicit uncertainty); `xr_toolz.interpolate` for OI baseline
- Evaluation: `pipekit-evaluate` probabilistic lens emphasised; physical-constraint lens for T-S consistency
- Splits: spatial + by-river-system

**Gap addressed.** Underrepresented in current ocean ML benchmarks. The combination of low S/N + sparse in-situ + strong regional patterns is a good test of uncertainty-aware methods.

-----

### 1.4 — Ocean Colour (OC)

**Carrier transformation.** Retrieval + gap-filling: L1 radiance → L2 Chl-a / Kd490 → L3 gridded product.

**Variant.** Deterministic for the canonical Chl-a product; probabilistic variants are research-stage.

**Why this matters.** Phytoplankton biomass is the base of the marine food web; Chl-a is the most widely-used satellite-derived biogeochemical variable. The retrieval is non-trivial (atmospheric correction is the dominant error source), and “Case 2” coastal waters (with CDOM, sediment, bottom reflectance) break the standard algorithms.

**Reference data.**

- L4 multi-mission track: **OC-CCI** (merged SeaWiFS / MODIS / VIIRS / Sentinel-3 OLCI Chl-a), **GlobColour**
- In-situ track: **HPLC chlorophyll** measurements (NASA SeaBASS, NOMAD; the gold standard)
- Operational: **NASA standard OC products** (NASA OC4, OCI algorithm)

**Tracks.** Model-to-OC-CCI (multi-mission L4), model-to-HPLC (in-situ ground truth). Model-to-operational track tests whether you beat the operational algorithm.

**Baselines.**

- `Operator(NASAStandardOC4)` — the standard band-ratio algorithm wrapped as an operator
- `Operator(GIOP)` — Generalized Inherent Optical Properties (semi-analytical)
- `ClimatologyBaseline` from monthly OC-CCI climatology

**Metric set.**

- *Field × Point-wise*: log-Chl-a RMSE (the field is log-normal), bias by water type
- *Field × Spectral*: spatial PSD; ensure submesoscale variability isn’t smoothed
- *Event × Detection*: bloom-onset detection (POD/FAR with timing tolerance)
- *Statistic × Probabilistic*: log-Chl-a distribution comparison (KL divergence, Anderson-Darling)
- *Field × Structural*: frontal-feature alignment (compare with SST fronts)

**Splits.** Decorrelation varies hugely by region. Open ocean: ~100 km / ~30 days. Coastal: ~10 km / ~3 days. **Split by biogeochemical province** (Longhurst provinces): leave-one-province-out tests true regional generalization.

**Known failure modes.**

- Atmospheric correction error in coastal “Case 2” waters → biased L2
- Sun-glint contamination in summer mid-latitudes
- High-altitude cloud shadows produce false low-Chl signals
- Sediment-rich coastal water consistently overestimated by standard algorithms; ML often learns the *bias* rather than the correction
- Sub-pixel cloud contamination

**Stack mapping.**

- Carriers: `geocatalog` for L1/L2 swath products; `geocatalog` with `ProfileSlice` for HPLC bottle samples
- Pipeline: `geotoolz` for the retrieval (radiance → Chl-a); `xr_toolz.interpolate` for gap-fill; `pipekit-cycle.NeuralForward` for learnable retrievals
- Evaluation: `pipekit-evaluate` with log-space metrics; event detection for blooms
- Splits: leave-one-Longhurst-province-out + temporal block

**Gap addressed.** OC benchmarks are domain-mature but rarely use the full lens × unit matrix — bloom detection (event) and log-distribution comparison (statistic) are typically reported only in research papers, not standardised.

-----

### 1.5 — Biogeochemistry (BGC)

**Carrier transformation.** Discretization + Gap-filling: BGC-Argo points (DO, pH, NO3, Chl, irradiance) → 3D gridded fields.

**Variant.** Probabilistic strongly preferred — calibration drift in BGC-Argo sensors makes uncertainty quantification non-optional.

**Why this matters.** **The largest gap in current ocean ML benchmarks** (per the source). BGC-Argo has only recently grown enough to support gridded products; 3D subsurface biogeochemistry is what the next generation of ocean ML needs to tackle.

**Reference data.**

- Gridded track: **WOA BGC** (climatology, coarse); **CMEMS BGC reanalysis** (model-based, less trustworthy as truth)
- Argo track: **BGC-Argo floats** (deep DO, pH, NO3, optical backscatter, Chl)
- Bottle track: **GLODAP v2** (ship-based bottle samples; gold standard but very sparse), **CARINA / PACIFICA** legacy compilations

**Tracks.** Model-to-WOA (climatological), model-to-BGC-Argo (in-situ, held-out floats), model-to-GLODAP (bottle data). The Argo track with leave-one-float-out is the strongest test.

**Baselines.**

- `ClimatologyBaseline` from WOA monthly climatology
- `OptimalInterpolationBaseline(decorr_length_km=500, decorr_time_days=180)` — slow signal
- Per-variable: ESPER (Empirical Seawater Property Estimation Routines)

**Metric set.**

- *Field × Point-wise*: per-variable RMSE (DO in μmol/kg, pH in units, NO3 in μmol/kg) on 3D grid
- *Field × Physical-constraint*: stoichiometric consistency (Redfield ratio bounds on (O2, NO3, PO4) triples); pH-DIC-TA consistency where multiple variables predicted
- *Field × Probabilistic*: CRPS per depth level; calibration of posterior uncertainty against held-out bottles
- *Event × Detection*: oxygen minimum zone (OMZ) detection; subsurface chlorophyll maximum (DCM) detection
- *Statistic × Point-wise*: T-S-O2 watermass-relationship consistency

**Splits.** **Leave-one-float-out** is the canonical test — train on most Argo floats, test on the remaining one’s full record. Plus temporal block (some BGC drifts decadally). Plus by region (Atlantic / Pacific / Indian / Southern Ocean).

**Known failure modes.**

- Sensor calibration drift — model can’t outperform the noise level set by BGC-Argo accuracy
- Depth-dependent biases: surface optically affected; thermocline gradients hard
- OMZ regions: very low DO values are persistently overestimated
- The “Argo sampling shadow” — regions with few floats systematically worse, but this is honest
- Polar regions: under 60S coverage is poor; ML extrapolations there are unreliable

**Stack mapping.**

- Carriers: `geocatalog` with `ProfileSlice` (the canonical use case for the new slice type from `geodata_lifecycle.md`)
- Pipeline: `pyrox-gp` for 3D Bayesian gap-fill; `xr_toolz.profile` operators for vertical-axis ops
- Evaluation: `pipekit-evaluate` with depth-resolved + probabilistic + physical-constraint lenses
- Splits: `LeaveOnePlatformOut(platform_field="argo_float_id")` is the headline pattern

**Gap addressed.** **The headline missing benchmark** in current ocean ML. The carrier-transformation framing makes the structure clean: it’s a Discretization + Gap-Filling chain applied to multi-variable 3D fields with the depth axis as primary, exactly the case the existing GeoStack underspecifies.

-----

## Domain 2 — Land

Land-surface benchmarks have a long meteorological tradition (ERA5-Land, GHCN, IMERG) but ML benchmarks lag weather ones by several years. The opportunity is to bring the same multi-track / multi-lens discipline that weather and ocean benchmarks have developed.

### 2.1 — 2m Temperature (T2m) / Land Surface Temperature (LST)

**Carrier transformation.** Gap-filling + Forecast: stations + satellite → dense grid; or, for forecast variants, State → State (future).

**Variant.** Both. Operational forecasts increasingly probabilistic (ECMWF ENS).

**Why this matters.** Heatwave prediction has direct mortality consequences; LST is the most widely used remote-sensed land variable; T2m is the headline weather variable for most public-facing products.

**Reference data.**

- Reanalysis track: **ERA5-Land** (0.1°, 1950-present), **MERRA-2-Land**
- Station track: **GHCN-Daily** (Global Historical Climatology Network), **HadCRUT5** for monthly aggregates
- Satellite track: **MODIS LST**, **VIIRS LST**, **Sentinel-3 SLSTR LST**

**Tracks.** Model-to-reanalysis (ERA5-Land), model-to-station (GHCN), model-to-LST. All three are valuable; LST track is the hardest because of strong gradients and clear-sky bias.

**Baselines.**

- `PersistenceBaseline` (24h, 168h leads)
- `ClimatologyBaseline` from 30-year ERA5-Land
- `EcmwfOperationalForecast` reference (where available)

**Metric set.**

- *Field × Point-wise*: T2m RMSE, MAE, ME (bias)
- *Field × Probabilistic*: CRPS, rank histogram for ensemble forecasts
- *Field × Structural*: diurnal cycle phase error (radians), amplitude
- *Event × Detection*: heatwave (95th percentile, ≥3 days) POD/FAR/CSI, plus duration error
- *Field × Physical-constraint*: urban / vegetation / topographic-elevation relationships; bias-vs-elevation should be flat for skilled models

**Splits.** `SpatioTemporalBlockSplit(spatial_block_km=200, temporal_block_days=30)`. **By climate zone** (Köppen-Geiger classes): leave-one-zone-out tests whether the model learned transferable physics. **By elevation band** for orographic regions.

**Known failure modes.**

- Urban heat island under-resolved (and ERA5-Land doesn’t capture it either, so model-to-ERA5 hides this)
- Topographic effects: lapse rate biases scale with terrain complexity
- Station distribution highly non-uniform (US over-represented, Africa under)
- Diurnal phase error particularly bad over deserts and snow
- Skin temperature vs. 2m temperature confusion in LST validation

**Stack mapping.**

- Carriers: `geocatalog` for satellite LST; `geocatalog` with `ProfileSlice` (single point, point-time) for GHCN stations; `statecatalog` for ERA5-Land
- Pipeline: `pipekit-cycle.Cycle` for forecasts; `xr_toolz.interpolate` for station-to-grid baselines
- Evaluation: `pipekit-evaluate` with full lens coverage; `xr_toolz.events.heatwave_detector`
- Splits: by Köppen zone (`LeaveOneRegionOut`) + temporal block

**Gap addressed.** Land surface ML benchmarking is dominated by point-wise RMSE; heatwave detection and physical-constraint lenses would be a meaningful upgrade.

-----

### 2.2 — Precipitation

**Carrier transformation.** Forecast + State estimation: gauge + satellite (GPM / IMERG) + radar → dense grid; or, for forecast, State → State (future).

**Variant.** **Strongly probabilistic.** Precipitation is the canonical heavy-tailed, intermittent, double-penalty-cursed variable. Deterministic point forecasts are nearly meaningless for actionable use.

**Why this matters.** Operational weather forecasting’s worst-performing variable; flood prediction’s first ingredient; **the canonical “double penalty” failure case**. Whatever you think your ML model does, precipitation benchmarks will reveal what it actually learned.

**Reference data.**

- L4 fusion track: **IMERG Final** (0.1°, half-hourly, multi-satellite), **MSWEP** (multi-source weighted ensemble)
- Gauge track: **GPCC** (Global Precipitation Climatology Centre), **CPC Unified**
- Radar track: **MRMS** (Multi-Radar Multi-Sensor, US), **OPERA** (Europe), per-country QPE products

**Tracks.** All three; the gauge track is the most-trusted truth where coverage is dense (US, Europe, parts of Asia).

**Baselines.**

- `PersistenceBaseline(lead_time_hours=1)` — surprisingly strong for short leads
- `ClimatologyBaseline` from 30-year IMERG
- `EcmwfOperationalForecast` for forecast leads ≥ 6h

**Metric set.**

- *Field × Probabilistic*: **CRPS is mandatory**; deterministic-only submissions are second-class
- *Event × Detection*: rain/no-rain POD/FAR/CSI at multiple thresholds (1mm/h, 10mm/h, 50mm/h)
- *Field × Spectral*: FSS (Fractions Skill Score) at multiple spatial scales — **the canonical anti-double-penalty metric**
- *Field × Point-wise*: log-normalized RMSE (untransformed RMSE is dominated by extremes)
- *Statistic × Distributional*: precipitation distribution comparison (full PDF, especially tails)

**Splits.** **Causal temporal split is mandatory** (forecasting); `SpatioTemporalBlockSplit(spatial_block_km=500, temporal_block_days=14)`. Note the large spatial block — synoptic systems are large. **By climate zone** + **by season** to expose seasonal biases.

**Known failure modes.**

- Drizzle vs. heavy rain: models bias toward the mean → too much drizzle, not enough heavy events
- Double-penalty: spatial displacement of storms penalised twice; predicting “flat low rain everywhere” beats predicting “right pattern, wrong location”
- Convective precipitation systematically under-skilled compared to synoptic
- Mountainous regions: orographic forcing not resolved
- Light precipitation thresholds (< 1mm/h) badly miscalibrated

**Stack mapping.**

- Carriers: `geocatalog` for IMERG L4; `geocatalog` with `ProfileSlice` for gauge stations; `geocatalog` for radar
- Pipeline: `pipekit-cycle.EnsembleCycle` for ensemble forecasts; `pipekit-train` with FSS as training loss
- Evaluation: `pipekit-evaluate` heavy on event-detection lens (multiple thresholds), spectral lens (FSS), probabilistic lens (CRPS)
- Splits: `CausalTemporalSplit` + by climate zone

**Gap addressed.** Existing precipitation ML benchmarks (IMS, MetNet evaluations) emphasize point-wise + threshold detection but underdevelop the probabilistic + spectral combination. Both should be standard.

-----

### 2.3 — Wind Speed and Direction

**Carrier transformation.** Forecast + Gap-filling: stations + scatterometer (over ocean) + ECMWF → dense grid.

**Variant.** Both deterministic and probabilistic; ensemble wind forecasts critical for renewable-energy applications.

**Why this matters.** Vector-valued variable with anisotropy and circular statistics; energy applications (wind power) drive the operational stakes; gusts are a high-impact tail behavior.

**Reference data.**

- Reanalysis: **ERA5** (10m wind components u, v)
- Station: **ASOS/AWOS** (US), **METAR** (global airports), **MERIDIAN** (research-quality)
- Over ocean: **ASCAT** scatterometer, **OSCAT**
- Aircraft: **AMDAR / EU-AMDAR** ascent/descent wind reports
- Upper-air: **radiosondes** (twice-daily globally)

**Tracks.** Model-to-ERA5, model-to-station (lots of regional coverage), model-to-ASCAT (ocean), model-to-radiosonde (upper-air).

**Baselines.**

- `PersistenceBaseline` for short leads
- `ClimatologyBaseline` from monthly ERA5 wind roses
- `EcmwfOperationalForecast` for forecasts

**Metric set.**

- *Field × Point-wise*: vector RMSE (not separate u/v); **direction RMSE in circular statistics** (Tepper formula)
- *Field × Probabilistic*: CRPS per component, ensemble spread-skill
- *Event × Detection*: gust events (≥ threshold), calm events (≤ 1 m/s), wind shifts
- *Statistic × Distributional*: Weibull-distribution parameter recovery (energy yield calculations)
- *Field × Physical-constraint*: divergence/curl reasonableness; geostrophic-wind alignment in synoptic conditions

**Splits.** `SpatioTemporalBlockSplit(spatial_block_km=200, temporal_block_days=10)`. **By topographic complexity**: leave-one-region-out among flat/coastal/mountainous classes.

**Known failure modes.**

- Calm conditions: vector RMSE is dominated by direction errors that mean nothing physically
- Mountainous regions: terrain channeling not captured at typical reanalysis resolution
- Gust prediction: under-skilled at all leads, gust-to-mean ratio biases
- Sea-breeze fronts: timing errors propagate downstream
- Boundary-layer wind shear: vertical structure missed

**Stack mapping.**

- Carriers: `geocatalog` with various; `geocatalog.queries.matchup` for ASCAT-station co-locations
- Pipeline: `pipekit-cycle` for forecasts; vector-aware operators in `xr_toolz.calc`
- Evaluation: circular-statistics in `pipekit-evaluate.metrics.pointwise.CircularRMSE` (new); Weibull-fitting in distributional lens
- Splits: by topographic class + temporal block

**Gap addressed.** Vector-variable benchmarks rarely report proper circular statistics; the framework’s metric-as-operator design lets `CircularRMSE` ship as a standard implementation.

-----

### 2.4 — Surface Pressure (MSLP)

**Carrier transformation.** Forecast + Gap-filling: stations + GPS-RO + reanalysis → dense grid.

**Variant.** Both; ensemble pressure forecasts inherit from ENS / GEFS.

**Why this matters.** Pressure tracks synoptic systems (cyclones, blocking); the headline operational forecast variable for medium-range; MSLP errors aggregate into storm-track errors.

**Reference data.**

- Reanalysis: **ERA5**, **JRA-3Q**, **MERRA-2**
- Station: **GHCN-Daily** pressure observations
- Aircraft: ascent/descent profiles via AMDAR
- Upper-air: **radiosonde** geopotential heights at standard levels

**Tracks.** Model-to-reanalysis, model-to-analysis (operational analysis), model-to-station.

**Baselines.**

- `PersistenceBaseline` for short leads
- `ClimatologyBaseline` from 30-year ERA5
- `EcmwfOperationalForecast`

**Metric set.**

- *Field × Point-wise*: MSLP RMSE (hPa), bias
- *Field × Probabilistic*: CRPS, rank histogram
- *Event × Detection*: cyclone track skill (object-based: position, intensity, timing errors)
- *Field × Spectral*: Anomaly Correlation Coefficient (ACC) at 500 hPa — **the canonical NWP metric**, but known to be low-bar
- *Event × Detection*: atmospheric blocking detection
- *Field × Physical-constraint*: hydrostatic consistency where multiple levels predicted

**Splits.** Synoptic timescales: `SpatioTemporalBlockSplit(spatial_block_km=1000, temporal_block_days=14)`. **By ENSO phase** for inter-annual variability; **by season**. **Careful around major eruptions** (Pinatubo 1991, Hunga Tonga 2022): split so training and test don’t share recovery period.

**Known failure modes.**

- ACC is misleading at long leads — easy to beat persistence with very smooth predictions
- Blocking pattern prediction systematically poor across all models
- Tropical cyclone intensity errors larger than track errors
- Polar lows under-resolved
- Mountain-lee cyclones (Genoa lows etc.) badly predicted

**Stack mapping.**

- Carriers: standard `statecatalog` for reanalysis + analysis; `geocatalog` for stations
- Pipeline: `pipekit-cycle.EnsembleCycle` for ensembles; cyclone-detection operators in `xr_toolz.events`
- Evaluation: `pipekit-evaluate` heavy on event-detection (cyclones, blocking)
- Splits: synoptic-scale blocks + by ENSO phase

**Gap addressed.** Cyclone tracking as an event-detection benchmark exists in research literature (TempestExtremes, TRACK algorithm comparisons) but isn’t standardized for ML; the framework’s event-unit + detection-lens makes it shippable.

-----

## Domain 3 — Atmosphere

The most-mature ML benchmarking domain (WeatherBench, GraphCast / FourCastNet / Pangu / GenCast evaluations). Our contribution is *trace gas / chemistry* benchmarking, which is structurally similar to weather but operationally less developed.

### 3.1 — Trace Gases (Methane, CO2, Water Vapor)

**Carrier transformation.** Retrieval + Gap-filling + Inverse: hyperspectral L1 → L2 column → L3 grid → L4 source estimates.

**Variant.** Increasingly probabilistic; uncertainty quantification mandatory for emissions attribution.

**Why this matters.** **The headline use case for the MARS / IMEO mission**. Multi-stage benchmark: retrieval accuracy at L2, gridding skill at L3, source attribution at L4. Each stage is a separate benchmarkable transformation; the chain is also benchmarkable end-to-end.

**Reference data.**

- L2 column: **TROPOMI L2 CH4 / CO**, **OCO-2/3 L2 CO2**, **EMIT L2 CH4 plumes**
- L4 reanalysis: **CAMS** (Copernicus Atmosphere Monitoring Service)
- In-situ: **NOAA Cooperative Air Sampling** (flask samples), **NOAA tall towers**, **TCCON** (Total Carbon Column Observing Network)
- Aircraft: **MethaneAIR**, **CARVE**, **HIPPO** campaigns
- Controlled releases: **METEC** (Methane Emissions Technology Evaluation Center; gold-standard known emissions)

**Tracks.** Model-to-CAMS (reanalysis), model-to-TCCON (column ground truth), model-to-flask (point ground truth), model-to-aircraft (mid-altitude), **model-to-controlled-release** (the strongest test for attribution).

**Baselines.**

- `MatchedFilterBaseline` for plume detection (the canonical hyperspectral retrieval)
- `BAEMRBaseline` for column retrieval
- `IMEBaseline` (Integrated Mass Enhancement) for source quantification
- `CAMSReanalysisBaseline` for global concentrations

**Metric set.**

- *Field × Point-wise*: column XCH4 RMSE (ppb)
- *Event × Detection*: plume detection POD/FAR/CSI **stratified by emission rate** (1, 10, 100, 1000 kg/h) — this is the canonical curve
- *Field × Probabilistic*: CRPS for posterior emission distributions
- *Statistic × Point-wise*: regional total emission error (kt/year) vs. inventories
- *Event × Detection*: source persistency (point sources over time)
- *Field × Physical-constraint*: mass conservation in transport; positive concentrations

**Splits.** **Leave-one-source-class-out** (urban / oil-and-gas / agricultural / wetland); **leave-one-region-out**; temporal block. Critical: **METEC controlled-release data must be temporally held out** because the same emitters are observed many times.

**Known failure modes.**

- Retrieval biases (cloud, aerosol, surface) → systematic L2 errors that propagate
- Background variability: weather-driven concentration changes mistaken for emission changes
- Plume edge: detection-vs-quantification trade-off; small plumes detected but mass underestimated
- Attribution ambiguity: nearby sources confound point-source attribution
- The “minimum detection limit” floor — physics, not algorithm, sets the lower bound

**Stack mapping.**

- Carriers: `geocatalog` for L1/L2/L3 satellite; `geocatalog` with `ProfileSlice` for TCCON / tall towers / flask samples; `statecatalog` for CAMS reanalysis; per-source `EventCatalog` for detected plumes
- Pipeline: `geotoolz` for retrieval operators; `plumax` for forward model + `pipekit-cycle.DACycle` for inversion; `pipekit-train` for learnable retrievals
- Evaluation: **the canonical multi-stage benchmark** — `pipekit-evaluate.MultiTrackEvaluation` with retrieval + gridding + attribution stages
- Splits: source-class + region + temporal block

**Gap addressed.** The multi-stage / multi-track structure isn’t standardized; each MARS / IMEO study uses bespoke evaluation. Standardizing this as a benchmark contract would be a real community contribution.

-----

### 3.2 — 3D Wind

**Carrier transformation.** Forecast + Gap-filling: sondes + scatterometer + AMV + reanalysis → dense 3D grid.

**Variant.** Both; operational forecasts are deterministic, research increasingly probabilistic.

**Why this matters.** 3D winds drive transport (chemistry, dust, aerosols); upper-level winds drive jet-stream variability that controls extreme weather; the bottleneck for atmospheric chemistry forecasts.

**Reference data.**

- Reanalysis: **ERA5** (37 pressure levels)
- Upper-air: **radiosondes** (twice-daily; the strongest truth at altitude)
- Scatterometer (surface, ocean): **ASCAT**
- Atmospheric motion vectors (AMV): **GOES**, **Meteosat**, **Himawari** derived winds
- **Aeolus** Doppler lidar (mission ended 2023 but multi-year reference available)

**Tracks.** Model-to-ERA5, model-to-sonde, model-to-AMV, model-to-Aeolus.

**Baselines.**

- `PersistenceBaseline`, `ClimatologyBaseline`
- `EcmwfOperationalForecast`

**Metric set.**

- *Field × Point-wise*: 3D vector RMSE per pressure level
- *Field × Probabilistic*: CRPS per level, spread-skill ratio
- *Field × Spectral*: kinetic-energy spectrum at multiple levels (target $k^{-3}$ near tropopause)
- *Event × Detection*: jet-streak detection; clear-air-turbulence indicators
- *Statistic × Point-wise*: jet-position bias (latitude, altitude)
- *Field × Physical-constraint*: hydrostatic balance, geostrophic balance at extratropical latitudes

**Splits.** `SpatioTemporalBlockSplit(spatial_block_km=500, temporal_block_days=14)`. **By altitude band** (boundary layer / free troposphere / stratosphere) for stratified evaluation.

**Known failure modes.**

- Upper-level (stratosphere) sparser, often higher error
- Tropical winds (no geostrophic constraint) particularly hard
- Boundary-layer wind structure missed at typical model resolution
- Tropospheric gravity waves systematically smoothed
- Jet-streak position: small lat errors propagate into large mid-latitude forecast errors

**Stack mapping.**

- Carriers: `statecatalog` for ERA5/3D fields; `geocatalog` with `ProfileSlice` for sondes (the canonical case for the ProfileSlice type — depth becomes altitude); `geocatalog` for AMV
- Pipeline: `pipekit-cycle` for forecasts; level-resolved operators in `xr_toolz.atm`
- Evaluation: multi-level evaluation; by-altitude lens
- Splits: spatial block + by altitude band

**Gap addressed.** 3D evaluation is reported per-pressure-level in research papers but rarely as a standardised benchmark; the framework’s depth-axis support (from `geodata_lifecycle.md`) makes this clean.

-----

### 3.3 — Atmospheric Pressure (Z500, MSLP, Tropopause)

**Carrier transformation.** Forecast: 3D state → 3D state (future).

**Variant.** Both; ENS / GEFS provide ensemble references.

**Why this matters.** Z500 is the canonical NWP forecast metric (“ACC at Z500” is the headline number for medium-range forecasts); MSLP tracks synoptic systems; tropopause height connects tropospheric and stratospheric dynamics.

**Reference data.**

- Reanalysis: **ERA5**, **JRA-3Q**, **MERRA-2**
- Operational analysis: **ECMWF HRES analysis**, **GFS analysis**

**Tracks.** Model-to-reanalysis, model-to-analysis (higher res operational), model-to-radiosonde.

**Baselines.**

- `PersistenceBaseline`, `ClimatologyBaseline`, `EcmwfOperationalForecast`
- **The CDC-style “no-skill line”** (ACC = 0.6 as the operational threshold)

**Metric set.**

- *Field × Spectral*: **Z500 ACC** (the standard; low-bar; mandatory)
- *Field × Point-wise*: Z500 RMSE
- *Field × Probabilistic*: CRPS, ensemble Z500 ACC
- *Event × Detection*: atmospheric blocking detection (multiple algorithms: Tibaldi-Molteni, AGP)
- *Field × Physical-constraint*: hydrostatic balance, gradient-wind balance
- *Statistic × Point-wise*: storm-track latitude bias

**Splits.** Synoptic timescales: `SpatioTemporalBlockSplit(spatial_block_km=1000, temporal_block_days=14)`. **By ENSO phase**, **by NAO phase** for inter-annual variability.

**Known failure modes.**

- ACC overestimates skill for smooth predictions
- Blocking systematically under-predicted across all models (data-driven and physical)
- Stratospheric sudden warming events badly predicted
- Tropical-extratropical interaction errors

**Stack mapping.**

- Carriers: `statecatalog` for 3D reanalysis; `geocatalog` with `ProfileSlice` for radiosondes
- Pipeline: `pipekit-cycle` for forecasts; blocking-detection operators in `xr_toolz.events`
- Evaluation: full lens × unit matrix; this is the most-evaluated benchmark in any domain
- Splits: synoptic blocks + by phase indices

**Gap addressed.** Already well-instrumented (WeatherBench 2 is the standard). The framework’s contribution here is *content-addressable contracts* — WeatherBench 2 is shared via documentation; making it a hashable artifact would close the verification gap.

-----

## Domain 4 — Remote Sensing

Cross-instrument benchmarks. Less mature as standardised ML benchmarks than weather / ocean, but operationally critical for any multi-sensor product.

### 4.1 — Multispectral ↔ Hyperspectral

**Carrier transformation.** Cross-instrument harmonization, super-resolution: hyperspectral (high spectral, low spatial / temporal) ↔ multispectral (lower spectral, higher spatial / temporal).

**Variant.** Deterministic primarily; uncertainty propagation in research stage.

**Why this matters.** Hyperspectral data is information-rich but coverage-poor; multispectral is the operational workhorse. Cross-instrument fusion is what unlocks both worlds; **the unsolved hyperspectral super-resolution problem** has direct applications in agriculture, water quality, and atmospheric chemistry.

**Reference data.**

- Hyperspectral: **PRISMA** (Italian, 30m, 250 bands), **EnMAP** (German, 30m, 250 bands), **EMIT** (NASA on ISS, 60m, 285 bands), **DESIS** (German, 30m, 235 bands)
- Multispectral: **Sentinel-2 MSI** (10/20/60m, 13 bands), **Landsat 8/9 OLI** (30m, 11 bands), **PlanetScope** (3m, 8 bands)
- Co-located pairs: airborne campaigns (AVIRIS-NG, HYTES) flown over Sentinel-2 / Landsat scenes

**Tracks.** Model-to-coincident-hyperspectral (where simultaneous overflights exist), model-to-airborne (gold standard), model-to-downstream-task (does the predicted hyperspectral improve a known task?).

**Baselines.**

- `SpectralUnmixingBaseline` (classical NMF-based)
- `SpectralAngleBaseline` (cosine-similarity-based per-pixel matching)
- Simple regression (band ratio extrapolation)

**Metric set.**

- *Field × Point-wise*: spectral angle (SAM), band-wise RMSE
- *Field × Spectral*: spectral PSD; reflectance-spectrum smoothness
- *Statistic × Distributional*: end-member spectra preservation
- *Event × Detection*: downstream-task performance (mineral mapping, water-quality classification)
- *Field × Structural*: spatial coherence (SSIM at multispectral resolution)

**Splits.** **Leave-one-scene-out**: each PRISMA / EnMAP scene is a unit. Temporal block (some surfaces evolve seasonally). **By land-cover class** for transferability.

**Known failure modes.**

- Atmospheric correction differences between instruments → systematic spectral biases
- Spatial resolution mismatch: subpixel mixing in low-res, edge effects in high-res
- Sun-target-sensor geometry differences
- Spectral binning: how to compare instruments with different band centers / widths

**Stack mapping.**

- Carriers: `geocatalog` with multi-sensor support; `geopatcher` for co-registered patches
- Pipeline: `geotoolz.spectral` operators; `pipekit-train` for learnable harmonization
- Evaluation: spectral lens emphasised; downstream-task evaluation as a separate report entry
- Splits: leave-one-scene-out

**Gap addressed.** No standard cross-instrument benchmark exists in the community despite the operational need. The carrier-aware framing (`geocatalog` indexes both Sentinel-2 and PRISMA; patcher co-registers) makes this practical to ship.

-----

### 4.2 — Polar-Orbiting ↔ Geostationary

**Carrier transformation.** Cross-platform fusion, temporal super-resolution: polar (high spatial, low temporal) + geostationary (low spatial, high temporal) → both high.

**Variant.** Deterministic; probabilistic variants emerging for nowcasting.

**Why this matters.** Polar orbiters give global high-spatial coverage at low cadence; geostationary gives high-cadence sub-hemisphere coverage at lower spatial resolution. Operational meteorology depends on the fusion; nowcasting (0-2h forecasts) is increasingly driven by this combination.

**Reference data.**

- Polar: **MODIS** (Aqua/Terra), **VIIRS** (NOAA-20, SNPP, NOAA-21), **Sentinel-3 OLCI / SLSTR**
- Geostationary: **GOES-16/18** (US), **Meteosat-11/12** (Europe), **Himawari-9** (Japan), **GeoKompsat / FY-4B** (Korea / China)
- Co-located: simultaneous-overpass pairs at sub-daily cadence

**Tracks.** Model-to-coincident-overpass (where polar and geo see the same scene), model-to-in-situ (where ground stations validate both).

**Baselines.**

- Temporal interpolation of polar to geostationary cadence
- Simple bilinear regridding of geostationary to polar resolution
- Time-aligned averaging

**Metric set.**

- *Field × Point-wise*: spectral RMSE at coincident pixels
- *Field × Structural*: spatial PSD comparison
- *Temporal × Point-wise*: temporal RMSE at hourly cadence (does the polar-to-geo time-extension preserve the diurnal cycle?)
- *Field × Physical-constraint*: smooth transitions across the polar/geo handover boundary
- *Event × Detection*: rapid-developing convection (fast events) — does the higher cadence help?

**Splits.** **By season** (geometric viewing-angle effects); **by latitude band** (polar coverage gets denser with latitude; geo coverage drops); **by sensor pair**.

**Known failure modes.**

- Viewing-geometry differences (oblique geo vs. nadir polar) → spectral biases
- Sub-pixel cloud contamination at lower geo resolution
- Sun-glint geometry differs between platforms
- Cross-sensor calibration drift over mission lifetimes
- High-latitude poor geo coverage → model trained on tropics fails at poles

**Stack mapping.**

- Carriers: `geocatalog` for both platform types; `geocatalog.queries.matchup` for coincident-overpass pairs (the canonical use of the matchup pattern)
- Pipeline: `pipekit-cycle` for temporal super-resolution; `geopatcher` for spatial alignment
- Evaluation: temporal + spatial + cross-sensor consistency
- Splits: by latitude band + by sensor pair

**Gap addressed.** Operational meteorology centers do this internally but rarely as a public benchmark. Standardizing it would help the NWP and nowcasting communities.

-----

### 4.3 — Radiative Transfer Model (RTM) Emulation

**Carrier transformation.** Forward simulation / emulation: atmospheric + surface state → simulated radiances.

**Variant.** Deterministic; with Jacobian (gradient) requirements for inverse problems.

**Why this matters.** RT calculations are the inner loop of nearly every retrieval; they’re expensive (LBLRTM minutes per scene); neural emulators offering 100× speedup with maintained accuracy + differentiability unlock differentiable retrievals (per Report 5 on `pipekit-jax`).

**Reference data.**

- Reference physics: **LBLRTM** (Line-By-Line RTM; gold standard for accuracy)
- Operational: **MODTRAN**, **6S**, **COART** (for ocean)
- For comparison: existing emulators (RTTOV, CRTM, RTNN)

**Tracks.** Model-to-LBLRTM (accuracy), model-to-MODTRAN (operational), model-to-actual-observations (the strongest test — does emulating RT closely enough that the retrieval still works?).

**Baselines.**

- `LookupTableBaseline` (the classical fast-RTM approach)
- `PolynomialRegressionBaseline` (per-band)
- `RTTOV / CRTM` standard operational emulators

**Metric set.**

- *Field × Point-wise*: spectral RMSE (radiance units)
- *Statistic × Point-wise*: Jacobian (gradient) fidelity — critical for differentiable retrievals
- *Field × Physical-constraint*: spectral monotonicity where physics requires it
- *Field × Point-wise*: speedup factor (forward and backward passes vs. reference)
- *Event × Detection*: regime-of-applicability (does the emulator fail catastrophically outside training distribution?)

**Splits.** **By atmospheric state regime** (clear / aerosol / cloudy); **by surface type** (ocean / vegetation / desert / snow); **by gas concentration range**. Train on standard distributions, test on extremes (high methane, high aerosol load).

**Known failure modes.**

- Out-of-distribution gas concentrations: standard emulators trained on background values fail at point-source plumes
- Multi-scattering regimes (heavy aerosol, broken cloud): physics-based RT handles, emulators often don’t
- Gradient quality: a model that’s accurate on forward radiance can have noisy / wrong gradients
- Spectral edge effects: band-edge accuracy drops

**Stack mapping.**

- Carriers: standard array carriers; no spatial extent (this is a point-wise emulator)
- Pipeline: `pipekit-train.SimulationDataset` driven by an RTM forward model is the canonical case
- Evaluation: `pipekit-evaluate` with Jacobian-fidelity as a custom metric; speedup as a stage-axis comparison
- Splits: by atmospheric regime + surface type

**Gap addressed.** RT emulator benchmarks exist in research papers (RTTOV-NN, RTNN) but rarely with the Jacobian-fidelity + out-of-distribution evaluation that operational retrievals need.

-----

### 4.4 — Satellite Sensor Operators (SRF, PSF, Noise)

**Carrier transformation.** Instrument simulation / inverse instrument simulation: high-resolution truth → instrument-degraded observation; or inverse.

**Variant.** Deterministic for forward instrument simulation; probabilistic for inversion.

**Why this matters.** The instrument is the boundary between the physical world and the data. Errors here cascade through every downstream product. Sensor-operator emulators that correctly model SRF (spectral response function), PSF (point spread function), and noise statistics are what enable OSSEs (Observing System Simulation Experiments) and counterfactual analyses (“what if we had this sensor?”).

**Reference data.**

- Pre-launch characterization: vendor-supplied SRF / PSF / noise specs
- On-orbit calibration: lunar / solar / vicarious calibration data
- For inversion: matched in-situ vs. observed

**Tracks.** Simulator-to-actual-instrument (degrade truth, compare to actual L1); model-to-pre-launch-spec (validate against vendor characterization).

**Baselines.**

- Pure convolution + Gaussian noise (the simplest possible sensor operator)
- Vendor-provided sensor models

**Metric set.**

- *Field × Point-wise*: per-band radiometric RMSE
- *Statistic × Point-wise*: spectral fidelity, noise characterization (NEdT, NEdL); detector-array spatial-variation fitting
- *Field × Spectral*: MTF (Modulation Transfer Function) reconstruction
- *Field × Physical-constraint*: positivity, monotonicity where physics requires
- *Event × Detection*: detection-of-instrument-anomaly (does the model flag known on-orbit issues?)

**Splits.** **By spectral band**; **by detector array element** (different detectors have different responses); **by mission phase** (pre-launch / commissioning / nominal / end-of-life).

**Known failure modes.**

- Detector-specific artifacts (striping, dead pixels, hot pixels) hard to model
- Time-dependent calibration drift
- Cross-talk between adjacent bands or detectors
- Stray light contamination at scene edges

**Stack mapping.**

- Carriers: `geocatalog` for both ground truth and sensor outputs
- Pipeline: `geotoolz` sensor-specific operators; `pipekit-train.SimulationDataset` for forward sensor simulation
- Evaluation: spectral + structural + physical-constraint lenses
- Splits: by mission phase + by band + by detector

**Gap addressed.** Sensor operator benchmarks are typically internal to space agencies; making them public benchmarks would benefit the OSSE community.

-----

### 4.5 — Multi-Satellite Fusion (NEW)

**Carrier transformation.** Cross-sensor fusion: multiple sensor streams (e.g., MODIS + geostationary; Sentinel-2 + Sentinel-3; PRISMA + Sentinel-2) → unified product.

**Variant.** Both deterministic and probabilistic; ensemble fusion is increasingly used for uncertainty propagation.

**Why this matters.** No single sensor gives everything you want; multi-sensor fusion is what gives operational products their robustness. **A canonical benchmark for “modern remote sensing” as it’s actually practiced.** Most operational L4 products (OSTIA, OC-CCI, IMERG, ECV products) are multi-sensor fusions internally.

**Reference data.**

- Operational fusion products: **OSTIA** (SST, multi-mission), **OC-CCI** (ocean colour, multi-mission), **IMERG** (precipitation, multi-satellite), **GlobColour**
- Component sensors: MODIS, VIIRS, SLSTR for SST; SeaWiFS, MODIS, MERIS, OLCI for OC; GPM, geostationary IR for precipitation
- Ground truth: where available, in-situ data

**Tracks.** Model-to-operational-fusion (does your fusion beat the operational product?); model-to-single-sensor (where overlap exists, does multi-sensor add value?); model-to-in-situ (the strongest test).

**Baselines.**

- Operational fusion product (the standard to beat)
- Weighted averaging across sensors with inverse-variance weights
- Sequential overpass averaging
- Sensor-specific climatology fallback

**Metric set.**

- *Field × Point-wise*: RMSE / bias by sensor combination
- *Field × Structural*: temporal continuity across sensor handovers (no jumps in time series); spatial continuity at swath edges
- *Statistic × Point-wise*: cross-sensor bias minimization
- *Event × Detection*: events captured by fusion but missed by any single sensor (the genuine value-add)
- *Field × Physical-constraint*: variance preservation (fusion shouldn’t excessively smooth)
- *Temporal × Point-wise*: gap-filling skill at known handover points

**Splits.** **Leave-one-sensor-out**: train fusion on N-1 sensors, test on full N (does the model still produce a sensible product when one sensor is missing?). **Temporal block**. **By sensor-combination availability** (some years have more sensors than others).

**Known failure modes.**

- Cross-sensor calibration errors propagated rather than corrected
- Geolocation mismatches at high latitudes (different orbits = different ground tracks)
- Sun-glint geometry differs between platforms → biased fusion at certain seasons
- Sensor lifecycle effects (early commissioning artifacts, end-of-life drift)
- “Best sensor wins” failure: model learns to ignore lower-quality sensors → worse fallback when high-quality unavailable

**Stack mapping.**

- Carriers: `geocatalog` with multi-sensor catalogs (one per sensor); cross-sensor matchups via `geocatalog.queries.matchup`
- Pipeline: `pipekit-cycle` for time-varying fusion; `geopatcher` for spatial alignment; `pipekit-train` for learnable fusion weights
- Evaluation: temporal continuity + cross-sensor consistency emphasised; event detection for “gain from fusion”
- Splits: leave-one-sensor-out + temporal block

**Gap addressed.** Multi-sensor fusion is *how operational products work* but isn’t standardised as an ML benchmark. The user’s specific example (MODIS + geostationary) is one of the most operationally important: high-cadence diurnal-cycle resolution combined with high-spatial-resolution snapshots. The framework’s catalog-and-matchup machinery is purpose-built for this case.

-----

## Domain 5 — Mathematical Models

The benchmarks here are different in shape: they test **a chain of dependent sub-tasks**, not a single transformation. Methane emission estimation is the canonical example — five linked steps from radiative transfer to total emission.

### 5.1 — Emission Estimation (Multi-Stage Inverse Problem)

This is a meta-benchmark composed of five sub-benchmarks. Each sub-stage is independently benchmarkable; the full chain is also benchmarkable end-to-end.

```
   Stage 1: Radiative Transfer Model (RTM)
   ──────────────────────────────────────
   Carrier: atmospheric+surface state → radiances
   (See section 4.3 above; RT emulation is the underlying capability)
   
            ▼
   Stage 2: Plume Simulation (Forward Model Emulation)
   ───────────────────────────────────────────────────
   Carrier: source emission rate + meteorology → downwind concentration field
   References: HYSPLIT, FLEXPART, WRF-Chem; controlled-release ground truth
   
            ▼
   Stage 3: Probability of Detection (POD Curve)
   ─────────────────────────────────────────────
   Carrier: scene + emission characteristics → probability of being detected
   References: METEC controlled-release campaigns (known emission rates,
              measured detection rates per overpass)
   
            ▼
   Stage 4: Source Persistency
   ────────────────────────────
   Carrier: source-history time-series → persistence probability
   References: long-term monitoring of known persistent emitters
              (oil and gas facilities, landfills, agricultural sources)
   
            ▼
   Stage 5: Total Emission
   ─────────────────────────
   Carrier: detections + persistencies + durations → mass flux (kt/year)
   References: bottom-up inventories (EDGAR, EPA GHGRP), tall-tower
              regional flux estimates, controlled-release totals
```

**Why this matters.** **The headline operational case for MARS / IMEO**. Each stage has its own ML opportunity; the chain has compound uncertainty that matters operationally. The benchmark structure forces evaluation at each stage *and* end-to-end, which is what regulatory applications require.

**Reference data, by stage:**

- Stage 1 (RTM): LBLRTM, MODTRAN
- Stage 2 (Plume): HYSPLIT, FLEXPART, WRF-Chem; **METEC controlled releases**
- Stage 3 (POD): **METEC field campaigns**, **OGCI field measurements**, **MethaneAIR**
- Stage 4 (Persistency): IMEO’s long-term monitoring data
- Stage 5 (Total): EDGAR inventory, IPCC tier-1/2/3 inventories, top-down inversions (CarbonTracker, TM5-4DVAR)

**Tracks.** **Model-to-controlled-release** is the gold standard (Stages 1-3); model-to-inventory for Stages 4-5 (with the caveat that inventories themselves have large uncertainties); model-to-aircraft for spot checks.

**Baselines.**

- Stage 1: `LookupTableBaseline`, **MODTRAN as reference**
- Stage 2: `GaussianPlumeBaseline`; FLEXPART as reference
- Stage 3: `MatchedFilterBaseline` (matched filter retrieval thresholded by SNR)
- Stage 4: persistence (yesterday’s detection = today’s prediction)
- Stage 5: per-source IPCC tier-1 emission factors

**Metric set.**

- Stage 1: spectral RMSE, Jacobian fidelity, speedup
- Stage 2: concentration RMSE, plume-position error (centroid), plume shape (IoU)
- Stage 3: **POD curve fit (canonical)** — POD vs. emission rate; minimum detection limit
- Stage 4: persistence prediction skill (Brier score), false-persistence rate
- Stage 5: **per-source mass error**, regional total bias, attribution accuracy, **cascade uncertainty** (does the predicted uncertainty match the empirical error?)

**Splits.**

- **Leave-one-region-out**: train on most regions, test on one (Permian / Bakken / Algerian Sahara / Australian outback)
- **Leave-one-source-class-out**: oil-and-gas / coal / landfill / agriculture / wetland / wildfire
- **Temporal block**, with **METEC controlled-release data strictly held out** because controlled releases recur
- For end-to-end: leave-one-controlled-campaign-out

**Known failure modes.**

- Cascade error: Stage 1 emulator small error → Stage 2 input distribution shifted → Stage 3 detection biased → Stage 5 total wrong
- Background variability: weather-driven background concentration fluctuations interpreted as emission changes
- Low-emission detection: physics-imposed minimum detection limit creates a floor that models can’t beat
- Attribution ambiguity: nearby sources cause attribution flips
- Inventory-prior bias: training on EDGAR-prior data → model regresses to EDGAR; doesn’t help with unknown sources

**Stack mapping.**

- Carriers: full GeoStack engagement
  - `geocatalog` for L1/L2/L3 satellite (per-source observations)
  - `statecatalog` for plume simulations + analysis products
  - `EventCatalog` (new, per Report 14) for detected plumes
- Pipeline:
  - Stage 1: `pipekit-train.SimulationDataset(forward_model=RTM)` → emulator in `pipekit-experiment.ModelRegistry`
  - Stage 2: `pipekit-train.SimulationDataset(forward_model=PlumeForward)` → emulator in registry; or used directly via `pipekit-cycle.NeuralForward`
  - Stage 3: `pipekit-train.CatalogDataset` with `(scene, label)` pairs from controlled releases
  - Stage 4: time-series operators in `xr_toolz`; or `pipekit-cycle.Recurrence` for iterative updating
  - Stage 5: `pipekit-cycle.DACycle` for full Bayesian inversion; or learnable amortized version via `pipekit-train` with normalizing flows
- Evaluation: `pipekit-evaluate.MultiStageEvaluation` (a new pattern: chain-of-stages reporting)
- Splits: by region + by source class + temporal; controlled-release strict held-out

**Gap addressed.** **The canonical end-to-end benchmark for MARS / IMEO.** Multi-stage benchmark contracts aren’t currently a thing in geophysical ML; the framework’s content-addressed contract + multi-track evaluation pattern + cascade-uncertainty discipline together make this shippable. This is probably the single most important benchmark in this gallery from a real-world impact perspective.

-----

## Cross-domain observations

A few patterns visible across the six domains:

### Pattern 1 — The three tracks are almost always available

Of 22 benchmarks across the gallery, only 1-2 lack a model-to-observations track. Reanalysis + analysis + observations is broadly available across geophysical domains. **The OceanBench multi-track pattern is generalizable.**

### Pattern 2 — The hardest splits are platform-based, not temporal

Many benchmarks rely on `LeaveOnePlatformOut` (one Argo float held out; one METEC campaign held out; one station network held out). Temporal blocks alone are not enough for spatial-correlation-rich data. **`LeaveOnePlatformOut` is more important than the source acknowledges.**

### Pattern 3 — Probabilistic is mandatory for some variables, optional for others

Precipitation, BGC, emission attribution: probabilistic is mandatory. SSH, SST: deterministic is the standard. **The variant decision is data-driven, not a framework choice.** Benchmark contracts should declare which is required.

### Pattern 4 — Event detection is undervalued in current practice

Every domain in the gallery has at least one event-detection metric that adds operational value. Heat waves, eddies, blooms, blocking, plumes, cyclones — these are what end-users care about. **Field-only evaluation systematically hides the operationally important behavior.**

### Pattern 5 — Cascade benchmarks (chains of sub-tasks) need their own pattern

Stage-1-to-Stage-5 emission estimation is structurally different from single-step benchmarks. The framework needs a `MultiStageEvaluation` pattern (mentioned in section 5.1) that aggregates per-stage reports and computes cascade-uncertainty estimates. **This is missing from Report 14 and worth adding to v0.2 of pipekit-evaluate.**

-----

## Recommendations summary

For each domain, the framework primarily needs the same things:

1. **A content-addressed contract** (Report 15 framework piece)
2. **Leakage-aware splitters** (the platform-leave-out variants especially)
3. **Standard baselines** as registered operators
4. **Multi-track evaluation** as a built-in pattern
5. **Event detectors** in `xr_toolz.events` (most domains have at least one critical event type)
6. **Probabilistic metrics** as first-class peers to point-wise metrics
7. **Profile / trajectory catalogs** for in-situ-heavy benchmarks (BGC, sondes, drifters)

These map onto the Report 14 + Report 15 + `geodata_lifecycle.md` recommendations cleanly. **No new packages required**; the existing scoping reports cover the needs.

Two new patterns surfaced by this gallery that should be added to pipekit-evaluate v0.2:

- **`MultiStageEvaluation`** for cascade benchmarks (emission estimation, multi-step retrieval chains)
- **`CircularRMSE`** as a standard metric for vector-direction variables (wind direction, ocean currents)

Estimated additional work: ~3-5 days each. Both are small compared to the gallery’s value.

-----

## What this gallery is NOT

Worth being explicit. This is not:

- A leaderboard. The framework provides contracts; running submissions is organisational work.
- A standardisation effort. Existing benchmarks (OceanBench, WeatherBench, etc.) own their domains; this gallery shows how those benchmarks could be expressed against the framework, not displaced.
- Comprehensive. Many sub-benchmarks within each domain (e.g., regional sea-ice benchmarks, terrestrial carbon flux benchmarks, fire-radiative-power benchmarks) are not covered.
- Final. These are draft contracts; real benchmarks require domain-expert review of the metric choices, baselines, and split rules.

The gallery’s purpose is to make the framework concrete by working through 23 realistic benchmark designs. If a real benchmark were to adopt the framework, this gallery is the template to adapt — not a finished product to use.