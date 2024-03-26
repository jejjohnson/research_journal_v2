---
title: State Space Models
subject: State Space Models
short_title: State-Space Models
authors:
  - name: J. Emmanuel Johnson
    affiliations:
      - CNRS
      - MEOM
    orcid: 0000-0002-6739-0053
    email: jemanjohnson34@gmail.com
license: CC-BY-4.0
keywords: data-assimilation, open-science
---

# Markov Models

> In these notes, we walk through a model for modeling time-dependent data. By enforcing the Markov chain properties, we only have a variable at time, $t$, depend on the variable at a previous time step, $t-1$. This results in very efficient directed graph which leads to inference of order $\mathcal{O}(T)$.

The main source of inspiration for this is the lecture from the Probabilistic ML course from Tubingen {cite:p}`gaussmarkov2020`. Some of the details we taken from the probabilistic machine learning textbook from Kevin Murphy {cite:p}`murphy2013probml`.

---
## Motivation

Consider a large dimensional dataset, e.g. a data cube. This will be of size: 

$$
\boldsymbol{y} \in \mathbf{R}^{D}
$$

But let's assume that it is a spatio-temporal dataset. Then we can decompose the dimension, $D$ into the following components.

$$
\text{Dimensions} = [  \text{Time} \times \text{Space} \times \text{Variables}]
$$

So we can rewrite this with this decomposition

$$
\boldsymbol{y} \in \mathbf{R}^{D_t \times D_y \times D_\Omega}
$$


This poses some immediate problems when we consider the full decomposition.

**High Dimensionality**.
This is a very high dimensional dataset.
For example, if we have a very long time series like $1,000$ time steps, then we will have a massive $D$-dimensional vector for the input variable.

**Time Dependencies**.
These time dependencies are very difficult to model. 
They are highly correlated, especially at very near, e.g. $t-1$, $t$, and $t-1$.

Let's say we are given a sequence of measurements, $\boldsymbol{y}_n$.

$$
\begin{aligned}
\mathcal{D} &= \left\{ \boldsymbol{y}_n \right\}_{n=1}^{N_t},
&& &&
\boldsymbol{y}_n\in\mathbb{R}^{D_y}
\end{aligned}
$$

How do we find an appropriate generative model for this sequence of measurements?

---
## Schematic

This method seeks to decouple time by enforcing the Markov assumption.

```{figure} https://www.researchgate.net/profile/Pierre-Jacob-2/publication/234140260/figure/fig1/AS:652600408023049@1532603470889/The-state-space-model.png
:alt: markov_model
:width: 500px
:align: center

A graphical model for the dependencies between the variables x and z. Notice how z only depends on the previous time step. 
```

This gives us the classical state-space formulation

$$
\begin{aligned}
\text{Initial Distribution}: && &&
\boldsymbol{z}_0 &\sim 
p(\boldsymbol{z}_0;\boldsymbol{\theta}) \\
\text{Markovian Dynamics Model}: && &&
\boldsymbol{z}_t &\sim  
p(\boldsymbol{z}_t|\boldsymbol{z}_{t-1};\boldsymbol{\theta}) \\
\text{Measurement Model}: && &&
\boldsymbol{y}_t &\sim 
p(\boldsymbol{y}_t|\boldsymbol{z}_{t};\boldsymbol{\theta}) \\
\end{aligned}
$$

Here, we have an *initial distribution* as a prior over the first state, $\boldsymbol{z}_0$.
We have a *dynamics model* as the prior over the forward state transitions.
We have a *measurement model* as a generative model for the observations of the latent state.





The key is that by enforcing these Markovian assumptions, we have a directed graph structure that results in very efficient inference. This is all due to the Markov property due to the chain structure. 


---
## Markov Properties


***
### Property of States

> Given the immediate past, the present state is independent of the entire history before it.

Given $\boldsymbol{z}_{t-1}$, $\boldsymbol{z}_t$ is independent of any other of the previous states, e.g. $\boldsymbol{z}_{t-2}, \boldsymbol{z}_{t-3}, \ldots$.

$$
p(\boldsymbol{z}_t | \boldsymbol{z}_{1:t-1}, \boldsymbol{y}_{1:t-1}) = p(\boldsymbol{z}_t|\boldsymbol{z}_{t-1})
$$(markov_prop_states)

This is enforcing some kind of *local memory* within our system. 
So even if we have the full system of observed variables, $\boldsymbol{y}_{1:T}$, and the posterior states, $\boldsymbol{z}_{1:T}$, we still only have the dependencies on the previous time step:

