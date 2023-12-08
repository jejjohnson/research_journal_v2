# Interpolation

In this case, we try to directly parameterize the field.


### Data Representation

$$
\mathcal{D} =\{ (\mathbf{x}_n,t_n), \boldsymbol{y}_n \}_{n=1}^N
$$

```python
# get dataset (Coordinate based)
ds: xr.Dataset = ...

# convert to ML-ready tensor
x: Array["N"] = ds.x.values
t: Array["N"] = ds.t.values
y: Array["N D"] = ds.variable.values
```

### Model 

We assume that there is some underlying model which can be inferred from the spatiotemporal coordinates.
$$
\begin{aligned}
\boldsymbol{y}_n &= \boldsymbol{f}(\mathbf{x}_n, t_n; \boldsymbol{\theta}) + \varepsilon_n, && && \varepsilon_n \sim \mathcal{N}(0,\sigma^2)
\end{aligned}
$$

In other words, we can write this as

$$
y_n \sim \mathcal{N}
\left(y_n|\boldsymbol{f_\theta}(\mathbf{x}_n, t_n), \sigma^2 \right)
$$

```python
# initialize parameterized function
params: Params = ...
fn: Model = Model(params)

# apply function
y_pred: Array["N D"] = fn(x, t)

# initial gaussian conditional likelihood
sigma: float = ...
model: ProbModel = Gaussian(mean_fn=fn, variance=sigma**2)

# apply model N(y|f(x,t),sigma)
y_pred: Dist = model(x,t)
y_pred_mean: Array["N Dy"] = y_pred.mean()
y_pred_var: Array["N Dy"] = y_pred.variance()
y_pred_samples: Array["N Dy"] = y_pred.sample(N=10)
```

### Criteria

We can learn some underlying parameterization by finding the best parameters given some loss function, $\mathcal{L}$.

$$
\boldsymbol{\theta}^* = \underset{\boldsymbol{\theta}}{\text{argmin}}\hspace{2mm}\mathcal{L}(\boldsymbol{\theta})
$$

We can minimize the data likelihood

$$
\mathcal{L}(\boldsymbol{\theta};\mathcal{D}) = 
\frac{1}{\mathcal{D}}\sum_{n\in\mathcal{D}}\log p(\boldsymbol{y}_n|\boldsymbol{f}(\mathbf{x}_n,t_n),\sigma^2)
$$


```python
# calculate log probability
loss: Array[""] = model.log_prob(y_true)

# create loss function
loss_fn: Callable = lambda rv_y, y_true: rv_y.log_prob(y_true)
```

To train, we can use any

$$
\boldsymbol{\theta}^{k+1} = \boldsymbol{\theta}^{k} - \alpha\boldsymbol{\nabla_\theta}\mathcal{L}(\boldsymbol{\theta})
$$

```python
# initialize criteria and training regime
loss: Loss = MSE()
optimizer: Optimizer = SGD(learning_rate=0.1)

# learn parameters
params: PyTree = fit_model(
    model=model, 
    data=[[x,t], y],
    optimizer=optimizer, loss=loss
)
```

### Inference

$$
\begin{aligned}
\boldsymbol{y}_n &= \boldsymbol{f}(\mathbf{x}_n, t_n; \boldsymbol{\theta}) && && \mathbf{x}\in\Omega_z\subseteq\mathbb{R}^{D_s}
\end{aligned}
$$

```python
# get coordinates for new domain
x_new: Array["M"] = ...
t_new: Array["M"] = ...

# apply model
y_pred: Array["M D"] = model(x_new, t_new, params)
```

There are many upgrades we can do:

* Improved Loss function
* Conditional Model, $\boldsymbol{f_\theta}(x,t,\mu)$
* Heterogeneous Noise Model, $\boldsymbol{\varepsilon}(\mathbf{x},t)$


---
## Latent Interpolator

### Model

