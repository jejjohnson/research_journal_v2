---
title: AI Forecasters
subject: AI 4 Attribution
short_title: AI Forecasters
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

# Literature Review


## Background



```{figure} https://climateset.github.io/AIWeatherClimateFigure.png
:name: myFigure
:width: 490px
:alt: Random image of the beach or ocean!
:align: center

Overview of Different Platforms [[Source](https://climateset.github.io/)]
```

**Focus**. 
Some things I'll focus on are the following engineering details:
* Dataset(s) Used
* Main Model Architecture
* Training Time + Resources

***

## Weather

> Below is a shortlist of different benchmark platforms and SOTA algorithms that are available within the literature.
> Many of the listings here are available within the [ECMWF platform](https://charts.ecmwf.int/catalogue/packages/ai_models/).

***

### Typical Variables

The typical variables that each model will predict include:

* Wind
* Mean Sea Level Pressure
* Temperature
* Geopotential
* Precipitation

Many are at (near) sea level whilst others are at each pressure level, e.g., `50, 100, 150`, etc

***

### Benchmark Platforms

#### [WeatherBench 2 ](https://sites.research.google/weatherbench/)

The WeatherBench 2 platform [[Rasp et al, 2023](https://doi.org/10.48550/arXiv.2308.15560)] demonstrates some datasets and metrics.
This is an upgrade from original WeatherBench platform [[Rasp et al, 2020](https://doi.org/10.1029/2020MS002203)].
It uses the same variables available for the ERA5 Dataset.



```{figure} https://production-media.paperswithcode.com/datasets/01ce33a2-4b0e-41d6-b04c-dfbf0d7d2d4d.png
:name: myFigure
:width: 490px
:alt: Random image of the beach or ocean!
:align: center

Picture of WeatherBench2 Logo. [[Source]()]
```

***

### SOTA Methods

> Below are a list of state of the art methods that are available in the literature.

#### [**GraphCast**](https://deepmind.google/discover/blog/graphcast-ai-model-for-faster-and-more-accurate-global-weather-forecasting/)

The graphcast paper [Lam et al, 2023](doi:10.1126/science.adi2336) uses a GNN to learn a mapping from time $t$ to time, $t+\Delta t$ where $\Delta t$ is 6 hours. 

```{figure} https://cdn.arstechnica.net/wp-content/uploads/2023/11/graphcast_illustration.jpg
:name: myFigure
:width: 490px
:alt: Random image of the beach or ocean!
:align: center

A picture of the GraphCast model

```

:::{note} Variables
:class: dropdown

| Variable | Description | ECMWF ID |
|:---------|:------------|:--------:|
| 10u | 10 m zonal wind | 165|
| 10v | 10 m meridional wind | 166 |
| 2T | 2 m temperature | 167
| sp | surface pression | 135 |
| msl | mean sea level pressure | 151 |
| tp | total precipitation | ... |
| tcwv | total column vertically-integrated water vapour | 137 |
| 100u | 100 m zonal wind | 228,248 |
| 100v | 100 m meridional wind component | 228,247 |
| z--- | geoponential (at pressure level ---) | 129 |
| T--- | temperature (at pressure level ---) | 130 |
| U--- | zonal wind (at pressure level ---) | 131 |
| V--- | meridional wind (at pressure level ---) | 132 |
| VZ--- | Vertical wind speed | |
| R--- | specific humidity (at pressure level ---) | 157 |

Pressure Levels: `1,2,3,5,7,10,20,30,50,70,100,125,150,175,200,225,250,300,350,400,450,500,550,600,650,700,750,775,800,825,850,875,900,925,950,975,100` hPa

For a more pragmatic view of the variables, we have:

* Grid: `0.25 x 0.25`
* Area: `-90:90`, `0:359.75`
* Pressure Levels: `50, 100, 150, 200, 250, 300, 400, 500, 600, 700, 850, 925, 1000`
* Parameters @ Pressure Levels: `t, z, u, v, z, w, q`
* Parameters @ Single Levels: `lsm, 2t, msl, 10u, 10v, tp, z`


:::


:::{warning} Warning: Weights
:class: dropdown
The weights are available but be careful with the licensing. See [Code](https://github.com/google-deepmind/graphcast?tab=readme-ov-file).

:::

---

#### [**FourCastNet**](https://docs.nvidia.com/deeplearning/modulus/modulus-sym/user_guide/neural_operators/fourcastnet.html)

The FourCastNet [[Pathak et al, 2022](https://doi.org/10.48550/arXiv.2202.11214)] is NVidia's contribute to the landscape.
An example using their [Nvidia Modulus](https://docs.nvidia.com/modulus/index.html) package can be found [here](https://docs.nvidia.com/deeplearning/modulus/modulus-sym/user_guide/neural_operators/fourcastnet.html).
There have been many iterations of **FourCastNet** including using transformers and UNet-like architectures. 
However, the most recent edition [[]()]using Spherical Harmonics to encode the spatial features




```{figure} https://imageio.forbes.com/specials-images/imageserve/624a2218c3ca2edec266a522/FourCastNet-is-a-weather-digital-twin-that-feeds-on-ground-truth-data-to-predict/960x0.jpg?height=399&width=711&fit=bounds
:name: myFigure
:width: 490px
:alt: Random image of the beach or ocean!
:align: center

Picture of FourCastNet. [[Source](https://www.forbes.com/sites/karlfreund/2022/04/03/nvidia-earth-2-leveraging-the-omniverse-to-help-understand-climate-change/)]
```

:::{note} Variables
:class: dropdown

They use a subset of the 26/73 variables used within the ERA5 Dataset.

| Variable | Description | ECMWF ID | CMIP6 |
|:---------|:------------|:--------:|:------:|
| 10u | 10 m zonal wind | 165| uas |
| 10v | 10 m meridional wind | 166 | vas |
| 2T | 2 m temperature | 167 | tas |
| sp | surface pression | 135 | ps |
| msl | mean sea level pressure | 151 | psl |
| tcwv | total column vertically-integrated water vapour | 137 | prw |
| 100u | 100 m zonal wind | 228,248 | ua100m |
| 100v | 100 m meridional wind component | 228,247 | va100m |
| z--- | geoponential (at pressure level ---) | 129 | zg |
| T--- | temperature (at pressure level ---) | 130 | ta |
| U--- | zonal wind (at pressure level ---) | 131 | ua |
| V--- | meridional wind (at pressure level ---) | 132 | va |
| R--- | relative humidity (at pressure level ---) | 157 | hur |

Pressure Levels: `50, 100, 150, 200, 250, 300, 400, 500, 600, 700, 850, 925, 1000` hPa

For a more pragmatic view of the variables, we have:

* Grid: `0.25 x 0.25`
* Area: `-90:90`, `0:359.75`
* Pressure Levels: `1000, 925, 850, 700, 600, 500, 400, 300, 250, 200, 150, 100, 50`
* Parameters @ Pressure Levels: `t, u, v, z, r`
* Parameters @ Single Levels: `10u, 10v, 2t, sp, msl, tcwv, 100u, 100v`

:::



---

#### [Pangu-Weather]()

Pangu-Weather [Bi et al, 2023](https://doi.org/10.1038/s41586-023-06185-3) is Hwawei's contribution to the SOTA landscape.
They use the Transformer architecture.

```{figure} https://media.springernature.com/lw685/springer-static/image/art%3A10.1038%2Fs41586-023-06185-3/MediaObjects/41586_2023_6185_Fig1_HTML.png?as=webp
:name: myFigure
:width: 490px
:alt: Random image of the beach or ocean!
:align: center

Figure of the Pangu-Framework
```


:::{note} Variables
:class: dropdown

For a more pragmatic view of the variables, we have:

* Grid: `0.25 x 0.25`
* Area: `-90:90`, `0:359.75`
* Pressure Levels: `1000, 925, 850, 700, 600, 500, 400, 300, 250, 200, 150, 100, 50`
* Parameters @ Pressure Levels: `z, q, t, u, v`
* Parameters @ Single Levels: `msl, 10u, 10v, 2t`


:::

***

#### [Stormer](https://tung-nd.github.io/stormer/)

The *Stormer* [[Nguyen, et al, 2023](https://doi.org/10.48550/arXiv.2312.03876)] is a new addition for SOTA.
They use a Transformer architecture (similar to Pangu-Weather and FuXi) but their addition is using variable prediction times.



```{figure} https://tung-nd.github.io/stormer/resources/approach.png
:name: myFigure
:width: 490px
:alt: Random image of the beach or ocean!
:align: center

Figure for Stormer Addition.
```




## Climate

Below are a list of benchmark datasets **and** SOTA algorithms which might be useful for training ML Models.

### Benchmark Datasets

#### [**ClimateBench**]()

ClimateBench [[Watson-Parris, et al, 2022](https://doi.org/10.1029/2021MS002954)] is the first iteration of the official Benchmark platforms for machine learning.


***

#### [**ClimateSet**](https://climateset.github.io/)

The *ClimateSet* [[Kaltenborn, et. al., 2023](https://doi.org/10.48550/arXiv.2311.03721)] platform offers uses access to some climate datasets


```{figure} https://climateset.github.io/climate_set_overview.png
:name: myFigure
:width: 490px
:alt: Random image of the beach or ocean!
:align: center

Figure of the ClimateSet Framework - [[Source](https://climateset.github.io/)]
```

***

#### [**ClimateSim**](https://leap-stc.github.io/ClimSim/README.html)

The *ClimateSim* platform [[Yu, et. al., 2023](https://doi.org/10.48550/arXiv.2306.08754)] offers uses access to some climate datasets.


```{figure} https://leap-stc.github.io/ClimSim/_images/fig_1.png
:name: myFigure
:width: 490px
:alt: Random image of the beach or ocean!
:align: center

Figure of the ClimSim Framework - [[Source](https://leap-stc.github.io/ClimSim/README.html)]
```


***

### SOTA Algorithms

#### [**ClimaX**](https://microsoft.github.io/ClimaX/)



```{figure} https://microsoft.github.io/ClimaX/assets/images/climax-coverfigure.png
:name: myFigure
:width: 490px
:alt: Random image of the beach or ocean!
:align: center

Figure of the ClimaX Framework - [[Source](https://microsoft.github.io/ClimaX/)]
```

**Note**: I think this is the most relevant to many people who wish to do transfer learning from weather to climate (and vice-versa).

**Note 2**: They use a nice CMIP6 dataset which has the exact variables from the ERA5 dataset.

---






<!-- 
## Ocean

### Datasets

#### Simulations

[**CMIP6**](https://cds.climate.copernicus.eu/cdsapp#!/dataset/projections-cmip6?tab=overview). 
We have the following variables. 

* Period - Monthly, Daily, 
* Experiments - 
* Date Range
    * Historical: `1850 - 2014`
    * SSP: `2015 - 2100`


| Variable | Units |
|:---------|:-----:|
| Sea surface height above geoid | m |
|Sea surface salinity | PSU |
| Sea surface temperature | K |
| Sea level pressure | Pa |


#### 

 -->
