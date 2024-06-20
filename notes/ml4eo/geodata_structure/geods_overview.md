---
title: GeoData Structures
subject: Available Datasets in Geosciences
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
keywords: observations
---

In this page, we will do a write-up of a **geo-tensor** datastructure which serves as a useful data-type for geoscience data.

$$
\begin{aligned}
\text{Image}: && &&
\text{Batch}\times
\text{Channels} \times
\text{Depth} \times
\text{Height} \times
\text{Width}
\end{aligned}
$$

We also have something similar with geoscience data where we have the reference of the 

$$
\begin{aligned}
\text{Field}: && &&
\text{Ensemble}\times
\text{State} \times
\text{Radius} \times
\text{Height} \times
\text{Width}
\end{aligned}
$$

In atmospheric terms, the radius would be equivalent to the altitude `[meters]` and in ocean applications, this would be equivalent to the depth `[meters]`.


***
## Field

> Container that holds the function (optional), function values, and domain.

* Values
* Domain

With this, we will have operations:
* Unary Operations
* Binary Operations
* Image Operations - Pad, Resiz
* Interpolation
* Differential Operations - Gradient, Kinematics





##### **Fields**
- Values
- Domain

##### Masks
- NodeMask
- FaceMask
- CenterMask

##### **Domain**
- Rectangular - Cartesian, Rectilinear, Curvilinear
- Spherical - Cartesian, Rectilinear, Curvilinear
- Cylindrical

##### **Stacked Fields**
* Stacked Independent Layers
* Ensembles
* Time




—-
### Cases:
- 1D
	- X - Linear SWM
	- T - NerF, NerOP, ODE Soln
- 2D
	- X,Y - Linear SWM, QG, SWM
	- T,X - NerF, NerOP, PDE Soln
- 3D
	- Z,X,Y - MultiLayer QG, SWM
	- T,X,Y - NerF, NerOP, PDE Soln
- 4D
	- T,Z,X,Y - NerF, NerOP, PDE Soln


—-
Stacked Field 
> Independent Operated Layers. Special Discretization of the Depth layer

- Isopyncal Layers - Multilayer QG, Multilayer SWM
- Time Dimension - QG, (Linear) SWM
- Independent Variables - SSH, SST, SSS
- Both - Multilayer QG, Multilayer (Linear) SWM

—-
Ensembles

Time | Ensemble | Layer | Space
- T,Ens,L,X,Y

