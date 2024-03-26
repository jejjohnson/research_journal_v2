---
title: Sequential Variational Inference
subject: Machine Learning for Earth Observations
short_title: Sequential Variational Inference
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

***
## Context

Let's say we are given a sequence of measurements, $\boldsymbol{y}_n$.


$$
\mathcal{D} = \left\{ \boldsymbol{y}_n \right\}_{n=1}^{N_t}
$$

We assume that there is some latent state, $\boldsymbol{z}_t$, which enables the sequential measurements to be conditionally independent.

***
### Joint Distribution

This represents how we decompose the time series.
We use the properties mentioned above.

$$
p_{\boldsymbol{\theta}}(\boldsymbol{z}_{0:T},\boldsymbol{y}_{1:T}) = 
p_{\boldsymbol{\theta}}\left(\boldsymbol{z}_0\right)
\prod_{t=1}^T
p_{\boldsymbol{\theta}}\left(\boldsymbol{y}_t|\boldsymbol{z}_t\right)
p_{\boldsymbol{\theta}}\left(\boldsymbol{z}_t|\boldsymbol{z}_{t-1}\right)
$$

> 

***
### Posterior

We are interested in finding the latent states, $\boldsymbol{z}_{0:T}$, given our observations, $\boldsymbol{y}_{1:T}$.
However, due to the Markovian nature of the state space model, this process is a combination of  
This is known as *filtering*.

$$
p_{\boldsymbol{\theta}}(\boldsymbol{z}_t | \boldsymbol{y}_{1:t}) =
\frac{1}{\boldsymbol{E}_{\boldsymbol{\theta}}} 
p_{\boldsymbol{\theta}}(\boldsymbol{z}_t|\boldsymbol{y}_t)
p_{\boldsymbol{\theta}}(\boldsymbol{z}_t|\boldsymbol{y}_{1:t})
$$(posterior)

where the marginal likelihood, $\boldsymbol{E}_{\boldsymbol{\theta}}$, is given by

$$
\boldsymbol{E}_{\boldsymbol{\theta}} = 
p_{\boldsymbol{\theta}}(\boldsymbol{y}_{t}|\boldsymbol{y}_{1:t-1}) = 
\int p_{\boldsymbol{\theta}}(\boldsymbol{y}_t|\boldsymbol{z}_t)
p_{\boldsymbol{\theta}}(\boldsymbol{z}_t|\boldsymbol{y}_{1:t-1})d\boldsymbol{z}_t
$$

This is typically given by the filtering algorithm which has a prediction and a correction step.

$$
\begin{aligned}
\text{Prediction}: && &&
p_{\boldsymbol{\theta}}(\boldsymbol{z}_t|\boldsymbol{y}_{1:t-1}) &= 
\int p_{\boldsymbol{\theta}}(\boldsymbol{z}_t|\boldsymbol{z}_{t-1})
p(\boldsymbol{z}_{t-1}|\boldsymbol{y}_{1:t-1})d\boldsymbol{z}_{t-1} \\
\text{Correction}: && &&
p_{\boldsymbol{\theta}}(\boldsymbol{z}_t|\boldsymbol{y}_{1-t}) &= 
\frac{1}{\boldsymbol{E}_{\boldsymbol{\theta}}}
p_{\boldsymbol{\theta}}(\boldsymbol{y}_t|\boldsymbol{z}_t)
p_{\boldsymbol{\theta}}(\boldsymbol{z}_t|\boldsymbol{y}_{1:t-1})
\end{aligned}
$$



***
## Variational Inference

We will start with the full posterior written like so

$$
p_{\boldsymbol{\theta}}(\boldsymbol{z}_t | \boldsymbol{y}_{1:t}) =
\frac{p_{\boldsymbol{\theta}}(\boldsymbol{z}_{0:T},\boldsymbol{y}_{1:T})}{p_{\boldsymbol{\theta}}(\boldsymbol{y}_{t}|\boldsymbol{y}_{1:t-1})} 
$$

