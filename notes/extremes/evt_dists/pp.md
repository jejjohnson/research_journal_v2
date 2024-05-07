---
title: Point Processes
subject: Machine Learning for Earth Observations
short_title: PP
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


## Counting Process

$$
\begin{aligned}
N(A) 
&= \#\left\{n\in\mathbb{N}^+: T_n \in A \right\} \\
&= \sum_{n=1}^\infty \boldsymbol{1}
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
### Lifetime Distribution Function

$$
F(t) = Pr[T\leq t] = 1 - S(t)
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
### Probability Density Function

We can write the conditional probability density function in terms of the hazard and cumulative hazard function

$$
f^*(t) = \lambda^*(t) \exp\left( -\Lambda(T) \right) = \lambda^*(t)S^*(t)
$$

We can also write it using the hazard function and the survival function

$$
f^*(t) =  \lambda^*(t)S^*(t)
$$

And lastly, we can write it in terms of the hazard function and the CDF function.

$$
f^*(t) =  \lambda^*(t)\left(1-F^*(t)\right)
$$


***
## Temporal Point Process

These are processes that are concerned with modeling sequences of random events in continuous time.
Let's say we have a sequence

$$
\begin{aligned}
\mathcal{H} &= \left\{ t_n \right\}_{n=1}^{N} && &&
t_n\in\mathcal{T}\subseteq \mathbb{R}^+
\end{aligned}
$$

We will also use the notation of the *historical events* predating time, $t$.

$$
\mathcal{H}_t = \left\{t_n|t_n < t,t_n\in \mathcal{H} \right\}
$$

Lastly, we will define the *conditional intensity function* (aka the hazard function) as

$$
\boldsymbol{\lambda} (t|\mathcal{H}_t) = 
\underset{\Delta t\downarrow 0}{\lim}
\frac{p(t_n\in [t,t+\Delta t]|\mathcal{H}_t)}
{\Delta t} =
\frac{\mathbb{E}\left[ N(\Delta t) |\mathcal{H}_t\right]}{\Delta t}
$$

where $\Delta t$ is the infinitesimal time interval containing $t$.

We will use the common shorthand to denote the conditional dependence on the historical dataset $\mathcal{H}_t$.

$$
\lambda^*(t) = 
\boldsymbol{\lambda}(t|\mathcal{H}_t)
$$

Finally, we can write out the joint log-likelihood of observing $\mathcal{H}$ within a time interval $\mathcal{T} = [0,T]$ which is given by 

$$
\log p(\mathcal{H}) = 
\sum_{n=1}^N\log \lambda^*(t_n) -
\int_0^T \lambda^*(\tau)d\tau
$$

We can also shorten the notation by introducing the cumulative hazard function as

$$
\Lambda^*(\mathcal{T}) = \int_{0}^T\lambda^*(\tau)d\tau
$$

This will leave us with
$$
\log p(\mathcal{H}) = 
\sum_{n=1}^N\log \lambda^*(t_n) -
\Lambda^*(\mathcal{T})
$$


:::{tip} Example I - Homogeneous Poisson Process
:class: dropdown

In this case, we have a dataset of number of exceedances along a timeline.

$$
\mathcal{H} = \left\{ t_n\right\}_{n=1}^{N_T}
$$

We have a vector which has the counts per unit time.
Let's let our intensity function $\lambda^*(t)$ be a constant parameter with no dependence on time.

$$
\lambda^*(t) = \lambda
$$

This means that our cumulative Hazard function, $\Lambda^*(\mathcal{T})$, will also not depend on any of the historical events and it will be constant with time.

$$
\begin{aligned}
\Lambda(\mathcal{T}) &= \int_{0}^T\lambda^*(\tau)d\tau =
 \int_0^T \lambda d\tau = (T-0) \lambda =
 \lambda T
\end{aligned}
$$

So, we can plug these two quantities into our log likelihood function

$$
\begin{aligned}
\log p(\mathcal{H}) &= 
\sum_{n=1}^N\log\lambda^*(t_n) - \Lambda^*(\mathcal{T})
\\
&= \sum_{n=1}^N\log \lambda - \lambda T \\
&= N\log\lambda - \lambda T
\end{aligned}
$$

