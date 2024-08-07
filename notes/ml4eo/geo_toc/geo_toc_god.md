---
title: Concept - Game of Dependencies
subject: ML4EO
short_title: Game of Dependencies
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


* Univariate Time Series
* Multiple Univariate Time Series
* Univariate Spatiotemporal Series
* Multiple Univariate Spatiotemporal Series

***
### Univariate Time Series

In this case, we have a univariate time series.
For this, we will investigate how we can model a time series.

**Tutorials**:
* Global Mean Surface Temperature Anomaly
* Single Weather Station for Spain


***
#### Unconditional Density Estimation

$$
\begin{aligned}
\mathcal{D} &= \left\{ y_n \right\}_{n=1}^N, && &&
N = N_T && &&
y_n \in\mathbb{R}^{D_y}
\end{aligned}
$$

We have a few types of models we can use when we are faced with this situation.

$$
\begin{aligned}
\text{Fully Pooled}: && &&
p(\mathbf{y},\mathbf{z},\boldsymbol{\theta})
&=
p(\boldsymbol{\theta})
p(\mathbf{z}|\boldsymbol{\theta})
\prod_{n=1}^N
p(\mathbf{y}_n|\mathbf{z}) \\
\text{Non-Pooled}: && &&
p(\mathbf{y},\mathbf{z},\boldsymbol{\theta})
&=
\prod_{n=1}^N 
p(y_n|\mathbf{z}_n)
p(\mathbf{z}_n|\boldsymbol{\theta}_n)
p(\boldsymbol{\theta}_n) \\
\text{Partially-Pooled}: && &&
p(\mathbf{y},\mathbf{z},\boldsymbol{\theta})
&=
p(\boldsymbol{\theta})\prod_{n=1}^N
p(y_n|\mathbf{z}_n)p(\mathbf{z}_n|\boldsymbol{\theta}) \\
\end{aligned}
$$

The conclusion of this demonstration is that it's almost always favourable to use a partially-pooled model as it effectively gives us options for modeling the dynamics of the parameters.


***
#### Temporally Conditioned Density Estimation

We can use conditional density estimation but we only condition on the time component.
In this case, we have some pairwise entries of measurements, $y_n$, at some associated time stamp, $t_n$.
$$
\begin{aligned}
\mathcal{D} &= \left\{ t_n, y_n \right\}_{n=1}^N
&& &&
y_n \in\mathbb{R}^{D_y}
&& &&
t_n\in\mathbb{R}^+
\end{aligned}
$$

where $N=N_T$.

$$
\begin{aligned}
\text{Measurements}: && &&
\mathbf{y} &\in\mathbb{R}^{N_T} 
&& &&
y_n \in\mathbb{R}\\
\text{Time Stamps}: && &&
\mathbf{t} &\in\mathbb{R}^{N_T} && &&
t_n \in\mathbb{R}^+\\
\text{Latent Variables}: && &&
\mathbf{Z} &\in\mathbb{R}^{N_T\times D_z} && &&
\mathbf{z}_n \in\mathbb{R}^{D_z}\\
\text{Parameters}: && &&
\boldsymbol{\theta} &\in\mathbb{R}^{D_\theta} \\
\end{aligned}
$$

Here, we need to use a conditional

$$
p(\mathbf{y},\mathbf{t},\mathbf{Z},\boldsymbol{\theta}) =
p(\boldsymbol{\theta})
\prod_{t=1}^{N_T}
p(y_n|\mathbf{z}_n)
p(\mathbf{z}_n|t_n,\boldsymbol{\theta})
$$

***
#### Unconditional Dynamic Model

$$
\begin{aligned}
\mathcal{D} &= \left\{ t_n, y_t \right\}_{n=1}^N
&& &&
y_t \in\mathbb{R}^{D_y}
&& &&
t\in\mathbb{R}^+
\end{aligned}
$$

where $N=N_T$.