$$
\begin{aligned}
\text{Prior Dist.}: && &&
\boldsymbol{z} &\sim p_\theta(\boldsymbol{z}) = \mathcal{N}(\mathbf{0}, \mathbf{1}) \\
\text{Conditional Likelihood Dist.}: && &&
\boldsymbol{y} &\sim p_\theta(\boldsymbol{y}|\mathbf{x},t,\boldsymbol{z})=
\mathcal{N}\left(\boldsymbol{y}|\boldsymbol{f_\theta}(\mathbf{x},t, \boldsymbol{z}), \sigma^2\right)
\end{aligned}
$$

```python
# init prior model
mean: Array["Dz"] = zeros_like(...)
sigma: Array["Dz"] = ones_like(...)
prior_model: Dist = DiagGaussian(mean=mean, sigma=sigma)

z_samples: Array["N Dz"] = prior_model.sample(N=...)

# init mean function - nerf
mean_fn: Model = init_nerf(...)

x: Array["Ds"] = ...
t: Array[""] = ...
y_pred: Array["Dy"] = mean_fn(x,t,z)

# init likelihood model w/ parameterized mean fn
sigma: float = ...
likelihood_model: Dist = CondGaussian(mean_fn=fn, scale=sigma)

y_pred: Dist = likelihood_model(x, t, z)
y_pred_mean: Array["Dy"] = y_pred.mean()
y_pred_var: Array["Dy"] = y_pred.variance()
y_pred_samples: Array["N Dy"] = y_pred.sample(N=...)
log_prob: Array["Dy"] = y_pred.log_prob(y)
```

---
### Criteria

We are interested in finding the best latent variable, $z$, that fits the data, $\mathcal{D}$.
The posterior is given by:

$$
p(z|y,x,t) = \frac{1}{Z}p(y|x,t,z)p(z)
$$

We can write the criteria as the KL-Divergence between the variational distribution, $q$, and the posterior, $p(z|y)$.

$$
q^*(\boldsymbol{z}) = \underset{q\in\mathcal{Q}}{\text{argmin}}\hspace{2mm}
D_{KL}\left[ q(\boldsymbol{z})||p(\boldsymbol{z}|\boldsymbol{y}) \right]
$$

The general criteria is given by the ELBO which is an upper bound on the KLD between the variational distribution, $q$, and the prior, $p$.

$$
\mathcal{L}(\theta,\phi) =
\mathbb{E}_{z\sim q_\phi}
\left[ \log p_\theta(y|z) - \log p_\theta(z) + \log q_\phi(z)\right]
$$

However, we're going to use the Flow-based objective function which is given by:

$$
\mathcal{L}(\theta,\phi) = 
\mathbb{E}_{\boldsymbol{z}\sim q_\theta(\boldsymbol{z})}
\left[ \log p_\theta(\boldsymbol{z})\right] +
\mathbb{E}_{\boldsymbol{z}\sim q_\theta(\boldsymbol{z})}
\left[ \log \frac{p_\theta(\boldsymbol{y}|\boldsymbol{z})}{q_\theta(\boldsymbol{z})}\right]
$$

---

### Pseudo-Code


#### Forward Transformation

$$
\begin{aligned}
(y,x,t)&\sim p(\mathcal{D}) \\
\boldsymbol{z} \sim q
\end{aligned}
$$


First, we need to sample from the variational distribution

$$
\boldsymbol{z}\sim q_{\boldsymbol{\theta}}(\boldsymbol{z})
$$

```python
# init variational dist
var_dist: Dist = DiagonalGaussian(mean=..., sigma=...)

# sample from variational dist, z ~ q(z)
z_sample: Array["N Dz"] = var_dist.sample(N=...)
```

Now, we can calculate the log probability of the variational dist and the likelihood terms.

$$
\mathbb{E}_{\boldsymbol{z}\sim q_\theta(\boldsymbol{z})}
\left[ \log p_\theta(\boldsymbol{y}|\mathbf{x},t,\boldsymbol{z}) - \log q_\theta(\boldsymbol{z})\right]
$$


