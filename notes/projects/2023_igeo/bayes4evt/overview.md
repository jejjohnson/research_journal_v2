---
title: Bayes4EVT
subject: AI 4 Extremes
short_title: Overview
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


## Datasets

We are primarily dealing with temperature measurements. 
In particular, we are looking at 2 meter temperature (t2m) above the Earths surface.
Our region of interest is Spain and the period of interest spans 1960 until 2021.
We are dealing directly with measurements from stations that are scattered throughout Spain, like  Madrid, Bilbao, or Valencia.
We want to take a step further and look for extreme temperatures.
So this entails taking maximum daily values through our region and period of interest.

From a modeling standpoint, we hope to characterize the tails of distribution of these temperature measurements, i.e., the extreme values.
This will be useful because we can make predictions about the occurrences of these extreme events.
In addition, if we can correlate these extremes to external factors like Global Mean Surface Temperature (GMST), it makes a stronger statement about the trajectory of frequency of occurrence of these extreme values.


***
## Models

We will take three approaches to modeling these extreme values: 1) block maximum (BM), 2) peak-over-thresholds (POT), and 3) temporal point process (TPP).

**GEVD**. For the BM method, we will use the generalized extreme value distribution (GEVD). 
This will be an annual maximum for each station.
The annual BM is arguably the most reliable and stable method for classifying extremes.
However, the downside is that we don't take advantage of all of the values we would consider extreme.

**GPD**.
For the POT method, we will use the generalized Pareto distribution (GPD).
This will choose a threshold and model all values above the threshold.
This method is more complex because one has to choose an appropriate threshold as well as *decluster* events.
However, the upside is that we will have more occurrences of extremes which will be better for fitting models.

**Point Process**. We will choose the extreme distribution to be the PP which will be a combination of the GEVD and the Poisson-GPD but under the PP framework.


***
## Covariates

Each of the above models assumes each observation is IID.

#### **No Covariates**
We will apply all models assuming no covariates.
So we will find a set of parameters for each station independently.

$$
p(y,\theta) = p(\theta) \prod_{n=1}^N p(y|\theta)
$$

#### **Spatial Covariates**
We will utilize the neighbouring stations as covariates for the model.

$$
p(y,\theta,f) = p(\theta) \prod_{n=1}^N p(y_n|z_n)p(z_n|f_n,\theta)
$$

#### **Global Mean Surface Temperature (GMST)**
We will use the GMST as a proxy for the temporal dependency.

$$
p(y,x,f,\theta) = p(\theta) \prod_{n=1}^N p(y_n|z_n)p(z_n|f_n, x_n,\theta)
$$

***
### Inference

Each of the above models will have various parameter estimators.

* Maximum Likelihood Estimator (MLE)
* Maximum A Posteriori (MAP)
* Laplace Approximation (Laplace)
* Markov Chain Monte Carlo (MCMC)

***

## Experiments

### Experiment I

We will apply different models using different inference methods on each station in Spain individually.
We make the following assumptions:
* I.I.D.
* Stationary Process
* No Spatial Dependencies
* No Covariates

$$
\begin{aligned}
\mathcal{D} = \left\{ t_n, y_n \right\}_{n=1}^N
&& &&
t_n \in\mathcal{T}\subseteq\mathbb{R}^+
&& &&
y_n\in\mathcal{Y}\subseteq\mathbb{R}
\end{aligned}
$$


***
#### Experiment Ia

> For this process, we will exclusively use the GEVD for the data likelihood.

**Results**: 
* [Madrid](./exp1_unc_madrid_gevd.md)
* [Spain](./exp1_unc_spain_gevd.md)



:::{tip} Model 1 - Point Process GEVD
:class: dropdown


:::

***
#### Experiment Ib

:::{tip} Model 0 - Baseline GPD
:class: dropdown



**Summary Formulation**

The null model, $M_0$, will demonstration a do a baseline where we maximize the log-likelihood of the joint distribution.

$$
\log p(y_{1:N},\theta) = 
\sum_{n=1}^N\log \boldsymbol{f}_{\text{GPD}}(y_n|\boldsymbol{\theta}) 
+ \log p(\boldsymbol{\theta})
$$

***
**Analysis**

Firstly, we will do the standard assessment of the fit by comparing this with the
We can also estimate the parameters of the GEVD using some relationships between the GEVD and the GPD.
We will also calculate the average recurrence interval (ARI) and the return period (RP) to calculate the 100-year event.


:::

:::{tip} Model 1 - Point Process GPD
:class: dropdown

**Summary Formulation**

$M_1$, will demonstration how we can apply the PP formulation to calculate the parameters of the GEVD.

$$
\begin{aligned}
\text{Hazard Function}: && &&
\lambda(y,t) &= \boldsymbol{f}_{\text{GPD}}(y;\boldsymbol{\theta}) \\
\text{Cumulative Hazard Function}: && &&
\Lambda(A) &= \int_0^T\boldsymbol{S}_{\text{GPD}}(y;\boldsymbol{\theta})d\tau
\end{aligned}
$$

The log-likelihood will result in 

$$
\log p(y_{1:N},\theta) = 
\sum_{n=1}^N\log \boldsymbol{f}_{\text{GPD}}(y_n|\boldsymbol{\theta})
+ \log p(\boldsymbol{\theta})
- \int_0^T\boldsymbol{S}_{\text{GPD}}(y;\boldsymbol{\theta})d\tau
$$

***
**Analysis**

Firstly, we will do the standard assessment of the fit by comparing this with the
We can also estimate the parameters of the GEVD using some relationships between the GEVD and the GPD.
We will also calculate the average recurrence interval (ARI) and the return period (RP) to calculate the 100-year event.


:::

***

### Experiment II

We will apply different models using different methods on each of the station assuming we can exploit the shared spatial information.

* **Experiment 2a** - GEVD Model
* **Experiment 2b** - GPD Model
* **Experiment 2c** - TPP Model


***

### Experiment III

We will apply different models using different methods on each of the station assuming we can exploit the shared spatial information.
In addition, we will use the GMST as a proxy for the time component.

* **Experiment 3a** - GEVD Model
* **Experiment 3b** - GPD Model
* **Experiment 3c** - TPP Model