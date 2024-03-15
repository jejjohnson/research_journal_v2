---
title: ML4EO
subject: ML4EO
short_title: Non-Parametric Interpolation
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



> In this section, we will look at some of the staple methods for nonparametric interpolation.
> We will outline each

- Naive Whirlwind Tour with applications for Data Assimilation
- Nearest Neighbours
	- K-NN
	- Weighted Distances
	- Scaling the Algorithm - KDTree + BallTree
	- Scaling the hardware - parallelization, GPU hardware
- Kernel Density Estimation
	- KDE 
	- FFT for Equidistant Grids
	- scaling the hardware - GPU hardware
	- Regression
- Gaussian Processes
	- Appendix: Playing with All things Gaussian
	- Spatial Autocorrelation with (Semi-)Variograms
	- 3 Views of GPs
	- GP with Numpyro
	- Scaling - Kernel Approximations
	- Scaling - Inducing Points
	- Scaling - 
	- Appendix GPs in practice
		- From Scratch
		- With TinyGP & GPJax
		- With PPL Numpyro
		- Customizing the Numpyro Implementation
		- Distances
		- Kernel Matrices
		- Kernel Matrix Derivatives
- Improved Gaussian Processes
	- Moment-Based
		- Sparse GPs
		- SVGPs
		- Structured GPs
		- Deep Kernel Learning
	- Basis Functions
		- Fourier Features GP
		- Spherical Harmonics GP
		- Sparse Spherical Harmonics GPs
