---
title: Preliminary Results
subject: Misc. Notes
short_title: Experiment 1a
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

Here, we showcase some deterministic models to find the best models.
When we say deterministic, we mean that we will only obtain a single set of parameters. 
Thus, when we do analysis for example, the return period, we will only obtain a single set of predictions.


***
## Results

```{list-table} Table with results for each model
:header-rows: 1
:name: tb:madrid_unc_det_model

* - Inference
  - Location, $\mu$
  - Scale, $\sigma$
  - Shape, $\kappa$
  - Return Level, 100 yr
  - NLL Loss
  - AIC
  - BIC
* - MLE Estimator, eq. [](eq:madrid-gevd-mle-loss)
  - 37.190
  - 1.478
  - -0.280
  - 41.011
  - -112.32
  - 230.64
  -
* - MAP Estimator, eq. [](eq:madrid-gevd-map-loss)
  - 37.184
  - 1.530
  - -0.290
  - 41.071
  - -109.47
  - 224.95
  -
```

***
### MLE Estimation



#### Posterior Predictive Checks


First, we will look at some of the loss function metrics.
Essentially, how well did we do


::::{tab-set}
:::{tab-item} NLL Loss Curve
:sync: tab1
:::{figure}
:label: madrid-t2m-ts
:align: center

![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1rRtwvQliIONgM9uz1bZ-xmOhVNl3_60Q)
The loss curve for the negative log-likelihood in equation [](eq:madrid-gevd-mle-loss).
:::

:::{tab-item} NLL Time Series
:sync: tab2
:::{figure}
:label: madrid-t2m-hist
:align: center

![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=13p947G3gdA_8isVaaKcHviVyuMjSmyBW)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} Q-Q Plot for MLE Estimator
:sync: tab3
:::{figure}
:label: madrid-t2m-ts
:align: center

![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1lvTPNw_i_ux6oE_pVai1UqET3TXk9uXS)
A Q-Q plot for the MLE estimator.
:::

:::{tab-item} Return Period 4 MLE Estimator
:sync: tab3
:::{figure}
:label: madrid-t2m-hist
:align: center

![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1j9LBWCcSoQXk5AYVVkOxeXHYOqlFiyhJ)
The return values for the MLE estimator
:::
::::



---
### MAP Estimation



***
#### Prior Predictive Checks

For the first stage, we do some prior predictive checks to see if our prior beliefs match our observations.
Firstly, we can look at [](fig:madrid-t2m-bm-map-prior-joint) which will showcase a joint plot of the prior parameters given in equation [](eq:madrid-gevd-map-priors). 
Secondly, we can propagate these through the data likelihood term (equation [](eq:gevd-joint-parts)) to get the measurement distribution of what we would expect to see, i.e., the *prior predictive posterior*.

$$
\begin{aligned}
\text{Prior Samples}: && &&
\boldsymbol{\theta}_n &\sim p(\boldsymbol{\theta}) \\
\text{Data Likelihood}: && &&
y_n &\sim p(\mathbf{y}|\boldsymbol{\theta})
\end{aligned}
$$

As we can see from [](fig:madrid-t2m-bm-map-prior-pred), the prior predictive posterior distribution is quite close to the approximate observed distribution.

Lastly, we can check to see 

$$
\begin{aligned}
\text{Return Periods}: && &&
\mathbf{y}_n &\sim \ldots \\
\text{Prior Samples}: && &&
\boldsymbol{\theta}_n &\sim p(\boldsymbol{\theta}) \\
\text{Data Likelihood}: && &&
y_p^{n} &\sim \boldsymbol{q}_\text{GEVD}(\mathbf{y}_p;\boldsymbol{\theta})
\end{aligned}
$$

where $\boldsymbol{q}_\text{GEVD}$ is the quantile distribution for the GEVD; see equation [](eq:gevd-quantile).




::::{tab-set}
:::{tab-item} Prior Parameters Joint Plot
:sync: tab1

:::{figure}
:label: fig:madrid-t2m-bm-map-prior-joint
:align: center

![](https://drive.google.com/uc?id=1LizbdXELBm6TuU4l-JcIDNZhJchav4mc)
A joint plot for the distribution of prior parameters based on the equations [](eq:madrid-gevd-map-priors).
:::

:::{tab-item} Prior Predictive Posterior
:sync: tab2
:::{figure}
:label: fig:madrid-t2m-bm-map-prior-pred
:align: center

![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1Zg79Uuu9-5GpgCcjh3wXKj2NseNDFtFr)
The prior predictive posterior distribution for our prior parameters given in equation [](eq:madrid-gevd-map-priors) and the outputs once propagated through the GEVD data likelihood distribution in equation [](eq:gevd-joint-parts)
:::

:::{tab-item} Prior Return Level
:sync: tab3
:::{figure}
:label: fig:madrid-t2m-bm-map-prior-pred
:align: center

![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1mmFtbtMVIpxpgchxZADH4Ac2LUCzRZ9k)
The prior return level based on the priors given in equation [](eq:madrid-gevd-map-priors) and the outputs once propagated through the GEVD quantile distribution which corresponds to the return level in equation [](eq:gevd-quantile)
:::
::::


#### Posterior Predictive Checks

::::{tab-set}

:::{tab-item} NLL Time Series
:sync: tab1
:::{figure}
:label: madrid-t2m-hist
:align: center

![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1eaAjMXBfZWE1ljho2CT_L1wV6tY5bW6s)
The negative log-likelihood loss (equation [](eq:madrid-gevd-mle-loss)) for each time step within the time series.
:::

:::{tab-item} Q-Q Plot
:sync: tab2
:::{figure}
:label: madrid-t2m-ts
:align: center

![](https://drive.google.com/uc?id=11SOHE2c_ZgUbvPhOqlTUtQpxcns-nYr6)
A Q-Q plot for the MAP estimator.
:::

:::{tab-item} Return Period
:sync: tab3
:::{figure}
:label: madrid-t2m-hist
:align: center

![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1wMb--C_ZWRvo9_tueoYblmvY8PvYnIah)
The return values for the MAP estimator
:::
::::