```python
# FORWARD TRANSFORMATION: y,x,t --> z

# sample from data distribution,
y_sample: Array["Dy"], x: Array["Ds"], t: Array[""] = Data(N=...)

# likelihood model, log p(y|x,t,z)
log_py: Array["Dy"] = likelihood_model(x, t, z_sample).log_prob(y_sample)
# var dist, log q(z)
log_pz: Array["Dy"] = var_dst.log_prob(z_sample)
ldj: Array["Dy"] = log_py - log_qz


# INVERSE TRANSFORMATION: Z --> Y
z_sample: Array["Dz"] = ...
# sample
y_sample: Array["Dy"] = likelihood_model(x, t, z_sample).sample(N=...)

```


### Inference


### All Together


```python
# 

```

---

## Amortized Model

### Data Representation

```python
# initialize domain
domain: Domain = ...

# initialize values
y_values: Array["Dx Dy"] = ...

# initialize field
y: Field["Dx Dy"] = Field(y_values, domain)
```

### Model

In this case, we assume that there is some underlying generative model that can be inferred

$$
\begin{aligned}
\text{Decoder}: && && \boldsymbol{y} &= \boldsymbol{T_D}(\boldsymbol{z}; \boldsymbol{\theta}) + \varepsilon
\end{aligned}
$$


$$
\begin{aligned}
\text{Decoder}: && && \boldsymbol{y} &\sim p(\boldsymbol{y}|\boldsymbol{z};\boldsymbol{\theta}_e) 
= \mathcal{N}(\boldsymbol{y}|\boldsymbol{T_D}(\boldsymbol{z};\boldsymbol{\theta}_e),\sigma^2) \\
\end{aligned}
$$

```python

```

$$
\begin{aligned}
\text{Encoder}: && && \boldsymbol{z} &= \boldsymbol{T_E}(\boldsymbol{y}; \boldsymbol{\theta}) 
\end{aligned}
$$


```python
# initialize decoder model
decoder_fn: Model = ...

# initialize
sigma: float = ...
prob_model: CondModel = CondGaussian(mean_fn=decoder_fn, variance=sigma**2)

# apply encoder N(z|f(y),sigma)
z: Array["Dz"] = prob_model.mean(context=y)
z: Array["Dz"] = prob_model.variance(context=y)
z: Array["N Dz"] = prob_model.sample(context=y, N=10)

# calculate loss
loss: Array[""] = prob_model.log_prob(context=y, x=z)
```

We have a constraint

$$
\boldsymbol{y} = \boldsymbol{T_D}\circ\boldsymbol{T_E}(\boldsymbol{y})
$$

```python


# initialize both
model: Model = EncoderDecoder(encoder=encoder_model, decoder=decoder_model)
params: Params = [encoder_params, decoder_params]

# apply model
y_pred: Array["Dx Dy"] = model(y, params)
```

### Criteria

$$
\mathcal{L}(\boldsymbol{\theta}) = \frac{1}{2\sigma^2}\frac{1}{N}
\sum_{n=1}^N \left(\boldsymbol{y}_n - \boldsymbol{T_D}\circ\boldsymbol{T_E}(\boldsymbol{y}) \right)^2
$$

```python


```

### Inference

```python
# get observations
y_obs: Array["Dx Dy"] = ...

# apply model
y_pred: Array["Dx Dy"] = model(y_obs, params)
```


There are many improvements to this model that we can do:

* Use a simplified linear model - PCA
* Improved Loss Function
* Stochastic Encoder


:::{tip} Training Tips
:class: dropdown
We can always do some augmentations to learn


**Regression-Like**

```python
# create augmentation functions
fn = [
    random_noise,
    resize,
    patchify,
    missing_data
]
aug_fn: Callable = make_seq_fn(fn)

# apply augmentation function
y: Array["Dx Dy"] = aug_fn(y)
```

**Image-Like**

```python
# create augmentation functions
fn = [
    random_rotate,
    random_flip,
    random_constrast,
    random_translate
]
aug_fn: Callable = make_seq_fn(fn)

# apply augmentation function
y: Array["Dx Dy"] = aug_fn(y)
```


:::

