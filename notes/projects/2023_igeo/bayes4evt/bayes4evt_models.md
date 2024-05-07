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
y_n = \boldsymbol{f}(\mathbf{s}_n, t_n), && &&
y = \boldsymbol{y}: \mathbb{R}^{D_s}\times \mathbb{R}^+ \rightarrow \mathbb{R}
\end{aligned}
$$

where $t_n$ is the time stamp of acquisition and $\mathbf{s}_n$ is the station coordinates in latitude, longitude and height above sea level.


***
## Data

We assume that we have a sequence of data points available.

$$
\begin{aligned}
\mathcal{D} &= \left\{ (t_n, \mathbf{s}_n), y_n \right\}_{n=1}^N && &&
y_n \in \mathbb{R} && &&
\mathbf{y} = [y_1, y_2, \ldots, y_N]
\end{aligned}
$$


***
## Model



We also assume that there is a joint distribution of a set of parameters, $\boldsymbol{\theta}$, combined with the observation, $\mathbf{y}$.
However, we decompose the joint distribution into a likelihood and prior.
Basically, the observations can be explained some prior parameters.

$$
p(\mathbf{y},\boldsymbol{\theta}) = p(\mathbf{y}|\boldsymbol{\theta})p(\boldsymbol{\theta})
$$

The likelihood term is an arbitrary distribution and the prior term are the prior parameters for the likelihood distribution.

$$
\begin{aligned}
\text{Data Likelihood}: && &&
y &\sim p(\boldsymbol{\theta}) \\
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

We are interested in extreme values.

### GEVD (TODO)

The first option is the generalized extreme value distribution (GEVD)

### GPD (TODO)

Another option is the generalized Pareto distribution.

### Point Process (TODO)

The final option is the Point process (PP).

***
## Posterior


