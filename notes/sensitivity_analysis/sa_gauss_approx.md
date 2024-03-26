---
title: Sensitivity Analysis - Gaussian Approximation
subject: Misc. Notes
short_title: Gaussian Approximation
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

We are given some approximations of inputs"

$$
\begin{aligned}
\text{Uncertainty Inputs}: && &&
\boldsymbol{x} &\sim \mathcal{N}(\boldsymbol{\mu_x},\boldsymbol{\Sigma_x}) \\
\text{Model}: && &&
\boldsymbol{x} &= \boldsymbol{\mu_x} + \boldsymbol{\varepsilon_x}, && && 
\boldsymbol{\varepsilon_x} \sim \mathcal{N}(0,\boldsymbol{\Sigma_x})
\end{aligned}
$$

We have the data likelihood given 

$$
\boldsymbol{y}\sim p(\boldsymbol{y}|\boldsymbol{x},\boldsymbol{\theta})
$$


***
## Formulation

We assume that this predictive density is given by a Gaussian distribution
$$
\begin{aligned}
\boldsymbol{y} &\sim 
p(\boldsymbol{y}|\boldsymbol{x},\boldsymbol{\theta}) \approx 
\mathcal{N}
\left(\boldsymbol{y}\mid \boldsymbol{\mu_y}, \boldsymbol{\Sigma_y}\right)
\end{aligned} \\
$$
where $\boldsymbol{h_\mu}$ and $\boldsymbol{h_\sigma}$ is the predictive mean and variance respectively.
For example, this predictive mean could be a basis function, a non-linear function or a neural network.
The predictive variance function could be constant or a simple linear function.

$$
\begin{aligned}
\text{Predictive Mean}: && &&
\boldsymbol{\mu_y} &=
\boldsymbol{h_\mu}(\boldsymbol{x};\boldsymbol{\theta}), && &&
 \boldsymbol{h_\mu}: \mathbb{R}^{D_x}\times\mathbb{\Theta}\rightarrow\mathbb{R}^{D_y}\\
\text{Predictive Variance}: && &&
\boldsymbol{\Sigma_y} &=
\boldsymbol{h_{\sigma^2}}(\boldsymbol{x};\boldsymbol{\theta}), && &&
 \boldsymbol{h_{\sigma^2}}: \mathbb{R}^{D_x}\times\mathbb{\Theta}\rightarrow\mathbb{R}^{D_y\times D_y}
\end{aligned}
$$

We have ways to estimate these quantities as follows using the law of iterated expectations.

$$
\begin{aligned}
\boldsymbol{\mu}_{\boldsymbol{y}}(\boldsymbol{x};\boldsymbol{\theta}) &=
\mathbb{E}_{\boldsymbol{x}} \left[ \boldsymbol{h_\mu}(\boldsymbol{x},\boldsymbol{\theta})\right] \\
\boldsymbol{\sigma}_{\boldsymbol{y}}(\boldsymbol{x};\boldsymbol{\theta}) &=
\mathbb{E}_{\boldsymbol{x}} \left[ \boldsymbol{h_{\sigma^2}}(\boldsymbol{x},\boldsymbol{\theta})\right]  +
\mathbb{E}_{\boldsymbol{x}} \left[ \boldsymbol{h_\mu}^2(\boldsymbol{x},\boldsymbol{\theta})\right] -
\mathbb{E}_{\boldsymbol{x}}^2 \left[ \boldsymbol{h_\mu}(\boldsymbol{x},\boldsymbol{\theta})\right]
\end{aligned}
$$

In integral form, we can write this as:
$$
\begin{aligned}
\boldsymbol{\mu}_{\boldsymbol{y}}(\boldsymbol{x};\boldsymbol{\theta}) &=
\int \boldsymbol{\mu_x}(\boldsymbol{x},\boldsymbol{\theta}) p(\boldsymbol{x})d\boldsymbol{x} \\
\boldsymbol{\sigma}_{\boldsymbol{y}}(\boldsymbol{x};\boldsymbol{\theta}) &=
\int \boldsymbol{h_{\sigma^2}}(\boldsymbol{x},\boldsymbol{\theta}) p(\boldsymbol{x})d\boldsymbol{x}  +
\int \boldsymbol{h_\mu}^2(\boldsymbol{x},\boldsymbol{\theta})p(\boldsymbol{x})d\boldsymbol{x}  -
\left[\int \boldsymbol{\mu_x}(\boldsymbol{x},\boldsymbol{\theta}) p(\boldsymbol{x})d\boldsymbol{x}\right]^2
\end{aligned}
$$


***
## Taylor Approximation

* Source - [wiki](https://en.wikipedia.org/wiki/Delta_method) | [bookdown](https://bookdown.org/ts_robinson1994/10EconometricTheorems/dm.html)

$$
\begin{aligned}
\mathbb{E}_{\boldsymbol{x}} \left[ \boldsymbol{h_\mu}(\boldsymbol{x},\boldsymbol{\theta})\right] 
&\approx
\boldsymbol{h_\mu}(\boldsymbol{\mu_x},\boldsymbol{\theta}) + 
\frac{1}{2}\text{Tr}\left[
  \partial^2\boldsymbol{h_\mu}(\boldsymbol{\mu_x},\boldsymbol{\theta})
  \boldsymbol{\Sigma_x}
\right] \\
\mathbb{E}_{\boldsymbol{x}} \left[ \boldsymbol{h_\mu}(\boldsymbol{x},\boldsymbol{\theta})\right] 
&\approx
\boldsymbol{h_\mu}(\boldsymbol{\mu_x},\boldsymbol{\theta}) + 
\frac{1}{2}\text{Tr}\left[
  \partial^2\boldsymbol{h_\mu}(\boldsymbol{\mu_x},\boldsymbol{\theta})
  \boldsymbol{\Sigma_x}
\right] \\
\mathbb{E}_{\boldsymbol{x}} \left[ \boldsymbol{h_\mu}(\boldsymbol{x},\boldsymbol{\theta})\right] 
&\approx
\boldsymbol{h_\mu}(\boldsymbol{\mu_x},\boldsymbol{\theta}) + 
\frac{1}{2}\text{Tr}\left[
  \partial^2\boldsymbol{h_\mu}(\boldsymbol{\mu_x},\boldsymbol{\theta})
  \boldsymbol{\Sigma_x}
\right] 
\end{aligned}
$$

***
## Moment-Matching
