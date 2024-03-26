---
title: Gaussian Markov Model
subject: Jax Approximate Ocean Models
# subtitle: How can I estimate the state AND the parameters?
short_title: Gauss-Markov Model
authors:
  - name: J. Emmanuel Johnson
    affiliations:
      - CNRS
      - MEOM
    orcid: 0000-0002-6739-0053
    email: jemanjohnson34@gmail.com
license: CC-BY-4.0
keywords: data-assimilation, open-science
---


## Formulation

$$
\begin{aligned}
\text{Initial Condition}: && &&
\boldsymbol{z}_0 &\sim 
\mathcal{N}(\boldsymbol{z}_0|\boldsymbol{\mu}_0,\boldsymbol{\Sigma}_0) \\
\text{Dynamical Model}: && &&
\boldsymbol{z}_t &\sim  
\mathcal{N}(\boldsymbol{z}_t|\boldsymbol{f}(\boldsymbol{z}_{t-1},\boldsymbol{\theta}),\boldsymbol{\Sigma_z}) \\
\text{Measurement Model}: && &&
\boldsymbol{y}_t &\sim 
\mathcal{N}(\boldsymbol{y}_t|\boldsymbol{h}(\boldsymbol{z}_{t},\boldsymbol{\theta}),\boldsymbol{\Sigma_y}) \\
\end{aligned}
$$


**Assumptions**:
* Transition Function, $f$, and measurement function, $h$, are known.
* Gaussian system and measurement noise
* Gaussian distributions everywhere

## Core Operations

* Posterior
* Filtering - Prediction + Correction
* Marginal Likelihood
* Posterior Samples


## Bayesian


### Joint Distribution

This represents how we decompose the time series.
We use the Markov property that states that every subsequent prediction at time step $t+1$ is independent of any previous time steps, $t-\tau$.

$$
p(\boldsymbol{z}_{0:T},\boldsymbol{y}_{1:T}) = 
\mathcal{N}\left(\boldsymbol{z}_0|\boldsymbol{\mu}_0,\boldsymbol{\Sigma}_0\right)
\prod_{t=1}^T
\mathcal{N}\left(\boldsymbol{y}_t|\boldsymbol{h}(\boldsymbol{z}_t;\boldsymbol{\theta}),\boldsymbol{\Sigma_y}\right)
\mathcal{N}\left(\boldsymbol{z}_t|\boldsymbol{f}(\boldsymbol{z}_{t-1};\boldsymbol{\theta}),\boldsymbol{\Sigma_z}\right)
$$

We see that this factorizes.

***
### Prediction Step

$$
p(\boldsymbol{z}_t|\boldsymbol{y}_{1:t-1}) = 
\int\mathcal{N}(\boldsymbol{z}_t|\boldsymbol{f}(\boldsymbol{z}_{t-1};\boldsymbol{\theta}),\boldsymbol{\Sigma_z})
p(\boldsymbol{z}_{t-1}|\boldsymbol{y}_{1:t-1})d\boldsymbol{z}_{t-1}
$$

We can use a generic set of equations

$$
\begin{aligned}
\text{Predict}: && &&
p(\boldsymbol{z}_t) &= 
\mathcal{N}(\boldsymbol{z}_t|\boldsymbol{\mu}_{t|t-1},\boldsymbol{\Sigma}_{t|t-1})
\end{aligned}
$$

***
### Correction Step

$$
p(\boldsymbol{z}_t|\boldsymbol{y}_{1-t};\boldsymbol{\theta}) = 
\frac{1}{\boldsymbol{E}(\boldsymbol{\theta})}
\mathcal{N}(\boldsymbol{y}_t|\boldsymbol{h}(\boldsymbol{z}_t;\boldsymbol{\theta}),\boldsymbol{\Sigma_y})
p(\boldsymbol{z}_t|\boldsymbol{y}_{1:t-1})
$$

For Gauss-Markov models, we can write a generic set of equations to calculate the analysis step.

$$
\begin{aligned}
\text{Predictive Mean}: && &&
\boldsymbol{\mu}_{t|t}^{\boldsymbol{z}} &= 
\boldsymbol{\mu}_{t|t-1}^{\boldsymbol{z}} + 
\boldsymbol{\Sigma}_{t|t-1}^{\boldsymbol{zy}} 
\left(\boldsymbol{\Sigma}_{t|t-1}^{\boldsymbol{y}}  \right)^{-1}
(\boldsymbol{z}_t - \boldsymbol{\mu}_{t|t-1}^{\boldsymbol{y}}) \\
\text{Predictive Covariance}: && &&
\boldsymbol{\Sigma}_{t|t}^{\boldsymbol{z}} &= 
\boldsymbol{\Sigma}_{t|t-1}^{\boldsymbol{z}} + 
\boldsymbol{\Sigma}_{t|t-1}^{\boldsymbol{zy}} 
\left(\boldsymbol{\Sigma}_{t|t-1}^{\boldsymbol{y}}  \right)^{-1}
\boldsymbol{\Sigma}_{t|t-1}^{\boldsymbol{yz}} \\
\end{aligned}
$$

This is expressed in terms of means and (cross)-covariances.
This generic set of equations can be used to understand almost all filtering methods.
For example:
* Linear + Conjugate -> Linear Kalman Filter
* Linearization via Taylor Approximations -> Extended Kalman Filter
* Sigma Points -> Unscented Kalman Filter
* Cubature Points -> Cubature Kalman Filter
* Moment Matching -> Assumed Density Filter

