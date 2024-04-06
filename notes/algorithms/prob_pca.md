---
title: Probabilistic PCA
subject: Machine Learning for Earth Observations
short_title: Probabilistic PCA
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



## Context 

We consider some observations, $\boldsymbol{y}$, which are multi-dimensional.

$$
\begin{aligned}
\boldsymbol{y} &=\boldsymbol{y}(\mathbf{s},t), && && 
\mathbf{s}\in\Omega\subseteq\mathbb{R}^{D_s} && &&
t\in\mathcal{T}\subseteq\mathbb{R}^+
\end{aligned}
$$


Let's say we have a group of observations:

$$
\mathcal{D} = \left\{ \mathbf{y}_n\right\}_{n=1}^N, \hspace{2mm}
\mathbf{y}_n\in\mathbb{R}^{D_\Omega}
$$

We are interested in finding a mapping


**Joint Distribution**

$$
p(\boldsymbol{y},\boldsymbol{z},\boldsymbol{\theta}) = p(\boldsymbol{y}|\boldsymbol{z},\boldsymbol{\theta})p(\boldsymbol{z}|\boldsymbol{\theta})p(\boldsymbol{\theta})
$$


## Model

$$
\begin{aligned}
\text{Data Likelihood}: && &&
\mathbf{y} &\sim \mathcal{N}(\mathbf{Wz} + \mathbf{b}, \boldsymbol{\Sigma}_\mathbf{y}) \\
\text{Prior}: && &&
\mathbf{z} &\sim \mathcal{N}(0,1)
\end{aligned}
$$

**Probabilistic PCA**: Assumes a scalar value for the covariance

$$
\boldsymbol{\Sigma}_\mathbf{y}=\sigma^2\mathbf{I}
$$

**Factor Analysis**: Assumes a diagonal matrix

$$
\boldsymbol{\Sigma}_\mathbf{y}=\sigma_d^2\mathbf{I}
$$

## Uniqueness

* Enforce that rows of $W$ have a norm of 1
* Enforce that rows of $W$ are orthogonal
* Fit the rows of $W$ sequentially


## Minimization Problem


**Least Squares**

$$
\boldsymbol{J}(\boldsymbol{z};\boldsymbol{\theta}) = ||\mathbf{y} - \mathbf{W}^\top\mathbf{z}||=(\mathbf{WW}^\top)^{-1}\mathbf{Wy}
$$


***
## PsuedoCode I

Here, we will do this from scratch.

#### 1 - Data


$$
\begin{aligned}
\text{Data}: && &&
\mathbf{Y}\in\mathbb{R}^{D_\Omega \times D_T}
\end{aligned}
$$



```python
# get data
y: Dataset["lat lon time"] = ...

# stack dimensions
y: Dataset["space time"] = y.stack(sample=["lat" "lon"])
```

***
#### 2 - Temporal vs Spatial EOFs

$$
\begin{aligned}
\text{Data}: && &&
\mathbf{Y}\in\mathbb{R}^{D_\Omega \times D_\text{T}} \\
\text{T-Mode}: && &&
\mathbf{Y}\in\mathbb{R}^{N_\Omega \times D_\text{T}} \\
\text{S-Mode}: && &&
\mathbf{Y}\in\mathbb{R}^{ D_\Omega \times N_\text{T}} \\
\end{aligned}
$$

Recall that **T-Mode** maximizes the spatial variance and **S-Mode** maximizes the temporal variance.


```python
# choose sample vs dimensions
y: Array["N D"] = y.rename({"space": "N", "time": "D"})
```



***
#### 3 - SVD Decomposition

Using the Singular Value Decomposition (SVD), we can decompose the matrix, $\mathbf{Y}$, like so:

$$
\begin{aligned}
\mathbf{Y} &= \mathbf{USV}^\top && &&
\mathbf{U}_\Omega\in\mathbb{R}^{D_\Omega\times D_z} &&
\mathbf{S}\in\mathbb{R}^{D_z \times D_z} &&
\mathbf{U}^\top_\text{T}\in\mathbb{R}^{D_z \times D_\text{T} } &&
\end{aligned}
$$

where $\mathbf{U}_\Omega$ is the spatial EOFs, $\mathbf{U}_\text{T}$ is the temporal EOFs, and $\mathbf{S}$ are the single values.


***
#### 4 - Eigenvalue Decomposition

Alternatively, we can decompose the matrix $\mathbf{Y}$ using the covariance matrix $\boldsymbol{\Sigma}$:

$$
\begin{aligned}
\text{Spatial Covariance}: && &&
\boldsymbol{\Sigma}_\Omega &:= \mathbf{\mathbf{YY}^\top} \in \mathbb{R}^{D_\Omega\times D_\Omega} \\
\text{Temporal Covariance}: && &&
\boldsymbol{\Sigma}_\text{T} &:= 
\mathbf{\mathbf{Y}^\top\mathbf{Y}} \in \mathbb{R}^{D_\text{T}\times D_\text{T}}
\end{aligned}
$$

```python
# covariance in space
cov_space: Array["D D"] = cov(Y, rowvar=True)
# covariance in time
cov_time: Array["T T"] = cov(Y, rowvar=False)
```

Once this is done, we can do the eigenvalue decomposition of this:

$$
\begin{aligned}
\text{Spatial Eig. Decomposition}: 
&& &&
\mathbf{U}_\Omega, \mathbf{s}_\Omega 
&= 
\text{eig}\left(\boldsymbol{\Sigma}_\Omega\right) ,
&& &&
\mathbf{U}_\Omega \in \mathbb{R}^{D_\Omega \times D_z }
&&
\mathbf{s}_\Omega  \in \mathbb{R}^{D_z }\\
\text{Temporal Eig. Decomposition}: 
&& &&
\mathbf{U}_\text{T}, \mathbf{s}_\text{T} 
&:= 
\text{eig}\left(\boldsymbol{\Sigma}_\text{T} \right),
&& &&
\mathbf{U}_\text{T} \in \mathbb{R}^{D_\text{T} \times D_z }
&&
\mathbf{s}_\text{T}  \in \mathbb{R}^{D_z }
\end{aligned}
$$

We can do this in either case.
However, we must be careful because we can get gigantic matrices.
For example, a spatiotemporal field that's `200x200x10` will result in a matrix of $\mathbf{Y}\in\mathbb{R}^{20K\times 10}$.
Subsequently, we will result get a covariance matrix of $\boldsymbol{\Sigma}_\Omega\in\mathbb{R}^{20K\times 20K}$ for the spatial components and $\boldsymbol{\Sigma}_\text{T}\in\mathbb{R}^{10\times 10}$ for the temporal components.

So combat this, we will use the eigenvalue decomposition on the cheapest covariance, i.e., the temporal covariance matrix, $\boldsymbol{\Sigma}_\text{T}$. 
From this, we can calculate the temporal EOFs, $\mathbf{U}_\text{T}$, and the eigenvalues, $\mathbf{S}$.
From this, we can recover the spatial EOFs, $\mathbf{U}_\text{T}$.
This is possible because we can do some matrix multiplication tricks on the SVD decomposition to isolate the EOFs.

$$
\begin{aligned}
\mathbf{X} &= \mathbf{USV}^\top \\
\mathbf{X}^\top &= \mathbf{VSU}^\top \\
\mathbf{X}^\top\mathbf{U} &= \mathbf{VS} \\
\mathbf{U} &= \mathbf{XVS}
\end{aligned}
$$

```python
# (SxT) = (Sxd)(dxd)(dxT)
# (TxS) = (Txd)(dxd)(dxS)
# (TxS)(Sxd) = (Txd)(dxd)
# (TxS) = (SxT)(Txd)(dxd)
U, S, V = svd(X)
V_, S_ = eig(X.T @ X)
np.testing.assert()
```

***
#### 4 - 

***
## PsuedoCode II

### Prior

$$
\begin{aligned}
\text{Weights}: && &&
\boldsymbol{w} &\sim p(\boldsymbol{w}) \\
\text{Noise}: && &&
\sigma &\sim p(\sigma) \\
\end{aligned}
$$

```python
# parameters
loc: Array["Dx"] = ...
scale: Array["Dx"] = ...
W: Array["Dx Dz"] = sample("w", dist.Normal(loc, scale))
noise: Array[""] = sample("noise", dist.Normal(0.0, 1.0))
```

### Likelihood

We will use a low-rank multivariate likelihood.

$$
\mathbf{\Sigma} = \mathbf{W}\mathbf{W}^T + \mathbf{D}
$$


```python
D: Array["Dz"] = noise * eye_like(W)
# likelihood
obs = sample("obs", dist.LowRankMVN(loc=0.0, cov_factor=W, cov_diag=D), obs="y")
```


## PseudoCode II

* Resource - [jupyter nb](https://github.com/namoshi/colab/blob/master/PPCA.ipynb) | [Edward](https://edwardlib.org/tutorials/probabilistic-pca) | [TFP](https://www.tensorflow.org/probability/examples/Probabilistic_PCA)


### Data

```python
# get data
y: Dataset["lat lon time"] = ...

# stack dimensions
y: Dataset["space time"] = y.stack(sample=["lat" "lon"])

# choose sample vs dimensions
y: Array["N D"] = y.rename({"space": "N", "time": "D"})
```

### Model

```python
Dz = 10

def model(obs: Array["N Dy"]):
    # calculate alpha, prior for weights
    rate: Array["Dz"] = ones(shape=(Dz,))
    alpha: Array["Dz"] = sample("alpha", dist.Exponential(rate=rate).to_event(1))
    # calculate W
    loc: Array["Dz"] = zeros(shape=(Dy, Dz))
    scale: Array["Dy Dy"] = einx.rearrange("Dz -> Dy Dz", alpha, Dz=Dz)
    W: Array["Dx Dz"] = sample("W", dist.Normal(loc, scale).to_event(1))
    # scale
    sigma: Array[""] = sample("sigma", dist.HalfCauchy(scale=1))
    # TODO: add bias...
    # different batches
    with numpyro.plate("samples", N):
        # latent variable
        loc = ones(shape=(Dz,))
        scale = ones(shape=(Dz,))
        z: Array["Dz"] = sample("z", dist.Normal(loc, scale).to_event(1))
        # calculate mean
        loc: Array["N Dy"] = einx.dot("N Dy, Dy Dz", W, z)
        # calculate scale
        scale: Array["Dy"] = sigma * eye(shape=(Dy,))
        y = sample.("y", dist.Normal(loc=loc, scale=scale).to_event(1), obs=obs)
```


### Inference

#### MCMC Sampling

```python
kernel = numpyro.infer.NUTS(model)
mcmc = numpyro.infer.MCMC(kernel, num_warmup=1000, num_samples=10000, thinning=5, num_chains=1)
mcmc.run(jax.random.PRNGKey(1), obs=y)
```

#### Variational Inference

```python
guide = AutoNormal(model)
```