:::

:::{tip} Example II - Inhomogeneous Poisson Process
:class: dropdown

In this case, we have a dataset of number of exceedances along a timeline.

$$
\mathcal{H} = \left\{ t_n\right\}_{n=1}^{N_T}
$$

We have a vector which has the counts per unit time.
Let's let our intensity function $\lambda^*(t)$ be a function parameter with dependence on time but no dependence on any historical events.

$$
\lambda^*(t) = \lambda(t)
$$

This means that our cumulative Hazard function, $\Lambda^*(\mathcal{T})$, will also not depend on any of the historical events but it will depend on time.

$$
\begin{aligned}
\Lambda(\mathcal{T}) &= \int_{0}^T\lambda^*(\tau)d\tau =
 \int_0^T \lambda(\tau) d\tau
\end{aligned}
$$

So, we can plug these two quantities into our log likelihood function

$$
\begin{aligned}
\log p(;\boldsymbol{\theta}|\mathcal{H}) &= 
\sum_{n=1}^N\log\lambda(t_n) - \Lambda^*(\mathcal{T})
\\
&= \sum_{n=1}^N\log \lambda(t_n;\boldsymbol{\theta}) -  \int_0^T \lambda(\tau;\boldsymbol{\theta}) d\tau
\end{aligned}
$$

There are a number of parametric equations we could use for the $\lambda(t;\boldsymbol{\theta})$.
We could use a log-linear model, a cox process or a Hawkes process to name a few.
The game is to 1) use a simple parametric function that has a closed form integral form, or 2) use a more complex parametric function and approximate the integral using quadrature or discretization strategies.

:::






<!-- #### Linear

The classic is the log-linear model which enables one to incorporate time dependencies within the model.


$$
\log \lambda (t) = w t + b, \hspace{2mm} t \geq 0
$$

#### Self-Correcting Models -->





***
## Marked Temporal Point Process

These are processes that are concerned with modeling sequences of random events in continuous time along with some additional meta-data, i.e., marks.
Marks can be whatever type of meta-data we have available.
For example, we could have some magnitude, e.g., temperature, Earthquake magnitude.
We could also have some spatial information, i.e., latitude, longitude, and/or altitude.

Firstly, we will have some underlying process which is dependent upon time

$$
\begin{aligned}
y_n &= y(t_n) && &&
y:\mathbb{R}^+\rightarrow \mathbb{R}^{D_y} && &&
t_n\in\mathcal{T}\subseteq \mathbb{R}^+
\end{aligned}
$$

Let's say we have a sequence of time stamps, $t_n$, and their associated marks, $y$.
This is given as a sequence of events

$$
\begin{aligned}
\mathcal{H} &= \left\{ t_n, y_n \right\}_{n=1}^{N}
\end{aligned}
$$

We will also use the notation of the *historical events* predating time, $t$.

$$
\mathcal{H}_t = \left\{(t_n,y_n)|t_n < t,t_n\in \mathcal{H} \right\}
$$

Lastly, we will define the *conditional intensity function*

$$
\lambda (t|\mathcal{H}_t) = 
\underset{\Delta t\downarrow 0}{\lim}
\frac{p\left((t_n,y_n)\in [t,t+\Delta t]|\mathcal{H}_t\right)}
{\Delta t}
$$

We will use the common shorthand to denote the conditional dependence on the historical dataset $\mathcal{H}_t$.

$$
\boldsymbol{\lambda}^*(t,y) = 
\boldsymbol{\lambda}(t,y|\mathcal{H}_t)
$$

We can write out the joint density as an autoregressive probability where the arrival time, $t_n$, and the mark, $y_n$, is conditioned upon the history.

$$
p_n^*(t,y) = p(t,y|(t_1, y_1), (t_2, y_2), \ldots, (t_{n-1}, y_{n-1}))
$$

We can decompose this joint intensity measure into its conditional dependencies, i.e., the mark depends on the time. 

$$
p_n^*(t,y) =  p_n(y|t_n=t) \cdot p_n^*(t)
$$

