---
title: Preliminary Results
subject: Misc. Notes
short_title: Experiment 1 - Formulation
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


## Experiment 1a


> For this process, we will exclusively use the GEVD for the data likelihood.


Under these assumptions we will try a few different models for fitting the GEVD method.
We will try the following:
* Null Model ($M_0$) - a naive log-likelihood estimation of the parameters assuming IID.
* $M_1$ - a 2D point process formulation using the GEVD method

**Hypothesis**.
*The log-likelihood loss function is very similar for both approaches.*
*However, the PP formulation has an extra "regularization" term which may improve or worsen the parameter estimation.*

**Analysis**.
We do a number of analysis to assess the efficacy of the methods.
Some standard methods include:
* Q-Q Plot
* AIC 
* BIC


***
### Null Model - Baseline GEVD


**Summary Formulation**.
The null model, $M_0$, will demonstration a do a baseline where we assume the data are distributed IID

$$
\mathcal{D} = \left\{ y_n \right\}_{n=1}^N
$$

We can write the joint distribution as 

$$
p(y_{1:N},\boldsymbol{\theta}) = p(\boldsymbol{\theta})\prod_{n=1}^N p(y_n|\boldsymbol{\theta})
$$
where $p(\boldsymbol{\theta})$ are the prior parameters and $p(y_n|\boldsymbol{\theta})$ is the data likelihood.
In this case, we assume that the measurements follow a GEVD.

$$
\begin{aligned}
\text{Data Likelihood}: && &&
p(y_n|\boldsymbol{\theta}) &= \boldsymbol{f}_{\text{GEVD}}(y_n;\boldsymbol{\theta})
\end{aligned}
$$

So, to find the best parameters, we can maximize the log-likelihood of the joint distribution which is given as

$$
\log p(y_{1:N},\theta) = 
\sum_{n=1}^N\log \boldsymbol{f}_{\text{GEVD}}(y_n|\boldsymbol{\theta}) 
+ \log p(\boldsymbol{\theta})
$$

We can plug in the equations for the GEVD to obtain the full expressions

$$
\boldsymbol{L}_\text{GEVD}(\boldsymbol{\theta})
:= 
- N \log \sigma -
(1+1/\kappa)\sum_{n=1}^N 
\log \left[ 1 + \kappa z_n\right]_+
- 
\sum_{n=1}^N 
\left[ 1 + \kappa z_n\right]_+^{-1/\kappa}
$$


***

**Results**: 
* [Madrid](./exp1_unc_madrid_gevd.md)
* [Spain](./exp1_unc_spain_gevd.md)


***
### Model 1 - PP GEVD


***
**Summary Formulation**. $M_1$, will demonstration how we can apply the PP formulation to calculate the parameters of the GEVD.
We have a 2D space

$$
\begin{aligned}
A &= \left\{[0,T]\times[y,\infty) \right\},
&& &&
t\in\mathcal{T}\subseteq\mathbb{R}^+ 
&&
y\in\mathcal{Y}\subseteq\mathbb{R}
\end{aligned}
$$

The joint hazard function is factored into a temporal component and a marks component

$$
\lambda(y,t) = \lambda(t)\lambda(y) = \boldsymbol{f}_{\text{GEVD}}(y;\boldsymbol{\theta}) 
$$
Note, we assume the ground intensity term equal 1, $\lambda_g(t)=1$, which corresponds to a standard Poisson process (SPP); a special case of the Homogeneous Poisson process (HPP).
The cumulative hazard function can be written as

$$
\Lambda(A) = \int_0^T\int_y^\infty \boldsymbol{f}_{\text{GEVD}}(y;\boldsymbol{\theta}) dyd\tau
= \int_0^T\boldsymbol{S}_{\text{GEVD}}(y;\boldsymbol{\theta})d\tau
$$

We used the relationship of the SF, the CDF, and the PDF.
We approximate this integral using a simple Riemann sum

$$
\int_0^T\boldsymbol{S}_\text{GEVD}(y_0;\boldsymbol{\theta}) 
\approx 
\sum_{n=1}^{N_\text{Years}} 
\boldsymbol{S}_\text{GEVD}(y_0;\boldsymbol{\theta})
=
N_\text{Years}\boldsymbol{S}_\text{GEVD}(y_0;\boldsymbol{\theta})
$$

where $N_\text{Years}$ corresponds to the number of years.
Now, we can write the log-likelihood function as

$$
\log p(y_{1:N},\theta) = 
\sum_{n=1}^N\log \boldsymbol{f}_{\text{GEVD}}(y_n|\boldsymbol{\theta})
+ \log p(\boldsymbol{\theta})
- 
N_\text{Years}\boldsymbol{S}_\text{GEVD}(y_0;\boldsymbol{\theta})
$$

The first term is the log-likelihood of the specific events at the specific location, $(t_n,y_n)$, that we observe them.
The second term is the probability that we do not observe them anywhere else within the time interval of interest, $(0,T]$.
We can plug in the formulas for the GEVD into this expression to obtain

$$
\begin{aligned}
\boldsymbol{L}_\text{PP-GEVD}(\boldsymbol{\theta})
&:= 
- N \log \sigma -
(1+1/\kappa)\sum_{n=1}^N 
\log \left[ 1 + \kappa z_n\right]_+
- 
\sum_{n=1}^N 
\left[ 1 + \kappa z_n\right]_+^{-1/\kappa} 
- 
N_\text{Years}
\left[ 1 + \kappa z_n\right]_+^{-1/\kappa}
\end{aligned}
$$




***
#### **GPD Connections**

We can also estimate the parameters of the Poisson-GPD using some relationships between the GEVD and the GPD.
The parameters of the GPD can be calculated by
$$
\begin{aligned}
\mu^* = \mu + \frac{\sigma}{\kappa}(1 - \lambda^\kappa) 
&& &&
\sigma^* = \sigma \lambda^{\kappa}
&& &&
\kappa^* = \kappa
\end{aligned}
$$
Note, in this experiment, we have 1 event per year, i.e., $\lambda=1$. 
So we can simplify this formulation to be:
$$
\begin{aligned}
\mu^* = \mu 
&& &&
\sigma^* = \sigma
&& &&
\kappa^* = \kappa
\end{aligned}
$$


***
#### **Return Period / Average Recurrence Interval**

We will also calculate the average recurrence interval (ARI) and the return period (RP) to calculate the 100-year event.

$$
\begin{aligned}
y = \boldsymbol{Q}_\text{GEVD}(y_p;\boldsymbol{\theta}) 
&& &&
y_p = 1 - 1/T_a 
&& &&
y_p = \exp(- 1 / T_p)
\end{aligned}
$$
where $\boldsymbol{Q}_\text{GEVD}$ is the quantile distribution function and $T_a$ / $T_p$ is the year.
***
