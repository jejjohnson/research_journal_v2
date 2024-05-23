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
## Processes

###


***
## Likelihood Model



### Joint Distribution

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
### Process Parameters

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
\boldsymbol{z}_{\boldsymbol{\mu}}: \mathbb{R}^{D_s}\times\mathbb{R}^+\times\mathbb{R}^{D_x}\times\Theta
\rightarrow
\mathbb{R} \\
\text{Scale Parameter}: && &&
\boldsymbol{z}_{\boldsymbol{\sigma}} &\approx 
\boldsymbol{z}_{\boldsymbol{\sigma}}(\mathbf{s},x;\boldsymbol{\theta}) , && &&
\boldsymbol{z}_{\boldsymbol{\sigma}}: \mathbb{R}^{D_s}\times\mathbb{R}^+\times\mathbb{R}^{D_x}\times\Theta
\rightarrow
\mathbb{R} \\
\text{Shape Parameter}: && &&
\boldsymbol{z}_{\boldsymbol{\kappa}} &\approx 
\boldsymbol{z}_{\boldsymbol{\kappa}}(\mathbf{s},x;\boldsymbol{\theta}) , && &&
\boldsymbol{z}_{\boldsymbol{\kappa}}: \mathbb{R}^{D_s}\times\mathbb{R}^+\times\mathbb{R}^{D_x}\times\Theta
\rightarrow
\mathbb{R}
\end{aligned}
$$



The hypothesis is that the location parameter for the extremes distribution will be correlated with the GMST covariate.
We also conjecture that the location parameter for each of the stations is highly correlated.
However, we do not postulate that the scale and shape parameters.



***
#### Location Parameters

We have a range of use cases for the location parameter.



Case 1 is a constant value which will represent the 

$$
\begin{aligned}
\text{Constant}: && &&
\boldsymbol{z}_{\boldsymbol{\mu}} &= \boldsymbol{\mu}_0 + \epsilon \\
\text{Covariate}: && &&
\boldsymbol{z}_{\boldsymbol{\mu}} &= 
\boldsymbol{\mu}_0 + \boldsymbol{\mu}_1\phi(x;\boldsymbol{\theta}) + \epsilon\\
\text{Spatial}: && &&
\boldsymbol{z}_{\boldsymbol{\mu}} &= 
\boldsymbol{\mu}_0 + \boldsymbol{f}(\mathbf{s};\boldsymbol{\theta}) + \epsilon\\
\text{Spatial + Covariate}: && &&
\boldsymbol{z}_{\boldsymbol{\mu}} &= 
\boldsymbol{\mu}_0 + \boldsymbol{f}(\mathbf{s};\boldsymbol{\theta}) + \boldsymbol{\mu}_1\phi(x;\boldsymbol{\theta}) + \epsilon \\
\end{aligned}
$$

***
#### Scale & Shape Parameters

For the scale and shape parameters, we impose only constraint on each form.
We allow for the scale parameter to be different for each station.
We also allow for the shape parameter to be different for each station **only** when we our model incorporates on an individual station.
When we train on all of the stations together

$$
\begin{aligned}
\text{Scale}: && &&
\log \mathbf{z}_{\boldsymbol{\sigma}} &= \boldsymbol{\sigma}_0
&& && \boldsymbol{\sigma}_0 \in \mathbb{R}^{D_\Omega} \\
\text{Shape}: && &&
\log \mathbf{z}_{\boldsymbol{\kappa}} &= \boldsymbol{\kappa}_0, 
&& && \kappa \in \mathbb{R} \\
\end{aligned}
$$



***
## Data Likelihood

We are interested in extreme values.

### GEVD (TODO)

The first option is the generalized extreme value distribution (GEVD)

### GPD (TODO)

Another option is the generalized Pareto distribution.

### Point Process (TODO)

The final option is the Point process (PP).

***
## Posterior