The term, $p_n^*(y|t_n=t)$ is either a probability density function or a probability mass function depending upon whether the marks are continuous or discrete.
Now, we can write the conditional intensity for the marked TPP as

$$
\boldsymbol{\lambda}^*(t,y) = f^*(y|t) \cdot \lambda^*(t)
$$

where $\lambda^*(t)$ is the *ground intensity* and $f^*(y|t)$ is the conditional mark density function.
Notice how the arrival times $\lambda^*(t)$ are similar to the unmarked case except that now this intensity measure may depend on past marks.

Finally, we can write out the joint log-likelihood of observing $\mathcal{H}$ within a time interval $\mathcal{T} = [0,T]$ which is given by 

$$
\log p(\mathcal{H}) = 
\sum_{n=1}^N\log \lambda^*(t_n) +
\sum_{n=1}^N\log f^*(y_n|t_n) -
\int_0^T \lambda^*(\tau)d\tau
$$ (eq:mtpp-nll)

:::{tip} Joint Intensity Function
:class: dropdown
Notice that this decomposition is very similar to the joint distribution decomposition.
Let's say we have $y_n$ and $t_n$ composed as a joint distribution which we factorize as follows.

$$
p(t_n,y_n) = p(y_n|t_n)p(t_n)
$$

As shown above, we can decompose the joint intensity function into it's conditional parts

$$
\lambda^*(t,y) = \lambda^*(t)f^*(y|t)
$$

Using some rules from survival analysis, we can rewrite this using only PDFs and CDFs.

$$
\begin{aligned}
\lambda^*(t)f^*(y|t) &= 
\frac{f(t|\mathcal{H}_t)}{1-F\left(t|\mathcal{H}_t\right)} f^*(y|t) \\
&=  
\frac{f(t|\mathcal{H}_t)}{1-F\left(t|\mathcal{H}_t\right)} f(y|\mathcal{H}_t) \\
&= \frac{f(t,y|\mathcal{H}_t)}{1-F\left(t|\mathcal{H}_t\right)}
\end{aligned}
$$

where $f(t,y|\mathcal{H}_t)$ is the joint density (in a broad sense) of the time, $t$, and mark, $y$, conditioned on the past times and marks.
The term $F(t,y|\mathcal{H})$ is the conditional CDF of $t$ also conditioned on the past times and marks.

We can simplify this even more by considering the survival function $S^*(t)=1-F^*(t)$
$$
\lambda^*(t,y) = 
\frac{f^*(y|t)f^*(t)}{S^*(t)}
$$


:::

<!-- :::{tip} Example
:class: dropdown

We could say that our function is related as follows

$$
y_n  = f(t_n;\theta) + \epsilon_n,
\hspace{5mm}
\epsilon_n \sim \mathcal{N}(0,\sigma^2)
$$

This is equivalent to a Gaussian distribution

$$
y \sim \mathcal{N}(f(t_n;\theta), \sigma^2)
$$

::: -->



:::{tip} Example - Unconditional Extreme Events
:class: dropdown

{cite:t}`https://doi.org/10.1080/14697680500039613` showcased how one can utilize the GPD as a parametric distribution for the marks.
In this case, they assume a homogenous Poisson process for the temporal intensity function.
In other words, it is a constant term with no dependence on time or the history.

$$
\lambda^*(t) \approx \lambda(\boldsymbol{\theta}) =  \lambda
$$

So we can use the same expressions as the example in the TPP section.

However, they impose a parametric distribution for the marks.
In this case, they assume that there is no temporal dependency for the marks nor any historical dependency.

$$
f^*(y|t) \approx f(y;\boldsymbol{\theta})
$$

In this case, the PDF is the GPD given some threshold, $y_0$, we can write the PDF as

$$
\begin{aligned}
f(y;\boldsymbol{\theta}) &= \sigma^{-1}\left[ 1 + \kappa z\right]_+^{-\frac{1}{\kappa}-1} 
&& &&
1 + \kappa z > 0
&& &&
\kappa \neq 0 
\end{aligned}
$$

