---
title: Generalized Pareto Distribution
subject: Machine Learning for Earth Observations
short_title: GPD
authors:
  - name: J. Emmanuel Johnson
    affiliations:
      - CSIC
      - UCM
      - IGEO
    orcid: 0000-0002-6739-0053
    email: juanjohn@ucm.es
license: CC-BY-4.0
keywords: simulations
---

This is a location-scale family distribution.

***
## Parameters

$$
\begin{aligned}
\text{Location}: && &&
y_0 &\in \mathbb{R} \\
\text{Scale}: && &&
\sigma &\in \mathbb{R}^+ \\
\text{Shape}: && &&
\kappa &\in \mathbb{R} \\
\end{aligned}
$$

***
### Interpretation

We can interpret the shape parameters as follows:

**$\kappa=0$**.
This corresponds to a type 1, short tail distribution with exponential decay.

**$\kappa>0$**.
This corresponds to a type 2, heavy tail distribution with a slow power-law decay.

**$\kappa<0$**.
This corresponds to a type 3, thin-tailed, polynomial decay with a finite upper bound.

***
## Probability Density Function

This is denoted as the probability that our rv $Y$ will be equivalent to some specific value, $y$, conditioned on the fact that our values are greater than some threshold $y_0$.

$$
p(Y=y|y\geq y_0) := f(y;\boldsymbol{\theta})
$$

We can define the probability density function as

$$
\begin{aligned}
\boldsymbol{f}(y;\boldsymbol{\theta}) = 
\frac{1}{\sigma}\left[ 1 + \kappa \left( \frac{y-\mu}{\sigma} \right)\right]^{-\frac{1}{\kappa} - 1}_+
\end{aligned}
$$

where $a_+=\text{max}(a,0)$.

***
## Cumulative Distribution Function

This is denoted as the probability that our rv $Y$ will be less than or equal to some specific value $y$ conditioned on the fact that our values are greater than some threshold $y_0$.

$$
p(Y\leq y|y\geq y_0) := F(y;\boldsymbol{\theta})
$$



We can define the cumulative density function is defined as:

$$
\boldsymbol{F}(y;\boldsymbol{\theta}) = 
\begin{cases}
1 - \left[ 1 + \kappa \left( \frac{y-\mu}{\sigma} \right)\right]^{-1/\kappa}
, && \kappa\neq 0 \\
1 - \exp\left(-\frac{y-\mu}{\sigma}\right), && \kappa=0
\end{cases}
$$

***
## Survival Function

This is the exceedence probability of $Y$ above some value $y$.
**However**, in this case, this probability is conditioned on the probability of a threshold value, $y_0$.

$$
\boldsymbol{S}(y):= p(Y>y|Y>y_0) = 1 - p(Y\leq y|Y>y_0)
$$

We denote as the *survival function* of the GPD.
This is simply 1 minus the CDF of the GPD given as:

$$
\boldsymbol{S}(y;\boldsymbol{\theta}) = 1 - \boldsymbol{F}(y;\boldsymbol{\theta})
$$

We can plug in the CDF function into this equation  defined as:

$$
\boldsymbol{S}(y;\boldsymbol{\theta}) = 
\begin{cases}
\left[ 1 + \kappa \left( \frac{y-\mu}{\sigma} \right)\right]^{-\frac{1}{\kappa}}, && \kappa\neq 0 \\
\exp\left(-\frac{y-\mu}{\sigma}\right), && \kappa=0
\end{cases}
$$


***
## Quantile Function

This is also known as the *Point-Percentile-Function* or the inverse CDF.
This function maps an input threshold, $y_0$, to a value $y$ st the probability of $Y$ being less than or equal to $y$ is $y_p$.

$$
y_p = \boldsymbol{F}(y;\boldsymbol{\theta})
$$

We can take the inverse of this function to see that it is the inverse CDF which we denote as the quantile function.

$$
y_p = \boldsymbol{F}^{-1}(y_p;\boldsymbol{\theta}) := \boldsymbol{Q}(y_p;\boldsymbol{\theta})
$$

where $y_p\in[0,1]$ is the data within the probability transform domain.
These can be computed in closed form

$$
\boldsymbol{Q}(y_p) =
\begin{cases}
y_0 + \frac{\sigma}{\kappa} \left[ (1 - y_p)^{-\kappa} - 1 \right], && 
\kappa \neq 0 \\
y_0 - \sigma \log (1 - y_p), && 
\kappa = 0
\end{cases}
$$ (eq:gpd-quantile)

