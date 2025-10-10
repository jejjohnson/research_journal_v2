---
title: JAX Stack
subject: My JAX Stack
short_title: JAX Stack
authors:
  - name: J. Emmanuel Johnson
    affiliations:
      - CSIC
      - UCM
      - IGEO
    orcid: 0000-0002-6739-0053
    email: juanjohn@ucm.es
license: CC-BY-4.0
keywords: data
---

> Here are my favourite JAX packages.

## **Tutorials**


[**Advanced Scientific Machine Learning**](https://predictivesciencelab.github.io/advanced-scientific-machine-learning/intro.html).
This is a set of tutorials which are **Application-Based**.
I think there is value in learning JAX from an application-based stand point.
I personally like the scientific machine learning perspective.
Some highlights include tutorials on [functional programming](https://predictivesciencelab.github.io/advanced-scientific-machine-learning/functional_programming/00_intro.html), [differentiable programming](https://predictivesciencelab.github.io/advanced-scientific-machine-learning/differentiation/00_intro.html), and [optimization](https://predictivesciencelab.github.io/advanced-scientific-machine-learning/optimization/00_intro.html).

[**Bayesian Modelling and Probabilistic Programming with Numpyro, and Deep Generative Surrogates for Epidemiology**](https://elizavetasemenova.github.io/prob-epi/01_intro.html).
This is easily the best course to learn about probabilistic programming through the lens of JAX and numpyro.
I find it very useful when thinking probabilistically.
Some highlights include the [Bayesian Workflow](https://elizavetasemenova.github.io/prob-epi/11_Bayesian_workflow.html), [Gaussian Processes](https://elizavetasemenova.github.io/prob-epi/17_GP_priors.html), and even [ODEs!](https://elizavetasemenova.github.io/prob-epi/22_ODEs.html).

[Jax 101](https://jax.readthedocs.io/en/latest/tutorials.html).
These set of tutorials are very exhaustive in terms of the features of JAX.
They are very neural network focused but they cover every aspect of why someone would want to use JAX.
Some highlights include **jax essentials** like [JIT compilation](https://jax.readthedocs.io/en/latest/jit-compilation.html), [automatic vectorization](https://jax.readthedocs.io/en/latest/automatic-vectorization.html), [automatic differentiation](https://jax.readthedocs.io/en/latest/automatic-differentiation.html).
However, there are some more interesting tutorials like [PyTrees](https://jax.readthedocs.io/en/latest/working-with-pytrees.html), [Stateful Computations](https://jax.readthedocs.io/en/latest/stateful-computations.html) and even [parallel computing](https://jax.readthedocs.io/en/latest/sharded-computation.html).


[Autodidax: JAX from Scratch](https://jax.readthedocs.io/en/latest/autodidax.html).
This is more for hardcore devs who are very interested in understanding the underlying aspects of JAX.
It really takes you step-by-step into some of the inner workings in an interesting way.
I think it's worth it to just take a look for awareness.
However, unless you plan to develop your own packages, it may not be necessary.


***
## **Special DataStructures**

* [coordinax ](https://github.com/GalacticDynamics/coordinax)
* [jaxdf](https://github.com/ucl-bug/jaxdf)
* [tree-math](https://github.com/google/tree-math)
* [xarray_jax](https://github.com/google-deepmind/graphcast)
* [quax](https://github.com/patrick-kidger/quax)
* [jaxtyping](https://docs.kidger.site/jaxtyping/)

***
## **Symbolic Math**

* sympy2jax

***

## **Numerical Methods**

### **Linear Algebra**
* Cola, [Lab](https://github.com/wesselb/lab)
* [autoray](https://autoray.readthedocs.io/en/latest/)
* [einx](https://github.com/fferflo/einx)
* [einops](https://github.com/arogozhnikov/einops)
* [**matfree**](https://github.com/pnkraemer/matfree) - Matrix-Free linear algebra in JAX
* [**opt-einsum**](https://github.com/dgasmith/opt_einsum) - optimized einsum (numpy, JAX, TF, PyTorch, Dask, CuPy, Sparse)


***
### **Convolutions**

* [Kernex](https://github.com/ASEM000/kernex)
* [Serket](https://serket.readthedocs.io/API/convolution.html#serket.nn.spectral_conv_nd)

***
### **Integration**

[torchquad](https://github.com/esa/torchquad),

***
### **Interpolation**

* [interpax](https://github.com/f0uriest/interpax)
* [Nyx](https://github.com/stanbiryukov/Nyx)
* [RBF](https://github.com/treverhines/RBF)



***
### **Optimization**

* Optimistix
* LineaX
* Optax
* JaxOp
* [varz](https://github.com/wesselb/varz) - Simple, multi-backend constrained (L-BFGS) and unconstrained optimization (Adam).
* [ott](https://github.com/ott-jax/ott)


***
### **Kernels**

* [**mlkernels**](https://github.com/wesselb/mlkernels) - Kernel Matrices (JAX, TF, PyTorch, Julia).
* [KernelBiome](https://github.com/shimenghuang/KernelBiome/blob/fed4e05c0a1b83deb437a9759b6d941fe08abe01/kernelbiome/kernels_jax.py)

***
### **Differentiation**

* FiniteDiffX, FiniteVolX, SpectralDiffX
* [jax-fem](https://github.com/deepmodeling/jax-fem)
* [Probfindiff](https://github.com/pnkraemer/probfindiff)
* [LapJax](https://github.com/YWolfeee/lapjax)
* [RBF-FDax](https://github.com/kvndhrty/RBF-FDax)

***
### **ODESolvers**

* Diffrax, 
* [**probdiffeq**](https://github.com/pnkraemer/probdiffeq) - probabilistic solvers for differential equations

***
### **Ordinary Differential Equations**

* [DiffEqZoo](https://github.com/pnkraemer/diffeqzoo)
* [Dysts](https://github.com/williamgilpin/dysts)
* [sdeint](https://github.com/mattja/sdeint)

***
### **Partial Differential Equations**

*  [pyqg-jax](https://github.com/karlotness/pyqg-jax)
[pyshocks](https://github.com/alexfikl/pyshocks)
* somaX,
* [dinosaur](https://github.com/google-research/dinosaur)
* [veros](https://github.com/team-ocean/veros)




***
### **Basis Functions**

#### **PCA/SVD/POD/EOF**

* [pcax](https://github.com/alonfnt/pcax)

#### **Fourier**

* [s2fft](https://github.com/astro-informatics/s2fft)

#### **Orthogonal**
* [orthojax](https://github.com/PredictiveScienceLab/orthojax)
* [orthax](https://github.com/f0uriest/orthax)
* [s2ball](https://github.com/astro-informatics/s2ball)

#### **Wavelet**

* [jax-wavelet-toolbox](https://github.com/v0lta/Jax-Wavelet-Toolbox)
* [cr-wavelets](https://github.com/carnotresearch/cr-wavelets)
* [s2wav](https://github.com/astro-informatics/s2wav)

#### **Spherical Harmonics**

* [**SphericalHarmonics**](https://github.com/vdutor/SphericalHarmonics) - spherical harmonics (numpy, JAX, PyTorch, TF)
* [Jax Implementation](https://jax.readthedocs.io/en/latest/_autosummary/jax.scipy.special.sph_harm.html)


*** 
## **Neural Networks**

* Equinox
* Flax
* [Keras](https://github.com/keras-team/keras)
* [serket]()



***
## **Probabilistic**


### **Probabilistic Programming Languages**

* blackjack, 
* numpyro
* [numpyro-ext](https://github.com/dfm/numpyro-ext)
* tfp.substrate.jax
* [bayeux](https://github.com/jax-ml/bayeux)

### **Distributions**

* [efax](https://github.com/NeilGirdhar/efax)
* [fenbux](https://github.com/JiaYaobo/fenbux)

### **Samplers**

* [jaxns](https://github.com/Joshuaalbert/jaxns)
* [SGMCMCJax](https://github.com/jeremiecoullon/SGMCMCJax) - stochastic Gradient samplers in jax
* [jax-sgmc](https://github.com/tummfm/jax-sgmc) - stochastic gradient samplers in jax

### **Normalizing Flows**

* [FlowMC](https://github.com/kazewong/flowMC)
* [flowjax](https://github.com/danielward27/flowjax)

### **Gaussian Processes**

* [GPJax](https://github.com/JaxGaussianProcesses/GPJax)
* [TinyGP](https://tinygp.readthedocs.io/en/latest/index.html)

### **State Space Models**

* [Dynamax](https://github.com/probml/dynamax)
* [ReBayes](https://github.com/probml/rebayes)
* [sts-jax](https://github.com/probml/sts-jax)
* [dynax](https://github.com/fhchl/dynax)

## **Image Processing**

* [dm-pix](https://github.com/google-deepmind/dm_pix)

## **Units**

* [jpu](https://github.com/dfm/jpu)



***
## **Parallel Programming**
* [mpi4jax](https://github.com/mpi4jax/mpi4jax)
* [paxml](https://github.com/google/paxml)
* [Jax-Parallel](https://astralord.github.io/posts/exploring-parallel-strategies-with-jax/)
