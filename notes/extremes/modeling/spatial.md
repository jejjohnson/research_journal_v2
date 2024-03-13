---
title: Spatiotemporal Effects
subject: AI 4 Attribution
short_title: IV - Spatiotemporal
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
> We will incorporate spatiotemporal effects into our model assumptions. 
> We will use nonparametric Gaussian process models  to account for the spatial and temporal autocorrelations present within the data. 
> We assume that each of the parameters of the distribution are a random field given which is the result of an underlying latent spatial process. 
> Then, we can say that the extreme values are conditionally independent of the parameters of the data likelihood. 
> These latent models will be used to parameterize the data likelihood parameters. We can include the covariates within the kernel function (Deep Kernel Learning) or we can include them within the mean function. 
> The heterogeneity can be accounted for by having a separate GP for the scale parameter for the data likelihood. We can use approximations like inducing points or spectral approximations to deal with the large number of spatial samples present.

## Questions

> How do we go beyond the univariate site-per-site or spatially aggregated modeling? 

> Can we take into account the spatial pairwise dependence among different sites?


***
## Assumptions

The idea is that standard EVT methods can greatly benefit from spatial considerations.
We assume that these spatial methods can map risk at an individual location and borrow strength of spatial neighbours which would be helpful to estimate rare-event probabilities.
We assume that this spatial dependence consideration is necessary and valid for inference.

**Conditional Independence**.
The extreme values, $y$, are independent given the distribution parameters.

**Process Layer**.
The parameters, $\boldsymbol{\theta}$, of the distribution, $p(\cdot)$, are random fields and result from an unobservable latent spatiotemporal process.


***
## Model

**Data Layer**.
We make the following assumption for the data layer.
$$
\begin{aligned}
\text{Data} &:= p(\text{Data}|\text{Process},\text{Covariates},\text{Parameters})
\end{aligned}
$$
More concretely, the extreme observations, $y$, stem from a conditional distribution which is a distribution parameterized by some process, $\theta$, and the hyperparameters of the process, $\alpha$.
$$
y_n \sim p(y_n|\boldsymbol{\theta}_n,\boldsymbol{x}_n,\boldsymbol{\alpha})
$$

**Process Layer**.
We assume that the process layer has the form:
$$
\begin{aligned}
\text{Process} &:=p(\text{Process}|\text{Parameters})
\end{aligned}
$$
More concretely, we believe the parameters of the data distribution are parameters by some covariates and hyperparameters.
$$
\boldsymbol{\theta}_n \sim p(\boldsymbol{\theta}_n|\boldsymbol{x}_n,\boldsymbol{\alpha})
$$
For example, we could have the following Mean Function:
$$
\mu_n = \boldsymbol{\mu}(\boldsymbol{x},\mathbf{s};\boldsymbol{\theta})= b + \mathbf{W}_1^\top \mathbf{s} + \mathbf{W}_2^\top\boldsymbol{x} + 
\text{MVN}\left(0,\alpha_0 \exp \left(-\alpha_1 ||\mathbf{s}_i - \mathbf{s}_j||^2_2 \right) \right)
$$
where the hyperparameters are $\boldsymbol{\alpha} = \{b, \mathbf{w}_1,\mathbf{W}_2, \alpha_1, \alpha_2 \}$.

## Previous Work

:::{seealso} Gaussian Processes
:class: dropdown

Gaussian Processes
- Exact
- Inference - MLE, MAP, Variational, MCMC
- Scale (Hardware) - Cola, GPUs, Parallel GPUs
- Scale (Moment)- Inducing Points
- Covariates - Additive, Seperable, Mixture Kernels
- Noise - Heteroskedastic
- Physics Informed - Deep Kernel Learning, Custom Mean Function
- Scale (Spectral) - RFF
- Scale (Time Series) - Markovian, Variational Markovian
- Uncertain Inputs - MC, Taylor (1st, 2nd Order), Unscented, Moment-Matching, GPLVM

Heteroskedastic GP
- Pymc ex - latent, sparse latent, correlated sparse latent - [](https://www.pymc.io/projects/examples/en/latest/gaussian_processes/GP-Heteroskedastic.html)
- GPFlow Ex - hetero example - [](https://gpflow.github.io/GPflow/develop/notebooks/advanced/heteroskedastic.html)
- GPFlow - Custom Likelihood Noise Functions - [](https://gpflow.github.io/GPflow/develop/notebooks/advanced/varying_noise.html)
- Priors 4 GPs - [](https://github.com/stan-dev/stan/wiki/Prior-Choice-Recommendations#priors-for-gaussian-processes)


:::

:::{seealso} **Max-Stable Processes**
:class: dropdown

> These papers adapt asymptotic results for multivariate extremes.
> They typically measure the spatial dependence among maxima.

[Schlather & Tawn, 2003](https://doi.org/10.1093/biomet/90.1.139) | [Pereira & Andraz, 2005]( https://doi.org/10.1111/j.1467-9361.2005.00271.x) |  | [Vannitsem & Naveau, 2007](https://doi.org/10.5194/npg-14-621-2007) | 

:::

:::{seealso} **Bayesian or Latent Models**
:class: dropdown

spatial structure indirectly modeled via the EVT parameters distribution, i.e., conditioning via covariates and Bayesian Hierarchical Modeling.


**Spatial Interpolation of Return Levels in Colorado** - [Cooley et al, 2012](https://doi.org/10.1198/016214506000000780) | [Coles & Tawn, 1996](https://doi.org/10.2307/2986068)

**Downscaling Extremes** - [Vrac & Naveau, 2007]( https://doi.org/10.1029/2006WR005308)
:::

:::{seealso} **Dynamical Models**
:class: dropdown

> Auto-Regressive spatio-temporal heavy tailed processes.

[Davis & Mikosch, 2009](https://doi.org/10.1007/978-3-540-71297-8_8)

:::

:::{seealso} **Gaussian Anamorphasis**
:class: dropdown

> Transforming the field into a Gaussian one.

[Wackernagel, 2003](https://doi.org/10.1007/978-3-662-05294-5)

:::

## PseudoCode


### Gaussian Process Model

#### Mean Function

```python
def mean_function(
		X: Array["N Dx+Ds+Dt"], weight: Array["Dy Dx"], bias: Array["Dy"]
	) -> Array["Dy"]:
    # extract covariates only
    return weight @ x[:,-2:] + bias
```


```python
def gp_model(S: Array["N"], T: Array["N"], X: Array["N Dx"], Y: Array["N Dy"]):
    # mean function hyper parameters
    mean = numpyro.sample("mean", dist.Normal(0.0, prior_sigma))
    jitter = numpyro.sample("jitter", dist.HalfNormal(prior_sigma))
    
    # hyperparameters for spatial coordinates
    s_sigma = numpyro.sample("s_sigma", dist.HalfNormal(prior_sigma))
    s_rho = numpyro.sample("s_rho", dist.HalfNormal(prior_sigma))
    s_tau = numpyro.sample("s_tau", dist.HalfNormal(prior_sigma))
    kernel_s = sigma1**2 * kernels.ExpSquared(tau) * kernels.Cosine(rho1)

    # compute kernel
    kernel = kernel_s(S) + kernel_t(T) + kernel_x(X)
    # concaténate input
    input: Array["N 3"] = jnp.vstack([S,T,X])

    # sample Y according to the standard gaussian process formula
    gp = GaussianProcess(kernel, input, diag=yerr**2 + jitter, mean=mean)
    numpyro.sample("gp", gp.numpyro_dist(), obs=y)

    if y is not None:
        numpyro.deterministic("pred", gp.condition(y, true_t).gp.loc)
```