:::{tip} Derivation, $\kappa\neq 0$
:class: dropdown

Here, we will do the derivation for the case of $\kappa\neq 0$.
First, we will write out the CDF and assign it the value of $y_0$.

$$
\boldsymbol{F}(y;\boldsymbol{\theta}):=y_0 = 1 - \left(1 + \kappa z \right)^{-1/\kappa}
$$

where $\kappa\neq 0$ and $z=(y - y_0)/\sigma$. We will rearrange the terms to get

$$
\begin{aligned}
y_0 &= 1 - \left(1 + \kappa z \right)^{-1/\kappa} \\
\left(1+\kappa z \right)^{-1/\kappa} &=
1 - y_p \\
-\frac{1}{\kappa}\log(1 + \kappa z) &=
\log (1 - y_p) \\
\log (1 + \kappa z) &=
- \kappa \log (1 - y_p) \\
1 + \kappa z &= 
(1 - y_p)^{-\kappa} \\
\kappa z &= (1 - y_p)^{-\kappa} - 1 \\
z &= \frac{1}{\kappa}\left[ (1 - y_p)^{-\kappa}-1\right] \\
\end{aligned}
$$

Now, we plug in $z$ and we get our final expression

$$
y = \mu + \frac{\sigma}{\kappa}
\left[(1 - y_p)^{-\kappa} - 1 \right]
$$

:::

:::{tip} Derivation, $\kappa = 0$
:class: dropdown

Here, we will do the derivation for the case of $\kappa = 0$.
First, we will write out the CDF and assign it the value of $y_0$ where $\kappa = 0$.

$$
\boldsymbol{F}(y;\boldsymbol{\theta}):=y_0 = 1 - \exp(-z)
$$

where $\kappa = 0$ and $z=(y - y_0)/\sigma$. We will rearrange the terms to get

$$
\begin{aligned}
y_0 &= 1 - \exp(-z) \\
\exp(-z) &=
1 - y_p \\
-z &=
\log (1 - y_p) \\
z &=
- \log (1 - y_p) \\
\end{aligned}
$$

Now, we plug in $z$ to get our final expression.
$$
\boldsymbol{F}(y;\boldsymbol{\theta}):=y_0 = 1 - \sigma \log ( 1 - y_0)
$$

:::

<!-- y_0 + \frac{\sigma}{\kappa}\left[ 1 - \left(\frac{}{\lambda y_p}\right)^{\kappa}\right] -->

:::{tip} Code Snippet
:class: dropdown

We can do some naive functions for calculating the quantile functions based on the equations [](eq:gpd-quantile)

```python
# function for kappa neq 0
def gpd_quantile(yp, loc, scale, shape):
    # loc - scale / shape * (1 - (- log(1 - p)) ** (- shape))
    return loc + scale / shape * ((1 - yp) ** (- shape) - 1)
# function for kappa = 0
def quantile(yp, loc, scale):
    return loc - scale * log(1 - yp)
```

However, we can take into account some of the numerical errors that can come up.
We can look at the expression in equation [](eq:gpd-quantile) to be functions of the shape parameter only.

$$
\boldsymbol{F}_z(y_p;\kappa) =
\begin{cases}
\frac{1}{\kappa} \left[ (1-y_p)^{-\kappa} - 1\right], && \kappa \neq 0 \\
- \log (1 - y_p), && \kappa = 0
\end{cases}
$$

We will do some manipulation to write this in terms of a single function

$$
\boldsymbol{F}_z(y_p;\kappa) =
\begin{cases}
\frac{1}{\kappa}\exp\left[-\kappa\log (1 - y_p)\right] - 1, && \kappa \neq 0 \\
- \log (1 - y_p), && \kappa = 0
\end{cases}
$$

This makes it easier to code while taking into account numerical errors because we can do a simple `where` statement.

```python
# location scale inverse
def location_scale_inverse(z, location, scale):
    return location + scale * z

def location_scale_forward(x, location, scale):
    return (x - location) / scale

def gpd_quantile_shape(y_p, shape):
    # get boolian array
    is_shape_zero = jnp.equal(shape, 0.0)
    # calculate the true shape
    safe_shape = jnp.where(is_shape_zero, 0.0, shape)
    # calculate negative log term, -log(1-yp)
    shape_zero_term = - jnp.log1p(- y_p)
    # calculate k neq 0, exp(-k log(1-yp)) / k
    shape_nonzero_term = jnp.expm1(shape * neglog1mp) / safe_shape
    # zero 
    term = jnp.where(is_shape_zero, shape_zero_term,  shape_nonzero_term)
    return term

# function for kappa > 0
def gpd_quantile(y_p, loc, scale, shape):
    # calculate the shape parameter
    z = gpd_quantile_shape(y_p, shape)
    # calculate the inverse of location-scale
    return location_scale_inverse(z, loc, scale)
```


