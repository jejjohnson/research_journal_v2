---
title: Data-Driven Attribution
subject: Data-Driven Modeling for Attribution
short_title: DDAttr - Modeling
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
abbreviations:
    ERA5: ECMWF Reanalysis Version 5
    CMIP6: Coupled Model Intercomparison Project Phase 6
    AMIP6: Atmospherical Model Intercomparison Project Phase 6
    EOFs: Empirical Orthogonal Functions
    POD: Proper Orthogonal Decomposition
    PCA: Principal Components Analysis
    SSP: Shared Socioeconomic Pathways
    GPD: Generalized Pareto Distribution
    GEV: Generalized Extreme Value
    QoI: Quantity of Interest
    iid: Independently Identically Distributed
---

> Overview of data representations & modeling assumptions.

## Data Structure Assumptions

Recall, we are dealing with a spatiotemporal field given by

$$
\begin{aligned}
\boldsymbol{y} = \boldsymbol{y}(\mathbf{x},t)
&& &&
\boldsymbol{y}:\mathbb{R}^{D_s}\times\mathbb{R}^+\rightarrow\mathbb{R}^{D_y}
&& &&
\mathbf{x}\in\Omega_y\subseteq\mathbb{R}^{D_s}
&& &&
t\in\mathcal{T}\subseteq\mathbb{R}^+
\end{aligned}
$$

where $\mathbf{x}$ are the spatial coordinates and $t$ is the temporal coordinate.

***

## I.I.D. Samples

This is the simplest form where we assume each datapoint is independent, i.e., no spatial or temporal dependencies. 
When given a:
* Time Series: this means that we assume there are no temporal correlations.
* Spatial Field - this means that we assume that there are no spatial correlations.
* SpatioTemporal Field - we assume there are no spatial AND temporal correlations.

So the dataset will be:

$$
\mathcal{D} = \{ \boldsymbol{y}_n \}_{n=1}^{N}
\hspace{10mm}
\boldsymbol{y}_n\in\mathbb{R}^{D_y}
$$

where $N=N_s N_t$ are the total number of points in the spatiotemporal datacube.
When given a spatiotemporal datacube, this can be achieved through spatiotemporal aggregations, e.g., 
The reasoning is be

***

### Parametric Model



We assume we have a data likelihood given by:

$$
\boldsymbol{y} \sim p(\boldsymbol{y}|\boldsymbol{\theta})
$$

This distribution could be a Gaussian,a GEVD or a Pareto distribution.
We are interested in finding the best parameters, $\boldsymbol{\theta}$ given the observations, $\boldsymbol{y}$, i.e., the posterior.
The full Bayesian posterior can be written as

$$
p(\boldsymbol{\theta}|\boldsymbol{y}) = \frac{1}{Z}p(\boldsymbol{y}|\boldsymbol{\theta})p(\boldsymbol{\theta})
$$

where $Z$ is a normalization constant.
We can use any inference technique including approximate inference methods or sampling methods.



***  

### Conditional Parametric Model

We could also include some conditioning variables, $\boldsymbol{u}$.
The parameters, $\boldsymbol{\theta}$, will be functions of the conditioning variable and some hyperparameters, $\boldsymbol{\alpha}$.

$$
\begin{aligned}
\boldsymbol{y}|\boldsymbol{u} \sim p(\boldsymbol{y}|\boldsymbol{u},\boldsymbol{\theta},\boldsymbol{\alpha})
\end{aligned}
$$

Some ideas for conditioning variables, $\boldsymbol{u}$.

**Standard Variables**

* $\boldsymbol{u}$ - standard variables, e.g., temperature, precipitation, ENSO, etc. $\boldsymbol{\theta_\mu} = \exp \left( \mathbf{W}^\top\mathbf{u} + \mathbf{b}\right)$
* $t$ - temporal coordinate encoding, $\boldsymbol{\theta_\mu}=a\sin(2\pi t/\omega L)$
* $\mathbf{x}$ - spatial coordinates encoding 



***

### Generative Parametric Model

For this model, we assume that there is some underlying latent variable, $\boldsymbol{z}$, that underlines our process.

$$
p(\boldsymbol{y},\boldsymbol{z}) = p(\boldsymbol{y}|\boldsymbol{z})p(\boldsymbol{z})
$$

So, the data likelihood will be:

$$
\begin{aligned}
\boldsymbol{z} &\sim p(\boldsymbol{z}|\boldsymbol{\theta}) \\
\boldsymbol{y}|\boldsymbol{z} &\sim p(\boldsymbol{y}|\boldsymbol{\theta},\boldsymbol{z})
\end{aligned}
$$