but will rearrange this to have the marginal likelihood isolated

$$
p_{\boldsymbol{\theta}}(\boldsymbol{y}_{t}|\boldsymbol{y}_{1:t-1}) =
\frac{p_{\boldsymbol{\theta}}(\boldsymbol{z}_{0:T},\boldsymbol{y}_{1:T})}
{p_{\boldsymbol{\theta}}(\boldsymbol{z}_t | \boldsymbol{y}_{1:t})} 
$$


Now, we will do the standard log transformation on both sides

$$
\log p_{\boldsymbol{\theta}}(\boldsymbol{y}_{t}|\boldsymbol{y}_{1:t-1}) =
\log \frac{p_{\boldsymbol{\theta}}(\boldsymbol{z}_{0:T},\boldsymbol{y}_{1:T})}
{p_{\boldsymbol{\theta}}(\boldsymbol{z}_t | \boldsymbol{y}_{1:t})} 
$$

Then we will do the identity trick to push in our variational distribution, $q(\boldsymbol{z}_{1:T})$.


$$
\log p_{\boldsymbol{\theta}}(\boldsymbol{y}_{t}|\boldsymbol{y}_{1:t-1}) =
\mathbb{E}_{q_{\boldsymbol{\phi}}(\boldsymbol{z}_{1:T})}\left[
  \log
  \frac{p_{\boldsymbol{\theta}}(\boldsymbol{z}_{0:T},\boldsymbol{y}_{1:T})}
  {p_{\boldsymbol{\theta}}(\boldsymbol{z}_t | \boldsymbol{y}_{1:t})} 
  \frac{q_{\boldsymbol{\phi}}(\boldsymbol{z}_{1:T})}{q_{\boldsymbol{\phi}}(\boldsymbol{z}_{1:T})}
\right]
$$

Now, we can break apart the log terms

$$
\log p_{\boldsymbol{\theta}}(\boldsymbol{y}_{t}|\boldsymbol{y}_{1:t-1}) =
\mathbb{E}_{q_{\boldsymbol{\phi}}(\boldsymbol{z}_t)}\left[
  \log
  \frac{p_{\boldsymbol{\theta}}(\boldsymbol{z}_{0:T},\boldsymbol{y}_{1:T})}
  {q_{\boldsymbol{\phi}}(\boldsymbol{z}_{1:T})} +
  \log
  \frac{q_{\boldsymbol{\phi}}(\boldsymbol{z}_{1:T})}
  {p_{\boldsymbol{\theta}}(\boldsymbol{z}_t | \boldsymbol{y}_{1:t})} 
\right]
$$

and we can seperate the expectation terms as they are additive

$$
\log p_{\boldsymbol{\theta}}(\boldsymbol{y}_{t}|\boldsymbol{y}_{1:t-1}) =
\mathbb{E}_{q_{\boldsymbol{\phi}}(\boldsymbol{z}_{1:T})}\left[
  \log
  \frac{p_{\boldsymbol{\theta}}(\boldsymbol{z}_{0:T},\boldsymbol{y}_{1:T})}
  {q_{\boldsymbol{\phi}}(\boldsymbol{z}_{1:T})}
  \right] +
  \mathbb{E}_{q_{\boldsymbol{\phi}}(\boldsymbol{z}_{1:T})}\left[
  \log \frac{q_{\boldsymbol{\phi}}(\boldsymbol{z}_{1:T})}
  {p_{\boldsymbol{\theta}}(\boldsymbol{z}_t | \boldsymbol{y}_{1:t})} 
\right]
$$

The 2nd term on the RHS is the KLD term which we can replace this with the more compact form.

$$
\log p_\theta(x) =  
\mathbb{E}_{q_{\boldsymbol{\phi}}(\boldsymbol{z}_{1:T})}\left[
  \log
  \frac{p_{\boldsymbol{\theta}}(\boldsymbol{z}_{0:T},\boldsymbol{y}_{1:T})}
  {q_{\boldsymbol{\phi}}(\boldsymbol{z}_{1:T})}
  \right] + 
