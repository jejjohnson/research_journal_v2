---
title: Background
subject: Machine Learning for Earth Observations
short_title: Background
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

## Probability Density Function

> The probability that a variate, $Y$, has the value $y$.

$$
Pr[Y=y] := f(y)
$$ (eq:pdf)


***
## Cumulative Distribution Function

> The probability that a variate, $Y$, takes a value less than or equal to $y$.

$$
Pr[Y \leq y] := F(y)
$$ (eq:cdf)

From a TPP perspective, this is known as the *lifetime* distribution.

$$
F(t) = Pr[T\leq t] = 1 - S(t)
$$

***
## Survival Function

> The probability that a variate, $Y$, takes a value greater than $y$. 
> In other words, this gives the probability that an event will happen past a value $y$, e.g., time.

$$
Pr[Y > y] = 1 - Pr[Y \leq y] = 1 - F(y) := S(y)
$$

From a TPP perspective, i.e., $S(t)$ where $t\in[0,\infty)$, we have the following properties:
1. The survival function is non-increasing.
2. At $t=0$, $S(t)=1$, i.e., the probability of surviving past time 0 is 1.
3. At $t=\infty$, $S(t=\infty)=0$, i.e., as time goes to infinity, the survival curve goes to 0.

In theory, the survival function is smooth.
However, in practice, we may observe events on a discrete scale.
For example, on a time scale we may have days, weeks, or months.

***
## Quantile Function

$$
y_p = Pr[Y\leq y]
$$ 

We can write this as the quantile function

$$
y = F^{-1}(y_p):= Q(y_p)
$$ (eq:quantile)

We often use this function to calculate the frequency estimation like the AEP or the ARI.

***
## Inverse Survival Function

This is the same as the quantile function given in equation [](eq:quantile) except we set the probability equal to the survival probability

$$
y_p = 1 - y_s
$$ (eq:prob-survival)

***
(sec:aep)=
## Annual Exceedence Probability

The recurrence interval is a measure of how often an event is expected to occur based on the probability of exceeding a given stage streshold.
This threshold is called the *annual exceedance probability*.
To calculate this, we can express the return period (in years) as

$$
R_a = R_a(T_a) = \frac{1}{T_a}
$$ (eq:prob-return)

where $R_a$ is the annual exceedence probability (AEP) and $T_a$ is the number of years {cite:p}`https://doi.org/10.1007/s11069-020-03968-z`.
The AEP is has a domain between 0 and 1, $R_a\in[0,1]$, and the return period, $T_a$, has a domain between 1 and infinity, $T_a\in[1,\infty)$.
This can be limiting when we consider sub-annual probabilities which would be elements less than 1. 
In addition, it can be incorrect when there is some wrong interpolation between 100 and 1.


:::{figure}
:label: fig:prob-return
:align: left

![](../assets/rp.png)

A figure showing the return period `[years]` vs the probability of exceedance, $R_a$.
:::

***
### Derivation

This section is based off of {cite:p}`https://doi.org/10.1007/s11069-020-03968-z; https://doi.org/10.1111/j.2517-6161.1990.tb01796.x`. Let $Y_t$ be an indicator variable that indicates whether in $(t,t+1]$, at least one event occurs or not

$$
Y_t =
\begin{cases}
1, && && \text{when }N_{t+1}-N_t >0 \\
0, && && \text{otherwise}
\end{cases}
$$

Then, $Y_t$ is a Bernoulli distribution with the probabilities

$$
F(t) = Pr[T\leq t] = 1 - S(t)
$$

***
### Usage


In practice, we can use this to calculate the return level given any arbitrary CDF function

$$
R_a = Pr[Y > y] = 1 - Pr[Y \leq y] = 1 - F(y; \boldsymbol{\theta})
$$

Once we solve this for the quantity $y$ in terms of $R_p$.

$$
\frac{1}{T_a} = 1 - \boldsymbol{F}(y;\boldsymbol{\theta})
$$

After we simplify the expression, we get the following relationship

$$
y = \boldsymbol{F}^{-1}(y_p;\boldsymbol{\theta}) =
\boldsymbol{Q}(y_p;\boldsymbol{\theta})
$$

where $Q$ is the quantile function, i.e., the inverse CDF function, and $y_p = 1 - R_a = 1 - 1/T_a$.

***
(sec:ari)=
## Average Recurrence Interval

The average recurrence interval (ARI) is the average time between events for a specified duration at a given location.
This term is associated with partial duration series (PDS) or peak-over-thresholds (POTs). 
This is also known as the Mean Inter-Arrival Time or the Mean Recurrence Interval.

$$
R_p = R_p(T_p) = 1 - \exp\left(- \frac{1}{T_p}\right)
$$ (eq:prob-ari)

where $T_p$ is the mean inter-arrival time measured in $years$ {cite:p}`https://doi.org/10.1007/s11069-020-03968-z`.

:::{figure}
:label: fig:prob-return
:align: left

![](../assets/ari.png)

A figure showing the average recurrence interval `[years]` vs the probability of recurrence, $R_p$.
:::

***
### Derivation

This section is based off of {cite:p}`https://doi.org/10.1007/s11069-020-03968-z`. We assume that we have a counting process, $N(A)$, which is a Poisson process with a rate of occurrence, $\lambda$.
Then the probability that there is at least 1 event in the time interval, $(0,T]$, is given as the survival function of the exponential distribution:

$$
Pr[N(A) \geq 1] = 1 - Pr[N(A)=0] = 1 - \exp \left(-\lambda\right)
$$

The mean inter-arrival time is given as

$$
\mathbb{E}[Y] = \frac{1}{\lambda} := \bar{T},
\hspace{10mm}
\bar{T}\in[0,\infty)
$$

