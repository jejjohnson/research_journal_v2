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