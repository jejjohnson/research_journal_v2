---
title: Preliminary Results
subject: Misc. Notes
short_title: Experiment 1a - Spain
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
* - IID Model
  - -17089.15032017
  - 4.06643326
* - Temporal Model
  - -15571.70729426
  - 4.73258625
* - Spatiotemporal Model
  - -15198.35183499
  - 59.1095967
```

::::{tab-set}

:::{tab-item} IID
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1ZYdGRfbmqLYnZl0lLtW-ZK75_DZ8shuN)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} Time
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1-hemd578kUpwqLVeoguWH_ymrNoXbIpD)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} Space-Time
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1aY09hV62qzl4eBrGvrw0I9criNYGSE_2)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

::::

***
# Parameters


***
## Location Parameter


For the location parameter, recall the formulation

$$
\boldsymbol{\mu}(t,\mathbf{s},\boldsymbol{\theta}) =
\mu_0 +
\mu_1t +
\mu_2(\mathbf{s})
$$

So for this experiment, each model has a location bias parameter, $\mu_0$.
However, the temporal model includes the location-bias parameter **and** the location-temporal weight parameter, $\mu_1$.
In addition, the spatial model includes all parameters in the above equation.

### Location-Bias

#### Histogram

This is the histogram of **all samples** of the location-bias parameter, $\mu_0$, for each station in Spain.


::::{tab-set}

:::{tab-item} IID
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1ETPsyh5_G-Dv3fKTWZz9iKC2ILe2a0_H)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} Time
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1Db4d9jAoqM30NWtNzFOIPt1S-Qnw-S__)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} Space-Time
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1Z1GgqZtBN1THaQgA9av4hdwbEYXDVYUd)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

::::


#### Mean Histogram

This is the histogram of the **mean** of the location-bias parameter, $\mu_0$, for each station in Spain.

::::{tab-set}

:::{tab-item} IID
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1MPCdwBe-M5MvkqxyRI_0r4-cCbePIoRL)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} Time
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1ilEe51dIXLrmOjjvymcSqLfgEgLtrGUb)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} Space-Time
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=13wjIIL5RwmXD6mmcwwQwxGscPJ20j7oD)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

::::


#### Maps

::::{tab-set}

:::{tab-item} IID
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1p4agHYmgP6-yocqc2Zs_Ro9ZGADrnvX_)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} Time
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1mdhiYMycQzL-UTBtRj21mMdqNSxhdkTA)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} Space-Time
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1hhDqDRREyt1SgpYzppL0c6R-Zovx8eMd)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

::::

***

### Location Time-Weight

We will look at the location temporal-weight parameter, $\mu_1$.
This parameter dictates the positive (or negative) correlation between the time parameter and the location parameter.


#### Histogram

::::{tab-set}
:::{tab-item} Time
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1lblCWmiyMB8_zxMA5-t7aFo-b-IQf0oL)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} Space-Time
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1UT341gCM7IUL3WIgbyxSxZqp6Gpe3eaS)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

::::

#### Mean Histogram

::::{tab-set}
:::{tab-item} Time
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=17yUW3B0-5XiHWp3JLlwqqP_2gcPGfQ3o)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} Space-Time
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1o5SJWuQt2ye-QRfQU11oXHCQqbtLY8QO)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

::::

#### Maps


::::{tab-set}
:::{tab-item} Time
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1KmbfEneT1WNr3nQo-qlhD2FBGPm78Ss0)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} Space-Time
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1yrChIRrBiC4fD3OFriIp6nxAEBc7p1-n)
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

:::{tab-item} IID
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1ydWZ8t7nwerU1j4HBZVViZ730rjKehRq)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} Time
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1PmzXiIo9YuzG43D1OXrj1lNzH6TnPS0Z)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} Space-Time
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1Ex0nIdHLoNjSHPzBf0Zxd6RNQ4UBWvm4)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

::::

### Mean Histogram

::::{tab-set}

:::{tab-item} IID
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=168lrD9uTqFb3eh2aPnqluUzrZ3nBOoBH)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} Time
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1BuhwO4mBJqAwf1t4sXYftNVxEmMZd528)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} Space-Time
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1sa8DHfdpHnb43NVfWhtvkcLcaURrl0S4)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

::::

### Map

::::{tab-set}

:::{tab-item} IID
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1UMxG73ietUXRG14NkL6ohaKrAI_r0RGN)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} Time
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1xi6rCXMkm5dOtyPjVyyxFFFEFsnHl5wP)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} Space-Time
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1IbiXGHEXVwT2IfQ7fDoqRbdydQ63zhTi)
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

:::{tab-item} IID
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1t7uLs5KeHNIPVHNgcANBMBtFTg3h7Iy3)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} Time
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1MDF-BxayRVC30t8RURiajhzgV-7YVdPh)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} Space-Time
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1I0e2jhk26ndVT8dncubV4Ugt84ZSHcKY)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

::::

### Mean Histogram

::::{tab-set}

:::{tab-item} IID
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1Pg0iC8ojjsDRImoAh2IDh262O7NfS2hQ)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} Time
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1_LoVdtl9HVLumRkVh40cz59mLYAWyV05)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} Space-Time
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=11GOGQnVGbb79yRUyOmfAeDku0IgOvPqt)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

::::

### Maps

::::{tab-set}

:::{tab-item} IID
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1G0vptzngPTjNKhJRFye_ecYK39264IYS)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} Time
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1hSBbwS7tTOkQRWzYNCU9abZsunUvVzPB)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} Space-Time
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1vWyon_eAgICETmMw5XwRbbH65r77kAKh)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

::::






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

:::{tab-item} Histogram
:::{figure}
:label: spain-threshold-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1OEYlNJhfFTju0wf0ag2TEp9dp6dHR1ZE)
A histogram of the threshold parameter, $y_0$, for all stations.
:::

:::{tab-item} Map
:::{figure}
:label: spain-threshold-map
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1Gxr3ijb8O48LNYK9KZ2bj7Vh1QAE0giD)
A map of the threshold parameter, $y_0$, for each station.
:::

::::

## Histogram

::::{tab-set}

:::{tab-item} IID
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1waVSFAlIQf14yZ-FigLTlXeRn-YZ-ORz)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} Time
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1PxTtuJIEfMlv_f9Ki-WuRwmnXkpR_vsg)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} Space-Time
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=14eds2Go1w9z84aF6DbpJn9pFPUvNOcgN)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

::::

## Mean Histogram



::::{tab-set}

:::{tab-item} IID
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1daA-VZ5eNwLo1MQJUjRdLLtFRTlE-Vyz)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} Time
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1gGRxUeTYuzzQsiX07rw-bb67j12qi5Kh)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} Space-Time
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1u7br-b7uV6Fumj2XL5bkK3nJ4QeJTZgb)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

::::




## Maps


### GMST - Scenario 0


::::{tab-set}

:::{tab-item} IID
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1Ij3ABiioK3MzgiEKGtz6wcAcUgBoAc-t)
The return period for the iid model.
:::

:::{tab-item} Time
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=167rTxyEvJeqHIxFs5knKqFRIJ9eEwQ1E)
The return period under a GMST scenario 0 for the temporal model.
:::

:::{tab-item} Space-Time
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=16iCY2VbrYKSTK6CnhuBxDEyUKwal3eig)
The return period under a GMST scenario 0 for the spatio-temporal model.
:::

::::

### GMST - Scenario 1

::::{tab-set}

:::{tab-item} IID
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1Ij3ABiioK3MzgiEKGtz6wcAcUgBoAc-t)
The return period for the iid model.
:::

:::{tab-item} Time
:::{figure}
:label: madrid-t2m-hist
:align: center

![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1DysGvessTvfPyeTXgHevYUVOKHw3D-aX)
The return period under a GMST scenario 1 for the temporal model.
:::

:::{tab-item} Space-Time
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1avezr6gTYUKZpRHEsGhgEFx6l2RRehCB)
The return period under a GMST scenario 1 for the spatio-temporal model.
:::

::::


### GMST - Scenario 2

::::{tab-set}

:::{tab-item} IID
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1Ij3ABiioK3MzgiEKGtz6wcAcUgBoAc-t)
The return period for the iid model.
:::

:::{tab-item} Time
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1gk6WPrFpobNunZhgwuOc-8A0nwXCZlWY)
The return period under a GMST scenario 2 for the temporal model.
:::

:::{tab-item} Space-Time
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1_kNaH9ix3C46HaBtcNoTDONoD-3Ilo1i)
The return period under a GMST scenario 2 for the spatio-temporal model.
:::

::::





# Returns

## Histogram

::::{tab-set}

:::{tab-item} IID
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1qTIOLXTGqVGWAyb06Opg439Wiv_rPQfx)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} Time
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1GyLcAmdU0UVEsuyIZ8pD5zXALEikfPsg)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} Space-Time
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=125SQgg4HoQ7EQl7V8PDm5OJm6_2dUysA)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

::::

## Mean Histogram

::::{tab-set}

:::{tab-item} IID
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1bK_lk9ljehF8A6GIcA_hzXkHX9QaKAZG)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} Time
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1ccGszkmJBfELXrl-jKiEUaSOuu7dj3Xt)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} Space-Time
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1cyw2Ee2HMgbjPCVI4I9vkMwGlcuCkeJr)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

::::




## Maps

### GMST - Scenario 0


::::{tab-set}

:::{tab-item} IID
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1_E4BavUauLsGKtUz9aS7O7ZcNNGd3nG-)
The return period for the iid model.
:::

:::{tab-item} Time
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1ReEWQx1xtmfGuxirb5OJYnI76dFJtjmu)
The return period under a GMST scenario 0 for the temporal model.
:::

:::{tab-item} Space-Time
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1ZH4rwPfTAO4_bhJSWo1SE6FZAGD91fnI)
The return period under a GMST scenario 0 for the spatio-temporal model.
:::

::::

### GMST - Scenario 1

::::{tab-set}

:::{tab-item} IID
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1fDiCsIbmCwvRkAzSj59V3U8SqXaHQO5g)
The return period for the iid model.
:::

:::{tab-item} Time
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1ReEWQx1xtmfGuxirb5OJYnI76dFJtjmu)
The return period under a GMST scenario 1 for the temporal model.
:::

:::{tab-item} Space-Time
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1B_egEwD6UtYQESGZK-7t7jaESSgj_jnB)
The return period under a GMST scenario 1 for the spatio-temporal model.
:::

::::


### GMST - Scenario 2

::::{tab-set}

:::{tab-item} IID
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1fDiCsIbmCwvRkAzSj59V3U8SqXaHQO5g)
The return period for the iid model.
:::

:::{tab-item} Time
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1eGyyILsEBBNonyTF4QkPHE54JNV50paE)
The return period under a GMST scenario 2 for the temporal model.
:::

:::{tab-item} Space-Time
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1k0V1gRhGn1NgmPfNjioj5sjR_2rfNEPd)
The return period under a GMST scenario 2 for the spatio-temporal model.
:::

::::



## Differences

***
### Case I - Scenario 0 and 1

The first case, we look at the absolute difference between the GMST scenarios 0 and 1.
This corresponds to the difference in the pre-industrial climate and the actual climate.


::::{tab-set}

:::{tab-item} Time
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1JqG7712s3by0kuBjH2wnBpUT7ef3I2j5)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} Space-Time
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=10_Vi6-f4RHycPlo0SxGBdZOZHuC399Ei)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

::::

***
### Case I - Scenario 1 and 2s

The first case, we look at the absolute difference between the GMST scenarios 1 and 2.
This corresponds to the difference in the actual climate and the future climate.

::::{tab-set}

:::{tab-item} Time
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1JQjjxuXY2zC1geWfAkaC0qFOXaS12tC0)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} Space-Time
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1txc229DF80RiRzrmp5i9hJQlP35C3NgH)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

::::
