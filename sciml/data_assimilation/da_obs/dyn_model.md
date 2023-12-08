# Dynamical Model

Now, we're going back to basics.

Assume we have a physical model

$$
\partial_t \boldsymbol{u} = \boldsymbol{f}(\boldsymbol{u}_{t-1},t;\boldsymbol{\theta})
$$

We can solve this using classical PDEs

$$
\boldsymbol{u}_t = \text{ODESolve}(f, u_0, t, \theta)
$$

### Data

$$
\mathcal{D} = \{ y_t \}_{t=1}^T  \hspace{10mm} y_t\in\mathbb{R}^{D_y}
$$

### Model



$$
\begin{aligned}
\text{Initial}: && &&
\boldsymbol{u}_0 &\sim \mathcal{N}(\boldsymbol{u}_0|\boldsymbol{u}_b, \boldsymbol{\Sigma}_b)\\
\text{Dynamical Model}: && &&
\boldsymbol{u}_t &= \text{ODESolve}(f, u_{t-1}, t-1, \theta) \\
\text{Observation Model}: && &&
\boldsymbol{y}_t &= \boldsymbol{h}(\boldsymbol{u}_{t},t;\boldsymbol{\theta}) + \boldsymbol{\varepsilon_y} \\
\end{aligned}
$$

### Criteria

$$
\mathcal{L}(\boldsymbol{\theta}) = 
\sum_{t=1}^T||y_t - h(u_t, t;\boldsymbol{\theta})||_{\Sigma_y^{-1}}^2
+ ||u_0 - \boldsymbol{u}_b||_{\boldsymbol{\Sigma}_b^{-1}}^2
$$

Here, the parameters are

$$
\boldsymbol{\theta} = \{ \boldsymbol{\theta}, \boldsymbol{u}_b, \boldsymbol{\Sigma}_b \}
$$


## Latent Dynamical Model


### Model

$$
\begin{aligned}
\text{Initial Latent Dist.}: && &&
\boldsymbol{z}_0 &\sim p(\boldsymbol{z}_{0}|\boldsymbol{\theta})\\
\text{Latent Dynamical Model}: && &&
\boldsymbol{z}_t &= \boldsymbol{f}(\boldsymbol{z}_{t-1},t;\boldsymbol{\theta}) + \boldsymbol{\varepsilon_z} \\
\text{Observation Model}: && &&
\boldsymbol{y}_t &= \boldsymbol{h}(\boldsymbol{z}_{t},t;\boldsymbol{\theta}) + \boldsymbol{\varepsilon_y} \\
\end{aligned}
$$

### Criteria

$$
\mathcal{L}(\boldsymbol{\theta}, \boldsymbol{\phi};\mathcal{D}) = 
\sum_{t=1}^T\mathbb{E}_{q_\phi(\boldsymbol{z}_{t-1})}\left[\log p_\theta(\boldsymbol{z}_t|\boldsymbol{z}_{t-1}) +
\log p_\theta(y_t|z_t) - \log q_\phi(z_t|z_{t-1})
\right]
$$

where

$$
\begin{aligned}
\text{Prior}: && && p(\boldsymbol{z}_t|\boldsymbol{z}_{t-1};\boldsymbol{\theta}) 
&= \mathcal{N}(\boldsymbol{z}_t|\boldsymbol{f_{\theta_e}}(\boldsymbol{z}_{t-1});)
\end{aligned}
$$