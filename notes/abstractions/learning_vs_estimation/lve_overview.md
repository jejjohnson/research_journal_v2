---
title: Learning vs Estimation
subject: ML4EO
short_title: Overview
authors:
  - name: J. Emmanuel Johnson
    affiliations:
      - CSIC
      - UCM
      - IGEO
    orcid: 0000-0002-6739-0053
    email: juanjohn@ucm.es
license: CC-BY-4.0
keywords: notation
---

In general, there are two concrete tasks that we may wish to do:
1. Estimate some quantity of interest(QoI) given some observations and parameters.
2. Learn the parameters of a model given some observations.

## Estimation

We are interested in the estimation problem.
So ultimately, we have some QoI, $u$, we are interested in estimating given some observations, $y$, and parameters $\theta$. 
$$
\boldsymbol{u}^* = \underset{\boldsymbol{u}}{\text{argmin}}
\hspace{2mm}
\boldsymbol{J}(\boldsymbol{u};\boldsymbol{y},\boldsymbol{\theta})
$$
The key is that we have an objective function, $J$, which validates whether or not we have converged to the best estimated value $u^*$.
This formulation comes in many names, e.g., Inverse problems, Data assimilation.
Despite the term *inverse*, it could be a simple identity

$$
\begin{aligned}
\text{Identity}: && &&
\boldsymbol{y} &= \boldsymbol{u} + \varepsilon \\
\text{Linear Transformation}: && &&
\boldsymbol{y} &= \mathbf{w}\boldsymbol{u} + \mathbf{b} + \varepsilon \\
\text{Non-Linear Transformation}: && &&
\boldsymbol{y} &=\boldsymbol{f}(\boldsymbol{u};\boldsymbol{\theta}) + \varepsilon \\
\end{aligned}
$$

***
### Example: Bayesian Posterior

An example might be the posterior

$$
p(u|y,\theta) \propto p(y|u)p(u|\theta)p(\theta)
$$

So we can use this as a log

$$
J(u;y,\theta) = \log p(y|u) + \log p(u|\theta) + \log p(\theta)
$$


***
## Learning

$$
\boldsymbol{\theta}^* = \underset{\boldsymbol{\theta}}{\text{argmin}}
\hspace{2mm}
\boldsymbol{L}(\boldsymbol{\theta};\boldsymbol{u},\boldsymbol{y})
$$

***
### Example: Bayesian Posterior

An example might be the posterior

$$
p(u|y,\theta) \propto p(y|u)p(u|\theta)p(\theta)
$$

So we can use this as a log

$$
L(\theta;y,u) = \log p(y|u) + \log p(u|\theta) + \log p(\theta)
$$


## Cascading Objectives

We treated learning and estimation as two separate cases. 
However, we often need to do them in tandem or perhaps one after the other.
I call this cascade of objectives because the solution to one objective might be useful within another objective. 


## Examples

### [Density Estimation](./lve_density_estimation.md)

### [Predictions](./lve_predictions.md)

### [Time Series](./lve_predictions.md)