:::

***
## Inverse Survival Function

The inverse survival function maps the input value $y_s$ to some probability value $y_p$ which represents the probability that there is some value greater than said input value.

$$
y_s = Pr[Y> y_p]
$$

So recall the survival function is the negative of the CDF. 
This implies that the inverse survival function is the negative of the quantile function.

$$
y_p = \boldsymbol{S}(y;\boldsymbol{\theta}) = 1 - \boldsymbol{F}(y;\boldsymbol{\theta})
$$

We can take the inverse of this function to see that it is the inverse CDF which we denote as the quantile function.

$$
y_p = \boldsymbol{S}^{-1}(y_s;\boldsymbol{\theta}) := \boldsymbol{Q}(y_s;\boldsymbol{\theta})
$$

where $y_s\in[0,1]$ is the survival probability within the probability transform domain.
These can be computed in closed form

$$
\boldsymbol{Q}^{-1}(y_s) =
\begin{cases}
y_0 + \frac{\sigma}{\kappa} \left[ y_s^{-\kappa} - 1 \right], && 
\kappa \neq 0 \\
y_0 - \sigma \log y_p, && 
\kappa = 0
\end{cases}
$$ (eq:gpd-isurvival)

where $y_s=1-y_p$ is the survival probability.


:::{tip} Code Snippet
:class: dropdown

We can reuse the code snippet from before.

```python
# function for kappa > 0
def gpd_isf(y_s, loc, scale, shape):
    # calculate the shape parameter
    z = gpd_quantile_shape(1 - y_s, shape)
    # calculate the inverse of location-scale
    return location_scale_inverse(z, loc, scale)

```

:::



***
## Joint Distribution

We can write the likelihood that the observations, $y$, follow the GEVD distribution.
So, given some observations, $\mathcal{D}=\{y_n\}_{n=1}^{N}$, which we believe follow the GEVD distribution, we can write the joint distribution decomposition as


$$
p(y_{1:N}>y_0, y>y_0,\boldsymbol{\theta}) =
p(\boldsymbol{\theta})
\prod_{n=1}^N
p(y_n|y_n>y_0,\boldsymbol{\theta})p(y_n>y_0|\boldsymbol{\theta})
$$

This implies that the *global* prior parameters come from some distribution

$$
\boldsymbol{\theta} \sim p(\boldsymbol{\theta})
$$

and that these parameters get passed through our data likelihood term

$$
y_n \sim p(y|\boldsymbol{\theta})
$$

***
## Log Probability

Let's say we are given some samples.

$$
\mathcal{D} = \left\{ y_n\right\}_{n=1}^N
$$

where $N$ are the number of exceedances above our threshold, $y_0$.
Recall the GPD PDF for our iid samples is

$$
p(y_{1:N}|\boldsymbol{\theta}) = \prod_{n=1}^N
\frac{1}{\sigma}\left[ 1 + \kappa \left( \frac{y_n-y_0}{\sigma} \right)\right]^{-\frac{1}{\kappa} - 1}_+
$$

We can add the log term to get

$$
\log p(\boldsymbol{y}_{1:N}|\boldsymbol{\theta}) = \sum_{n=1}^N \log 
\left[ 1 + \kappa \left( \frac{y_n-y_0}{\sigma} \right)\right]^{-\frac{1}{\kappa} - 1}_+
$$

which reduces to

$$
\log p(\boldsymbol{y}_{1:N}|\boldsymbol{\theta}) =
- N \log \sigma -
(1+1/\kappa)\sum_{n=1}^N 
\log \left[ 1 + \kappa z_n\right]_+
$$ (eq:gpd_nll)

where $z_n=(y_n - y_0)/\sigma$ and $[1 + \kappa z_n]_+ = \text{max}(1 + \kappa z_n,0)$.

:::{tip} Code Snippet
:class: dropdown

We can create an likelihood function for this.

