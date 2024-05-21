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


> In this section, we look at point processes (PP).
> In particular, we will use point processes to outline the framework for how we can jointly model extreme event occurrences and magnitudes.
> We will start with temporal point processes which will address extreme event occurrences. 
> Then we will go into marked temporal point processes which will incorporate magnitudes.
> finally we will add the spatial component.


***
## Temporal Point Process

These are processes that are concerned with modeling sequences of random events in continuous time.
Let's say we have an ordered sequence of events at time $t$. 
We denote this as

$$
\begin{aligned}
\mathcal{H} &= \left\{ t_n \right\}_{n=1}^{N} && &&
t_n\in\mathcal{T}\subseteq \mathbb{R}^+
\end{aligned}
$$ (eq:data-sequence)

Typically, $\mathcal{T}=(0,T]$, but it can be between any two arbitrary time endpoints, e.g., $\mathcal{T}=[t_0,t_1]$.
We will also use the notation of the *historical events* predating our time event of interest, $t$.
We denote this as

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
We can write out the conditional likelihood function as the probability that we observe an event of interest given all of the history as:

$$
p^*(\mathcal{H}) = ...
$$
This can be decomposed as
$$
p^*(\mathcal{H}) = \left(\prod_{n=1}^N\lambda^*(t)\right)
\exp\left(-\int_0^T\lambda^*(\tau)d\tau\right)
$$

***
### Learning

In general, we are interested in finding the best parameters of our model given access to potentially many sequences of events.
So naturally, we can simply maximize the log-likelihood.

$$
\boldsymbol{L}(\boldsymbol{\theta}) =
\underset{\boldsymbol{\theta}}{\argmax}
\hspace{2mm}
\sum_{n\in\mathcal{D}}\log p(\mathcal{H};\boldsymbol{\theta})
$$

We can write out the joint log-likelihood of observing $\mathcal{H}$ within a time interval $\mathcal{T} = (0,T]$ which is given by 

$$
\log p(\mathcal{H}) = 
\sum_{n=1}^N\log \lambda^*(t_n) -
\int_0^T \lambda^*(\tau)d\tau
$$

We can also shorten the notation by introducing the cumulative hazard function as

$$
\Lambda^*(\mathcal{T}) = \int_{0}^T\lambda^*(\tau)d\tau
$$ (eq:tpp-cumulative-hazard)

This will leave us with

$$
\log p^*(\mathcal{H}) = 
\sum_{n=1}^N\log \lambda^*(t_n) -
\Lambda^*(\mathcal{T})
$$ (eq:tpp-loglikelihood)

There are other alternatives to maximizing the log-likelihood.
In general, the loss function can look like

$$
\boldsymbol{L}(\boldsymbol{\theta}) =
\underset{\boldsymbol{\theta}}{\argmax}
\hspace{2mm}
\mathbb{E}_{x\sim p(x_n|{\boldsymbol{\theta}})}
\left[ \boldsymbol{f}(x)\right]
$$

where $x$ is described by some parametric distribution, $p(x_n|{\boldsymbol{\theta}})$, and $f$ is some criteria.
In the above example, our criteria is simply the log-likelihood function.
We can use some other generative modeling methods like:
1. GANs use a parametric model and the loss is some sample quality metric
2. reinforcement learning uses some policy and the loss is some reward function
3. variational inference uses some approximate posterior and the loss is the evidence lower bound.

***
### Usages

**Prediction**.
The first obvious use case is prediction.
In this case, we have some observed data over a period, $\mathcal{T}\in(0,T]$, and we would like to know what will happen in a forecast period, $\mathcal{T}_\tau \in (T,T+\tau]$.
1. How much time, $\tau_n$, until the next event?
2. What type of mark, $y_n$, of the next event?
3. How many events of the type, $y_n$, will happen?

We can even sample some potential trajectories of events of the future which helps to answer how many events could possibly happen.

**100-Year Events**.
If the marks distribution is parametric, we can do some post-analysis about the occurrence of events.
This can be done through the use of return periods (RPs) or average recurrence intervals (ARI).
See sections [](sec:aep) and [](sec:ari) for more details.


***
### Example I: Homogeneous Poisson Process (HPP)


In this case, we have a dataset of number of exceedances along a timeline as seen in equation [](eq:data-sequence).
Essentially, we have a vector, $\mathbf{t}$, which has the counts per unit time.
According to the traditional PP, we can define our assumptions as:
1. The number of events in any two disjoint intervals are independent
2. The number of events in any interval $[a,b]$ for $0\leq t_0 < t_1 \leq T$ follows a Poisson distribution with rate $\lambda(t_1-t_0)$.
3. The inter-event times are iid rv that follow the exponential distribution with a rate parameter, $\lambda$.

