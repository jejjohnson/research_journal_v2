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


```{list-table} Table of methods
:header-rows: 1
:name: tb-methods-exp1 

* - Experiment
  - Model
  - Name
* - 1a
  - $M_0$
  - GEVD
* - 1a
  - $M_1$
  - PP-GEVD
* - 1b
  - $M_0$
  - GPD
* - 1b
  - $M_1$
  - PP-GPD
* - 1b
  - $M_1$
  - PP-GPD-GEVD
```


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
\sum_{n=1}^N\log \boldsymbol{f}_{\text{GEVD}}(y_n;\boldsymbol{\theta}) 
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
$$ (eq:gevd-nll)


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
$$ (eq:pp-space-2d)

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
\sum_{n=1}^{N_T} 
\boldsymbol{S}_\text{GEVD}(y_0;\boldsymbol{\theta})
=
N_T\boldsymbol{S}_\text{GEVD}(y_0;\boldsymbol{\theta})
$$

where $N_T$ corresponds to the number of years.
Now, we can write the log-likelihood function as

$$
\log p(y_{1:N},\theta) = 
\sum_{n=1}^{N_T} 
\log \boldsymbol{f}_{\text{GEVD}}(y_n|\boldsymbol{\theta})
+
\log p(\boldsymbol{\theta})
- 
N_T\boldsymbol{S}_\text{GEVD}(y_0;\boldsymbol{\theta})
$$

The first term is the log-likelihood of the specific events at the specific location, $(t_n,y_n)$, that we observe them.
The second term is the probability that we do not observe them anywhere else within the time interval of interest, $(0,T]$.
We can plug in the formulas for the GEVD into this expression to obtain

$$
\begin{aligned}
\boldsymbol{L}_\text{PP-GEVD}(\boldsymbol{\theta})
&:= 
\boldsymbol{L}_\text{GEVD}(\boldsymbol{\theta})
- 
N_T
\left[ 1 + \kappa z_n\right]_+^{-1/\kappa}
\end{aligned}
$$ (eq:pp-gevd-nll)

where $\boldsymbol{L}_\text{GEVD}$ is the LL for the GEVD PDF (equation [](eq:gevd-nll)).




***
#### **GPD Connections**

We can also estimate the parameters of the Poisson-GPD using some relationships between the GEVD and the GPD.
The parameters of the GPD can be calculated by
$$
\begin{aligned}
\lambda = [1 + \kappa z_0]_+^{-1/\kappa}
&& &&
\sigma^* &= \sigma + \kappa(y_0 - \mu)
&& &&
\kappa^* = \kappa
\end{aligned}
$$
where $z_0 = (y_0 - \mu)/\sigma$.
There are other formulations which exist like:
$$
\begin{aligned}
\mu^* = \mu + \frac{\sigma}{\kappa}(1 - \lambda^\kappa) 
&& &&
\sigma^* = \sigma\kappa^{\kappa}
&& &&
\kappa^* = \kappa
\end{aligned}
$$
Note, in this experiment for the GEVD, we have 1 event per year, i.e., $\lambda=1$. 
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
## Model 2

> For this process, we will exclusively use the GPD model for the data likelihood.

Under these assumptions, we will try fitting different methods for the GPD method. 
We will try the following:
* $M_0$ - a naive parameter estimation assuming IID. This will server as the *null model* for this experiment.
* $M_1$ - a marked point process formulation
* $M_2$ - a decoupled marked point process formulation


***
### Model 2a - GPD

The null model, $M_{2_a}$, will demonstration a do a baseline where we assume the data are distributed IID

$$
\mathcal{D} = \left\{ y_n \right\}_{n=1}^N
$$

We can write the joint distribution as 

$$
p(y_{1:N},\boldsymbol{\theta}) = p(\boldsymbol{\theta})\prod_{n=1}^N p(y_n|\boldsymbol{\theta})
$$
where $p(\boldsymbol{\theta})$ are the prior parameters and $p(y_n|\boldsymbol{\theta})$ is the data likelihood.
In this case, we assume that the measurements follow a GPD.

$$
\begin{aligned}
\text{Data Likelihood}: && &&
p(y_n|\boldsymbol{\theta}) &= \boldsymbol{f}_{\text{GPD}}(y_n;\boldsymbol{\theta})
\end{aligned}
$$

So, to find the best parameters, we can maximize the log-likelihood of the joint distribution which is given as

$$
\log p(y_{1:N}|\theta) = 
\sum_{n=1}^N\log \boldsymbol{f}_{\text{GPD}}(y_n;\boldsymbol{\theta}) 
$$

We can plug in the equations for the GEVD to obtain the full expressions

$$
\boldsymbol{L}_\text{GPD}(\boldsymbol{\theta})
:= 
- N \log \sigma -
(1+1/\kappa)\sum_{n=1}^N 
\log \left[ 1 + \kappa z_n\right]_+
$$ (eq:gpd-nll)



***
### Model 2b - PP-GPD

**Summary Formulation**. 
$M_{2_b}$ will demonstration how we can apply the PP formulation to calculate the parameters of the GEVD.
We have a 2D space as shown in equation [](eq:pp-space-2d).
The joint hazard function is factored into a temporal component and a marks component

$$
\lambda(y,t) = \lambda(t)\lambda(y) = \boldsymbol{f}_{\text{GPD}}(y;\boldsymbol{\theta}) 
$$
Note, we assume the ground intensity term equal 1, $\lambda_g(t)=1$, which corresponds to a standard Poisson process (SPP); a special case of the Homogeneous Poisson process (HPP).
The cumulative hazard function can be written as

