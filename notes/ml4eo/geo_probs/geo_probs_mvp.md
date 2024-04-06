---
title: Geo Problems
subject: Machine Learning for Earth Observations
short_title: MVP Solution
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

## TLDR

**Step 1**: Train a coordinate-based Gaussian process interpolator on patches.

**Step 2**: Train a conditional prior model from GP simulations. Estimate full field from prior.

**Step 3**: Train a 



***
## Coordinate-Based Interpolation

**Data**

$$
\mathcal{D} = \left\{ (\mathbf{s}_n,t_n),\boldsymbol{y}_n\right\}_{n=1}^N
$$

where $N=N_s N_t$.

***
**Joint Distribution**

We formulate this as a conditional density estimation problem.

$$
p(\boldsymbol{y},\mathbf{s},t,\boldsymbol{f},\boldsymbol{\theta}) = p(\boldsymbol{y}|\boldsymbol{f},\boldsymbol{\theta})p(\boldsymbol{f}|\mathbf{s},t,\boldsymbol{\theta})p(\boldsymbol{\theta})
$$

***
**Model**

We will use a simple Gaussian process model to fill in the gaps.

$$
\begin{aligned}
\boldsymbol{y}_n = \boldsymbol{f}(\mathbf{x}_n,t_n;\boldsymbol{\theta}) + \varepsilon_n, && &&
\boldsymbol{f} \sim 
\mathcal{GP}
\left(
    \boldsymbol{m}_{\boldsymbol{\theta}}(\mathbf{s},t),
    \boldsymbol{k}_{\boldsymbol{\theta}}(\mathbf{s},t)
\right),
&& &&
\varepsilon_n \sim \mathcal{N}(0,\sigma_2) 
\end{aligned}
$$

***
**Criteria**

$$
\boldsymbol{L}(\boldsymbol{\theta}) = \log p(\boldsymbol{y})
$$

***
**Scale**

There are many opportunities to improve the scalability of this class of methods.
* We could use approximate kernels using Fourier Features.
* We could also use inducing inputs to sparsify this method.
* We could use dynamical methods


***
## Field-Based Interpolation


**Initial Condition**
We will use the Gaussian process

***
**Joint Distribution**
$$
p(\boldsymbol{y},\boldsymbol{u},\boldsymbol{\theta}) = 
p(\boldsymbol{y}|\boldsymbol{u},\boldsymbol{\theta})
p(\boldsymbol{u}|\boldsymbol{\theta})p(\boldsymbol{\theta})
$$



***
**Model**

$$
\begin{aligned}
\text{Likelihood}: && &&
\boldsymbol{y}_n &= \boldsymbol{h}(\boldsymbol{u}_n,\boldsymbol{\theta}) + \boldsymbol{\varepsilon}_n, && &&
\boldsymbol{\varepsilon} \sim \mathcal{N}(0,\boldsymbol{\Sigma_y}) \\
\text{Prior}: && &&
\boldsymbol{u}_n &= \boldsymbol{\mu_u} + \boldsymbol{\varepsilon}_n, && &&
\boldsymbol{\varepsilon} \sim \mathcal{N}(0,\boldsymbol{\Sigma_u}) \\
\end{aligned}
$$


***
**Criteria**

$$
\boldsymbol{J}(\boldsymbol{u};\boldsymbol{\theta}) =
\frac{1}{2}||\boldsymbol{y} - \boldsymbol{h}(\boldsymbol{u};\boldsymbol{\theta_h})||_{\boldsymbol{\Sigma}_y^{-1}}^2 + 
\frac{1}{2}||\boldsymbol{u} - \boldsymbol{\mu_u}||_{\boldsymbol{\Sigma_u}^{-1}}^2
$$

where $\boldsymbol{\theta}=\left\{\boldsymbol{h},\boldsymbol{\theta_h},\boldsymbol{\mu_u}, \boldsymbol{\Sigma_u}, \boldsymbol{\Sigma_y}, \boldsymbol{H}\right\}$ are the parameters of the objective function.


***
## Pretraining

For these, we will use a conditional

### Gaussian Process Prior

$$
\begin{aligned}
\text{Sample Parameters}: && &&
\boldsymbol{\theta}_n &\sim p(\boldsymbol{\theta})\\
\text{Sample Gaussian Process}: && &&
\boldsymbol{f}_n &\sim \mathcal{GP}(\boldsymbol{m}_{\boldsymbol{\theta}},\boldsymbol{k}_{\boldsymbol{\theta}})\\
\text{Dataset}: && &&
\mathcal{D}  &= \left\{\boldsymbol{\theta}_n,\boldsymbol{f}_n \right\}_{n=1}^N
\end{aligned}
$$

**Model**

$$
\begin{aligned}

\end{aligned}
$$

**Loss Function**

$$
\boldsymbol{L}(\boldsymbol) = 
\mathbb{E}_{q_{\boldsymbol{\phi}}(\boldsymbol{z}|\boldsymbol{\theta})}
\left[ 
    p_{\boldsymbol{\theta}}\left( \boldsymbol{} \right)
\right]
$$


### Interpolated Data


### Assimilated Data

***
## Deep Equilibrium Model

$$
\boldsymbol{u} = \boldsymbol{h}(\boldsymbol{u},\boldsymbol{y},\boldsymbol{x};\boldsymbol{\theta})
$$

***
## Dynamical Model



**Model**

$$
\begin{aligned}
\text{Observation Model}: && &&
\boldsymbol{y}_t &= \boldsymbol{h}(\boldsymbol{u}_t;\boldsymbol{\theta}) + \boldsymbol{\varepsilon}_t, && &&
\boldsymbol{\varepsilon}_t \sim \mathcal{N}(0,\boldsymbol{\Sigma_y}) \\
\text{Dynamical Model}: && &&
\boldsymbol{u}_t &=  \text{ODESolver} \left(\boldsymbol{f}, \boldsymbol{u}_0, t_0, t\right) \\
\end{aligned}
$$