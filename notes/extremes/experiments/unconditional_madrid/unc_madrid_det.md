---
title: Preliminary Results
subject: Misc. Notes
short_title: Deterministic Models
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
### Model

We assume that our data

$$
\begin{aligned}
\mathcal{D} &= \left\{ y_n \right\}_{n=1}^N && &&
y_n \in \mathbb{R} && &&
\mathbf{y} = [y_1, y_2, \ldots, y_N]
\end{aligned}
$$

We also assume that there is a joint distribution of a set of parameters, $\boldsymbol{\theta}$, combined with the observation, $\mathbf{y}$.
However, we decompose the joint distribution into a likelihood and prior.
Basically, the observations can be explained some prior parameters.

$$
p(\mathbf{y},\boldsymbol{\theta}) = p(\mathbf{y}|\boldsymbol{\theta})p(\boldsymbol{\theta})
$$

The likelihood term is the GEVD distribution and the prior term are the prior parameters for the GEVD distribution.

$$
\begin{aligned}
\text{Data Likelihood}: && &&
y &\sim \text{GEVD}(\mu, \sigma, \kappa) \\
\text{Prior Parameters}: && &&
\boldsymbol{\theta} &\sim p(\boldsymbol{\theta}) \\
\end{aligned}
$$ (eq:gevd-joint-parts)

where $\boldsymbol{\theta} = \left\{\mu,\sigma,\kappa\right\}$.

***
### Inference

The full term for inference is given by

$$
p(\boldsymbol{\theta}|\mathbf{y}) = 
\frac{1}{Z}p(\mathbf{y}|\boldsymbol{\theta})
p(\boldsymbol{\theta})
$$

where $Z$ is a normalizing constant. 
The problem term is the normalizing constant because it is an integral wrt to all of the parameters

$$
Z=\int p(\mathbf{y}|\boldsymbol{\theta})p(\boldsymbol{\theta})p\boldsymbol{\theta}
$$

This is intractable because there is no closed form given the non-linearities in the GEVD PDF as seen in [](eq:gevd_pdf) and [](eq:gevd_pdf_function).


We assume that the posterior distribution is proportional to the decomposition of the joint distribution and ignore the normalization constant.

$$
p(\boldsymbol{\theta}|\mathbf{y}) \propto
p(\mathbf{y}|\boldsymbol{\theta})p(\boldsymbol{\theta})
$$

Thus, we will acquire an approximate estimate of the parameters given the measurements.
To minimize this, we will simply

$$
\boldsymbol{L}(\boldsymbol{\theta}) = \underset{\boldsymbol{\theta}}{\text{argmin}} \hspace{2mm}
\sum_{n=1}^N\log p(\boldsymbol{\theta}|\mathbf{y}_n) 
$$ (eq:madrid-gevd-approx-loss)

:::{tip} Optimization Scheme
:class: dropdown
We still need to find the parameters whichever methodology we use.

$$
\boldsymbol{\theta}^* = \underset{\boldsymbol{\theta}}{\text{argmin}}
\hspace{2mm}
\boldsymbol{L}(\boldsymbol{\theta})
$$

This requires one to iterate until convergence

$$
\begin{aligned}
\text{Initial Parameters}: && && 
\boldsymbol{\theta}_0 &= \ldots \\
\text{Initial Optimization State}: && &&
\mathbf{h}_0 &= \ldots \\
\text{Optimization Step}: && &&
\boldsymbol{\theta}^{(k)}, \mathbf{h}^{(k)} &= \boldsymbol{g}(\boldsymbol{\theta}^{(k-1)}, \mathbf{h}^{(k-1)}, \boldsymbol{\alpha}) \\
\end{aligned}
$$

For these methods, we use a highlevel optimizer for solving unconstrained problems.
In particular, we use the Broyden–Fletcher–Goldfarb–Shanno (BFGS) algorithm {cite:p}`doi:10.1002/9781118723203` [[wiki](https://en.wikipedia.org/wiki/Broyden%E2%80%93Fletcher%E2%80%93Goldfarb%E2%80%93Shanno_algorithm)].
It is a higher level optimization scheme which uses the Hessian matrix of the loss function, in this case it is the negative log-likelihood loss.
It is chosen because it offers very fast convergence for nonlinear optimization problems where higher level gradient information is available.

:::



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

#### Background

$$
\boldsymbol{L}_\text{MLE}(\boldsymbol{\theta}) = \underset{\boldsymbol{\theta}}{\text{argmin}} \hspace{2mm}
\sum_{n=1}^N\log p(y_n|\boldsymbol{\theta})  
$$ (eq:madrid-gevd-mle-loss)

We put some constraints on the parameters.
The mean and shape parameters are allowed to be completely free however, the scale parameter is constrained to be positive.

$$
\begin{aligned}
\text{Mean}: && &&
\mu &\in \mathbb{R} \\
\text{Scale}: && &&
\sigma &\in \mathbb{R}^+ \\
\text{Shape}: && &&
\kappa &\in \mathbb{R}
\end{aligned}
$$ (eq:madrid-gevd-mle-constraints)


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
#### Background

The MAP estiamtion is very similar to the MLE estimation except that we put priors on the parameters.

$$
\boldsymbol{L}_\text{MAP}(\boldsymbol{\theta}) = \underset{\boldsymbol{\theta}}{\text{argmin}} \hspace{2mm}
\sum_{n=1}^N\log p(y_n|\boldsymbol{\theta})  + 
\log p(\boldsymbol{\theta})
$$

We put some prior distributions on the parameters.
The mean and shape parameters are allowed to be completely free however, the scale parameter is constrained to be positive.

$$
\begin{aligned}
\text{Mean}: && &&
\mu &\sim  \text{Normal}(\hat{\mu},\hat{\sigma})\\
\text{Scale}: && &&
\sigma &\sim \text{LogNormal}(0.5\hat{\sigma}, 0.25)\\
\text{Shape}: && &&
\kappa &\sim \text{Normal}(\hat{\kappa}, 0.1)\\
\end{aligned}
$$ (eq:madrid-gevd-map-priors)

The estimated parameters for the $\mu$ are estimated directly from the data by calculating the mean and standard deviation.
We use the same estimated parameter

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