$$
\Lambda(A) = \int_0^T\int_y^\infty \boldsymbol{f}_{\text{GPD}}(y;\boldsymbol{\theta}) dyd\tau
= \int_0^T\boldsymbol{S}_{\text{GPD}}(y;\boldsymbol{\theta})d\tau
$$

We used the relationship of the SF, the CDF, and the PDF.
We approximate this integral using a simple Riemann sum

$$
\int_0^T\boldsymbol{S}_\text{GPD}(y_0;\boldsymbol{\theta}) 
\approx 
\sum_{n=1}^{N_T} 
\boldsymbol{S}_\text{GPD}(y_0;\boldsymbol{\theta})
=
N_T\boldsymbol{S}_\text{GPD}(y_0;\boldsymbol{\theta})
$$

where $N_T$ corresponds to the number of events.
Now, we can write the log-likelihood function as

$$
\log p(y_{1:N},\theta) = 
\sum_{n=1}^{N_T}\log \boldsymbol{f}_{\text{GPD}}(y_n;\boldsymbol{\theta})
+ \log p(\boldsymbol{\theta})
- 
N_T\boldsymbol{S}_\text{GPD}(y_0;\boldsymbol{\theta})
$$

The first term is the log-likelihood of the specific events at the specific location, $(t_n,y_n)$, that we observe them.
The second term is the probability that we do not observe them anywhere else within the time interval of interest, $(0,T]$.
We can plug in the formulas for the GEVD into this expression to obtain

$$
\begin{aligned}
\boldsymbol{L}_\text{PP-GPD}(\boldsymbol{\theta})
&:= 
\boldsymbol{L}_\text{GPD}(\boldsymbol{\theta})
- 
N_T
\left[ 1 + \kappa z_0\right]^{-\frac{1}{\kappa}}
\end{aligned}
$$

where $z_0 = (y_0 - \mu)/\sigma$ and $\boldsymbol{L}_\text{GPD}$ is the LL for the GPD PDF (equation [](eq:gpd-nll)).

***
### Model 2c - PP-GPD-GEVD

$M_{2_c}$ will be the same as the above one except we will investigate how we can use

$$
\begin{aligned}
\sigma^* = \sigma + \kappa (y_0 - \mu)
\end{aligned}
$$

***
## Model 3

> For this process, we will exclusively use a combination of the GPD model for the data likelihood.

Under these assumptions, we will try fitting different methods for the GPD method. 
We will try the following:
* $M_0$ - a naive parameter estimation assuming IID. This will server as the *null model* for this experiment.
* $M_1$ - a marked point process formulation
* $M_2$ - a decoupled marked point process formulation

***
### Model 3a

We have the hazard function

$$
\lambda (t,y) =
\lambda_g(t)p(y|t) =
\lambda \hspace{1mm}\boldsymbol{f}_\text{GPD}(y;\boldsymbol{\theta})
$$

So, we can calculate the cumulative Hazard function just on the ground intensity

$$
\Lambda(\mathcal{T}) = \int_0^T\lambda d\tau = \lambda T
$$

Now, we can plug this into our log-likelihood function.

$$
\log p(A) =
N\log\lambda
-
\lambda T
+
\sum_{n=1}^{N_T} \log \boldsymbol{f}_\text{GPD}(y_n;\boldsymbol{\theta}) 
$$

***
### Model 3b

We will use some reparameterization of the lambda term, $\lambda$, to be in terms of the 

$$
\begin{aligned}
\lambda &= [1 + \kappa z_0]^{-1/\kappa} 
&& &&
z_0 = (y_0 - \mu) / \sigma \\
\sigma^* &=
\sigma + \kappa (y_0 - \mu) \\
\kappa^* &=
\kappa
\end{aligned}
$$

We can expand this likelihood function fully to be

$$
\log p(A) =
-\frac{N}{\kappa}\log[1 + \kappa z_0]
-
N_{T_y} [1 + \kappa z_0]^{-1/\kappa} 
+
\sum_{n=1}^{N_T} \log \boldsymbol{f}_\text{GPD}(y_n;\boldsymbol{\theta}) 
$$

where $N_{T_y}$ is the number of years.


***
### Model 3c

$$
\lambda (t,y) =
\lambda_g(t)\lambda_g(y)p(y|t)
$$

So

$$
\begin{aligned}
\text{Ground Intensity (Time)}: && &&
\lambda_g(t) &= 1 \\
\text{Ground Intensity (Marks)}: && &&
\lambda_g(y) &= \boldsymbol{f}_\text{GEVD}(y_0;\boldsymbol{\theta}) \\
\text{Conditional Marks}: && &&
p(y|t) &= \boldsymbol{f}_\text{GPD}(y;\boldsymbol{\theta})
\end{aligned}
$$

We have already seen the intensity terms in the above section.
This is equivalent to Model $M_{1_b}$.

$$
\begin{aligned}
\boldsymbol{L}_\text{PP-GPD-GEVD}(\boldsymbol{\theta})
&:= 
\boldsymbol{L}_\text{PP-GPD-GEVD}(\boldsymbol{\theta}) 
+
\boldsymbol{L}_\text{GPD}(\boldsymbol{\theta}) \\
&=
\sum_{n=1}^{N_T} 
\log \boldsymbol{f}_{\text{GEVD}}(y_n|\boldsymbol{\theta})
- 
N_T\boldsymbol{S}_\text{GEVD}(y_0;\boldsymbol{\theta})
+
\sum_{n=1}^{N_T} \log \boldsymbol{f}_\text{GPD}(y_n;\boldsymbol{\theta}) 
\end{aligned}
$$

where $\boldsymbol{L}_\text{PP-GEVD}(\boldsymbol{\theta})$ is defined in equation [](eq:pp-gevd-nll) and $\boldsymbol{L}_\text{GPD}(\boldsymbol{\theta})$ in equation [](eq:gpd-nll).