$$
p(\boldsymbol{z}_{t-1}|\boldsymbol{z}_{1:T}, \boldsymbol{y}_{1:T}) = 
p(\boldsymbol{z}_{t-1}|\boldsymbol{z}_t)
$$

Bottom line - **the past is independent of the future given the present**.

***
### Conditional Independence of Measurements

> The current measurement is conditionally independent of the past measurements and states given the current state.

We assume that the measurement, $\boldsymbol{y}_t$, given the current state, $\boldsymbol{z}_t$, is conditionally independent of the measurements and its histories.

$$
p(\boldsymbol{y}_t|\boldsymbol{z}_{1:t}, \boldsymbol{y}_{1:t-1}) = p(\boldsymbol{y}_t|\boldsymbol{z}_t)
$$

So as you can see, the measurement at time, $t$, is only dependent on the state, $\boldsymbol{z}$, at time $t$ state irregardless of how many other time steps have been observed.


***
### Joint Distribution

Given the above properties, this represents how we decompose the time series.
We use the properties mentioned above.

$$
p(\boldsymbol{z}_{0:T},\boldsymbol{y}_{1:T};\boldsymbol{\theta}) = 
p\left(\boldsymbol{z}_0;\boldsymbol{\theta} \right)
\prod_{t=1}^T
p\left(\boldsymbol{y}_t|\boldsymbol{z}_t;\boldsymbol{\theta}\right)
p\left(\boldsymbol{z}_t|\boldsymbol{z}_{t-1};\boldsymbol{\theta}\right)
$$

While this may not be immediately useful, it is useful for certain other quantities of interest.

***
### Posterior

We are interested in finding the latent states, $\boldsymbol{z}_{0:T}$, given our observations, $\boldsymbol{y}_{1:T}$.
However, due to the Markovian nature of the state space model, this process is a combination of  
This is known as *filtering*.

$$
p(\boldsymbol{z}_t|\boldsymbol{y}_{1:t}) = 
$$

***



***
## Quantities of Interest

Once we have the model structure, now we are interested in the specific quantities. All of them really boil down to quantities from inference.

### TLDR

**Posterior**, $p(\boldsymbol{z}_t|\boldsymbol{y}_{1:t})$ - this is the probability of the state, $\boldsymbol{z}_t$ given the current and previous measurements, $\boldsymbol{y}_{1:t}$.

**Predict Step**, $p(\boldsymbol{z}_t|\boldsymbol{y}_{1:t-1})=\int p(\boldsymbol{z}_t|\boldsymbol{z}_{t-1})p(\boldsymbol{z})$ - the current state, $\boldsymbol{z}_t$, given the past measurements, $\boldsymbol{y}_{1:t-1}$.

**Measurement Step**, $p(\boldsymbol{z}_t|\boldsymbol{y}_t, \boldsymbol{y}_{1:t-1}) \propto p(\boldsymbol{y}_t|\boldsymbol{z}_t)p(\boldsymbol{z}_t|\boldsymbol{y}_{1:t-1})$ - the current state, $\boldsymbol{z}_t$, given the present measurement $\boldsymbol{y}_t$ and past measurements, $\boldsymbol{y}_{1:t-1}$

**Marginal Likelihood** - $p(\boldsymbol{y}_{1:T}) = \sum_{t}^T p(\boldsymbol{y}_t|\boldsymbol{y}_{1:t-1})$ - the likelihood of measurements, $\boldsymbol{y}_{1:T}$, given the state, $\boldsymbol{z}_{1:T}$.

**Posterior Predictive**: $p(\boldsymbol{y}_t|\boldsymbol{y}_{1:t-1}) = \int p(\boldsymbol{y}_t|\boldsymbol{z}_t)p(\boldsymbol{z}_t|\boldsymbol{z}_{t-1})d\boldsymbol{z}_t$ - The probability of the measurement, $\boldsymbol{y}_t$, given the previous measurements, $\boldsymbol{y}_{1:t-1}$.

**Sampling (Posterior)**: $\boldsymbol{z}_{1:T} \sim p(\boldsymbol{z}_t|\boldsymbol{y}_{1:T})$ - Trajectories for states, $\boldsymbol{z}_{1:t}$, given the measurements, $\boldsymbol{y}_{1:T}$.

