---
title: Filtering EO Data
subject: Filtering Spatiotemporal Data
short_title: Filtering EO Data
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

> This is my quick start guide to filtering Earth Observation data.
> Filtering is a very useful tool.
> It can be used for smoothing which can remove high-frequency or low frequency signals.
> It can also be used to calculate min-max-mean values of a window of data.
> The unique thing about EO data is that we have spatiotemporal data.
> So this implies that we will have to often decide whether we want to apply the filter operation along the spatial axis and/or the temporal axis.

## Formulation

Most filtering operations are special cases of convolutions.

$$
\begin{aligned}
\text{Convolution Operator}: && && \boldsymbol{\bar{y}}{(\mathbf{x})} &= (\boldsymbol{f} \circledast \boldsymbol{y})(\mathbf{x}) \\
\text{Continuous Convolution}: && && &= \int_{-\infty}^\infty 
\boldsymbol{y}(\tau)\boldsymbol{f}(\mathbf{x}-\tau)d\tau \\
\text{Discrete Convolution}: && && &= \sum_{m=-\infty}^\infty 
\boldsymbol{y}(m)\boldsymbol{f}(n-m)
\end{aligned}
$$


Essentially, this is:

1. an element-wise multiplication of data points with filter coefficients.
2. Performing a mathematical operation on the weighted points within a window.

This is equivalent to the dot product of two vectors, where one vector is the data points within a window and the other vector is the filter coefficients.

***

## From Scratch


We can write some basic pseudo-code for filtering.
We can use some basic filtering

```python
# define kernel operator
kernel_size = (5,)
stride = (1,)
@kex.kmap(kernel_size=kernel_size, stride=stride)
def filter_all(u: Float[Array, "... Nt"]):
    return jnp.average(u)
```


We can use some more advanced filtering methods.

***

## `xarray`

We can use `xarray` to compute the rolling mean

See [docs](https://docs.xarray.dev/en/stable/generated/xarray.DataArray.rolling.html) for more detailed examples.

```python
# initialize data
data: Float[Array, "Nt"] = np.linspace(0, 11, num=12)
coords: pd.DateRange = pd.date_range("1999-12-15", periods=12, freq=pd.DateOffset(months=1))

# create an xarray dataarray
da: xr.DataArray = xr.DataArray(data, coords, dims="time")

# compute rolling mean over 5 day window
time_window: int = 5 # 5 Days
da: xr.DataArray = da.rolling(time=5, center=True).mean()

# (Optional) Remove NANS from end-points
da: xr.DataArray = da.dropna("time")
```

***

## `gcm_filter`

There is another package called [gcm-filters](https://gcm-filters.readthedocs.io/en/latest/index.html) which is a convenient wrap-around the `xarray.Dataset`.
They feature many more advanced filters which take into account things like masks and curvilinear grids.