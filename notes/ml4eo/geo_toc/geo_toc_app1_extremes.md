---
title: App 1 - Modeling Extreme Values
subject: ML4EO
short_title: TOC - App I - Extremes
authors:
  - name: J. Emmanuel Johnson
    affiliations:
      - CSIC
      - UCM
      - IGEO
    orcid: 0000-0002-6739-0053
    email: juanjohn@ucm.es
license: CC-BY-4.0
keywords: notation
---


## Overview

In this application, we are interested in modeling temperatures, and in particular, temperature extremes.

*** 
### Quick Walk-Through

***
#### **Datasets**.
The first set of datasets will feature a range of different

$$
\begin{aligned}
\text{Univariate Time Series}: && &&
\mathcal{D} &= \left\{t_n, y_t \right\}_{n=1}^{N_T} && &&
y_n\in\mathbb{R} \\
\text{Multivate Time Series}: && &&
\mathcal{D} &= \left\{t_n, \mathbf{y}_t \right\}_{n=1}^{N_T} && &&
\mathbf{y}_n\in\mathbb{R}^{D_y} \\
\text{Multivate Spatiotemporal Series}: && &&
\mathcal{D} &= \left\{(t_n, \mathbf{s}_n), \mathbf{y}_t \right\}_{n=1}^{N_T} && &&
\mathbf{y}_n\in\mathbb{R}^{D_y} \\
\text{Coupled Multivate Spatiotemporal Series}: && &&
\mathcal{D} &= 
\left\{(t_n, \mathbf{s}_n), \mathbf{x}_n, \mathbf{y}_t \right\}_{n=1}^{N_T} 
&& &&
\mathbf{y}_n\in\mathbb{R}^{D_y} \\
\end{aligned}
$$

***
#### **Sub-Topics**

**Basics**.
We will feature some basics of the Bayesian modeling workflow.
There will be some basics like defining a prior, likelihood, and posterior.
We will also have.
All code will be done with a high-level PPL, i.e., `numpyro`.

**Bayesian Hierarchical Modeling**.
For many small datasets, we have a lot of hierarchical dependencies.
By introducing the notion of a fully-pooled, non-pooled, and partially-pooled model for a simple model, we will introduce the notion of a latent-variable model.
This will be an underlying approach for all remaining models throughout these applications.


**Game of Dependencies**.
Many people do not have a solid grasp about dependencies within spatiotemporal data.
We will walk-through this step-by-step by slowly introducing more complex representations, e.g., IID, time conditioning, dynamical models, and state-space models.

**Extreme Values**.
Extreme values are a worlds apart from the standard mean and standard deviation.
In this section, we will introduce this from fir
We will introduce this from the perspective of Temporal Point Processes (TPPs).
Some staple distributions will include the Poisson Process, the GEVD, and the GPD.

**Marked Temporal Point Processes**.
The end-goal for extreme values (and many schemes in general) is to make predictions, i.e., what is the probability that there will be an extreme event, $\lambda$, with a certain intensity, $z$, at a certain location, $\mathbf{s}$, or time, $t$, given historical observations, $\mathcal{H}$, and some covariate parameter, $x$.


***
#### **Useful Skills**

**Unstructured Measurements**.
We will immediately start dealing with unstructured datasets which are ubiquitous in the geosciences.
We will learn how to model data with an unstructured representation.
We will also learn how we can transform them to a more structured representation which is more useful for other other applications.

**Real-Time Applications**.
We will be dealing with time series directly. 
This gives us the advantage that we will be able to train our models, use them for predictions, and then update them as we obtain more observations.

**Immediate Applicability**.
We will have some immediate applicability because extreme events are things that we have to deal with on a daily basis.

***
## **Datasets**

We will use some standard datasets that are found within the AEMET database.

