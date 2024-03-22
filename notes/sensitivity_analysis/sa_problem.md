---
title: Sensitivity Analysis - Problem Formulation
subject: Misc. Notes
short_title: Problem Formulation
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


## Context

### Modeling

Image, we have some data

$$
\begin{aligned}
\mathcal{D} = \left\{ \boldsymbol{x}_n,\boldsymbol{y}_n\right\}_{n=1}^N =
\left\{ \boldsymbol{X},\boldsymbol{Y}\right\}
\end{aligned}
$$

We are interested in finding the joint distribution which maps the co-variates, x, to the observations, y.
We can decompose the joint distribution as follows

$$
\begin{aligned}
\text{Joint Distribution}: && &&
p(\boldsymbol{x}_{1:N},\boldsymbol{y}_{1:N},\boldsymbol{\theta}) &=
p(\boldsymbol{\theta})\prod_{n=1}^Np(\boldsymbol{y}_n|\boldsymbol{x}_n,\boldsymbol{\theta})
\end{aligned}
$$

This can be done by finding the posterior parameters

$$
\begin{aligned}
\text{Posterior}: && &&
p(\boldsymbol{\theta}|\mathcal{D}) &= \frac{1}{Z}p(\boldsymbol{Y}|\boldsymbol{X},\boldsymbol{\theta})p(\boldsymbol{\theta})
\end{aligned}
$$

There are a myriad of methods to find the parameters.
For example we could use some conjugate methods if the functions are linear or we can use approximate inference or sampling.
Irrespective of the method, we will have some set of parameters that we think are good for the model.

***
### Post-Modeling Analysis

However, assuming we have found the parameters, we are interested in performing *sensitivity analysis* which is whereby we take a distribution of interest of our input co-variates, x, and we perform some analysis on the generated outputs.
$$
\begin{aligned}
\text{Co-Variates}: && &&
\boldsymbol{x}^*_n &\sim p(\boldsymbol{x}^*) \\
\text{Posterior Parameters}: && &&
\boldsymbol{\theta}_n &\sim p(\boldsymbol{\theta}|\mathcal{D}) \\
\text{Data Likelihood}: && &&
\boldsymbol{y}_n &\sim p(\boldsymbol{y}_n|\boldsymbol{x}^*_n,\boldsymbol{\theta}_n)
\end{aligned}
$$

So, our new problem is to find some sort of expectation over our data likelihood given our model parameters

$$
\begin{aligned}
\text{Sensitivity Analysis}: && &&
\mathbb{E}_{\boldsymbol{x}^*}
\left[\mathbb{E}_{\boldsymbol{\theta}}
\left[ 
    p(\boldsymbol{y}|\boldsymbol{x}^*,\boldsymbol{\theta}) 
\right] 
\right] &= \int_{\boldsymbol{x}^*}\int_{\boldsymbol{\theta}}
p(\boldsymbol{y}|\boldsymbol{x}^*,\boldsymbol{\theta})
d\boldsymbol{\theta}d\boldsymbol{x}^*
\end{aligned}
$$

In general, there are two ways we can tackle this: 1) deterministic inference and 2) stochastic inference.
Deterministic inference is well known within the community as approximations.
Stochastic inference is more known as MonteCarlo inference or some variant of.


***
## Exact Inference

This is the case when we have linear methods and simple, conjugate distributions.
If these two conditions are satisfied, then we can do a series of linear algebra tricks and identities to construct a closed-form solution to this integral problem. 

***
### Example

In this example, we can predict the mean and the covariance under a linear Gaussian model.

$$
\begin{aligned}
\text{Prior Distribution}: && &&
\boldsymbol{x} &\sim \mathcal{N}(\mathbf{x}\mid \mathbf{m},\mathbf{S}) \\
\text{Data Likelihood}: && &&
\boldsymbol{y} &\sim \mathcal{N}(\mathbf{y}\mid \boldsymbol{h}(\mathbf{x},\boldsymbol{\theta}), \mathbf{Q}) \\
\text{Linear Operator}: && &&
\boldsymbol{h}(\mathbf{x},\boldsymbol{\theta}) &= \mathbf{Wx} + \mathbf{b}
\end{aligned}
$$

**Parameters**

```python
# input covariates
m: Array["Dx"] = ...       # prior mean covariate, x
S: Array["Dx Dx"] = ...    # prior covariance covariate, x
# parameters
W: Array["Dy Dx"] = ...    # weight matrix
b: Array["Dy"] = ...       # bias vector
Q: Array["Dy Dy"] = ...    # observation covariance matrix
```


**Prediction Function**
$$
\begin{aligned}
p(\mathbf{y}) &= \int \mathcal{N}(\mathbf{x}\mid \mathbf{m},\mathbf{S})
\mathcal{N}(\mathbf{y}\mid \mathbf{Wx} + \mathbf{b}, \mathbf{Q}) \\
&= \mathcal{N}(\mathbf{y}\mid \mathbf{Fm}, \mathbf{FSF}^T+\mathbf{Q})
\end{aligned}
$$

```python
y_mu: Array["Dy"] = F @ m + b
y_cov: Array["Dy Dy"] = F @ S @ F.T + Q
```

**Sample Function**

$$
\begin{aligned}
\mathbf{x}^{(n)} &\sim  \mathcal{N}(\mathbf{x}\mid \boldsymbol{\mu}_\mathbf{x},\boldsymbol{\Sigma}_\mathbf{x}) \\
\boldsymbol{\mu}_y^{(n)} &= \boldsymbol{h}(\mathbf{x}^{(n)},\boldsymbol{\theta}) \\
\boldsymbol{y}^{(n)}&\sim \text{MultivariateNormal}(\boldsymbol{\mu}_y^{(n)}, \boldsymbol{\Sigma}_y)
\end{aligned}
$$

```python
# create covariate distribution
mvn_dist_x: Dist = MVM(μ_x, σ_x)
# sample covariates
n_samples: int = 100
seed: RNGKey = RNGKey(123)
x_samples: Array["Nx Dx"] = sample(dist=mvn_dist_x, seed=seed, shape=(n_samples,))
# calculate variables
μ_y: Array["Nx Dy"] = einsum("ND,D->ND", x, w) + b
σ_y: Array["Dy Dy"] = ...
# create observation distribution
mvn_dist_y: Dist = BatchedMVM(μ_y, σ_y)
# sample observations
n_samples: int = 100
seed: RNGKey = RNGKey(123)
y_samples: Array["Ny Nx Dy"] = sample(dist=mvn_dist_y, seed=seed, shape=(n_samples,))
```


***
## Determinstic Inference

In general, we can do deterministic inference using 

Some example methods include:
* Linearization, i.e., Taylor Expansion
* Unscented Transformation, i.e., Sigma Points
* Moment-Matching, i.e., GH-Quadrature, Bayesian Quadrature, etc.

### Example

$$
\begin{aligned}
\boldsymbol{y}_n &= \boldsymbol{h}(\boldsymbol{x}_n,\boldsymbol{\theta}) + \boldsymbol{\varepsilon}_n, && &&
\boldsymbol{\varepsilon}_n\sim\mathcal{N}(0,\mathbf{Q})
\end{aligned}
$$

***
## Stochastic Inference

Some example methods include:
* Sequential Monte Carlo
* Ensemble Points
