---
title: Observations
subject: Available Datasets in Geosciences
short_title: Observations
authors:
  - name: J. Emmanuel Johnson
    affiliations:
      - CSIC
      - UCM
      - IGEO
    orcid: 0000-0002-6739-0053
    email: juanjohn@ucm.es
license: CC-BY-4.0
keywords: observations
---


## L-Scale

**L0**. 
This is raw signal that is retrieved from satellites or sensors.
We rarely get access to this kind of data and sometimes it's not even available for public use.

**L1**.
This is the data that has been minimally transformed to meaningful physical units.
For example, radiances or height.
They also have geometric corrections and some internal quality flags like data quality or probability cloud.
Lastly, they typically remove some noise, have geometric corrections, and include sensor-specific calibrations.

**L2**.
This is data that has been processed and corrected.
Some corrections include atmospheric effects, noise and quality enhancements.
In general, the data is better calibrated for specific variables of interest for different communities like vegetation and temperature.
Thus, this stage of data is usually ready for scientific analysis and specific use cases.

**L3**.
This is data that has been aggregated in time and space to get nice clean scenes.
They are typically aggregates of the L2 products.
These are aggregates so they are useful for the community to study more long term trends like climate and environmental monitoring.


***
## L1 Data Products

The list below organizes the products by 

#### MODIS

This data comes from the MODIS satellite sensor. 
It is an orbiting satellite so it takes measurements along track
It measure radiances and reflectances from the sensor along the satellite SWATH

#### GOES

This data comes from the GOES 16/17/18 sensors.
This is a geostationary satellite so it takes fixed measurements over an area at a relatively high frequency.
The give radiance values.

#### MSG

This data comes from the Meteosat sensors.
This is a geostationary satellite so it takes fixed measurements over an area at a relatively high frequency.
The give radiance values.

***
## L2 Data Products

It is better to organize these products by the actual variable of interest.

```{list-table} Table with idealized configuration
:header-rows: 1
:name: tb:qg_idealized

* - Variable
  - Satellite Type
  - Spatial Resolution
  - Revisit Time
  - Project
* - Sea Surface Height
  - Altimeter
  - `7x7 km`
  - `5 Hz`
  - 
* - Sea Surface Temperature
  - Orbiting
  - `7x7 km`
  - `5 Hz`
  - 

```

#### Sea Surface Height

We have various ways to measure sea surface height: altimetry and in-situ measurements.
These measurements are crucial for studying ocean circulation, monitoring sea level rise, detecting ocean currents, and understanding climate change impacts on the oceans.

These are typically altimetry satellites that measure the sea surface height.
They can be characterized into two classes: NADIR track and SWOT data.
We have many nadir tracks which have a higher frequency (`5 Hz`) but a very small spatial window (`7x7 km`).
An example product can be found on the [Copernicus Website](https://data.marine.copernicus.eu/product/SEALEVEL_GLO_PHY_L3_NRT_008_044/description).
The SWOT data is a recent addition which is a satellite which measures sea surface height along a SWATH. 
This has a lower spatial resolution but a.

#### Sea Surface Temperature

We have a multisensor product called [ODYSSEA](https://data.marine.copernicus.eu/product/SST_GLO_SST_L3S_NRT_OBSERVATIONS_010_010/description).m

* Sea Surface Temperature - [Multi-Sensor Fusion](`0.1 x 0.1 deg, daily`)

#### Sea Surface Salinity

* Sea Surface Salinity - [SMOS CATDS](https://data.marine.copernicus.eu/product/MULTIOBS_GLO_PHY_SSS_L3_MYNRT_015_014/description) (`0.25 x 0.25 deg, Daily`)

#### Ocean Colour

Ocean Colour - [Copernicus GLOBCOLOUR](https://data.marine.copernicus.eu/product/OCEANCOLOUR_GLO_BGC_L3_MY_009_103/description) (`4 x 4 km | 0.3 x 0.3 km, Daily`)


#### In-Situ 
vv
- [ARGO Floats](https://github.com/euroargodev/argopy)
- [Aritcle](https://www.frontiersin.org/articles/10.3389/fmars.2019.00419)


***
## L3 Products

#### **L3 Gap-Filled Observations**

- Sea Surface Height - [Interpolated Satellite Data](https://data.marine.copernicus.eu/product/SEALEVEL_GLO_PHY_L4_NRT_008_046/description) (`0.25 x 0.25 deg, Daily`)
- Sea Surface Temperature 
  - [Multi-Sensor Fusion (ODYSSEA)](https://data.marine.copernicus.eu/product/SEALEVEL_GLO_PHY_L4_NRT_008_046/description)(`0.1 x 0.1 deg, daily`)
  - oSTIa - [](https://data.marine.copernicus.eu/product/SST_GLO_SST_L4_NRT_OBSERVATIONS_010_001/description) (`0.05 x 0.05 deg, daily`)
- Sea Surface Salinity - [Multisensor](https://data.marine.copernicus.eu/product/MULTIOBS_GLO_PHY_S_SURFACE_MYNRT_015_013/description) (`0.125 x 0.125 deg, Daily`)
- Ocean Colour - [Copernicus GLOBCOLOUR]([](https://data.marine.copernicus.eu/product/OCEANCOLOUR_GLO_BGC_L4_MY_009_104/description) (`4 x 4 km | 0.3 x 0.3 km, Daily`)