$$
\begin{aligned}
\text{Measurements}: && &&
\mathbf{y} &\in\mathbb{R}^{N_T} 
&& &&
y_t \in\mathbb{R}\\
\text{Latent Variables}: && &&
\mathbf{Z} &\in\mathbb{R}^{N_T\times D_z} && &&
\mathbf{z}_t \in\mathbb{R}^{D_z}\\
\text{Parameters}: && &&
\boldsymbol{\theta} &\in\mathbb{R}^{D_\theta} \\
\end{aligned}
$$

Finally, we can write the joint distribution

$$
\begin{aligned}
\text{Strong-Constrained}: && &&
p(\mathbf{y},\mathbf{Z},\boldsymbol{\theta})
&=
p(\boldsymbol{\theta})
p(\mathbf{z}_0|\boldsymbol{\theta})
\prod_{t=1}^{T}
p(y_t|\mathbf{z}_t)p(\mathbf{z}_t|\mathbf{z}_0) \\
\text{Weak-Constrained}: && &&
p(\mathbf{y},\mathbf{z},\boldsymbol{\theta})
&=
p(\boldsymbol{\theta})
p(\mathbf{z}_0|\boldsymbol{\theta})
\prod_{t=1}^{T}
p(y_t|\mathbf{z}_t)p(\mathbf{z}_t|\mathbf{z}_{t-1},\boldsymbol{\theta})  \\
\end{aligned}
$$

***
### Multivariate Time Series

In this case, we have a univariate time series.
For this, we will investigate how we can model a time series.

**Tutorials**:
* Single Weather Station for Spain + Multiple Variables


***
#### Unconditional Density Estimation

$$
\begin{aligned}
\mathcal{D} &= \left\{ \mathbf{y}_n \right\}_{n=1}^N, && &&
N = N_T && &&
\mathbf{y}_n \in\mathbb{R}^{D_y}
\end{aligned}
$$

We have a few types of models we can use when we are faced with this situation.

$$
\begin{aligned}
\text{Partially-Pooled}: && &&
p(\mathbf{Y},\mathbf{Z},\boldsymbol{\theta})
&=
p(\boldsymbol{\theta})\prod_{n=1}^N
p(\mathbf{y}_n|\mathbf{z}_n)p(\mathbf{z}_n|\boldsymbol{\theta}) \\
\end{aligned}
$$

The conclusion of this demonstration is that it's almost always favourable to use a partially-pooled model as it effectively gives us options for modeling the dynamics of the parameters.


***
#### Temporally Conditioned Density Estimation

We can use conditional density estimation but we only condition on the time component.
In this case, we have some pairwise entries of measurements, $y_n$, at some associated time stamp, $t_n$.
$$
\begin{aligned}
\mathcal{D} &= \left\{ t_n, \mathbf{y}_n \right\}_{n=1}^N
&& &&
\mathbf{y}_n \in\mathbb{R}^{D_y}
&& &&
t_n\in\mathbb{R}^+
\end{aligned}
$$

where $N=N_T$.

$$
\begin{aligned}
\text{Measurements}: && &&
\mathbf{Y} &\in\mathbb{R}^{N_T\times D_y} 
&& &&
\mathbf{y}_n \in\mathbb{R}\\
\text{Time Stamps}: && &&
\mathbf{t} &\in\mathbb{R}^{N_T} && &&
t_n \in\mathbb{R}^+\\
\text{Latent Variables}: && &&
\mathbf{Z} &\in\mathbb{R}^{N_T\times D_z} && &&
\mathbf{z}_n \in\mathbb{R}^{D_z}\\
\text{Parameters}: && &&
\boldsymbol{\theta} &\in\mathbb{R}^{D_\theta} \\
\end{aligned}
$$

Here, we need to use a conditional

$$
p(\mathbf{Y},\mathbf{t},\mathbf{Z},\boldsymbol{\theta}) =
p(\boldsymbol{\theta})
\prod_{t=1}^{N_T}
p(\mathbf{y}_n|\mathbf{z}_n)
p(\mathbf{z}_n|t_n,\boldsymbol{\theta})
$$

***
#### Unconditional Dynamic Model

