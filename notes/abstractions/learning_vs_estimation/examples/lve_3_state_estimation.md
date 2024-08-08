---
title: State Estimation
subject: Modern 4DVar
subtitle: What components can we use to estimate the state?
short_title: State Estimation
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

> In these examples, we will estimate the state of the system. We are not interested in how we estimate the parameters of the data fidelity term or the regularization terms (this will be tackled in another section).

$$
\begin{aligned}
\boldsymbol{z}^*(\boldsymbol{\theta}) &=
\underset{\boldsymbol{z}}{\text{argmin}}
\hspace{2mm}
\boldsymbol{J}(\boldsymbol{z};\boldsymbol{\theta})
\end{aligned}
$$




# Priors


For these examples, let's look at a simple case where we have a Gaussian distribution with a non-linear transformation on the mean function.

$$
\begin{aligned}
\text{Prior State}: &&
\boldsymbol{z} &\sim 
p(\boldsymbol{z};\boldsymbol{\theta})\\
\text{Conditional QOI}: &&
\boldsymbol{u} &\sim 
p(\boldsymbol{u}|\boldsymbol{z};\boldsymbol{\theta})
\end{aligned}
$$


---
# AutoRegressive Priors


A natural approach is to define the spatiotemporal scheme s.t. we enforce a temporal causal structure. We can assume that there is a sequential model that inputs a starting field and propagates it forward in time to create the full trajectory. The most natural way to define this is through some Markovian assumption for some temporal discretization, i.e. the current time step only depends on the previous time step and no other time steps before that. For example, we often make this assumption for ODESolvers for ODEs/PDEs and state space models. 

In most instances, all methods are written in the following form:

$$
\begin{aligned}
\text{Initial Distribution}: &&
\boldsymbol{z}_{0} &\sim 
p(\boldsymbol{z}_0;\boldsymbol{\theta}) \\
\text{Transition Dynamics}: &&
\boldsymbol{z}_{t} &\sim
p(\boldsymbol{z}_{t}|\boldsymbol{z}_{t-1}; \boldsymbol{\theta})\\
\text{Emission Dynamics}: &&
\boldsymbol{u}_{t} &\sim
p(\boldsymbol{u}_{t}|\boldsymbol{z}_{t}; \boldsymbol{\theta})\\
\end{aligned}
$$

This formulation looks familiar to the classic state space model representation except we don't use the terms state and observations. As mentioned in the previous section, we decouple the idea of state and QOI. In addition, for this section, we are looking at priors so we will need the state and QOI as the components. Furthermore, you may see the terms used *Markovian* dynamics and *measurements*. Here we use the terms transition dynamics and emission dynamics respectively. 


Because we have constrained the system to respect Markovian dynamics in the state space, we can write down all of the quantities we can have access to when considering recursion principals and the Chapman-Kolomogrov equation. This results in the following quantities: 

$$
\begin{aligned}
\text{Predictions}: &&
\boldsymbol{z}_t &\sim 
p(\boldsymbol{z}_{t}|\boldsymbol{u}_{1:t-1}; \boldsymbol{\theta}) \\
\text{Filtering}: &&
\boldsymbol{z}_t &\sim 
p(\boldsymbol{z}_{t}|\boldsymbol{u}_{1:t}; \boldsymbol{\theta}) \\
\text{Smoothing}: &&
\boldsymbol{z}_t &\sim 
p(\boldsymbol{z}_{t}|\boldsymbol{u}_{1:T}; \boldsymbol{\theta}) \\
\text{Data Likelihood}: &&
\boldsymbol{u}_t &\sim 
p(\boldsymbol{u}_{t}|\boldsymbol{u}_{1:t-1}; \boldsymbol{\theta}) \\
\end{aligned}
$$

The data likelihood term is the term that would be inserted into the loss function for the parameter estimation case. For state estimation, the filtering term and the prior probability for the initial state would be used within the data fidelity and prior state loss terms. 


### Null Case

I think it is important to mention the null case where we don't separate the state and the QOI. In this case, the conditional distribution for the emission dynamics would just be the identity with no noise. We could also change the notation of the state space from $\boldsymbol{z}$ to $\boldsymbol{u}$. In this case, we are simply putting a likelihood function on the transition dynamics and a prior on the initial distribution.


---
## Weak vs Strong Constrained