**Sampling (Measurements)**: $\boldsymbol{y}_t \sim p(\boldsymbol{y}_t|\boldsymbol{y}_{1:t-1})$ - Trajectories for observations, $\boldsymbol{y}_{1:T}$, given the state space model, $\boldsymbol{z}_{1:T}$.


---
### Filtering/Posterior

> The probability of the state, $\boldsymbol{z}_t$ given the current and previous measurements, $\boldsymbol{y}_{1:t}$.

We are interested in computing the belief of our state, $\boldsymbol{z}_t$. This is given by

$$
p(\boldsymbol{z}_t | \boldsymbol{y}_{1:t}) =
\frac{1}{\boldsymbol{E}(\boldsymbol{\theta})} 
p(\boldsymbol{z}_t|\boldsymbol{y}_t)p(\boldsymbol{z}_t|\boldsymbol{y}_{1:t})
$$(posterior)

This equation is the posterior probability of $\boldsymbol{z}_t$ given the present measurement, $\boldsymbol{y}_t$, and all of the past measurements, $\boldsymbol{y}_{1:t-1}$. We can compute this using the Bayes method (eq {eq}`bayes`) in a sequential way.

```{prf:remark}
:label: filter-name

The term *filter* comes from the idea that we reduce the noise of current time step, $p(\boldsymbol{z}_t|\boldsymbol{y}_t)$, by taking into account the information within previous time steps, $\boldsymbol{y}_{1:t-1}$.

```

This is given by the predict-update equations:

$$
\begin{aligned}
\text{Prediction}: && &&
p(\boldsymbol{z}_t|\boldsymbol{y}_{1:t-1};\boldsymbol{\theta}) &= 
\int p(\boldsymbol{z}_t|\boldsymbol{z}_{t-1};\boldsymbol{\theta})
p(\boldsymbol{z}_{t-1}|\boldsymbol{y}_{1:t-1};\boldsymbol{\theta})d\boldsymbol{z}_{t-1} \\
\text{Correction}: && &&
p(\boldsymbol{z}_t|\boldsymbol{y}_{1-t};\boldsymbol{\theta}) &= 
\frac{1}{\boldsymbol{E}(\boldsymbol{\theta})}
p(\boldsymbol{y}_t|\boldsymbol{z}_t;\boldsymbol{\theta})
p(\boldsymbol{z}_t|\boldsymbol{y}_{1:t-1})
\end{aligned}
$$

It is a recursive relationship where the predict step depends on the correction step and vice versa.

***
### Predict

> The current state, $\boldsymbol{z}_t$, given the past measurements, $\boldsymbol{y}_{1:t-1}$.

This quantity is given via the *Chapman-Kolmogrov* equation.

$$
p(\boldsymbol{z}_t|\boldsymbol{y}_{1:t-1}) = \int p(\boldsymbol{z}_t|\boldsymbol{z}_{t-1})p(\boldsymbol{z}_{t-1}|\boldsymbol{y}_{1:t-1})d\boldsymbol{y}_{t-1}
$$(chapman_kolmogrov)


**Term I**: the transition distribution between time steps.

**Term II**: the posterior distribution of the state, $\boldsymbol{z}_{t-1}$, given all of the observations, $\boldsymbol{y}_{1:t-1}$.

Note: term III is the posterior distribution but at a previous time step.


---

### Correction

>  The posterior distribution of state, $\boldsymbol{z}_t$, given the current **and** previous measurements, $\boldsymbol{y}_{1:t}$.

$$
p(\boldsymbol{z}_t|\boldsymbol{y}_{1:t}) =  \frac{p(\boldsymbol{y}_t|\boldsymbol{z}_t)p(\boldsymbol{z}_t|\boldsymbol{y}_{1:t-1})}{p(\boldsymbol{y}_t)}
$$(markov_update)


**Term I**: The observation model for the current measurement, $\boldsymbol{y}_t$, given the current state, $\boldsymbol{z}_t$.

**Term II**: The posterior distribution of the current state, $\boldsymbol{z}_t$, given all of the previous measurements, $\boldsymbol{y}_{1:t-1}$.

**Term III**: The marginal distribution for the current measurement, $\boldsymbol{y}_t$.

---
### Filtering Algorithm

The full form for filtering equation is given by an iterative process between the predict step and the update step.

**1. Predict the next hidden state**

* First you get the posterior of the previous state, $\boldsymbol{z}_{t-1}$, given all of the observations, $\boldsymbol{y}_{1:t-1}$.
* Second, you get the posterior of the current state, $\boldsymbol{z}_t$, given all of the observations, $p(\boldsymbol{y}_{1:t-1})$


