---
title: Data-Driven Attribution
subject: Data-Driven Modeling for Attribution
short_title: AI 4 Attribution
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
    EOFs: Empirical Orthogonal Functions
    POD: Proper Orthogonal Decomposition
    PCA: Principal Components Analysis
    SSP: Shared Socioeconomic Pathways
    GPD: Generalized Pareto Distribution
    GEV: Generalized Extreme Value
    QoI: Quantity of Interest
    iid: Independently Identically Distributed
---

> This is a summary of my interpretation for the data-driven modeling for attribution.
> Attribution is used as a way to *explain* how or why an event occurs within a given model.
> I will be mainly using the paper by [[Phillip et al, 2020](https://doi.org/10.5194/ascmo-6-177-2020)] to explain one way to perform attribution using simple statistical models.

***

## Objective

> Attribution - The action of regarding something as being caused by a person or thing (Oxford Languages)


**What We Care About**. 
Overall, we care about whether an event occurs due to something measurable. 
In the case of climate, we care if we can explain extreme weather or climate event can be explained by some anthropogenic cause.

**Risk-Based Method**.
We can try and pose the question by taking two sample populations: 1) a factual world and 2) a counter-factual world.

$$
\begin{aligned}
\text{Factual}: && && u_0 &\sim p(u_0|\mathcal{M}_0) \\
\text{Counter Factual}: && && u_1 &\sim p(u_1|\mathcal{M}_1) 
\end{aligned}
$$

For example, the event, $u_0$, could be the likelihood of the event occurring under a natural varying climate, $\mathcal{M}_0$, whereas $u_1$ could be the likelihood of the event occurring under an anthropogenic forced varying climate, $\mathcal{M}_1$.

Here, 
[Shepard 2016](https://doi.org/10.1007/s40641-016-0033-y)


**StoryLine-Based Methods**.
We can try and pose the question by trying to best estimate the contribution of climate change to an observed event.

***

## Data


There are a large number of preprocessing routines that were implemented to preprocess the data.
However, we start with a spatiotemporal field of a variable, e.g., temperature or precipitation.

$$
\begin{aligned}
\boldsymbol{y} = \boldsymbol{y}(\mathbf{x},t)
&& && \mathbf{x}\in\Omega\subseteq\mathbb{R}^{D_s} && &&
t\in\mathcal{T}\subseteq\mathbb{R}^+
\end{aligned}
$$

The domain, $\Omega$, is over some region and the period, $\mathcal{T}$, is over the entire period of data available, e.g., `1850-2023`.
We are typically interested in data involving observations.
So we can use pure observations, reanalysis data (e.g., ERA5), or simulations with forcing from observations (e.g., CMIP-Historical).

***

### Filtering

First, we perform some sort of filtering procedure to remove ... from the spatiotemporal cube. 

$$
\begin{aligned}
\boldsymbol{y}(\mathbf{x},t) = \boldsymbol{F}_\text{Filter}[\boldsymbol{y};\theta](\mathbf{x},t), && &&
\mathbf{x}\in\Omega_\text{Globe}\subseteq\mathbb{R}^{D_s} && &&
t\in\mathcal{T}_\text{Globe}\subseteq\mathbb{R}^+
\end{aligned}
$$

In this case a kernel average of 3-5 days is applied.

**Note**: 

:::{seealso} Help

See [my guide](../../../cookbook/filtering.md) for more information on filtering.

:::

***

### Anomalies

First, we need to calculate the climatology of our dataset which is the global spatial average over some defined reference period.
The equation for the climatology is given by:


$$
\begin{aligned}
\text{Climatology Equation}: && && \bar{y}_\text{Climatology}(t) &= \frac{1}{N_s}\sum_{n=1}^{Ns}\boldsymbol{y}(\mathbf{x}_n,t) \\
\text{Climatology Function}: && && \bar{y}_\text{Climatology}&: \Omega_\text{Globe}\times\mathcal{T}_\text{Reference} \rightarrow \mathbb{R}^{D_y} \\
\text{Spatial Domain}: && && \mathbf{x}&\in\Omega_\text{Globe}\subseteq\mathbb{R}^{D_s}\\
\text{Temporal Domain}: && && t&\in\mathcal{T}_\text{Reference}\subseteq\mathbb{R}^+
\end{aligned}
$$

The reference period, $\mathcal{T}_\text{Reference}$, is some defined period which captures majority of the trends we can expect to see.
We also want this reference period to have minimal influence of anthropogenic activity.
So, given the defined period of `1850-2023`, we could take the reference period to be `1850-1880` (30 years).

:::{seealso} Climatology

There are many ways to calculate the climatology.
See [my climatology guide](../../../cookbook/anomalies.md) for examples of how to calculate the climatology.

:::



To calculate the anomalies of the spatiotemporal cube, we subtract the climatology from the field.

$$
\begin{aligned}
\text{Anomaly Equation}: && && \boldsymbol{\bar{y}}_\text{Anomaly}(\mathbf{x},t) &= \boldsymbol{y}(\mathbf{x},t) + \boldsymbol{\bar{y}}_\text{Climatology}(t) \\
\text{Anomaly Function}: && && \boldsymbol{\bar{y}}_\text{Anomaly}&: \Omega_\text{Globe}\times\mathcal{T}_\text{Globe} \rightarrow \mathbb{R}^{D_y} \\
\text{Spatial Domain}: && && \mathbf{x}&\in\Omega_\text{Globe}\subseteq\mathbb{R}^{D_s}\\
\text{Temporal Domain}: && && t&\in\mathcal{T}_\text{Globe}\subseteq\mathbb{R}^+
\end{aligned}
$$

What remains are the anomalies of the spatiotemporal field, $\boldsymbol{y}$.




***

### Data Reduction

Now, we perform a data reduction of the spatiotemporal field. 
In the simplest case, we can take the spatial average of the field at every time step.
This will result in a single time series for the entire data cube.

$$
\begin{aligned}
\text{Reduced Data Equation}: && && \tilde{y}_\text{anomaly}(t) &= \frac{1}{N_s}\sum_{n=1}^{N_s}\boldsymbol{\bar{y}}_{anom}(\mathbf{x},t) \\
\text{Reduced Data Anomaly Function}: && && \tilde{y}_\text{anomaly} &: \mathcal{T}_\text{Globe} \rightarrow \mathbb{R}^{D_y} \\
\text{Temporal Domain}: && && t&\in\mathcal{T}_\text{Globe}\subseteq\mathbb{R}^+
\end{aligned}
$$

:::{seealso} Help

See [my guide](../../../cookbook/spatial_mean.md) for more information on how we can calculate the spatial mean.

**Note**: there are other ways we can reduce the dimensionality of the data.
For example, we can use Empirical Orthogonal Functions (EOFs) (a.k.a. PCA, POD).

:::

***

## Data Representation

There are a number of ways to represent the time series above.
In the subsequent sections, we will look at 2 different ways: 1) independent observations and 2) time-dependent observations.

