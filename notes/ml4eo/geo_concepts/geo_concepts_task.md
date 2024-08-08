---
title: Task
subject: ML4EO
short_title: Tasks
authors:
  - name: J. Emmanuel Johnson
    affiliations:
      - CSIC
      - UCM
      - IGEO
    orcid: 0000-0002-6739-0053
    email: juanjohn@ucm.es
license: CC-BY-4.0
keywords: tasks, learning, estimation, predictions
abstract: |
  In computer science, we often can "bin" all problems into a series of sub-problems that we 
  can iterate over until convergence. 
  The same can be said for data-driven geoscience! 
  In fact, I claim that most problems can be put into a series of 4 categories: 1) data acquisition,
  2) learning, 3) estimating, and/or 4) predictions. 
---


## Overview


* Data Acquisition
* Learn
* Estimate
* Predict

## Data

$$
\mathcal{D} = \left\{ \mathbf{x}_n, \mathbf{y}_n, \mathbf{z}_n^*, \right\}_{n=1}^N
$$

$$
\begin{aligned}
\text{Measurements}: && &&
\mathbf{y}_n &\in\mathcal{Y}\subseteq\mathbb{R}^{D_y} \\
\text{Covariates}: && &&
\mathbf{x}_n &\in\mathcal{X}\subseteq\mathbb{R}^{D_x} \\
\text{Simulationed States}: && &&
\mathbf{z}_n^{sim} &\in\mathcal{Z}^{sim}\subseteq\mathbb{R}^{D_z} \\
\text{Reanalysis States}: && &&
\mathbf{z}_n^{*} &\in\mathcal{Z}^{*}\subseteq\mathbb{R}^{D_z} \\
\end{aligned}
$$


***
## Learning

> I have data, $\mathcal{D}$, which captures the phenomena that I want to learn.

> I want to learn a model, $f$, with the associated parameters, $\theta$, give the data, $\mathcal{D}$.



$$
\boldsymbol{\theta}^* = \underset{\boldsymbol{\theta}}{\argmin}
\hspace{2mm}
\boldsymbol{L}(\boldsymbol{\theta};\mathcal{D})
$$

where $\boldsymbol{L}(\cdot)$ is our loss function.

$$
\begin{aligned}
\boldsymbol{L} : \mathbb{R}^{D_\theta} \times \mathcal{D} \rightarrow \mathbb{R}
\end{aligned}
$$


***
## Estimation

> I have a model, $f$, and parameters, $\theta$.

> I have some measurements, $y$.

> I want to estimate a state, $z$.

$$
\mathbf{z}^*(\boldsymbol{\theta}) = \underset{\mathbf{z}}{\argmin}
\hspace{2mm}
\boldsymbol{J}(\mathbf{z};\boldsymbol{\theta},\mathcal{D})
$$

where $\boldsymbol{J}(\cdot)$ is our objective function defined as:

$$
\begin{aligned}
\boldsymbol{J} : \mathbb{R}^{D_z} \times \mathbb{R}^{D_\theta}\times\mathcal{D} \rightarrow \mathbb{R}
\end{aligned}
$$

***
## Parameter & State Estimation


$$
\begin{aligned}
\text{Parameter Estimation}: && &&
\boldsymbol{\theta}^* = \underset{\boldsymbol{\theta}}{\argmin}
\hspace{2mm}
\boldsymbol{L}(\boldsymbol{\theta};\mathcal{D}) \\
\text{State Estimation}: && &&
\mathbf{z}^*(\boldsymbol{\theta}) = \underset{\mathbf{z}}{\argmin}
\hspace{2mm}
\boldsymbol{J}(\mathbf{z};\boldsymbol{\theta},\mathcal{D})
\end{aligned}
$$

This is akin to the:
* Approximate Inference methods - expectaction maximization, variational inference
* Bi-Level Optimization
* Data Assimilation


***
## Prediction

> I have my model, parameters, and state estimation.

> I want to make a prediction for my QoI, $u$.

$$
u^* = \boldsymbol{f}(\mathbf{z}^*, \boldsymbol{\theta})
$$

In this case, we never have access to any sort of validation, $u$.
We are simply making a prediction.