---
title: Notation - Operators
subject: ML4EO
short_title: Operators
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

> Below is my preferred notation for modeling.

# Spatiotemporal Field

* Coordinates
* Domain
* Field

***
## Coordinates

***
###  Spatial Coordinates

$$
\mathbf{s} \in \Omega \subseteq \mathbb{R}^{D_s}
$$

For example, we can have:

$$
\begin{aligned}
\text{Cartesian}: && && \mathbf{s} &= [x,y,z]\\
\text{Spherical}: && && \mathbf{s} &= [\text{Longitude},\text{Latitude},\text{Depth/Altitude}]
\end{aligned}
$$

Some spatial coordinate systems include some idealized ones like Spherical, Cartesian and Cylindrical. 

$$
\begin{aligned}
\text{Cartesian Coordinates}: && 
\mathbf{s} &= [x,y,z] \in\mathbb{R}^{3} \\
\text{Spherical Coordinates}: && 
\mathbf{s} &= [\lambda, \varphi, r] \in\mathbb{R}^{3} \\
\text{Cylindrical Coordinates}: && 
\mathbf{s} &= [\rho, \varphi, z] \in\mathbb{R}^{3}
\end{aligned}
$$

However, there are some more geographic coordinate systems. Most of these can be found within the Coordinate Reference System (CRS).

**Note**: in many cases, we have coordinate transformations whereby we can move between different coordinate systems. 
For example, we can simply move between Cartesian coordinate system and the spherical coordinate system.
There are also many examples of the Coordinate Reference System (CRS) which allows users to use their own custom system depending upon their field of view.

***
### Temporal Coordinates

$$
t \in \mathcal{T} \subseteq \mathbb{R}^+
$$

For example, we can have:

$$
\begin{aligned}
t &= [\text{seconds},\text{minutes},\text{hours},\text{days},\text{seasons},\text{years},\ldots] 
\end{aligned}
$$

***
## Domain




### Spatial Domain

> The domain is the region or convex hull which is a subset of the coordinate space, $\mathbb{R}$.

$$
\begin{aligned}
\text{Spatial Domain}: && 
\boldsymbol{x}\in\Omega\subseteq\mathbb{R}^{D_s}
\end{aligned}
$$

The spatial domain can be though of as the convex hull. 

#### Boundaries

We also have boundaries associated with the domain, i.e., along the convex hull of the spatial domain or at the end-points of the line.

$$
\begin{aligned}
\text{Spatial Domain Boundaries}: && 
\boldsymbol{x}\in\partial\Omega\subseteq\mathbb{R}^{D_s} 
\end{aligned}
$$

### Temporal Domain

> The domain is the region or convex hull which is a subset of the coordinate space, $\mathbb{R}$.

$$
\begin{aligned}
\text{Temporal Domain}: && 
t\in\mathcal{T}\subseteq\mathbb{R}^+
\end{aligned}
$$

The temporal domain is a real, ordered number line of positive integers.

#### Boundaries

We also have boundaries associated with the domain, i.e., along the convex hull of the spatial domain or at the end-points of the line.

$$
\begin{aligned}
\text{Temporal Domain Boundaries}: && 
t\in\partial\mathcal{T}\subseteq\mathbb{R}^+
\end{aligned}
$$

***
## Field

> A field is a scaler or vector-value which is associated with a coordinate within some domain.

$$
\begin{aligned}
\vec{\boldsymbol{u}}=\vec{\boldsymbol{u}}(\boldsymbol{x}, t) && &&
\vec{\boldsymbol{u}}:\mathbb{R}^{D_s}\times\mathbb{R}^+\rightarrow \mathbb{R}^{D_u}
\end{aligned}
$$

These could include some essential variables like height, temperature, or salinity. However, these could also be some derived variables like NDVI, sadness or poverty. In the geoscience case, thes can include some subjective variables like polar amplification, tropical amplification, and/or vortex stratification.

#### Pseudo-Code

```python
# initialize domain
domain: Domain = ...

# initialize values
init_fn: Callable = ...
u_values: Array["Nx Ny"] = init_fn(domain)

# initialize field
u: Field = Field(u_values, domain)
```

---
### Discretized Domain

$$
\begin{aligned}
\text{Discretized Spatial Domain}: && 
\boldsymbol{x}\in\boldsymbol{\Omega}\subseteq\mathbb{R}^{D_s} \\
\text{Discretized Temporal Domain}: && 
t\in\boldsymbol{\mathcal{T}}\subseteq\mathbb{R}^+
\end{aligned}
$$


#### Boundaries

We also have boundaries associated with the domain, i.e., along the convex hull of the spatial domain or at the end-points of the line.

$$
\begin{aligned}
\text{Spatial Domain Boundaries}: && 
\boldsymbol{x}\in\partial\boldsymbol{\Omega}\subseteq\mathbb{R}^{D_s} \\
\text{Temporal Domain Boundaries}: && 
t\in\partial\boldsymbol{\mathcal{T}}\subseteq\mathbb{R}^+
\end{aligned}
$$


#### Coordinates

Because we have a discretized domain, we don't have an infinite set of coordinates that we can get from the domain. So, we can stack

$$
\begin{aligned}
\text{Spatial Coordinates}: && 
\mathbf{X}\in\mathbb{R}^{D_\Omega\times D_s} \\
\text{Temporal Coordinates}: && 
\mathbf{T}\in\mathbb{R}^{D_\mathcal{T}}
\end{aligned}
$$

#### StepSize

Again, because we have a discretized domain, we don't have an infinite set of coordinates that we can get from the domain. In addition to stacking the coordinates, we can also draw

$$
\begin{aligned}
\text{Spatial Coordinate Step}: && 
\Delta\mathbf{x}\in\mathbb{R}^{D_\Omega\times D_s} \\
\text{Temporal Coordinates}: && 
\Delta t\in\mathbb{R}^{D_\mathcal{T}}
\end{aligned}
$$

In many cases, we can make some simplifications about the size. For example, we can have a constant step size in space, e.g., Cartesian grid. 


```python!
dx: Array[""] = ...
dy: Array[""] = ...
```

We can have a variable stepsize in each direction independently. This is analogous to a Rectilinear grid.

```python!
dx: Array["Dx"] = ...
dy: Array["Dy"] = ...
```

We can also have a variable stepsize in each direction. This is often referred to as a Curvilinear Grid.

```python!
dx: Array["Dx Dy"] = ...
dy: Array["Dx Dy"] = ...
```