$$
\begin{aligned}
\mathcal{D} &= \left\{(t_n, \mathbf{s}_n), \mathbf{x}_n, \mathbf{y}_n \right\}_{n=1}^{N},
&& &&
\mathbf{y}_n\in\mathbb{R}^{D_y} &&
\mathbf{x}_n\in\mathbb{R}^{D_y} &&
\mathbf{s}_n\in\mathbb{R}^{D_s} &&
t_n\in\mathbb{R}^{+}
\end{aligned}
$$


* Covariante, $x_n$
  * Global Mean Surface Temperature Anomaly (GMSTA)
* Measurement, $y_n$: 
  * Daily Mean Temperature (TMax)
  * Daily Maximum Temperature (TMean)


***
### **Extreme Events**

$$
\mathcal{D} = \left\{y_n\right\}_{n=1}^N
$$
We will use some standard techniques to extract the extreme events from the time series.
* Block Maximum (BM)
* Peak-Over-Threshold (POT)
* Temporal Point Process (TPP)


***
### **Data Likelihood**

$$
y \sim p(y|z)
$$
We need to decide which likelihood we want to use.
For the mean data, we can assume that it follows a Gaussian distribution or a long-tailed T-Student distribution.
However, for the maximum values, we need to assume an EVD like the GEVD, GPD or TPP.
* Mean -> Gaussian, T-Student
* Maximum -> GEVD, GPD, TPP

***
### **Parameterizations**

$$
p(\mathbf{y},\mathbf{z},\boldsymbol{\theta}) = p(y|z)p(z|\theta)p(\theta)
$$
We have to decide the parameterization we wish to use.
* IID
* Hierarchical
* Strong-Constrained Dynamical, i.e., Neural ODE/PDE
* Weak-Constrained Dynamical, i.e., SSM, EnsKF

***
### **State Estimation**

$$
z^*(\theta) = \argmin \hspace{2mm}\boldsymbol{J}(z;\theta)
$$

* Weak-Constrained
  * Gradient-Based - 4DVar
  * Derivative-Free - Ensemble Kalman Filter
  * Minimization-Based - DEQ

***
### **Predictions**

$$
u \sim p(u|z^*)p(z^*|\mathcal{D})
$$

Our final task is to use a our new model to make predictions.
* Feature Representation
* Interpolation
* HindCasting
* Forecasting

***
## Datasets

#### Global Mean Surface Temperature

This is an anomaly dataset.

$$
\begin{aligned}
y &= y(t), && && y:\mathbb{R}^+\rightarrow\mathbb{R}
&& &&
t\in\mathcal{T}\subseteq\mathbb{R}^+
\end{aligned}
$$

***
**Time**

$$
\begin{aligned}
\Delta t &= \text{1 Year} \\
\mathcal{T} &= [1930,2023]\\
N_T &= 
\end{aligned}
$$

***
#### Weather Station Data Spain

$$
\begin{aligned}
\mathbf{y}_n &= \boldsymbol{y}(\mathbf{s}_n,t_n), && &&
\boldsymbol{y}:\mathbb{R}^{D_s}\times\mathbb{R}^+ \rightarrow \mathbb{R}^{D_y} \\
\end{aligned}
$$

Our coordinates are as follows.

$$
\begin{aligned}
\mathbf{s}_n \in\Omega\subseteq\mathbb{R}^{D_s} && &&
t_n\in\mathcal{T}\subseteq\mathbb{R}^+ && &&
\mathbf{y}_n \in \mathcal{Y}\subseteq\mathbb{R}^{D_y}
\end{aligned}
$$

We can also showcase the discretized version


***
**Time**

$$
\begin{aligned}
\Delta t &= \text{1 Day} \\
\mathcal{T} &= [1960, 2020] \\
N_T &= 
\end{aligned}
$$

***
**Spatial Coordinates**

$$
\begin{aligned}
\Omega &= \text{Point Cloud} && [\text{670 Stations}]\\
D_s &=
\begin{bmatrix}
\text{Longitude} \\
\text{Latitude} \\
\text{Altitude}
\end{bmatrix}
\end{aligned}
$$