$$
p(\boldsymbol{z}_{t-1}|\boldsymbol{y}_{1:t-1}) \rightarrow p(\boldsymbol{z}_t|\boldsymbol{y}_{1:t-1})
$$

**2. Predict the observation**

* First, you take the state, $\boldsymbol{y}_t$, given the previous measurements, $\boldsymbol{y}_t$. 
* Second you predict the current measurement, $\boldsymbol{y}_t$, given all previous measurements, $\boldsymbol{y}_{1:t-1}$.

$$
p(\boldsymbol{y}_t|\boldsymbol{y}_{1:t-1}) \rightarrow p(\boldsymbol{y}_t|\boldsymbol{y}_{1:t-1})
$$

**3. Update the hidden state given the observation**

* First, you take the new observation, $\boldsymbol{y}_t$
* Then, you do an update step to get the current state, $\boldsymbol{y}_t$, given all previous measurements, $\boldsymbol{y}_{1:t}$.




***

### Smoothing

We compute the state, $\boldsymbol{z}_t$, given all of the measurements, $\boldsymbol{y}_{1:T}$ where $1 < t < T$. 

$$
p(\boldsymbol{z}_t|\boldsymbol{y}_{1:T})
$$

We condition on the past and the future to significantly reduce the uncertainty.

```{prf:remark}
:label: hindsight

We can see parallels to our own lives. Take the quote "Hindsight is 22". This implies that we can easily explain an action in our past once we have all of the information available. However, it's harder to explain our present action given only the past information.

```

This use case is very common when we want to *understand* and *learn* from data. In a practical sense, many reanalysis datasets take this into account.

$$
p(\boldsymbol{z}_t|\boldsymbol{y}_{1:T}) = p(\boldsymbol{z}_t|\boldsymbol{y}_{1:t}) \int p(\boldsymbol{z}_{t+1}|\boldsymbol{z}_t) \frac{p(\boldsymbol{z}_{t+1}|\boldsymbol{y}_{1:T})}{p(\boldsymbol{z}_{t+1}|\boldsymbol{y}_{1:t})}d\boldsymbol{z}_{t+1}
$$(markov_smooth)

**Term I**: The current state, $\boldsymbol{z}_t$, given all of the past, current and future measurements, $\boldsymbol{y}_{1:T}$ (smoothing step)

**Term II**: The current state, $\boldsymbol{z}_t$, given all of the present and previous measurements, $\boldsymbol{y}_{1:t}$ (the predict step)

**Term III**: The "future" state, $\boldsymbol{z}_{t+1}$, given the previous state, $\boldsymbol{z}_t$ (transition prob)

**Term IV**: The "future" state, $\boldsymbol{z}_{t+1}$, given all of the measurements, $\boldsymbol{y}_{1:T}$.

**Term V**: The "future" state, $\boldsymbol{z}_{t+1}$, given all of the current and past measurements, $\boldsymbol{y}_{1:T}$.




---

### Predictions

We want to predict the future state, $\boldsymbol{z}_{T+\tau}$, given the past measurements, $\boldsymbol{y}_{1:T}$.

$$
p(\boldsymbol{z}_{T+\tau}|\boldsymbol{y}_{1:T})
$$

where $\tau > 0$. $\tau$ is the *horizon* of our forecasting, i.e. it is how far ahead of $T$ we are trying to predict. So we can expand this to write that we are interested in the future hidden states, $\boldsymbol{z}_{T+\tau}$, given all of the past measurements, $\boldsymbol{y}_{1:T}$.

$$
p(\boldsymbol{z}_{T+\tau}|\boldsymbol{y}_{1:T}) = \sum_{\boldsymbol{z}_{T+\tau}} \sum_{\boldsymbol{z}_t} p(\boldsymbol{z}_{T+\tau}|\boldsymbol{z}_t) p(\boldsymbol{z}_t|\boldsymbol{y}_{1:T})
$$

We could also want to get predictions for what we observe

$$
p(\boldsymbol{y}_{T+\tau}|\boldsymbol{y}_{1:t}) = \sum p(\boldsymbol{y}_{T+\tau}|\boldsymbol{z}_{T+\tau})p(\boldsymbol{z}_{T+\tau}|\boldsymbol{y}_{1:T})
$$

This is known as the *posterior predictive density*.

