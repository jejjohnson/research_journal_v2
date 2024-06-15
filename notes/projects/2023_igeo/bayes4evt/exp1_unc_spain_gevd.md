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


### Metrics

#### Log-Likelihood

* -17089.15032017 +/- 4.06643326
* -15571.70729426 +/- 4.73258625
* -15198.35183499 +/- 59.1095967

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


### Static Parameters


#### Location-Bias

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
#### Scale

Recall, the parameterization for the scale parameter is given by

$$
\sigma(t;\boldsymbol{\theta})
=
\sigma_0
$$

where $\sigma_0$ is the scale parameter per station.
This means that each model will have the same scale parameterization.

::::{tab-set}

:::{tab-item} IID
:::{figure}
:label: madrid-t2m-hist
:align: center


![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1ayUQO0IE4lwOToYD2c89XEnyB6DhcyLu)
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
#### Concentration

Recall, the parameterization for the shape parameter is given by

$$
\kappa(t;\boldsymbol{\theta})
=
\kappa_0
$$

where $\kappa_0$ is the shape parameter per station.
This means that each model will have the same shape parameterization.


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


### Returns

#### Differences


##### Case I - 0.0 -> 1.0


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


##### Case I - 1.0 -> 2.0
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
