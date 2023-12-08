# SurVAE Flows


## Flow Model




## Inverse Flow Model


---
### Sample w/ Log Prob

```python
# base distribution, z ~ q(z)
base_dist: Dist = Gaussian(mean=..., variance=...)
# Decoder/Likelihood, y ~ p(y|x,t,z)
decoder: Dist = Gaussian(mean_fn=..., scale=...)

# number of samples
num_samples: int = ...

z_sample, log_prob = base_dist.sample_with_log_prob(...)

# ============================================
# Under the hood
# ============================================
# sample from base distribution, z ~ q(z)
z_sample: Array["Dz"] = base_dist.sample()
# calculate log probability, log q(z)
log_prob: Array[""] = base_dist.log_prob(z_sample)
# ============================================

# transform with likelihood model, y ~ p(y|x,t,z)
# y = f(z|x,t)
# log |det J| = df(z|x,t)/dz
# log p_y(y|x,t) = log p_z(f(z|x,t)) + log |det J|
y, ldj = transform(z_sample, context=[x,t]) 

# ============================================
# Under the hood
# ============================================
# calculate mean function, emb = f(x,t)
mean: Array["Dy"] = mean_fn(x, t)
# init conditional dist, p(z|emb)
dist: Dist = Gaussian(mean=mean, scale=...)
# sample from dist
y_sample: Array["Dy"] = dist.rsample()
# calculate log prob, N(y|)
log_prob: Array[""] = dist.log_prob(z_sample)
# ============================================

# get log probability
log_prob: Array["Dz"] -= ldj
```