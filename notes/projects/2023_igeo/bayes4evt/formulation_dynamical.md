---
title: Dynamical System
subject: Misc. Notes
short_title: Experiment 2a - Spain
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

# Dynamical Systems Formulation

Firstly, we have some weather stations

$$
\begin{aligned}
\text{Spatial Coordinates}: && &&
\mathbf{s}&\in\Omega\subseteq\mathbb{R}^{D_s}
\end{aligned}
$$

In our case, the vector, $\mathbf{s}$, gives us the longitude, latitude, and altitude of the weather station.
In addition, we have some measurements across time.

$$
\begin{aligned}
\text{Temporal Coordinates}: && &&
t &\in \mathcal{T} \subseteq \mathbb{R}^+
\end{aligned}
$$

There are two time domains that we have access to.
For the global mean surface temperature (GMST), we have a time series that is available from 1800 till present day (2020).
For the daily maximum temperature measurements, we have a time series that is available from 1960 till present day (2020).

First, we have our measurements which are maximum temperature values.

$$
\begin{aligned}
\text{Measurements}: && &&
y &= y(t,\mathbb{s}) && &&
y:\mathbb{R}^+\rightarrow\mathbb{R} 
&& &&
t \in \mathcal{T}_y\subseteq \mathbb{R}^+ &&
\mathbf{s}\in\Omega\subseteq\mathbb{R}^{D_s}
\end{aligned}
$$

Next, we have our GMST measurements which is the temperature anomaly (in degrees Celsius) over our time domain.
This is a single time series so there is no dependency on spatial coordinates.

$$
\begin{aligned}
\text{Covariate}: && &&
x &= x(t) && &&
x:\mathbb{R}^+\rightarrow\mathbb{R} 
&& &&
x \in \mathcal{T}_x\subseteq \mathbb{R}^+
\end{aligned}
$$

***
### ODE Formulation

The DMT is formulated as an ordinary differential equation (ODE).
First, we will define it as a system of ODEs whereby we have a state variable

$$
\begin{aligned}
\text{State}: && && 
\mathbf{z} &=
\begin{bmatrix}
x \\ y
\end{bmatrix}, && &&
\mathbf{z}\in\mathbb{R}^2
\end{aligned}
$$

Now, we can define an equation of motion which describes the temporal dynamics of the system.

$$
\begin{aligned}
\text{Equation of Motion}: && &&
\frac{d\mathbf{z}}{dt} &= \boldsymbol{f}(\mathbf{z},t,\theta), 
&& &&
\boldsymbol{f}:\mathbb{R}^2 \times \mathbb{R}^+ \times \Theta \rightarrow \mathbb{R}
\end{aligned}
$$

We also have initial measurements of the system

$$
\begin{aligned}
\text{Initial Values}: && &&
\mathbf{z}(0) &= 
\begin{bmatrix}
x(0) \\ y(0)
\end{bmatrix} 
:=
\mathbf{z}_0
\end{aligned}
$$

From the fundamental theory of calculus, we know that the solution of said ODE is a temporal integration wrt time

$$
\begin{aligned}
\mathbf{z}_t = \mathbf{z}_0 + \int_0^t \boldsymbol{f}(\mathbf{z}_0, t, \theta)dt
\end{aligned}
$$

Conventionally, we use ODE solvers like Euler, Heun, or Runge-Kutta.

$$
\mathbf{z}_t = \text{ODESolve}(\boldsymbol{f}, \mathbf{z}_0, t, \theta)
$$

***
#### Non-Dimensionalization

We will reparameterize this ODE to remove some dependencies on time.
The above equation is divided by 

$$
\frac{dy}{dt}\times \frac{dt}{dx} 
= \frac{dy}{dx} 
= \frac{f(y,t,\theta)}{g(x,t,\theta)}
:= h(y,x,\theta)
$$

***
### Parameterization

There are many special forms of ODEs which are known from the literature.

$$
\begin{aligned}
\text{1st Order ODE}: && &&
\boldsymbol{f}(y,x,\theta) &=
\boldsymbol{f}_1(x) - \boldsymbol{f}_2(x)\cdot y
\end{aligned}
$$

An example form would the following:

$$
\boldsymbol{f}(y,x,\theta) =
a_0 + a_1 x + a_2 y
$$

**Constant Form**.
The first form assumes that we have a constant change in DMT wrt the GMST

$$
\begin{aligned}
\text{Constant EOM}: && &&
\boldsymbol{f}(y,x,\theta)
&= 
a_0 \\
\text{Linear Solution}: && &&
y(x) &=
y_0 + a_0 t
\end{aligned}
$$

**Linear Form**.
The first form assumes that we have a constant change in DMT wrt the GMST

$$
\begin{aligned}
\text{Linear EOM}: && &&
\boldsymbol{f}(y,x,\theta)
&= 
a_0 + a_1 t\\
\text{Quadratic Solution}: && &&
y(x) &=
y_0 + a_0 t + \frac{1}{2}a_1t^2
\end{aligned}
$$

**Multiplicative Form**.
The first form assumes that we have a constant change in DMT wrt the GMST

$$
\begin{aligned}
\text{Linear EOM}: && &&
\boldsymbol{f}(y,x,\theta)
&= 
a_2 y\\
\text{Exponential Solution}: && &&
y(x) &=
y_0 \exp \left( a_2t \right)
\end{aligned}
$$