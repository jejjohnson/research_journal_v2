---
title: Data-Driven StoryLines
subject: Available Datasets in Geosciences
short_title: DD StoryLines
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



***
## Variables


***
### Quantity of Interest

Our quantity of interest is temperature.

$$
\text{Quantity of Interest} = 
\left[ 
\text{Temperature}
\right]
$$
So we can write this as:
$$
\begin{aligned}
\text{Quantity of Interest}: && &&
\boldsymbol{u}&=\boldsymbol{u}(\mathbf{s},t) && &&
\boldsymbol{u}: \mathbb{R}^{2}\times\mathbb{R}^+\rightarrow\mathbb{R}
\end{aligned}
$$

***
### Covariates

We choose some Covariates (aka drivers) that we believe are 

$$
\text{Covariates} = 
\begin{bmatrix}
\text{Sea Surface Temperature} \\
\text{Soil Moisture} \\
\text{Geopoential @ 500}
\end{bmatrix}^\top
\text{}
$$
So we can write this as

$$
\begin{aligned}
\text{Covariates}: && &&
\boldsymbol{x}=\boldsymbol{x}(\mathbf{s},t) && &&
\boldsymbol{x}:\mathbb{R}^{2}\times\mathbb{R}^+ \rightarrow\mathbb{R}^3
\end{aligned}
$$


***
## Algorithm

- Load Data
- Subset - Variables, Region, Period
- Remove Climatology - Time
- Resample - Time, Space
- Aggregation - Space
- Aggregation - Time
- Convert to Samples


### PseudoCode

```python
# load datacube
# Dims: “Model Variable Ensemble Time Latitude Longitude”
u: xr.Dataset = xr.open_mfdataset(list_of_files)

# subset variables, region, period
variables: List[str] = ["t2m", "sst", "z500", "tmax"]
period: Period = Period(time=slice(t0,t1))
region: Region = init_region("spain")
u: xr.Dataset = select(u, variables, region, period)

# remove climatology
u: xr.Dataset = remove_climatology(u, **params)

# resample time, space
u: xr.Dataset = resample_time(u, **params)
u: xr.Dataset = resample_space(u, **params)

# Split Period
period0 = select_period("present")
period1 = select_period("future")
u0 = select(u, period0)
u1 = select(u, period1)

# spatial averaging
# Dims: “Model Variable Ensemble Time”
u0 = spatial_average(u0, **params)
u1 = spatial_average(u1, **params)

# temporal average
u0 = temporal_average(u0, **params)
u1 = temporal_average(u1, **params)

# convert to samples
new_dims: str = "(Model Ensemble)=Samples"
# Dims: “Samples Variable Time”
u: xr.Dataset = rearrange(u, new_dims)
```

## Model

Some key characteristics of the data that we're dealing with stem from the preprocessing steps. 
In the end, we are left with $N$ samples where $N$ is the number of models and ensembles.
This leaves us with 30+ points to work with.

**Small Data**. 
We have less than 50 samples.
This limits the need for a high representation power because we do not want to overfit.



**Interpretable**.
We are using a *risk-based* approach to climate attribution.
So, when we make predictions, we need to be able to interpret the results and the model.
It would be advantageous if the model matches some underlying scientific understanding of the results.
However, there could also be some new insights.

**Uncertainty**.
We need to quantify the uncertainty in our predictions and model parameters.
This will be necessary for small datasets.

***
## Previous Work