Following these assumptions, we say that our intensity function $\lambda^*(t)$ be a constant parameter with no dependence on time.

$$
\lambda^*(t) = \lambda
$$ (eq:hazard-constant)

This means that our cumulative Hazard function, $\Lambda^*(\mathcal{T})$, will also not depend on any of the historical events and it will be constant with time.
Plugging our terms into the cumulative hazard function in equation [](eq:tpp-cumulative-hazard)  results in

$$
\begin{aligned}
\Lambda(\mathcal{T}) &=
 \int_0^T \lambda d\tau = (T-0) \lambda =
 \lambda T
\end{aligned}
$$ (eq:cumulative-hazard-constant)

where $T$ is the interval of interest, e.g., number of years, $T_\text{years}$.
So, we can plug these two quantities into our log likelihood function in equation [](eq:tpp-loglikelihood) as

$$
\begin{aligned}
\log p(\mathcal{H}) &= \sum_{n=1}^N\log \lambda - \lambda T \\
&= N\log\lambda - \lambda T
\end{aligned}
$$ (eq:hpp-loglikelihood)

As mentioned above, the inter-arrival time is an exponential distribution.
Please see section ... for more details.

***
### Example II: Inhomogeneous Poisson Process


Also in this case, in this case, we have a dataset of number of exceedances along a timeline as seen in equation [](eq:data-sequence).
However, we let our intensity function $\lambda^*(t)$ be a function parameter with dependence on time but no dependence on any historical events.

$$
\lambda^*(t) = \lambda(t)
$$

This means that our cumulative Hazard function, $\Lambda^*(\mathcal{T})$, will also not depend on any of the historical events but it will depend on time.

$$
\begin{aligned}
\Lambda(\mathcal{T}) &= \int_{0}^T\lambda^*(\tau)d\tau =
 \int_0^T \lambda(\tau) d\tau
\end{aligned}
$$ (eq:tpp-cumulative-hazard)

So, we can plug these two quantities into our log likelihood function into the equation [](eq:tpp-loglikelihood)

$$
\begin{aligned}
\log p(;\boldsymbol{\theta}|\mathcal{H})
&= \sum_{n=1}^N\log \lambda(t_n) -  \Lambda^*(\mathcal{T}) \\
&= \sum_{n=1}^N\log \lambda(t_n) -  \int_0^T \lambda(\tau) d\tau
\end{aligned}
$$ (eq:ipp-loglikelihood)

The first term is the log-likelihood of the specific events at the specific location, $t_n$, that we observe them.
The second term is the probability that we do not observe them anywhere else within the time interval of interest.
The difficult part for this equation is the 2nd term which is an integral; however, there are many ways to deal with this. 
For example, we can use a parametric form for the intensity

$$
\lambda(t) \approx \lambda_{\boldsymbol{\theta}}(t)
$$

which would result in a closed-form integral.
For example, we could use a log-linear model, a cox process or a Hawkes process to name a few.
The game is to:
1. use a simple parametric function that has a closed form integral form 
2. use a more complex parametric function and approximate the integral using quadrature or discretization strategies.

See the section [](sec:evt-param-temporal) for more ideas of temporal parameterizations.

<!-- In addition, we can also recover the density function from equation [](eq:tpp-density).
This is given as

$$
f^*(t) = \lambda(t;\boldsymbol{\theta}) \exp(-\Lambda^*(\mathcal{T};\boldsymbol{\theta}))
$$ -->







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

From a PP perspective, we can model this as a 2D PP which results in

$$
A = \left\{
  [t_0, t_1]\times[y,\infty)
 \right\}
\hspace{10mm}
t\in\mathcal{T}\subseteq\mathbb{R}^+
\hspace{10mm}
y_0\in\mathcal{Y}\subseteq\mathbb{R}
$$ (eq:mpp-space)

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


 We can write out the joint log-likelihood of observing $\mathcal{H}$ within a time interval $\mathcal{T} = [0,T]$ which is given by 

$$
\log p^*(\mathcal{H}) = 
\sum_{n=1}^N\log \lambda^*(t_n,y_n) +
\int_0^T \lambda^*(\tau)d\tau
$$ (eq:mtpp-nll)

***
### Marks Parameterizations

Now, let's dive a bit into the marks distribution.
In general, we can model the marks in three ways: 1) conditionally independent, 2) conditioned on time, and 3) time conditioned on the marks.
These can be seen in these equations

