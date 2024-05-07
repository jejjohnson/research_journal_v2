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


**Single Station Data**. All of these experiments are performed on univariate time series which corresponds to a single station.
We will take a single station, e.g., Madrid, Bilbao, or Valencia, and learn the parameters of the an extreme distribution.

**Multivariate Data**. We will improve upon these by applying a model that can take into account all of the stations within Madrid.


***
## Models


**GEVD**. We will choose the extreme distribution to be the GEVD distribution.

**Poisson-GPD**. We will choose the extreme distribution to be the Poisson-GPD distribution.

**Point Process**. We will choose the extreme distribution to be the Point Process which will be a combination of the GEVD and the Poisson-GPD but under the Point process framework.


***
### Covariates

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

We will apply different models using different inference methods on each station in Madrid individually.
We will assume there are no covariates within the model.

* [**Experiment 1a**](./exp1_unc_madrid_gevd.md) - GEVD Model
* **Experiment 1b** - Poisson-GPD Model
* **Experiment 1c** - MCMC Model

***

### Experiment II

We will apply different models using different methods on each of the station assuming we can exploit the shared spatial information.

* **Experiment 2a** - GEVD Model
* **Experiment 2b** - Poisson-GPD Model
* **Experiment 2c** - MCMC Model


***

### Experiment III

We will apply different models using different methods on each of the station assuming we can exploit the shared spatial information.
In addition, we will use the GMST as a proxy for the time component.

* **Experiment 3a** - GEVD Model
* **Experiment 3b** - Poisson-GPD Model
* **Experiment 3c** - MCMC Model