This notion of weak constrained versus strong constrained appeared in the classical 4DVar formulation. These are two formulations that relegate how much we trust our function. The function we impose is autoregressive so there are accumulations

**Weak Constrained**. The weak-constrained version works as a "one-step" prediction whereby we step through the trajectory with the ODE solver one at a time up to a designated output. We are sure to output the state during moments of the trajectory to ensure that we can check to ensure that we can check out how well they match the observations. 

We pass this along with our equation of motion, initial condition and boundary conditions into our `TimeStepper` function

$$
\boldsymbol{\Phi}(\boldsymbol{u};\boldsymbol{\theta}) = 
\text{TimeStepper}\left( \boldsymbol{F}, t_0, t_1, \Delta t, \boldsymbol{u}_0, \boldsymbol{u}_b,\boldsymbol{\theta}\right)
$$

The output of this solver will be the field, $\hat{\boldsymbol{u}}_t\in\mathbb{R}^{D_u}$, as the solution to our time stepper. Our subsequent cost function will be

$$
\mathbf{R}(\boldsymbol{u};\boldsymbol{\theta}) =
\frac{1}{2\sigma^2}
\sum_{t=1}^T
||\boldsymbol{u}_t - \boldsymbol{\Phi}(\boldsymbol{u};\boldsymbol{\theta})||_2^2
$$



---
## Weak vs Strong Constrained

In the data assimilation community, they work with dynamical models for state and parameter estimation.
There, they are know that the models are incomplete and only approximate the true physics. 
To reflect their uncertainty of the model on the problem, there is a notion of *weak constrained* vs *strong constrained*.