***
### Marginal Likelihood

In the correction step, we see the normalization constant, $\boldsymbol{E}(\boldsymbol{\theta})$.

$$
\boldsymbol{E}(\boldsymbol{\theta}) = 
p(\boldsymbol{y}_{t}|\boldsymbol{y}_{1:t-1};\boldsymbol{\theta}) = 
\int \mathcal{N}(\boldsymbol{y}_t|\boldsymbol{h}(\boldsymbol{z}_t;\boldsymbol{\theta}),\boldsymbol{\Sigma_y})
p(\boldsymbol{z}_t|\boldsymbol{y}_{1:t-1})d\boldsymbol{z}_t
$$


***
### Smoothing

$$
p(\boldsymbol{z}_t|\boldsymbol{y}_{1:T}) = ...
$$

***
## Exact Inference

There are very few circumstances when we can get exact inference.

### **Observation Operator Encoder**
$$
\begin{aligned}
\text{Forward Transform}: && &&
\boldsymbol{z}_t &= \boldsymbol{T}(\boldsymbol{y}_t;\boldsymbol{\theta}) \\
\text{Inverse Transform}: && &&
\boldsymbol{y}_t &= \boldsymbol{T}^{-1}(\boldsymbol{z}_t;\boldsymbol{\theta}) \\
\end{aligned}
$$

This can be seen from the [[de Bézenac et al (2020)](https://proceedings.neurips.cc/paper/2020/hash/1f47cef5e38c952f94c5d61726027439-Abstract.html)]

The joint distribution will be:

$$
p(\boldsymbol{z}_{0:T},\boldsymbol{y}_{1:T}) = 
\mathcal{N}\left(\boldsymbol{z}_0|\boldsymbol{\mu}_0,\boldsymbol{\Sigma}_0\right)
\prod_{t=1}^T
\mathcal{N}\left(\boldsymbol{y}_t|\boldsymbol{T}^{-1}(\boldsymbol{z}_t;\boldsymbol{\theta}),\boldsymbol{\Sigma_y}\right)
\mathcal{N}\left(\boldsymbol{z}_t|\boldsymbol{f}(\boldsymbol{z}_{t-1};\boldsymbol{\theta}),\boldsymbol{\Sigma_z}\right)
$$

```python
# initial state prior
mu_0: Array["Dy"] = param("mu_0", init_value=...)
Sigma_0: Array["Dy Dy"] = param("Sigma_0", init_value=..., constrains=positive)
z0: Array["Dy"] = sample("z0", Normal(mu_0, Sigma_0))

# transition prior
F: Array["Dy Dy"] = param("F", init_value=...)
b: Array["Dy"] = param("b", init_value=...)
mu_z = F @ z0 + b
Sigma_z: Array["Dy Dy"] = param("Sigma_z", init_value=..., constrains=positive)
z: Array["Dy"] = sample("z", Normal(mu_z, Sigma_z))

# transition prior
flow = NSF(features=y.shape, *args, **kwargs)
obs: Array["Dy"] = sample("obs", flow(z), obs=y)
```




***
## Parameter Estimation



The assumptions can be any combination of the the following:
* We have an unknown dynamics model, $f$, and and unknown measurement model, $h$.
* We have an unknown dynamics and measurement model parameters, $\boldsymbol{\theta}$.
* We have an unknown initial distribution, $p(\boldsymbol{z}_0|\boldsymbol{\theta})$
* We have unknown Gaussian system and measurement noise, $\boldsymbol{\Sigma_z}$, $\boldsymbol{\Sigma_y}$

In the first case of parameter estimation, we assume that we do not know

$$
\boldsymbol{L}(\boldsymbol{\theta}) :=
\log p(\boldsymbol{y}_{1:T};\boldsymbol{\theta}) = 
\sum_{t=1}^T\log p(\boldsymbol{y}_{t}|\boldsymbol{y}_{1:t-1};\boldsymbol{\theta})
$$

We can decompose this expression further

$$
p(\boldsymbol{y}_{t}|\boldsymbol{y}_{1:t-1};\boldsymbol{\theta}) = 
\int \mathcal{N}(\boldsymbol{y}_t|\boldsymbol{h}(\boldsymbol{z}_t),\boldsymbol{\Sigma_y})
p(\boldsymbol{z}_t|\boldsymbol{y}_{1:t-1})d\boldsymbol{z}_t
$$

Unfortunately, analytical expressions for the filtering distribution, $p(\boldsymbol{z}_t|\boldsymbol{y}_{1:t})$ and thus the data log-likelihood $\boldsymbol{L}(\boldsymbol{\theta})$ are only available for a small class of SSMs like the linear-Gaussian and discrete SSMs.
Thus we need to use approximate filtering distributions to estimate the log-likelihood.



***
## State Estimation

**Assumptions**:
* Transition Function, $f$, and measurement function, $h$, are known.
* Gaussian system and measurement noise


This is basically how we are able to fil

**Deterministic Inference**
* Approximate Model ($f$,$h$) - Linearization, Sigma Points
* Approximate Integral

**Stochastic Inference**:
* Ensembles
* Monte Carlo / Particle Filter