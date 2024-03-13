---
title: Geo0Operations
subject: Machine Learning for Earth Observations
short_title: Introduction
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


**Core Operations**
* Input
* Split
* Apply
* Combine

```{figure} https://comptools.climatematch.io/_images/t5_split_apply_combine.png
:name: earth-sys-decomp
:width: 490px
:alt: Random image of the beach or ocean!
:align: center

Example of a decomposition of the Earth system based on a domain. [[Source](https://www.energy.gov/science/doe-explainsearth-system-and-climate-models)]
```


***

* Functions - Unary Binary, etc
* Grouped Computations
* Windowed Computations


***

## **High-Level Operations**


**Window Operations**
* Coarsen - block windows of fixed length
* Rolling - Sliding windows of fixed length

**Group Operations**
* GroupBy
* Resample

Agnostic Operations
* Apply uFunc 

**Recipes**
* Interpolation
* Climatology
* Anomalies
* Regridding
* Fill-NANs
* Calculating Exceedences
* Discretization 


***
## Detailed Operations


***

### **Resampling**

> This will be useful for selecting the min/max values of a time series possibly over a given threshold.

* [xarray - StackOverFlow](https://stackoverflow.com/questions/54431557/xarray-use-groupby-to-group-by-every-day-over-a-years-climatological-hourly-n)
* [xarray-docs](https://docs.xarray.dev/en/stable/user-guide/time-series.html#)
* xcdat time averages - [Notebook](https://xcdat.readthedocs.io/en/latest/examples/temporal-average.html)


***

### **Coarsen**

> This will be useful for selecting the min/max values of a spatial field possibly over a given threshold.

* [xarray-docs](https://docs.xarray.dev/en/stable/user-guide/computation.html#coarsen-large-arrays)
* xcdat for geospatial weighted averaging - [Notebook](https://xcdat.readthedocs.io/en/latest/examples/spatial-average.html)
* climatology with coarsen - [Notebook](https://climate-cms.org/posts/2021-07-29-coarsen_climatology.html)

***

### **Rolling**

> This is useful for capturing events with memory.

* Calculating heatwaves with rolling - [gist](https://gist.github.com/ScottWales/dd9358bea2547c99e46b197bc9f53d21)


***

### **Counting Exceedences**

> This will be a string of operations but we essentially want a workflow to count the number of occurrences given a specific threshold.

* count occurrences over threshold - [xarray-stackoverflow](https://stackoverflow.com/questions/62698837/calculating-percentile-for-each-gridpoint-in-xarray)
* climate event detection - [Notebook](https://climate-cms.org/posts/2020-09-28-eventdetection.html)


***

### **Regions**

* regions and zonal statistics - [Notebook](https://climate-cms.org/posts/2023-07-05-select-region-shapefile.html)

***

### **Climatology**


***

### **Anomalies**




***

### **Interpolation**