where $z = (y - y_0) / \sigma$, $[1 + \kappa z_n]_+ = \text{max}(1 + \kappa z_n,0)$, and the parameters are $\boldsymbol{\theta} = \left\{ \mu,\kappa\right\}$.

So, putting all of this together, we can write out the expression for the log-likelihood of the conditional intensity function as seen in equation [](eq:mtpp-nll) as

$$
\begin{aligned}
\log p(\boldsymbol{\theta}|\mathcal{H}) &=
\sum_{n=1}^N\log \lambda +
\sum_{n=1}^N\log f(y_n;\boldsymbol{\theta}) -
\lambda T\\
&= 
N \log \lambda - \lambda T
+
\sum_{n=1}^N\log f(y_n;\boldsymbol{\theta})
\\
\end{aligned}
$$

We can plug in the log-likelihood for the GPD which we have done previously in equation [](eq:gpd_nll) to reduce the entire expression to

$$
\begin{aligned}
\log p(\boldsymbol{\theta}|\mathcal{H}) &= 
N \log \lambda - \lambda T
- N \log \sigma -
(1+1/\kappa)\sum_{n=1}^N 
\log \left[ 1 + \kappa z_n\right]_+
\\
\end{aligned}
$$

where the parameters, $\boldsymbol{\theta}$, are $\boldsymbol{\theta} = \left\{ \lambda, \mu,\kappa\right\}$.
In the literature, this is known as the Poisson-GPD which is a combination of an assumption that the events occur with a homogeneous Poisson process and the events magnitude are a GPD.

:::

:::{tip} Example - Unconditional Reparameterized Extreme Events
:class: dropdown


Like the unconditional case, they assume a homogenous Poisson process for the temporal intensity function.
In other words, it is a constant term with no dependence on time or the history.

$$
\lambda^*(t) \approx \lambda(\boldsymbol{\theta}) =  \lambda h 
\hspace{10mm} [\text{Event}][\text{Time}]^{-1}
$$
where $\lambda$ is the constant rate and $h$ is some unit of time, e.g., Years.
So we can use the same expressions as the example in the TPP section.

However, they impose a parametric distribution for the marks.
In this case, they assume that there is no temporal dependency for the marks nor any historical dependency.

$$
f^*(y|t) \approx f(y;\boldsymbol{\theta})
$$

In this case, the PDF is the GPD given some threshold, $y_0$, we can write the PDF as

$$
\begin{aligned}
f(y;\boldsymbol{\theta}) &= \sigma^{-1}\left[ 1 + \kappa z\right]_+^{-\frac{1}{\kappa}-1} 
&& &&
1 + \kappa z > 0
&& &&
\kappa \neq 0 
\end{aligned}
$$

where $z = (y - y_0) / \sigma$, $[1 + \kappa z_n]_+ = \text{max}(1 + \kappa z_n,0)$, and the parameters are $\boldsymbol{\theta} = \left\{ \mu,\kappa\right\}$.

So, putting all of this together, we can write out the expression for the log-likelihood of the conditional intensity function as seen in equation [](eq:mtpp-nll) as

$$
\begin{aligned}
\log p(\boldsymbol{\theta}|\mathcal{H}) &=
\sum_{n=1}^N\log \lambda +
\sum_{n=1}^N\log f(y_n;\boldsymbol{\theta}) -
\lambda T\\
&= 
N \log \lambda - \lambda T
+
\sum_{n=1}^N\log f(y_n;\boldsymbol{\theta})
\\
\end{aligned}
$$

We can plug in the log-likelihood for the GPD which we have done previously in equation [](eq:gpd_nll) to reduce the entire expression to

$$
\begin{aligned}
\log p(\boldsymbol{\theta}|\mathcal{H}) &= 
N \log \lambda - \lambda T
- N \log \sigma -
(1+1/\kappa)\sum_{n=1}^N 
\log \left[ 1 + \kappa z_n\right]_+
\\
\end{aligned}
$$

where the parameters, $\boldsymbol{\theta}$, are $\boldsymbol{\theta} = \left\{ \lambda, \mu,\kappa\right\}$.
In this case, we are going to reparameterize this loss function with the GEVD distribution.
We are given the translations as

