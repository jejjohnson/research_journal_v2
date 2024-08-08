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

In other words, if you have a model: you make an estimation.
If you do not have a model: you need to learn one.


**Parameter Estimation**

> We want to find the best parameters, $\boldsymbol{\theta}$, given some criteria, $\boldsymbol{L}$.

$$
\boldsymbol{\theta}^* = \underset{\theta}{\text{argmin}}\hspace{2mm}
\boldsymbol{L}(\boldsymbol{\theta})
$$


***
## Estimation

> When you already have a model, $f$, for the data and you want to estimate a value of the state, z, or a quantity of interest, u, given observations, y. Objective-based is the inverse prob formulation and the amortized-based is the skipped.

We can further separate this into two classes: 1) hard predictory and a 2) soft predictor.
A hard predictor gives an "exact" value for what you're interested in.
A soft predictor gives a score value for what you're interested in. 
The big difference is the hard predictor is looking for the value of the QoI whereas the soft predictor is weighing the possible values of the QoI.

We can further distinguish the estimation problem based on the discretization of the QoI: **continuous** and **discrete**.
If the QoI is continuous, we continue to call it an estimation task.
If the QoI is discrete, then we can label it a detection task.
Some estimation tasks include regression, variable-to-variable, denoising, and calibration.
Some detection tasks include classification, segmentation, anomaly detection, and clustering.


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

> When a model, $f$, is not available for the observations, $y$, you need learning. You need to learn the parameters for the model that you believe best fits the data.

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

The first example, we look at how we can do some density estimation for temperature values.

### [Parameter Estimation]()

### [State Estimation]()

### [Predictions](./lve_predictions.md)

### [Time Series](./lve_predictions.md)

