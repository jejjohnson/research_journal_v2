---
title: GMTL
subject: Modern 4DVar
subtitle: Overview
short_title: Overview
authors:
  - name: J. Emmanuel Johnson
    affiliations:
      - CNRS
      - MEOM
    orcid: 0000-0002-6739-0053
    email: jemanjohnson34@gmail.com
license: CC-BY-4.0
keywords: data-assimilation, open-science
abbreviations:
    GP: Gaussian Process
---

**Hierarchical Assemblage of Hypothesis**

* Conservation Laws
* System Discretization
* Process Parameterization
* Uncertainty Quantification
* Solution Procedure
* Sensitivity Analysis
* Iterative Hypothesis Refinement

***
## **Conservation Laws**

1. Model Components
2. Game of Dependencies
3. Model Forms

### Model Components

* Quantity of Interest
* Observations
* Latent Variables
* Parameters
* State

***

### Game of Dependencies

* Time & Space - Independent
* Time & Space - Partially Dependent
* Space - Globally Dependent
* Time - Autoregressive

### Model Form

* Unconditional vs Conditional
* Parametric vs Generative
* Static vs Dynamical

***
## **System Architecture**

1. Process Discretization
2. Discretization

***
### **Process Discretization**

* Scale: Small <--> Large
* Region -> Global, Local
* Spatial Resolution 
* Period
* Frequency

***
### **Data Discretization**

* Regular
* Rectilinear
* Curvilinear
* Unstructured Grid - (Finite Element, Finite Volume, Graphs) | (Line Segments, Triangles, Quadilaterals, Tetrahedrals)
* Point-Clouds



***
## **Process Parameterization**

### **Model Form**

* Linear -> Differential, Low-Rank, Reduced Order
* Basis Function
* Non-Linear
* Neural Network
* Functional - Neural Field, DeepONer, Neural Operator


## **Uncertainty Quantification**

* Deterministic
* Probabilistic
* Bayesian

## **Sensitivity Analysis**

* Local - Derivative
* Global - Monte Carlo (Sobol Indices)
