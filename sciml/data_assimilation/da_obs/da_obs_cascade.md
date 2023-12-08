# Cascading Approaches


### Interpolator + DA


---

**1. Train NerF on Observations**

Assume we have a dataset of independent observations, $y_n$, on the observation domain $(\Omega_y,\mathcal{T}_y)$. 

$$
\begin{aligned}
\mathcal{D}=\{(x_n,t_n),y_n\}_{n=1}^N, && && 
x\in\Omega_y\subseteq\mathbb{R}^{D_s} &&
t\in\mathcal{T}_y\subseteq\mathbb{R}^+
\end{aligned}
$$

We train a neural field, $f_\theta$, to interpolate the observation wrt the spatiotemporal coordinate values.


$$
\begin{aligned}
y_n &= f_\theta(x_n, t_n) + \varepsilon_n
\end{aligned}
$$



---

**2. Train Strong Constrained DA with NerF**


$$
\begin{aligned}
\boldsymbol{u}_0 &\sim \mathcal{N}(\boldsymbol{u}_b,\boldsymbol{\Sigma}_b)\\
\boldsymbol{u}_t &= \boldsymbol{f_\theta}\left( \boldsymbol{u}_{t-1},t\right)\\
\boldsymbol{y}_t &= \boldsymbol{h_\theta}(\boldsymbol{u}_t, t) + 
\boldsymbol{\varepsilon}_y, && && 
\boldsymbol{\varepsilon}_y \sim \mathcal{N}(0,\boldsymbol{\Sigma_y})
\end{aligned}
$$

We can estimate the state by minimizing the objective function

$$
\mathcal{J}(u) = 
\sum_{t=1}^T||\boldsymbol{y_\theta}(t)  - h_\theta(u_t,t)||_{\boldsymbol{\Sigma_y}^{-1}}^2 +
||\boldsymbol{u}_0 - \boldsymbol{u}_b||_{\boldsymbol{\Sigma}_b^{-1}}^2
$$

---
**3. Train NerF**

Assume we have a dataset of independent reanalysis points, $u_n^*$, on the observation domain $(\Omega_y,\mathcal{T}_u)$. 

$$
\begin{aligned}
\mathcal{D}=\{(x_n,t_n),u_n^*\}_{n=1}^N, && && 
x\in\Omega_z\subseteq\mathbb{R}^{D_s} &&
t\in\mathcal{T}_z\subseteq\mathbb{R}^+
\end{aligned}
$$

We train a neural field, $f_\theta$, to interpolate the observation wrt the spatiotemporal coordinate values.


$$
\begin{aligned}
\boldsymbol{u}^*(x_n, t_n) &= f_\theta(x_n, t_n) + \varepsilon_n, 
&& &&
\mathbf{x}\in\Omega_z\subseteq\mathbb{R}^{D_s}
\end{aligned}
$$


---

**5. Train Weak-Constrained DA**


$$
\begin{aligned}
\boldsymbol{u}_0 &\sim \mathcal{N}(\boldsymbol{u}_b,\boldsymbol{\Sigma}_b)\\
\boldsymbol{u}_t &= \boldsymbol{f_\theta}\left( \boldsymbol{u}_{t-1},t\right), && && 
\boldsymbol{\varepsilon}_u \sim \mathcal{N}(0,\boldsymbol{\Sigma_u}) \\
\boldsymbol{y}_t &= \boldsymbol{h_\theta}(\boldsymbol{u}_t, t) + 
\boldsymbol{\varepsilon}_y, && && 
\boldsymbol{\varepsilon}_y \sim \mathcal{N}(0,\boldsymbol{\Sigma_y})
\end{aligned}
$$

We can estimate the state by minimizing the objective function

$$
\mathcal{J}(u) = 
\sum_{t=1}^T||\boldsymbol{y_\theta}(t)  - h_\theta(u_t,t)||_{\boldsymbol{\Sigma_y}^{-1}}^2 +
\sum_{t=1}^T||\boldsymbol{u_\theta}(t)  - \boldsymbol{f_\theta}\left( \boldsymbol{u}_{t-1},t\right)||_{\boldsymbol{\Sigma_u}^{-1}}^2 +
||\boldsymbol{u}_0 - \boldsymbol{u}_b||_{\boldsymbol{\Sigma}_b^{-1}}^2
$$

---

### Interpolator + Foundational Models

**2. Train Embedding on NerF**

Assume we have a dataset of sequential, independent observations, $y_t$, which is given by the neural field, $f_\theta$.
However, we query the functa on the latent domain, $(\Omega_z, \mathcal{T}_z)$.

$$
\begin{aligned}
\boldsymbol{y_\theta}(t)&=\boldsymbol{f_\theta}(\mathbf{X}_z,t), && && 
\mathbf{X}_z\in\mathbb{R}^{D_{\Omega_z}} &&
t\in\mathcal{T}_z\subseteq\mathbb{R}^+
\end{aligned}
$$

where $\mathbf{X}_z = \{ \mathbf{x}\in\Omega_z\in\mathbb{R}^{D_s}\}$. 
We can create a dataset by (quasi-)randomly selecting points

$$
\mathcal{D}=\{ \boldsymbol{y_\theta}(t) \}_{t=1}^T
\hspace{10mm}
$$

We train an embedding on the latent domain, $z$, using the Neural Field. 
We can also apply a random mask, $\boldsymbol{m}$, to help augment the data by randomly masking pixels.

$$
\mathcal{L}(\theta) = 
\frac{1}{|\mathcal{D}|}\sum_{t\in\mathcal{D}}
||\boldsymbol{y_\theta}(t) - T_D\circ T_E\circ \boldsymbol{m}\circ \boldsymbol{y_\theta}(t)||^2_2
$$

### Latent Variable

1. Train (Masked) AutoEncoder on Simulations
2. PnP for Real Observations
3. Train AutoEncoder on Sparse Observations
2. Train Variational AutoEncoder (Probabilistic Reconstruction)
3. Train U-Net (DEQ)