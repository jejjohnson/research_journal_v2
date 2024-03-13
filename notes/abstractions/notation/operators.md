---
title: Operators
subject: 
subtitle: 
short_title: Operators
authors:
  - name: J. Emmanuel Johnson
    affiliations:
      - CNRS
      - MEOM
    orcid: 0000-0002-6739-0053
    email: jemanjohnson34@gmail.com
license: CC-BY-4.0
keywords: notation, math, scientific-ml
---

> In this section, we will look at the transformations between each of the components. Recall, we have a hierarchy of dependencies starting from the coordinates, to the domain, and lastly the field. So how we do find transformations between different fields?


## Coordinate Transformations

$$
\mathbf{x}' = \boldsymbol{T}(\mathbf{x};\theta)
$$

For example, we can transform coordinates from Cartesian to Spherical coordinates. There are other words for this, e.g., reprojection, resample, regrid.

Most of these are related to the CRS.

---

#### Pseudo-Code


Here, we 

```python
# define field
u: Field = ...

# get domain from field
u_domain: Domain = u.domain

# transform domain
new_domain: Domain = transform(domain)

# convert old domain to new domain
u_new: Field = field_domain_transform(u, new_domain)
```

Here is a special case whereby we use. This example is motivated by the [rioxarray package](https://corteva.github.io/rioxarray/stable/examples/reproject.html#).

```python
# get dataset
ds_u: xr.Dataset = ...

# get associated CRS
crs_u: CRS = ...

# initialize new coordinate system
transformer: Callable = init_transformer("ESPG:...")

# transform
ds_a: xr.Dataset = transformer(ds_u)

```

---

### Field Operators

Now, let's say we are given two fields

$$
\begin{aligned}
\vec{\boldsymbol{u}}=\vec{\boldsymbol{u}}(\mathbf{x},t) && &&
\mathbf{x}\in\Omega_u\subseteq\mathbb{R}^{D_s} &&
t\in\mathcal{T}_u\subseteq\mathbb{R}^{+} \\
\vec{\boldsymbol{a}}=\vec{\boldsymbol{a}}(\mathbf{x},t) && &&
\mathbf{x}\in\Omega_a\subseteq\mathbb{R}^{D_s} &&
t\in\mathcal{T}_a\subseteq\mathbb{R}^{+} 
\end{aligned}
$$

We are interested in learning a mapping from one field to another

$$
\boldsymbol{a}(\mathbf{x},t) = 
\boldsymbol{f}[\boldsymbol{u}](\mathbf{x},t)
$$

**Example 1: Variable-2-Variable**

For example, we could learn an absolute mapping from temperature to humidity for a given region and time, i.e. 

$$
H = f(T)
$$

Notice that there are no dependencies on space and time. So we assume that there is an absolute relationship between the two variables.

Another example is to learn a mapping of temperature, T

$$
T_{t+\Delta t} = f(T, t)
$$


### Discretizations

1. Transform u to the coordinate system of a
2. Transform u to a

$$
\begin{aligned}
\boldsymbol{\Omega}_a &= \boldsymbol{f}_s(\boldsymbol{\Omega}_u) \\
\end{aligned}
$$








---


> Everything is an interpolation/regression problem…until it's not.


**Operators**
* Decomposition: Space-Time-Quantity
* Convex Hull: Inside, Outside
---
**Space (Inside Convex)**
> "Interpolation"
* Coordinate System Transformation
	* Spherical <--> Cartesian <--> Cylindrical ([wiki](https://en.wikipedia.org/wiki/Spherical_coordinate_system#Coordinate_system_conversions))
	* Geophysical --> [Local Tangent Plane](https://en.wikipedia.org/wiki/Geographical_distance#Spherical_Earth_projected_to_a_plane)
	* Geodetic <--> ENU <--> ECEF ([wiki](https://en.wikipedia.org/wiki/Geographic_coordinate_conversion))
* Discrete + Structured + Regular --> Discrete + Structured + Regular
	* Arakawa C-Grid
* Discrete + Structured + Regular --> Discrete + Structured + Regular
	* NADIR/SWOT Tracks --> Global Map
* Discrete + Unstructured + Irregular --> Discrete + Structured + (Regular | Irregular)
	* InSitu --> Global Map

---
**Space (Outside Convex Hull)**
> "Extrapolation"
* Vertical Depth: $\eta_{surface}(x,z_0) \rightarrow \eta_{cube}(x,z)$

---
**Time (Inside Convex)**
> "*Interpolation*"
* Kalman Smoother

---
**Time (Outside Convex)**
> "*Forecasting*"
* Sea Surface Height: $\eta(\vec{x},t) \rightarrow \eta(\vec{x},t+\Delta t)$

---
**Spatiotemporal (Outside Convex)**
* Sea Surface Height: $\eta(\vec{x},z_0,t) \rightarrow \eta(\vec{x},z,t+\Delta t)$

---
**Quantity**

* Variable-to-Variable Transformation: 
	* SST --> SSH
	* SSH --> SSC
* Forcing
* Subgrid Parameterization



Examples
* Arakawa C-Grid - Domain to Domain
	* Louis Thiry - Variable to Variable
	* 
	* 
*

## Operators

Let's say we are given a field.


$$
\begin{aligned}
\text{Field 1}: && &&
\vec{\boldsymbol{u}} &=
\vec{\boldsymbol{u}}(\vec{\mathbf{x}}),
\hspace{5mm} 
\vec{\mathbf{x}}\in\boldsymbol{\Omega}_u\subseteq\mathbb{R}^{D_s} \\
\text{Field 2}: && &&
\vec{\boldsymbol{a}} &=
\vec{\boldsymbol{a}}(\vec{\mathbf{x}}),
\hspace{5mm} 
\vec{\mathbf{x}}\in\boldsymbol{\Omega}_a\subseteq\mathbb{R}^{D_s}
\end{aligned}
$$

```python
# create domain
domain_u: Domain = Domain(...)
domain_a: Domain = Domain(...)

# create field
u: Field = Field(domain_u, ...)
a: Field = Field(domain_a, ...)
```

We have a *banach space*:

$$
\begin{aligned}
\text{Banach Space U}: && &&
\mathcal{U} &=\left\{ 
\vec{\boldsymbol{u}}: \boldsymbol{\Omega}_u \rightarrow 
\mathbb{R}^{D_u}
\right\} \\
\text{Banach Space A}: && &&
\mathcal{A} &= \left\{ 
\vec{\boldsymbol{a}}: \boldsymbol{\Omega}_a \rightarrow 
\mathbb{R}^{D_a}
\right\}
\end{aligned}
$$

```python

```

Given some Observations

$$
\begin{aligned}
\text{Observations}: && &&
\mathcal{D} &=
\left\{ 
\mathcal{U},\mathcal{A}
\right\}
\end{aligned}
$$

We assume that there exists some operator, $\boldsymbol{T}$, which maps one banach space to another.

$$
\begin{aligned}
\text{Operator}: && &&
\boldsymbol{T} &: 
\mathcal{U} \rightarrow \mathcal{A}\\
\text{Data}: && &&
\mathcal{D} &=
\left\{ 
\mathcal{U},
\boldsymbol{T}(\mathcal{U})
\right\}
\end{aligned}
$$

Now, we can try to find some parameterized operator that is approximately equal to the true operator, i.e., $\boldsymbol{T}\approx \boldsymbol{T_\theta}$.

$$
\begin{aligned}
\text{Parameterized Operator}: && &&
\boldsymbol{T_\theta} &: 
\mathcal{U} \times
\mathcal{\Theta} \rightarrow \mathcal{A}\\
\end{aligned}
$$


**Empirical Risk Minimization**

$$
\boldsymbol{\theta}^* = \underset{\theta}{\text{argmin}}
\hspace{2mm}
\mathbb{E}_{\mathcal{u}\sim\mu}
\left[ ||\mathcal{A} - \boldsymbol{T_\theta}(\mathcal{U},\boldsymbol{\theta}) ||_2^2\right]
$$

**Bayesian Inference**

$$
p(\mathcal{M}|\mathcal{D}) = \frac{1}{Z} p(\mathcal{D}|\mathcal{M})p(\mathcal{M})
$$



**Pseudo-Code**

```python
# initialize fields
u: ContinuousField = ...
a: ContinuousField = ...

# initialize operator
operator: Callable =
params: PyTree ==

# apply operator
a_hat: ContinuousField = operator(u: Field=u, params: Params=params)

# checks
assert a_hat.domain == a.domain
assert a_hat.values == a.values
```


Case Omega Domain
Case - Functional Output Domain
Case - 

Sources:
- https://youtu.be/tASot9j7-Cc?si=6-Eg4RNkYFJj4MeJ
- 

---
### Decomposition

We can divide the operations into the following: 1) space, 2) time, and 3) quantity.

---
## Space (Inside Convex)

### Coordinate System Transformations

#### Example: Spherical-Cartesian-Cylindrical

#### Example: Geodetic

#### Example: Geodetic-ENU-ECEF


### Same Domain

:::{tip} Example: Arakawa C-Grid
:class: dropdown

```{figure} https://veros.readthedocs.io/en/latest/_images/c-grid.svg
:name: fig-arakawa-cgrid
:alt: arakawa C Grid.
:align: center
:width: 400px

Structure of Arakawa C-Grid. The $\zeta$ represents the $h$ in our case. Source: [veros-documentation](https://veros.readthedocs.io/en/latest/introduction/introduction.html)
```

$$
\begin{aligned}
\text{Variable}: && &&
\zeta &= \boldsymbol{\zeta}(\boldsymbol{\Omega}_\zeta), 
\hspace{5mm} 
\boldsymbol{\Omega}_\zeta\subseteq\mathbb{R}^{D_s}\\
\text{Zonal Velocity}: && &&
u &= \boldsymbol{u}(\boldsymbol{\Omega}_u), 
\hspace{5mm} 
\boldsymbol{\Omega}_u\subseteq\mathbb{R}^{D_s}\\
\text{Meridional Velocity}: && &&
v &= \boldsymbol{v}(\boldsymbol{\Omega}_v), 
\hspace{5mm} 
\boldsymbol{\Omega}_v\subseteq\mathbb{R}^{D_s}\\
\text{Tracer}: && &&
q &= \boldsymbol{q}(\boldsymbol{\Omega}_q), 
\hspace{5mm} 
\boldsymbol{\Omega}_q\subseteq\mathbb{R}^{D_s}\\
\end{aligned}
$$

First, we need to create the domain for the variable 
```python
# initialize domain
h_domain: Domain = ...
```
Now we need to create the staggered domains.

```python
# create stagger domains
u_domain: Domain = stagger_domain(h_domain, direction=("right", None), stagger=(True, False))
v_domain: Domain = stagger_domain(h_domain, direction=(None, "right"), stagger=(False, True))
q_domain: Domain = stagger_domain(h_domain, direction=("right", "right"), stagger=(True, True))
```

Now, we create the discretized fields where the values lie

```python
h: Field = Field(h_domain, ...)
u: Field = Field(u_domain, ...)
v: Field = Field(v_domain, ...)
q: Field = Field(q_domain, ...)
```
Now, we can use operators to calculate the quantities on the other doamins


```python
# transform the domain
u_on_h: Field = domain_transform(u, h.domain)
v_on_h: Field = domain_transform(v, h.domain)
q_on_h: Field = domain_transform(q, h.domain)

# check
assert h.domain == u_on_h.domain == v_on_h.domain == q_on_h.domain
```

:::




### Different Domain

### Unstructured Domains




---
## Quantity



---
## Time


---
### Examples

#### Forecasting


**PDE Operator**

```python
# initialize domain
domain: Domain = ...

# initialize fields
Field = Discrete & Structured & Regular
u_0: Field = Field(domain, ...)
u_t: Field = Field(domain, ...)

# initialize finite difference operator
pde_model: Model = ...
pde_params: PyTree = ...
ode_solver: Solver = ...

# apply operator
u_t_hat: DiscretizedField = ode_solver(
	pde_model, pde_params, u_0, [t0, t1], dt
)

# checks
assert u_t_hat.domain == u_t.domain
assert u_t_hat.values == u_t.values
```

**Neural Operators**

```python
# initialize domain
domain: Domain = ...

# initialize fields
Field = Continuous & Structured & (Regular | Irregular)
u_t0: Field = Field(domain, ...)
u_t1: Field = Field(domain, ...)

# initialize fourier neural operator
operator: Model =
params: PyTree =

# apply operator
a_hat: ContinuousField = operator(u: Field=u, params: Params=params)

# checks
assert a_hat.domain == a.domain
assert a_hat.values == a.values
```

---
#### Spatial Domain Transformation


```python
# initialize domains
domain_u: Domain = Domain(...)
domain_a: Domain = Domain(...)

# initialize fields
Field = (Continuous | Continuous) & Structured & (Regular | Irregular)
u: Field = Field(domain_u, ...)
a: Field = Field(domain_a, ...)

# initialize domain transformation
operator: Model = ...
params: PyTree = ...

# apply operator
domain_a_hat: Domain = operator(u, domain_a, params) 

# checks
assert u_t_hat.domain == u_t.domain
assert u_t_hat.values == u_t.values
```



- Everything is an interpolation/regression problem…
- Forecasting: T to T+1 prediction
- Prediction:
	- Quantity to Quantity
	- Parameterization - Forcing to Solution/Correction
- Interpolation (Domain Transformation):
	- RegularGrid —> RegularGrid (Arakawa C-Grid)
	- Irregular Grid —> Regular Grid (AlongTrack Data)
	- Unstructured Grid —> Regular Grid (InSitu Data)

In this section, we will break down the

**Variables**: Variable + Coordinates + Domain + Space
**Transformation**: Variable I --> Variable II


**Examples**:
 

**Problems**:
* What transformation from 1 variable to another?
* What if the domains are different?
* What about spatiotemporal data?



---
### Functional


**Motivating Examples**

* X-Casting - Weather, Ice Cores, Climate
* Image-to-Image (Instrument-to-Instrument)
* Variable Transformation - SSH —> SSC

---
### Heterogeneous Domains

$$
\Omega_u = \boldsymbol{T_\theta}\left(\Omega_a\right)
$$

Examples:
- SST
	- 1D Linear Interpolation
- SSH
	- 2D Spatial Interpolation
	- Continuous —> Discrete (Binning)

Simple Example


```python
# obtain values
a: Array = ...
u: Array = ...

# initialize transformation + params
params: Params = ...
transform: Callable = ...

# apply transformation
u_hat: Array = transform(a, params)

# test to ensure it is equal
np.testing.assert_array_equal(u, u_hat)
```


```python
# Domain 1
field_a: Field = Field(values_a, domain_a)
field_u: Field = Field(values_u, domain_u)

# initialize interpolator
a_to_u_f: Callable = FieldInterpolator(field_u.values, field_u.coords)

# apply interpolator
field_a_on_u: Field = a_to_u_f(field_a.values, field_a.coords)
```

---
#### Unpaired Domains




## PDE





## Geo-FNO



```Python
# Get input data
# [H,W]
X = …
# create interpolation layer
num_dims = 3 # input channel is 3: (a(x, y), x, y)
weights = random(size=(num_dims, num_outputs))  
# create grid coordinates [H,W,2]
grid = get_normalized_grid_coords(x.shape)
# Concaténate Data
# [H,W],[H,W,2] —> [H,W,3]
x = torch.cat((x, grid), dim=-1)
# Change Coordinates
# [H,W,3] —> [H,W,Dz]
x = einsum(“…c,cd->…d”, x,weights)
# Apply Operator
# [H,W,Dz] —-> [H,W,Dza]
a = Operator(X)
# Apply Inverse Operator
# [H,W,Dza] —> [H,W,C]
a = einsum(“…d,cd->…c”, x,weights)
# Apply Learned Inverse Operator
# [H,W,Dza] —> [H,W]
a = einsum(“…d,cd->…1”, x,weights_)
```