\text{D}_{\text{KL}} 
\left[
  q_{\boldsymbol{\phi}}(\boldsymbol{z}_{1:T}) ||
  p_{\boldsymbol{\theta}}(\boldsymbol{z}_t | \boldsymbol{y}_{1:t})
\right]
$$

The term on the right is now the variational gap term.
We know that this will always be greater than or equal to 0.
So we need to maximize the first term in order to minimize the second term, i.e., minimize the variational gap.

Thus, we can drop that term and put a lower bound on the likelihood.


We can decompose the joint distribution within the first term

$$
\boldsymbol{L}_\text{ELBO} :=
\mathbb{E}_{q_{\boldsymbol{\phi}}(\boldsymbol{z}_{1:T})}\left[
  \log
  \frac{p_{\boldsymbol{\theta}}(\boldsymbol{z}_{0:T},\boldsymbol{y}_{1:T})}
  {q_{\boldsymbol{\phi}}(\boldsymbol{z}_{1:T})}
  \right]
\leq
\log p_{\boldsymbol{\theta}}(\boldsymbol{z}_t | \boldsymbol{y}_{1:t}) 
$$

To clean this term up, first we will split the term using the log rules

$$
\boldsymbol{L}_\text{ELBO} :=
\mathbb{E}_{q_{\boldsymbol{\phi}}(\boldsymbol{z}_{1:T})}
\left[
  \log p_{\boldsymbol{\theta}}(\boldsymbol{z}_{0:T},\boldsymbol{y}_{1:T}) -
  \log q_{\boldsymbol{\phi}}(\boldsymbol{z}_{1:T})
\right]
$$

Now, we will decompose the joint distribution based on our priors.

$$
\boldsymbol{L}_\text{ELBO} :=
\mathbb{E}_{q_{\boldsymbol{\phi}}(\boldsymbol{z}_t)}
\left[
  \sum_{t=1}^T\log
p_{\boldsymbol{\theta}}\left(\boldsymbol{y}_t|\boldsymbol{z}_t\right)
+
  \sum_{t=1}^T\log
p_{\boldsymbol{\theta}}\left(\boldsymbol{z}_t|\boldsymbol{z}_{t-1}\right)
 -
    \sum_{t=1}^T
    \log q_{\boldsymbol{\phi}}(\boldsymbol{z}_{t})
\right]
$$

We can push the summations outside of the logs and expectations


```{math}
:label: seq-vi-elbo-gen
\boldsymbol{L}_\text{ELBO} :=
\sum_{t=1}^T
\mathbb{E}_{q_{\boldsymbol{\phi}}(\boldsymbol{z}_t)}
\left[
\log
p_{\boldsymbol{\theta}}\left(\boldsymbol{y}_t|\boldsymbol{z}_t\right)
+
\log
p_{\boldsymbol{\theta}}\left(\boldsymbol{z}_t|\boldsymbol{z}_{t-1}\right)
 -
    \log q_{\boldsymbol{\phi}}(\boldsymbol{z}_{t})
\right]
```



Similar to our other derivations of the Variational distribution, we will also have 3 different terms depending upon how we break this apart.

---
## Variational Free Energy (VFE)


