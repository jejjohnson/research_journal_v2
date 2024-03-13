---
title: Data-Driven Regional Parameterizations
subject: Available Datasets in Geosciences
short_title: Parameterizations
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
## Background

### Motivation

There are a number of variables present within the reanalysis dataset that are not present within the current AI models. These missing variables could be pivotal for the regional models. We can fill this void by learning a parameterization to predict the missing variables based on relevant covariates that can be extracted from AI models.

***
### Objective

Learn a data-driven model to predict the missing variables based on


***
### Task

We have a classic task
$$
\boldsymbol{f}: \boldsymbol{x}\times\boldsymbol{\theta} \rightarrow \boldsymbol{u} 
$$


***
## Data

**Quantity of Interest**. We have a standard quantity of interest which is a spatiotemporal field.
$$
\begin{aligned}
u &= u(s,t) && 
u: \mathbb{R}^{D_s}\times\mathbb{R} \rightarrow \mathbb{R}^{D_u} &&
s \in \Omega\subseteq\mathbb{R}^{D_s} &&
t \in \mathcal{T}\subseteq\mathbb{R}^{+}
\end{aligned}
$$


* Short Wave Radiation
* Long Wave Radiation

**Covariates**. We have all of the variables that are returned from the AI emulators.

$$
\begin{aligned}
\boldsymbol{x} &= \boldsymbol{x}(s,t) && 
\boldsymbol{x}: \mathbb{R}^{D_s}\times\mathbb{R} \rightarrow \mathbb{R}^{D_u} &&
s \in \Omega_x\subseteq\mathbb{R}^{D_s} &&
t \in \mathcal{T}_x\subseteq\mathbb{R}^{+}
\end{aligned}
$$
Some likely candidates include:
- Wind
- Temperature
- Humidity

**Reanalysis**. We will use reanalysis data from

$$
\text{Dimensions} = \left[ \text{Variable}\times\text{Time}\times\text{Latitude}\times\text{Longitude}\right]
$$

* spatial resolution - `0.25x0.25`
* Number of Pixels - `1440x720`
* temporal frequency - `1h`
* period - `1970-2017`




***
## Data Representation



### Observations

We assume that all measurements are i.i.d.

$$
\begin{aligned}
u = \{ u_n\}_{n=1}^N && && u_n \in \mathbb{R}^{D_u} &&N=N_sN_t
\end{aligned}
$$

```python
# get observations
y: xr.Dataset["Variable Latitude Longitude Time"] = ...
```


### Covariate Representation

This is trickier because we need to include the full vertical column for the pressure levels.
From physics, we can assume that there is some operator, $f$, that takes the entire length of the water column.

$$
\boldsymbol{u}(\mathbf{s},t) = 
\int_Z \boldsymbol{f}[\boldsymbol{x}](\mathbf{s},z,t,\boldsymbol{\theta})dz
$$


```python
# get dataset
x: Array["Variable Time Latitude Longitude Level"] = ...
```

* Case I - Aggregated Vertical Column, Independent Lat-Lon, Dependent Time
* Case II - Dependent Vertical Column, Independent Lat-Lon
* Case III - Dependent Vertical Column, Dependent Lat-Lon (w/ memory)
* Case IV - Dependent Vertical Column, Dependent

| Case | Vertical Dimension | Lat-Lon Dimensions | Time Dimension |
| :--: | ---- | ---- | ---- |
| I | Aggregated | Independent | Independent |
| II | Dependent | Independent | Independent |
| III | Dependent | Dependent | Independent |
| IV | Dependent | Dependent | Dependent |

***
#### Case I - Aggregated Pixels

Here, we assume that the lat-lon spatial plane is independent and the time dimension is independent. However, the vertical column is an aggregated in some form.
Now, like our QoI, we assume that this data is IID

$$
\begin{aligned}
\boldsymbol{x} = \{ \boldsymbol{x}_n\}_{n=1}^N && && 
\boldsymbol{x}_n \in \mathbb{R}^{D_x} &&N=N_{s}N_t
\end{aligned}
$$