***

### Independent Assumption

In this example, we do not discriminate between the values of our QOI wrt time.
We simply assume each observation is iid.

$$
\mathcal{D} = \{\boldsymbol{y}_n\}_{n=1}^{N_t}
$$


In all cases, we are looking for some parameterized probability distribution that explains the anomalies.
We can write this as a parameterized, generative model that can fit the distribution of observations.

$$
\boldsymbol{y} \sim p(\boldsymbol{y};\boldsymbol{\theta})
$$


***

#### Example Distributions



We will outline a few cases below including the generalized Pareto distribution, the generalized extreme value distribution, the Gumbel distribution, the Gamma distribution, and the T-Student/Cauchy distribution.

:::{note} Generalized Pareto Distribution
:class: dropdown

The first distribution is the GPD.

$$
p(y;\boldsymbol{\theta}) = \frac{1}{\sigma}\left[ 1 + \xi\left(\frac{y - \mu}{\sigma}\right)\right]^{-\frac{1}{\xi}-1}
$$

This is a three parameter model.
$x$ is the input variable, e.g., temperature or precipitation.
The parameters for the distribution is $\boldsymbol{\theta} = \{\mu, \sigma, \xi\}$.
$\mu$ is the threshold, $\sigma$ is the scale parameter, and $\xi$ is the shape parameter.