There is one more main derivation that remains (that's often seen in the literature). Looking at the equation {eq}`seq-vi-elbo-gen` again we will isolate the likelihood *and* the prior under the variational expectation. This gives us:


$$
 \mathcal{L}_{\text{ELBO}}=
 {\color{red}
 \sum_{t=1}^T
\mathbb{E}_{q_{\boldsymbol{\phi}}(\boldsymbol{z}_t)}
\left[ \log 
p_{\boldsymbol{\theta}}\left(\boldsymbol{y}_t|\boldsymbol{z}_t\right)
p_{\boldsymbol{\theta}}\left(\boldsymbol{z}_t|\boldsymbol{z}_{t-1}\right)
\right]} - 
 {\color{green} 
 \sum_{t=1}^T
 \mathbb{E}_{q_{\boldsymbol{\phi}}(\boldsymbol{z}_t)}
 \left[ \log q_{\boldsymbol{\phi}}(\boldsymbol{z}_{t})\right]
 }.
$$

where:

* ${\color{red}\mathbb{E}_{q_{\boldsymbol{\phi}}(\boldsymbol{z}_t)}\left[ \log p_{\boldsymbol{\theta}}\left(\boldsymbol{y}_t|\boldsymbol{z}_t\right)p_{\boldsymbol{\theta}}\left(\boldsymbol{z}_t|\boldsymbol{z}_{t-1}\right)\right]}$ - is the ${\color{red}\text{energy}}$ function
* ${\color{green} \mathbb{E}_{q_{\boldsymbol{\phi}}(\boldsymbol{z}_t)}\left[ \log q_{\boldsymbol{\phi}}(\boldsymbol{z}_{t})\right]}$ - is the ${\color{green}\text{entropy}}$


**Source**: I see this approach a lot in the Gaussian process literature when they are deriving the Sparse Gaussian Process from Titsias.


---
## Reconstruction Loss

This is the most common loss. Looking at equation {eq}`seq-vi-elbo-gen` again, we group the prior probability and the variational distribution together, we get:

$$
\boldsymbol{L}_\text{ELBO} :=
\sum_{t=1}^T
\mathbb{E}_{q_{\boldsymbol{\phi}}(\boldsymbol{z}_t)}
\left[
\log
p_{\boldsymbol{\theta}}\left(\boldsymbol{y}_t|\boldsymbol{z}_t\right)
\right]
+
\sum_{t=1}^T
\mathbb{E}_{q_{\boldsymbol{\phi}}(\boldsymbol{z}_t)}
\left[
  \log 
  \frac{p_{\boldsymbol{\theta}}\left(\boldsymbol{z}_t|\boldsymbol{z}_{t-1}\right)}
  {q_{\boldsymbol{\phi}}(\boldsymbol{z}_{t})}
\right]
$$

This is the same KLD term as before but in the reverse order. So with a slight of hand in terms of the signs, we can rearrange the term to be

$$
\boldsymbol{L}_\text{ELBO} :=
\sum_{t=1}^T
\mathbb{E}_{q_{\boldsymbol{\phi}}(\boldsymbol{z}_t)}
\left[
\log
p_{\boldsymbol{\theta}}\left(\boldsymbol{y}_t|\boldsymbol{z}_t\right)
\right]
-
\sum_{t=1}^T
\mathbb{E}_{q_{\boldsymbol{\phi}}(\boldsymbol{z}_t)}
\left[
  \log 
  \frac{q_{\boldsymbol{\phi}}(\boldsymbol{z}_{t})}
  {p_{\boldsymbol{\theta}}\left(\boldsymbol{z}_t|\boldsymbol{z}_{t-1}\right)}
\right]
$$

So now, we have the exact same KLD term as before. So let's use the simplified form.

$$
 \boldsymbol{L}_{\text{ELBO}}=
 {\color{red}
 \sum_{t=1}^T
 \mathbb{E}_{q_{\boldsymbol{\phi}}(\boldsymbol{z}_t)}
 \left[ p_{\boldsymbol{\theta}}\left(\boldsymbol{y}_t|\boldsymbol{z}_t\right)\right]} - 
 {\color{green}
 \sum_{t=1}^T\text{D}_\text{KL}\left[
  q_{\boldsymbol{\phi}}(\boldsymbol{z}_{t})||p_{\boldsymbol{\theta}}\left(\boldsymbol{z}_t|\boldsymbol{z}_{t-1}\right)
  \right]}.
$$


where:
* ${\color{red}\mathbb{E}_{q_{\boldsymbol{\phi}}(\boldsymbol{z}_t)}\left[ p_{\boldsymbol{\theta}}\left(\boldsymbol{y}_t|\boldsymbol{z}_t\right)\right]}$ - is the $\color{red}\text{reconstruction loss}$.
* ${\color{green}\text{D}_\text{KL}\left[q_{\boldsymbol{\phi}}(\boldsymbol{z}_{t})||p_{\boldsymbol{\theta}}\left(\boldsymbol{z}_t|\boldsymbol{z}_{t-1}\right)\right]}$ - is the complexity, i.e. the $\color{green}\text{KL divergence}$ (a distance metric) between the prior and the variational distribution.

This is easily the most common ELBO term especially with Variational AutoEncoders (VAEs). The first term is the expectation of the likelihood term wrt the variational distribution. The second term is the KLD between the prior and the variational distribution.


---
## Volume Correction

Another approach is more along the lines of the transform distribution. Assume we have our original data domain $\mathcal{X}$ and we have some stochastic transformation, p(z|x), which transforms the data from our original domain to a transform domain, $\mathcal{Z}$.

$$
z \sim p(z|x)
$$

To acquire this from equation {eq}`seq-vi-elbo-gen`, we will isolate the prior and combine the likelihood and the variational distribution.

$$
 \boldsymbol{L}_{\text{ELBO}}=
 {\color{red}
 \sum_{t=1}^T
 \mathbb{E}_{q_{\boldsymbol{\phi}}(\boldsymbol{z}_t)}
 \left[ \log p_{\boldsymbol{\theta}}\left(\boldsymbol{z}_t|\boldsymbol{z}_{t-1}\right) \right]} + 
 {\color{green}
 \sum_{t=1}^T
 \mathbb{E}_{q_{\boldsymbol{\phi}}(\boldsymbol{z}_t)}
 \left[ \log 
 \frac{p_{\boldsymbol{\theta}}\left(\boldsymbol{y}_t|\boldsymbol{z}_t\right)}
 {q_{\boldsymbol{\phi}}(\boldsymbol{z}_{t})} \right]}.
$$


where:

* ${\color{red}\mathbb{E}_{q_{\boldsymbol{\phi}}(\boldsymbol{z}_t)}\left[ \log p_{\boldsymbol{\theta}}\left(\boldsymbol{z}_t|\boldsymbol{z}_{t-1}\right) \right]}$ - is the expectation of the transformed distribution, aka the ${\color{red}\text{reparameterized probability}}$.
* ${\color{green}\mathbb{E}_{q_{\boldsymbol{\phi}}(\boldsymbol{z}_t)}\left[ \log \frac{p_{\boldsymbol{\theta}}\left(\boldsymbol{y}_t|\boldsymbol{z}_t\right)}{q_{\boldsymbol{\phi}}(\boldsymbol{z}_{t})} \right]}$ - is the ratio between the inverse transform and the forward transform , i.e. ${\color{green}\text{Volume Correction Factor}}$ or *likelihood contribution*.


**Source**: I first saw this approach in the SurVAE Flows paper.



***
## ELBO Loss

We have the generic ELBO loss function calculates a loss between the joint variational distribution and the joint prior distribution.

$$
\boldsymbol{L}_{ELBO}(\boldsymbol{\theta},\boldsymbol{\phi}) = 
\mathbb{E}_{q_{\boldsymbol{\phi}}(\boldsymbol{z}_{0:T})}
\left[ 
    \log p_{\boldsymbol{\theta}}(\boldsymbol{z}_{0:T},\boldsymbol{y}_{1:T}) -
    \log q_{\boldsymbol{\phi}}(\boldsymbol{z}_{0:T})
\right]
\leq
p_{\boldsymbol{\theta}}(\boldsymbol{y}_{1:T})
$$

where the prior parameters, $\boldsymbol{\theta}$, and variational parameters, $\boldsymbol{\phi}$.
So, we can calculate gradients

$$
\boldsymbol{\nabla}_{\boldsymbol{\phi},\boldsymbol{\theta}}\boldsymbol{L}_\text{ELBO} =
\boldsymbol{\nabla}_{\boldsymbol{\phi},\boldsymbol{\theta}}
\mathbb{E}_{q_{\boldsymbol{\phi}}(\boldsymbol{z}_{0:T})}
\left[ 
    \log p_{\boldsymbol{\theta}}(\boldsymbol{z}_{0:T},\boldsymbol{y}_{1:T}) -
    \log q_{\boldsymbol{\phi}}(\boldsymbol{z}_{0:T})
\right]
$$

There are some difficulties regarding calculating gradients over expectations.
See the [pyro-ppl guide](https://pyro.ai/examples/svi_part_iii.html) for more information about this.

***
## Variational Distributions

There are many ways one could

* Independent
* Markovian
* Autoregressive
* Bi-Directional


***
### Independent

This first case is the simplest.
We assume that the state does not depend upon anything.
An example formulation can be given by:

$$
q(\boldsymbol{z}_{1:T},\boldsymbol{y}_{1:T}) =
\prod_{t=1}^T
\mathcal{N}
\left(\boldsymbol{z}_t|
\boldsymbol{m}_{\boldsymbol{\phi}},
\boldsymbol{S}_{\boldsymbol{\phi}}
\right)
$$

***
### Conditional

This first case is the simplest.
We assume that the state only depends upon the observations, i.e., $z_t \sim q(\boldsymbol{z}_t|\boldsymbol{y}_t)$.
However, we allow for a non-linear relationship between the observations, $\boldsymbol{y}_t$, and the state, $\boldsymbol{z}_t$.
An example formulation can be given by:

$$
q(\boldsymbol{z}_{1:T},\boldsymbol{y}_{1:T}) =
\prod_{t=1}^T
\mathcal{N}
\left(\boldsymbol{z}_t|
\boldsymbol{m}(\boldsymbol{y}_t;\boldsymbol{\phi}),
\boldsymbol{S}(\boldsymbol{y}_t;\boldsymbol{\phi})
\right)
$$

This distribution captures the independent nature between the states, $p(\boldsymbol{z}_t,\boldsymbol{z}_{1:t-1}) = p(\boldsymbol{z}_t)$.

***
### Markovian

Another option is to do a linear transformation of the previous state and the current observation.

$$
q(\boldsymbol{z}_{0:T},\boldsymbol{y}_{1:T}) =
\mathcal{N}(\boldsymbol{z}_0|\boldsymbol{\mu}_0,\boldsymbol{\Sigma})
\prod_{t=1}^T
\mathcal{N}\left(\boldsymbol{z}_t|
\boldsymbol{m}(\boldsymbol{y}_t,\boldsymbol{z}_{t-1};\boldsymbol{\phi}),
\boldsymbol{S}(\boldsymbol{y}_t,\boldsymbol{z}_{t-1};\boldsymbol{\phi})
\right)
$$

This distribution captures the Markovian nature between states, $p(\boldsymbol{z}_t,\boldsymbol{z}_{1:t-1}) = p(\boldsymbol{z}_t|\boldsymbol{z}_{t-1})$.

***
### Autoregressive

$$
q(\boldsymbol{z}_{0:T},\boldsymbol{y}_{1:T}) =
\mathcal{N}(\boldsymbol{z}_0|\boldsymbol{\mu}_0,\boldsymbol{\Sigma})
\prod_{t=1}^T
\mathcal{N}\left(\boldsymbol{z}_t|
\boldsymbol{m}(\boldsymbol{y}_t,\boldsymbol{z}_{1:t-1};\boldsymbol{\phi}),
\boldsymbol{S}(\boldsymbol{y}_t,\boldsymbol{z}_{1:t-1};\boldsymbol{\phi})
\right)
$$

This distribution captures the auto-regressive nature between the states, $p(\boldsymbol{z}_t,\boldsymbol{z}_{1:t-1}) = p(\boldsymbol{z}_t|\boldsymbol{z}_{1:t-1})$.

***
### Bi-Directional

$$
q(\boldsymbol{z}_{0:T},\boldsymbol{y}_{1:T}) =
\mathcal{N}(\boldsymbol{z}_0|\boldsymbol{\mu}_0,\boldsymbol{\Sigma})
\prod_{t=1}^T
\mathcal{N}\left(\boldsymbol{z}_t|
\boldsymbol{m}(\boldsymbol{y}_t,\boldsymbol{z}_{1:T};\boldsymbol{\phi}),
\boldsymbol{S}(\boldsymbol{y}_t,\boldsymbol{z}_{1:T};\boldsymbol{\phi})
\right)
$$

This distribution captures the auto-regressive nature between the states, $p(\boldsymbol{z}_t,\boldsymbol{z}_{1:T}) = p(\boldsymbol{z}_t|\boldsymbol{z}_{1:T})$.



***
### Latent Encoders

$$
\boldsymbol{\mu_h}_t, \boldsymbol{\Sigma_h}_t = \boldsymbol{T}(\boldsymbol{y}_{1:T};\boldsymbol{\phi})
$$

Now, we can redo each of the above methods using this encoder structure.


***
#### Conditionally Independent Observations


$$
\begin{aligned}
\text{Data Encoder}: && &&
\boldsymbol{\mu_h}_t, \boldsymbol{\Sigma_h}_t &= \boldsymbol{T}(\boldsymbol{y}_{1:T};\boldsymbol{\phi})\\
\text{Variational}: && &&
q(\boldsymbol{z}_{1:T},\boldsymbol{y}_{1:T}) &=
\prod_{t=1}^T
\mathcal{N}
\left(\boldsymbol{z}_t|\boldsymbol{\mu_h}_t,\boldsymbol{\Sigma_h}_t\right)
\end{aligned}
$$

This is referred to as the RNN Mean-Field encoder because the outputs are independent of the posterior.


***
#### Markovian

$$
\begin{aligned}
\text{Data Encoder}: && &&
\boldsymbol{\mu_\theta}_t, \boldsymbol{\sigma_\theta}_t &= \boldsymbol{T}(\boldsymbol{y}_{1:T};\boldsymbol{\phi})\\
\text{Variational}: && &&
q(\boldsymbol{z}_{1:T},\boldsymbol{y}_{1:T}) &=
\prod_{t=1}^T
\mathcal{N}
\left(\boldsymbol{z}_t|
\boldsymbol{m}(\boldsymbol{z}_{t-1};\boldsymbol{\mu_\theta}_t),
\boldsymbol{S}(\boldsymbol{z}_{t-1};\boldsymbol{\sigma_\theta}_t)
\right)
\end{aligned}
$$

This acts as a type of hyper-network whereby the weights of the variational distribution function are given by a another neural network, the RNN.

***
#### Autoregressive


$$
\begin{aligned}
\text{Data Encoder}: && &&
\boldsymbol{\mu_\theta}_t, \boldsymbol{\sigma_\theta}_t &= \boldsymbol{T}(\boldsymbol{y}_{1:T};\boldsymbol{\phi})\\
\text{Variational}: && &&
q(\boldsymbol{z}_{1:T},\boldsymbol{y}_{1:T}) &=
\prod_{t=1}^T
\mathcal{N}
\left(\boldsymbol{z}_t|
\boldsymbol{m}(\boldsymbol{z}_{1:t-1};\boldsymbol{\mu_\theta}_t),
\boldsymbol{S}(\boldsymbol{z}_{1:t-1};\boldsymbol{\sigma_\theta}_t)
\right)
\end{aligned}
$$