One way to achieve this would be to take the weighted mean of the vertical column.
$$
\boldsymbol{x}(\mathbf{s},t) = \sum_{n=1}^{N_z}
\boldsymbol{w}(\mathbf{z}_n)\cdot\boldsymbol{x}(\mathbf{z}_n,\mathbf{s},t)
$$


```python
# take the mean or some other aggregate
x: xr.Dataset["Variable Latitude Longitude Time"] = aggregate_function(x, dim="Height", **params)
# create samples
x: xr.Dataset["Samples Variable"] = rearrange(x, "(Latitude Longitude Time)=Samples Variable")
```


***
#### Case II - 1D Vertical Column

We assume that the lat-lon spatial plane is independent and the time dimension is independent.

$$
\begin{aligned}
\boldsymbol{x} = \{ \boldsymbol{x}_n\}_{n=1}^N && && 
\boldsymbol{x}_n \in \mathbb{R}^{D_x\times D_z} &&N=N_{s}N_t
\end{aligned}
$$

```python
# create samples
x: xr.Dataset["Samples Variable Height"] = rearrange(x, "(Latitude Longitude Time)=Samples ...")
```

To deal with the high dimensionality, we may need to do some dimensionality reduction techniques. 
For example, we could use a simple PCA or a more advanced PCA scheme. 

```python
# create samples for dimred
x: xr.Dataset["Samples Height Variable"] = rearrange(x, "")

# dimension reduction
x: xr.Dataset["Variable Latitude Longitude Time ReducedDim"] = dimension_reduction(x, dim=["Height", "Variable"], **params)

# create samples
x: xr.Dataset["Samples Variable ReducedDim"] = rearrange(x, "(Latitude Longitude Time)=Samples ...")
```

Alternatively, we could also use a specific architecture like a convolutional neural network with assumed locality or a spectral convolution to account for global features.

***
#### Case III - 3D Spatial Cube

We assume that the  time dimension is independent. However, we assume that the lat-lon spatial plane and the vertical column is dependent. 
This would result in:

$$
\begin{aligned}
\boldsymbol{x} = \{ \boldsymbol{x}_n\}_{n=1}^N && && 
\boldsymbol{x}_n \in \mathbb{R}^{D_x\times D_s\times D_z} &&N=N_t
\end{aligned}
$$

```python
# create samples
x: xr.Dataset["Samples Variable Height Latitude Longitude"] = rearrange(x, "(Time)=N  ...")
```

Similar to the problem above, we have high dimensionality which means we should either do some dimensionality reduction technique or assume an architecture that will account for the spatial dimensions.


***
#### Case IV - 3D+T Spatiotemporal Cube

We assume that the  time dimension is independent. However, we assume that the lat-lon spatial plane and the vertical column is dependent. 
This would result in:

$$
\begin{aligned}
\boldsymbol{x} = \{ \boldsymbol{x}_n\}_{n=1}^N && && 
\boldsymbol{x}_n \in \mathbb{R}^{D_x\times D_s\times D_z} && N=1
\end{aligned}
$$

In this case, we will not have any samples, just a single large data cube.

```python
# create samples
x: xr.Dataset["Variable Time Height Latitude Longitude"] = ...
```

This is the worst kind of problem whereby we have high dimensionality.
In this case, we need to make some assumptions about the dimensionality of the data such that we only learn local relationships.
An additional constraint is the idea that we need to have some causal constraints in the time dimension, i.e., $p(u_t|u_{t-1})$.

***
## Model


We have a data distribution which comes from reanalysis data.

$$
(x,u) \sim p_{data}(x,u)
$$
This data distribution is represented by the reanalysis data. We assume that we can find some distribution via a parameterization
$$
p_{data}(x,u) \approx p(x,u,\theta)
$$

### Joint Distribution

We can decompose this joint distribution as a conditional model for the covariates given some parameters.

$$
p(u,x,\theta) = p(u|x,\theta)p(\theta)
$$

### Data Likelihood

$$
y_n \sim p(y_n|x_n;\theta)
$$

### Prior

$$
\theta \sim p(\theta)
$$

### Posterior

$$
p(\theta|\mathcal{D}) = \frac{1}{Z}p(\mathcal{D}|\theta)p(\theta)
$$


