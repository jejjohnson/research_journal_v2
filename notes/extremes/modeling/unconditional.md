---
title: Unconditional
subject: AI 4 Attribution
short_title: I - Unconditional
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


> **TLDR**: 
> We will explore some staple data likelihoods for modeling extreme values. 
> We can include some standard distributions like the Normal and LogNormal, more long-tail distributions like the T-Student and Stable Distribution, and also more extreme value specific distributions like GEVD and GPD. 
> We will directly find the best parameters of these distributions given observations of extreme values . 
> We will explore various methods for extracting extreme values from spatiotemporal data like block maxima method or the peak-over-threshold (POT) method. 
> We will look at advanced inference methods using the `numpyro` library to estimate the parameters. 
> We will explore different analysis techniques like the quality of data fit (p-p plot, q-q plot, PDFs, CDFs) and return periods to make predictions about unseen extremes. We will also do an exploratory analysis to characterize the autocorrelations in space and time. In addition, we will explore different standardized ad-hoc feature extraction techniques to extract IID data, i.e., the residuals. 
> Some examples include removing trends like the climatology, appropriate time scale aggregation, appropriate spatial scale aggregation, filtering and differencing.

***

## **Table of Contents**

- *Deep Dive*: Extreme Value Theory
- Calculating Extreme Values for Spatiotemporal Data
- Feature Extraction for Spatiotemporal Dependencies
- Bayesian Modeling of Extreme Values
- Bayesian Hierarchical Modeling of Extreme Values
- Analysis of Extreme Values

***

## Abstractions

**Data-Driven Modeling Pipeline**

1. Data Acquisition
2. Feature Extraction
3. Extreme Values Extraction
4. Bayesian Model
5. Bayesian Inference
6. Analysis


***

**Extreme Value Extractor Pipeline**

1. Define spatiotemporal block
2. Select a threshold
3. Select Minimum/Maximum Values
4. Count the number occurrences of the values above a threshold within a spatiotemporal block
5. Summary statistic of occurrences, eg mean, median, etc


***
## Proposal