The probability of at least 1 event  in the interval $(0,T]$ is given as

$$
Pr[N(A) \geq 1] = 1 - \exp \left(-T/ \bar{T}\right)
$$

and the probability that there is at least 1 event within 1 unit time interval is given as

$$
Pr[N(A) \geq 1] = 1 - \exp \left(-1/ \bar{T}\right)
$$

**Note**: we can extend this for distributions where we have multiple criteria. 
For example, in marked HPP, we could have a 2D Poisson process given over the domain

$$

$$


$$
\lambda(t,y) = \lambda f(y;\theta)
$$

So essentially, we state that

$$
Pr[Y>y|Y> y_0]Pr[Y>y_0] = \lambda \left(1 - F(y;\boldsymbol{\theta})\right)
$$


So, the probability of no exceedances of $y$ over a 1-year period is given by the Poisson distribution

$$
F_a(y) = \exp\left[ -\lambda S(y)\right]
$$

***
### Usage

In practice, we can use this to calculate the return level given any arbitrary CDF function

$$
R_T = Pr[Y > y] = 1 - Pr[Y \leq y] = 1 - F(y;\boldsymbol{\theta})
$$

Once we solve this for the quantity $y$ in terms of $R_T$, we get the following relationship

$$
y_T = \boldsymbol{Q}(y_p;\boldsymbol{\theta})
$$

where $Q$ is the quantile function, i.e., the inverse CDF function, and $y_p = 1 - R_T = \exp\left(-1/T_p\right)$.

***
## AEP vs ARI

There are some equivalences of these two quantities. 
Namely, we can write this as:

$$
\begin{aligned}
R_p &= R_a \\
\frac{1}{T_a} &= 1 - \exp\left(- \frac{1}{T_p}\right)
\end{aligned}
$$

[](fig:aep-vs-pr) showcases the AEP vs the probability of recurrence.
We see that they are almost the same except for near the upper tail.
[](fig:rp-vs-ari) demonstrates the relationship better.
We see that the ARI has the domain between $T_p \in [0, \infty)$ whereas the RP has the domain between $R_p \in [0, \infty)$.
So, there is a relationship between the two quantities but they are not the same due to the differences in the domain.

::::{tab-set}

:::{tab-item} Probabilities
:::{figure}
:label: fig:aep-vs-pr
:align: left

![](../assets/aep_vs_pr.png)

A figure showing the probability of occurrence, $R_a$, vs the probability of exceedence, $R_p$.
:::

:::{tab-item} Periods
:::{figure}
:label: fig:rp-vs-ari
:align: left

![](../assets/ari_vs_rp.png)

A figure showing the average recurrence interval, $T_p$, `[years]` vs the return period, $T_a$`[years]`. 
:::

::::


***
## Hazard Function

> The ratio of probability density function to the survival function, aka the conditional failure density function.

$$
H(y) = \int_{-\infty}^yh(\tau)d\tau = -\log\left(1-F(y)\right)=- \log S(y)
$$

## Counting Process

$$
\begin{aligned}
N(A) 
&= \#\left\{n\in\mathbb{N}^+: T_n \in A \right\} \\
&= \sum_{n=1}^\infty \mathcal{1}
(T_n \in A)
\end{aligned}
$$

***
### Survival Function

This is the probability that the time of death is later than some specified time, $t$.

$$
S(t) = Pr[T>t] = \int_t^\infty f(\tau)d\tau = 1 - F(t)
$$

***
### Event Density

This is the rate of death/failure events per unit time

$$
f(t) = F'(t) = \frac{d}{dt}F(t)
$$

***
### Survival Event Density

$$
\begin{aligned}
s(t) &= S'(t) = \frac{d}{dt}S(t) \\
&= \frac{d}{dt}\int_t^\infty f(\tau)d\tau \\
&= \frac{d}{dt}\left[1 - F(t) \right] \\
&= - f(t)
\end{aligned}
$$

***
### Conditional Intensity Function

This is the instantaneous rate of a new arrival of new events at time, $t$, given a history of past events, $\mathcal{H}_t$. 
This is also known as the hazard function.

$$
\lambda^*(t) = \frac{f^*(t)}{1-F^*(t)}
$$

We can rewrite this using th relationship of the survival function

$$
\lambda^*(t) = \frac{f^*(t)}{S^*(t)}
$$

We can also rewrite this using the relationship between the survival function and the cumulative hazard function

$$
\lambda^*(t) = \frac{f^*(t)}{\exp\left( -\Lambda(\mathcal{T}) \right)}
$$

***
### Cumulative Hazard Function

In general, there are four properties it needs to satisfy

$$
\begin{aligned}
\Lambda^*(t) &> 0  \\
\Lambda^*(t_n) &= 0 \\
\lim_{t\rightarrow \infty} \Lambda^*(t) &= \infty \\
\frac{d \Lambda^*(t)}{dt} &> 0
\end{aligned}
$$

This is achieved by always having a positive outcome within hazard function parameterization. 

***
### Probability Density Function

We can write the conditional probability density function in terms of the hazard and cumulative hazard function

$$
f^*(t) = \lambda^*(t) \exp\left( -\Lambda(T) \right) = \lambda^*(t)S^*(t)
$$ (eq:tpp-density)

We can also write it using the hazard function and the survival function

$$
f^*(t) =  \lambda^*(t)S^*(t)
$$ (eq:tpp-density-survival)

And lastly, we can write it in terms of the hazard function and the CDF function.

$$
f^*(t) =  \lambda^*(t)\left(1-F^*(t)\right)
$$ (eq:tpp-density-cdf)
