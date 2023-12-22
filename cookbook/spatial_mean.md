---
title: Spatial Averaging
subject: Averaging Spatial Data
short_title: Spatial Averaging
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

