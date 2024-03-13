---
title: Reanalysis
subject: Available Datasets in Geosciences
short_title: Reanalysis
authors:
  - name: J. Emmanuel Johnson
    affiliations:
      - CSIC
      - UCM
      - IGEO
    orcid: 0000-0002-6739-0053
    email: juanjohn@ucm.es
license: CC-BY-4.0
keywords: reanalysis, era5
---



```{figure} https://www.issibern.ch/teams/dataassimsphere/wp-content/uploads/sites/20/2014/11/anim_assim.gif
:name: da-gif
:width: 600px
:alt: Random image of the beach or ocean!
:align: center

A simple example of data assimilation for an upper atmosphere variable. [[Source](https://www.issibern.ch/teams/dataassimsphere/)]
```




In the above section, we were in the world of simulations which means we were using dynamical models with different forcings.
However, an improvement to this would be to incorporate observations of the actual variables we wish to use.
This process is usually done through the process of **data assimilation** (DA). 
DA is the process of combining observations with physical models.

$$
\boldsymbol{u}_\text{Analysis} = \boldsymbol{T}[\boldsymbol{u}_\text{Dynamical}, \boldsymbol{y}_\text{obs};\boldsymbol{\theta}]
(\mathbf{x},t)
$$

where $\boldsymbol{T_\theta}$ is a parameterized transformation that combines the prior state from the dynamical model, $\boldsymbol{u}_\text{Dynamical}$, and the observations, $\boldsymbol{y}_\text{Obs.}$.


The main reason why DA is necessary is because the observations almost never exactly match the physical variables we are interested in modeling.
For example, they could be sparse/incomplete or they could be completely unobserved.
In addition, they could be noisy due to instrument error.
For example, we may be interested in the ocean state but we only observe a fraction of the oceans surface [[Johnson et al., 2023](https://doi.org/10.48550/arXiv.2309.15599)].
This results in a very high-dimensional system whereby we only have partial observations of a tiny fraction of the system.
So it's absolutely essential to incorporate strong prior information through the form of physical models to try and recover the "true" ocean state.

The **ERA5** is the most comprehensive reanalysis dataset available.
However, it is worth noting that the ocean component of the **ERA5** dataset is really lacklustre compared to the atmospheric and land components.
So there are other more comprehensive reanalysis datasets specifically for the oceanic variables, e.g., [GLORYS](https://www.mercator-ocean.eu/en/ocean-science/glorys/) and [HYCOM](https://www.hycom.org/).

***
## Data Access

### Climate

[**ERA5**](https://cds.climate.copernicus.eu/cdsapp#!/dataset/reanalysis-era5-single-levels?tab=overview).
This is a reanalysis dataset which are climate models which have assimilated observations.

[**NCEP**](https://psl.noaa.gov/data/reanalysis/).
This is a reanalysis dataset from the NOAA/NCAR institutions which for assimilated observations.

***
### Atmosphere

***
### Ocean

[**GLORYS**](https://www.mercator-ocean.eu/en/ocean-science/glorys/).
A **reanalysis** dataset for the **ocean**. It is based on the NEMO model and observations.
It has global coverage with a spatial resolution of `0.083 x 0.083 deg` $\approx$ `9.2 km`. 
It does have some higher resolution subregions like the Med or Arctic with higher spatial resolutions, e.g., `0.043 x 0.043 deg` $\approx$ `4.8 km`.

[**HYCOM**](https://www.hycom.org/).
A **reanalysis** dataset for the **ocean**. It is based on the ... model and observations.
It has global coverage with a spatial resolution of `0.083 x 0.083 deg` $\approx$ `9.2 km`. 

[**ORAS5**](https://www.hycom.org/).
A **reanalysis** dataset for the **ocean**. It is based on the NEMO model and observations. It has global coverage with a spatial resolution of `0.25 x 0.25` $\approx$ `[25,9] km`