$$
\begin{aligned}
\text{Rate}: && &&
\lambda &=  
\left[ 1 + \kappa \frac{y_0 - \mu}{\sigma} \right]^{- \frac{1}{\kappa}} \\
\text{Log Rate}: && &&
\log\lambda &=  
- \frac{1}{\kappa}\log
\left[ 1 + \kappa \frac{y_0 - \mu}{\sigma} \right] \\
\text{Scale}: && &&
\sigma_{y_0} &=
\sigma + \kappa(y_0 - \mu) \\
\text{Shape}: && &&
\kappa_{y_0} &= \kappa \\
\end{aligned}
$$

These are the parameters of the reparameterized distribution.
We can plug these components into the log-likelihood loss function to obtain

$$
\begin{aligned}
\log p(\boldsymbol{\theta}|\mathcal{H}) &= 
\frac{N}{\kappa}\log
\left[ 1 + \kappa \frac{y_0 - \mu}{\sigma} \right] \\
&- T \left[ 1 + \kappa \frac{y_0 - \mu}{\sigma} \right]^{- \frac{1}{\kappa}} \\
&- N \log \left[ \sigma + \kappa(y_0 - \mu) \right] \\
&-
(1+1/\kappa)\sum_{n=1}^N 
\log \left[ 1 + \kappa z_n\right]_+
\\
\end{aligned}
$$

where $z_n = (y_n - y_0)/(\sigma + \kappa(y_0 - \mu))$.


We can make this a bit neater by introducing a masking variable, $\boldsymbol{m}$.
This variable acts as an indicator variable

$$
m_n = 
\begin{cases}
1, && y > y_0 \\
0, && y \leq 0
\end{cases}
$$

Now, we can use this indicator variable to mask the likelihood function to zero if the observed value at the temporal resolution is above or below the threshold, $y_0$.

$$
\begin{aligned}
\log p(y_n|\boldsymbol{\theta}) &= 
\frac{m_n}{\kappa}\log
\left[ 1 + \kappa \frac{y_0 - \mu}{\sigma} \right] \\
&- T \left[ 1 + \kappa \frac{y_0 - \mu}{\sigma} \right]^{- \frac{1}{\kappa}} \\
&- m_n \log \left[ \sigma + \kappa(y_0 - \mu) \right] \\
&-
m_n(1+1/\kappa)\sum_{n=1}^N 
\log \left[ 1 + \kappa z_n\right]_+
\\
\end{aligned}
$$


:::


:::{tip} Example - Conditional Extreme Events
:class: dropdown


Like the unconditional case, they assume a homogenous Poisson process for the temporal intensity function.
In other words, it is a constant term with no dependence on time or the history.

$$
\lambda^*(t) \approx \lambda(\boldsymbol{\theta}) =  \lambda
$$

So we can use the same expressions as the example in the TPP section.

However, they impose a conditional parametric distribution for the marks.
In this case, they assume that there is no temporal dependency for the marks nor any historical dependency.

$$
f^*(y|t) \approx f(y;\boldsymbol{\theta}_t)
$$

where the parameters are time dependent

$$
\boldsymbol{\theta}_t = \boldsymbol{\theta}(t)
$$

In this case, the PDF is the GPD given some threshold, $y_0$, we can write the PDF as

$$
\begin{aligned}
f(y_t|\boldsymbol{\theta}_t) &= \sigma_t^{-1}\left[ 1 + \kappa z_t\right]_+^{-\frac{1}{\kappa}-1} 
&& &&
1 + \kappa z > 0
&& &&
\kappa \neq 0 
\end{aligned}
$$

where $z_t = (y - y_0) / \sigma_t$, $[1 + \kappa z_t]_+ = \text{max}(1 + \kappa z_t,0)$, and the parameters are $\boldsymbol{\theta}_t = \left\{ \sigma_t,\kappa\right\}$.
For this distribution, the scale parameter is time dependenent

$$
\begin{aligned}
\sigma_t := \sigma(t) &= \sigma_0 + \sigma_1 \psi(t)
\end{aligned}
$$

