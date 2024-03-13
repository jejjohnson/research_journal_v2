---
title: Google Earth Engine
subject: ML4EO
short_title: Google Earth Engine
authors:
  - name: J. Emmanuel Johnson
    affiliations:
      - CSIC
      - UCM
      - IGEO
    orcid: 0000-0002-6739-0053
    email: juanjohn@ucm.es
license: CC-BY-4.0
keywords: notation
---


# Helpful Packages

## [**`xee`**](https://github.com/google/Xee/tree/main)

### PseudoCode


```python
import ee
import xarray as xr
# initialise (no need for a log-in!)
ee.Initialize(opt_url='https://earthengine-highvolume.googleapis.com')
# initialise image collection
ic = ee.ImageCollection("ECMWF/ERA5_LAND/HOURLY")    # ERA5 Reanalysis
ic = ee.ImageCollection("NASA/GDDP-CMIP6")           # CMIP6 Simulations
# filter for specific date
ic = ic.filterDate('1992-10-05', '1993-03-31')
# define geometry
geometry = ee.Geometry.Rectangle(113.33, -43.63, 153.56, -10.66)
projection = ic.first.select(0).projection()
scale = 0.25 # km
crs = "EPSG:4326" # Coordinate Reference system
# open dataset
ds = xr.open_dataset(
    ic, 
    engine='ee',
    projection=projection,
    crs=crs, scale=0.25, geometry=geometry
)

```

## [**`eemount`**](https://eemont.readthedocs.io/en/latest/)

### PsuedoCode

```python
import ee, eemont
   
ee.Authenticate()
ee.Initialize()

point = ee.Geometry.PointFromQuery(
    'Cali, Colombia',
    user_agent = 'eemont-example'
) # Extended constructor

S2 = (ee.ImageCollection('COPERNICUS/S2_SR')
    .filterBounds(point)
    .closest('2020-10-15') # Extended (pre-processing)
    .maskClouds(prob = 70) # Extended (pre-processing)
    .scaleAndOffset() # Extended (pre-processing)
    .spectralIndices(['NDVI','NDWI','BAIS2'])) # Extended (processing)
```


## [**`wxee`**](https://wxee.readthedocs.io)


# Climate Data Store

# Marine Data Store

# NASA EarthAccess