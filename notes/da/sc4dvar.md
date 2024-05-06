---
title: Strong-Constrained 4DVar
subject: Machine Learning for Earth Observations
short_title: SC-4DVar
authors:
  - name: J. Emmanuel Johnson
    affiliations:
      - CSIC
      - UCM
      - IGEO
    orcid: 0000-0002-6739-0053
    email: juanjohn@ucm.es
license: CC-BY-4.0
keywords: simulations
---

## Problem Formulation


#### Joint Distribution

$$
p(\boldsymbol{y}_{1:T},\boldsymbol{u}_{1:T},\boldsymbol{\theta}) =
p(\boldsymbol{\theta})p(\boldsymbol{u}_0)
\sum_{t=1}^T
p(\boldsymbol{y}_t|\boldsymbol{z}_t,\boldsymbol{\theta})
$$

#### Posterior

$$
p(\boldsymbol{z}_t|\boldsymbol{})
$$

#### Loss Function

$$
\boldsymbol{J}(\boldsymbol{u},\boldsymbol{\theta}) =
\sum_{t=1}^T\log p(\boldsymbol{y}_t|\boldsymbol{u}_t,\boldsymbol{\theta}) +
\log p(\boldsymbol{z}_0|\boldsymbol{\theta})  + \log p(\boldsymbol{\theta})
$$

So each of the terms:

$$
\begin{aligned}
\text{Data Likelihood}: && &&
p(\boldsymbol{y}_t|\boldsymbol{u}_t,\boldsymbol{\theta}) &=
\mathcal{N}(\boldsymbol{y}_t|\boldsymbol{u}_t,\boldsymbol{\Sigma_{uu}}) \\
\text{Prior State}: && &&
p(\boldsymbol{z}_t|\boldsymbol{\theta}) &=
\mathcal{N}(\boldsymbol{z}_t|\boldsymbol{\mu_z},\boldsymbol{\Sigma_z}) \\
\text{Prior Parameters}: && &&
p(\boldsymbol{\theta}) &=
\mathcal{N}(\boldsymbol{\theta}|\boldsymbol{\mu_\theta},\boldsymbol{\Sigma_\theta}) \\
\end{aligned}
$$

***
## Algorithm

### Data

$$
\begin{aligned}
\text{Observations}: && &&
\mathcal{D} &= \left\{ \boldsymbol{y}_t\right\}_{n=1}^N && &&
\boldsymbol{y}_t \in \mathbb{R}^{D_y} \\
\end{aligned}
$$

***
#### Dynamical Model

$$
\partial_t \boldsymbol{u} = \boldsymbol{f}(\boldsymbol{u},t,\boldsymbol{\theta})
$$

***
#### Adjoint Model

$$
\begin{aligned}
\partial_t \boldsymbol{\lambda} 
&= \boldsymbol{f}^* \left( \boldsymbol{\lambda}, t, \boldsymbol{u}, \boldsymbol{y} \right)
\end{aligned}
$$

```python
def init_f_adjoint(f) -> Callable:
    f = lambda u, lam: jax.vjp(f, u)(lam)[0]
    return f
```

***
### Initial Condition

We need an initial condition for the state, $\boldsymbol{u}_0$, and the parameters, $\boldsymbol{\theta}$.

$$
\begin{aligned}
\text{Initial State}: && &&
\boldsymbol{u}_0 &\in \mathbb{R}^{D_\theta} \\
\text{Initial Parameters}: && &&
\boldsymbol{\theta}_0 &\in \mathbb{R}^{D_\theta} \\
\end{aligned}
$$

***
### Integrate Forward Model

We need the list of time steps which match the observations

$$
\begin{aligned}
\mathbf{T}^+ = \left[t_0,t_1,t_2, \ldots, t_T\right]
\end{aligned}
$$

```python
# time step
dt: float = 0.01
# list of time steps
time_steps: Array["Nt"] = np.arange(0, num_time_steps, dt)
```