where $\psi(t)$ is some function which encodes time, e.g., linear, log-linear, Fourier, etc.
So, putting all of this together, we can write out the expression for the log-likelihood of the conditional intensity function as seen in equation [](eq:mtpp-nll) as

$$
\begin{aligned}
\log p(\boldsymbol{\theta}|\mathcal{H}) &=
\sum_{n=1}^{N_T}\log \lambda +
\sum_{t=1}^{N_T}\log f(y_t;\boldsymbol{\theta}_t) -
\lambda T\\
&= 
N \log \lambda - \lambda T
+
\sum_{t=1}^{N_T}\log f(y_t|\boldsymbol{\theta}_t)
\\
\end{aligned}
$$

We can plug in the log-likelihood for the GPD which we have done previously in equation [](eq:gpd_nll) to reduce the entire expression to

$$
\begin{aligned}
\log p(\boldsymbol{\theta}|\mathcal{H}) &= 
N \log \lambda - \lambda T
- N \log \sigma -
(1+1/\kappa)\sum_{t=1}^{N_t} 
\log \left[ 1 + \kappa z_t\right]_+
\\
\end{aligned}
$$

where $z_t=(y_n - y_0)/\sigma_t$ and the parameters, $\boldsymbol{\theta}_t$, are $\boldsymbol{\theta}_t = \left\{ \lambda, \sigma_t,\kappa\right\}$.
In the literature, this is known as the Poisson-GPD which is a combination of an assumption that the events occur with a homogeneous Poisson process and the events magnitude are a GPD.

:::





***
## Spatial Point Process

These are processes that are concerned with modeling sequences of random events in continuous space and time.
Let's say we have a sequence

$$
\begin{aligned}
\mathcal{H} &= \left\{ (t_n,\mathbf{s}_n) \right\}_{n=1}^N && &&
t_n\in\mathcal{T}\subseteq\mathbb{R}^+ && &&
\mathbf{s}_n\in\mathcal{\Omega}\subseteq\mathbb{R}^{D_s}
\end{aligned}
$$

We will also use the notation of the *historical events* predating time, $t$.

$$
\mathcal{H}_t = \left\{(t_n,\mathbf{s}_n)|t_n < t,t_n\in \mathcal{H} \right\}
$$

Lastly, we will define the *conditional intensity function*

$$
\lambda (t,\mathbf{s}|\mathcal{H}_t) = 
\underset{\Delta t\downarrow 0, \Delta \mathbf{s} \downarrow 0}{\lim}
\frac{p(t_n\in [t,t+\Delta t], \mathbf{s}_n \in \Omega(\mathbf{s},\Delta \mathbf{s})|\mathcal{H}_t)}
{|\Omega(\mathbf{s},\Delta \mathbf{s})|\Delta t}
$$

We will use the common shorthand to denote the conditional dependence on the historical dataset $\mathcal{H}_t$.

$$
\boldsymbol{\lambda}^*(t,\mathbf{s}) = 
\boldsymbol{\lambda}(t,\mathbf{s}|\mathcal{H}_t)
$$

Finally, we can write out the joint log-likelihood of observing $\mathcal{H}$ within a time interval $\mathcal{T} = [0,T]$ which is given by 

$$
\log p(\mathcal{H}) = 
\sum_{n=1}^N\log \boldsymbol{\lambda}^*(t_n,\mathbf{s}_n) -
\int_0^T \int_\mathcal{\Omega}\boldsymbol{\lambda}^*(\tau,\mathbf{s})d\mathbf{s}d\tau
$$


***
## Marked Spatiotemporal Point Process

A *marked spatiotemporal processes* that are concerned with modeling sequences of random events in continuous space and time which come with some underlying function for the marks.
Firstly, we will have some underlying process which is dependent upon time and space

$$
\begin{aligned}
y_n &= y(\mathbf{s}_n, t_n) && &&
y:\mathbb{R}^{D_s}\times\mathbb{R}^+\rightarrow \mathbb{R}^{D_y} && &&
\mathbf{s}_n\in\mathcal{\Omega}\subseteq\mathbb{R}^{D_s} && && 
t_n\in\mathcal{T}\subseteq \mathbb{R}^+
\end{aligned}
$$


