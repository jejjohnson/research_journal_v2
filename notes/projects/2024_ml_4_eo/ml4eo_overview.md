# Overview


* Unstructured Observations to Structured Observations
* Observations to Reanalysis
* Surrogate Models for Forecasting


---
## Part I: Unstructured Observations

In this section, we want to map our unstructured observations to structured observations. 
Most of the time, the observations we receive are on the observation domain which is typically unstructured, sparse and noisy. 

$$
\begin{aligned}
\boldsymbol{y}= \boldsymbol{y}(\mathbf{x},t) && &&
\mathbf{x}\in\boldsymbol{\Omega}_y\in\mathbb{R}^{D_s} &&
t\in\mathcal{T}_y\in\mathbb{R}^{+}
\end{aligned}
$$

However, this is very difficult to deal with in practice.
Ideally, we want nice, clean observations and we also want them on the state domain.

$$
\begin{aligned}
\boldsymbol{y}= \boldsymbol{y}(\mathbf{x},t) && &&
\mathbf{x}\in\boldsymbol{\Omega}_{z}\in\mathbb{R}^{D_s} &&
t\in\mathcal{T}_z\in\mathbb{R}^{+}
\end{aligned}
$$

**Objective**. 
The objective is to find some parameterized function that maps the data from the unstructured domain $\boldsymbol{\Omega}_y\times\mathcal{T}_u$

$$
\boldsymbol{f}:
\{y\in\boldsymbol{\Omega}_y\times\mathcal{T}_y\}
\times\mathcal{\Theta}
\rightarrow 
\{y\in\boldsymbol{\Omega}_u\times\mathcal{T}_u\} 
$$


### Proposed Solutions

Below we go over a few proposed solution with increasing difficulty.


---
#### **Modern Optimal Interpolation**

This first module will implement methods that can be applied out of the box.
In general, the dataset we're dealing with just the coordinates and scaler or vector values.

$$
\mathcal{D} = \{ (\mathbf{x}_n, t_n),\boldsymbol{y}_n \}_{n=1}^N
$$

In this module, we will explore a simple way to interpolate observations onto any domain.
Our primary method of choice will be the Gaussian process, aka, OI, Kriging, etc.
This method is parameterized by a mean function, $\mu_\theta$ and a kernel function, $k_\theta$, which produces a range of different values.

$$
p(\boldsymbol{f}) \sim \mathcal{GP}(\boldsymbol{\mu_\theta},\mathbf{K}_{\boldsymbol{\theta}})
$$

We will use some of the standard methods like GPs using off the shelf
We will also explore some new methods which include Spherical Harmonics basis functions [[Dutordoir et al, 2020](
https://doi.org/10.48550/arXiv.2006.16649); [Eleftheriadis et al, 2023](
https://doi.org/10.48550/arXiv.2303.15948); [Tiao et al, 2023](
https://doi.org/10.48550/arXiv.2304.14034)] and Markovian
We will use open-source software like `GPyTorch`, `GPJax`, and `GPFy`.

---

#### **Differentiable Interpolators**

In this module, we will look at some simple differentiable interpolators which would allow users to query points from unstructured grids at any resolution. 

$$
\begin{aligned}
\boldsymbol{y}_{obs}(\mathbf{x},t) &= \boldsymbol{y_\theta}(\mathbf{x},t,\mu,\epsilon), && &&
\mathbf{x}\in\boldsymbol{\Omega}\in\mathbb{R}^{D_s} &&
t\in\mathcal{T}\in\mathbb{R}^+
\end{aligned}
$$

This can be useful as plug-n-play modules for training surrogate models or for data assimilation.
We will look at some simple ones found in off-the-shelf packages like [`interpax`](https://github.com/f0uriest/interpax) and more advanced methods like neural fields (NerFs). 
NerFs offer more advantages like scalability, stochasticity, and tailored loss functions to respect smoothness or some predefined physics.



---

**Deep Equillibrium Models**.
These models are models to directly learn the mapping from the unstructured observations to the structured representations. 
They directly try to interpolate the observations using methods like convolutions.

$$
\boldsymbol{z} = \boldsymbol{f_\theta}(\boldsymbol{z},\boldsymbol{y}_{obs},\boldsymbol{\theta})
$$


---
## Part II: Observations to Reanalysis

In this part, we learn mappings between the observations and the reanalysis data.
The observations capture a lot of physics information but we often want to embed further physics when estimating the state.
Typically, our observations are in

$$

$$

### **Objective**

The objective is to find some parameterized function that maps the observations to the state $\boldsymbol{\Omega}_u\times\mathcal{T}_u$

$$
\boldsymbol{f}:
\{y\in\boldsymbol{\Omega}_u\times\mathcal{T}_u\}
\times\mathcal{\Theta}
\rightarrow 
\{u\in\boldsymbol{\Omega}_u\times\mathcal{T}_u\} 
$$

### Proposed Solutions

**Deep Equilibrium Models**.


**Latent Variable Data Assimilation**.
In this module, we will have many pretrained 

$$
u = T_{Du}(z) \hspace{10mm}
y = T_{Dy}(z)
$$

$$
\boldsymbol{J}(z) =
||\boldsymbol{y_\theta} - \boldsymbol{h_\theta}\circ T_{Du}(z)|| + ||z||_2^2
$$

```python
z: Array["Dz"] = ...
# generate through model decoder
u_pred: Array["Du"] = model_decoder(z)
# apply interpolation to y.domain
y_pred: Array["Dy"] = interp(u_pred, u.domain, y.domain)
```




## Part III: Surrogate Reanalysis Models for Forecasting


**Differentiable Surrogate Models**.
This field is already quite saturated with different models. 
Primarily, we will look at a few key models: 1) Neural Operators, 2) GraphCast, and 3) Transformers.
We will also try to incorporate some uncertainty within the mix via probabilistic output layers [[Daxberger et al, 2022](https://doi.org/10.48550/arXiv.2106.14806)] or with flow models [[Winkler, 2023](https://doi.org/10.48550/arXiv.2311.06958)].


**Foundation Model Race**.
In this module, we will explore how we can pretrain models to arrive at better and better scales.
For example, we can pretrain with simulations and then refine it with reanalysis both at a global scale. 
Then we can start to fine-tune each model with more specific tasks like regional X-casting and super-resolution.
We can start with:
1. Pre-Train - global, climate simulations (CMIP6)
2. Fine-Tune - global, reanalysis data (ERA5/GLORYS/HYCOM)
3. Fine-Tune - regional, reanalysis data (GLORYS/HYCOM)