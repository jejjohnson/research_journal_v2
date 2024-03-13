---
title: Simulations
subject: Available Datasets in Geosciences
short_title: Simulations
authors:
  - name: J. Emmanuel Johnson
    affiliations:
      - CSIC
      - UCM
      - IGEO
    orcid: 0000-0002-6739-0053
    email: juanjohn@ucm.es
license: CC-BY-4.0
keywords: simulations, cmip6, cmip5, cmip
---


> This is a summary of different datasets available from the geoscience community. I want to understand some key differences in how they are constructed as well as some key similarities that can be exploited for other tasks.


***

## TLDR

There are essentially 2 types of datasets that are available within the community: **simulations** and **reanalysis**.


**Simulations**.
These are solutions to dynamical models under different forcing conditions.
There are a large number of simulations that exist from different institutions under different assumptions and different numerical implementations.
In addition, some include multiple runs.
The CMIP-X project is a large collection of simulations from different institutions.

**Reanalysis**.
These are simulations that are *assimilated* with real observations. 
The ECMWF Reanalysis Version 5 (ERA5) is a large collection of reanalysis data available.

***
## Simulations

> In this section, we will primarily talk about the CMIP6 project and the simulations available therein.

For notation, we are considering a vector-valued field, $\boldsymbol{u}$, as a vector-valued field that varies in a spatial domain, $\Omega$ and a time domain, $[t_0, t_1]$.

$$
\begin{aligned}
\boldsymbol{u} &= \boldsymbol{u}(\mathbf{x},t) && && && 
\mathbf{x}\in\mathcal{\Omega}_u\subseteq\mathbb{R}^{D_s} &&
t\in[t_0, t_1]\subseteq\mathbb{R}^+
\end{aligned}
$$