$$
\begin{aligned}
\text{Conditionally Independent}: && &&
\lambda^*(t_n,y_n) &= \lambda_g^*(t_n)p^*(y_n) \\
\text{Temporal Conditioned Marks}: && &&
\lambda^*(t_n,y_n) &= \lambda_g^*(t_n)p^*(y_n|t_n) \\
\text{Marks Conditioned Time}: && &&
\lambda^*(t_n,y_n) &= \lambda^*(t_n|y_n) \\
\end{aligned}
$$

The first case, we say there is no dependence between the marks.
The second case gives us a more flexible parameterization of the marks which influences how the marks behave wrt time.
The third cases is the most flexible parameterization and frankly the most correct because we state that the occurrence of events is also conditioned on the marks.

There are some known special cases of these marks.
These include:
1. A compound Poisson process if $\lambda_g^*(t)=\lambda(t)$ and $f^*(y|t)=f(y|t)$ for deterministic functions $\lambda(t)$ and $f(y|t)$.
2. A process with independent marks if $\lambda_g^*(t)$ and $\mathcal{H}_g$-intensity and $f^*(y|t)=f(y|t)$
3. A process with unpredictable marks if $f^*(y|t)=f(y|t)$.

***
### Example III: MPP 4 Extremes


We have a marked point process where we represent it as a 2D point process as shown in equation [](eq:mpp-space) where we write the joint intensity function for the temporal plane and the mark plane.
However, we simplify it to be a parametric form.

$$
\lambda^*(t,y) = \boldsymbol{f}(y;\boldsymbol{\theta})
$$

where $f(y;\boldsymbol{\theta})$ is some parametric function in terms of the marks.
Now, it's easier to reason about the cumulative hazard function because it's an integral of some parametric PDF which has a closed-form double integral.

$$
\Lambda(A) =\int_0^T\int_y^\infty\lambda(\tau,y)dyd\tau
=\int_0^T\int_y^\infty \boldsymbol{f}(y;\boldsymbol{\theta})dyd\tau
$$

We recognize that the inner integral for the mark domain is simply the survival function, $\boldsymbol{S}$, of the parametric PDF, $\boldsymbol{f}$.

$$
\int_{y_0}^\infty\boldsymbol{f}(y;\boldsymbol{\theta})dy =
1 - \int_0^y\boldsymbol{f}(y;\boldsymbol{\theta})dy =
1 - \boldsymbol{F}(y_0;\boldsymbol{\theta}) :=
\boldsymbol{S}(y_0;\boldsymbol{\theta})
$$

We take the threshold of interest, $y_0$, to be the lower bound of the mark space.
So, the remaining outer integral on the temporal domain is a simple homogeneous Poisson process that was done previously in equation [](eq:tpp-cumulative-hazard).
Plugging our expression into this equation leaves us with

$$
\Lambda(A) = \int_0^T\boldsymbol{S}(y_0;\boldsymbol{\theta})d\tau
$$

Our final log-likelihood expression will be

$$
\log p^*(A) = 
\sum_{n=1}^{N(A)} \log \boldsymbol{f}(y;\boldsymbol{\theta}) -
\int_0^T \boldsymbol{S}(y_0;\boldsymbol{\theta})d\tau
$$

We can use whatever PDF we want for the marks, e.g., Normal, LogNormal, or T-Student.
However, in the literature for extreme values, we typically use the GPD or even the GEVD in some cases.

**Annual Exceedence Probabilities**. 
We can also do return periods where try to find the annual exceedence probability or the average recurrence interval. See sections [](sec:aep) and [](sec:ari) for more details. 
For our case, as shown in equations [](eq:prob-return) and [](eq:prob-ari) we equate these to our cumulative distribution function.
After solving for the respective $T_p$ and $T_a$, we arrive at

$$
\begin{aligned}
y &= \boldsymbol{Q}(y_p;\boldsymbol{\theta})
\end{aligned}
$$

where $\boldsymbol{Q}$ is the quantile function for the PDF/CDF and the probability in the $y$ domain, $y_p$. 

$$
\begin{aligned}
\text{Annual Exceedence Probability}: && &&
y_p &= 1 - 1 / T_a && &&
T_a\in[1,\infty)\\
\text{Average Recurrence Interval}: && &&
y_p &= \exp ( - 1 / T_p), && &&
T_p\in[0,\infty)
\end{aligned}
$$




***
## Decoupled Marked Temporal Point Process


We can decompose this joint intensity measure into its conditional dependencies, i.e., the mark depends on the time. 

