---
title: AI 4 Story Lines
subject: Available Datasets in Geosciences
short_title: AI 4 Story Lines
authors:
  - name: J. Emmanuel Johnson
    affiliations:
      - CSIC
      - UCM
      - IGEO
    orcid: 0000-0002-6739-0053
    email: juanjohn@ucm.es
license: CC-BY-4.0
keywords: simulations
abbreviations:
    ERA5: ECMWF Reanalysis Version 5
    CMIP6: Coupled Model Intercomparison Project Phase 6
    AMIP6: Atmospherical Model Intercomparison Project Phase 6
    PDEs: Partial Differential Equations
    RHS: Right Hand Side
    TLDR: Too Long Did Not Read
    SSP: Shared Socioeconomic Pathways
    CDS: Climate Data Store
---

> This is a summary of my interpretation for the AI for StoryLines.


## Objective

The objective of this project is to try and explain some characteristics for how they do "storylines". 
This is done by using 


## Model

We are interested in finding a predictive model

$$
\boldsymbol{a}(\mathbf{x},t) = \boldsymbol{f}[\boldsymbol{u};\boldsymbol{\theta}](\mathbf{x},t)
$$

Here, the variable, $\boldsymbol{u}$, is the **driver**, i.e., the causal variable.
$\boldsymbol{a}$ is the variable of interest.

In general, to estimate extremes, we are interested in looking at differences.