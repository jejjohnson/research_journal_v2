---
title: Dynamical-Based Interpolation
subject: ML4EO
short_title: Dynamical
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