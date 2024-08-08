---
title: Hierarchical Sequence of Decisions
subject: ML4EO
# subtitle: How can I estimate the state AND the parameters?
short_title: Decisions
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


* Conserivation Laws
* Discretization
* Process Parameterization
* Uncertainty
* Solution Procedure

***
## Rubric

***
### Conservation Laws

aka. System Diagram, PGM.

> What knowledge should I encode and what knowledge should I ignore?

This includes things like:
* Physics -> conservation laws, law of thermodynamics
* Physical Processes
* System Geometry -> Boundaries
* Material Properties

This will *restrict* the possible trajectories of $x,y,z$.

**Example I**:

$$
\partial_t z = x - y
$$

**Example II**: Constraints

$$
\left\{z_t, x_t, y_t \right\} \geq 0
$$

On a more practical level, we could call this **process identification**.

***
### System Discretization

aka system architecture, discretization

> What is a sufficiently complex, finite dimensional, spatially organized representation of the sub-system architecture?

First, we need to decide which discretization we need.
We could have a continuous system if we can express our equations through some sort of symbolic representation.
Subsequently, we could use some sort of auto-differentiation framework to try and test it out using PDEs and such.
This sort of approach lends itself well to function approximations.

$$
\begin{aligned}
\mathbf{u} &= \boldsymbol{u}(\mathbf{s}) 
&& &&
\mathbf{s}\in\boldsymbol{\Omega}\subseteq\mathbb{R}^{D_s}
&& &&
\mathbf{u}\in\mathbb{R}^{D_u}
\end{aligned}
$$

We could also use a discrete representation, which is more likely in many modeling situations.

$$
\begin{aligned}
\mathbf{u} &= \boldsymbol{u}(\boldsymbol{\Omega}) 
&& &&
\boldsymbol{\Omega}\subseteq\mathbb{R}^{D_s}
&& &&
\mathbf{u}\in\mathbb{R}^{D_u\times D_\Omega}
\end{aligned}
$$

In this case, we need to decide how we will handle the shape of the domain.
We could use an irregular domain.
This approach lends itself well with more traditional state-space and dynamical systems representations.

**Examples:**
* Scale
* Dimension
* 3D Structure of State-Space elements

This further restricts the trajectories.
This also determines the spatial variability!


```{figure} https://www.science.org/cms/10.1126/sciadv.abn3488/asset/8f8eb61b-8789-44f5-9315-cd0c6f02bbbd/assets/images/large/sciadv.abn3488-f1.jpg
:label: myFigure
:alt: Sunset at the beach
:align: center

Schematic representation of space and time scales of atmospheric phenomena from aerosols and cloud drops/crystals at the “microscale” to clouds, tornadoes, and thunderstorms at the “mesoscale” up to tropical cyclones (hurricanes), and extratropical cyclones at the “synoptic scale” up to the general circulation and global climate scale. Types of models and their approximate ranges are colored. The “resolved” scale of a model is typically three to five times the spatial scale, so the effective spatial scale should be shifted to the right. DNS, direct numerical simulation. Source: [Paper (Science)](https://www.science.org/doi/10.1126/sciadv.abn3488)
```

[For example](https://www.science.org/cms/10.1126/sciadv.abn3488/asset/8f8eb61b-8789-44f5-9315-cd0c6f02bbbd/assets/images/large/sciadv.abn3488-f1.jpg)




```{figure} https://www.worldclimateservice.com/wp-content/uploads/2020/08/longrangeforecasts_timescale.png
:label: myFigure
:alt: Sunset at the beach
:align: center

Schematic representation of space and time scales of atmospheric phenomena from aerosols and cloud drops/crystals at the “microscale” to clouds, tornadoes, and thunderstorms at the “mesoscale” up to tropical cyclones (hurricanes), and extratropical cyclones at the “synoptic scale” up to the general circulation and global climate scale. Types of models and their approximate ranges are colored. The “resolved” scale of a model is typically three to five times the spatial scale, so the effective spatial scale should be shifted to the right. DNS, direct numerical simulation. Source: [Paper (Science)](https://www.science.org/doi/10.1126/sciadv.abn3488)
```

***
### Process Parameterization

> What mathematical forms to use for the process parameterization equations, and at what architecture scale of interest.

**Examples**:
* Process relationships via equations that account for the sub-element processes
* Material Properties

This will even further restrict the trajectories that can occur within my system.


**Note**: there are some processes we can ignore due to scale of interest, e.g., QG versus Shallow Water.

**Note 2**.
From a dynamical model perspective, this is kind of like thinking of the *God* equation which encompasses **all** elements. 
But we don't know the God equation and we also don't have enough compute for all of the higher order terms.
So we choose a reduced model, e.g., only linear or 1st order non-linear.

$$
y = f(x|\theta)
$$

***
### Uncertainty

> What uncertainties are important, and how to represent them mathmatically?

We can use some uncertainty representations which are uninformative, e.g., Uniform or Gaussian.
We can also encode some knowledge about the tails of the distribution.
For example, we could use some long-tailed distributions like the LogNormal or GEVD/GPD case.
We could also put some very narrow priors which would converge to a single value, e.g., Delta or Beta.

***
### Solution Procedure

aka - Inference, `Learner`

> How to integrate, in space & time, the resulting system of Stochastic Differential equations (SDEs)?

The procedure for **solving** the resulting mathematical model.


## What can go wrong?


## Learning

**Check Assumptions About Data**.
We make sure that the *likelihood* metric accurately reflects the stochastic nature of the information provided by the data.

$$
\text{maximize} \hspace{2mm} L(\text{Model}|\text{Data})
$$

**Parameter and/or State Estimation**.
We want to search for all feasible state and/or parameter values.

$$
z^*(\theta) = \argmin p(z,\theta|\mathcal{D},\mathcal{H})
$$

$$
\text{maximize} \hspace{2mm} 
L(
z,\theta |
\mathcal{H}^{pp},
\mathcal{H}^{un},
\mathcal{H}^{disc},
\mathcal{H}^{CL},\mathcal{D})
$$


**Process Parameterization Estimation**.
We need to re-read the literature, do more field work or try more guesses.

$$
\text{maximize} \hspace{2mm} 
L(\mathcal{H}^{pp} | 
\mathcal{H}^{un},
\mathcal{H}^{disc},
\mathcal{H}^{CL},\mathcal{D})
$$



**Discretization Estimation**.

How do we distinguish system discretization & process parameterization?

$$
\text{maximize} \hspace{2mm} 
L(
\mathcal{H}^{disc},
\mathcal{H}^{pp} | 
\mathcal{H}^{un},
\mathcal{H}^{CL},\mathcal{D})
$$