$$
p_n^*(t,y) =  p_n(y|t_n=t) \cdot p_n^*(t)
$$

The term, $p_n^*(y|t_n=t)$ is either a probability density function or a probability mass function depending upon whether the marks are continuous or discrete.
Now, we can write the conditional intensity for the marked TPP as

$$
\boldsymbol{\lambda}^*(t,y) = \lambda_g^*(t) \cdot f^*(y|t)
$$

where $\lambda_g^*(t)$ is the *ground intensity* and $f^*(y|t)$ is the conditional mark density function.
Notice how the arrival times $\lambda_g^*(t)$ are similar to the unmarked case except that now this intensity measure may depend on past marks.

:::{tip} Proof: Joint Intensity Function
:class: dropdown
Notice that this decomposition is very similar to the joint distribution decomposition.
Let's say we have $y_n$ and $t_n$ composed as a joint distribution which we factorize as follows.

$$
p(t_n,y_n) = p(y_n|t_n)p(t_n)
$$

As shown above, we can decompose the joint intensity function into it's conditional parts

$$
\lambda^*(t,y) = \lambda_g^*(t)f^*(y|t)
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

Finally, we can write out the joint log-likelihood of observing $\mathcal{H}$ within a time interval $\mathcal{T} = [0,T]$ which is given by 

$$
\log p(\mathcal{H}) = 
\sum_{n=1}^N\log \lambda_g^*(t_n) 
-
\int_0^T \lambda_g^*(\tau)d\tau
+
\sum_{n=1}^N\log f^*(y_n|t_n) 
$$ (eq:dmtpp-nll)

The first two terms are the ground intensity likelihoods for the temporal rate and the third term is the marks likelihood.



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

***
### Example IV: MHPP 4 Extremes


In this example, we have a DMTPP for extremes.
We have a marked point process where we represent it as a 2D point process as shown in equation [](eq:mpp-space).
In this case, we decouple the intensity function as shown above section.
For the ground intensity, we have a HPP.
For the marks, we have iid parametric distribution

$$
\begin{aligned}
\text{Ground Intensity}: && &&
\lambda^*_g(t) &= \lambda \\
\text{Marks}: && &&
f^*(y|t) &= \boldsymbol{f}(y,\boldsymbol{\theta})
\end{aligned}
$$

We can plug in these terms into the equation [](eq:dmtpp-nll) to obtain:

$$
\log p^*(A) = 
\sum_{n=1}^{N(A)}\log \lambda -
\int_0^T\lambda d\tau +
\sum_{n=1}^{N(A)}\log \boldsymbol{f}(y_n,\boldsymbol{\theta})
$$ (eq:dmhpp-loglikelihood)

Because we have the homogeneous rate parameter cases, we get the Marked Homogeneous Poisson Process (MHPP). 
Using the portion of the HPP, we can plug in the terms found in equation [](eq:hpp-loglikelihood) into our equation above.
This gives us

$$
\log p^*(A) = 
N\log \lambda -
\lambda T +
\sum_{n=1}^{N(A)}\log \boldsymbol{f}(y_n|t_n,\boldsymbol{\theta})
$$

We see that both likelihood terms we decoupled as there are no dependencies between parameters of the temporal likelihood (the first two terms) and the marks likelihood (the third term) so they can be solved independently.
In the case of extremes, one option is to use the GPD as the marked distribution.
We can write out the new log-likelihood as

$$
\log p^*(A)= N\log\lambda - \lambda T +
\sum_{n=1}^{N(A)}
\log \boldsymbol{f}_{\text{GPD}}(y;\boldsymbol{\theta})
$$

This is known as the **Poisson-GPD** algorithm within the EVT literature {cite:p}`https://doi.org/10.1080/14697680500039613;https://doi.org/10.1007/s10666-020-09718-6`.
We can also parameterize the intensity with the parameterization in equation [](eq:poisson-reparam-gev) where we have some new free parameters $\boldsymbol{\theta} = \left\{ y_0, \mu, \sigma, \kappa\right\}$.

Alternatively, we can use the GEVD as the marked distribution.

$$
\log p^*(A)= N\log\lambda - \lambda T +
\sum_{n=1}^{N(A)}
\log \boldsymbol{f}_{\text{GEVD}}(y;\boldsymbol{\theta})
$$

