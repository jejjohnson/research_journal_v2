


## Baseline

**Algorithms**:
* [Inverse Weighted Distances](https://pangeo-pyinterp.readthedocs.io/en/latest/generated/pyinterp.RTree.inverse_distance_weighting.html#pyinterp.RTree.inverse_distance_weighting)
* [Radial Basis Function](https://pangeo-pyinterp.readthedocs.io/en/latest/generated/pyinterp.RTree.radial_basis_function.html#pyinterp.RTree.radial_basis_function)
* [Window Function](https://pangeo-pyinterp.readthedocs.io/en/latest/generated/pyinterp.RTree.window_function.html#pyinterp.RTree.window_function)
* [Universal Kriging](https://pangeo-pyinterp.readthedocs.io/en/latest/generated/pyinterp.RTree.universal_kriging.html#pyinterp.RTree.universal_kriging)


***
## Gaussian Processes

* Scratch: Gaussian Processes + Jax + Cola
* Library: GPJax + Cola
* Custom Library: TinyGP + Cola + Custom Solver


***
## Scaling I - Hardware

* Scratch: KeOPs + Gaussian Processes
* Library: KeOPs + GPyTorch
* Library: KeOps + Nystrom


***
## Scaling II - Algorithm

> Here, we try to take advantage of algorithm speed-ups

### Model Approximations

* RBFSampler/Nystrom + Linear SGD
* KeOps GPU + Gaussian Kernel

### Sparse Approximations

> These methods are some speed-ups that can be achieved from using SOTA Gaussian processes.

* Sparse Gaussian Process (SGP)
* Stochastic Variational Gaussian Processes (SVGP)
* KISS-GP
* Deep Kernel Learning

### Basis Functions

* Deep Kernel Learning
* RFF Gaussian Processes
* Spherical Gaussian Process

### Dynamical

* Linear Kalman Filter
* Non-Linear Kalman Filter
* Markovian Gaussian Processes




***
## Engineering Tricks



### Feature Engineering


**Scaling** - MinMaxScaler, StandardScaler

**Temporal Features** - Coordinates, Cyclic, Splines, Fourier Features, Sinusoidal Features

**Spatial Features** - Coordinate Transforms (Cartesian, Spherical, Cylindrical), Cycle, Splines, Fourier Features, Spherical Harmonics


### Patches vs Radius

