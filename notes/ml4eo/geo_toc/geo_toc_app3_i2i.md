---
title: App 3 - Instrument 2 Instrument
subject: ML4EO
short_title: TOC - App III - I2I
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


## Overview

In this application, we are interested in modeling surface observations on the ocean.
These observations include temperature, height, salinity, and colour.
Contrary to the previous application for extremes, here we will focus more on different parameterizations which we can learn based on different datasets which are available.

*** 
### Quick Walk-Through

***
#### **Datasets**.

The first set of datasets will feature a range of different

$$
\begin{aligned}
\text{Multivate Spatiotemporal Series}: && &&
\mathcal{D} &= \left\{(t_n, \mathbf{s}_n), \mathbf{y}_t \right\}_{n=1}^{N_T} && &&
\mathbf{y}_n\in\mathbb{R}^{D_y} \\
\text{Coupled Multivate Spatiotemporal Series}: && &&
\mathcal{D} &= 
\left\{(t_n, \mathbf{s}_n), \mathbf{x}_n, \mathbf{y}_t \right\}_{n=1}^{N_T} 
&& &&
\mathbf{y}_n\in\mathbb{R}^{D_y} \\
\end{aligned}
$$


**Polar-Orbiting Satellites**.
These are satellites with a spatial resolution and a large number of spectral channels.
However, they also have a low temporal resolution, e.g., days, which leads to a lower revisit time.
In addition, they are on irregular geometries but they have good spatial coverage (they cover the whole globe).

**Geostationary Satellites**.
These are satellites with a lower spatial resolution and a lower number of spectral channels.
However, they have a high temporal resolution, e.g., 15 minutes.
In addition, they are on regular geometries but they do not have good spatial coverage (they do not cover the whole globe).


**AlongTrack Satellites**.
These are satellites which are polar-orbiting, however, they do not have the high-spatial resolution as do the typical polar-orbiting satellites.
Instead, these tend to be active satellites so they measure specific quantities.
In our applications, we will look at Sea Surface Height and Cloud properties.


***
#### **Sub-Topics**

**Foundation Models**.
Here, we will look at how we can learn high-quality foundation models.
Essentially, we will look at how we can a good encoder-decoder using many of the standard training tricks like data augmentation and masking.

**Fine-Tuning**.
We will look at how we can utilize pre-trained models to update the weights for more specific tasks.

**Encoding**.
We wish to encode as much information as possible.
So we want to investigate how we can encode as much information as possible.
This includes time coordinates, spatial coordinates, and wavelengths.
If possible, we will also include extra static information like ocean, land, and cloud masks or even orography and topography.

**Data Alignment**.
We have a lot of data for individual satellites.
However, they are rarely have the same geometry nor measure the same spectral signatures.
So we need to acquire high-quality training samples which involves good ol' fashioned matching schemes.


***
#### **Useful Skills**

**Geoscience**.
We need to use all attributes of the geosciences as we are essentially working with the core data which is used for observation data world-wide.

**Scale**.
Remote sensing data is some of the heaviest data

**Data Harmonization**.
We will attack the data harmonization front from all angles. 
This includes operator learning across different data modalities.


***
## Blog

### Part I: Geo 2 Geo

> In this first part, we will look at the


* Alignment


### Part II: Polar 2 Geo


### Part III: Polar 2 Geo 2 CloudSAT

* 


***
## Appendices

* Hydra
* Databases: EarthAccess, GOES2GO, EUMDAC
* GeoProcessing: Clean, Label, Reprojection, Resample, Clip, Mask, Harmonize, Save (TIFF, npy, zarr)
* Feature Representation, Compression
* Variable Transformation
* Metrics: Pixels, Spectral, Multiscale
* Encoding: Time, Coordinates, Wavelength