```python
def gpd_logpdf(x, location, scale, shape):
    # calculate location scale: z=(y−μ​)/σ
    z = (x - location) / scale
    # calculate t(z) = max(1+κz)
    t = max(1.0 + shape * z, 0)
    # term 1: −log σ
    t1 = - np.log(scale)
    # term 2: - (1+1/κ)log(1+κz)
    t2 = - (1.0 / shape + 1.0) * np.log(t) 
    return  t1 + t2
```

Instead of actually calculating the full scheme, we can simply apply this

```python
y: Array["T"] = ...
params: PyTree = ...
# apply vectorized operation
nll: Array["T"] = vectorize(gpd_logpdf, y, *params)
# take the sume
nll: Scalar = sum(nll)
```

:::




:::{tip} Proof of Log-Probability, $\kappa\neq 0$
:class: dropdown

We are interested in calculating the log probability function

$$
\log p(\boldsymbol{y}_{1:N}|\boldsymbol{\theta}) = \sum_{n=1}^N \log p(y_n|\boldsymbol{\theta})
$$

Let's consider only a single input, $y_n$.
We plug in $\boldsymbol{t}(y_n;\boldsymbol{\theta})$ to the likelihood term. 

$$
p(y_n|\boldsymbol{\theta}) = \frac{1}{\sigma}\left[ 1 + \kappa \left( \frac{y-y_0}{\sigma} \right)\right]^{-\frac{1}{\kappa} - 1}_+
$$

Now, we apply the log function 

$$
\log p(y_n|\boldsymbol{\theta}) = \log 
\left(
    \frac{1}{\sigma}
\left[ 1 + \kappa \left( \frac{y-y_0}{\sigma} \right)\right]^{-\frac{1}{\kappa} - 1}_+
\right)
$$

We can separate each of the terms

$$
\log p(y_n|\boldsymbol{\theta}) = \log 
\left(\frac{1}{\sigma}\right) + 
\log
\left(
\left[ 1 + \kappa \left( \frac{y-y_0}{\sigma} \right)\right]^{-\frac{1}{\kappa} - 1}_+
    \right)
$$

Now we can do some log rules to simplify the terms

$$
\log p(y_n|\boldsymbol{\theta}) = 
-\log \sigma + \left(-\frac{1}{\kappa} - 1\right)\log  
\left[ 1 + \kappa \left( \frac{y-y_0}{\sigma} \right)\right]_+
$$

We can plug in the $\boldsymbol{t}(y;\boldsymbol{\theta})$ to get a complete form.
Let $z=\frac{y-y_0}{\sigma}$

$$
\log p(y_n|\boldsymbol{\theta}) = 
-\log \sigma + 
\left(-\frac{1}{\kappa} - 1\right)
\log \left[ 1 + \kappa z\right]_+
$$


Now, we can plug in the sum

$$
\log p(\boldsymbol{y}_{1:N}|\boldsymbol{\theta}) =
\sum_{n=1}^N 
\left(
-\log \sigma - 
(1+1/\kappa)
\log \left[ 1 + \kappa z_n\right]_+
\right)
$$

We can factor out the constant values

$$
\log p(\boldsymbol{y}_{1:N}|\boldsymbol{\theta}) =
- N \log \sigma -
(1+1/\kappa)\sum_{n=1}^N 
\log \left[ 1 + \kappa z_n\right]_+
$$


:::

***
## Return Period

We can calculate the RP using equation [](eq:prob-return).

$$
R_T = Pr[Y>y|Y>y_0]Pr[Y>y_0]
$$

We assume that the occurrence of events over the threshold, $y_0$, is given by the Poisson process.

$$
\lambda_p = Pr[Y>y_0]
$$

We can calculate the RP using equation [](eq:prob-return).
Practically, we set this to the survival function of the GEVD (equation [](eq:gpd-survival)).

$$
1/T_R =
\lambda_p\boldsymbol{S}(y;\boldsymbol{\theta})=
\lambda_p\left(1-\boldsymbol{F}(y;\boldsymbol{\theta})\right)
$$ 

If we rearrange this equation, we get

$$
y_p := \boldsymbol{F}(y;\boldsymbol{\theta}) = 1 - 1 / (\lambda_p T_R)
$$

To make things simpler, we can simply use the quantile function in equation [](eq:gpd-quantile) and set the probability to 

$$
y_p = 1 - 1 / (\lambda_p T_R)
$$

However, if we expand this out, we get

