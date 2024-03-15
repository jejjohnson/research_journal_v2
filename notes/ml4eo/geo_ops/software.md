---
title: Geo Ops Software
subject: ML4EO
short_title: Software
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



### Data Harmonization

> Input EO data tends to be very messy and heterogeneous. 
> Even the best packages have certain quirks when loading the data. The routines in this part are meant to clean the data in an attempt to "harmonize" them.

**`validation`** - some routines to validate the coordinates.
This includes the usual suspects like lat, lon and time.
We also have some other candidates like sea surface height or temperature.

**`subset`** - these are routines to be able to effectively select a subset of the dataset based on regions and periods.

**`masks`** - these are some routines to add masks to our datasets.
Some usual suspects include the land and ocean as well as some countries, peninsulas, or other official scientific zones.

**`crs`** - some routines for embedding and validating coordinate reference systems.

**`datastructure`** - these hold general purpose methods for converting to xarray datastructures (aka rasters) from other data structures including numpy arrays, polygons, or unstructured coordinates. 

**`dtypes`** - we have some custom data types which are in the form of xarray coordinates or variable names.
These are useful for generating datasets and/or validating datasets.

***
### High-Level Routines

**`grid`** - some general routines for defining grids and transforming grids.
Some subroutines include `regridding` whereby we provide some target grid to regrid our current coordinates to that grid.
Another subroutine includes `resample/coarsen` whereby we reduce the resolution based on some metric like the resolution or a factor.


**`encoders`** - has some subroutines to calculate transformations on the coordinates themselves.
The `spatial` subroutine deals with spatial coordinates like lat-lon and spherical, cartesian or cartesian.
The `time` subroutine deals with absolute groups as well as some temporal embeddings.
The `wavelength` subroutine deals with spectral channels.


**`kinematics`** - a tool to calculate physical quantities.
For example, in remote sensing we have radiance, reflectance. 
In oceanography and meteorology, we have sea surface height, stream function, etc.

**`spectral`** - a tool to calculate some spectral transformations for space and time.
These include some isotropic metrics and some space-time specific transformations.

**`discretization`** - some recipes to calculate some discretization schemes using histograms.
We have options to do it in a windowed formulation in space and time or just space.
Some options include counts, max, and mean.

**`interpolation`** - Som general recipes for doing interpolation.
The `grids` subroutine has functions for transforming with all grids like Unstructured, Curvilinear, Rectilinear, or Regular.
The `fillnan` subroutine is particular for interpolating NANs within a defined boundary.


**`detrend`** - Some general routines for detrending the data.
The `climatology` subroutine calculates trends based on definite frequency groups, e.g., *season*.
The `anomalies` subroutine removes trends based on climatology and filtering (optional).
The `filter` subroutine removes trends based on some filtering scheme in wavelength, space, and/or time.

**`extremes`** - some general routines for calculating extremes from data.
The `bm` subroutine uses the *block-maxima* method calculates the trends based on a block-wise, typically a year or a season.
The `pot` subroutine uses the *peak-over-threshold* method to calculate the extremes based on a threshold.
It also features a declustering method which uses a moving window.


***
### Metrics

**`pixel`** - are pixel-based metrics that operate on the pixels individually.
In general, we can simply use these custom functions directly or we can use them with `xarray.u_func` to vectorize the operations and preserve dimensions. 

**`spectral`** - are spectral-based metrics.
This means applying a Fourier or Wavelet decomposition and then applying the metrics on the spectral space.

**`multiscale`** - are multiscale metrics which operate on different spatial scales.
This means applying a spatial filter at a particular scale and then applying the metrics.

***
### Visualizations

> The `viz` package has some lightweight visualizations that might be useful for users.


***
### `Toolz` Compatibility

The objective is to be able to pipe these transformations through functions like `xarray.Dataset.pipe` and `toolz`.
These are immensely helpful when trying out different preprocessing and geoprocessing operations in conjunction with machine learning.
This gives the user the flexibility to try out different preprocessing strategies to see which yield the best results. 
The user could also use some of these transformations to process data on the fly for training or for inference.
Furthermore, this exposes some of the preprocessing decisions in a more transparent manner that is readable and extendible which allows users to understand, critique and improve.

**Example (PseudoCode)**

```python
# create the function type
FN_TYPE: Callable[[xr.Dataset], xr.Dataset]
# create preprocessing functions
fn1: FN_TYPE = validate_lon
fn2: FN_TYPE = partial(reproject, crs="crs")
fn3: FN_TYPE = partial(fillnans, method="gauss_siedel")
# create sequential function
fnX: FN_TYPE = compose_left(fn1, fn2, fn3)
# open xarray datarray with function composition
ds: xr.Dataset = xr.open_mfdataset("path/to/files/*.nc", preprocess=fnX, engine="netcdf4")
```


***
### `Hydra` Compatibility

In addition to the toolz


