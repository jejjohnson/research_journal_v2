---
title: ML4EO Abstractions
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


## Goals

* Objective
* Task

## Estimation vs Learning

> Using models as a means of estimating or predicting a QoI.

> Using models as a means of *learning*.

## Modeling & Simulation

* Earth System
* Abstraction -> Model
* Measurements -> Data
* Model -> Predictions


***
## **Hierarchical Assemblage of Hypothesis**

* Conservation Laws
* System Discretization
* Process Parameterization
* Uncertainty Quantification
* Solution Procedure
* Sensitivity Analysis
* Iterative Hypothesis Refinement

***
## **ML4EO**


### **Geo Tasks**

* Interpolation - Missingness
* Extrapolation - Data Drift, Distribution Shift, Bad Generalization
* Variable Transformation - Multivariate, High Correlation
* Feature Extraction - Ad-hoc, Foundation Models, Downstream Tasks, Transfer Learning

### **Geo Issues**

* Measurements
* Data Shape
* Model
* Solution Procedure

***
### **Geo Operations**

***
### **Game of Spatiotemporal Dependencies**

* IID
* Partial
* Global
* Autoregressive

***
## **Operator Learning**

* Space
* Time
* Quantity
* Shape
* Transformation



***
## **Hierarchical Sequence of Decisions**


***
## **Data-Driven Modeling Elements**

* Measurements
* State
* Quantity of Interest
* Latent Variable

***
## **Bayesian Modeling**

* Data Likelihood
* Prior
* Posterior
* Marginal Likelihood
* Prior Prediction
* Posterior Prediction
* Sampling
* Inference

***
## **Discretization**

* Regular
* Rectilinear
* Curvilinear
* Unstructured - FEM/FVM/GNNs (line segments, triangles, quadrilateral, tetrahedral)
* Point Clouds

***
## **Parameterization Complexity**

**Parametric**
* Linear
* Basis Function
* Neural Network

**Functional**
* Neural Fields
* Deep ONets
* Neural Operators

***
## **Machine Learning Abstractions**

* Data Module
* Model
* Criteria
* Optimizer
* Learner

***
## **Model Form**

- Parametric
- Generative
- Conditional Parametric
- Conditional Generative
- Dynamical

***
## **Software**

* Hardware Agnostic Tensor Libraries
* AutoDifferentiation
* Deep Learning
* Probabilistic Programming Libraries
* Data Pipelines