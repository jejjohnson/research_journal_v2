---
title: Spatio-Temporal Data Representation
subject: Modern 4DVar
subtitle: What components can we use to estimate the state?
short_title: ST Data
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


## Core Data Structures

### Points

### Lines

### Polygons

### Rasters


---
## Spatiotemporal Dependencies


### Indepedence

#### Spatial Independence

Here, we assume that there is no dependence on the spatial coordinates.

$$
\boldsymbol{\Omega} = 
\left\{ \mathbf{x}_n\in\boldsymbol{\Omega}\subseteq\mathbb{R}^{D_s}\right\}_{n=1}^{N_s}
$$

We can stack this vector which includes all of the spatial coordinates within the domain.

$$
\mathbf{X} = [\mathbf{x}_1, \mathbf{x}_2, \ldots, \mathbf{x}_{N_s}] \in \mathbb{R}^{N_s\times D_s}
$$

---

#### Temporal Independence

$$
\mathcal{T} = 
\left\{ t_n\in\mathcal{T}\subseteq\mathbb{R}^+\right\}_{n=1}^{N_t}
$$

We can stack this vector which includes all of the temporal coordinates within the domain.

$$
\mathbf{T} = [t_1, t_2, \ldots, t_{N_s}] \in \mathbb{R}^{N_t}
$$


---

### Dependence


---

#### Spatial Dependence

Here, we assume that there is full dependence on

$$
\boldsymbol{\Omega} = 
\left\{ \mathbf{x}_d\in\boldsymbol{\Omega}\subseteq\mathbb{R}^{D_s}\right\}_{d=1}^{D_\Omega}
$$

We can stack this vector which includes all of the spatial coordinates within the domain.

$$
\mathbf{X} = [\mathbf{x}_1, \mathbf{x}_2, \ldots, \mathbf{x}_{D_\Omega}] \in \mathbb{R}^{D_\Omega\times D_s}
$$

---
#### Temporal Dependence

Here, we assume that there is no dependence

$$
\mathcal{T} = 
\left\{t_d \in [0,T]\subseteq\mathbb{R}^+ \right\}_{d=1}^{D_t}
$$

We can stack this vector which includes all of the temporal coordinates within the domain.

$$
\mathbf{T} = [t_1, t_2, \ldots, t_{D_t}] \in \mathbb{R}^{D_t}
$$

---


### Partial Dependence


> In many cases, there is assumed to be partial dependence. This is reasonable for many geospatial variables because we can assume that the nearby neighbours are



---
#### Partial Spatial Dependence


Here, we assume that there is partial dependence on the spatial variables. So first, we partition the space into $p$ subdomains.

$$
\boldsymbol{\Omega} = 
\left\{ \boldsymbol{\Omega}_p\subseteq \boldsymbol{\Omega}\right\}_{p=1}^{N_p}
$$

Notice that we have $N_p$ samples for this set and not $D_p$. This is because we assume that there is no dependence between the partitions. However, we can do some hierarchical dependencies

Now, we do the same as above for the spatial dependence. However, we can apply the spatial dependence set on each of the partitions.

$$
\boldsymbol{\Omega}_p = 
\left\{ \mathbf{x}_d\in\boldsymbol{\Omega}\subseteq\mathbb{R}^{D_s}\right\}_{d=1}^{D_\Omega}
$$

We can stack this vector which includes all of the spatial coordinates within the domain.

$$
\mathbf{X}_p = [\mathbf{x}_1, \mathbf{x}_2, \ldots, \mathbf{x}_{D_{\Omega_p}}] \in \mathbb{R}^{D_{\Omega_p}\times D_s}
$$

We can stack all of the variables together to include all of the spatial coordinates for all of the domains.

$$
\mathbf{X} = [\mathbf{X}_{1}, \mathbf{X}_{2}, \ldots, \mathbf{X}_{N_p}] \in \mathbb{R}^{N_p\times D_{\Omega_p}\times D_s}
$$


---
#### Partial Temporal Dependence


Here, we assume that there is partial dependence on the temporal variables. So first, we partition the space into $p$ subdomains.

$$
\boldsymbol{\mathcal{T}} = 
\left\{ \boldsymbol{\mathcal{T}}_p\subseteq \boldsymbol{\mathcal{T}}\right\}_{p=1}^{N_p}
$$

Notice that we have $N_p$ samples for this set and not $D_p$. This is because we assume that there is no dependence between the partitions. However, we can do some hierarchical dependencies

Now, we do the same as above for the temporal dependence. However, we can apply the spatial dependence set on each of the partitions.

$$
\boldsymbol{\mathcal{T}}_p = 
\left\{ t_d\in\boldsymbol{\mathcal{T}}\subseteq\mathbb{R}^+\right\}_{d=1}^{D_{\mathcal{T}_p}}
$$

We can stack this vector which includes all of the spatial coordinates within the domain.

$$
\mathbf{T}_p = [t_1, t_2, \ldots, t_{D_{\Omega_p}}] \in \mathbb{R}^{D_{\mathcal{T}_p}\times D_s}
$$

We can stack all of the variables together to include all of the spatial coordinates for all of the domains.

$$
\mathbf{T} = [\mathbf{T}_{1}, \mathbf{T}_{2}, \ldots, \mathbf{T}_{N_p}] \in \mathbb{R}^{N_p\times D_{\mathcal{T}_p}}
$$
