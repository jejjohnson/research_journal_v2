---
title: Preliminary Results
subject: Misc. Notes
short_title: Experiment 1a - Spain (IID)
authors:
  - name: J. Emmanuel Johnson
    affiliations:
      - CSIC
      - UCM
      - IGEO
    orcid: 0000-0002-6739-0053
    email: juanjohn@ucm.es
license: CC-BY-4.0
keywords: data
---


* Duration?
* Mean of Globe -> Correlated with Mean Location of Extremes


# Metrics

## Log-Likelihood

```{list-table} Table with results for each model
:header-rows: 1
:name: tb:madrid_unc_det_model

* - Model
  - NLL
  - Error
* - GEVD
  - -124.7383235
  - 4.06643326
* - GPD (Q95, 3D)
  - -1358.70624244
  - 20.17945954
* - GPD (Q98, 3D)
  - -567.97480681
  - 14.90358918
* - GPD (Q99, 3D)
  - -291.28153454
  - 11.48212622
```

::::{tab-set}

:::{tab-item} GEVD
:::{figure}
:label: madrid-t2m-hist
:align: center



![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=10YYT3BDUdBOfhpyMne7HW2zAEUrhA7vE)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::


:::{tab-item} GPD (Q95, 3D)
:::{figure}
:label: madrid-t2m-hist


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1297t3_nmmBHJ3vGxFhxBzGrlZDnlraID)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} GPD (Q95, 3D)
:::{figure}
:label: madrid-t2m-hist


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1OWjeVsL299MViJkhVEp1uGwPLNzQQSdZ)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} GPD (Q98, 3D)
:::{figure}
:label: madrid-t2m-hist


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1NvJNUzXLosux9YWICHlRSJoHwk5jCZ-o)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} GPD (Q99, 3D)
:::{figure}
:label: madrid-t2m-hist

![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1cjVdSALvhIlEO6CcWGEhkyacwG9ihSfg)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::


::::

***
# Parameters


***
## Location Parameter


For the location parameter, recall the formulation

$$
\boldsymbol{\mu}(\mathbf{s},\boldsymbol{\theta}) =
\mu_0
$$

So for this experiment, each model has a location bias parameter, $\mu_0$.
However, the temporal model includes the location-bias parameter **and** the location-temporal weight parameter, $\mu_1$.
In addition, the spatial model includes all parameters in the above equation.

### Location-Bias

#### Histogram

This is the histogram of **all samples** of the location-bias parameter, $\mu_0$, for each station in Spain.


::::{tab-set}

:::{tab-item} GEVD
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1ETPsyh5_G-Dv3fKTWZz9iKC2ILe2a0_H)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} GPD (Q90, 3D)
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1EH_S-gu3SyECu2vGYcrVnFpiC8Ocj5QF)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} GPD (Q95, 3D)
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1mN5YtPMrSAyaTPbYbog-yPPLStoHw9RF)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} GPD (Q98, 3D)
:::{figure}
:label: madrid-t2m-hist
:align: center

![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1gnPilwodM364wZBhP-05gAEcGbYRFNMF)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} GPD (Q98, 3D)
:::{figure}
:label: madrid-t2m-hist
:align: center

![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1pQoNtQoFuUVm-88tpNUOOEaUHAAltIig)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

::::


#### Mean Histogram

This is the histogram of the **mean** of the location-bias parameter, $\mu_0$, for each station in Spain.

::::{tab-set}

:::{tab-item} GEVD
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1MPCdwBe-M5MvkqxyRI_0r4-cCbePIoRL)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} GPD (Q90, 3D)
:::{figure}
:label: madrid-t2m-hist
:align: center

![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1nogaNLXBqHyAKwOqMqdzREyuqKu5Xv-C)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} GPD (Q95, 3D)
:::{figure}
:label: madrid-t2m-hist
:align: center

![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=12AP4q1yugqwUP4kBLu5fd-JOHlPpUZuz)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} GPD (Q98, 3D)
:::{figure}
:label: madrid-t2m-hist
:align: center

![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1ehmBfckeQC61o8RPFeeQJ4OZT4RMpZ-L)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} GPD (Q98, 3D)
:::{figure}
:label: madrid-t2m-hist
:align: center

![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=100Y6z23wWZ_LtM_znXkvhpK9r3bcNAsf)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::
::::


#### Maps

::::{tab-set}

:::{tab-item} GEVD
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1p4agHYmgP6-yocqc2Zs_Ro9ZGADrnvX_)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::