See the [GPD wiki](https://en.wikipedia.org/wiki/Generalized_Pareto_distribution) for more information.

:::



:::{note} Generalized Extreme Value Distribution
:class: dropdown

The second distribution is the GEV Distribution.

$$
p(y;\boldsymbol{\theta}) = \exp 
\left[ - 
\left( 1 + \xi \left(\frac{y - \mu}{\sigma} \right) \right)^{-1/\xi}
\right]
$$

where $\boldsymbol{\theta} = \{ \mu, \sigma, \xi \}$ are the free parameters of the distribution.


:::

***

## Conditional Models

A second attempt would be to construct a conditionally parameterized distribution.
In this case, we introduce some dependencies on the variable itself.

$$
u \sim p\left(\theta (u)\right)
$$

This changes this function from a generative parametric model to a likelihood model, i.e., a model that generates the parameters wrt some external parameter like time.

In general, most of the distributions that were mentioned above have a mean and standard deviation parameter.
One could easily try to parameterize those parameters with functions that are dependent upon some space and time parameters.
For example, the mean function could be depending upon space, time, and some control vector and likewise the standard deviation.

### Data

For fitting this data, we assume that all elements within the time series are a sequential set of observations

$$
\mathcal{D} = \{ t, u_t\}_{t=1}^{N_t}
$$

where $u\in\mathbb{R}$.


:::{note} Case Study: Temperature Anomaly Tendency & Scale
<!-- :class: dropdown -->

In the paper of [Phillip et al, 2020](https://doi.org/10.5194/ascmo-6-177-2020), they parameterize the mean and scale function using a linear function of the temperature. 
They assume that the mean is some function
They remove the dependency that the temperature is independent and they try to fit a conditional parametric distribution to explain the anomalies on the temperature values which have a dependency on time.
So the variable of interest is temperature and we assume it is iid

$$
\begin{aligned}
\mathcal{D} = \{ T_n \}_{n=1}^{N_t}
\end{aligned}
$$

They assume a conditional likelihood function for temperature and time.

$$
y \sim p(y;\theta(T)) 
$$

They use a GEV distribution for the likelihood function

$$
p(y|\theta;T) = \exp 
\left[ - 
\left[ 1 + \xi \left(\frac{u - \mu(T;\boldsymbol{\theta})}{\sigma(T;\boldsymbol{\theta})}\right) \right]^{-1/\xi}
\right]
$$

The authors try to fit a linear function wrt time and a constant scale parameter.
This is given by the equation

$$
\begin{aligned}
\text{Mean}: && && \mu(T;\theta) &= \mu_0 + \alpha T \\
\text{Scale}: && && \sigma(T;\theta) &= \sigma_0
\end{aligned}
$$

where the parameters of the mean function are $\theta_\mu=\{\mu_0, \alpha\}$ and their are no parameters for the scale function. They showcase another example whereby they try to fit a function for the scale

$$
\begin{aligned}
\text{Mean}: && && \mu(T; \theta) &= \mu_0 \exp\left(\frac{\alpha T}{\mu_0}\right) \\
\text{Scale}: && && \sigma(T; \theta) &= \sigma_0 \exp\left(\frac{\alpha T}{\mu_0}\right)
\end{aligned}
$$

where the parameters of the mean function are $\theta_\mu=\{\mu_0, \alpha\}$ and the parameters of the scale function are $\theta_\sigma=\{\sigma_0, \mu_0, \alpha\}$. 
The origin of this function comes from 

:::

*** 

## Conditional Dynamical Models

$$
y_t \sim p\left(y|t;\theta\right)
$$


:::{note} Case Study I: Temperature Tendency  & Scale
<!-- :class: dropdown -->

In the paper of [Phillip et al, 2020](https://doi.org/10.5194/ascmo-6-177-2020), they parameterize the mean and scale function using the temperature wrt time. 
They remove the dependency that the temperature is independent and they try to fit a conditional parametric distribution to explain the anomalies on the temperature values which have a dependency on time.
So the variable of interest is temperature which varies wrt time.

$$
\begin{aligned}
T &= T(t), && && t\in[t_0, t_1]\subseteq\mathbb{R}^+
\end{aligned}
$$

They assume a conditional likelihood function for temperature and time.

$$
y(t) \sim p(y|t;\theta) 
$$

They use a GEV distribution for the likelihood function

$$
p(u|t;\theta) = \exp 
\left[ - 
\left( 1 + \xi \frac{u - \mu(t;\theta)}{\sigma(t;\theta)} \right)^{-1/\xi}
\right]
$$

whereby the 


$$
\begin{aligned}
\text{Mean}: && && \mu(t;\theta) &= \mu_0 + \alpha u(t) \\
\text{Scale}: && && \sigma(t;\theta) &= \sigma_0
\end{aligned}
$$

where the parameters of the mean function are $\theta_\mu=\{\mu_0, \alpha\}$ and their are no parameters for the scale function. They showcase another example whereby they try to fit a function for the scale

$$
\begin{aligned}
\text{Mean}: && && \mu(t; \theta) &= \mu_0 \exp\left(\frac{\alpha u(t)}{\mu_0}\right) \\
\text{Scale}: && && \sigma(t; \theta) &= \sigma_0 \exp\left(\frac{\alpha u(t)}{\mu_0}\right)
\end{aligned}
$$

where the parameters of the mean function are $\theta_\mu=\{\mu_0, \alpha\}$ and the parameters of the scale function are $\theta_\sigma=\{\sigma_0, \mu_0, \alpha\}$

:::

***

## Inference

We can use the standard posterior distribution to best fit the parameters of the distribution given the data.

$$
p(\theta|\mathcal{D}) = \frac{1}{Z}p(\mathcal{D}|\theta)p(\theta)
$$

Here, we have many examples of different inference methods to use. 
For example, we can use simple methods like Maximum Likelihood Estimation (MLE) or Maximum-A-Posterior (MAP). 
We can use approximate inference methods like Laplace or Variational Inference (VI).
We could even use sampling methods like Markov Chain Monte-Carlo (MCMC).