***
**Variables**

$$
D_y =
\begin{bmatrix}
\text{Max Temperature} \\
\text{Mean Temperature} \\
\text{Minimum Temperature} \\
\text{Precipication} \\
\text{Wind Speed}
\end{bmatrix}
$$


***
## Questions


**Parameter Estimation**
* Naive Density Estimator, $p(y,\theta)=p(\theta^*|\mathcal{D})$
* Can we maximize the data likelihood?, $\theta^* = \argmin \boldsymbol{L}(\theta)$
* What are the distribution of the parameters? $\theta\sim p(\theta^*|\mathcal{D})$
* What parametric form fits the best? $f,\theta,AIC,BIC,NLL$
* How sensitive is it to the initial condition? $x_0\sim p(x_0|\theta)$
* What is the predictive uncertainty?, $y\sim p(y|z)p(z|x^*,\theta^*)p(\theta^*|\mathcal{D})$
* Can we introduce structure to reduce the complexity? LocalLinear, AutoRegressive, Cycle

**Representation**
* What temporal resolution for GEVD?, e.g. Decade, Year, Season, Month
* What temporal resolution for GPD?, e.g., Day, 3 Days, 5 Days, 7 Days
* What spatial resolution for GEVD?, e.g., Individual Stations, Spatial Clusters, Coarse Grid, Fine Grid

**Predictions**
* Can we forecast? Does it make sense? $z_{T+\tau}$
* Can we hindcast? Does it makes sense? $z_{T-\tau}$



***
## Appendix

There are various things we need to go over which will help us deal with extreme events.


***
## Blog Schedule

**Part I**: Global Mean Surface Temperature

**Part II**: Weather Station Means

**Part III**: Weather Station Extremes

**Part IV**: Multiple Weather Stations

***
### **Part I**: GMST

* [ ] Data Download + EDA
    * `matplotlib`
    * Statistics, Histogram, Stationarity, Noise
* [ ] Recreating the Anomalies
    * `xarray`
    * Filtering, Averaging, Periods + Averaging
* [ ] Manual Feature Representation
    * `statsmodels`
    * Additive vs Multiplicative
    * Trend, Cycle, Residuals
* [ ] Unconditional Density Estimation
    * `Numpyro`
    * Bayesian IID Model
* [ ] Metrics
    * PP-Plot, QQ-Plot, Posterior, Joint Plot, Return Period
    * NLL, AIC, BIC
* [ ] Bayesian Hierarchical Model
    * `Numpyro`
    * Fully Pooled, Non-Pooled, Partial Pooled
* [ ] Temporally Conditioned Density Estimation
    * `Numpyro`
    * Function Approximation
    * Time-Split, Training Split Tricks
* [ ] Function Approximation Whirlwind Tour
    * Linear
    * Basis Function
    * Neural Network
    * Gaussian Processes
* [ ] Ensembles
    * Multiple GMSTA Perspectives
* [ ] X-Casting
* [ ] Strong-Constrained Dynamic Model, aka, NeuralODE
* [ ] Weak-Constrained Dynamical Model, aka, SSM

***
### **Part II**: Spain Weather Stations (Mean)

> In this module, we start to look at single weather stations for Spain.

* [ ] Data Download + EDA - Histograms, Stationarity, Noise
* [ ] Gaussian vs T-Student vs GEVD
* [ ] IID
* [ ] Discretization
    * [ ] Regular + Finite Diff + Convolutions
    * [ ] Irregular + Symbolic + AD
* [ ] Dynamical
* [ ]  Custom Likelihood in `Numpyro` - GEVD, GPD


***
### **Part III**: Spain Weather Stations (Extremes)

* [ ] Extreme Values - Block Maximum v.s. Peak-Over-Threshold
* [ ] Parameterization - Temporal Point Process
* [ ] Relationship with common dists, GEVD & GPD