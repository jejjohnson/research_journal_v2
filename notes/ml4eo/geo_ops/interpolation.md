---
title: Anomalies in EO
subject: Anomalies with Spatiotemporal Data
short_title: Interpolation
authors:
  - name: J. Emmanuel Johnson
    affiliations:
      - CSIC
      - UCM
      - IGEO
    orcid: 0000-0002-6739-0053
    email: juanjohn@ucm.es
license: CC-BY-4.0
keywords: simulations
---




> Synonyms - Regrid, Resample, Reproject

In general, we often need to interpolate data because of various reasons. For example, we may have some messy *unstructured* data structure which are basically point clouds with arbitrary and we want to move them to a *structured* data structure.

**Resampling** - Moving data to a higher or lower resolution

**Regridding** - Moving data from one grid resolution/composition to different one


**Guides**

* [Introduction to Interpolation](https://www.neonscience.org/resources/learning-hub/tutorials/spatial-interpolation-basics)
* [NCAR Regridding Guide](https://climatedataguide.ucar.edu/climate-tools/regridding-overview)

**Packages**


* xcdat for horizontal regridding - [Notebook](https://xcdat.readthedocs.io/en/latest/examples/regridding-horizontal.html)
* xcdat for vertical regridding - [Notebook](https://xcdat.readthedocs.io/en/latest/examples/regridding-vertical.html)
* Comparison of Interpolation Methods - xarray, pyinterp, xegrid, scipy - [Notebook](https://github.com/GeospatialGeeks/Py4Geo/blob/master/Regridding%20and%20Spatial%20Interpolation%20in%20Python.ipynb)
* Simple example with rioxarray & `xarray` - [blog](https://www.theurbanist.com.au/2022/02/updated-how-to-create-an-xarray-dataset-from-scratch-reproject-and-save/)
* Example with GOES and rioxarray - [stackoverflow](https://gis.stackexchange.com/questions/349886/using-rioxarray-qgis-projection)
* Pyresample Tutorial - [ipynb](https://github.com/pytroll/tutorial-satpy-half-day/blob/main/notebooks/04_resampling.ipynb)
* Example with `GOES,pyproj,pyresample,cartopy` - [ipynb](https://github.com/joaohenry23/GOES/blob/master/examples/v3.2/G16_IR__SRCYL_plot.ipynb)
