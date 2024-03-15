---
title: Field-Based Interpolation
subject: ML4EO
short_title: Field-Based
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

- Interpolation Operator: A Physics-Informed Approach (Spatiotemporal Decomposition)
- Abstraction: Amortization vs Objective-Based
- Whirlwind Tour for 3 Architectures - CNNs, Transformers, Graphs
- Convolutions
	- Explaining Convolutions via Finite Differences
	- More on Convolutions - FOV, Separable, 
	- FFT Convolutions via Pseudospectral Methods
	- Missing Values & Masks
	- Partial Convolutions
- Transformers
	- Attention is All You Need
	- Transformers & Kernels
	- Missing Data - Masked Transformers
- Graphical Models
	- Graphs and Finite Element Methods
	- Missing Data
- Dimension Reduction
	- Dimensionality Reduction - What is it and why we need it? (SWM vs Linear SWM vs ROM)
	- AutoEncoders I - PCA/EOF/SVD/POD
	- AutoEncoders II - CNNs
	- AutoEncoders III - Transformers (MAE)
	- AutoEncoders IV - Graphs
- Multiscale
	- Introduction to Multiscale - Power Spectrum Approach
	- U-Net I - CNN
	- U-Net II - Transformers
	- U-Net III - Graphs
- Objective-Based Approaches
	- Implicit Models I - Fixed Point/Root Finding
	- Implicit Models II - Argmin Differentiation
	- Implicit Models III - Deep Equilibrium Models 
	- From Scratch
	- Packages - JaxOpt, optimistix
- Conditional Generative Models
	- Latent Variable Models
	- Bijective Flows
	- Stochastic Flows
	- Surjective Flows
	- Stochastic Interpolants