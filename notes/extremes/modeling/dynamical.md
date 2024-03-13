---
title: Dynamical Effects
subject: AI 4 Attribution
short_title: V - Dynamics
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
> We will make the transition from coordinate-based models to field-based models by way of state space models (SSM). 
> To start, we can examine some simple structural time series methods (STS) where we can manually fit the periodicity and covariates. 
> We can also use an entire family of Bayesian filtering methods like KF, EKF, UKF and ADF. 
> These methods will have more advanced inference methods like approximate Gaussian assumptions and Variational methods. 
> We’re also free to include other sampling methods like MCMC, ensemble methods and particle filters for inference. To deal with scalability issues, we can use convolutions for the spatial Parameterizations and simple time steppers like Euler. We can also include ODEs/PDEs to include more physics within the spatial operators. 
> In addition, we can include more traditional numerical time steppers for more stable rollouts (Autoregressive applications).




### State Space Model

Here, we assume that there is a latent variable, $\boldsymbol{z}$, which is described by a dynamical system.
We also have an optional control variable, $\boldsymbol{u}$, which could be influencing the hidden state.

$$
\begin{aligned}
\text{Initial Distribution}: && && \boldsymbol{z}_0 &\sim p(\boldsymbol{z}_0|\mathbf{\mu}_{z_0}, \mathbf{\Sigma}_{z_0})\\
\text{Transition Distribution}: && && \boldsymbol{z}_t &\sim p(\boldsymbol{z}_t|\boldsymbol{z}_{t-1},\boldsymbol{\alpha}_z) \\
\text{Emission Distribution}: && && \boldsymbol{\theta}_t &\sim p(\boldsymbol{\theta}_t|\boldsymbol{z}_t,\boldsymbol{\alpha}_\theta) \\
\text{Data Likelihood}: && && \boldsymbol{y}_t &\sim p(\boldsymbol{y}_t|\boldsymbol{\theta}_t)
\end{aligned}
$$

where $\boldsymbol{T_\theta}$ is the transition function for the latent variable, $\boldsymbol{z}_t$, and $\boldsymbol{h_\theta}$ is the emission function.
We are free to make these functions as complex as we see fit.
For example, we could have simple linear functions or more complex non-linear functions.
**Note**: these methods have many names including: statistical data assimilation, statistical inverse problem, (dynamical) latent variables, Bayesian filtering methods (Kalman, Particle), Bayesian hierarchical models, and mixed effects models.




***

## PseudoCode


### State Space Model

#### Transition + Emission Model

```python
def gaussian_hmm(x0, y=None, T=10):
    # create scan function
    def transition(z_prev, y_curr):
        # transition function
        z_curr = weight @ z_prev + bias
        z_curr = numpyro.sample('z', dist.Normal(z_curr, 0.1))
        # observation function
        y_curr = weight_obs @ z_curr + bias_obs
        y_curr = numpyro.sample('y', dist.Normal(y_curr, 1), obs=y_curr)
        return z_curr, (z_curr, y_curr)
	# create initial condition
    z0 = sample('z_0', dist.Normal(x0, 1))
    # scan through
    _, (z, y) = scan(transition, z0, y, length=T)
    return (z, y)
```


#### Inference

Here, we simply run through the model which should be the same

```python
with numpyro.handlers.seed(rng_seed=0):
    x, y = gaussian_hmm(np.arange(10.))
assert x.shape == (10,) and y.shape == (10,)
assert np.all(y == np.arange(10))
```

Here, we generate some samples using the generative process

```python
with numpyro.handlers.seed(rng_seed=0):  # generative
    x, y = gaussian_hmm()
assert x.shape == (10,) and y.shape == (10,)
assert np.all(y != np.arange(10))
```

***

## Literature

::: {seealso} State Space Models
:class: dropdown

- Structural Time Series Model - [](https://github.com/probml/sts-jax)
- KF, EKF, UKF, ADF - Dynamax - [](https://github.com/probml/dynamax) [](https://github.com/lindermanlab/ssm) [Rank-Reduced](https://arxiv.org/abs/2306.07774) | [OKF](https://github.com/ido90/Optimized-Kalman-Filter) | [Pierre Tandeo](https://github.com/ptandeo/Kalman)
- NN SSM - [](https://github.com/HazyResearch/spacetime) | [Neural-SSM](https://github.com/qu-gg/torch-neural-ssm) | [DMM Scratch](https://github.com/guxd/deepHMM)
- Ensemble KF - [](https://github.com/mchoblet/ensemblefilters) [ROAD-KF](https://github.com/ymchen0/ROAD-EnKF) | [Low-Rank 4 Elliptical](https://arxiv.org/abs/2203.05120)
- Sequential Monte Carlo - [](https://github.com/nchopin/particles) [Parallel Particle Smoothing](https://github.com/AdrienCorenflos/parallel-ps) [Kalman and Gibbs Samplers](https://github.com/AdrienCorenflos/aux-ssm-samplers) [Parallel Sqrt-Root Filters](https://github.com/EEA-sensors/sqrt-parallel-smoothers)
- Neural ODEs - [](https://github.com/pnkraemer/probdiffeq) [](https://sebastiancallh.github.io/post/neural-ode-weather-forecast/) 

:::