$$
y =
\begin{cases}
y_0 + \frac{\sigma}{\kappa} \left[ (\lambda_p T_R)^{\kappa} - 1 \right], && 
\kappa \neq 0 \\
y_0 + \sigma \log (\lambda_p T_R), && 
\kappa = 0
\end{cases}
$$ (eq:gpd-return)



:::{tip} Proof
:class: dropdown

In general, we can expand the RHS of the equation to include the CDF

$$
1 - 1/T_R = \exp \left( -t(y;\boldsymbol{\theta}) \right)
$$

and we can reduce this to be:

$$
-\log\left(1-1/T_R\right) = t(y;\boldsymbol{\theta})
$$

Finally, we can plug in the $\kappa \neq 0$ term to get

$$
\begin{aligned}
-\log\left(1-1/T_R\right) &= [1 + \kappa z]_+^{-1/\kappa} \\
\log\left[-\log\left(1-1/T_R\right)\right]&= -(1/\kappa)\log[1 + \kappa z] \\
\log(1+\kappa z) &= -\kappa\log\left[-\log\left(1-1/T_R\right)\right] \\
1+\kappa z &=\left[-\log\left(1-1/T_R\right)\right]^{-\kappa}  \\
\kappa z &= \left[\log\left(1-1/T_R\right)\right]^{\kappa}-1\\
z &= \frac{1}{\kappa}\left\{\left[\log\left(1-1/T_R\right)\right]^{\kappa}-1\right\} \\
\end{aligned}
$$

Now, we can plug in the normalization factor

$$
y = \mu + \frac{\sigma}{\kappa}\left\{\left[\log\left(1-1/T_R\right)\right]^{\kappa}-1\right\}
$$

We can do the same thing for $\kappa = 0$ term to get


$$
\begin{aligned}
-\log (1 - 1/T_R) &= \exp(-z) \\
\log \left(-\log(1 - 1/T_R)\right) &= - z \\
z &= - \log \left(-\log(1 - 1/T_R)\right) \\
\end{aligned}
$$

Now, we can plug in the normalization factor

$$
y = \mu - \sigma \log \left[ - \log \left(1 - 1/T_R \right) \right]
$$

:::



***
## Average Recurrence Interval

We can calculate the RP using equation [](eq:prob-ari).

$$
\exp(-1/\bar{T}) = 
\exp\left(
    -Pr[Y>y|Y>y_0]Pr[Y>y_0]
\right)
$$

Removing the exponential components, we are left with

$$
1/\bar{T} = 
Pr[Y>y|Y>y_0]Pr[Y>y_0]
$$

We assume that the occurrence of events over the threshold, $y_0$, is given by the Poisson process.

$$
\lambda_p = Pr[Y>y_0]
$$

We can calculate the RP using equation [](eq:prob-ari).
Practically, we set this to the survival function of the GEVD (equation [](eq:gpd-survival)).

$$
1/\bar{T} =
\lambda_p\boldsymbol{S}(y;\boldsymbol{\theta})=
\lambda_p\left(1-\boldsymbol{F}(y;\boldsymbol{\theta})\right)
$$ 

If we rearrange this equation, we get

$$
y_p := \boldsymbol{F}(y;\boldsymbol{\theta}) = 1 - 1 / (\lambda_p T_R)
$$

To make things simpler, we can simply use the quantile function in equation [](eq:gpd-quantile) and set the probability to 

$$
y_p = 1 - 1 / (\lambda_p \bar{T})
$$

However, if we expand this out, we get

$$
y =
\begin{cases}
y_0 + \frac{\sigma}{\kappa} \left[ (\lambda_p \bar{T})^{\kappa} - 1 \right], && 
\kappa \neq 0 \\
y_0 + \sigma \log (\lambda_p \bar{T}), && 
\kappa = 0
\end{cases}
$$ (eq:gpd-ari)

:::{tip} Proof
:class: dropdown

In general, we can expand the RHS of the equation to include the CDF

$$
\exp(-1/\bar{T}) = \exp \left( -t(y;\boldsymbol{\theta}) \right)
$$

and we can reduce this to be:

$$
1/\bar{T} = t(y;\boldsymbol{\theta})
$$

Finally, we can plug in the $\kappa \neq 0$ term to get

$$
\begin{aligned}
\bar{T} &= [1 + \kappa z]_+^{1/\kappa} \\
\kappa \log \bar{T} &= \log [ 1 + \kappa z] \\
1 + \kappa z &= \bar{T}^{\kappa} \\
z &= \frac{1}{\kappa}\left( \bar{T}^{\kappa}-1\right) \\
\end{aligned}
$$