$$
\begin{aligned}
\mathcal{D} &= \left\{ t_n, \mathbf{y}_t \right\}_{n=1}^N
&& &&
\mathbf{y}_t \in\mathbb{R}^{D_y}
&& &&
t\in\mathbb{R}^+
\end{aligned}
$$

where $N=N_T$.

$$
\begin{aligned}
\text{Measurements}: && &&
\mathbf{Y} &\in\mathbb{R}^{N_T\times D_y} 
&& &&
\mathbf{y}_t \in\mathbb{R}^{D_y}\\
\text{Latent Variables}: && &&
\mathbf{Z} &\in\mathbb{R}^{N_T\times D_z} && &&
\mathbf{z}_t \in\mathbb{R}^{D_z}\\
\text{Parameters}: && &&
\boldsymbol{\theta} &\in\mathbb{R}^{D_\theta} \\
\end{aligned}
$$

Finally, we can write the joint distribution

$$
\begin{aligned}
\text{Strong-Constrained}: && &&
p(\mathbf{Y},\mathbf{Z},\boldsymbol{\theta})
&=
p(\boldsymbol{\theta})
p(\mathbf{z}_0|\boldsymbol{\theta})
\prod_{t=1}^{T}
p(\mathbf{y}_t|\mathbf{z}_t)p(\mathbf{z}_t|\mathbf{z}_0) \\
\text{Weak-Constrained}: && &&
p(\mathbf{Y},\mathbf{Z},\boldsymbol{\theta})
&=
p(\boldsymbol{\theta})
p(\mathbf{z}_0|\boldsymbol{\theta})
\prod_{t=1}^{T}
p(\mathbf{y}_t|\mathbf{z}_t)p(\mathbf{z}_t|\mathbf{z}_{t-1},\boldsymbol{\theta})  \\
\end{aligned}
$$



***
### Multivariate Spatiotemporal Series

In this case, we have a univariate time series.
For this, we will investigate how we can model a time series.

**Tutorials**:
* Multiple Weather Station for Spain + Multiple Variables


***
#### Unconditional Density Estimation

$$
\begin{aligned}
\mathcal{D} &= \left\{ \mathbf{y}_n \right\}_{n=1}^N, && &&
N = N_T
&& && 
D = D_y D_\Omega
&& &&
\mathbf{y}_n \in\mathbb{R}^{D}
\end{aligned}
$$

We have a few types of models we can use when we are faced with this situation.

$$
\begin{aligned}
\text{Partially-Pooled}: && &&
p(\mathbf{Y},\mathbf{Z},\boldsymbol{\theta})
&=
p(\boldsymbol{\theta})\prod_{n=1}^N
p(\mathbf{y}_n|\mathbf{z}_n)p(\mathbf{z}_n|\boldsymbol{\theta}) \\
\end{aligned}
$$

The conclusion of this demonstration is that it's almost always favourable to use a partially-pooled model as it effectively gives us options for modeling the dynamics of the parameters.

***
#### Temporally Conditioned Density Estimation

##### Coordinate-Based

We can use conditional density estimation but we only condition on the time component.
In this case, we have some pairwise entries of measurements, $y_n$, at some associated time stamp, $t_n$.
$$
\begin{aligned}
\mathcal{D} &= \left\{ (t_n, \mathbf{s}_n), \mathbf{y}_n \right\}_{n=1}^N
&& &&
\mathbf{y}_n \in\mathbb{R}^{D_y}
&& &&
t_n\in\mathbb{R}^+
\end{aligned}
$$

where $N=N_T$ and $D=D_y$.

$$
\begin{aligned}
\text{Measurements}: && &&
\mathbf{Y} &\in\mathbb{R}^{N_T\times D_y} 
&& &&
\mathbf{y}_n \in\mathbb{R}^{D_y}\\
\text{Time Stamps}: && &&
\mathbf{t} &\in\mathbb{R}^{N_T} && &&
t_n \in\mathbb{R}^+\\
\text{Spatial Coordinates}: && &&
\mathbf{S} &\in\mathbb{R}^{N_T \times D_s} && &&
\mathbf{s}_n \in\mathbb{R}^{D_s}\\
\text{Latent Variables}: && &&
\mathbf{Z} &\in\mathbb{R}^{N_T\times D_z} && &&
\mathbf{z}_n \in\mathbb{R}^{D_z}\\
\text{Parameters}: && &&
\boldsymbol{\theta} &\in\mathbb{R}^{D_\theta} \\
\end{aligned}
$$

