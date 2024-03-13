---
title: Feature Representation
subject: AI 4 Attribution
short_title: Features (Manually)
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
    CDS: Climate Data Store
---


**Things to Consider**:

* Univariate --> Multivariate
* Spatially Independent --> Spatially Dependent
* Temporally Independent --> Temporally Dependent
* Stationary --> Non-Stationary

***
## Spatial Mean

This example was taken from the [xarray documentation](https://docs.xarray.dev/en/latest/examples/area_weighted_temperature.html).


```python
weights: xr.Coordinates = np.cos(np.deg2rad(da.lat))
weights.name = "weights"
```

:::{seealso} Tutorials
:class: dropdown

[**xarray**](https://docs.xarray.dev/en/latest/examples/area_weighted_temperature.html).
An example from `xarray` that showcases the area weighted temperature.

[**xcdata**](https://xcdat.readthedocs.io/en/latest/examples/spatial-average.html).
An example for calculating geospatial weighted averages from monthly time series.
:::


***
## Stationarity in Time Series

See [example](https://www.kaggle.com/code/mozturkmen/stationarity-tests-in-time-series).

## Stationarity in Spatial Data


See [example](https://ai.plainenglish.io/what-is-stationarity-in-spatial-data-f541b04b5811).



***

### Filtering

First, we perform some sort of filtering procedure to remove ... from the spatiotemporal cube. 

$$
\begin{aligned}
\boldsymbol{y}(\mathbf{x},t) = \boldsymbol{F}_\text{Filter}[\boldsymbol{y};\theta](\mathbf{x},t), && &&
\mathbf{x}\in\Omega_\text{Globe}\subseteq\mathbb{R}^{D_s} && &&
t\in\mathcal{T}_\text{Globe}\subseteq\mathbb{R}^+
\end{aligned}
$$

In this case a kernel average of 3-5 days is applied.

**Note**: 

:::{seealso} Help

See [my guide](../cookbook/filtering.md) for more information on filtering.

:::

***

### Anomalies

First, we need to calculate the climatology of our dataset which is the global spatial average over some defined reference period.
The equation for the climatology is given by:


$$
\begin{aligned}
\text{Climatology Equation}: && && \bar{y}_\text{Climatology}(t) &= \frac{1}{N_s}\sum_{n=1}^{Ns}\boldsymbol{y}(\mathbf{x}_n,t) \\
\text{Climatology Function}: && && \bar{y}_\text{Climatology}&: \Omega_\text{Globe}\times\mathcal{T}_\text{Reference} \rightarrow \mathbb{R}^{D_y} \\
\text{Spatial Domain}: && && \mathbf{x}&\in\Omega_\text{Globe}\subseteq\mathbb{R}^{D_s}\\
\text{Temporal Domain}: && && t&\in\mathcal{T}_\text{Reference}\subseteq\mathbb{R}^+
\end{aligned}
$$

The reference period, $\mathcal{T}_\text{Reference}$, is some defined period which captures majority of the trends we can expect to see.
We also want this reference period to have minimal influence of anthropogenic activity.
So, given the defined period of `1850-2023`, we could take the reference period to be `1850-1880` (30 years).

:::{seealso} Climatology

There are many ways to calculate the climatology.
See [my climatology guide](../cookbook/anomalies.md) for examples of how to calculate the climatology.

:::



To calculate the anomalies of the spatiotemporal cube, we subtract the climatology from the field.

$$
\begin{aligned}
\text{Anomaly Equation}: && && \boldsymbol{\bar{y}}_\text{Anomaly}(\mathbf{x},t) &= \boldsymbol{y}(\mathbf{x},t) + \boldsymbol{\bar{y}}_\text{Climatology}(t) \\
\text{Anomaly Function}: && && \boldsymbol{\bar{y}}_\text{Anomaly}&: \Omega_\text{Globe}\times\mathcal{T}_\text{Globe} \rightarrow \mathbb{R}^{D_y} \\
\text{Spatial Domain}: && && \mathbf{x}&\in\Omega_\text{Globe}\subseteq\mathbb{R}^{D_s}\\
\text{Temporal Domain}: && && t&\in\mathcal{T}_\text{Globe}\subseteq\mathbb{R}^+
\end{aligned}
$$

What remains are the anomalies of the spatiotemporal field, $\boldsymbol{y}$.




***

### Data Reduction

Now, we perform a data reduction of the spatiotemporal field. 
In the simplest case, we can take the spatial average of the field at every time step.
This will result in a single time series for the entire data cube.

$$
\begin{aligned}
\text{Reduced Data Equation}: && && \tilde{y}_\text{anomaly}(t) &= \frac{1}{N_s}\sum_{n=1}^{N_s}\boldsymbol{\bar{y}}_{anom}(\mathbf{x},t) \\
\text{Reduced Data Anomaly Function}: && && \tilde{y}_\text{anomaly} &: \mathcal{T}_\text{Globe} \rightarrow \mathbb{R}^{D_y} \\
\text{Temporal Domain}: && && t&\in\mathcal{T}_\text{Globe}\subseteq\mathbb{R}^+
\end{aligned}
$$

:::{seealso} Help

See [my guide](../cookbook/spatial_mean.md) for more information on how we can calculate the spatial mean.

**Note**: there are other ways we can reduce the dimensionality of the data.
For example, we can use Empirical Orthogonal Functions (EOFs) (a.k.a. PCA, POD).

:::