:::{tab-item} GPD (Q95, 3D)
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1PA-DRwkYNTYTK_lh6szL9S0ZsIWPEMwz)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} GPD (Q95, 3D)
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1KHKXMG0jyK4N3u4KPGfvfifzhU6Vwr-5)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} GPD (Q98, 3D)
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1ejRt_c5cxY9zNMRLCOQ1jdqFFm5OTWaK)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} GPD (Q98, 3D)
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=183kz5sEdZD6sz32N_8yXeTwKNRFBia26)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::
::::

***
## Sigma

$$
\sigma^* = \sigma + \kappa (y_0 - \mu)
$$

This parameter is **only** present for the GPD distribution.

### Histogram

::::{tab-set}

:::{tab-item} GPD (Q95, 3D)
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=12GwqxxHPa5QhjpxX9HqYaS4I9nabl0Sm)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} GPD (Q98, 3D)
:::{figure}
:label: madrid-t2m-hist
:align: center

![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=12u3wv2g-mUYgxsysHr8YjLMuZbIAP0e-)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

::::

### Mean Histogram

::::{tab-set}

:::{tab-item} GPD (Q98,3D)
:::{figure}
:label: madrid-t2m-hist
:align: center

![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=11r5hkDLcCSdnPUjR2_IhtNRA9AZHabNd)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} GPD (Q98, 3D)
:::{figure}
:label: madrid-t2m-hist
:align: center

![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=11uUiWwYkKxflGWjniNwwdzC_WvFzKfSp)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::


::::

### Map

::::{tab-set}

:::{tab-item} GPD (Q95, 3D)
:::{figure}
:label: madrid-t2m-hist
:align: center

![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1tX20cMx8WZ9Up_L5vfRhJh6oFvmbLuzU)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} GPD (Q98, 3D)
:::{figure}
:label: madrid-t2m-hist
:align: center

![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1i4He1NWB6G-memSayQzm4MDsSum94LZe)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::


::::


***
## Scale


Recall, the parameterization for the scale parameter is given by

$$
\sigma(t;\boldsymbol{\theta})
=
\sigma_0
$$

where $\sigma_0$ is the scale parameter per station.
This means that each model will have the same scale parameterization.

### Histogram

::::{tab-set}

:::{tab-item} GEVD
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1ydWZ8t7nwerU1j4HBZVViZ730rjKehRq)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} GPD (Q95, 3D)
:::{figure}
:label: madrid-t2m-hist
:align: center

![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1ioYWsy7XtQAGm1eiKsBvQ5-3Qj39SDZ2)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::


:::{tab-item} GPD (Q98, 3D)
:::{figure}
:label: madrid-t2m-hist
:align: center

![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1K3bXUo2Wg0lr2GmiAOaenLTY4ssDOwdT)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

::::

### Mean Histogram

::::{tab-set}

:::{tab-item} GEVD
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=168lrD9uTqFb3eh2aPnqluUzrZ3nBOoBH)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} GPD (Q95, 3D)
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=16YUL4al0OGsP67JcbmcuU9U4bCWkYmdM)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::


:::{tab-item} GPD (Q98, 3D)
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1TeTvvraTRfkXx4DnkwUGF2nuvv4fW20i)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::


::::

### Map

::::{tab-set}

:::{tab-item} GEVD
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1UMxG73ietUXRG14NkL6ohaKrAI_r0RGN)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} GPD (Q95, 3D)
:::{figure}
:label: madrid-t2m-hist
:align: center

![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=19dEhzt3H0YaYWJ1iCCxe2ZTKTWBdHdxM)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} GPD (Q95, 3D)
:::{figure}
:label: madrid-t2m-hist
:align: center

![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1dC1oICKp3sUdYhSjKQ1Ulh9dJAwDlm-D)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

::::



***
## Concentration

Recall, the parameterization for the shape parameter is given by

$$
\kappa(t;\boldsymbol{\theta})
=
\kappa_0
$$

where $\kappa_0$ is the shape parameter per station.
This means that each model will have the same shape parameterization.

### Histogram

::::{tab-set}

:::{tab-item} GEVD
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1t7uLs5KeHNIPVHNgcANBMBtFTg3h7Iy3)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} GPD (Q95, 3D)
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1q0Rb30AFrgBKxW-R2jUgzM3t3MzuV6hQ)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::


::::

### Mean Histogram

::::{tab-set}

:::{tab-item} GEVD
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1Pg0iC8ojjsDRImoAh2IDh262O7NfS2hQ)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} GPD (Q95, 3D)
:::{figure}
:label: madrid-t2m-hist
:align: center

