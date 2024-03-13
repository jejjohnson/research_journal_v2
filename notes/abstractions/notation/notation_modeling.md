---
title: Notation - Modeling
subject: ML4EO
short_title: Modeling
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


# Modeling Components

***
## Observations

> Measurements we can actually observe.

$$
\begin{aligned}
\boldsymbol{y} &= \boldsymbol{y}(\mathbf{s},t), && &&
\boldsymbol{y}: \mathbb{R}^{D_s}\times\mathbb{R}^+\rightarrow\mathbb{R}^{D_y} 
&& &&
\mathbf{s}\in\Omega_y\subseteq\mathbb{R}^{D_s} && &&
t \in \mathcal{T}_y \subseteq \mathbb{R}^+
\end{aligned}
$$


## Covariate

> Data which we believe is conditionally important for our model.

$$
\begin{aligned}
\boldsymbol{x} &= \boldsymbol{x}(\mathbf{s},t), && &&
\boldsymbol{x}: \mathbb{R}^{D_s}\times\mathbb{R}^+\rightarrow\mathbb{R}^{D_x} 
&& &&
\mathbf{s}\in\Omega_x\subseteq\mathbb{R}^{D_s} && &&
t \in \mathcal{T}_x \subseteq \mathbb{R}^+
\end{aligned}
$$

## Quantity of Interest (QoI)

> The true quantity we are interested in estimating.

$$
\begin{aligned}
\boldsymbol{u} &= \boldsymbol{u}(\mathbf{s},t), && &&
\boldsymbol{u}: \mathbb{R}^{D_s}\times\mathbb{R}^+\rightarrow\mathbb{R}^{D_x} 
&& &&
\mathbf{s}\in\Omega_u\subseteq\mathbb{R}^{D_s} && &&
t \in \mathcal{T}_u \subseteq \mathbb{R}^+
\end{aligned}
$$

## Latent Variables

> Unknown, unobserved variables

$$
\begin{aligned}
\boldsymbol{z} &= \boldsymbol{z}(\mathbf{s},t), && &&
\boldsymbol{z}: \mathbb{R}^{D_s}\times\mathbb{R}^+\rightarrow\mathbb{R}^{D_x} 
&& &&
\mathbf{s}\in\Omega_z\subseteq\mathbb{R}^{D_s} && &&
t \in \mathcal{T}_z \subseteq \mathbb{R}^+
\end{aligned}
$$

## Parameters

> Unknown, unobserved quantities to be estimated.

$$
\begin{aligned}
\boldsymbol{\theta} &\in\boldsymbol{\Theta}\subseteq\mathbb{R}^{D_\theta} 
\end{aligned}
$$

***
# Operators

$$
\boldsymbol{f}: \boldsymbol{x}(\mathbf{s},t) \rightarrow \boldsymbol{u}(\mathbf{s},t)
$$

**Parameterized**

$$
\boldsymbol{f}^*: \boldsymbol{x}(\mathbf{s},t)\times\boldsymbol{\Theta} \rightarrow \boldsymbol{u}(\mathbf{s},t)
$$

***
# Criteria

## Loss Function

$$
\boldsymbol{L}: \mathbb{R}^{D_\theta}\times\mathbb{R}^{D_y} \rightarrow \mathbb{R}
$$

## Objective Function

$$
\boldsymbol{J}: \mathbb{R}^{D_u}\times\mathbb{R}^{D_\theta} \rightarrow \mathbb{R}
$$

***
# Tasks

***
## Parameter Learning

$$
\boldsymbol{\theta}^* = \underset{\boldsymbol{\theta}}{\text{argmin}}\hspace{2mm}
\boldsymbol{L}(\boldsymbol{\theta})
$$


***
## Estimation

$$
\boldsymbol{u}^*(\boldsymbol{\theta}) = \underset{\boldsymbol{u}}{\text{argmin}}\hspace{2mm}
\boldsymbol{J}(\boldsymbol{u};\boldsymbol{\theta})
$$


***
## Bi-Level Optimization

$$
\begin{aligned}
\boldsymbol{\theta}^* &= \underset{\boldsymbol{\theta}}{\text{argmin}}\hspace{2mm}
\boldsymbol{L}(\boldsymbol{\theta}) \\
\boldsymbol{u}^*(\boldsymbol{\theta}) &= \underset{\boldsymbol{u}}{\text{argmin}}\hspace{2mm}
\boldsymbol{J}(\boldsymbol{u};\boldsymbol{\theta})
\end{aligned}
$$