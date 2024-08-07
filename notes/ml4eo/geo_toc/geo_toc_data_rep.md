---
title: Concept - Data Representation
subject: ML4EO
short_title: Data Representation
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


## Examples

* **Univariate Time Series**
* **Multivariate Time Series**
* **Univariate SpatioTemporal Series**
* **Multivariate SpatioTemporal Series**
* **Coupled Multivariate SpatioTemporal Series**

***
## Coordinates

### Spatial

$$
\left[ \text{Radius, Longitude, Latitude}\right]
$$

$$
\left[ \text{Altitude/Depth, Longitude, Latitude}\right]
$$


$$
\left[ \text{Channel, X, Y}\right]
$$

### Temporal


### Variable

* Remote Sensing - Spectral Signature
* Ocean - Temperature, Height, Salinity, Colour
* Weather Station - Temperature, Precipitation, Wind Speed

### Samples

* Ensembles/Realizations
* Patches


***
## Dataset Structures

***
### Univariate Time Series

$$
\begin{aligned}
\mathcal{D} &= \left\{ t_n, y_n \right\}_{n=1}^N, && &&
N = N_T && &&
y_n \in\mathbb{R}^{D_y}
&& &&
t_n\in\mathbb{R}^+
\end{aligned}
$$

$$
\begin{aligned}
\text{Measurements}: && &&
\mathbf{y} &\in\mathbb{R}^{N_T} 
&& &&
y_t \in\mathbb{R}\\
\text{Time Stamps}: && &&
\mathbf{t} &\in\mathbb{R}^{N_T} && &&
t_n \in\mathbb{R}^+
\end{aligned}
$$

***
#### Shape

**Irregular**.

**Example**:
* Extreme Events
* Faulty Station
* ARGO Floats

**Regular**.

**Examples**:
* Single Weather Station - Max Temperature, Mean Temperature, Precipitation Accumulation
* Global Mean Surface Temperature Anomaly


***
### Multivariate Time Series


$$
\begin{aligned}
\mathcal{D} &= \left\{ t_n, \mathbf{y}_n \right\}_{n=1}^N, && &&
N = N_T && &&
\mathbf{y}_n \in\mathbb{R}^{D_y}
&& &&
t_n\in\mathbb{R}^+
\end{aligned}
$$

$$
\begin{aligned}
\text{Measurements}: && &&
\mathbf{Y} &\in\mathbb{R}^{N_T\times D_y} 
&& &&
\mathbf{y}_n \in\mathbb{R}\\
\text{Time Stamps}: && &&
\mathbf{t} &\in\mathbb{R}^{N_T} && &&
t_n \in\mathbb{R}^+
\end{aligned}
$$

***
### Univariate SpatioTemporal Series


#### Coordinate-Based Representation

$$
\begin{aligned}
\mathcal{D} &= \left\{ (t_n, \mathbf{s}_n), \mathbf{y}_n \right\}_{n=1}^N
&& &&
\mathbf{y}_n \in\mathbb{R}^{D_y}
&& &&
t_n\in\mathbb{R}^+
\end{aligned}
$$


$$
\begin{aligned}
\text{Measurements}: && &&
\mathbf{Y} &\in\mathbb{R}^{N_T\times D_y} 
&& &&
\mathbf{y}_n \in\mathbb{R}^{D_y}\\
\text{Time Stamps}: && &&
\mathbf{t} &\in\mathbb{R}^{N_T} && &&
t_n \in\mathbb{R}^+\\
\text{Spatial Coordinates}: && &&
\mathbf{S} &\in\mathbb{R}^{N_T \times D_s} && &&
\mathbf{s}_n \in\mathbb{R}^{D_s}
\end{aligned}
$$

**Examples**:
* Weather Stations

***
#### Field-Based Representation

$$
\begin{aligned}
\mathcal{D} &= \left\{ t_n, \mathbf{y}_n \right\}_{n=1}^N, && &&
N = N_T
&& && 
D = D_y D_\Omega
&& &&
\mathbf{y}_n \in\mathbb{R}^{D}
\end{aligned}
$$

$$
\begin{aligned}
\text{Measurements}: && &&
\mathbf{Y} &\in\mathbb{R}^{N_T\times D} 
&& &&
\mathbf{y}_n \in\mathbb{R}^D\\
\text{Time Stamps}: && &&
\mathbf{t} &\in\mathbb{R}^{N_T} && &&
t_n \in\mathbb{R}^+
\end{aligned}
$$

**Examples**:
* Gridded Weather Station Data Product
* Sea Surface Height
* Sea Surface Temperature