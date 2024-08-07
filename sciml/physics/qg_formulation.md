---
title: Quasi-Geostrophic Equations Formulation
subject: QuasiGeostrophic Equations
short_title: QG Formulation
authors:
  - name: J. Emmanuel Johnson
    affiliations:
      - CNRS
      - MEOM
    orcid: 0000-0002-6739-0053
    email: jemanjohnson34@gmail.com
license: CC-BY-4.0
keywords: jax, shallow water model, differentiable
abbreviations:
    SW: Shallow Water
    QG: Quasi-Geostrophic
    PDE: Partial Differential Equation
    RHS: Right Hand Side
    PV: Potential Vorticity
    SF: Stream Function
    N-S: Navier-Stokes
    Pa: Pascals
---

In this section, we look at how we can solve the QG equations using elements from this package.


---
## Generalized QG Equations

**Note**: This formational is largely based on [{cite}`10.3934/dcdss.2022058`].
See this paper for more information including a derivation about the energetics.

We can define two fields as via the potential vorticity (PV) and stream function (SF).

$$
\begin{aligned}
\text{Stream Function}: &&
\psi & =\boldsymbol{\psi}(\vec{\mathbf{x}},t) && && 
\vec{\mathbf{x}}\in\Omega\sub\mathbb{R}^{D_s} , &&
t\in\mathcal{T}\sub\mathbb{R}^{+} \\
\text{Potential Vorticity}: &&
q& =\boldsymbol{q}(\vec{\mathbf{x}},t) && && 
\vec{\mathbf{x}}\in\Omega\sub\mathbb{R}^{D_s},  &&
t\in\mathcal{T}\sub\mathbb{R}^{+} \\
\end{aligned}
$$ (eq:qg_fields)

Let's assume we have a stack of said fields, i.e. $q_k,\psi_k$.
So we have a state defined as:

$$
\begin{aligned}
\text{Stream Function}: &&
\vec{\boldsymbol{\psi}} = [\psi_1, \psi_2, \ldots, \psi_K]^\top \\
\text{Potential Vorticity}: &&
\vec{\boldsymbol{q}} = [q_1, q_2, \ldots, q_K]^\top \\
\end{aligned}
$$ (eq:qg_state)

We can write the QG PDE to describe the spatiotemporal relationship between the PV and the SF which is defined as:

$$
\begin{aligned}
\partial_t q_k + \vec{\boldsymbol{u}}_k\cdot\boldsymbol{\nabla}q_k = F_k + D_k
\end{aligned}
$$ (eq:qg_general)

where at each layer $k$, we have $\vec{\boldsymbol{u}}_k$ is the velocity vector, $q_k$ is the potential vorticity, $F_k$ are the forcing term(s), and $D_k$ are dissipation terms.
The forcing term can be made up of any external forces we deem necessary for the PDE.
For example, we could have wind stress that affects the top layer or bottom friction that affects the bottom layer.
The dissipation term represents all of the diffusion terms.
For example, we could have some lateral friction or hyper-viscosity terms.

