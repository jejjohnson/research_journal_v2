---
title: Probabilistic PCA
subject: Machine Learning for Earth Observations
short_title: PPCA + Missing
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


## Context

We are given some measurements, $\boldsymbol{y}$, which are sparse.

$$
\begin{aligned}
\text{Dataset}: && &&
\mathcal{D}_{tr} = \left\{ \boldsymbol{y}_n\right\}_{n=1}^{N}, && &&
\boldsymbol{y}_n\in\mathbb{R}^{D}
\end{aligned}
$$

**Assumption**

$$
\begin{aligned}
\text{Measurements}: && &&
\boldsymbol{y} &= \boldsymbol{y}(\boldsymbol{s},t), &&  &&
\boldsymbol{y}:\mathbb{R}^{D_s}\times\mathbb{R}^+ \rightarrow\mathbb{R}^{D_y} \\
\text{True Signal}: && &&
\boldsymbol{u} &= \boldsymbol{u}(\boldsymbol{s},t), &&  &&
\boldsymbol{u}:\mathbb{R}^{D_s}\times\mathbb{R}^+ \rightarrow\mathbb{R}^{D_u} \\
\text{Latent Variable}: && &&
\boldsymbol{z} &= \boldsymbol{z}(\boldsymbol{s},t), &&  &&
\boldsymbol{z}:\mathbb{R}^{D_s}\times\mathbb{R}^+ \rightarrow\mathbb{R}^{D_z} 
\end{aligned}
$$

**Joint Distribution**

$$
p(y,u,z,\theta) = p(y|u,\theta)p(u|z,\theta)p(z|\theta)p(\theta)
$$

**Process Relationships**

$$
\begin{aligned}
\text{Measurements}: && &&
\boldsymbol{y} &\sim p(\boldsymbol{y}|\boldsymbol{u},\boldsymbol{\theta}) \\
\text{True Signal}: && &&
\boldsymbol{u} &\sim p(\boldsymbol{u}|\boldsymbol{z},\boldsymbol{\theta}) \\
\text{Generative Model}: && &&
\boldsymbol{z} &\sim p(\boldsymbol{z}|\boldsymbol{\theta}) \\
\text{Parameters}: && &&
\boldsymbol{\theta} &\sim p(\boldsymbol{\theta}) \\
\end{aligned}
$$


**Example**

$$
\begin{aligned}
\text{Interpolation Operator}: && &&
\boldsymbol{y} &= \boldsymbol{h}(\boldsymbol{u};\boldsymbol{\theta}) + \boldsymbol{\varepsilon}_y, && &&
\boldsymbol{\varepsilon}_y \sim \mathcal{N}(\boldsymbol{0}, \boldsymbol{\Sigma_y}) \\
\text{Generative Model}: && &&
\boldsymbol{u} &= \boldsymbol{T}(\boldsymbol{z};\boldsymbol{\theta}) + \boldsymbol{\varepsilon}_u, && &&
\boldsymbol{\varepsilon}_u \sim \mathcal{N}(\boldsymbol{0}, \boldsymbol{\Sigma_u}) \\
\text{Latent Variable}: && &&
\boldsymbol{z} &= \boldsymbol{\mu_z} + \boldsymbol{\varepsilon_z}, && &&
\boldsymbol{\varepsilon_z}\sim\mathcal{N}(0,\boldsymbol{\Sigma_z}) 
\end{aligned}
$$

***
## Formulation

**Measurement Model**

$$
\boldsymbol{y} \sim 
\mathcal{N}(\boldsymbol{y}\mid\boldsymbol{h}(\boldsymbol{u},\boldsymbol{\theta}_h), \boldsymbol{\Sigma_y})
$$

where $\boldsymbol{\theta} =\{ \boldsymbol{\theta}_h, \boldsymbol{\Sigma_y}\}$ where the parameters for this model and $\boldsymbol{h}$ is the interpolation operator.

**QoI Generative Model**

$$
\boldsymbol{u} \sim 
\mathcal{N}(\boldsymbol{u}\mid\mathbf{W}\mathbf{z} + \boldsymbol{\mu}, \boldsymbol{\Sigma_u})
$$

where $\boldsymbol{\theta} =\{ \mathbf{W},\boldsymbol{\mu}, \boldsymbol{\Sigma_u}\}$ where the parameters for this model.

**Latent Variable Model**

$$
\boldsymbol{z} \sim 
\mathcal{N}(\boldsymbol{z}\mid\boldsymbol{\mu_z}, \boldsymbol{\Sigma_z})
$$

where $\boldsymbol{\theta} =\{ \boldsymbol{\mu_z}, \boldsymbol{\Sigma_z}\}$ where the parameters for this model.

***
### Joint Distribution

$$
\begin{bmatrix}
\boldsymbol{u} \\ 
\boldsymbol{z} 
\end{bmatrix} \sim 
\mathcal{N}
\left( 
    \begin{bmatrix}
    \boldsymbol{\mu_u} \\ 
    \boldsymbol{\mu_z} 
    \end{bmatrix},
    \begin{bmatrix}
    \mathbf{WW}^\top+\boldsymbol{\Sigma_u} && \mathbf{W} \\ 
    \mathbf{W}^\top && \mathbb{\Sigma_z}
    \end{bmatrix},
\right)
$$


***
### Posterior Distributions

We have the posterior distribution for the QoI, $\boldsymbol{u}$.

$$
p(\boldsymbol{u}|\boldsymbol{z};\boldsymbol{\theta}) = 
\mathcal{N}\left(\boldsymbol{u}\mid\boldsymbol{\mu_{u|z}},\boldsymbol{\Sigma_{u|z}}\right)
$$

where:

$$
\begin{aligned}
\boldsymbol{\mu_{u|z}} &=
\boldsymbol{\mu_u} + \mathbf{W}\boldsymbol{\Sigma_z}^{-1}(\boldsymbol{z} - \boldsymbol{\mu_z}) \\
\boldsymbol{\Sigma_{u|z}} &=
\boldsymbol{\Sigma_u} + \mathbf{W}\boldsymbol{\Sigma_u}^{-1}\mathbf{W}^\top \\
\end{aligned}
$$


We have the posterior distribution for the latent space, $\boldsymbol{z}$.

$$
q(\boldsymbol{z}|\boldsymbol{u};\boldsymbol{\theta}) = 
\mathcal{N}\left(\boldsymbol{z}\mid\boldsymbol{\mu_{z|u}},\boldsymbol{\Sigma_{z|u}}\right)
$$

where:

$$
\begin{aligned}
\boldsymbol{\mu_{z|u}} &=
\boldsymbol{\mu_z} + \mathbf{W}^\top
\left(\mathbf{WW}^\top + \boldsymbol{\Sigma_u}\right)^{-1}
(\boldsymbol{u} - \boldsymbol{\mu_u}) \\
\boldsymbol{\Sigma_{z|u}} &=
\boldsymbol{\Sigma_z} + \mathbf{W}^\top
\left(\mathbf{WW}^\top + \boldsymbol{\Sigma_u}\right)^{-1}
\mathbf{W}^\top \\
\end{aligned}
$$


***
### Marginal Likelihood

$$
p(\boldsymbol{u}) = \int p(\boldsymbol{u}|\boldsymbol{z})p(\boldsymbol{z})d\boldsymbol{z}
$$