Inspirational Tutorials
- [xarray docs](https://tutorial.xarray.dev/overview/xarray-in-45-min.html)


Field Types
- Discrete - Discretization Variant, Domain Invariant
- Continuous - Functional (Neural Field)


	- Fixed - FD, FV, PseudoSpectral
	- Parameterized - CNN, Spherical CNN, Transformer, RNN, MLP
	- MeshInvariant - NerOps
	- Parameterized - NerF



Operations
- Binary Operations - +,-,*,/
- Unary Operations - ^,1/,
- Interpolations / Reconstructions - Domain Transformations
- Differences
- Custom - FiniteDifference, SpectralDifference, NerF, NerOp,

Binary Operations

- Same Field - Easy
- Discrete Field + Discrete Field - evaluate at domain if domain is the same!
- ContinuousField + ContinuousField - evaluate at domain of other field!
	- NerF might fail outside domain
	- NerOP is invariant
- DiscreteField + ContinuousField

Spatial Operators
> Functions that transform field values

Domain Operators
> Functions that transforms domains


Examples
- ODE
- PDE - QG, SWM, Stacked
- Forcing
- Parameterization - Online
- Correction Term - NerOP
- Functa - NerF
- CORAL
- Surrogate

Sampling
* Points (Interior, Boundary) - NerFs
* Slices - NerOPs, CNNs, 
* XRPatcher integration

---
## PseudoCode



```Python
class Field(eqx.Module):
	domain: Domain = eqx.field(static=True)
	mask: Mask = eqx.field(static=True)

class Discrete(Field):
	values: Float[Array, "Nx Ny"]

    def __call__(self, x: Array) -> Array:
        u: Array = self.select_values_at_indices(x)
        return u

class Continuous(Field):
    fn: Callable
    
    @property
    def values(self) -> Array:
        u: Array = self.vmap_coords()
        u: Array = reshape(u, self.domain.Nx)
        return u
    
    def __call__(self, x: Array) -> Array:
        u: Array = self.fn(x)
        return u
```


#### Operations

```python

# ==========================================
# initialize field
# ==========================================
domain: Domain = …
u_values: Array[“Nx Ny”] = …
u: Field = Field(u_values, domain)

# initial condition
u: Field = init_from_scalar_fn(domain, fn)
u: Field = init_from_field_fn(domain, fn)
u: Field = init_with_constant(domain, constant=0.0)

# initialize with xarray
xrda: xarray.DataArray = …
eta: Field = init_with_xrdataarray(xrda)
xrda: xarray.DataArray = field_to_xrdataarray(eta)

############################################
# Operations
############################################

# ==========================================
# Unary Operations
# ==========================================

# math operations
u_sq: Field = u**2

# selection (True values)
u_sub: Array = u(2.5, 5.0)
u_sub: Array = jax.vmap(u, in_axes=(0,0))(X,Y)

# slicing
u: Field = u[1:-1, :]

# ==========================================
# Binary Operations
# ==========================================

# math operations
uv: Field = u + v
u_sq: Field = u * u
u_sqrt: Field = u ** 0.5

# constants
u: Field = - Constant(CORIOLIS)^2 * u / Constant(GRAVITY)

############################################
# Spatial Operators
############################################

# ==========================================
# Fixed Spatial Operators
# ==========================================
def operator(u: Field, args, **kwargs) —> Field:
    # do something
    return u
    
# Finite Difference | Finite Volume | PseudoSpectral
du: Field = difference(u, derivative=1)
d2u: Field = difference(u, derivative=2)
u_lap: Field = laplacian(u)
u, v = geostrophic_gradient(psi)
div_uv: Field = divergence(u, v)
rel_vort: Field = relative_vorticity(u, v)
curl: Field = curl_2D(u, v)

# function wrappers
fn: Callable = …
fn_op: Operator = FuncOperator(fn)
u_hat: Field = fn_op(u, args, **kwargs)

# Boundary condition 
enforce_bcs: Callable = …
bc_op: Operator = FuncOperator(enforce_bcs)
u_bc: Field = bc_op(u, args, **kwargs)

# ==========================================
# Parameterized Spatial Operators
# ==========================================
class Operator(PyTree):
    params: PyTree

    def __init__(self, domain: Domain, args, **kwargs):
        # init something

    def __call__(self, u: Field, args, **kwargs) —> Field:
        # do something
        return u
        
# (Learned) Differential Operator
fd_operator: Operator = Convolution(u.domain, params)
u_hat: Field = fd_operator(u)

# (Learned) Parametric Forcing
forcing_op: Operator = Forcing(u.domain, params)
wind_forcing: Field = forcing_op(u) 

# (Learned) Boundary Condition
bc_op: Operator = BCFunction(u.domain, params)
u_bc: Field = bc_op(u)

# (Learned) Parameter
diffusivity_op: Operator = …
nu: Field = diffusivity_op(u.domain, t)

# CNN (ResNet)
cnn_model: Operator = CNN(u.domain, params)
u_hat: Field = cnn_model(u)

# (Fourier) Neural Operator
nerop_model: Operator = NeuralOperator(u.domain, params)
u_hat: Field = nerop_model(u)

# Neural Field
nerf_model: Operator = NeuralField(params)
u_hat: Field = nerf_model(u.domain.coords)


############################################
# Domain Transformation (Interpolation)
############################################

# ==========================================
# simple (linear) interpolation
# ==========================================
# x average
u: Field[“Nx-1 Ny”] = avg_pool(u, (2,1))
# y average
u: Field[“Nx Ny-1”] = avg_pool(u, (1,2))
# center average
u: Field[“Nx-1 Ny-1”] = avg_pool(u, (2,2))

# ==========================================
# reconstructions
# ==========================================
# methods: linear, weno, wenoz
# num_pts: 1, 3, 5
# [Nx,Ny],[Nx-1,Ny] —> [Nx-1,Ny]
flux_hu: Field = calculate_flux(h, u, dim, num_pts, method)

# ==========================================
# generalized transformations
# ==========================================

# coordinate-based transformation
# method: linear, spline, rbf
interpolator: Callable = CoordInterpolator(u, method)
u_queries: Array = interpolator(X_coords, Y_coords)

# domain-based transform 
# method: linear, splines, rbf
interpolator: Callable = GridInterpolator(h, method)
u_on_h: Field = interpolator(u)

# parameterized interpolator (NerF, Functa)
# method: FFN, MLP, SIREN
functa: Module = Functa(u)
functa: Module = train_functa(functa, …)
u_queries: Array = functa(X_coords, Y_coords)
u_queries: Array = functa.domain(h.domain)

# ==========================================
# Padding
# ==========================================
# mode: constant, edge, reflect, symmetric, empty
u_pad: Field = pad(u, pad_width=((1,1),(0,0)), mode=“constant”, values=0.0)
# pad_width: “left”, “right”, “both”, None
u_pad: Field = pad(u, pad_width=(“both”, None), mode=“constant”, values=0.0)

```