Here, we need to use a conditional

$$
p(\mathbf{Y},\mathbf{t},\mathbf{S},\mathbf{Z},\boldsymbol{\theta}) =
p(\boldsymbol{\theta})
\prod_{t=1}^{N_T}
p(\mathbf{y}_n|\mathbf{z}_n)
p(\mathbf{z}_n|t_n,\mathbf{s}_n,\boldsymbol{\theta})
$$


***
##### Field-Based

We can use conditional density estimation but we only condition on the time component.
In this case, we have some pairwise entries of measurements, $y_n$, at some associated time stamp, $t_n$.
$$
\begin{aligned}
\mathcal{D} &= \left\{ t_n, \mathbf{y}_n \right\}_{n=1}^N
&& &&
\mathbf{y}_n \in\mathbb{R}^{D}
&& &&
t_n\in\mathbb{R}^+
\end{aligned}
$$

where $N=N_T$ and $D=D_\Omega D_y$.

$$
\begin{aligned}
\text{Measurements}: && &&
\mathbf{Y} &\in\mathbb{R}^{N_T\times D} 
&& &&
\mathbf{y}_n \in\mathbb{R}^D\\
\text{Time Stamps}: && &&
\mathbf{t} &\in\mathbb{R}^{N_T} && &&
t_n \in\mathbb{R}^+\\
\text{Latent Variables}: && &&
\mathbf{Z} &\in\mathbb{R}^{N_T\times D_z} && &&
\mathbf{z}_n \in\mathbb{R}^{D_z}\\
\text{Parameters}: && &&
\boldsymbol{\theta} &\in\mathbb{R}^{D_\theta} \\
\end{aligned}
$$

Here, we need to use a conditional

$$
p(\mathbf{Y},\mathbf{t},\mathbf{Z},\boldsymbol{\theta}) =
p(\boldsymbol{\theta})
\prod_{t=1}^{N_T}
p(\mathbf{y}_n|\mathbf{z}_n)
p(\mathbf{z}_n|t_n,\boldsymbol{\theta})
$$

***
#### Unconditional Dynamic Model

$$
\begin{aligned}
\mathcal{D} &= \left\{ t_n, \mathbf{y}_t \right\}_{n=1}^N
&& &&
\mathbf{y}_t \in\mathbb{R}^{D}
&& &&
t\in\mathbb{R}^+
\end{aligned}
$$

where $N=N_T$ and $D=D_\Omega D_y$.

$$
\begin{aligned}
\text{Measurements}: && &&
\mathbf{Y} &\in\mathbb{R}^{N_T\times D} 
&& &&
\mathbf{y}_t \in\mathbb{R}^{D}\\
\text{Latent Variables}: && &&
\mathbf{Z} &\in\mathbb{R}^{N_T\times D_z} && &&
\mathbf{z}_t \in\mathbb{R}^{D_z}\\
\text{Parameters}: && &&
\boldsymbol{\theta} &\in\mathbb{R}^{D_\theta} \\
\end{aligned}
$$

Finally, we can write the joint distribution

$$
\begin{aligned}
\text{Strong-Constrained}: && &&
p(\mathbf{Y},\mathbf{Z},\boldsymbol{\theta})
&=
p(\boldsymbol{\theta})
p(\mathbf{z}_0|\boldsymbol{\theta})
\prod_{t=1}^{T}
p(\mathbf{y}_t|\mathbf{z}_t)p(\mathbf{z}_t|\mathbf{z}_0) \\
\text{Weak-Constrained}: && &&
p(\mathbf{Y},\mathbf{Z},\boldsymbol{\theta})
&=
p(\boldsymbol{\theta})
p(\mathbf{z}_0|\boldsymbol{\theta})
\prod_{t=1}^{T}
p(\mathbf{y}_t|\mathbf{z}_t)p(\mathbf{z}_t|\mathbf{z}_{t-1},\boldsymbol{\theta})  \\
\end{aligned}
$$