This is often the most common use case in applications, e.g. weather predictions and climate model projections. The nice thing is that we will have this as a by-product of our model.


### Likelihood Estimation


$$
\boldsymbol{E}(\boldsymbol{\theta}) = 
p(\boldsymbol{y}_{t}|\boldsymbol{y}_{1:t-1};\boldsymbol{\theta}) = 
\int p(\boldsymbol{y}_t|\boldsymbol{z}_t;\boldsymbol{\theta})
p(\boldsymbol{z}_t|\boldsymbol{y}_{1:t-1})d\boldsymbol{z}_t
$$


For learning, we need to calculate the most probable state-space that matches the given observations. This assumes that we have access to all of the measurements, $\boldsymbol{y}_{1:T}$.

$$
\mathcal{L}_{NLL} = \operatorname*{argmax}_{\boldsymbol{z}_{1:T}} p(\boldsymbol{z}_{1:T}|\boldsymbol{y}_{1:T})
$$

**Note**: This is a non-probabilistic approach to maximizing the likelihood. However, this could be very useful for some applications. Smoothing would be better but we still need to find the best parameters.


### Posterior Samples

We are interested in generating possible states and state trajectories. In this case, we want the likelihood of a state trajectory, $\boldsymbol{z}_{1:T}$, given some measurements, $\boldsymbol{y}_{1:T}$. This is given by:

$$
\boldsymbol{z}_{1:T} \sim p(\boldsymbol{z}_{1:T}|\boldsymbol{y}_{1:T})
$$

This is very informative because it can show us plausible interpretations of possible state spaces that could fit the measurements.


```{prf:remark}
:label: markov_useful

In terms of information, we can show the following relationship.

$$
\text{MAP} << \text{Smoothing} << \text{Posterior Samples}
$$
```

### Marginal Likelihood

This is the probability of the evidence, i.e., the marginal probability of the measurements. This may be useful as an evaluation of the density of given measurements. We could write this as the joint probabilty

$$
p(\boldsymbol{y}_{1:T}) = \sum_{\boldsymbol{z}_{1:T}} p(\boldsymbol{z}_{1:T}, \boldsymbol{y}_{1:T})
$$

We can decompose this using the conditional probability. This gives us

$$
p(\boldsymbol{y}_{1:T}) = \sum_{\boldsymbol{z}_{1:T}} p(\boldsymbol{y}_{1:T}|\boldsymbol{z}_{1:T})p(\boldsymbol{z}_{1:T})
$$

As shown by the above function, this is done by summing all of the hidden paths. 

This can be useful if we want to use the learned model to classify sequences, perform clustering, or possibly anomaly detection. 

Note: We can use the log version of this equation to deal with instabilities.

$$
\mathcal{L} = \log p(\boldsymbol{y}_{1:T}) = \sum_{\boldsymbol{z}_{1:T}} \log p(\boldsymbol{z}_{1:T},\boldsymbol{y}_{1:T})
$$

### Complexity

This is the biggest reason why one would do a Markov assumptions aside from the simplicity. Let $D$ be the dimensionality of the state space, $z$ and $T$ be the number of time steps given by the measurements. We can give the computational complexity for each of the quantities listed above.

**Filter-Predict**

This is of order $\mathcal{O}(D^2T)$

If we assume sparsity in the methods, then we can reduce this to $\mathcal{O}(DT)$. 

We can reduce the complexity even further by assuming some special matrices within the functions to give us a complexity of $\mathcal{O}(T D \log D)$.

If we do a parallel computation, we can even have a really low computational complexity of $\mathcal{O}(D \log T)$.

Overall: the bottleneck of this method is not the computational speed, it's the memory required to do all of the computations cheaply.


---
### Viz

#### Bars


#### Regression


---
## Cons

While we managed to reduce the dimensionality of our dataset, this might not be the optimal model to choose. We assume that $\boldsymbol{z}_t$ only depends on the previous time step, $\boldsymbol{z}_{t-t}$. But it could be the case that $\boldsymbol{z}_t$ could depend on previous time steps, e.g. $p(\boldsymbol{z}_t | \boldsymbol{z}_{t-1}, \boldsymbol{z}_{t-2}, \boldsymbol{z}_{t-2}, \ldots)$. There is no reason to assume that 


#### Multiscale Time Dependencies

One way to overcome this is to assume 


#### Long Term 



---
```{bibliography}
:filter: docname in docnames
:style: alpha
```