Now, let's say we have a sequence

$$
\begin{aligned}
\mathcal{H} &= \left\{ (t_n,\mathbf{s}_n), y_n \right\}_{n=1}^N
\end{aligned}
$$

We will also use the notation of the *historical events* predating time, $t$.

$$
\mathcal{H}_t = \left\{(t_n,\mathbf{s}_n, y_n)|t_n < t,t_n\in \mathcal{H} \right\}
$$

Lastly, we will define the *conditional intensity function*

$$
\lambda (t,\mathbf{s},y|\mathcal{H}_t) = 
\underset{\Delta t\downarrow 0, \Delta \mathbf{s} \downarrow 0}{\lim}
\frac{p(t_n\in [t,t+\Delta t], \mathbf{s}_n \in \Omega(\mathbf{s},\Delta \mathbf{s}), y_n\in \mathcal{Y}|\mathcal{H}_t)}
{|\Omega(\mathbf{s},\Delta \mathbf{s})|\Delta t}
$$

We will use the common shorthand to denote the conditional dependence on the historical dataset $\mathcal{H}_t$.

$$
\boldsymbol{\lambda}^*(t,\mathbf{s},y) = 
\boldsymbol{\lambda}(t,\mathbf{s},y|\mathcal{H}_t)
$$

Finally, we can write out the joint log-likelihood of observing $\mathcal{H}$ within a time interval $\mathcal{T} = [0,T]$ and space interval $\mathcal{\Omega}$ which is given by 

$$
\log p(\mathcal{H}) = 
\sum_{n=1}^N\log \boldsymbol{\lambda}^*(t_n,\mathbf{s}_n) +
\sum_{n=1}^N\log \boldsymbol{f}^*(y_n|\mathbf{s}_n, t_n) -
\int_0^T \int_\mathcal{\Omega}\boldsymbol{\lambda}^*(\tau,\mathbf{s})d\mathbf{s}d\tau
$$




***
## Temporal Dependence

### Constant

We can use maximum likelihood to estimate the unknown parameters of the parametric distributions.

$$
L(\boldsymbol{\theta}) = 
\prod_{n=1}^{N_T} f(y_n) \prod_{n=1}^{N_T}S(y_n)
$$

We can rewrite this as a

$$
\log L(\boldsymbol{\theta}) = 
\sum_{n=1}^{N_T} \log f(y_n) -
\sum_{n=1}^{N_T}F(y_n)
$$

where $f$ is the PDF of some density function and $F$ is the CDF of some density function.

***
### Parametric


$$
\lambda^*(t,\mathbf{s}) = \boldsymbol{\mu}(t,\mathbf{s}) + \boldsymbol{g}(t,\mathbf{s})
$$

Typically, we can use some kernel function

$$
f(t|\boldsymbol{\theta}) = 
\sum_{n=1}^{N_s}
\mathbf{w}_n
\boldsymbol{k}(t,\boldsymbol{\theta}_n)
$$

where $\boldsymbol{k}$ is a kernel function (density function) with parameters $\boldsymbol{\theta}_n$.
The $\mathbf{w}_n$ are weights corresponding to the densities $\boldsymbol{k}(t,\boldsymbol{\theta}_n)$ and $\sum_{n=1}^{N_s}\mathbf{w}_n=1$.


***
### Kernel

A Hawkes Process is a process that has a background rate and a self-exciting term.
This term encourages more events to happen given past events.

$$
\boldsymbol{g}(t,\mathbf{s}) = g_t(t)\boldsymbol{g}_s(\mathbf{s})
$$

For this paper, they used a separable, parametric kernel function, i.e., a Hawkes kernel 
In particular, they used a Gaussian kernel in space and exponential in time.

$$
\boldsymbol{g}(t,\mathbf{s}) = 
\alpha\beta\exp(-\beta t)
\frac{1}{\sqrt{2\pi|\mathbf{\Sigma}|}}
\exp(-\mathbf{s}^\top\mathbf{\Sigma}^{-1}\mathbf{s})
$$