***
### Coupled Multivariate Spatiotemporal Series


In this case, we have a univariate time series.
For this, we will investigate how we can model a time series.

**Tutorials**:
* Multiple Weather Station for Spain + Multiple Variables


***
#### Conditional Density Estimation

$$
\begin{aligned}
\mathcal{D} &= \left\{ \mathbf{x}_n, \mathbf{y}_n \right\}_{n=1}^N, && &&
N = N_T
&& && 
D = D_y D_\Omega
&& &&
\mathbf{y}_n \in\mathbb{R}^{D} 
&& &&
\mathbf{x}_n \in\mathbb{R}^{D_x}
\end{aligned}
$$

We have a few types of models we can use when we are faced with this situation.

$$
\begin{aligned}
\text{Partially-Pooled}: && &&
p(\mathbf{Y},\mathbf{X},\mathbf{Z},\boldsymbol{\theta})
&=
p(\boldsymbol{\theta})\prod_{n=1}^N
p(\mathbf{y}_n|\mathbf{z}_n)p(\mathbf{z}_n|\mathbf{x}_n,\boldsymbol{\theta}) \\
\end{aligned}
$$

The conclusion of this demonstration is that it's almost always favourable to use a partially-pooled model as it effectively gives us options for modeling the dynamics of the parameters.

***
#### Temporal Conditional Density Estimation

##### Coordinate-Based

We can use conditional density estimation but we only condition on the time component.
In this case, we have some pairwise entries of measurements, $y_n$, at some associated time stamp, $t_n$.
$$
\begin{aligned}
\mathcal{D} &= \left\{ (t_n, \mathbf{s}_n), \mathbf{x}_n, \mathbf{y}_n \right\}_{n=1}^N
&& &&
\mathbf{y}_n \in\mathbb{R}^{D_y}
&& &&
\mathbf{x}_n \in\mathbb{R}^{D_x}
&& &&
t_n\in\mathbb{R}^+
\end{aligned}
$$

where $N=N_T$ and $D=D_y$.

$$
\begin{aligned}
\text{Measurements}: && &&
\mathbf{Y} &\in\mathbb{R}^{N_T\times D_y} 
&& &&
\mathbf{y}_n \in\mathbb{R}^{D_y}\\
\text{Covariates}: && &&
\mathbf{X} &\in\mathbb{R}^{N_T\times D_x} 
&& &&
\mathbf{x}_n \in\mathbb{R}^{D_x}\\
\text{Time Stamps}: && &&
\mathbf{t} &\in\mathbb{R}^{N_T} && &&
t_n \in\mathbb{R}^+\\
\text{Spatial Coordinates}: && &&
\mathbf{S} &\in\mathbb{R}^{N_T \times D_s} && &&
\mathbf{s}_n \in\mathbb{R}^{D_s}\\
\text{Latent Variables}: && &&
\mathbf{Z} &\in\mathbb{R}^{N_T\times D_z} && &&
\mathbf{z}_n \in\mathbb{R}^{D_z}\\
\text{Parameters}: && &&
\boldsymbol{\theta} &\in\mathbb{R}^{D_\theta} \\
\end{aligned}
$$

Here, we need to use a conditional

$$
p\left(\mathbf{Y},\mathbf{X},\mathbf{t},\mathbf{S},\mathbf{Z},\boldsymbol{\theta}\right) =
p(\boldsymbol{\theta})
\prod_{t=1}^{N_T}
p(\mathbf{y}_n|\mathbf{z}_n)
p(\mathbf{z}_n|t_n,\mathbf{s}_n,\mathbf{x}_n, \boldsymbol{\theta})
$$


***
##### Field-Based

