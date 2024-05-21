---
title: EVT Parameterizations
subject: Machine Learning for Earth Observations
short_title: EVT Parameterizations
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

(sec:evt-param-temporal)=
## Temporal Dependencies


> In this section, we outline some of the ways we can construct parametric functions which have parameters with temporal dependencies.

$$
\theta(t) = \theta_0 + \theta_1\phi(t) + \epsilon_\theta
$$

where $\psi(t)$ is some function which encodes time, e.g., linear, log-linear, Fourier, etc.

***
### Encoding Time

$$
\phi = \phi(t) 
\hspace{10mm}
\phi: \mathbb{R}^+\rightarrow\mathbb{R}^{D_t}
$$

The most general form would be Fourier series

$$
\phi(t) = \sum_{k=1}^K
a_k \sin\left(\frac{2\pi k t}{P}\right)
+ b_k \cos\left(\frac{2\pi k t}{P}\right)
$$

where $t$ is time, $P$ is the base period of the feature, $n$ is the index of the series.
We could go more difficult by adding an envelope


$$
\phi(t) = \sum_{k=1}^K
a_k \tilde{F}_n(t)\sin\left(\frac{2\pi k t}{P}\right)
+ b_k \tilde{F}_n\cos\left(\frac{2\pi k t}{P}\right)
$$

***
### Constant

We can use maximum likelihood to estimate the unknown parameters of the parametric distributions.

$$
L(\boldsymbol{\theta}) = 
\prod_{n=1}^{N_T} f(y_n) \prod_{n=1}^{N_T}S(y_n)
$$

We can rewrite this as a

$$
\log L(\boldsymbol{\theta}) = 
\sum_{n=1}^{N_T} \log f(y_n) -
\sum_{n=1}^{N_T}F(y_n)
$$

where $f$ is the PDF of some density function and $F$ is the CDF of some density function.

***
### Parametric


$$
\lambda^*(t,\mathbf{s}) = \boldsymbol{\mu}(t,\mathbf{s}) + \boldsymbol{g}(t,\mathbf{s})
$$

Typically, we can use some kernel function

$$
f(t|\boldsymbol{\theta}) = 
\sum_{n=1}^{N_s}
\mathbf{w}_n
\boldsymbol{k}(t,\boldsymbol{\theta}_n)
$$

where $\boldsymbol{k}$ is a kernel function (density function) with parameters $\boldsymbol{\theta}_n$.
The $\mathbf{w}_n$ are weights corresponding to the densities $\boldsymbol{k}(t,\boldsymbol{\theta}_n)$ and $\sum_{n=1}^{N_s}\mathbf{w}_n=1$.


***
### Kernel

A Hawkes Process is a process that has a background rate and a self-exciting term.
This term encourages more events to happen given past events.

$$
\boldsymbol{g}(t,\mathbf{s}) = g_t(t)\boldsymbol{g}_s(\mathbf{s})
$$

For this paper, they used a separable, parametric kernel function, i.e., a Hawkes kernel 
In particular, they used a Gaussian kernel in space and exponential in time.

$$
\boldsymbol{g}(t,\mathbf{s}) = 
\alpha\beta\exp(-\beta t)
\frac{1}{\sqrt{2\pi|\mathbf{\Sigma}|}}
\exp(-\mathbf{s}^\top\mathbf{\Sigma}^{-1}\mathbf{s})
$$

where $\alpha,\beta>0$ and $\mathbf{\Sigma}$ as a PSD matrix.


***
### Doubly Stochastic


This is also known as a Log-Gaussian Cox process.

$$
\log \boldsymbol{\mu}(t,\mathbf{s}) = 
\boldsymbol{f}_t(t) + 
\boldsymbol{f}_s(\mathbf{s})
$$

where $f$ is a realization from a Gaussian process

$$
\boldsymbol{f} \sim \mathcal{GP}(\boldsymbol{m_\theta},\boldsymbol{k_\theta})
$$

If we assume that our hazard function is a constant function

$$
h(t) = \lambda
$$

This implies that our survival function is

$$
S(t) = \exp(-\lambda t)
$$





***
## Approximating Integrals

Let's say we are given some pixel locations

$$
\mathcal{H} = \left\{\mathbf{s}_n \right\}_{n=1}^N
$$

***
### Monte Carlo 

$$
\int f(t) \approx
\sum_{n=1}^N \Delta t_n
\left[ 
  \frac{1}{K}\sum_{k=1}^K
  f(t_n + \Delta_{t_n}z_k)
\right]
\hspace{10mm}
z_k \sim U[0,1]
$$


***
### ODE Time Steppers

We can write our an equation of motion (EoM) describing the state transitions.

$$
\begin{aligned}
\partial_t \lambda &= \boldsymbol{f_\theta}(\lambda, t)
&& && &&
\boldsymbol{f}: \mathbb{R}^{D_\lambda}\times\mathbb{R}^+
\rightarrow
\mathbb{R}^{D_\lambda}
\end{aligned}
$$

Now, we can integrate this in time which is given by the fundamental theorem of calculus.

$$
\lambda(t) = \lambda_0 + \int_0^t\boldsymbol{f_\theta}(\lambda_0, \tau)d\tau
$$

In practice, we know that we have to do some numerical approximations, e.g., Euler (Taylor Expansion) or RK4 (Quadrature).
This leaves us with a time stepper function

