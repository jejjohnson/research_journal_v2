---
title: Generalized Extreme Value Distribution
subject: Machine Learning for Earth Observations
short_title: GEVD
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
\boldsymbol{\mu} &\in \mathbb{R} \\
\text{Scale}: && &&
\boldsymbol{\sigma} &\in \mathbb{R}^+ \\
\text{Shape}: && &&
\boldsymbol{\kappa} &\in \mathbb{R} \\
\end{aligned}
$$

***
## Probability Density Function

This is denoted as the probability that our rv $Y$ will be equivalent to some specific value

$$
p(Y=y) := f(y;\boldsymbol{\theta})
$$

We can define the probability density function

$$
\boldsymbol{f}(y;\boldsymbol{\theta}) = 
\frac{1}{\sigma}t\left(y;\boldsymbol{\theta}\right)^{\kappa+1}e^{-t\left(y;\boldsymbol{\theta}\right)}
$$

where the function $t(y;\boldsymbol{\theta})$ is defined as:

$$
\boldsymbol{t}(y;\boldsymbol{\theta}) = 
\begin{cases}
\left[ 1 + \kappa \left( \frac{y-\mu}{\sigma} \right)\right]^{-1/\kappa}, && \kappa\neq 0 \\
\exp\left(-\frac{y-\mu}{\sigma}\right), && \kappa=0
\end{cases}
$$

***
## Cumulative Distribution Function

This is denoted as the probability that our rv $Y$ will be less than or equal to some specific value $y$.

$$
p(Y\leq y) := F(y;\boldsymbol{\theta})
$$



We can define the cumulative density function

$$
\boldsymbol{F}(y;\boldsymbol{\theta}) = 
\exp
\left[ -\boldsymbol{t}(y;\boldsymbol{\theta}) \right]
$$

where the function $t(y;\boldsymbol{\theta})$ is defined as:

$$
\boldsymbol{t}(y;\boldsymbol{\theta}) = 
\begin{cases}
\left[ 1 + \kappa \left( \frac{y-\mu}{\sigma} \right)\right]^{-1/\kappa}_+, && \kappa\neq 0 \\
1 - \kappa\left(\frac{y-\mu}{\sigma}\right)^{1/\kappa}, && \kappa=0
\end{cases}
$$

***
## Survival Function

This is the probability that our value of interest $y$ is less than ...

$$
p(Y>y) := \boldsymbol{S}(y)
$$

We denote this as:

$$
\boldsymbol{S}_{GEVD}(y;\boldsymbol{\theta}) = 1 - \boldsymbol{F}(y;\boldsymbol{\theta})
$$

We can plug in the CDF function into this equation

$$
\boldsymbol{S}(y;\boldsymbol{\theta}) = 
1 - \exp
\left[ -\boldsymbol{t}(y;\boldsymbol{\theta}) \right]
$$

where the function $t(y;\boldsymbol{\theta})$ is defined as:

$$
\boldsymbol{t}(y;\boldsymbol{\theta}) = 
\begin{cases}
\left[ 1 + \kappa \left( \frac{y-\mu}{\sigma} \right)\right]^{-1/\kappa}, && \kappa\neq 0 \\
1 - \kappa\left(\frac{y-\mu}{\sigma}\right)^{1/\kappa}, && \kappa=0
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
\mu + \frac{\sigma}{\kappa}\left[ \left(-\ln y_p \right)^{-\kappa} - 1 \right] && \kappa\neq 0 \\
\mu - \sigma \ln \left( -\ln y_p \right) && \kappa=0
\end{cases}
$$

:::{tip} Code Snippet
:class: dropdown

We can create an likelihood function for the quantile function where $\kappa\neq 0$.

```python
# function for kappa > 0
def quantile(, loc, scale, shape):
    level = loc - scale / shape * (1 - (- log(1 - p)) ** (- shape))
    return level
```


We can also create a quantile function where $\kappa=0$.
```python
# function for kappa = 0
def quantile(p, loc, scale):
    level = loc - scale * log(- log())
    return level
```

:::



***
## Joint Distribution

We can write the likelihood that the observations, $y$, follow the GEVD distribution.
So, given some observations, $\mathcal{D}=\{y_n\}_{n=1}^{N}$, which we believe follow the GEVD distribution, we can write the joint distribution decomposition as

$$
p(y_{1:N};\boldsymbol{\theta}) =
p(\boldsymbol{\theta})
\prod_{n=1}^N
p(y_n|\boldsymbol{\theta})
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

Recall the PDF for our iid samples is

$$
p(y_{1:N}|\boldsymbol{\theta}) = \prod_{n=1}^N\frac{1}{\sigma}t\left(y_n;\boldsymbol{\theta}\right)^{\kappa+1}e^{-t\left(y_n;\boldsymbol{\theta}\right)}
$$

We can add the log term to get

$$
\log p(\boldsymbol{y}_{1:N}|\boldsymbol{\theta}) = \sum_{n=1}^N \log p(y_n|\boldsymbol{\theta})
$$