We need to pass this through a solver to get our states.

$$
\mathbf{U} = \text{ODESolve}\left( \boldsymbol{f},\boldsymbol{u}_0,\boldsymbol{\theta},\mathbf{T}\right)
$$

```python
state_sol: PyTree = ode_solve(f, u_0, params, time_steps)
```

So we essentially get a matrix of all of the time points output of our model.

$$
\mathbf{U} = \left[\boldsymbol{u}_1, \boldsymbol{u}_2, \ldots, \boldsymbol{u}_T \right] \in \mathbb{R}^{T\times D_u}
$$

```python
# extract state
u_sol: Array["Nt Du"]: state_sol.u
```

***
### Integrate Backward Adjoint Model

Now, we need to do the opposite, we need to run through our solver in reverse using the adjoint model.
First, we need to initialize

$$
\mathbf{T} = \left[ t_T, t_{T-1}, t_{T-2}, \ldots, t_2, t_1, t_0\right]
$$

```python
# list of inverse time steps
time_steps_reverse: Array["Nt"] = time_steps[::-1]
```

$$
\begin{aligned}
\partial_t \boldsymbol{\lambda} 
&= \boldsymbol{f}^* \left( \boldsymbol{\lambda}, t, \boldsymbol{u}, \boldsymbol{y} \right) \\
\boldsymbol{f}^*(\boldsymbol{u}_t,\boldsymbol{\lambda},\boldsymbol{y},\boldsymbol{\theta}) &=
\boldsymbol{J_f}^\top(\boldsymbol{u}_t)\boldsymbol{\lambda} -
\boldsymbol{J_h}^\top(\boldsymbol{u_t})\mathbf{C}_{\boldsymbol{yy}}^{-1}
\left(\boldsymbol{h}(\boldsymbol{u}_t) - \boldsymbol{y}_t\right)
\end{aligned}
$$

Now, we iterate through each of these time steps

$$
\boldsymbol{\lambda}_{t+1} = 
\boldsymbol{f}^*(\boldsymbol{u}_t,\boldsymbol{\lambda}_t,\boldsymbol{y},\boldsymbol{\theta})
$$


***
### Loss Function

***
#### State

First, we have the loss function for the state

$$
\boldsymbol{\nabla_{u_0}}\boldsymbol{L}(\boldsymbol{u}_0,\boldsymbol{\theta},\boldsymbol{\lambda}_0) =
\boldsymbol{\Sigma}_{\boldsymbol{zz}}^{-1}
\left(\boldsymbol{u}_0 - \boldsymbol{\mu}_z \right) - \boldsymbol{\lambda}_0
$$

So a single gradient step would be

$$
\boldsymbol{u}_0^{k+1} = \boldsymbol{u}_0^{k} - \alpha
\mathbf{B}\boldsymbol{\nabla_{u_0}}
\boldsymbol{L}(\boldsymbol{u}_0^{k},\boldsymbol{\theta},\boldsymbol{\lambda}_0)
$$

***
#### Parameters

Secondly, we have the loss function for the parameters

$$
\boldsymbol{\nabla_{\theta}}\boldsymbol{L}(\boldsymbol{u}_0,\boldsymbol{\theta},\boldsymbol{\lambda}_0) =
\boldsymbol{\Sigma}_{\boldsymbol{\theta\theta}}^{-1}
\sum_{t=1}^T
\boldsymbol{J_f}^\top(\boldsymbol{\theta}_t)\boldsymbol{\lambda}_{t+1}
$$

So a single gradient step would be

$$
\boldsymbol{\theta}^{k+1} = \boldsymbol{\theta}^{k} - \alpha
\mathbf{B}\boldsymbol{\nabla_{\theta}}
\boldsymbol{L}(\boldsymbol{u}_0^{k},\boldsymbol{\theta},\boldsymbol{\lambda}_0)
$$