The advection term in equation [](#eq:qg_general) includes the velocity vector, $\vec{\boldsymbol{u}}_k$, which is defined in terms of the stream function, $\psi$. 
This is given by:

$$
\vec{\boldsymbol{u}} = [u, v]^\top = \left[ -\partial_y \psi, \partial_x \psi\right]^\top
$$ (eq:qg_general_vel)

The PV is the culmination of the potential energy contained within the dynamical forces, the thermal/stretching forces and the planetary forces.

$$
\text{Potential Vorticity Forces} = \text{Dynamical} + \text{Thermal} + \text{Planetary} + \ldots
$$

Concretely, we can define this the PV and its relationship to the SF and other forces as:

$$
\begin{aligned}
q_k = \boldsymbol{\Delta}\psi_k + (\mathbf{M}\psi)_k + f_k
\end{aligned}
$$ (eq:qg_general_pv)

where at each layer, $k$, we have the dynamical (relative) vorticity, $\boldsymbol{\Delta}\psi_k$, the thermal/stretching vorticity, $(\mathbf{M}\psi)_k$, and the planetary vorticity, $f_k$. 


---
## Idealized QG Model

We can use the above formulation to describe an idealized QG model.
This idealized model will be fairly abstract with parameters that represent real things but do not actually correspond to anything tangible.
However, these types of flows are *very* well-studied and are very useful for having a controlled setting which removes all uncertainties.
We will use the notation used in [{cite}`10.48550/arxiv.2204.03911,10.48550/arxiv.2304.05029 `] with some explanations taken from [{cite}`10.48550/arxiv.2209.15616`].

The domain is simplified to be periodic and defined on a $2\pi$ domain, i.e. $Lx = L_y = 2\pi$.
We will also assume a periodic domain.
This domain is topologically equivalent to a two-dimensional torus.

We will define a final form for the idealized QG model of the vorticity-stream functions on this idealized, periodic domain as

$$
\partial_t \omega + \det\boldsymbol{J}(\psi,\omega) =
 - \mu\omega +
 \nu\boldsymbol{\nabla}^2\omega - 
\beta\partial_x\psi +
F
$$ (eq:qg_idealized)

where $\omega$ is the vorticity and $\psi$ is the stream function.
The $\beta\psi_x =\beta v$-term is geophysical system approximation that captures the effect of the differential rotation.
This force is experienced within the Earth system in a tangent plane approximation, i.e. $\beta = \partial_y f$.
This $\beta$-term is important and it allows the flow to manifest different turbulent regimes. 
For example, Rossby waves are common within the planetary systems and can appear when $\beta=0$. 
The determinant Jacobian term encapsulates the advection term seen in [](#eq:qg_general). 
It is defined as:

$$
\begin{aligned}
\text{Determinant Jacobian}: && &&
\det \boldsymbol{J}(\psi,\omega) &= 
\partial_x\psi\partial_y \omega - 
\partial_y\psi\partial_x \omega
\end{aligned}
$$ (eq:eq_detj)

We see from [](#eq:qg_detj) that it is directly related to the advection term seen in [](#eq:qg_general) but written in a different way.

:::{note} Determinant Jacobian
:class: dropdown

Like most things in physics, there are often many ways to express the same expression.
Ultimately, they are all advection expressions.
See the example on [wikipedia](https://en.wikipedia.org/wiki/Jacobian_matrix_and_determinant#Example_1) for more details.
The detemrinant Jacobian term [](#eq:qg_detj) can be written in many ways.
Let's rewrite it as:

$$
\text{Advection} = \det \boldsymbol{J}(\psi,\omega)
$$

We can expand the full expression which gives us

$$
\text{Advection}  = 
\partial_x\psi\partial_y \omega - 
\partial_y\psi\partial_x \omega 
$$

We can plug int the velocity components of the stream function definition [](#eq:qg_general_vel) into the above equation

$$
\text{Advection} = v\partial_y \omega - u\partial_x \omega
$$

The partial derivative operator is commutable so we can take out the operator of both terms

$$
\text{Advection} = \partial_y (v\omega) - \partial_x (u\omega)
$$

Alternatively, we can write the velocity and partial derivative operators in the vector format

$$
\text{Advection} = \vec{\boldsymbol{u}} \cdot \boldsymbol{\nabla} \omega
$$

and we see that we arrive at formulation in [](#eq:qg_idealized).
I personally prefer this way of writing it as it is more general. 
Furthermore, it exposes the many ways we can express this term like the determinant Jacobian or simple partial derivatives.

**Note**: It is important to take note of the many ways to express this as it can be useful for numerical schemes. 
For example, an upwind scheme might benefit from advection term where the velocity components are multiplied with the partial derivatives. 
Alternatively the determinant Jacobian on an Arakawa C-grid is a well known formulation for dealing with this.

:::

The forcing term is typically chosen to be a constant wind forcing

$$
\boldsymbol{F}_\omega(\vec{\mathbf{x}}) = k_f
\left[ \cos (k_f x) + \cos (k_f y)\right]
$$ (eq:qg_idealized_wind)

:::{seealso} Relation to Navier-Stokes Equations
:class: dropdown

> This derivation and explanation was largely taken from [{cite}`10.48550/arxiv.2304.05029`] which has one of the best high-level explanation of the derivation without too much mathematical detail.

Taking a velocity field, $\vec{\boldsymbol{u}} = [u,v]^\top$,
we can write the non-dimensional form of the Navier-Stokes (N-S) equations as

$$
\partial_t \vec{\boldsymbol{u}} + 
\vec{\boldsymbol{u}} \cdot \boldsymbol{\nabla}\vec{\boldsymbol{u}} +
f (k \times \vec{\boldsymbol{u}}) =
-\mu \vec{\boldsymbol{u}} +
\frac{1}{Re}\boldsymbol{\nabla}^2\vec{\boldsymbol{u}} +
\boldsymbol{F}_{\vec{\boldsymbol{u}}}(\vec{\mathbf{x}})
$$ (eq:ns_idealized_nondim)

The, $f$, is the Coriolis parameter which is the local rotation rate of the Earth and/or other planetary atmospheric forcings.
The example in []() showcases an example with beta-plane forcing.
$\boldsymbol{k}$ is the unit-vector normal to the $(x,y)$-plane. 
The $\mu$ is the linear drag coefficient which represents the bottom friction.
The $Re$ is the Reynolds number measuring the strength of the non-linear advection term, relative to the viscous term. 
In otherwords, the relationship give by:

$$
\vec{\boldsymbol{u}} \cdot \boldsymbol{\nabla}\vec{\boldsymbol{u}}\propto
\frac{1}{Re}\boldsymbol{\nabla}^2\vec{\boldsymbol{u}}
$$

This Reynolds number is indirectly proportional to the viscosity and proportional to the absolute velocity [{cite}`10.48550/arxiv.2209.15616`]

[{cite}`10.48550/arxiv.2304.05029`] choose a Reynolds number of $Re=2,500$.
The forcing is given by

$$
\begin{aligned}
\text{Forcing}: && 
\boldsymbol{F}_{\vec{\boldsymbol{u}}}(\vec{\mathbf{x}}) &=
[-\sin(k_f y), \sin(k_f x)]^\top
\end{aligned}
$$

which is a sinusoidal time-invariant forcing field that continuously drives the flow. In [{cite}`10.1016/j.physd.2022.133568`], the wavenumber $k_f=4$, was chosen.

The velocity field in equation [](#eq:ns_idealized_nondim) is required to satisfy the mass conservation principal given by the continuity equation

$$
\begin{aligned}
\text{Continuity Equation}: &&
\boldsymbol{\nabla}\cdot\vec{\boldsymbol{u}} &= \partial_yu + \partial_xv = 0
\end{aligned}
$$

One can satisfy this by defining a stream function, $\psi(\vec{\mathbf{x}})$, which is a scalar field that is defined as

$$
\begin{aligned}
u = - \psi_y, && && v =\psi_x
\end{aligned}
$$ (eq:qg_idealized_vel)

The stream function and the continuity equations can be expressed as an evolution equation of a single scalar field, the vorticity.
This scalar field is defined as the two-dimensional curl of the velocity field

$$
\omega = \boldsymbol{\nabla}\times \vec{\boldsymbol{u}}=\partial_x v - \partial_y u = \boldsymbol{\nabla}^2\psi
$$

This equation captures the local rotation of a fluid parcel.
The final result is the incompressible 2D Navier-Stokes equations in the **scalar vorticity stream function form**.
In other words, the Quasi-Geostrophic equations.

$$
\partial_t \omega + \det\boldsymbol{J}(\psi,\omega) - \beta v=
 - \mu\omega +
 \frac{1}{Re}\boldsymbol{\nabla}^2\omega +
F
$$ (eq:qg_ns)

**Note**:
There are some small differences between this equation and .
The first is the coefficient in front of the diffusion term, $\boldsymbol{\nabla}^2\omega$. Here, we have the Reynolds number, $1/Re$ instead of the viscosity term, $\nu$, as shown in [](#eq:qg_idealized).
In addition, we have the $\beta$ term. 
In this formulation, it is $\beta v$ whereas in [](#eq:qg_idealized) it is expressed as $\beta \partial_x$.
However, these are equivalent because the first component of the stream function velocities [](#eq:qg_idealized_vel) is defined as $v=\partial_x\psi$.
So we can plug this into the equation above.

**NOTE**: I am not sure about the sign issue of the $\beta$-term in [](#eq:qg_ns).
I think it is a mistake and that it should be positive which would match the equation in [](#eq:qg_idealized) along with various other formulations [{cite}`10.48550/arxiv.2204.03911`]

:::

---
### Case Studies

#### Flow Regimes

In [{cite}`10.48550/arxiv.2204.03911`], they were looking at how the QG model could be help train surrogate models to fill in missing dynamics. They did the whole training regime online.

:::{tip} Parameter Details
:class: dropdown

Below are some experimental parameters found in  which showcase 3 different flow regimes based on the parameter scheme.

```{list-table} Table with idealized configuration
:header-rows: 1
:name: tb:qg_idealized

* - Name
  - Symbol
  - Units
  - Decay Flow
  - Forced Flow
  - $\beta$-Plane Flow
* - Resolution
  - $N_x\times N_y$ 
  - 
  - $2,048\times 2,048$
  - $2,048\times 2,048$
  - $2,048\times 2,048$
* - Domain
  - $L_x\times L_y$
  - km
  - $10e3 \times 10e3$
  - $10e3 \times 10e3$
  - $10e3 \times 10e3$
* - Time Step
  - $\Delta_t$
  - s
  - $120$
  - $120$
  - $120$
* - Linear Drag Coefficient
  - $\mu$
  - m$^{-1}$
  - $0$ 
  - $1.25e-8$
  - $1.25e-8$
* - Viscosity
  - $\nu$
  - m$^2$s$^{-1}$
  - $67.0$ 
  - $22.0$
  - $22.0$
* - Beta-Term
  - $\beta$
  - m$^{-1}$s$^{-1}$
  - $0.0$ 
  - $0.0$
  - $1.14e-11$
* - Reynolds Number
  - $Re$
  - 
  - $32e3$
  - $22e4$
  - $34e4$
```

:::








---
## Toy QG

> In this section, we will briefly outline an idealized QG model with terms that correspond to real quantities in nature.
> This was taken from the lab that's available online ([PDF](https://clouds.eos.ubc.ca/~phil/numeric/pdf_files/Lab_8.pdf) | [Course](https://rhwhite.github.io/numeric_2022/notebooks/lab9/01-lab9.html) | [Notebook](https://github.com/rhwhite/numeric_2022/blob/main/notebooks/lab8/01-lab8.ipynb) | [Code](https://github.com/rhwhite/numeric_2022/blob/main/numlabs/lab8/qg.py)).
> It features a great step-by-step introduction to a complete toy problem.

$$
\partial_t q + \vec{\boldsymbol{u}}\cdot q = 
\frac{1}{\rho H}\boldsymbol{\nabla}_H\times\vec{\boldsymbol{\tau}} -
\kappa\boldsymbol{\nabla}_H\psi +
a_4\boldsymbol{\Delta}_H^2 -
\beta\partial_x\psi
$$ (eq:qg_toy)

where $q=\boldsymbol{\nabla}^2\psi$ is the PV.
This PDE describes the transport of the PV with respect to the following

$$
\partial_t q + \text{Advection} =
\text{Wind Stress} + \text{Bottom Friction} +
\text{Dissipation} + \text{Planetary Forces}
$$

which correspond to all of the terms in equation [](#eq:qg_toy).

**Horizontal Operators**.
Apart from the partial derivative operators, we have some horizontal operators which means that they only operate on the horizontal axis, i.e. $(x,y)$. 
$\boldsymbol{\nabla}_H$ is the horizontal gradient operator defined as $\boldsymbol{\nabla}_H = [\partial_x, \partial_y]^\top$. 
$\boldsymbol{\Delta}_H$ is the horizontal Laplacian operator defined as $\boldsymbol{\Delta}_H = [\partial^2_x, \partial^2_y]^\top$.
$\boldsymbol{\Delta}_H^2$ is the hyper-Laplacian operator which is normally applied sequentially, i.e. $\boldsymbol{\Delta}_H\circ\boldsymbol{\Delta}_H$.

**Advection**. 
We have the advection term defined as the dot product velocity vector (equation [](#eq:qg_general_vel)) defined via the stream function.
As mentioned above, there are many ways to write this advection term, for example the determinant Jacobian.


**Wind Stress**.
We have defined a wind stress term which is the cross product of the horizontal gradient and the wind stress, $\vec{\boldsymbol{\tau}}$.
As shown above, this term is a 2D vector field for the x and y directions.

$$
\vec{\boldsymbol{\tau}} := 
\vec{\boldsymbol{\tau}}(x,y) = 
\left[ \tau_x(x,y), \tau_y(x,y)\right]^\top
$$ (eq:qg_forcing_wind)

An "ideal" example os to assume the ocean is a "box" that extends from the equator to a latitude of about 60$^\circ$.
The winds are typically constant and easterly near the equation and turn westerly at middle latitudes.
In ideal setting, this is prescribed as a constant cosine forcing $\vec{\boldsymbol{\tau}}=\vec\tau_{\text{max}}(-\cos y,0)$ which is similar to the idealized QG model listed above.
This product is then scaled according to the inverse of the density of water, $\rho$, and the height of the layer, $H$.

**Bottom Friction**.
The bottom friction parameter is a scaling constant that dissipates the energy.
The constant, $\kappa$, is defined as inversely proportional to the product of the height, $H$, and the square-root of the vertical Eddy viscosity constant and the Coriolis parameter.
This constant is multiplied with the Laplacian of the stream function.

**Dissipation**.
There is a dissipation term which features the hyper-viscosity term.
The horizontal hyper-Laplacian of the stream function is multiplied by some constant $\nu_H$ which represents the lateral Eddy viscosity that may occur in the system.

**Planetary Forcing**
The planetary forcing within this toy model is given by the $\beta$-plane approximation for the planetary vorticity. 
This is given by the $\beta$ term which is defined as

$$
\beta \approx \partial_y f
$$

where $f$ is the planetary forcing function given by equation [](#eq:planetary_vorticity).
The only term in this function that depends upon $y$ is the second term so we approximate this as $\beta$.

:::{tip} Parameter Details
:class: dropdown

> There are many constants that are displayed in equation [](#eq:qg_toy) and they each mean something.
> Below are some tables which outline each of the constants and parameters seen in the equation.
> The subsequent tables showcase some derived quantities.
> The last table showcases the nondimensional versions which might be useful for the non-dimensional version of the PDE.

The first table showcases the constants along with the range of values that it can take for the toy model.


```{list-table} Table with constants
:header-rows: 1
:name: tb:qg_constants

* - Name
  - Symbol
  - Units
  - Value
* - Earth's Radius
  - $R$ 
  - m
  - $6400e3$
* - Earth's Angular Frequency
  - $\Omega$ 
  - s$^{-1}$
  - $7.25e-5$
* - Depth of Active Layer
  - $H$ 
  - m
  - $100 \rightarrow 4,000$
* - Length of Ocean Basin
  - $L$ 
  - m
  - $1000e3 \rightarrow 5000e3$
* - Density of Water
  - $\rho$
  - kg m$^{-3}$ 
  - $1e3$
* - Lateral Eddy Viscosity
  - $\nu_H$
  - m$^2$s$^{-1}$ 
  - $0$ or $1e1 \rightarrow 1e4$
* - Vertical Eddy Viscosity
  - $\nu_Z$
  - m$^2$s$^{-1}$ 
  - $1e-4 \rightarrow 1e1$
* - Maximum Wind Stress
  - $\tau_{\text{max}}$
  - kg m$^{-1}$s$^{-2}$ 
  - $1e-2\rightarrow 1$
* - Mean/Mid Latitude
  - $\theta_0$
  - 
  - $0\rightarrow \pi/3$

```

The second table lists some of the derived constants that we can calculate given the above constants.

```{list-table} Table of derived quantities.
:header-rows: 1
:name: tb:qg_derived_constants

* - Name
  - Equation
  - Units
  - Value
* - $\beta$-Plane
  - $\beta = 2\Omega\cos\theta_0/R$ 
  - 
  - $1.1 \rightarrow 2.3e11$
* - Coriolis Parameter
  - $f_0 = 2\Omega\sin\theta_0$ 
  - s$^{-1}$
  - $0.0 \rightarrow 1.3e-4$
* - Velocity Scale
  - $U_0 = \tau_{\text{max}}/(\beta\rho H L)$ 
  - 
  - $1e-5 \rightarrow 1e-1$
* - Bottom Friction
  - $\kappa = \frac{1}{H\sqrt{(\nu_Z f_0)/2}}$ 
  - 
  - $0.0 \rightarrow 1e-5$
```

The last table lists the non-dimensional derived quantities which are useful for the non-dimensional version of the toy QG PDE [](#eq:qg_toy).

```{list-table} Table of non-dimensional quantities.
:header-rows: 1
:name: tb:qg_nondimensionals

* - Name
  - Equation
  - Value
* - 
  - $\epsilon/\text{Vorticity Ratio} = U_0/(\beta L^2)$ 
  - 
* - 
  - $\tau_{\text{max}}/(\epsilon\beta^2\rho HL^3)$ 
  - $1e-12 \rightarrow 1e-14$
* - 
  - $\kappa/(\beta L)$ 
  - $4e-4 \rightarrow 6e1$
* - 
  - $\nu_H/(\beta L^3)$ 
  - $1e-7 \rightarrow 1e-4$
```

:::


---
## QG for Sea Surface Height

> In this section, we will briefly outline how the QG equations can be used to represent the

There is a known relationship between sea surface height (SSH) and the stream function. This is given by

$$
\eta = \frac{f_0}{g}\psi
$$ (eq:qg_ssh_sf)

where $f_0$ and $g$ is the Coriolis and gravity constant respectively.

This relationship has been exploited in various works in the literature, especially within the data assimilation literature.
For example [{cite}`10.1175/jtech-d-20-0104.1,10.5194/egusphere-2023-509,10.3934/dcdss.2022058`] used a 1 layer QG model to assimilate NADIR alongtrack SSH observations.
A related example was in [{cite}`10.1029/2021MS002613`] where they used a simple 1 layer QG model and a 1 layer linear SW model to model the *balanced motions* and the *internal tides* respectively.
This was also used to assimilate NADIR and SWOT alongtrack SSH observations.

To write out the PDE, we will use the same formulation listed in equation [](#eq:qg_general).
However, we will change this to reflect the relationship between SSH, the SF and now the PV.

$$
q = (\boldsymbol{\nabla}^2 - \frac{f_0^2}{c^2})\psi + f
$$ (eq:qg_ssh_pv)

where $f$ is the planetary forcing given by equation [](#eq:planetary_vorticity), $f_0$ is the Coriolis parameter and $c$ is the phase speed.
This formulation is very similar to the PV listed in [](#eq:qg_general_pv) except for the coefficient listed in front of the $\psi$ component.
This can be summarized as the barotrophic deformation wavenumber

$$
k = \frac{f_0}{c}=\frac{1}{L_R}
$$

where $L_R$ is the Rossby radius of deformation. 
In an idealized setting, this is equal to $L_R = \sqrt{gH}/f_0$
It is a helpful parameter that can be used for the QG model of choice.
For example, in [{cite}`10.1175/jtech-d-20-0104.1`], they used a Rossby radius of $30$km for a $10^\circ\times 10^\circ$ domain.


### Case Studies

The most common case study I have seen for this would be applied to data assimilation.
In particular, the QG model has been used to assimilate SSH satellite observations [{cite}`10.3934/dcdss.2022058`].



In [{cite}`10.3934/dcdss.2022058`], the authors did a free-run of the QG model for an assimilation task of 21 days.
Their target area was over the North Atlantic (NA) domain.
A slight change to the above formulation is that they used a forcing term as the constant wind forcing term outlined above.
**Note**: They needed to do $\sim$10,000 spinup steps to get a good running simulation.

Below is an outline of the configuration.


:::{tip} Parameter Details
:class: dropdown

**Note**: They used a LeapFrog scheme for the integrator.




```{list-table} Fixed for their Eddy resolving simulations.
:header-rows: 1
:name: tb:qg_idealized

* - Name
  - Symbol
  - Units
  - Value
* - Domain Size
  - $L_x\times L_y$ 
  - km
  - `2_052 x 3_099`
* - Resolution
  - $dx\times dy$ 
  - km
  - `18 x 18`
* - Grid Size
  - $N_x\times N_y$ 
  - 
  - `113 x 170`
* - Time Step
  - $\Delta t$ 
  - s
  - `600`
* - Phase Speed
  - $c$
  - ms$^{-2}$ 
  - `[2.5, 1.0, 1.0]`
* - Assimilation Window
  - $T$ 
  - days
  - `21`
* - Time Splitter
  - $\mu$
  -  
  - `0.2`
  
```


:::





---
## Stacked QG Model

> In this section, we will look at the formulation from the stacked QG model.
> The majority of this section comes from papers by [{cite}`10.48550/arxiv.2204.13914,10.22541/essoar.167397445.54992823/v1`] with some inspiration from the [Q-GCM](http://www.q-gcm.org/) numerical model.

In this case, we are similar to the generalized QG model outlined in equation [](#eq:qg_general).
We will change the notation slightly.
Let's have a stacked set of PV and SF vectors denoted as $\vec{\boldsymbol{q}}$ and $\vec{\boldsymbol{\psi}}$ respectively. 
We consider the stream function and the potential vorticity to be $N_Z$ stacked  isopycnal layers.
This is already outlined in equation [](#eq:qg_state)
Now, we will write the stacked model in vector format as


$$
\partial_t \vec{\boldsymbol{q}} +
\vec{\boldsymbol{u}}\cdot\boldsymbol{\nabla}
\vec{\boldsymbol{q}} = 
\mathbf{BF} + \mathbf{D}
$$ (eq:qg_stacked)

where $F$ is a vector of forcing terms to be applied at each layer, $k$, $\mathbf{B}$ is a matrix of interlayer height scaling factors and $\mathbf{D}$ is a vector of dissipation terms to be applied at each layer, $k$.
This is analogous to equation [](#eq:qg_general) but in vector format instead of a component-wise.

We can also define the PV equation in vectorized format (analogous to equation [](#eq:qg_general_pv)) as

$$
\vec{\boldsymbol{q}} =
\left(\boldsymbol{\nabla}^2 - f_0^2\mathbf{M}\right)\psi
+ \beta y
$$ (eq:qg_stacked_pv)

Below, we will go over some key components of these two formulations.

### Inter-Connected Layers

We define $\mathbf{B}$ as the matrix which connects the inter-layer interactions.
This is a bi-diagonal matrix which only maps the corresponding layer $k$ and $k-1$.

$$
\mathbf{B} =
\begin{bmatrix}
\frac{1}{H_1} & \frac{-1}{H_1} & 0 & \ldots & \ldots  \\
0 & \frac{1}{H_1} & \frac{-1}{H_2} & \ldots & \ldots  \\
\ldots & \ldots & \ldots & \ldots & \ldots \\
\ldots & \ldots & \frac{-1}{H_{N-1} } & \frac{1}{H_{N-1}} & 0  \\
\ldots & \ldots& \ldots & \frac{-1}{H_N} & \frac{1}{H_N}   \\
\end{bmatrix}
$$ (eq:qg_stacked_B)

We also have $\mathbf{M}$ as the matrix connecting the layers of the stream function

$$
\mathbf{M} =
\begin{bmatrix}
\frac{1}{H_1 g_1'} & \frac{-1}{H_1 g_2'} & \ldots & \ldots & \ldots  \\
\frac{-1}{H_2 g_1'} & \frac{1}{H_1}\left(\frac{1}{g_1'} + \frac{1}{g_2'} \right) & \frac{-1}{H_2 g_2'} & \ldots & \ldots  \\
\ldots & \ldots & \ldots & \ldots & \ldots \\
\ldots & \ldots & \frac{-1}{H_{n-1} g_{n-2}'} & \frac{1}{H_{n-1}}\left(\frac{1}{g_{n-2}'} + \frac{1}{g_{n-1}'} \right) & \frac{-1}{H_{n-1} g_{n-2}'}  \\
\ldots & \ldots& \ldots & \frac{-1}{H_n g_{n-1}'} & \frac{1}{H_n g_{n-1}'}   \\
\end{bmatrix}
$$ (eq:qg_stacked_M)

This matrix is a tri-diagonal matrix as each layer, $k$, within the stacked layers will influence or be influenced by the neighbours, $k-1,k+1$

### Forcing

We have a forcing vector/matrix $\mathbf{F}$ which defines the forcing we apply at each layer.
For example, the top layer could have wind forcing and/or atmospheric forcing.
The bottom layer could have bottom friction due to the topography.

$$
\mathbf{F} =
\left[ F_0, 0, \ldots, 0, F_N\right]^\top
$$ (eq:qg_stacked_F)

where we have the wind stress and the bottom friction. 
The wind forcing could be 

$$
\begin{aligned}
F_0 =& \partial_x\tau_y - \partial_y\tau_x \\
\vec{\boldsymbol{\tau}} =& \frac{\tau_0}{\rho_0 H_1}
\left[ -\cos(2\pi y/L_y), 0\right]^\top
\end{aligned}
$$ (eq:qg_stacked_wind)

and the bottom friction could be described as

$$
\begin{aligned}
F_N =& \frac{\delta_{ek}}{2H_N} \boldsymbol{\nabla}\psi_N
\end{aligned}
$$ (eq:qg_stacked_bottom)

where $\delta_{ek}$ is the Ekman coefficient.


### Dissipation

We have a very similar dissipation stategy as listed above in .... 
Here, we define this as

$$
\begin{aligned}
\text{Viscosity}: && &&
D_1 &= a_2 \boldsymbol{\Delta}^2\psi \\
\text{HyperViscosity}: && &&
D_2 &= - a_4 \boldsymbol{\Delta}^3\psi
\end{aligned}
$$ (eq:qg_stacked_dissipation)





### Case Studies

#### Q-GCM

There is an open-source QG GCM model ([Q-GCM](http://www.q-gcm.org/)) that is available.
It has a coupled model for the atmosphere and ocean where the atmospheric component is a stacked QG model and the oceanic component is a stacked QG model.
They describe in detail two configurations for the double-gyre (North Atlantic) and the southern ocean. 
We outline in detail their

:::{tip} Parameter Details
:class: dropdown

Below is a table with the parameter configuration for their experiments.


```{list-table} Variable parameters for their Northern and Southern Ocean experiments.
:header-rows: 1
:name: tb:qg_stacked_gcm

* - Name
  - Symbol
  - Units
  - Double Gyre
  - Southern Ocean
* - Domain Size
  - $L_x \times L_y$
  - km
  - `3_840 x 4_800`
  - `23_040 x 2_880`
* - Resolution
  - $dx \times dy$
  - km
  - `10 x 10`
  - `10 x 10`
* - Grid Size
  - $N_x \times N_y$
  - 
  - `384 x 480`
  - `2_304 x 288`
* - Time Step
  - $\Delta t$
  - min
  - `30`
  - `10`
* - Mean Layer Thickness
  - $H_k$ 
  - m
  - `[300, 1_100, 2_600]`
  - `[300, 1_100, 2_600]`
* - Reduced Gravity
  - $g_k$ 
  - ms$^{-2}$
  - `[0.05, 0.025]`
  - `[0.05, 0.025]`
* - Bottom Ekman Layer Thickness
  - $\delta_{ek}$ 
  - m
  - `1`
  - `2`
* - Ocean Density
  - $\rho_0$ 
  - kgm$^{-3}$
  - `1_000`
  - `1_000`
* - Baroclinic Rossby Radii
  - $L_d$ 
  - km
  - `[51, 32]`
  - `[42, 26]`
* - Laplacian Viscosity Coefficient
  - $a_2$
  - m$^2$s$^{-1}$
  - `0`
  - `0`
* - BiHarmonic Viscosity Coefficient
  - $a_4$
  - m$^4$s
  - `1e10`
  - `3e10`
* - Mean Coriolis Parameter
  - $f_0$
  - s$^{-1}$
  - `1e-4`
  - `-1.1947e-4`
* - Coriolis Parameter Gradient
  - $\beta$
  - m$^{-1}$s$^{-1}$
  - `2e-4`
  - `1.313e-11`
```

:::


---
#### Dissipation Studies

In the paper [[Thiry et al., 2023](https://doi.org/10.22541/essoar.167397445.54992823/v1)], they were investigating the impact of implicit dissipation via numerical methods or explicit dissipation via a hyper-viscosity parameter.
For their experiments, they use the stacked QG model that was listed above to do a canonical double gyre experiment.

$$
\partial_t \vec{\boldsymbol{q}} +
\vec{\boldsymbol{u}}\cdot\boldsymbol{\nabla}_H
\vec{\boldsymbol{q}} = 
a_2\boldsymbol{\Delta}_H^2\psi 
-a_4\boldsymbol{\Delta}_H^3\psi +
\frac{\tau_0}{\rho_0H_1}\left[\partial_x\tau_y - \partial_y\tau_x, 0\cdots,0\right] -
\frac{\delta_{ek}}{2H_{N_Z}}
\left[0,\cdots,0,\Delta\psi_N\right]
$$

Using this model, they modified the configuration of the spatial resolution and the hyper-viscosity which coincide with Eddy non-resolving, Eddy permitting, and Eddy resolving cases.
They showcased how the numerical scheme they used was better than explicitly prescribing the dissipation.

:::{tip} Parameter Details
:class: dropdown

Below is a table with the parameter configuration for their experiments.


```{list-table} Variable parameters for their Eddy resolving simulations.
:header-rows: 1
:name: tb:qg_stacked_louis_variable

* - Name
  - Symbol
  - Units
  - Non-Eddy Resolving
  - 
  -
  - Eddy Permitting
  - 
  - 
  - Eddy Resolving
* - Grid Size
  - $N_x \times N_y$
  - 
  - `129 x 129`
  - `161 x 161`
  - `193 x 193`
  - `257 x 257`
  - `385 x 385`
  - `513 x 513`
  - `1,025 x 1,025`
* - Resolution 
  - $dx \times dy$ 
  - km
  - `40 x 40`
  - `32 x 32`
  - `26 x 26`
  - `20 x 40`
  - `13.3 x 13.3`
  - `10 x 10`
  - `5 x 5`
* - Time Step
  - $\Delta t$ 
  - s
  - `8_000`
  - `6_000`
  - `5_400`
  - `4_000`
  - `2_700`
  - `2_000`
  - `1_000`
* - Munk Scale
  - $\delta$ 
  - 
  - `1`
  - `1`
  - `1`
  - `1`
  - `1.25`
  - `1.5`
  - `2`
* - Hyperviscosity
  - $a_4$ 
  - m$^4$s$^{-1}$
  - `1.8e12`
  - `5.9e11`
  - `2.4e11`
  - `5.6e10`
  - `2.6e10`
  - `1.3e10`
  - `1.7e9`
```

Below is a table with the fixed parameters that stayed constant throughout the simulation.

```{list-table} Fixed for their Eddy resolving simulations.
:header-rows: 1
:name: tb:qg_stacked_louis_fixed

* - Name
  - Symbol
  - Units
  - Value
* - Domain Size
  - $L_x\times L_y$ 
  - km
  - `5120 x 5120`
* - Mean Layer Thickness
  - $H_k$ 
  - m
  - `[400, 1_100, 2_600]`
* - Reduced Gravity
  - $g_k$ 
  - ms$^{-2}$
  - `[0.025, 0.0125]`
* - Bottom Ekman Layer Thickness
  - $\delta_{ek}$ 
  - m
  - `1`
* - Wind Stress Magnitude
  - $\tau_0$ 
  - Nm$^{-1}$ | Pa
  - `0.08`
* - Ocean Density
  - $\rho_0$ 
  - kgm$^{-3}$
  - `1_000`
* - Mean Coriolis Parameter
  - $f_0$ 
  - s$^{-1}$
  - `9.375e-5`
* - Coriolis Parameter Gradient
  - $\beta$ 
  - ms${-1}$
  - `1.754e-11`
* - Baroclinic Rossby Radii
  - $L_d$ 
  - km
  - `[41, 25]`
```

---

**Forcing**

They used a stationary symmetric wind stress forcing.

$$
\begin{aligned}
\tau_x = - \frac{\tau_0}{\rho_0}
\cos
\left[ \frac{2\pi y}{L_y} \right], && &&
\tau_y = 0
\end{aligned}
$$

---

**Boundaries**

* For the velocity, $\vec{\boldsymbol{u}}$, they use *free-slip* boundaries, i.e., the tangential velocity for the North-South extent is zero.
* For the relative vorticity, $q$, they use zero boundaries.

---

**Note**: they used a 60 year spin-up period to get started.


:::



---
#### Data Assimilation Benchmark

In [{cite}`10.1002/qj.3891`], they were exploring the effectiveness of a data assimilation method (4DVar) when applied to observation data.

They used a simple 2-Layer QG model with the stream function $\psi_k$ and the potential vorticity, $q_k$, as shown in equation [](#eq:qg_stacked).
In the equation, they don't have any explicit forcing but they do mention some optional constant wind forcing.

They have a two layer system so their M-equation will be

$$
\mathbf{M} =
\begin{bmatrix}
\frac{f_0^2}{H_1 g} & \frac{-f_0^2}{H_1 g} \\
\frac{-f_0^2}{H_n g} & \frac{f_0^2}{H_n g}   \\
\end{bmatrix}
$$ 

which is similar to equation [](#eq:qg_stacked_M) except they put the constant Coriolis parmater inside. 
In addition, they don't have any reduced gravities, just a constant gravity for each term.

This was designed for speed, stability, and convenience instead of accuracy and conservation.



:::{tip} Parameter Details
:class: dropdown

The authors have written the formulation completely out as.

$$
\begin{aligned}
q_1 &= \nabla^2\psi_1 - F_1(\psi_1 - \psi_2) + \beta y \\
q_2 &= \nabla^2\psi_2 - F_2(\psi_2 - \psi_1) + \beta y + R_s
\end{aligned}
$$

where $\beta$ is the (non-dimensionalized) northward derivative, $f$ is the Coriolis parameter, $y$ is the vertical coordinate and $R_s$ represents the orography or heating.
The parameters, $F_1,F_2$, are the parameters that couple the laters together.

Below are some experimental parameters for the experimental setup


```{list-table} Parameters
:header-rows: 1
:name: tb:qg_stacked_louis_fixed

* - Name
  - Symbol
  - Units
  - Value
* - Basin Length
  - $L$ 
  - m
  - `1e6`
* - Velocity
  - $U$ 
  - ms$^{-1}$
  - `10`
* - Coriolis Parameter
  - $f_0$ 
  - s$^{-1}$
  - `1e-4`
* - Northward Derivative
  - $\beta_0$ 
  - m$^{-1}$s$^{-1}$
  - `1.5e-11`
* - Layer Depths
  - $D_1, D_2$ 
  - m
  - `[6_000, 4_000]`
* - Mean Potential Temperature
  - $\bar{\theta}$ 
  - ...
  - ...
* - Layer Difference in Potential Temperature
  - $\Delta\theta$ 
  - ...
  - ...
* - Ratio PT
  - $\frac{\Delta\theta}{\bar{\theta}}$ 
  - ...
  - `0.1`
* - Mean Wind - Upper
  - ... 
  - ms$^{-1}$
  - `40`
* - Mean Wind - Lower
  - ... 
  - ms$^{-1}$
  - `10`
```

**Note**: the Coriolis paramater is at the *southern boundary*.

---

```{list-table} Non-Dimensionalization
:header-rows: 1
:name: tb:qg_stacked_louis_fixed

* - Name
  - Symbol
  - Units
  - Transformation
* - Time
  - $t$ 
  - s
  - $\tilde{t} \frac{\bar{U}}{L}$
* - X-Coordinate
  - $x$ 
  - m
  - $\frac{\tilde{x}}{L}$
* - Y-Coordinate
  - $y$ 
  - m
  - $\frac{\tilde{y}}{L}$
* - u-Velocity
  - $u$ 
  - ms$^{-1}$
  - $\frac{\tilde{u}}{U}$
* - v-Velocity
  - $v$ 
  - ms$^{-1}$
  - $\frac{\tilde{v}}{U}$
* - Northward Derivative
  - $\beta$ 
  - ...
  - $\beta_0\frac{L^2}{U}$
* - Coupling Term I
  - $F_1$ 
  - ...
  - $\frac{f_0^2L^2}{D_1 g \frac{\Delta\theta}{\bar{\theta}}}$
* - Coupling Term II
  - $F_2$ 
  - ...
  - $\frac{f_0^2L^2}{D_2 g \frac{\Delta\theta}{\bar{\theta}}}$
* - Rossby Number
  - $\epsilon$ 
  - ...
  - $\frac{\bar{U}}{f_0 L} = 0.1$
```

---

**Experimental Details**

* Time Stepping - first order upstream
* PV Advection - Semi-Lagrangian advection
* Interpolation of upstream PV - bi-cubic
* Advection Outside Domain - edge values
* North-South PV Values - user supplied
* Advection Wind - Inverting PV
* Domain - Cyclic in Zonal Direction

---

**Initial Condition**

They place a Gaussian hill centered at point `(10,15)` with a dimensional height of `2_000m` and an e-folding width of `1_000km`


---

**Errors**

```{list-table} Parameters
:header-rows: 1
:name: tb:qg_stacked_louis_fixed

* - Covariance Matrix
  - Standard Deviation ($\sigma$)
  - Horizontal Correlation ($c_h$)
  - Vertical Correlation ($c_v$)
  - Scales
* - $\mathbf{B}$
  - `0.8` 
  - `0.6e6`
  - `0.2`
  - Short
* - $\mathbf{Q}_s$
  - `0.005555` 
  - `0.6e6`
  - `0.2`
  - Short
* - $\mathbf{Q}_l$
  - `0.005555` 
  - `1.6e6`
  - `0.8`
  - Long
* - $\mathbf{Q}_{k_i}$
  - `0.8` 
  - `1.6e6`
  - `0.8`
  - Long
* - $\mathbf{R}$
  - `0.2` 
  - `0.0`
  - `0.8`
  - Grid Pint
```

:::


### Important Quantities

#### Quasi-Geostrophic Equations

$$
\begin{aligned}
\text{Geostrophic Wind}: && &&
\vec{\boldsymbol{u}}_g &= 
\frac{1}{f_0}\hat{\boldsymbol{k}}
\times
\nabla\Psi \\
\text{Momentum Equation}: && &&
\frac{D_g \vec{\boldsymbol{u}}_g}{D_t} 
&= 
- f_0\hat{\boldsymbol{k}}\times
\vec{\boldsymbol{u}}_g 
- \beta y \vec{\boldsymbol{k}} \times
\vec{\boldsymbol{u}}_g \\
\text{Continuity Equation}: && &&
\partial_x u_a &+ \partial_y v_a + \partial_p \omega = 0 \\
\text{Thermodynamic Equation}: && &&
\left(\partial_t + \vec{\boldsymbol{u}}_g \cdot \nabla\right)
&\left( - \partial_p \Psi\right) - \sigma \omega 
= 
\frac{\kappa J}{p} \\
\text{Auxillary Eqn. I}: && &&
\kappa &= \frac{R_d}{c_p} \\
\text{Auxillary Eqn II}: && &&
\sigma &= - \frac{R_d T_0}{p}\frac{\ln \theta_0}{p}
\end{aligned}
$$

[Source](https://climate.ucdavis.edu/ATM121/AtmosphericDynamics-Chapter05-Part05-QGPotentialVorticity.pdf)

***

#### Potential Vorticity

$$
\begin{aligned}
\text{Barotropic PV}: && &&
\text{PV} &= \frac{\zeta_g + f}{h}, 
&& &&
\text{m}^{-1}\text{s}^{-1}
\end{aligned}
$$

$$
\begin{aligned}
\text{Quasi-Geostrophic PV}: && &&
\text{q} &= 
\frac{1}{f_0}\nabla^2\psi +
f +
\partial_p
\left(\frac{f_0}{\sigma}\partial_p \Psi\right)
&& &&
\text{m}^{-1}
\end{aligned}
$$

The first 2 terms in the equation is the absolute vorticity and the second term is the vertical stretching, i.e., the change in thickness with height.


### Definitions

**Barotropic**: A barotropic fluid is a where a fluids density only depends on pressure.

$$
\rho = \rho(s, t, p)
$$

**Baroclinic**: A baroclinic fluid is where a fluids density depends on pressure and temperature.

$$
\rho = \rho(s, t, p, T)
$$





