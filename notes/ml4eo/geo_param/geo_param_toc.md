---
title: Geo-Modeling
subject: ML4EO
short_title: Parameterization - TOC
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



***
### Overview

* Inspiration - Anatomy of a PDE
* Data Discretization
* I - State Space Models
* II - Spatial Operators
* III - Reduced Order Models
* IV - TimeSteppers


***
### **Anatomy of a PDE**


* State
* Discretization
* Equation of Motion - Spatial Operators
* Initial Conditions
* Boundary Conditions
* TimeSteppers


***
### Data Discretization

* Unstructured, e.g., Weather Stations
* Irregular, e.g., Continents, Countries...
* Curvilinear, e.g., 2D Lat-Lon Coordinates, SWATHs
* Rectilinear, e.g., Geographic Coordinates
* Regular, e.g., Images, GeoStationary Satellites

***
### Parameterization


***
#### I - State Space Models

* Emission Distribution, $y_t \sim p(y_t|z_t,\theta)$
* Transition Distribution, $z_t \sim p(z_t|z_{t-1},x_t,\theta)$
* Initial Distribution, $z_0 \sim p(z_0|\theta)$
* Parameter Distribution, $\theta \sim p(\theta)$


***
#### II - Spatial Operators

* Differentiation
    * Exact - Symbolic, AutoDiff
    * Approximate - Finite Difference/Volume
* Neural Operators
    * Fully Connected
    * AutoDifferential + Symbolic
    * Convolutions + Finite Difference
    * Spectral Convolutions + PseudoSpectral
    * Graphical NNs + Finite Element
    * Free-Form
* Free-Form Complexity
    * Linear
    * Basis Function
    * Non-Linear


***
#### III - Reduced Order Models

* Encoder + Decoder, $z = f(u), u = g(z)$
* Bijections, Surjections, Stochastic
* Separable (POD), $u(s,t) = \sum \phi(s)\psi(t)$
* Structured


***
#### IV - TimeSteppers

* Integration
* AutoRegressive
* Taylor - Euler
* Sigma Points - Unscented
* Quadrature - Runge-Kutta
* Monte Carlo
* Hybrid - Leap-Frog, Adam-Bashforth