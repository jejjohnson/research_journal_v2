---
title: Instrument-2-Instrument
subject: Instrument-2-Instrument
short_title: ITI
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


## Remote Sensing


From a high level, we have two types of satellites: stationary and orbiting.

**Stationary** satellites have a very good temporal frequency typically around from 15mins. 
However they have a poor spatial resolution and spatial coverage because they only look at a single point along the Earth at one time.
In addition, orbiting satellites are typically further away from the Earths surface (e.g. ~35,000 km) which enables a worse spatial resolution but a good compromise on the spatial coverage.

**Orbiting** satellites have a good spatial resolution and spatial coverage because they wrap around the entire globe. 
However, they have a poor temporal resolution and temporal coverage because their revisit time can be quite infrequent compared to a stationary satellite.
For example, MODIS has a revisit time of 2 days ([source](https://gisgeography.com/modis-satellite/)) whereas LANDSAT has a revisit time of 8 days.
In addition, orbiting satellites are typically closer to the Earths surface (e.g. 200-1,000 km) which enables a better spatial resolution.

## Problem Formulation

We are given datasets within two different domains

$$
\begin{aligned}
\text{Dataset I}: && &&
\boldsymbol{u} &= \boldsymbol{u}(\mathbf{s},t), && &&
\boldsymbol{u}: \mathbb{R}^{D_s}\times\mathbb{R}^+\rightarrow\mathbb{R}^{D_u} && 
\mathbf{s}\in\Omega_u\subset\mathbb{R}^{D_s} &&
t\in\mathcal{T}_u\subset\mathbb{R}^+ \\
\text{Dataset II}: && &&
\boldsymbol{a} &= \boldsymbol{a}(\mathbf{s},t), && &&
\boldsymbol{a}: \mathbb{R}^{D_s}\times\mathbb{R}^+\rightarrow\mathbb{R}^{D_a} && 
\mathbf{s}\in\Omega_a\subset\mathbb{R}^{D_s} &&
t\in\mathcal{T}_a\subset\mathbb{R}^+ 
\end{aligned}
$$

Our objective is to find a transformation that maps dataset I to dataset II.

$$
\boldsymbol{f}: \left\{\boldsymbol{u}:\Omega_u\times\mathcal{T}_u\right\}
\rightarrow\left\{\boldsymbol{a}:\Omega_a\times\mathcal{T}_a\right\}
$$

In general, we have a 

$$
\begin{aligned}
\text{Encoder}: && &&
\mathbf{z}_u &= \text{Encoder}(\mathbf{x},\boldsymbol{\theta}) \\
\text{Transformation}: && &&
\mathbf{z}_a &= \text{Transformer}(\mathbf{z}_u), && &&
\mathbf{s}\in\mathbb{R}^{D_{z_u}}\\
\text{Decoder}: && &&
\mathbf{a} &= \text{Decoder}(\mathbf{z}_a,\boldsymbol{\theta}), && &&\\
\end{aligned}
$$

## Foundational Models

This pipeline is a general pipeline to be able to translate between different satellites. 
However, we can go further and


### Detection

A common subset of methods include detection problems.
These are problems where we want to estimate a discrete variable.
These can include items like buildings or cars.
They can also include more physics-based things like clouds or cars.


***
### Estimation

In all cases, we can derive many variables just with the radiance values.

**Temperature**.

**Sea Surface Temperature**.

**Colour**