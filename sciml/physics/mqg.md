---
title: Multilayer Quasi-Geostrophic Equations
subject: Jax Approximate Ocean Models
# subtitle: How can I estimate the state AND the parameters?
short_title: Anatomy of PDEs
authors:
  - name: J. Emmanuel Johnson
    affiliations:
      - CNRS
      - MEOM
    orcid: 0000-0002-6739-0053
    email: jemanjohnson34@gmail.com
license: CC-BY-4.0
keywords: data-assimilation, open-science
---




### Wind Forcing

```python
@dataclass
class WindForcing:
    F: Array

    def __init__(self, domain):
        # call wind forcing function
        ...

    def __call__(self, u: Array) -> Array:
        # add wind forcing the array
        u += self.F
        return u
```

### Bottom Drag


### Linear Solver

```python
# matrix vector product
matvec: Array["Nx Ny"] = ...
# RHS
solver = HelmHoltzDSTI
# initialize linear solver
solver = LinearSolver(matvec, solver)

# apply solver
sol = solver(rhs)
```


## Problem Statement

$$
\begin{aligned}
\text{PV}: && &&
q &= q(x), 
&& &&
q: \mathbb{R}^2\rightarrow\mathbb{R}
&& 
x \in \Omega_c \\
\text{SF}: && &&
\psi &= \psi(x), 
&& &&
\psi: \mathbb{R}^2\rightarrow\mathbb{R}
&& 
x \in \Omega_n \\
\text{SF}_b: && &&
\psi_b &= \psi_b(x), 
&& &&
\psi_b: \mathbb{R}^2\rightarrow\mathbb{R}
&& 
x \in \partial\Omega_n \\
\text{Source}: && &&
\rho &= \rho(x), 
&& &&
\rho: \mathbb{R}^2\rightarrow\mathbb{R}
&& 
x \in \partial\Omega_c,\Omega_c \\
\end{aligned}
$$

***
### Objectives

We want to solve the Poisson Equation for an unknown $\psi$ and boundary conditions, $\psi_b$, given some source term, $\rho$.

$$
\begin{aligned}
(\nabla^2 - \beta)\psi &= \rho,
&& &&
x \in \Omega_n \\
\tilde{\psi}_b(x) &= 
\psi_b(x),
&& &&
x \in \partial\Omega_n \\
\end{aligned}
$$

So we need a `LinearSolver`.

We also want to recover $\tilde{q}$ from the estimated $\tilde{\psi}$.

$$
\begin{aligned}
(\nabla^2 - \beta)\tilde{\psi} &= \tilde{q} \\
\rho &= q + f
\end{aligned}
$$

So we need to apply the linear operator.

***
### Scenario I

This first scenario, we assume that all of the variables are on the same grid.

$$
\begin{aligned}
q &= q(x), 
&& &&
x \in \Omega_n \\
\tilde{\psi} &= \tilde{\psi}(x), 
&& &&
x \in \Omega_n \\
\psi_b &= \psi_b(x), 
&& &&
x \in \Omega_n \\
\end{aligned}
$$

**Examples**.
This happens when we calculate the advection term using the Arakawa Determinant Jacobian term.
This also occurs if one decides to calculate the advection term on.

**Solution**.
We can use the Discrete Sine Transform type-I (DST-I) transformation.

```python
ssh: Array["Nx+2 Ny+2"] = ...

# calculate the stream function
psi: Array["Nx+2 Ny+2"] = (g / f0) * ssh

# calculate the perpendicular gradients
u: Array["Nx+2 Ny+2"] = - difference(psi, axis=1, step_size=dy, accuracy=1, method="backward")
v: Array["Nx+2 Ny+2"] = difference(psi, axis=0, step_size=dx, accuracy=1, method="backward")

# calculate the directly...
q: Array["Nx+2 Ny+2"] = divergence(u, v, step_size=(dx,dy), accuracy=1, method="backward")
```

***
### Scenario II

This second scenario, we have the $psi$ and $q$ that are on the cell centers but the boundaries, $\psi_b$, are on the cell corners.

$$
\begin{aligned}
q &= q(x), 
&& &&
x \in \Omega_c \\
\tilde{\psi} &= \tilde{\psi}(x), 
&& &&
x \in \Omega_c \\
\psi_b &= \psi_b(x), 
&& &&
x \in \Omega_n \\
\end{aligned}
$$

**Examples**.
This happens when we calculate the advection term using the Arakawa Determinant Jacobian term.
This also occurs if one decides to calculate the advection term on.

**Solution**.
We can use the Discrete Sine Transform type-I (DST-I) transformation.

```python
ssh: Array["Nx+2 Ny+2"] = ...

# calculate the stream function
psi: Array["Nx+2 Ny+2"] = (g / f0) * ssh

# calculate the perpendicular gradients
u: Array["Nx+2 Ny+1"] = - difference(psi, axis=1, step_size=dy, accuracy=1, method="backward")
v: Array["Nx+1 Ny+2"] = difference(psi, axis=0, step_size=dx, accuracy=1, method="backward")

# calculate the directly...
q: Array["Nx+1 Ny+1"] = divergence(u, v, step_size=(dx,dy), accuracy=1, method="backward")
```


***
### Linear Solver

First, we need to initialize the solver parameters.

```python
# initialize a 
matvec: LinearOperator = ...
# initialize the RHS
b: Array = ...
# initialize solver method, e.g., CG, DST, 
method: str = "CG" # "DST", "GMRES", "BI
# initialize solver
soln: Array = linear_solve(b, matvec, method)
```