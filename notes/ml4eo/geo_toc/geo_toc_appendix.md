---
title: ML4EO - TOC Apps
subject: ML4EO
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


## Parameterizations

**Linear** 

* Fully Connected
* Convolutions & Differentials
* Structured
* Differential

**Non-Linear**

* Fully Connected
* Spectral Convolution


## Databases

* Spatiotemporal Database
* DVC + GDrive


***
## Appendix


**Database** [`DVC`,`GDrive`].
We will need a database to store our raw and geoprocessed data.
In addition, we will need to store our model parameters and resulting figures.

**Representation** [`Raster`, `Point Cloud`]. 
We will need to represent our weather stations as point clouds and we may also need to represent them as Rasters.
So a blog post will be decided to showcase how we can move between them.

**Masks** [`Country`, `Land/Ocean`].
We need to mask our data

**Masked Likelihoods** [`GPD`, `TPP`].

**Gaussian Processes** [`GP`, `Kriging`, `Kernel Methods`].

**Sparse Gaussian Processes** [`SGP`].

**Sensitivity Analysis** [`MC`, `Gauss Approx`, `Taylor`, `Unscented`, `Moment Matching`]

**Numpyro + PPL I - Model** [`Prior`, `Likelihood`, `Posterior`, `Prior Predictive Posterior`].

**Numpyro + PPL II - Guide** [`MLE`, `MAP`, `Laplace`, `VI`, `MCMC`, `HMC`].

**Missing Data**.
e.g., Convolutions, Gaussian Processes