***

### Non-Parametric Model

$$
\begin{aligned}
\boldsymbol{y}(\cdot) &\sim p(\boldsymbol{y}(\cdot)|\boldsymbol{\theta})
\end{aligned}
$$


***

## Time Series

This is a little more advanced whereby we assume that there are some temporal dependencies.
This dependency could be stationary or non-stationary.
In this case, our dataset is an order set of observations for each time step within some period, $\mathcal{T}=[0,T]$.

$$
\mathcal{D} = \{ \boldsymbol{y}_t \}_{t=1}^T
\hspace{10mm}
\boldsymbol{y}_t\in\mathbb{R}^{D_y}
$$


***

#### Temporal Encoding

Here, we assume that the parameters of the data are processes which are parameterized functions of time.


$$
\begin{aligned}
\boldsymbol{\theta} \sim p(\boldsymbol{\theta}|t,\boldsymbol{\alpha})
\end{aligned}
$$

where $t$ is the time and $\boldsymbol{\alpha}$ are the parameters of the distribution.
For example, the Gaussian distribution could have a parameterized mean and scale.
Similarly, the GEVD could have a parameterized mean, scale and shape.
Again, this function can be as simple or as complicated as necessary, e.g., a linear model, a basis function, a non-linear function or a stochastic process.
So, we have a conditional data likelihood term.

$$
\boldsymbol{y}\sim 
p(\boldsymbol{y}|\boldsymbol{\theta},t,\boldsymbol{\alpha})
$$

The posterior is given by

$$
p(\boldsymbol{\theta},\boldsymbol{\alpha}|\boldsymbol{y}) =
\frac{1}{Z}
p(\boldsymbol{y}|\boldsymbol{\theta},t,\boldsymbol{\alpha})
p(\boldsymbol{\theta}|t,\boldsymbol{\alpha})
p(\boldsymbol{\alpha})
$$

This is known as a Bayesian Hierarchical Model (BHM) because we have hierarchical processes and priors which condition the data likelihood.

***

#### Spatial Encoding

$$
\begin{aligned}
\boldsymbol{\theta} \sim p(\boldsymbol{\theta}|\mathbf{x},\boldsymbol{\alpha})
\end{aligned}
$$

where $t$ is the time and $\boldsymbol{\alpha}$ are the parameters of the distribution.
For example, the Gaussian distribution could have a parameterized mean and scale.
Similarly, the GEVD could have a parameterized mean, scale and shape.
Again, this function can be as simple or as complicated as necessary, e.g., a linear model, a basis function, a non-linear function or a stochastic process.
So, we have a conditional data likelihood term.

$$
\boldsymbol{y}\sim 
p(\boldsymbol{y}|\boldsymbol{\theta},\mathbf{x},\boldsymbol{\alpha})
$$

The posterior is given by

$$
p(\boldsymbol{\theta},\boldsymbol{\alpha}|\boldsymbol{y}) =
\frac{1}{Z}
p(\boldsymbol{y}|\boldsymbol{\theta},\mathbf{x},\boldsymbol{\alpha})
p(\boldsymbol{\theta}|\mathbf{x},\boldsymbol{\alpha})
p(\boldsymbol{\alpha})
$$

This is also a BHM because we have hierarchical processes and priors which condition the data likelihood.


***

#### State Space Model

Here, we assume that there is a latent variable, $\boldsymbol{z}$, which is described by a dynamical system.
We also have an optional control variable, $\boldsymbol{u}$, which could be influencing the hidden state.

$$
\begin{aligned}
\text{Initial Distribution}: && && \boldsymbol{z}_0 &\sim p(\boldsymbol{z}_0|\mathbf{\mu}_{z_0}, \mathbf{\Sigma}_{z_0})\\
\text{Transition Distribution}: && && \boldsymbol{z}_t &\sim p(\boldsymbol{z}_t|\boldsymbol{z}_{t-1},\boldsymbol{\alpha}_z) \\
\text{Emission Distribution}: && && \boldsymbol{\theta}_t &\sim p(\boldsymbol{\theta}_t|\boldsymbol{z}_t,\boldsymbol{\alpha}_\theta) \\
\text{Data Likelihood}: && && \boldsymbol{y}_t &\sim p(\boldsymbol{y}_t|\boldsymbol{\theta}_t)
\end{aligned}
$$

where $\boldsymbol{T_\theta}$ is the transition function for the latent variable, $\boldsymbol{z}_t$, and $\boldsymbol{h_\theta}$ is the emission function.
We are free to make these functions as complex as we see fit.
For example, we could have simple linear functions or more complex non-linear functions.
