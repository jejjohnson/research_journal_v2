---
title: Data-Driven Numerical Weather Prediction
subject: Forecasting
short_title: AI4NWP
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

## Table of Contents

**Setup**. 
Motivation behind weather predictions.
We care about knowning the weather, the climate and the extremes.
This leads us to a forecasting problem.

**Data Representation**.
Geoscience data has 3 elements: Space, Time, and Variables

**Data**.
Observational Biases.
We have access to observations and reanalysis data.


**Architecture**.
Inductive Biases. 
We can take inspiration from PDEs to design architectures.

**Criteria**.
Learning Biases.
We are dealing with continuous values. 
We have an autoregressive model and we want it to be stable.

**Uncertainty**.
We want to be pragmatically bayesian.
This means we need ensembles and diffusion models because they are scalable.

**Results**.
WeatherBench2, Earth2MIP, ECMWF AI Models

**Next Steps**.

***

## Setup

### Concern


### Goal

> Be more informed about the weather, climate, and extremes.


### Objective

> We want an object that is able to take some state-of-the-Earth right now and predict the state-of-the-Earth at some time in the future.


### Task

$$
\text{Model}: \text{Current State} \times \text{Parameters} \rightarrow \text{Future State}
$$


***
## Data Representation

### Temporal Dimension


#### Period

$$
\left[ ~\sim70\text{ Years}\times365\text{ Days}\times24\text{ Hours}\times\ldots \right]
$$

#### Frequency

* Less Frequent -> Less Events -> Less Expensive
* More Frequent -> More Events -> More Expensive

### Spatial Dimension

$$
\left[ \text{Latitude},\text{Longitude},\text{Height}\right]
$$

#### Resolution

* Lower Resolution -> Less Detail -> Less Expensive
* Higher Resolution -> More Detail -> More Expensive


### Variables

* Less Variables -> Less Resolved -> Less Expensive ->
* More Variables -> More Complicated -> More Expensive 

### Problems

* Curse of Dimensionality
* High Correleations
* Complex Relationships (Non-Linear, Feedbacks, Lags)
* Heterogeneity


***
## Architecture

### Climate Models


### Multiscale




```{figure} http://portaldoclima.pt/media/images/gcm_rcm_1_.width-800.jpg
:name: da-gif
:width: 600px
:alt: Random image of the beach or ocean!
:align: center

A simple example of data assimilation for an upper atmosphere variable. [[Source](https://www.issibern.ch/teams/dataassimsphere/)]
```


***
## Augmentation

Self-Supervision ways to ignore artifacts.

* Bow-Tie Effects -> Correct it! (previous tools)
* LIMB Effects
* GOES16 vs GOES18
* Zenith + Azimuth Angles as Inputs


***

- **Globally Calibrated Gridded Satellite Imagery**
- Polar Orbiting --> Geostationary Time Series