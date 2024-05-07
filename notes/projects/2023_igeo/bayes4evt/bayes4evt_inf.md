---
title: Preliminary Results
subject: Misc. Notes
short_title: Inference
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


> An overview of the methods used to find the best parameters.

## Inference

In general, there are three different ways to get the parameters.



***
### Point Estimates

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
#### MLE Estimation

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


***
#### MAP Estimation

The MAP estiamtion is very similar to the MLE estimation except that we put priors on the parameters.

$$
\boldsymbol{L}_\text{MAP}(\boldsymbol{\theta}) = \underset{\boldsymbol{\theta}}{\text{argmin}} \hspace{2mm}
\sum_{n=1}^N\log p(y_n|\boldsymbol{\theta})  + 
\log p(\boldsymbol{\theta})
$$ (eq:madrid-gevd-map-loss)

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
### Approximate Inference


***
#### Laplace Approximation (TODO)

***
#### SVI (TODO)


***
### Sampling

***
#### MCMC (TODO)