$$
\lambda_{t_1} := \boldsymbol{\phi}_t(\boldsymbol{\lambda}) = \lambda_{t_0} + \int_{t_0}^{t_1}\boldsymbol{f_\theta}(\lambda_{t_0}, \tau)d\tau
$$
which we can apply in an autoregressive fashion
$$
\boldsymbol{\lambda}_T = 
\boldsymbol{\phi}_{t_T} \circ \boldsymbol{\phi}_{t_{T-1}} \circ
\ldots 
\circ
\boldsymbol{\phi}_{t_1}
\circ
\boldsymbol{\phi}_{t_0}(\boldsymbol{\lambda}_0)
$$
This is more commonly represented where we add a vector of time points we wish to receive from the ODESOlver, $\mathbf{t}=[t_0, t_1, \ldots, T]$ and pass this through the ODESolver

$$
\boldsymbol{\lambda} = \text{ODESolver}
\left(\boldsymbol{f},\lambda_0, \mathbf{t},\boldsymbol{\theta}\right)
$$

where $\boldsymbol{\lambda}=[\lambda_0, \lambda_1, \ldots, \lambda_T]$.
This is a nice abstraction which allows the user to choose any arbitrary solver like the Euler, Heun or Runge-Kutta.


***
### Quadrature

$$
\int_{\Omega}\boldsymbol{\lambda}(\mathbf{s})d\mathbf{s} \approx 
\sum_{n=1}^{N_s}\mathbf{w}_n\boldsymbol{\lambda}(\mathbf{s}_n)
$$

where $w_n>0$ and $\sum_{n=1}^Nw=|\Omega|$ and $\mathbf{s}_n=1,2,\ldots,N_s$ are all of the points in the domain, $\mathcal{\Omega}$.
This yields an approximation to the log likelihood as

$$
\log p(\mathcal{\Omega}) \approx
\sum_{n=1}^N\log \boldsymbol{\lambda}(\mathbf{s}_n)
-\sum_{n=1}^{N_s}\mathbf{w}_n\boldsymbol{\lambda}(\mathbf{s}_n)
$$

We have 3 sets of points:
* $N_s$ - the points within the discretized domain
* $N(\mathbf{s}_n)$ - the points within the discretized domain where we have events.
* $\bar{N}_s = N(\mathbf{s}_n)-N_s$ - the points in the discretized domain where there are no events.

{cite:t}`https://doi.org/10.2307/2347614` used the names design points, data points, and dummy points, respectively.

Let's create a mask vector which represents the case whether or not we observe an event within an element.

$$
\mathbf{m}_n =
\begin{cases}
1, && && N(\mathbf{s}_n) \geq 0 \\
0, && && N(\mathbf{s}_n) = 0
\end{cases}
$$

Now, we can rewrite the log-likelihood term to be

$$
\log p(\mathcal{\Omega}) \approx
\sum_{n=1}^{N_s}
\mathbf{w}_n
\left(
    \frac{\mathbf{m}_n}{\mathbf{w}_n}
    \log\boldsymbol{\lambda}(\mathbf{s}_n) -
    \boldsymbol{\lambda}(\mathbf{s}_n)
\right)
$$


***
### Pixel Counts

We can divide the domain, $\mathcal{\Omega}$, into small pixels of each area, $\omega$.
Then the integral over the domain, $\mathcal{\Omega}$, is approximated by summing over all of the pixels.

$$
\int_{\Omega}\lambda(\mathbf{s})d\mathbf{s} \approx 
\sum_{n=1}^{N_s}\omega_n\lambda(\mathbf{s}_n)
$$

where $s_n$ is the center of the $n$th pixel.
In this case, we discard the exact locations of the data points and we mark each data point with the center pixel.
To approximate the sum over data points, we can take the sum over pixels.

$$
\sum_n^N\log\lambda(\mathbf{s}_n) \approx 
\sum_{n=1}N(\mathbf{s}_n)\log \lambda(\mathbf{s}_n)
$$

where $N(s_n)$ is the number of data points falling into the $n$th pixel.
So we can take these two quantities and put them together to get

$$
\log p(\mathcal{\Omega}) \approx
\sum_{n=1}^N
\left(
    N(\mathbf{s}_n)\log \lambda(\mathbf{s}_n) 
    -
    \omega_n\lambda(\mathbf{s}_n)
\right)
$$

***
## Masks


We can make this a bit neater by introducing a masking variable, $\boldsymbol{m}$.
This variable acts as an indicator variable

$$
m_n = 
\begin{cases}
1, && y > y_0 \\
0, && y \leq y_0
\end{cases}
$$

Now, we can use this indicator variable to mask the likelihood function to zero if the observed value at the temporal resolution is above or below the threshold, $y_0$.

$$
\begin{aligned}
\log p(y_n|\boldsymbol{\theta}) &= 
\sum_{n=1}^{N(A)}m_n\log \boldsymbol{f}_{GEVD}(y_n;\boldsymbol{\theta}) \\
&- T_{years}\mathbf{S}_{GEVD}(y_0;\boldsymbol{\theta}) \\
&+\log \sum_{n=1}^{N(A)}\boldsymbol{f}_{GPD}(y_n;\boldsymbol{\theta}) 
\end{aligned}
$$


***
### Demo Code

For the spatiotemporal case:

```python
# initialize the event times
T: Array["T"] = ...
# initialize the spatial events points
S: Array["T S"] = ...
# initialize the marks at the events in space and time
Y: Array["T S Dy"] = ..
# initialize mask at marks
M: Array["T S Dy"] = ...
```