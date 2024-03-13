---
title: Anomalies in EO
subject: Anomalies with Spatiotemporal Data
short_title: EO Data Anomalies
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




## Anomalies

**Definition**: the anomaly of a variable is the variation in the signal relative to the climatological signal.


There is an error in this formulation because you cannot subtract the climatology from the global time series because they are on different temporal domains.

$$
\begin{aligned}
\text{Climatology}: && && 
\boldsymbol{\bar{y}} &=  \boldsymbol{\bar{y}}_c(t) && && t\in\mathcal{T}_\text{Reference}\subseteq\mathbb{R}^+ \\
\text{Data}: && &&
\boldsymbol{y} &= \boldsymbol{y}(\mathbf{x},t)
&& && t\in\mathcal{T}_\text{Globe}\subseteq\mathbb{R}^+ && && 
\mathbf{x}\in\Omega\subseteq\mathbb{R}^{D_s}
\end{aligned}
$$

From a code perspective, this can be stated where the global data is

```python
# global data
data_globe: Array["Nx Ny Nt"] = ...
# climatology reference period
data_climatology: Array["Nc"] = ...
# IMPOSSIBLE to subtract one timeseries from another (even with broadcasting)
data_anomaly: Array["Nx Ny Nt"] = data_globe - data_climatology

```

**TODO**: Need to figure out how this works.


**PsuedoCode**

https://xcdat.readthedocs.io/en/latest/examples/climatology-and-departures.html

### Example 1: Monthly Mean

This example was taken from the [xarray documentation](https://docs.xarray.dev/en/latest/examples/weather-data.html#Calculate-monthly-anomalies).

```python
# calculate monthly mean
climatology: xr.Dataset = ds.groupby("time.month").mean("time")

# calculate anomalies
anomalies: xr.Dataset = ds.groupby("time.month") - climatology
```

***

### Example 2: Monthly Standardization

We can also calculate the standardized monthly means.
This implies calculating the monthly mean and standard deviation.


```python
# calculate monthly mean
climatology_mean: xr.Dataset = ds.groupby("time.month").mean("time")
climatology_std: xr.Dataset = ds.groupby("time.month").std("time")

# create standardization function
std_fn = lambda x, mean, std: (x - mean) / std

# calculate anomalies
anomalies: xr.Dataset = xr.apply_ufunc(
    std_fn,
    ds.groupby("time.month"),
    climatology_mean,
    climatology_std
)
```

***

### Example 3: Seasonal


***
## Resources

* Calculating Anomalies with Climatology and Weighted Means - [Notebook](https://comptools.climatematch.io/tutorials/W1D1_ClimateSystemOverview/student/W1D1_Tutorial6.html)
* xcdat for anomalies - [Notebook](https://xcdat.readthedocs.io/en/latest/examples/climatology-and-departures.html)
* Extended Tutorial - [CDS Website](https://ecmwf-projects.github.io/copernicus-training-c3s/reanalysis-climatology.html)
* Calculating Climatology & Anomalies with Dask - [Gist](https://gist.github.com/rabernat/30e7b747f0e3583b5b776e4093266114)
* Rainfall Anomalies and Climatology with Dask - [Notebook](https://docs.digitalearthafrica.org/sandbox/notebooks/Real_world_examples/Rainfall_anomaly_CHIRPS.html)