Now, we can plug in the normalization factor

$$
y = \mu + \frac{\sigma}{\kappa}\left( \bar{T}^{\kappa}-1\right)
$$

We can do the same thing for $\kappa = 0$ term to get


$$
\begin{aligned}
1/\bar{T} &= \exp(-z) \\
z &= \log \bar{T}
\end{aligned}
$$

Now, we can plug in the normalization factor

$$
y = \mu + \sigma\log \bar{T}
$$

:::




***
## Reparameterization

In this instance, we are assuming that there is a threshold parameter, $y_0$.
We can write the reparameterization of the GPD in terms of the GEV distribution

$$
\begin{aligned}
\mu_{y_0} &= \mu + \frac{\sigma}{\kappa}\left(1 - \lambda_{y_0}^{\kappa} \right) && &&
\sigma_{y_0} =\sigma\lambda_{y_0}^{\kappa} && &&
\kappa\neq0 \\
\mu_{y_0} &= \mu - \sigma\ln\lambda_{y_0} && &&
\sigma_{y_0} =\sigma\lambda_{y_0}^{\kappa} && &&
\kappa=0 \\
\end{aligned}
$$

We can also re-parameterize the $\lambda_{y_0}$ in terms of the GPD and GEV parameters.

$$
\begin{aligned}
\lambda_{y_0} &=  \log
\left[ 1 + \kappa z \right]^{- \frac{1}{\kappa}}, && &&
z = (y - \mu_{y_0})/\sigma \\
\sigma_{y_0} &=\sigma + \kappa(y - \mu_{y_0}) \\
\kappa_{y_0} &= \kappa
\end{aligned}
$$ (eq:poisson-reparam-gev)


***
Lastly, we can do something similar like so

$$
\begin{aligned}
\log\lambda &=  - \frac{1}{\kappa}\ln
\left[ 1 + \kappa \frac{y_0 - \mu}{\sigma} \right] \\
\sigma_{y_0} &=\sigma + \kappa(y_0 - \mu) \\
\kappa_{y_0} &= \kappa
\end{aligned}
$$


There has also been a similar reparameterization found in

$$
\lambda = 1 - \exp 
\left\{ - h \left[ 1 + \kappa(y_0 - \mu)/\sigma\right]^{-1/\kappa}\right\}
$$

$$
\sigma_{y_0} = \log[\sigma + \kappa(y_0 - \mu)/\sigma]
$$

Similarly, another reparameterization is 

$$
\sigma_{y_0} = \sigma + \kappa (y_0 - \mu)
$$

***
### Background

$$
p(Y\leq y+y_0|Y>y_0) = 1 - \frac{1-F(y+y_0)}{1-F(y_0)}
$$

where $y>0$.
If we let $y_0\rightarrow\infty$, then this leads to an approximate family of distributions given by the GPD

***
### Marginal Survival Function

We are interested in the marginal probability of occurrence above an arbitrary maximum value, $y$.
We can write the joint distribution of both quantities to be factored as follows.

$$
p(Y>y,Y>y_0)=p(Y>y|Y>y_0)p(Y>y_0) 
$$

The first term is the rate of exceedences above some quantity $y$ given some threshold, $y_0$.
The second term is the probability that an event is above some threshold, $y_0$.
We could also describe it as the rate of exceedences above some threshold, $y_0$.

Let's define an arrival rate $\lambda$ to be the average number of events per year larger than a threshold, $y_0$.
This is analogous to a Poisson distribution.

$$
p(Y>y_0) := \text{Pois}(Y=k) 
$$

where $k$ is the number of occurrences within some period $T$.
We can write down this distribution as

$$
f(k;\lambda)= \frac{\lambda^k}{k!}e^{-\lambda}
$$


We know that the expected value is simply the parameter $\lambda$.

$$
\mathbb{E}\left[p(Y>y_0) \right] = \lambda
$$

We can calculate this approximately by summing the number of events, over the threshold, $y_0$, and then we divide them by the total number of events, $N_{y_0}$

$$
\hat{\lambda} = \frac{1}{N_{y_0}}\sum_{n=1}^{N_{y_0}} \boldsymbol{I}(y_n > y_0)
$$

To relate this back to our function, we would need the rate parameter $\lambda$ in units as events per year

$$
\lambda_{year}   = 
\lambda t \hspace{5mm} [\text{events}][\text{year}]^{-1}
$$

where $t$ is some conversion factor from whatever time unit to years.

