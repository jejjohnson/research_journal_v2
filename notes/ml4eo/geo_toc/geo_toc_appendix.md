---
title: Appendices
short_title: Appendices
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
## **Appendix**


**Database** [`DVC`,`GDrive`].
We will need a database to store our raw and geoprocessed data.
In addition, we will need to store our model parameters and resulting figures.

**Representation** [`Raster`, `Point Cloud`]. 
We will need to represent our weather stations as point clouds and we may also need to represent them as Rasters.
So a blog post will be decided to showcase how we can move between them.

**Masks** [`Country`, `Land/Ocean`].
We need to mask our data

**Masked Likelihoods** [`GPD`, `TPP`].


**Sensitivity Analysis** [`MC`, `Gauss Approx`, `Taylor`, `Unscented`, `Moment Matching`]

**Numpyro + PPL I - Model** [`Prior`, `Likelihood`, `Posterior`, `Prior Predictive Posterior`].

**Numpyro + PPL II - Guide** [`MLE`, `MAP`, `Laplace`, `VI`, `MCMC`, `HMC`].

**Missing Data**.
e.g., Convolutions, Gaussian Processes, Masked-Likelihoods

**CRS, Transform, Bounds, Resolution**.


***
#### Preprocessing

**Extreme Values** [`BM`, `POT`, `TPP`]

***
#### Algorithms

**Gaussian Processes** [`GP`, `Kriging`, `Kernel Methods`].

**Sparse Gaussian Processes** [`SGP`].

**Ensemble Kalman Filter** [`EnsKF`]



***
#### Other


* Differentiation
  * Symbolic - [Blog](https://python.plainenglish.io/how-is-symbolic-differentiation-done-in-python-using-sympy-6484554f25b0)
  * AutoDifferentiation - [Blog](https://theoryandpractice.org/stats-ds-book/autodiff-tutorial.html )
  * Finite Difference --> Convolutions
* Fourier --> Convolutional FFT
* Poisson Solver --> CG, FFT, DST, DCT
* Gaussian Kernel Matrix --> Process Convolutions
* Kernel Matrix --> NN Tapering
* Nearest Neighbours --> Gaussian Distance

---

* Woodbury, Nystrom, Inducing Points
* PCA --> SVD --> rSVD
* GPs: Moment, Spectral, Markovian
* Plug-N-Play Priors: GP, PCA
* Minimization
* Missing Values: Masks, Fill, Iterative, Numpyro Masks Dist, Zeros RS
* DMD, Convolution, Spectral Convolution
* Finite Elements --> Graphs, Adjacency Matrix, Spatial Weights, Gaussian Distance

---
**Algorithms**

* Gaussian Processes
  * Scratch: Numpyro + JAX
  * Custom Library: TinyGP + Lineax + Numpyro

---
**Architectures**

* Convolutions 
  * Convolutions & Finite Differences
  * More on Convolutions - 1x1, FOV, Separable, DepthWise
  * FFT Convolutions via PseudoSpectral Methods
  * Missing Values
    * Masks
    * Partial Convolutions
* Transformers
  * Attention is All You Need
  * Transformers and Kernels
  * Missing Data + Masked Transformers
* Graphical Models
  * Graphs and Finite Element Methods
  * Missing Data

---
**ROM**

* Dimensionality Reduction - What is it and why do we need it, e.g., (SWM, Linear SWM, ROM)
* AutoEncoders
  * Linear - PCA/EOF/POD/SVD
  * Convolutions
  * Spectral Convolutions
  * Transformers (Masked AutoEncoder)
  * Graphs

---
**Multiscale**

* Introduction to Multiscale - Power Spectrum Approach
* U-Net I - CNN
* U-Net II - Spectral Convolution
* U-Net III - Transformers
* U-Net IV - Graphs


---
**Objective-Based Approaches**

* Implicit Models
  * Fixed Point & Root-Finding
  * Argmin Differentiation
  * Deep Equilibrium Models
* Implementation
  * From Scratch - [Blog](https://teddykoker.com/2022/04/learning-to-learn-jax/)
  * `JaxOpt`, `Optimistix`
* Adjoints
  * Scratch - [Blog](https://cundy.me/post/the_adjoint_method_in_a_dozen_lines_of_jax/)
  * Optimistix - [Docs](https://docs.kidger.site/optimistix/api/adjoints/)
  * Diffrax - [Docs](https://docs.kidger.site/diffrax/api/adjoints/)


---
**Conditional Generative Models**

* Latent Variable Models
* Bijective
* Surjective
* Stochastic
* Gradient Flows, Stochastic Interpolants


---
**Engineering Tricks**

* Scaling - MinMax, StandardScaler
* TemporalFeatures - Coords, Cyclic, Splines, Fourier Features, Sinusoidals
* SpatialFeatures
  * Coordinate Transforms (Cartesian, Spherical, Cylindrical)
  * Cycle, Splines, Fourier Features
  * Spherical Harmonics


---
**Numpyro Tutorials**

* Simple IID Model
* Equinox Integration
* Bayesian Hierarchical Model
* Inference
  * Custom Variational Posterior
* Gaussian Processes
* Sparse Gaussian Processes
* Neural ODE
* Linear State Space Model
* Kalman Filter
* Structured State Space Model
* Deep Markov Model


---
**Keras Tutorial**