This has no specific name in the EVT literature, however there are a few papers which use this distribution to motivate the GPD via the PP.
In this work, we name this the **Poisson-GEVD**.
We can parameterize GEVD parameters in terms of the GPD parameters which are needed for the intensity parameter given in equations [](eq:gevd-reparam-gpd) where we introduce free parameters $\boldsymbol{\theta} = \left\{ \mu_{y_0}, \sigma_{y_0}, \kappa_{y_0}\right\}$.

**Annual Exceedence Probability**.
Lastly, something of great interest within the EVT community is to characterize the return periods. 
Recall section [](sec:ari) whereby we showed that the ARI can be related to the conditional CDF.
Recall that this is given as

$$
\exp(-1/\bar{T}) = \exp(-\lambda\boldsymbol{S}(y;\boldsymbol{\theta}))
$$

where $\boldsymbol{S}$ is the survival function for the marks distribution and $\lambda$ is the average rate of occurrences over the threshold, $y_0$.
After rearranging this equation and simplifying, we can recognize that this is simply the quantile function of the marks distribution.

$$
\begin{aligned}
y &= \boldsymbol{Q}(y_p;\boldsymbol{\theta})
\end{aligned}
$$

where $\boldsymbol{Q}$ is the quantile function for the PDF/CDF and the probability in the $y$ domain, $y_p$. 

$$
\begin{aligned}
\text{Annual Exceedence Probability}: && &&
y_p &= 1 - 1 / (\lambda T_R) && &&
T_R\in[1,\infty)\\
\text{Average Recurrence Interval}: && &&
y_p &= \exp \left( - 1 / (\lambda \bar{T})\right), && &&
\bar{T}\in[0,\infty)
\end{aligned}
$$


***
### Example VII: MIPP 4 Extremes

In this example, we have a DMTPP for extremes.
We have a marked point process where we represent it as a 2D point process as shown in equation [](eq:mpp-space).
In this case, we decouple the intensity function as shown above section.
For the ground intensity, we have a HPP or IPP.
For the marks, we have iid parametric distribution

$$
\begin{aligned}
\text{Ground Intensity}: && &&
\lambda^*_g(t) &= \lambda(t) := \lambda_t \\
\text{Marks}: && &&
f^*(y|t) &= \boldsymbol{f}(y|t_n, \boldsymbol{\theta}) := \boldsymbol{f}(y|\boldsymbol{\theta}(t_n))
\end{aligned}
$$

where the parameters of the marks distribution are time dependent

$$
\boldsymbol{\theta}_t = \boldsymbol{\theta}(t)
$$


We can plug in these terms into the equation [](eq:dmtpp-nll) to obtain:

$$
\log p^*(A) = 
\sum_{n=1}^{N(A)}\log \lambda(t) -
\int_0^T\lambda(\tau)d\tau +
\sum_{n=1}^{N(A)}\log \boldsymbol{f}\left(y_n|\boldsymbol{\theta}(t_n)\right)
$$ (eq:dmpp-loglikelihood)

Here, our free parameters of our model are $\left\{ \lambda_t, \theta_t\right\}$.
Similar to the HPP case, we can use the GEVD or the GPD.


**Return Periods**.
Lastly, something of great interest within the EVT community is to characterize the return periods. 
Recall section [](sec:ari) whereby we showed that the ARI can be related to the conditional CDF.
Recall that this is given as

$$
\exp(-1/\bar{T}) = \exp(-\lambda_t\boldsymbol{S}(y;\boldsymbol{\theta}_t))
$$

where $\boldsymbol{S}$ is the survival function for the marks distribution and $\lambda$ is the average rate of occurrences over the threshold, $y_0$.
After rearranging this equation and simplifying, we can recognize that this is simply the quantile function of the marks distribution.

$$
\begin{aligned}
y &= \boldsymbol{Q}(y_p;\boldsymbol{\theta}_t)
\end{aligned}
$$

where $\boldsymbol{Q}$ is the quantile function for the PDF/CDF and the probability in the $y$ domain, $y_p$. 

$$
\begin{aligned}
\text{Return Period}: && &&
y_p &= 1 - 1 / (\lambda_t T_R) && &&
T_R\in[1,\infty)\\
\text{Average Recurrence Interval}: && &&
y_p &= \exp \left( - 1 / (\lambda_t \bar{T})\right), && &&
\bar{T}\in[0,\infty)
\end{aligned}
$$


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
## Literature Review


**Applications**.
{cite:p}`10.1214/09-AOAS287` investigate the differences in precipitation extremes during the 21st century as a trend stemming from global warming.
In {cite:p}`10.1007/S13253-010-0023-9`, they compare the extreme precipitation simulated in a regional climate model over its spatial domain where they apply a Bayesian Hierarchical model for MHPP model.