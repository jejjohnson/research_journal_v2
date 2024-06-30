---
title: Preliminary Results
subject: Misc. Notes
short_title: Models
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


## System

We assume that there is an underlying process that can explain the temperature extremes 
$$
\begin{aligned}
\text{Measurement}: && &&
y_n &= \boldsymbol{y}(\mathbf{s}_n, t_n), && &&
\boldsymbol{y}: \mathbb{R}^{D_s}\times \mathbb{R}^+ \rightarrow \mathbb{R}
\end{aligned}
$$

where $t_n$ is the time stamp of acquisition and $\mathbf{s}_n$ is the station coordinates. 
More concretely, the input parameters of this unknown function is

$$
\begin{aligned}
\text{Spatial Coordinates}: && &&
\mathbf{s}_n&\in\Omega\subseteq\mathbb{R}^{D_s}  &&
[\text{Degrees}, \text{Degrees}, \text{Meters}]
 \\
\text{Temporal Coordinates}: && &&
t_n&\in\mathcal{T}\subseteq\mathbb{R}^+ &&
[\text{Days}]
\end{aligned}
$$

where $D_s = [\text{Latitude}, \text{Longitude}, \text{Altitude}]$.
We have an alternative representation when we want to stress the dependencies in the spatial domain

$$
\begin{aligned}
\text{Measurement}: && &&
\mathbf{y}_n &= \boldsymbol{y}(\boldsymbol{\Omega}, t_n), && &&
\boldsymbol{y}: \mathbb{R}^{D_\Omega}\times \mathbb{R}^+ \rightarrow \mathbb{R}^{D_\Omega}
\end{aligned}
$$


***
### Covariate

We assume that there is a covariate which is correlated with the increase of extremes.
In this case, we are interested in the Global Mean Surface Temperature (GMST).

$$
\begin{aligned}
\text{Covariate}: && &&
x_n &= x(t_n), && &&
x: \mathbb{R}^+ \rightarrow \mathbb{R}
\end{aligned}
$$


***
## Data

We assume that we have a sequence of data points available.

$$
\begin{aligned}
\mathcal{D} &= \left\{ (t_n, \mathbf{s}_n), x_n, y_n \right\}_{n=1}^N && &&
\mathbf{x} \in \mathbb{R}^{N} &&
\mathbf{y} \in \mathbb{R}^{N} &&
\mathbf{S} \in \mathbb{R}^{N\times D_s} &&
\mathbf{T} \in \mathbb{R}^{N} &&
\end{aligned}
$$

where $N=N_s\times N_\Omega$ are the total number of spatial and temporal coordinates available.

For convenience, throughout this paper, we will often stack each of these into vectors or matrices.
In addition, we might use a different notation to denote the dependencies between the spatial points


$$
\begin{aligned}
\mathcal{D} &= \left\{ (t_n, \mathbf{S}_n), x_n, \mathbf{y}_n \right\}_{n=1}^N && &&
\mathbf{y}_n \in \mathbb{R}^{D_\Omega} && &&
\mathbf{Y} \in \mathbb{R}^{D_\Omega \times N} &&
\mathbf{S}_\Omega \in \mathbb{R}^{N\times D_\Omega \times D_s} 
\end{aligned}
$$


***
## Joint Distribution

We also assume that there is a joint distribution of a set of parameters, $\boldsymbol{\theta}$, combined with the observation, $\mathbf{y}$.
However, we decompose the joint distribution into a likelihood and prior.
Basically, the observations can be explained some prior parameters.

$$
p(\mathbf{y},\mathbf{z},\boldsymbol{\theta}) = p(\mathbf{y}|\mathbf{z})p(\mathbf{z}|\boldsymbol{\theta})p(\boldsymbol{\theta})
$$

The likelihood term is an arbitrary distribution and the prior term are the prior parameters for the likelihood distribution.