This is based on the paper by [[Zappa & Sheperd, 2017](https://doi.org/10.1175/JCLI-D-16-0807.1)].
I outline the methodology below.
This assumes the data is a field representations

$$
\begin{aligned}
\mathcal{D} &= \{ \mathbf{u}_m, \mathbf{x}_m\}_{m=1}^M, && &&
\mathbf{u}_m\in\mathbb{R}^{D_\Omega} &&
\mathbf{x}_m\in\mathbb{R}^{D_x}
\end{aligned}
$$

They also assume that every dimension for the QoI has a set of parameters.

$$
p(u,\mathbf{x},\boldsymbol{\theta}) =
\prod_{m=1}^M\prod_{n=1}^{N_s} p(u_{mn}|\mathbf{x}_m,\boldsymbol{\theta}_n)
p(\boldsymbol{\theta}_n)
$$

They assume a functional form

$$
\begin{aligned}
\mathbf{u}_m &= \boldsymbol{f}(\mathbf{x}_m,\boldsymbol{\theta}) + \varepsilon_m,
&& && \varepsilon_m \sim \mathcal{N}(0,\sigma^2)
\end{aligned}
$$

So, the authors are interested in find a parametric function that maps the covariates to the spatial field.
However, this is a difficult problem because we are mapping a 3D parameter to a $D_\Omega$ spatial field. 
In other words, we have to map a low-dimensional vector to a high-dimensional spatial field. 
In addition, we don't have many samples.
To combat this, the users use a simple linear model.

$$
\boldsymbol{f}: \mathbb{R}^{D_x}\times\mathbb{R}^{D_\theta}\rightarrow\mathbb{R}^{D_\Omega}
$$

The function they employ was a simple additive linear model

$$
\boldsymbol{f}(\mathbf{x},\boldsymbol{\theta})=\mathbf{w}\mathbf{x} + \mathbf{b} 
$$

where $\mathbf{w}\in\mathbb{R}^{D_\Omega\times D_x}$ and $\mathbf{b}\in\mathbb{R}^{D_x}$.

Next, they did some sensitivity analysis whereby they query.
They can do this by taking the derivative of the function, $f$, wrt the input parameter, $x$.

$$
\boldsymbol{J}[\boldsymbol{f},\mathbf{x}] = \partial_\mathbf{x}\boldsymbol{f}(\mathbf{x},\boldsymbol{\theta})=\mathbf{w}
$$


Since this is a linear model, we can calculate this in closed-form.

$$
\partial_\mathbf{x}\boldsymbol{f}(\mathbf{x},\boldsymbol{\theta})=\mathbf{w}
$$

In addition, they query the function, $f$, with a distribution of input parameters, $\mathbf{x}$

$$
\begin{aligned}
\mathbf{x}_n &\sim p(\mathbf{x}) \\
\mathbf{u}_n &= \boldsymbol{f}(\mathbf{x}_n,\boldsymbol{\theta})
\end{aligned}
$$

***
### Potential Improvements

**Uncertainty Quantification**.
UQ is very important for decision-making. 
In addition, there is very little data so it is important to quantify the parameters and predictive uncertainty.

**Sensitivity Analysis**.
They don't express the notion of sensitivity analysis clearly.
While it is implicit in their formulation, I think there is more work that can be done to look at the SA literature and draw ideas from there. 
In addition, a more general form would be beneficial to the community.
Especially because we can use modern tools like auto-differentiation which would work for many model.

**Improved Modeling**.
We could also improve the modeling.
I outline more about this below. 

***

### Candidate Models

$$
\begin{aligned}
\text{Bayesian Model}: && &&
p(u,\boldsymbol{x},\boldsymbol{\theta}) &= 
p(u|,\boldsymbol{\theta})
p(\boldsymbol{\theta}) \\
\text{Hierarchical Bayesian Model}: && &&
p(u,\boldsymbol{x},\boldsymbol{z},\boldsymbol{\theta}) &= 
p(u|\boldsymbol{z})
p(\boldsymbol{z}|\boldsymbol{x},\boldsymbol{\theta})
p(\boldsymbol{\theta}) \\
\text{Gaussian Process}: && &&
p(u,\boldsymbol{f},\mathbf{X},\boldsymbol{\theta}) &= 
p(u|\boldsymbol{f})
p(\boldsymbol{f}|\mathbf{X},\boldsymbol{\theta})
p(\boldsymbol{\theta}) \\
\text{Neural Fields}: && &&
p(u,x,s,\theta) &= p(u|x,s,\theta)p(\theta)
\end{aligned}
$$


**Bayesian Regression Model**.
Our first choice is to use a simple Bayesian regression model. 
For more information, see the [prediction tutorial](../../abstractions/learning_vs_estimation/lve_predictions.md).

**Hierarchical Bayesian Regression Model**.
A second choice is to use a more advance Bayesian regression model where we include *latent variables*.
This tries to account for unseen variables that are not within the data.
While it is less interpretable than the standard Bayesian regression model, it may be more accurate by incorporating more sources of uncertainty.

**Gaussian Process Regression Model**.
The last choice is a non-parametric method.
It assumes an underlying function and then conditions on all of the observations.
This method has good predictive uncertainty with well calibrated confidence intervals.
These methods are typically more challenging to apply at scale but they work exceptionally well with small data sources.


***
#### Global Latent Variable Model

**Joint Distribution**
$$
p(u,x,\theta) = p(u|x,\theta)p(\theta) = p(\theta)\prod_{m=1}^M p(u_m|x_m,\theta)
$$



**Probabilistic Model**

$$
\begin{aligned}
\text{Data Likelihood}: && &&
u_{m} &\sim p(u|\mathbf{x},\boldsymbol{\theta}) \\
\text{Prior}: && &&
\boldsymbol{\theta} &\sim p(\boldsymbol{\theta})
\end{aligned}
$$


**Model**

$$
\begin{aligned}
u_{m} = \boldsymbol{f}(\mathbf{x}_m,\boldsymbol{\theta}) + \varepsilon_m, && &&
\varepsilon_m\sim\mathcal{N}(0,\sigma^2_)
\end{aligned}
$$

**Operators**

$$
\begin{aligned}
\text{Function}: && &&
\boldsymbol{f}&:\mathbb{R}^{D_x} \rightarrow \mathbb{R} \\
\text{Gradient}: && &&
\partial_x\boldsymbol{f}&:\mathbb{R}^{D_x} \rightarrow \mathbb{R}^{D_x}
\end{aligned}
$$



***
#### Local Latent Variable Model

In this case, we do not do any pooling.

**Joint Distribution**
$$
p(u,x,z,\theta) = p(u|z)p(z|\theta)p(\theta) = 
\prod_{m=1}^M \prod_{n=1}^{N_s} 
p(u_{mn}|\mathbf{z}_{mn})p(\mathbf{z}_{mn}|\mathbf{x}_n,\theta_n)p(\theta_n)
$$


**Probabilistic Model**

$$
\begin{aligned}
\text{Data Likelihood}: && &&
u_{mn} &\sim p(u_n|z_n) \\
\text{Process Likelihood}: && &&
z_{n} &\sim p(z|\mathbf{x}_m,\boldsymbol{\theta}) \\
\text{Prior}: && &&
\boldsymbol{\theta} &\sim p(\boldsymbol{\theta})
\end{aligned}
$$

**Model**

$$
\begin{aligned}
u_{mn} &= z_{mn} + \varepsilon_m, && &&
\varepsilon_m\sim\mathcal{N}(0,\sigma^2_u) \\
z_{n} &= \boldsymbol{f}(\mathbf{x}_m,\boldsymbol{\theta}_n) + \varepsilon_n, && &&
\varepsilon_n\sim\mathcal{N}(0,\sigma^2_z) \\
\end{aligned}
$$

**Operators**

$$
\begin{aligned}
\text{Function}: && &&
\boldsymbol{f}&:\mathbb{R}^{D_x} \rightarrow \mathbb{R} \\
\text{Gradient}: && &&
\partial_x\boldsymbol{f}&:\mathbb{R}^{D_x} \rightarrow \mathbb{R}^{D_x}
\end{aligned}
$$




***
**Hierarchical Latent Variable Model**

In this case, we do partial pooling.

**Joint Distribution**
$$
p(u,x,z,\theta) = p(u|z)p(z|\theta)p(\theta) = 
p(\theta)\prod_{m=1}^M \prod_{n=1}^{N_s} 
p(u_{mn}|\mathbf{z}_{mn})p(\mathbf{z}_{mn}|\mathbf{x}_n,\theta)
$$


**Probabilistic Model**

$$
\begin{aligned}
u_{mn} &\sim p(u_{mn}|z_n, x_m)\\
z_{n} &\sim p(u_{mn}|z_n)\\
\end{aligned}
$$


**Model**

$$
\begin{aligned}
u_{mn} &= z_{mn} + \varepsilon_m, && &&
\varepsilon_m\sim\mathcal{N}(0,\sigma^2_u) \\
z_{mn} &= \boldsymbol{f}(\mathbf{x}_n,\boldsymbol{\theta}) + \varepsilon_m, && &&
\varepsilon_m\sim\mathcal{N}(0,\sigma^2_z) \\
\end{aligned}
$$

**Operators**

$$
\begin{aligned}
\text{Function}: && &&
\boldsymbol{f}&:\mathbb{R}^{D_x} \rightarrow \mathbb{R} \\
\text{Gradient}: && &&
\partial_x\boldsymbol{f}&:\mathbb{R}^{D_x} \rightarrow \mathbb{R}^{D_x}
\end{aligned}
$$





#### PseudoCode - **From Scratch**


```python
# get inputs
x: Array["M D"] = ...
s: Array["N"] = ...
u: Array["N"] = ...

# get dimensions
num_models, num_dims = x.shape
num_spatial_points = s.shape

# scratch
sigma_z: Array["N"] = sample("noise_z", dist, num_samples=N)
weight_z: Array["N D"] = sample("weight", dist, num_samples=N)
bias_z: Array["N"] = sample("bias", dist, num_samples=N)
# z = w x + b + noise
z: Array["M N"] = einsum("ND,MD->MN", weight_z, x)
z += b + sigma_z
sigma_u: Array["M N"] = sample("noise_u", dist, num_samples=(M, N))
u: Array["M N"] = sample("obs", dist.Normal(z, sigma_u), obs=u)
```



#### PseudoCode - **Plate Notation**

```python
# get inputs
x: Array["M D"] = ...
s: Array["N"] = ...
u: Array["M N"] = ...

# create plate for spatial domain
spatial_plate = plate(num_spatial_points)
model_plate = plate(num_models)

with spatial_plate:
  sigma_z: Array[""] = sample("noise_z", dist)
  weight_z: Array["D"] = sample("weight", dist)
  bias_z: Array[""] = sample("bias", dist)
  
  with model_plate:
    # z = w x + b + noise
    z: Array[""] = einsum("D,D->", x, weight_z) + b + sigma_z
    sigma_u: Array[""] = sample("noise_u", dist)
    u: Array[""] = sample("obs", dist.Normal(z, sigma_u), obs=u)
```

***
#### Gaussian Process Model


**Joint Distribution**
$$
\begin{aligned}
p(u,x,z,f,s,\theta) &= p(u|z)p(z|f,x,\theta)p(f|s,\alpha)p(\theta)p(\alpha)\\
&= 
p(\theta)p(\alpha)\prod_{m=1}^M \prod_{n=1}^{N_s} 
p(u_{mn}|\mathbf{z}_{n})p(\mathbf{z}_{n}|\mathbf{x}_m, \boldsymbol{f}_n, \boldsymbol{\theta})
p(\boldsymbol{f}_n|\mathbf{s}_n,\boldsymbol{\alpha})
\end{aligned}
$$


**Probabilistic Model**

$$
\begin{aligned}
\text{Data Likelihood}: && &&
u_{mn} &\sim p(u_n|z_nm,) \\
\text{Process Likelihood}: && &&
z_{n} &\sim p(z|\mathbf{x}_m,\boldsymbol{\theta}) \\
\text{Prior}: && &&
\boldsymbol{\theta} &\sim p(\boldsymbol{\theta})
\end{aligned}
$$

```python
# get the 
S: Array["N S"] = ...
X: Array["M Dx"] = ...
U: Array["M Dx"] = ...

# initialize parameters
theta_f: Array[""] = sample(dist)
sigma: Array[""] = sample(dist)
B: Array["N D"] = sample(dist)
K: Array["N N"] = kernel(theta_f)

with plate("models", M):
  # initialize mean model
  Bx: Array["N"] = einsum("ND,D->N",B,x)
  # initialize GP model
  gp: Model = GaussianProcess(kernel, S, diag=sigma, Bx)
  # sample from GP Model
  u: Array["N"] = sample("f", gp.sample(), obs=u)

```

***
## Back to Basics


**Discrete Field Representation**

We have the data in the form of a field.

$$
\begin{aligned}
\mathcal{D} &= \{ \mathbf{u}_m, \mathbf{x}_m \}_{m=1}^M && &&
\mathbf{u}_m\in\mathbb{R}^{D_\Omega} && &&
\mathbf{x}_m\in\mathbb{R}^{D_x}
\end{aligned}
$$

Now, our target problem is:

$$
\boldsymbol{f}: \mathbb{R}^{D_x}\rightarrow\mathbb{R}^{D_\Omega}
$$

**Coordinate Representation**

We have the data in the form of coordinates

$$
\begin{aligned}
\mathcal{D} &= \{ (s_n,u_n)_m, \mathbf{x}_m \}_{m=1,n=1}^{M,N_s} && &&
\mathbf{s}_n\in\mathbb{R}^{D_s} &&
\mathbf{x}_m\in\mathbb{R}^{D_x} &&
u_{mn}\in\mathbb{R}
\end{aligned}
$$

Now, we have our target problem

$$
\boldsymbol{f}: \mathbb{R}^{D_s}\times\mathbb{R}^{D_x}\times\mathbb{R}^{D_\theta}
\rightarrow\mathbb{R}^{D_u}
$$


