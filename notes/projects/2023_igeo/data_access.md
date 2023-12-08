# Data Access


A few resources for quickly accessing datasets.

## Database

[**Google Earth Engine**](https://developers.google.com/earth-engine/datasets/catalog)

[**Marine Data Store (MDS)**]()

[**Climate Data Store (CDS)**]()

[**MARS Archive**](https://www.ecmwf.int/en/forecasts/access-forecasts/access-archive-datasets)


---
## [`xee`](https://github.com/google/Xee/tree/main)



```python
import ee
import array
# initialise (no need for a log-in!)
ee.Initialize(opt_url='https://earthengine-highvolume.googleapis.com')
# initialise image collection
ic = ee.ImageCollection("ECMWF/ERA5_LAND/HOURLY")    # ERA5 Reanalysis
ic = ee.ImageCollection("NASA/GDDP-CMIP6")           # CMIP6 Simulations
# filter for specific date
ic = ic.filterDate('1992-10-05', '1993-03-31')
# define geometry
geometry = ee.Geometry.Rectangle(113.33, -43.63, 153.56, -10.66)
# open dataset
ds = xarray.open_dataset(
    ic, 
    engine='ee',
    projection=ic.first().select(0).projection(),
    crs='EPSG:4326', 
    scale=0.25, 
    geometry=geometry
)

```

---
## [`eemount`](https://github.com/davemlz/eemont)

---
## [`wxee`]()

---
## [`CliMetLab`]()


```python

# define data source
data_source = "ecmwf-open-data" # "cds" | "mars"
# define dataset name
dataset_name = "reanalysis-era5-single-levels"
# define parameters
param = ["2t", "msl"]
param = {"param1": "val1"}
# ==========
# define domain
domain = "France" # "Spain"
area = [lon_min, lon_max, lat_min, lat_max]
# define period
period = (1991, 2001)
date = ["2012-12-12", "2012-12-13"],         # "2012-12-12"
time = [600, 1200, 1800],                    # "12:00" | 12
# define output format
format = "netcdf",                           # "grib" | "odb"
# load source
source = cml.load_source(
   "cds",
   dataset_name,
   param=param,
   product_type="reanalysis",
   grid='5/5',
   area=area, domain=domain,
   date=date, period=period, time=time,
   format=format,
)
# convert to xarray
ds: xr.Dataset = source.to_xarray()
df: pd.DataFrame = source.to_dataframe()
```