![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1AXrnE114Q2InY9B9HW5PYl18Zd3WmFT2)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} GPD (Q98, 3D)
:::{figure}
:label: madrid-t2m-hist
:align: center

![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1E2eWlHee0iie1rqh_55jZHWa4p1vQAgf)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::


::::

### Maps

::::{tab-set}

:::{tab-item} GEVD
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1G0vptzngPTjNKhJRFye_ecYK39264IYS)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} GPD (Q95, 3D)
:::{figure}
:label: madrid-t2m-hist
:align: center

![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1L3cLXuoY7eZeyt-AMJuInzJMKdBJCwvq)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::


:::{tab-item} GPD (Q98, 3D)
:::{figure}
:label: madrid-t2m-hist
:align: center

![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1_bv-v6bsbS47yBc2mbI28gJWjw3zIsX1)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

::::







***
## Rate

We can relate the GEVD parameters to the GPD.
This gives us a rate parameter, $\lambda$, which is the expected number of events that exceed some threshold, $y_0$, per year.

$$
\lambda = \sigma + \kappa (y_0 - \mu)
$$

However, we need to define an exceedence threshold, $y_0$.
We will do a simple 95% quantile for each independent station with a declustering of 3 days.
Then we can calculate the rate, $\lambda$.

### Threshold


::::{tab-set}

:::{tab-item} GEVD
:::{figure}
:label: spain-threshold-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1OEYlNJhfFTju0wf0ag2TEp9dp6dHR1ZE)
A histogram of the threshold parameter, $y_0$, for all stations.
:::

::::

## Histogram

::::{tab-set}

:::{tab-item} GEVD
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1waVSFAlIQf14yZ-FigLTlXeRn-YZ-ORz)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::



::::

## Mean Histogram



::::{tab-set}

:::{tab-item} GEVD
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1daA-VZ5eNwLo1MQJUjRdLLtFRTlE-Vyz)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::


::::




## Maps



::::{tab-set}

:::{tab-item} GEVD
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1Ij3ABiioK3MzgiEKGtz6wcAcUgBoAc-t)
The return period for the iid model.
:::


::::





# Returns


## Histogram

::::{tab-set}

:::{tab-item} GEVD
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1qTIOLXTGqVGWAyb06Opg439Wiv_rPQfx)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} GPD (Q90, 3D)
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=18rKFR10FUvy_Q3_O9OxP-KEOYZ_YEmkY)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} GPD (Q95, 3D)
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1sX3nvWjoCPiaRcBXxYZgmuwncU0lNqGo)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} GPD (Q98, 3D)
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1PrE5rNkRG2-zRf4leUqAlYoIpfJGLEAJ)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} GPD (Q99, 3D)
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1X6zz2q3o6mLKEyNZ23Y47GWoLWIihAwE)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

::::

## Mean Histogram

::::{tab-set}

:::{tab-item} GEVD
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1bK_lk9ljehF8A6GIcA_hzXkHX9QaKAZG)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} GPD (Q90, 3D)
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=18saN6lFaOZjI-ZhbCOYU9kxNR7wXi1BQ)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::



:::{tab-item} GPD (Q95, 3D)
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1lk0tQnl1nKVRT-JPAItts6_nHYwrhsBZ)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::


:::{tab-item} GPD (Q98, 3D)
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=11iAtVzrDr9TosgNs6PMImWkpFdeZlnwD)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} GPD (Q99, 3D)
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1bOKXo0aXfIMkUcr_ggdlX4_PHK7JMHvu)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::
::::




## Maps


::::{tab-set}

:::{tab-item} GEVD
:::{figure}
:label: madrid-t2m-hist
:align: center

![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=133GpTW20RDZq05bIsy0Dbn60Cy734KrF)
The return period for the iid model.
:::

:::{tab-item} GPD (Q90, 3D)
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=17qghIoiHcoletwqrfQqXP9kRSJyTDEuz)
The return period for the iid model.
:::

:::{tab-item} GPD (Q95, 3D)
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1rb1VoWEiRc7rJcN9xCJ7M9lVSNdJSMZz)
The return period for the iid model.
:::

:::{tab-item} GPD (Q95, 3D)
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1wv0fT7gGBuHv05eNv8Wl9pKPZQrIgBFK)
The return period for the iid model.
:::

:::{tab-item} GPD (Q99, 3D)
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1Mu7WigHz5Eeqeh68kSn_Y5uz7XFqW8N0)
The return period for the iid model.
:::

::::