$$
\begin{aligned}
\text{Data Likelihood}: && &&
y &\sim p(\mathbf{y}|\mathbf{z}) \\
\text{Process Parameters}: && &&
\mathbf{z} &\sim p(\mathbf{z}|\boldsymbol{\theta}) \\
\text{Prior Parameters}: && &&
\boldsymbol{\theta} &\sim p(\boldsymbol{\theta}) \\
\end{aligned}
$$ 

where $\boldsymbol{\theta} = \left\{\mu,\sigma,\kappa\right\}$.
The full term for posterior  is given by

$$
p(\boldsymbol{\theta}|\mathbf{y}) = 
\frac{1}{Z}p(\mathbf{y}|\boldsymbol{\theta})
p(\boldsymbol{\theta})
$$

where $Z$ is a normalizing constant. 
The problem term is the normalizing constant because it is an integral wrt to all of the parameters

$$
Z=\int p(\mathbf{y}|\boldsymbol{\theta})p(\boldsymbol{\theta})p\boldsymbol{\theta}
$$

This is intractable because there is no closed form given the non-linearities in the GEVD PDF as seen in [](eq:gevd_pdf) and [](eq:gevd_pdf_function).

***
## Data Likelihood

We are interested in extreme values so it is natural that we use some of the distributions that are readily available for extreme values.

***
### GEVD

The first option is the generalized extreme value distribution (GEVD).
The cumulative denisty function (CDF) of the GEVD is given by

$$
\boldsymbol{F}(y;\boldsymbol{\theta}) = 
\exp
\left[ -\boldsymbol{t}(y;\boldsymbol{\theta}) \right]
$$ (eq:gevd-cdf)

where the function $t(y;\boldsymbol{\theta})$ is defined as

$$
\boldsymbol{t}(y;\boldsymbol{\theta}) = 
\begin{cases}
\left[ 1 + \kappa \left( \frac{y-\mu}{\sigma} \right)\right]_+^{-1/\kappa}, && \kappa\neq 0 \\
\exp\left(-\frac{y-\mu}{\sigma}\right), && \kappa=0
\end{cases}
$$ (eq:gevd-internal-function)

***
#### Parameters

For this distribution, we have the following free parameters

$$
\boldsymbol{\theta}_\text{GEVD} =
\left\{ \mu, \sigma, \kappa\right\}
$$ (eq:gevd-params)

***
#### Log Probability

If we have a set of observations, we can maximize the log probability of the observations.
We can define the probability density function

$$
p_\text{GEVD}(y;\boldsymbol{\theta}) = 
\frac{1}{\sigma}t\left(y;\boldsymbol{\theta}\right)^{\kappa+1}e^{-t\left(y;\boldsymbol{\theta}\right)}
$$ (eq:gevd-pdf)

where $t(y;\boldsymbol{\theta})$ is defined in [](eq:gevd-internal-function).
Subsequently, we can take the log-probability to get a loss function.

$$
\log p(\boldsymbol{y}_{1:N}|\boldsymbol{\theta}) =
- N_b \log \sigma -
(1+1/\kappa)\sum_{n=1}^{N_b} 
\log \left[ 1 + \kappa z_n\right]_+
- 
\sum_{n=1}^{N_b}
\left[ 1 + \kappa z_n\right]_+^{-1/\kappa}
$$ (eq:gevd-nll)

where where $z_n=(y_n - \mu)/\sigma$ and $[1 + \kappa z_n]_+ = \text{max}(1 + \kappa z_n,0)$ and $N_{b}$ are the number of blocks.

***
### GPD

Another option is the generalized Pareto distribution.
This is a peak-over-threshold (POT) method which is the number of events conditioned on the fact that we are above a given threshold, $y_0$.

$$
p(Y\leq y|y\geq y_0) := F(y;\boldsymbol{\theta})
$$



We can define the CDF as:

$$
\boldsymbol{F}(y;\boldsymbol{\theta}) = 
\begin{cases}
1 - \left[ 1 + \kappa^* \left( \frac{y-y_0}{\sigma^*} \right)\right]^{-1/\kappa^*}
, && \kappa^*\neq 0 \\
1 - \exp\left(-\frac{y-y_0}{\sigma^*}\right), && \kappa^*=0
\end{cases}
$$ (eq:gpd-cdf)