In the case of climate simulations, these variables can be considered any number of physical quantities on the land, atmosphere and ocean surface. 
For example, the temperature, wind, and precipitation.
The CMIP6 simulations are particularly impressive because attempt to encapsulate almost all variables that are important for modeling the full climate system on Earth. 
For a full list of variables, see the CMIP6 simulations located at the [climate data store](https://cds.climate.copernicus.eu/cdsapp#!/dataset/projections-cmip6?tab=overview).

Recall, that every PDE can be written in a form of the partial derivative of a field in time, $\partial_t\boldsymbol{u}$, that's equivalent to some parameterized spatial operators, $\boldsymbol{F_\theta}$.

$$
\partial_t \boldsymbol{u}(\mathbf{x},t) = 
\boldsymbol{F}[\boldsymbol{u};\boldsymbol{\theta}](\mathbf{x}, t)
$$

$\boldsymbol{F}$ is set of all operators that act on a field $\boldsymbol{u}$ and $\boldsymbol{\theta}$ represents all parameters that stem from this PDE. 
This is the set of all operators, i.e., $\boldsymbol{F}\in\mathcal{F}$, which could be simple linear differentiable operators like the gradient, $\boldsymbol{\nabla}$, or the Laplacian, $\boldsymbol{\nabla}^2$, or non-linear operators like the advection term in the material derivative, $\boldsymbol{u}\cdot\boldsymbol{\nabla}q$. 

Regardless of the operation, these are meant to encapsulate all physical processes that we wish to include within our dynamical system.
In addition, there could be other operators like parameterizations, i.e., simplified equations that represent a dynamical system.
It represents a model of the effect of a process instead of a dynamical system resolving the process directly.
Parameterizations are included for a variety of reasons including increasing the speed of the simulation or making hard assumptions about the contribution of certain factors.
We could also include forcing functions which attempt to incorporate external (or internal) operations on the system.
Lastly, there could be stochasticity in the system which could be from unresolved processes or inherent variability within the system.

In the case of the CMIP6 simulations, there are many variations of these operators ranging from different dynamical models to different forcings. 
The remaining sections will outline some key differences to distinguishing the many available simulations for the CMIP6 project.
Essentially, we will decompose the operator, $\boldsymbol{F}$, into core components that highlight the key differences across different the simulations.

***

### Dynamical Components

```{figure} https://www.energy.gov/sites/default/files/styles/full_article_width/public/2021-08/gpawg-climate-earth-systems-models.png?itok=dgA97vSK
:name: earth-sys-decomp
:width: 490px
:alt: Random image of the beach or ocean!
:align: center

Example of a decomposition of the Earth system based on a domain. [[Source](https://www.energy.gov/science/doe-explainsearth-system-and-climate-models)]
```

The first way to decompose the operator is into the core dynamical system that represents processes within the Earth system.

$$
\boldsymbol{F} = \boldsymbol{F}_\text{Dynamical}
$$

While it is ideal to have all dynamical processes under a single umbrella, it's more feasible to decompose each into subcomponents.
We can do this by decomposing the Earth domain into different sections.
There are potentially many ways one can partition the Earth into sections as we can be as granular as possible when describing a dynamical system.
However, the Earth is a massive scale and we need to put a limit due to computational constraints. 

There are 3 key partitions that are prevalent in the CMIP6 simulations include the atmosphere, the land, and the ocean.

$$
\boldsymbol{F}_\text{Dynamical} = 
\text{Atmospheric} + \text{Land} + \text{Ocean} 
$$

On a high-level, this is a reasonable decomposition.
However, depending on your field and beliefs, one could easily decompose this field into other specific dynamical systems that are potentially influential.
For example, we could include a vegetation dynamical system and a (sea) ice dynamical system.

In the case of the CMIP6 project, the AMIP6 models only include the atmospheric portion and parameterize the ocean and land (?).
However, all other scenarios include each of these dynamical systems within their framework.

***

### Forcings

```{figure} https://skepticalscience.com/pics/meehle_2004.jpg
:name: natural-vs-anthro
:width: 490px
:alt: Random image of the beach or ocean!
:align: center

A figure from [[Meehl et. al., 2004](https://doi.org/10.1175/1520-0442(2004)017<3721:CONAAF>2.0.CO;2)] showing the anthropogenic plus natural vs. just natural radiative forcing temperature change vs. observed global surface temperature increase. [[Source](https://skepticalscience.com/print.php?n=348)]
```




We can add another term to our PDE which takes into account any external *natural* forcings that we think are necessary.

$$
\boldsymbol{F} = \boldsymbol{F}_\text{Dynamical} + \boldsymbol{F}_\text{Forcings}
$$

A forcing is essentially an external (or internal) factor that is independent of our defined dynamical system. 
For example, the wind is a factor of the atmosphere which influences the dynamical system of the ocean system and vice versa.

For the CMIP6 project, we consider 2 broad categories of forcings: *natural* and *anthropogenic*.

$$
\boldsymbol{F}_\text{Forcings} = \text{Natural} + \text{Anthropogenic}
$$

*Natural* is anything that we consider is a natural process, e.g., solar radiation, albedo, Milankovitch cycles, natural oscillations, sun spots, and volcanoes.
*Anthropogenic* is anything that we consider is a process or effect that was caused by humans, e.g., greenhouse gases.


One important factor is that forcings come from observations, $\boldsymbol{y}_{obs}$, when they are available.

$$
\begin{aligned}
\boldsymbol{F}_\text{Forcings} &:=
\boldsymbol{F}_\text{Forcings}[\boldsymbol{y}_{obs};\boldsymbol{\theta}](\mathbf{x},t) && &&
t\in[1850,2014]\subseteq\mathbb{R}^+ \\
\boldsymbol{F}_\text{Forcings}  &:= 0 && &&
t\in[2015,2100]\subseteq\mathbb{R}^+ 
\end{aligned}
$$

The first row showcases the simulations in the *historical* period $t\in[1850,2014]$ where observations are available so these are included within the forcing terms.
However, the second row showcases the simulations in the *projection* period $t\in[2015,2100]$ where observations are not available.
So the forcing terms are 0.

In the context of the CMIP6 project, they have different forcings available:

* **piControl** run will include **none** of the forcings (neither anthropogenic nor natural).
* **Historcal-Natural** will **only** include the natural forcing.
* **Historical** will include **both** the anthropogenic forcing and the natural forcing.

**Note**: A key component to note is that these are forcings using observations, and **not** assimilation.


***

### Summary

We can summarize a number of the different simulations that are available from the CDS.

$$
\begin{aligned}
\boldsymbol{F} &= \underbrace{\text{Atmospheric} + \text{Land} + \text{Ocean}}_{\text{Dynamical}} + 
\underbrace{\text{Natural} + \text{Anthropogenic}}_{\text{Forcing}} 
\end{aligned}
$$

Below, we have a summary table of the different CMIPX simulations that are available and what distinguishes them.

```{list-table} Table of Different CMIP6
:header-rows: 1
:name: cmip6-table

* - Simulation
  - Dynamical
  - Observation Forcing
  - Anthropogenic Forcing
* - piControl
  - Atm, Land, Ocn
  - No
  - No
* - Historical-Natural
  - Atm, Land, Ocn
  - Yes
  - No
* - Historical
  - Atm, Land, Ocn
  - Yes
  - Yes
* - GHG
  - Atm, Land, Ocn
  - Yes
  - Yes
* - [AMIP5](https://cds.climate.copernicus.eu/cdsapp#!/dataset/projections-cmip5-daily-pressure-levels?tab=overview)
  - Atm, Land
  - Yes
  - Yes
```


***
### Misc.

There are other important factors to consider when looking at the models.

***

#### Ensembles

Many institutions offer a number of different runs, i.e., *ensembles*. 

***

#### Scenarios

The strength of the forcing is the focus for the projections. 
We don't have observations of the anthropogenic activity, so we need to prescribe this forcing.
In general, there are a number of Shared Socioeconomic Pathways (SSP), a.k.a., *scenarios* provided ranging from optimistic to pessimistic.


:::{note} SSP Scenarios Summary
:class: dropdown

```{list-table} Table of Different Scenarios
:header-rows: 1
:name: scenarios-table

* - Scenario Acronym
  - Label
* - SSP1
  - Sustainability
* - Historical-Natural
  - Atm, Land, Ocn
* - SSP2
  - Middle of Road
* - SSP3
  - Regional Rivalry
* - SSP4
  - Inequality
* - SSP5
  - Fossil-Fueled Development
```


:::




```{figure} https://oceanhealthindex.org/images/cmip6/surface_air_temp.jpg
:name: ssp-scenarios
:width: 490px
:alt: Random image of the beach or ocean!
:align: center

Example of projections with different scenarios for surface air temperature [[Source](https://oceanhealthindex.org/news/cmip_1_what_is_this/)]
```


***

#### Pressure Levels

In the database, there is an option to choose the CMIP6 simulations at [pressure levels](https://cds.climate.copernicus.eu/cdsapp#!/dataset/projections-cmip5-daily-pressure-levels?tab=overview) or at [single levels](https://cds.climate.copernicus.eu/cdsapp#!/dataset/projections-cmip5-daily-single-levels?tab=overview).



---
## List of Datasets

> Below is a large list of my datasets.

A quick list of current reanalysis, see [this link](). 
They have a comprehensive list of reanalysis available for the [atmosphere](https://reanalyses.org/atmosphere/overview-current-atmospheric-reanalyses) and the [ocean](https://reanalyses.org/ocean/overview-current-reanalyses).

***

### Climate

[**CMIP5**](https://cds.climate.copernicus.eu/cdsapp#!/dataset/projections-cmip5-daily-single-levels?tab=overview) | [**CMIP6**](https://cds.climate.copernicus.eu/cdsapp#!/dataset/projections-cmip6?tab=overview).
Some climate projections for the **land**, **atmosphere**, and **ocean**.
They feature a **historical** period from 1850-2014 and a **projection** period from 2015-2100.
The anthropogenic forcing was dictated using different SSP scenarios.

***

### Atmosphere

***


### Ocean

