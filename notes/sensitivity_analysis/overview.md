---
title: Sensitivity Analysis - Problem Formulation
subject: Misc. Notes
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
keywords: data
---


> How uncertainty in the output of a model can be apportioned to different sources of uncertainty in the model input - Andrea Saltelli, 2007


**Local Sensitivity Analysis**.
A method based on derivatives, $\partial_x f(x;\theta)$.
It is computationally efficient.
However, it does not consider input uncertainty and model non-linearity.

**Global Sensitivity Analysis**.
A method based on simulations, $x^{(k)}\sim p(x;\theta)$.
This method is more computationally expensive.
It is used to hollistically assess uncertainty and model behaviour.
It can be used to reduce the dimensionality and/or inform additional experiments.


## Relationship to Uncertainty

In general, both SA and UQ are absolutely necessary for doing post-model analysis.

1. Propagate Input Uncertainties

**Generate viable Monte Carlo simulations**.

2. Analyze the Input-Output Dataset

**Quantify Uncertainty**.
How uncertain are model outputs given uncertain inputs?

**Quantify Sensitivity**.
Which inputs mostly contribute to the output uncertainty?

**Stress Testing**.
What designs perform well enough across a large range of inputs?
What are threshold values in the inputs that lead to "good enough outputs"?