***
#### Parameters

The free parameters available for this distribution are

$$
\boldsymbol{\theta}_\text{GPD} =
\left\{ y_0, \sigma^*, \kappa^* \right\}
$$ (eq:gpd-params)

The threshold parameter, $y_0$, needs to be decided before trying to fit the other two parameters.
If there are no strong concerns about what is a threshold, we typically choose a reasonable quantile range, e.g., $\geq$95%.
The remaining free parameters can be directly related to the GEVD parameters in equation [](eq:gevd-params) like so

$$
\begin{aligned}
\sigma^* &= \sigma + \kappa (y_0 - \mu) \\
\kappa^* &= \kappa
\end{aligned}
$$


***
#### Log Probability

If we have a set of observations, we can maximize the log probability of the observations.
We can define the probability density function for the GPD as

$$
\begin{aligned}
p_\text{GPD}(y;\boldsymbol{\theta}) = 
\frac{1}{\sigma^*}\left[ 1 + \kappa^* \left( \frac{y-y_0}{\sigma^*} \right)\right]^{-\frac{1}{\kappa^*} - 1}_+
\end{aligned}
$$ (eq:gpd-pdf)

where $a_+=\text{max}(a,0)$ and $t(y;\boldsymbol{\theta})$ is defined in [](eq:gevd-internal-function).
Subsequently, taking the log will result in


$$
\log p_\text{GPD}(\boldsymbol{y}_{1:N_{y_0}}|\boldsymbol{\theta}) =
- N_{y_0} \log \sigma^* -
(1+1/\kappa^*)\sum_{n=1}^N 
\log \left[ 1 + \kappa^* z_n\right]_+
$$ (eq:gpd-nll)

where where $z_n=(y_n - y_0)/\sigma$ and $[1 + \kappa^* z_n]_+ = \text{max}(1 + \kappa^* z_n,0)$ and $N_{y_0}$ are the number of exceedences above the threshold, $y_0$.

***
### Rate

The rate parameter is defined as the expected number of events per event period, $T$.
$$
\begin{aligned}
\lambda_{y_0} &= 
\left[ 1 + \kappa z \right]^{- \frac{1}{\kappa}}, && &&
z = (y_0 - \mu)/\sigma
\end{aligned}
$$ (eq:gpd-param-rate)

This parameterization is useful for both the GEVD and the GPD.

***
### Return Period

For the GEVD, we have the return period defined as:

$$
y =
\begin{cases}
\mu + \frac{\sigma}{\kappa}\left\{\left[\log\left(1-1/T_R\right)\right]^{\kappa}-1\right\} && \kappa\neq 0 \\
\mu - \sigma \log \left[ - \log \left(1 - 1/T_R \right) \right] && \kappa=0
\end{cases}
$$ (eq:gevd-return)

For the GPD, we have the return period defined as:

$$
y =
\begin{cases}
y_0 + \frac{\sigma}{\kappa} \left[ (\lambda_{y_0} T_R)^{\kappa} - 1 \right], && 
\kappa \neq 0 \\
y_0 + \sigma \log (\lambda_{y_0} T_R), && 
\kappa = 0
\end{cases}
$$ (eq:gpd-return)


***
## Process Parameterization

Concretely, we 

$$
\begin{aligned}
\text{Latent Variable}: && &&
\boldsymbol{\theta} :=
\mathbf{z} &=
\begin{bmatrix}
\boldsymbol{z}_{\boldsymbol{\mu}} \\
\boldsymbol{z}_{\boldsymbol{\sigma}} \\
\boldsymbol{z}_{\boldsymbol{\kappa}}
\end{bmatrix}
&& &&
\mathbf{z} \in \mathbb{R}^{D_\Omega}
\end{aligned}
$$

We define functions for each of these latent variables (which are input parameters for the respective methods).

