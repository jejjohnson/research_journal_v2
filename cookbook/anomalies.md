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
abbreviations:
    ERA5: ECMWF Reanalysis Version 5
    CMIP6: Coupled Model Intercomparison Project Phase 6
    AMIP6: Atmospherical Model Intercomparison Project Phase 6
    PDEs: Partial Differential Equations
    RHS: Right Hand Side
    TLDR: Too Long Did Not Read
    SSP: Shared Socioeconomic Pathways
    GPD: Generalized Pareto Distribution
    GEV: Generalized Extreme Value
---


## Climatology

$$
\begin{aligned}
\text{Climatology Equation}: && && \bar{y}_c(t) &= \frac{1}{N_s}\sum_{n=1}^{Ns}\boldsymbol{y}(\mathbf{x}_n,t) \\
\text{Climatology Function}: && && \bar{y}_c&: \Omega_\text{Globe}\times\mathcal{T}_\text{Reference} \rightarrow \mathbb{R}^{D_y} \\
\text{Spatial Domain}: && && \mathbf{x}&\in\Omega_\text{Globe}\subseteq\mathbb{R}^{D_s}\\
\text{Temporal Domain}: && && t&\in\mathcal{T}_\text{Reference}\subseteq\mathbb{R}^+
\end{aligned}
$$

:::{seealso} Tutorials
:class: dropdown

[**ClimateMatch**](https://comptools.climatematch.io/tutorials/W1D1_ClimateSystemOverview/student/W1D1_Tutorial5.html).
An simple tutorial showcasing how the `groupby` function works wrt monthly/seasonal means.

[**Xarray**](https://docs.xarray.dev/en/stable/examples/monthly-means.html).
A tutorial that showcases how to calculate seasonal averages from time series of monthly means.

:::

## Anomalies


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