**What's Been Done**.
The original paper [Philip et al, 2020](https://doi.org/10.5194/ascmo-6-177-2020)) looks at some of the standard probability distributions to model observation data; in particular, they look at temperature and precipitation.
They looked at standard distributions like the Normal distribution as well as long tail distributions like the T-Student distribution.
The most interesting was their investigation of extreme value distributions like the GEVD and the GPD. 
There is also a wealth of examples available at ([Coles, 2001](https://doi.org/10.1007/978-1-4471-3675-0)) which takes a more step-by-step approach.

**What's Lacking**.
Many papers do not show visualizations or intuitions for the uncertainty within parameters.
They also don't provide any practical insights into which inference methods work best and why.
In addition, there is no consistent software in the python community that is understandable, modular, and extensible.

**Data Representation**.
We will use the simplest data representation possible.
We will spatially aggregate the observations, $y$, to get a time series.
Then, we will assume the time series is IID.
$$
\begin{aligned}
\mathcal{D} = \{ y_n \}_{n=1}^N, && &&
y_n\in\mathbb{R}^{D_y}, && &&
N = N_t
\end{aligned}
$$
To extract extremes, we will look at the two methods: 1) block maxima and 2) peak-over-threshold.
To combat the iid assumption, we will do a wide range of preprocessing steps that are common within the climate community, e.g., filtering, removing the climatology, and other aggregation strategies.


**Model Formulation**.
We will use the standard Bayesian approach whereby we fit the observations to some staple distributions for extreme values.
$$
\begin{aligned}
\text{Data Likelihood}: && &&
\boldsymbol{y} &\sim p(\boldsymbol{y}|\boldsymbol{\theta}) \\
\text{Prior}: && &&
\boldsymbol{\theta} &\sim p(\boldsymbol{\theta})
\end{aligned}
$$
There will be using a data likelihood for the extremes and a prior set of parameters for the likelihood distribution, e.g., the mean, $\mu$, the scale, $\sigma$, and the shape, $\xi$.


**Proposed Improvements**.
We can add a short list of some Bayesian inference methods on these parametric models where we give alternative inference methods, e.g., MLE, MAP, Laplace Approximation, Variational Inference ([Wingate & Weber, 2013](https://doi.org/10.48550/arXiv.1301.1299), [Ranganath et al, 2013](https://doi.org/10.48550/arXiv.1401.0118)), MCMC, and HMC.
This will give users more uncertainty quantification of the parameters found.
We will use modern PPLs which will give users speed and reasonable scalability.
We will demonstrate how easy it is to implement simple ideas via well done code.
We will also uphold strict reproducibility standards so that the broader community can engage in further developments of modeling extreme values using modern ML-inspired tools.


***
## Data Structure Assumptions

Recall, we are dealing with a spatiotemporal field given by

$$
\begin{aligned}
\boldsymbol{y} = \boldsymbol{y}(\mathbf{x},t)
&& &&
\boldsymbol{y}:\mathbb{R}^{D_s}\times\mathbb{R}^+\rightarrow\mathbb{R}^{D_y}
&& &&
\mathbf{x}\in\Omega_y\subseteq\mathbb{R}^{D_s}
&& &&
t\in\mathcal{T}\subseteq\mathbb{R}^+
\end{aligned}
$$

where $\mathbf{x}$ are the spatial coordinates and $t$ is the temporal coordinate.

***

### I.I.D. Samples

This is the simplest form where we assume each datapoint is independent, i.e., no spatial or temporal dependencies. 
When given a:
* Time Series: this means that we assume there are no temporal correlations.
* Spatial Field - this means that we assume that there are no spatial correlations.
* SpatioTemporal Field - we assume there are no spatial AND temporal correlations.

So the dataset will be:

$$
\mathcal{D} = \{ \boldsymbol{y}_n \}_{n=1}^{N}
\hspace{10mm}
\boldsymbol{y}_n\in\mathbb{R}^{D_y}
$$

where $N=N_s N_t$ are the total number of points in the spatiotemporal datacube.
When given a spatiotemporal datacube, this can be achieved through spatiotemporal aggregations, e.g., 
The reasoning is be

***

### Parametric Model



We assume we have a data likelihood given by:

$$
\boldsymbol{y} \sim p(\boldsymbol{y}|\boldsymbol{\theta})
$$

This distribution could be a Gaussian,a GEVD or a Pareto distribution.
We are interested in finding the best parameters, $\boldsymbol{\theta}$ given the observations, $\boldsymbol{y}$, i.e., the posterior.
The full Bayesian posterior can be written as

$$
p(\boldsymbol{\theta}|\boldsymbol{y}) = \frac{1}{Z}p(\boldsymbol{y}|\boldsymbol{\theta})p(\boldsymbol{\theta})
$$

where $Z$ is a normalization constant.
We can use any inference technique including approximate inference methods or sampling methods.




***

#### Model

First, we will need to provide some priors for the variables.
We will use uninformative priors for each of the parameters.
However, we will constrain the scale and degress-of-freedom parameter, $\sigma,\nu$, to be positive only.

```python
# prior location parameter 
loc: Array[""] = numpyro.sample("loc", dist.Normal(0.0, 1.0)) 
scale: Array[""] = numpyro.sample("scale", dist.LogNormal(0.0, 10.0))
df: Array[""] = numpyro.sample("df", dist.LogNormal(0.0, 10.0))
```

We also need a data likelihood 

```python
y: Array[""] = numpyro.sample("y", dist.StudentT(df=df, loc=loc, scale=scale), obs=y)
```


#### Inference


**Prior Predictive Distribution**

$$
\begin{aligned}
\text{Prior Samples}: && && 
\boldsymbol{\alpha}_n &\sim p(\boldsymbol{\alpha}) \\
\text{Data Likelihood}: && &&
y &\sim p(y|\boldsymbol{\alpha})
\end{aligned}
$$

```python
prior_predictive = Predictive(model, num_sample=100)
prior
```

***

**Perform Inference**

```python
kernel = NUTS(model)
num_samples = 2_000
mcmc = MCMC(kernel, num_warmup=1_000, num_samples=num_samples)
mcmc.run(key, y=y)
mcmc.print_summary()
samples = mcmc.get_samples()
```


**Posterior Distribution over Regression Parameters**

```python
posterior_mu = samples["weight"] * u + samples["bias"]
mean_ = jnp.mean(posterior_mu, axis=0)
hpdi_mu = hpdi(posterior_mu, quantile=0.90)
```


**Predictive Posterior Distribution**


$$
\begin{aligned}
\text{Posterior Samples}: && &&
\boldsymbol{\alpha}_n &\sim p(\boldsymbol{\alpha}|y) \\
\text{Data Likelihood}: && &&
y_n^* &\sim p(y^*_n|\boldsymbol{\alpha}_n)
\end{aligned}
$$

```python
def predict(rng, post_samples, model, *args, **kwargs):
  model = handlers.seed(handlers.condition(model, post_samples), rng)
  model_trace = handlers.trace(model).get_trace(*args, **kwargs)
  return model_trace["y"]["value"]

```