We can use conditional density estimation but we only condition on the time component.
In this case, we have some pairwise entries of measurements, $y_n$, at some associated time stamp, $t_n$.
$$
\begin{aligned}
\mathcal{D} &= \left\{ t_n, \mathbf{x}_n, \mathbf{y}_n \right\}_{n=1}^N
&& &&
\mathbf{y}_n \in\mathbb{R}^{D_y}
&& &&
\mathbf{x}_n \in\mathbb{R}^{D_x}
&& &&
t_n\in\mathbb{R}^+
\end{aligned}
$$

where $N=N_T$ and $D_y=D_\Omega D_y$, $D_x=D_{\Omega_x}$.

$$
\begin{aligned}
\text{Measurements}: && &&
\mathbf{Y} &\in\mathbb{R}^{N_T\times D} 
&& &&
\mathbf{y}_n \in\mathbb{R}^D\\
\text{Covariates}: && &&
\mathbf{X} &\in\mathbb{R}^{N_T\times D_x} 
&& &&
\mathbf{x}_n \in\mathbb{R}^{D_x}\\
\text{Time Stamps}: && &&
\mathbf{t} &\in\mathbb{R}^{N_T} && &&
t_n \in\mathbb{R}^+\\
\text{Latent Variables}: && &&
\mathbf{Z} &\in\mathbb{R}^{N_T\times D_z} && &&
\mathbf{z}_n \in\mathbb{R}^{D_z}\\
\text{Parameters}: && &&
\boldsymbol{\theta} &\in\mathbb{R}^{D_\theta} \\
\end{aligned}
$$

Here, we need to use a conditional

$$
p(\mathbf{Y},\mathbf{X},\mathbf{t},\mathbf{Z},\boldsymbol{\theta}) =
p(\boldsymbol{\theta})
\prod_{t=1}^{N_T}
p(\mathbf{y}_n|\mathbf{z}_n)
p(\mathbf{z}_n|t_n,\mathbf{x}_n,\boldsymbol{\theta})
$$

***
#### Conditional Dynamic Model

$$
\begin{aligned}
\mathcal{D} &= \left\{ t_n, \mathbf{x}_t,\mathbf{y}_t \right\}_{n=1}^N
&& &&
\mathbf{y}_t \in\mathbb{R}^{D_y}
&& &&
\mathbf{x}_t \in\mathbb{R}^{D_x}
&& &&
t\in\mathbb{R}^+
\end{aligned}
$$

where $N=N_T$ and $D=D_\Omega D_y$.

$$
\begin{aligned}
\text{Measurements}: && &&
\mathbf{Y} &\in\mathbb{R}^{N_T\times D_y} 
&& &&
\mathbf{y}_t \in\mathbb{R}^{D_y}\\
\text{Covariates}: && &&
\mathbf{X} &\in\mathbb{R}^{N_T\times D_x} 
&& &&
\mathbf{x}_t \in\mathbb{R}^{D_x}\\
\text{Latent Variables}: && &&
\mathbf{Z} &\in\mathbb{R}^{N_T\times D_z} && &&
\mathbf{z}_t \in\mathbb{R}^{D_z}\\
\text{Parameters}: && &&
\boldsymbol{\theta} &\in\mathbb{R}^{D_\theta} \\
\end{aligned}
$$

Finally, we can write the joint distribution

$$
\begin{aligned}
\text{Strong-Constrained}: && &&
p(\mathbf{Y},\mathbf{X},\mathbf{Z},\boldsymbol{\theta})
&=
p(\boldsymbol{\theta})
p(\mathbf{z}_0|\boldsymbol{\theta})
\prod_{t=1}^{T}
p(\mathbf{y}_t|\mathbf{z}_t)p(\mathbf{z}_t|\mathbf{x}_t,\mathbf{z}_0) \\
\text{Weak-Constrained}: && &&
p(\mathbf{Y},\mathbf{X},\mathbf{Z},\boldsymbol{\theta})
&=
p(\boldsymbol{\theta})
p(\mathbf{z}_0|\boldsymbol{\theta})
\prod_{t=1}^{T}
p(\mathbf{y}_t|\mathbf{z}_t)p(\mathbf{z}_t|\mathbf{x}_t,\mathbf{z}_{t-1},\boldsymbol{\theta})  \\
\end{aligned}
$$




