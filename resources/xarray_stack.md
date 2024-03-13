---
title: XArray Stack
subject: Available Datasets in Geosciences
short_title: xarray stack
authors:
  - name: J. Emmanuel Johnson
    affiliations:
      - CSIC
      - UCM
      - IGEO
    orcid: 0000-0002-6739-0053
    email: juanjohn@ucm.es
license: CC-BY-4.0
keywords: data
---

## Data Structures

### Rasters

> In general, xarray can handle most of the raster calculations.
> Shoutout to `numpy` because it always comes in handy to know how to do some operations by onesself.

**[xarray]()**

**[numpy]()**

**[xarray-dataclasses](https://github.com/astropenguin/xarray-dataclasses)** - create standardized xarray datasets and dataarrays

***
### Vectors

> If we want to manipulate polygons and convert them into raster format, we need a specialized package to do so.

**[GeoCube](https://corteva.github.io/geocube/latest/index.html)** - compatibility between rasters and vectors

***
## Remote Sensing

> Here, we refer to satellite observations.

**[SatPy](https://satpy.readthedocs.io/en/stable/)** - read some common satellite data into xarray datasets.


**[GeoWombat](https://geowombat.readthedocs.io/en/latest/index.html)** - General purpose raster processor

***
## **Masks**

**[regionmask](https://regionmask.readthedocs.io/en/stable/)** - working with masks and shape files for xarray


***

### **Coordinate Projections**

**[rioxarray](https://corteva.github.io/rioxarray/stable/)** - rasterio and xarray compatibility

**[GeoBox](https://github.com/opendatacube/odc-geo)** - A great little library for handling coordinates and projections. 
This is an example of [GeoCube-Rioxarray Compatibility](https://github.com/corteva/geocube/blob/master/geocube/geo_utils/geobox.py)



***

## **Math**

#### **Linear Algebra**

**[xarray-einstats](https://einstats.python.arviz.org/en/latest/)** - linear algebra, Einops and statistics

**General Array Operations**

```python
ds: XRDataset["T X Y"] = ...
# combine dimensions
ds: XRDataset["N"] = rearange(ds, "(T X Y)=N")
ds: XRDataset["N T"] = rearange(ds, "(X Y)=Samples")
# Creating Patches
ds: XRDataset["N"] = rearange(ds, "T X Y -> ")
# aggregate dimensions
# options: mean, min, max, sum, prod
ds: XRDataset["T"] = reduce(ds, "X Y", "mean")
ds: XRDataset["X Y"] = reduce(ds, "T", "mean")
# pooling (max, average)
```


#### **PCA/EOF/POD**

**[xeofs](https://github.com/xarray-contrib/xeofs)** - empirical orthogonal functions (PCA)


***
#### **Derivatives**

**[MetPy](https://unidata.github.io/MetPy/latest/index.html)** - derivatives and geophysical calculations

**[xinvert](https://xinvert.readthedocs.io/en/latest/)** - Poisson equation inversion with numba

***
#### **Spectral**

**[xrft](https://github.com/xgcm/xrft)** - Fourier transforms 


**[xwavelet](https://github.com/roxyboy/xwavelet)** - Wavelet Transforms with xarray


#### **Units**
* [pint-xarray](https://pint-xarray.readthedocs.io/en/stable/index.html) - units aware xarray

***

## **Interpolation**

**[xarray-regrid](https://github.com/EXCITED-CO2/xarray-regrid)** - regrid rectilinear grids

**[pyinterp](https://pangeo-pyinterp.readthedocs.io/en/latest/)** - interpolation for unstructured grids and nans

**[xesmf](https://pangeo-xesmf.readthedocs.io/en/latest/)** - regrid curvilinear grids


**[pyresample](https://pyresample.readthedocs.io/en/latest/)**

**[geotiepoints](https://python-geotiepoints.readthedocs.io/en/latest/)**

***
## **Filtering**

* [GCM-filter](https://gcm-filters.readthedocs.io/en/latest/)
* [xr-scipy](https://github.com/hippalectryon-0/xr-scipy)

***
## **Metrics**

**[xskillscore](https://github.com/xarray-contrib/xskillscore)** - pixel-wise metrics using ufuncs 

***

## **Climate**

**[xcdat](https://xcdat.readthedocs.io/en/latest/)** - climatology and weighted spatiotemporal reductions


***

## **Scale**

> We often need to deal with a large amount of data which is more

***[Dask Ecosystem]()**.
***[xarray-beam](https://xarray-beam.readthedocs.io/en/latest/index.html)**.

***

## **Visualization**

**[Holoviz](https://holoviz.org/)** | **GeoViews** | **datashader**

**[lexcube](https://github.com/msoechting/lexcube)**

**[Terracotta ](https://github.com/DHI/terracotta)** - easily create a nice database for visualizing geotiffs.

**Matplotlib + Cartopy**

**Seaborn**. 
This is great for plotting pixel distributions.
