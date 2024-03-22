---
title: ML4EO
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


***
## Community

I personally think that the community needs an upgrade about what's possible.

### Good News 

Tackling problems at a global scale requires resources and talent that the academic community does not have. 
So we need to leave these experiments up to larger entities like Google, NVidia, ECMWF.

#### Multi-Platform Language: JAX

The more I work with JAX, the more I am convinced that this is the greatest addition to the scientific commuity.
It allows you to do autodiff, JIT your code, and automatic vectorization.
In addition, it is hardware agnostic so you can use it with CPUs, GPUs, and TPUs with a very intuitive way to scale it.
The best part is that it keeps the exact same API as one that everyone is familiar with: numpy and scipy.

***
#### AutoDifferentiation

I think there is a great opportunity to rethink how we do our science now that we have autodifferentiation. 
In fact all numerical methods should take into account the fact that we can do many optimization problems using autodiff.
In addition, there are many cases where we cannt write down the functional form to optimize our system.
It shifts the thinking of *what we want to optimize* instead of *how to optimize what we want*.


***
#### Inference: MCMC

It's time for MCMC to make a comeback.
Many papers say that they did not use MCMC because *it was too expensive*.
For many problems that academics face, this is not true.
MCMC is very scalable nowadays.
In fact, if you factor in the time it took you get the approximate inference scheme to work then it might be even faster.
Even in the cases where MCMC isn't scalable, there are a number methods that are available to speed-up MCMC, scale-up MCMC, or speed-up the convergence.

***
#### Clustering

I think clustering is undervalued within the community. 

**Dimensionality**. 
It gives us a way to deal with dimensionality.
We can use clustering regimes to partition a spatial field or discretize a continuous field.
Its a nice way to reduce the complexity of our system and look for patterns.

**Similarity**.
It also gives us a way to find similar instances of a phenomena of our choosing.
For example, we may have the perfect example of a jet-stream and we want to acquire similar instances.
One could using clustering to.
This is known in many geoscience communities as analogous.




On an academic scale, there are many things we can do!

* Academic Scale - MCMC, AutoDiff
* Discovery - Clustering, Equation Discovery

Bad News
* 


***
### **Problem Formulations**

> The overview can be viewed through the lens of *operator learning*.

$$
\boldsymbol{f}: 
\left\{ \boldsymbol{x}:\boldsymbol{\Omega}_x\times\mathcal{T}_x \right\}
\times
\boldsymbol{\Theta}\rightarrow
\left\{\boldsymbol{u}:\boldsymbol{\Omega}_u\times\mathcal{T}_u \right\}
$$

- Interpolation
- Extrapolation
- Variable Transformation

***
### **Discretization**

> To go from observations to models, we almost always need to have some sort of structure.
> We will look at the tried and true classic of the discretization methods: histogram binning.
> We will also look at some extra things we can do when creating histograms like defining specifying the binning from prior knowledge.
> We will also look at more adaptive binning methods for more irregular structures.

- Histogram Formulation (**TODO**)
- Equidistant Binning 4 Cartesian Grids (**TODO**)
- Adaptive Binning 4 Rectilinear & Curvilinear Grids (**TODO**)
- Graph-Node Binning (**TODO**)

***
### **Nonparametric Interpolation**


***
### **Coordinate-Based Parametric Interpolator**


***
### **Field-Based Parametric Interpolators**



***
### **Parametric Dynamical Models**

$$
\boldsymbol{f} : \mathbb{R}^{D_\Omega}\times\mathbb{R}^+\times\mathbb{R}^{D_\theta}\rightarrow\mathbb{R}^{D_\Omega}
$$


- Operator Learning Revisited - Universal Differential Equations
- Whirlwind Tour - Spatial Operators
- Training
	- Experimental Setup - OSSE vs OSE
	- Online
	- Offline
- Spatial Operators Deep Dive
	- Linear Spatial Operator & MLP
	- Convolutions
	- FFT Convolutions
	- Spectral Convolutions
	- Transformers
	- Graphical Models
- Bayesian Filtering
	- State Space Models
	- Parameter & State Inference in SSMs
	- Linear Models + Exact Inference - KF
	- Non-Linear Model + "Exact" Inference - EKF, UKF, ADF
	- Whirlwind Tour of Deterministic Inference for SSMs
	- Amortized Variational Posteriors (Encoders)
	- Whirlwind Tour of Stochastic Inference for SSMs
- Nonparametric Revisited
    - Markovian Gaussian Processes
    - Sparse Markovian Gaussian Processes
- Latent Generative Dynamical Models
	- Latent State Space Models
	- Conjugate Transforms - Conditional Markov Flows
	- Stochastic Transform Filters
	- Observation Operator Encoders
	- Stochastic Differential Equations
	- Neural Stochastic Differential Equations