where $\alpha,\beta>0$ and $\mathbf{\Sigma}$ as a PSD matrix.

### Gaussian Process


This is also known as a Log-Gaussian Cox process.

$$
\log \boldsymbol{\mu}(t,\mathbf{s}) = 
\boldsymbol{f}_t(t) + 
\boldsymbol{f}_s(\mathbf{s})
$$

where $f$ is a realization from a Gaussian process

$$
\boldsymbol{f} \sim \mathcal{GP}(\boldsymbol{m_\theta},\boldsymbol{k_\theta})
$$

If we assume that our hazard function is a constant function

$$
h(t) = \lambda
$$

This implies that our survival function is

$$
S(t) = \exp(-\lambda t)
$$


## Approximating Integrals

Let's say we are given some pixel locations

$$
\mathcal{H} = \left\{\mathbf{s}_n \right\}_{n=1}^N
$$


### Quadrature

$$
\int_{\Omega}\boldsymbol{\lambda}(\mathbf{s})d\mathbf{s} \approx 
\sum_{n=1}^{N_s}\mathbf{w}_n\boldsymbol{\lambda}(\mathbf{s}_n)
$$

where $w_n>0$ and $\sum_{n=1}^Nw=|\Omega|$ and $\mathbf{s}_n=1,2,\ldots,N_s$ are all of the points in the domain, $\mathcal{\Omega}$.
This yields an approximation to the log likelihood as

$$
\log p(\mathcal{\Omega}) \approx
\sum_{n=1}^N\log \boldsymbol{\lambda}(\mathbf{s}_n)
-\sum_{n=1}^{N_s}\mathbf{w}_n\boldsymbol{\lambda}(\mathbf{s}_n)
$$

We have 3 sets of points:
* $N_s$ - the points within the discretized domain
* $N(\mathbf{s}_n)$ - the points within the discretized domain where we have events.
* $\bar{N}_s = N(\mathbf{s}_n)-N_s$ - the points in the discretized domain where there are no events.

{cite:t}`https://doi.org/10.2307/2347614` used the names design points, data points, and dummy points, respectively.

Let's create a mask vector which represents the case whether or not we observe an event within an element.

$$
\mathbf{m}_n =
\begin{cases}
1, && && N(\mathbf{s}_n) \geq 0 \\
0, && && N(\mathbf{s}_n) = 0
\end{cases}
$$

Now, we can rewrite the log-likelihood term to be

$$
\log p(\mathcal{\Omega}) \approx
\sum_{n=1}^{N_s}
\mathbf{w}_n
\left(
    \frac{\mathbf{m}_n}{\mathbf{w}_n}
    \log\boldsymbol{\lambda}(\mathbf{s}_n) -
    \boldsymbol{\lambda}(\mathbf{s}_n)
\right)
$$


***
### Pixel Counts

We can divide the domain, $\mathcal{\Omega}$, into small pixels of each area, $\omega$.
Then the integral over the domain, $\mathcal{\Omega}$, is approximated by summing over all of the pixels.

$$
\int_{\Omega}\lambda(\mathbf{s})d\mathbf{s} \approx 
\sum_{n=1}^{N_s}\omega_n\lambda(\mathbf{s}_n)
$$

where $s_n$ is the center of the $n$th pixel.
In this case, we discard the exact locations of the data points and we mark each data point with the center pixel.
To approximate the sum over data points, we can take the sum over pixels.

$$
\sum_n^N\log\lambda(\mathbf{s}_n) \approx 
\sum_{n=1}N(\mathbf{s}_n)\log \lambda(\mathbf{s}_n)
$$

where $N(s_n)$ is the number of data points falling into the $n$th pixel.
So we can take these two quantities and put them together to get

$$
\log p(\mathcal{\Omega}) \approx
\sum_{n=1}^N
\left(
    N(\mathbf{s}_n)\log \lambda(\mathbf{s}_n) 
    -
    \omega_n\lambda(\mathbf{s}_n)
\right)
$$