which reduces to

$$
\log p(\boldsymbol{y}_{1:N}|\boldsymbol{\theta}) =
- N \log \sigma -
(1+1/\kappa)\sum_{n=1}^N 
\log \left( 1 + \kappa z_n\right)
- 
\sum_{n=1}^N 
\left( 1 + \kappa z_n\right)^{-1/\kappa}
$$



:::{tip} Code Snippet
:class: dropdown

We can create an likelihood function for this.

```python
def gev_logpdf(x, location, scale, shape):
    # calculate location scale: z=(y−μ​)/σ
    z = (x - mu) / sigma
    # calculate t(z) = 1+κz
    t = 1.0 + shape * z
    # term 1: −log σ
    t1 = - np.log(sigma)
    # term 2: − (1+κz) ** −1/κ
    t2 = - np.power(t, -1.0 / xi)
    # term 3: - (1+1/κ)log(1+κz)
    t3 = - (1.0 / xi + 1.0) * np.log(t) 
    return  t1 + t2 + t3
```

Instead of actually calculating the full scheme, we can simply apply this

```python
y: Array["T"] = ...
params: PyTree = ...
# apply vectorized operation
nll: Array["T"] = vectorize(gev_logpdf, y, params)
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
p(y_n|\boldsymbol{\theta}) = \frac{1}{\sigma}t\left(y_n;\boldsymbol{\theta}\right)^{\kappa+1}e^{-t\left(y_n;\boldsymbol{\theta}\right)}
$$

Now, we apply the log function 

$$
\log p(y_n|\boldsymbol{\theta}) = \log 
\left(\frac{1}{\sigma}t\left(y_n;\boldsymbol{\theta}\right)^{\kappa+1}e^{-t\left(y_n;\boldsymbol{\theta}\right)}\right)
$$

We can separate each of the terms

$$
\log p(y_n|\boldsymbol{\theta}) = \log 
\left(\frac{1}{\sigma}\right) + 
\log\left(t\left(y_n;\boldsymbol{\theta}\right)^{\kappa+1}\right) +
\log \left(e^{-t\left(y_n;\boldsymbol{\theta}\right)}\right)
$$

Now we can do some log rules to simplify the terms

$$
\log p(y_n|\boldsymbol{\theta}) = 
-\log \sigma + 
(\kappa+1) \log t\left(y_n;\boldsymbol{\theta}\right)
- t\left(y_n;\boldsymbol{\theta}\right) 
$$

We can plug in the $\boldsymbol{t}(y;\boldsymbol{\theta})$ to get a complete form.
Let $z=\frac{y-\mu}{\sigma}$

$$
\log p(y_n|\boldsymbol{\theta}) = 
-\log \sigma + 
(\kappa+1) \log \left( 1 + \kappa z\right)^{-1/\kappa}
- \left( 1 + \kappa z\right)^{-1/\kappa}
$$

We can do some final simplification

$$
\log p(y_n|\boldsymbol{\theta}) = 
-\log \sigma - 
(1+1/\kappa)\log \left( 1 + \kappa z_n\right)
- \left( 1 + \kappa z_n\right)^{-1/\kappa}
$$

Now, we can plug in the sum

$$
\log p(\boldsymbol{y}_{1:N}|\boldsymbol{\theta}) =
\sum_{n=1}^N 
\left(
-\log \sigma - 
(1+1/\kappa)\log \left( 1 + \kappa z_n\right)
- \left( 1 + \kappa z_n\right)^{-1/\kappa}
\right)
$$

We can factor out the constant values

$$
\log p(\boldsymbol{y}_{1:N}|\boldsymbol{\theta}) =
- N \log \sigma -
(1+1/\kappa)\sum_{n=1}^N 
\log \left( 1 + \kappa z_n\right)
- 
\sum_{n=1}^N 
\left( 1 + \kappa z_n\right)^{-1/\kappa}
$$


:::


***
## Reparameterization

In this instance, we are assuming that there is a threshold parameter, $y_0$.
We can write the reparameterization of this distribution as

$$
\begin{aligned}
\mu &= y_0 + \frac{\sigma_{y_0}}{\kappa}\left(1 - \lambda^{-\kappa} \right) && &&
\sigma =\sigma_{y_0}\lambda^{-\kappa} && &&
\kappa\neq0 \\
\mu &= y_0 + \sigma_{y_0}\ln\lambda && &&
\sigma =\sigma_{y_0} && &&
\kappa=0 \\
\end{aligned}
$$

#### Joint Distribution

Now, we can write the joint distribution which is


***
## Rescaling

$$
\delta_h = \frac{h}{h^*}
$$

where $h$ is in years and $h^*$ is in days.
We can write all of the parameters with these rescaled ones

$$
\begin{aligned}
\mu^* &= \mu + \frac{1}{\kappa}\left[\sigma^*(1-\delta_h^{-\kappa}) \right] \\
\sigma^* &= \sigma\delta_h^{\kappa} \\
\kappa^* &= \kappa
\end{aligned}
$$