Recall, many `ODESolvers` use some autoregressive-like time stepper that incrementally approximates the evolution of the fields initial state, $\boldsymbol{u}_0$, from $t=0$ until $t=T$ as see in equation [](#eq:timestepper). 
This works by applying the `TimeStepper` function on the field recursively starting with $t=0$ until it reaches the target time $t=t+\Delta t$ as see in equation [](#eq:timestepper-increment).

The DA community make the distinction between whether or not we apply the time window $\mathcal{T}=[0,T]$ or do we apply it incrementally $\mathcal{T}=\{[t,t+\Delta t], [t+\Delta t, t+2\Delta t], \ldots, \}$. 
We outline both of them in more detail below.

**Strong Constrained**. The strong-constrained version works by applying the solver directly through the entire trajectory from start, $t=0$, to finish, $t=T$. We are sure to output the state during moments of the trajectory to ensure that we can check to ensure that we can check out how well they match the observations. So, the function will look something like:



We pass this along with our equation of motion, initial condition and boundary conditions into our `TimeStepper` function

$$
\boldsymbol{\Phi}(\boldsymbol{u};\boldsymbol{\theta}) = 
\text{TimeStepper}\left( \boldsymbol{F}, \mathbf{T}, \Delta t, \boldsymbol{u}_0, \boldsymbol{u}_b,\boldsymbol{\theta}\right)
$$

The output of this solver will be a matrix, $\mathbf{U}\in\mathbb{R}^{D_T\times D_u}$, which contains all of the solution of the TimeStepper for every time step of interest. So our $\boldsymbol{\phi}$ operator will be

$$
\begin{aligned}
\boldsymbol{\Phi}(\boldsymbol{u};\boldsymbol{\theta}) &= 
\left[ \boldsymbol{u}_T, \boldsymbol{u}_{T-\Delta t}, \ldots, \boldsymbol{u}_{\Delta t}, \boldsymbol{u}_0\right]^\top
\end{aligned}
$$

and our subsequent cost function will be

$$
\mathbf{R}(\boldsymbol{u};\boldsymbol{\theta}) =
\frac{1}{2\sigma^2}
\sum_{t=1}^T
||\boldsymbol{u}_t - \boldsymbol{\Phi}(\boldsymbol{u};\boldsymbol{\theta})||_2^2
$$

**Weak Constrained**. The weak-constrained version works as a "one-step" prediction whereby we step through the trajectory with the ODE solver one at a time up to a designated output. We are sure to output the state during moments of the trajectory to ensure that we can check to ensure that we can check out how well they match the observations. 

We pass this along with our equation of motion, initial condition and boundary conditions into our `TimeStepper` function

$$
\boldsymbol{\Phi}(\boldsymbol{u};\boldsymbol{\theta}) = 
\text{TimeStepper}\left( \boldsymbol{F}, t_0, t_1, \Delta t, \boldsymbol{u}_0, \boldsymbol{u}_b,\boldsymbol{\theta}\right)
$$

The output of this solver will be the field, $\hat{\boldsymbol{u}}_t\in\mathbb{R}^{D_u}$, as the solution to our time stepper. Our subsequent cost function will be

$$
\mathbf{R}(\boldsymbol{u};\boldsymbol{\theta}) =
\frac{1}{2\sigma^2}
\sum_{t=1}^T
||\boldsymbol{u}_t - \boldsymbol{\Phi}(\boldsymbol{u};\boldsymbol{\theta})||_2^2
$$


---
### Pseudo-Code

<!-- :::{tip} Pseudo-Code - ODE Solver
:class: dropdown -->

Let's initialize all of the pieces that we are going to need from the weak-constrained formulation

```python
# initialize inputs
u0: Array["T-1"] = ...
params: PyTree = ...
F: Callable = ...
```

Recall the equation for a single stepper as [](#eq:timestepper-increment).
We can write some pseudo-code to define our custom `TimeStepper` like so:

```python
# initialize integral solver, e.g. Euler, Runga-Kutta, Adam-Bashforth
integral_solver: Callable = ...

def time_stepper(u, params, t0, t1):
  
    # calculate the increment (the integral)
    u_increment = integral_solver(F, u, params, t0, t1)

    # add increment to initial condition
    u += u_increment
    return u
```

Here, we are only calculating the solution to the ODE between $t$ and $t +\Delta t$.
To calculate the recursive step to calculate the full solution to the ODE from equation [](#eq:timestepper), we can do it manually by defining a time vector, $\mathbf{t}$, with all of the time intervals where we want out output state, $\boldsymbol{u}_t$.

\begin{align}
\mathbf{t} &= 
\left[t_0, t_{\Delta t}, t_{2\Delta t}, \ldots,  t_{T-2\Delta t}, t_{T-\Delta t}, t_{T}\right] \in \mathbb{R}^T \\
\mathbf{u} &= 
\left[ u_0, u_1, u_3, \ldots, u_{T-2}, u_{T-1} \right] \in \mathbb{R}^{T-1} \\
\end{align}

Now we can apply our `time_stepper` function recursively.

```python
# initialize time steps
time_steps: Array["T"] = jnp.arange(0, T, dt)

# partition into start times and end times
t0s: Array["T-1"] = time_steps[:-1]
t1s: Array["T-1"] = time_steps[1:]

# initialize initial conditions
u0s: Array["T-1"] = ...

# initialize solutions
u_solutions: List = []

# loop through list of time steps
for u0, t0, t1 in zip(u0s, t0s, t1s):
    # time step
    u: Array[""] = time_stepper(F, u0, t0, t1, params)
    # store the solutions
    u_solutions.append(u)

# concatenate the solutions
u_solutions: Array["T-1"] = jnp.stack(u_solutions, axis=0)
```

Again, most modern functions have this functionality built into the software. 
So we only have to call it on the initial condition.
However, in this case, we need to be careful because it is no longer recursive.
We can `jaxify` it to treat it like vectors.

```python
# initialize time steps
dt = 0.01

# do everything in one shot.
fn: Callable = lambda u0, t0, t1: package.time_stepper(F, u0, params, t0=0, t1=t1, dt=dt)

# apply it as if it were batches of points.
u: Array["T-1"] = jax.vmap(fn, in_axes=(0,0,0))(u0s, t0s, t1s)
```

Using the advanced functionality, we can apply this same method to a function with more functionality to save custom outputs. 
In this case, we only need to store the last time step for each of the increments.

```python
# initialize time steps
dt = 0.01

# time steps for saving the output vector
dt_saved = 0.1
saved_time_steps = jnp.arange(0, T, dt_saved)

# do everything in one shot.
fn: Callable = lambda u0, t0, t1, saveas: package.time_stepper(F, u0, params, t0=0, t1=t1, dt=dt, saveas)

# do everything in one shot.
u: Array["T-1"] = jax.vmap(fn, in_axes=(0,0,0))(u0s, t0s, t1s, t1s)
```

<!-- ::: -->




---
## ODE/PDEs


We can use the exact PDE equations and use an off the shelve `TimeStepper` to do the integration. Typically, to estimate the state using autodiff techniques, the model should be differentiable and relatively light. This is easy for the canonical chaotic dynamical systems like the Lorenz-63, Lorenz-96 or the 2 Layer Lorenz-96. However, for ocean applications, we need some lighter models like the Quasi-Geostrophic equations or the Shallow water equations.

**Stochasticity**. We can also add some stochasticity to the system. We can use the approximate distributions to add stochasticity to the system. This is akin to the transitions step in the Kalman filter methods. We could also add ensembles of trajectories which is akin to the Ensemble Kalman filter methods.




$$
\begin{aligned}
\text{PDE Constraint}: &&
\partial_t\boldsymbol{u}
&= \boldsymbol{F}[\boldsymbol{u};\boldsymbol{\theta}]
(\boldsymbol{\Omega}_u,\mathcal{T}_u)
&& \boldsymbol{F}: \mathbb{R}^{D_u} \times \mathcal{T}_u \times \mathbb{\Theta} \rightarrow \mathbb{R}^{D_u} \\
\text{Initial Condition}: &&
\boldsymbol{u}_0 &= \boldsymbol{u}(\boldsymbol{\Omega}_u,0) \\
\text{Boundary Condition}: &&
\boldsymbol{u}_b &= \boldsymbol{u}(\partial\boldsymbol{\Omega}_u,\mathcal{T}_u) \\
\end{aligned}
$$

This function $\boldsymbol{F}(\cdot)$ can be defined in many different ways. For example, we can take a purely physics-driven approach by defining an equation of motion, aka a PDE, composed as gradient operations on a spatial field, e.g. Quasi-Geostrophic, Shallow Water, Navier-Stokes, etc. We could also take a purely data-driven approach where we parameterized functions which we try to learn from example datasets, e.g. (Deep) Markov Models. Lastly, we could take a hybrid approach between the purely physical model definition and the learned function approach where we combine the two approaches, e.g. [universal differential equations](https://arxiv.org/abs/2001.04385), [parameterization](https://zanna-researchteam.github.io/publication/hewitt-et-al-2020/), hybrid modeling, etc.

Regardless of the approach, we still need to find the  solution which is given by the fundamental theorem of calculus.

$$
\boldsymbol{u}(t_1) = \boldsymbol{u}(t_0) +
\int_{t_0}^{t_1}
\boldsymbol{F}\left(\boldsymbol{u}, \tau; \boldsymbol{\theta} \right)
d\tau
$$

To solve the integral, we can use a wide range of techniques ranging from simple Euler schemes to more complex Runge-Kutta schemes. However, in practice, we typically abstract this concept behind some 

$$
\boldsymbol{\Phi}(\boldsymbol{u};\boldsymbol{\theta}) = 
\text{TimeStepper}\left( \boldsymbol{F},t_0, t_1, \Delta_t, \boldsymbol{u}_0, \boldsymbol{\theta}\right)
$$

Again, this is typically hidden behind some `odesolver` scheme but we could also learn the time stepper via [neural networks](https://arxiv.org/abs/2008.09768) or [generative models](https://arxiv.org/abs/2110.13040).


---
## **Linear Gaussian Approximation**


The simplest scenario we can do is to have a linear and Gaussian approximation to the state.


$$
\begin{aligned}
\text{Initial Distribution}: &&
\boldsymbol{z}_{0} &\sim 
\mathcal{N}(\boldsymbol{\mu}_0;\boldsymbol{\Sigma}_0) \\
\text{Transition Dynamics}: &&
\boldsymbol{z}_{t} &\sim
\mathcal{N}(\boldsymbol{A}(\boldsymbol{z}_{t-1},t;\boldsymbol{\theta}); \boldsymbol{Q}_{t-1}) &&
\boldsymbol{A}(\boldsymbol{z}_{t-1},t;\boldsymbol{\theta}) = 
\mathbf{A}_{t-1}\boldsymbol{z}_{t-1} + \boldsymbol{b}_{t-1}\\
\text{Emission Dynamics}: &&
\boldsymbol{u}_{t} &\sim
\mathcal{N}(\boldsymbol{T}(\boldsymbol{z}_{t},t;\boldsymbol{\theta}); \boldsymbol{R}_{t}) &&
\boldsymbol{T}(\boldsymbol{z}_{t},t;\boldsymbol{\theta}) = 
\mathbf{T}_{t}\boldsymbol{z}_{t} + \boldsymbol{c}_{t}\\
\end{aligned}
$$

Typically when things are linear and Gaussian, inference becomes exact. So the same quantities that we mentioned in the SSM section, we have them here with the Gaussian assumption and the individual parameters that can be calculated in closed form.


$$
\begin{aligned}
\text{Predictions}: &&
p(\boldsymbol{z}_{t}|\boldsymbol{u}_{1:t-\Delta t}; \boldsymbol{\theta}) &\sim 
\mathcal{N}(\boldsymbol{\mu}_t^-, \boldsymbol{\Sigma}_t^-) \\
\text{Filtering}: &&
p(\boldsymbol{z}_{t}|\boldsymbol{u}_{1:t}; \boldsymbol{\theta}) &\sim 
\mathcal{N}(\boldsymbol{\mu}_t, \boldsymbol{\Sigma}_t) \\
\text{Smoothing}: &&
p(\boldsymbol{z}_{t}|\boldsymbol{u}_{1:T}; \boldsymbol{\theta}) &\sim 
\mathcal{N}(\boldsymbol{\xi}_t, \boldsymbol{\Lambda}_t) \\
\text{Data Likelihood}: &&
p(\boldsymbol{u}_{t}|\boldsymbol{u}_{1:t-\Delta t}; \boldsymbol{\theta}) &\sim 
\mathcal{N}(\hat{\boldsymbol{u}}_t, \boldsymbol{S}_t) \\
\end{aligned}
$$


For example, if we assume that they are both Gaussian distributed (even with a non-linear transformation), we can write them as

$$
\begin{aligned}
\text{Prior State}: &&
\mathbf{P}_z(\boldsymbol{z};\boldsymbol{\theta}) &=
\frac{1}{2}
||\boldsymbol{z}_0 - \boldsymbol{\mu}_0||_{\boldsymbol{\Sigma}_0^{-1}}^2 \\
\text{Regularization}: &&
\mathbf{R}(\boldsymbol{z};\boldsymbol{\theta}) &=
\sum_{t=1}^T
||\boldsymbol{z}_t - \boldsymbol{T}(\hat{\boldsymbol{u}}_t, t;\boldsymbol{\theta})||_{\boldsymbol{S}^{-1}}^2
\end{aligned}
$$

where $\hat{\boldsymbol{z}}$ are predictions from the filtering step from the LGSSM model.

**Disclaimer**: We used a Gaussian assumption about the distributions for this example. However, there is no obligation to put a Gaussian assumption if it is incorrect. The nice thing about the Gaussian assumption is that 


**Examples**

Below are examples where we have linear Gaussian state space models where we learned the parameters from data using various forms of inference like exact MLE or expectation propagation.

* Kalman Filter - Paper | Paper | Dynamax (JAX)
* Ensemble Kalman Filter



---
## **Non-Linear Flow Map**

$$
\begin{aligned}
\text{Initial Distribution}: &&
\boldsymbol{z}_{0} &\sim 
\mathcal{N}(\boldsymbol{\mu}_0;\boldsymbol{\Sigma}_0) \\
\text{Transition Dynamics}: &&
\boldsymbol{z}_{t} &\sim
\mathcal{N}(\boldsymbol{A}(\boldsymbol{z}_{t-1},t;\boldsymbol{\theta}); \boldsymbol{Q}_{t-1})\\
\text{Emission Dynamics}: &&
\boldsymbol{u}_{t} &\sim
\mathcal{N}(\boldsymbol{T}(\boldsymbol{z}_{t},t;\boldsymbol{\theta}); \boldsymbol{R}_{t}) \\
\end{aligned}
$$

Although we assume the distribution is Gaussian, the functions are not linear, so exact inference is impossible. So the same quantities that we mentioned in the SSM section, we have them here with the Gaussian assumption and the individual parameters that can be calculated in closed form.


### Approximate Model


$$
\begin{aligned}
\text{Predictions}: &&
p(\boldsymbol{z}_{t}|\boldsymbol{u}_{1:t-\Delta t}; \boldsymbol{\theta}) &\approx 
\mathcal{N}(\boldsymbol{\mu}_t^-, \boldsymbol{\Sigma}_t^-) \\
\text{Filtering}: &&
p(\boldsymbol{z}_{t}|\boldsymbol{u}_{1:t}; \boldsymbol{\theta}) &\approx 
\mathcal{N}(\boldsymbol{\mu}_t, \boldsymbol{\Sigma}_t) \\
\text{Smoothing}: &&
p(\boldsymbol{z}_{t}|\boldsymbol{u}_{1:T}; \boldsymbol{\theta}) &\approx  
\mathcal{N}(\boldsymbol{\xi}_t, \boldsymbol{\Lambda}_t) \\
\text{Data Likelihood}: &&
p(\boldsymbol{u}_{t}|\boldsymbol{u}_{1:t-\Delta t}; \boldsymbol{\theta}) &\approx 
\mathcal{N}(\hat{\boldsymbol{u}}_t, \boldsymbol{S}_t) \\
\end{aligned}
$$

We can *approximate the model* by using things like the Taylor expansion, unscented transformations, or momement matching which will result in closed-form inference. These methods all correspond to the Extended KF, the Unscented KF and the assumed density filter respectively. 


**Examples**:

* MAP Estimation with EM vs SGD - [Jax ipynb](https://github.com/probml/dynamax/blob/main/docs/notebooks/linear_gaussian_ssm/lgssm_learning.ipynb)

---

### Approximate Inference


$$
\begin{aligned}
\text{Predictions}: &&
p(\boldsymbol{z}_{t}|\boldsymbol{u}_{1:t-\Delta t}; \boldsymbol{\theta}) &\neq 
\mathcal{N}(\boldsymbol{\mu}_t^-, \boldsymbol{\Sigma}_t^-) \\
\text{Filtering}: &&
p(\boldsymbol{z}_{t}|\boldsymbol{u}_{1:t}; \boldsymbol{\theta}) &\neq 
\mathcal{N}(\boldsymbol{\mu}_t, \boldsymbol{\Sigma}_t) \\
\text{Smoothing}: &&
p(\boldsymbol{z}_{t}|\boldsymbol{u}_{1:T}; \boldsymbol{\theta}) &\neq  
\mathcal{N}(\boldsymbol{\xi}_t, \boldsymbol{\Lambda}_t) \\
\text{Data Likelihood}: &&
p(\boldsymbol{u}_{t}|\boldsymbol{u}_{1:t-\Delta t}; \boldsymbol{\theta}) &\neq 
\mathcal{N}(\hat{\boldsymbol{u}}_t, \boldsymbol{S}_t) \\
\end{aligned}
$$

Here, we can try to *approximate the posterior* by using techniques like the Laplace approximation, variational inference or sampling schemes like MCMC/HMC. These are connected to many papers that use [Deep Markov Models](https://pyro.ai/examples/dmm.html) or modified Kalman filters with transformations like [Flows](https://proceedings.neurips.cc/paper/2020/hash/1f47cef5e38c952f94c5d61726027439-Abstract.html) or [VAEs](https://arxiv.org/abs/1710.05741). We can also look at some approximate methods like using ensembles or Bayesian ensembles. 

**Examples**:

* Deep Markov Model - [Original Paper](https://arxiv.org/abs/1609.09869) | [Physics Informed](https://arxiv.org/abs/2110.08607) | [Numpyro](https://num.pyro.ai/en/stable/examples/stein_dmm.html) | [Pyro](https://pyro.ai/examples/dmm.html)
* Normalizing Kalman Filter
* VAE Kalman Filter


---
### Functions

This is probably where one can spend a lot of time doing research: which functions do we use for the transition and emission dynamics. For example, we can use some of the staple solutions like convolutional neural networks (CNNs), Fourier Neural Operators (FNOs), or UNets.



---
## Universal Differential Equations

---

### Generative Priors

$$
\begin{aligned}
\boldsymbol{L}(\boldsymbol{u};\boldsymbol{\theta}) &= \\
\boldsymbol{R}(\boldsymbol{u};\boldsymbol{\theta}) &=
\log p(\boldsymbol{u}|\boldsymbol{z};\boldsymbol{\theta})
\end{aligned}
$$

In many cases, we can calculate this prior term exactly.



## Bi-Level Optimization

