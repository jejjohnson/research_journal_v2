---
title: Learning vs Estimation Example - Density Estimation
subject: ML4EO
short_title: Ex I - Density Estimation
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

For example, let's say I want to see if I can model temperature.
In other words, I want to find the best parameters given 
I assume there is some model that can do this for me.
$$
\text{Temperature} = \text{Model}\left(\text{Parameters}\right)
$$
The model could be a statistical model or a physics-based model.
It's most likely that it is a statistical model because temperature in a vacuum without any observations is a hard thing to draw any physical conclusions.
However, I don't really know the model or the parameters of the model.
So I need to get some observations of temperature and humidity
$$
\text{Data} = \left\{ \text{Temperature}\right\}
$$

## I - Learning Problem


***
### Data

Let's say that I want to model the joint distribution of Temperature.
First, I need to collect some observations of temperature

$$
\begin{aligned}
\text{Data}: && &&
\mathcal{D} &= \{ y_n \}_{n=1}^N
\end{aligned}
$$

```python
# get data
y: Vector["N"] = get_data(...)
```

***
### Model

Now, I assume a model.
Let's assume that I can perfectly model my temperature observations via a Gaussian distribution.

$$
\begin{aligned}
\text{Model}: && &&
y &= \mu + \varepsilon, &&
\varepsilon \sim \mathcal{N}(0, \sigma^2)
\end{aligned}
$$

Now, to translate this into a probabilistic interpretation, we can write this as a likelihood.

```python
def model(params) -> Model:
    # extract parameters
    mu, sigma = params["mu"], params["sigma"]
    # initialize Gaussian
    model = Gaussian(mu, sigma)
    return model
```

$$
\begin{aligned}
\text{Data Likelihood}: && &&
y &\sim p(y|\theta) =\mathcal{N}(y|\mu,\sigma^2)
\end{aligned}
$$

So in this case, we see that our parameters are the mean and standard deviation

$$
\theta = \left\{\mu, \sigma \right\}
$$

Now, we can also put a prior on the parameters

$$
\theta \sim \text{Uniform}[-\infty,\infty]
$$



$$
\begin{aligned}
\text{Joint Distribution}: && &&
p(y,\theta) &= p(y|\theta)p(\theta) \\
\text{Posterior}: && &&
p(\theta|\mathcal{D}) &\propto p(y|\theta)p(\theta)
\end{aligned}
$$

***
### Criteria

To get a criteria, there is a general form that one could use. 
However, we will be Bayesian about it.
We are interested in the posterior, i.e., we want the best parameters given our data.
$$
\begin{aligned}
\text{Posterior}: && &&
p(\theta|\mathcal{D}) &\propto p(y|\theta)p(\theta)=\exp(-L(\theta;y))
\end{aligned}
$$
Because we are in Bayesian territory, we can use the MLE estimation


$$
\begin{aligned}
\text{Objective Function}: && &&
\log p(\theta|\mathcal{D}) &=
-L(\theta;y) = p(y|\theta) + p(\theta)
\end{aligned}
$$

```python
def objective_fn(params: PyTree, y: Vector["N"]) -> Scalar:
    # initialize model
    model = initialize_model(params)
    # calculate log probability from observations
    loss = log_probability(model, y)
    # return loss
    return loss
```

***
### Inference Method

Now we can minimize our objective

$$
\begin{aligned}
\text{Objective}: && &&
\theta^* &= \underset{\theta}{\text{argmin}} \hspace{2mm}
L(\theta;y)
\end{aligned}
$$

```python
# initialize parameters
params_init: PyTree = ...
num_iterations: int = 1_000
# optimize parameters
params = minimize_objective(
    objective_fn, 
    params_init, 
    num_iterations
)
```

***
## II - Estimation Problem

### Data

Now, let's say we get some new observations of temperature
$$
\begin{aligned}
\text{New Data}: && &&
\mathcal{D}' &= \left\{y_n'\right\}_{n=1}^{N_{test}}
\end{aligned}
$$

### Model


So in this case, I believe that the new parameters is some new combination of the older parameters.
So I'm effectively looking for the change in parameters.

$$
u \sim p(u|\theta)
$$


### Criteria

Now, we are interested in estimating
$$
\begin{aligned}
\text{Objective}: && &&
\theta^* &= \underset{\theta}{\text{argmin}} \hspace{2mm}
J(\theta;y)\\
\text{Objective Function}: && &&
J(\theta;y) &= p(y|\theta)p(\theta) = p(y|\theta)p(\theta|\mathcal{D})
\end{aligned}
$$

### Inference Method

To keep things simple, I will use some optimization method which simply minimizes the objective function.


```python
# initialize parameters
params_init: PyTree = params
num_iterations: int = 1_000
# optimize parameters
params = minimize_objective(
    objective_fn, 
    params_init, 
    num_iterations
)
```