$$
\begin{aligned}
\text{Location Parameter}: && &&
\boldsymbol{z}_{\boldsymbol{\mu}} &\approx 
\boldsymbol{z}_{\boldsymbol{\mu}}(\mathbf{s},x;\boldsymbol{\theta}) , && &&
\boldsymbol{z}_{\boldsymbol{\mu}}: \mathbb{R}^+\times\mathbb{R}^{D_x}\times\Theta
\rightarrow
\mathbb{R}^{D_\Omega} \\
\text{Scale Parameter}: && &&
\boldsymbol{z}_{\boldsymbol{\sigma}} &\approx 
\boldsymbol{z}_{\boldsymbol{\sigma}}(\mathbf{s},x;\boldsymbol{\theta}) , && &&
\boldsymbol{z}_{\boldsymbol{\sigma}}: \mathbb{R}^+\times\mathbb{R}^{D_x}\times\Theta
\rightarrow
\mathbb{R}^{D_\Omega} \\
\text{Shape Parameter}: && &&
\boldsymbol{z}_{\boldsymbol{\kappa}} &\approx 
\boldsymbol{z}_{\boldsymbol{\kappa}}(\mathbf{s},x;\boldsymbol{\theta}) , && &&
\boldsymbol{z}_{\boldsymbol{\kappa}}: \mathbb{R}^+\times\mathbb{R}^{D_x}\times\Theta
\rightarrow
\mathbb{R}^{D_\Omega}
\end{aligned}
$$



The hypothesis is that the location parameter for the extremes distribution will be correlated with the GMST covariate.
We also conjecture that the location parameter for each of the stations is highly correlated.
However, we do not postulate that the scale and shape parameters.


***
### Latent Parameter

$$
\begin{aligned}
\text{Latent Variable}: && &&
\mathbf{z}(t,\boldsymbol{\theta})
&=
\mathbf{z}_0 
+
\mathbf{z}_1\psi(t;\boldsymbol{\theta})
+
\mathbf{z}_1\psi(t;\boldsymbol{\theta})
+
\epsilon
\end{aligned}
$$


***
#### Location Parameters

We have a range of use cases for the location parameter.

$$
\begin{aligned}
\text{Location}: && &&
\mathbf{z}_{\boldsymbol{\mu}} 
&= 
\boldsymbol{\mu}_0 
+ 
\mu_1 \phi(t;\boldsymbol{\theta}) 
+ 
\mu_2 \phi(\mathbf{s};\boldsymbol{\theta}) 
+
\epsilon \\
\end{aligned}
$$

where $\mathbf{z}_{\boldsymbol{\mu}}\in\mathbb{R}^{D_\Omega}$

***
#### Scale & Shape Parameters

For the scale and shape parameters, we impose only constraint on each form.
We allow for the scale and shape parameter to be different for each station.

$$
\begin{aligned}
\text{Scale}: && &&
\log \mathbf{z}_{\boldsymbol{\sigma}} &= \boldsymbol{\sigma}_0
&& && \boldsymbol{\sigma}_0 \in \mathbb{R}^{D_\Omega} \\
\text{Shape}: && &&
\mathbf{z}_{\boldsymbol{\kappa}} &= \boldsymbol{\kappa}_0, 
&& && \kappa_0 \in \mathbb{R}^{D_\Omega} \\
\end{aligned}
$$

We use the $\log$ transformation to ensure that everything is positive.


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
\text{TimeStepper}: && &&
\mathbf{z}_t = \mathbf{z}_0 + \int_0^t \boldsymbol{f}(\mathbf{z}_0, \tau, \theta)d\tau
\end{aligned}
$$

Conventionally, we use ODE solvers like Euler, Heun, or Runge-Kutta.

$$
\begin{aligned}
\text{ODESolver}: && &&
\mathbf{z}_t = \text{ODESolve}(\boldsymbol{f}, \mathbf{z}_0, t, \theta)
\end{aligned}
$$

***
#### Non-Dimensionalization

We will reparameterize this ODE to remove some dependencies on time.
The above equation is divided by 

$$
\frac{dy}{dt}\frac{dt}{dx} 
= f(y,x,\theta)
$$

***
#### Parameterization

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


