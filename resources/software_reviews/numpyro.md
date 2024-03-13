---
title: Numpyro Software
subject: AI 4 Attribution
short_title: Numpyro Overview
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
    PDEs: Partial Differential Equations
    RHS: Right Hand Side
    TLDR: Too Long Did Not Read
    SSP: Shared Socioeconomic Pathways
    CDS: Climate Data Store
---



## PPL

[Numpyro](https://num.pyro.ai/en/stable/index.html) | [Github](https://github.com/pyro-ppl/numpyro)


***

### Example: Bayesian Regression



**Build a Model**

```python
def model(u: Array, y: Optional[Array]=None):
    # sample parameters
    bias = numpyro.sample("b", dist.Normal(0.0, 0.2))
    weight = numpyro.sample("w", dist.Normal(0.0, 0.5))
    sigma = numpyro.sample("sigma", dist.Exponential(1.0))
    # calculate formula
    mu = weight * u + bias
    # data likelihood
    numpyro.sample("obs", dist.normal(mu, sigma), obs=y)
```

**Prior Predictive Distribution**

```python
prior_predictive = Predictive(model, num_sample=100)
prior
```

**Perform Inference**

```python
kernel = NUTS(model)
num_samples = 2_000
mcmc = MCMC(kernel, num_warmup=1_000, num_samples=num_samples)
mcmc.run(key, u=u, y=y)
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

```python
prior_predictive = Predictive(model, num_sample=100)
prior
```

*** 

### Example: MLE vs MAP vs MCMC

```python
```

***

### Example: Variational Inference


**Prior**

$$
\begin{aligned}
\text{Prior}: && &&
\theta &\sim p(\theta) \\
\text{Data Likelihood}: && &&
y &\sim p(y|\theta)
\end{aligned}
$$

```python
def model(data):
    f = numpyro.sample("latent_fairness", dist.Beta(10, 10))
    with numpyro.plate("N", data.shape[0] if data is not None else 10):
        numpyro.sample("obs", dist.Bernoulli(f), obs=data)
```


**Variational Posterior**

$$
q \sim q(\mu, \sigma)
$$

```python
def guide(data):
    alpha_q = numpyro.param("alpha_q", 15., constraint=constraints.positive)
    beta_q = numpyro.param("beta_q", lambda rng_key: random.exponential(rng_key),
                           constraint=constraints.positive)
    numpyro.sample("latent_fairness", dist.Beta(alpha_q, beta_q))
```


**Inference**

$$
\boldsymbol{\phi}^* = \underset{\boldsymbol{\phi}}{\text{argmin}} \hspace{2mm} \text{ELBO}(\boldsymbol{\phi};y)
$$

```python
optimizer = numpyro.optim.Adam(step_size=5e-5)
svi = SVI(model, guide, optimizer, loss=Trace_ELBO())
svi_result = svi.run(random.PRNGKey(0), 2000, data)
params = svi_result.params
```

**Best Parameters**






**Approximate Posterior**


```python
# use guide to make predictive
predictive = Predictive(model, guide=guide, params=params, num_samples=1000)
samples = predictive(random.PRNGKey(1), data=None)
```

**Posterior Samples**

```python
predictive = Predictive(guide, params=params, num_samples=1000)
posterior_samples = predictive(random.PRNGKey(1), data=None)
```

**Posterior Predictive Samples**

```python
# use posterior samples to make predictive
predictive = Predictive(model, posterior_samples, params=params, num_samples=1000)
samples = predictive(random.PRNGKey(1), data=None)
```
