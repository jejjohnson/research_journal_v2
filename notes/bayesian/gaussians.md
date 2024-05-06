---
title: All Things Gaussian
subject: Machine Learning for Earth Observations
short_title: Gaussian Distribution
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


## Multivariate Gaussian

$$
\mathcal{N}(\boldsymbol{u}|\boldsymbol{\mu},\boldsymbol{\Sigma}) =
\frac{1}{(2\pi)^{D/2}}
\frac{1}{|\boldsymbol{\Sigma}|^{1/2}}
\exp
\left[ 
    -\frac{1}{2}
    (\boldsymbol{u} - \boldsymbol{\mu})^\top
    \boldsymbol{\Sigma}^{-1}
    (\boldsymbol{u} - \boldsymbol{\mu})
\right]
$$

where:
* $\boldsymbol{u}\in\mathbb{R}^{D}$ - $D$-dimensional vector
* $\boldsymbol{\mu}\in\mathbb{R}^{D}$ - $D$-dimensional mean vector
* $\boldsymbol{\Sigma}\in\mathbb{R}^{D\times D}$ - $D\times D$-dimensional covariance matrix

***
### Mahalanobis Distance

We often call this the quadratic term.

$$
\begin{aligned}
\text{Mah Distance}: && &&
\boldsymbol{\Delta}^2 &= 
(\boldsymbol{u} - \boldsymbol{\mu})^\top
\boldsymbol{\Sigma}^{-1}
(\boldsymbol{u} - \boldsymbol{\mu}) \\
&& &&
\boldsymbol{\Delta} &= 
\sqrt{(\boldsymbol{u} - \boldsymbol{\mu})^\top
\boldsymbol{\Sigma}^{-1}
(\boldsymbol{u} - \boldsymbol{\mu})} \\
&& &&
\boldsymbol{\Delta} &= 
\sqrt{\boldsymbol{\Sigma}^{-1}(\boldsymbol{u} - \boldsymbol{\mu})^\top
(\boldsymbol{u} - \boldsymbol{\mu})} \\
\end{aligned}
$$

***
#### Case I: Identity

$$
\text{Euclidean Distance}: \hspace{2mm}
(\boldsymbol{u} - \boldsymbol{\mu})^\top
(\boldsymbol{u} - \boldsymbol{\mu})
$$


***
#### Case II: Scalar

$$
\text{Euclidean Distance}: \hspace{2mm}
\sigma
(\boldsymbol{u} - \boldsymbol{\mu})^\top
(\boldsymbol{u} - \boldsymbol{\mu})
$$


#### Case III: Diagonal

$$
\text{Euclidean Distance}: \hspace{2mm}
\boldsymbol{\sigma}^{-1}
(\boldsymbol{u} - \boldsymbol{\mu})^\top
(\boldsymbol{u} - \boldsymbol{\mu})
$$

#### Case IV: Decomposition

#### Case V: Full Covariance


***
### Masked Likelihood


***
## Conditional Gaussian Distributions

We have the joint distribution for the latent variables, $\boldsymbol{z}$, and a QoI, $\boldsymbol{u}$.

$$
\begin{bmatrix}
\boldsymbol{z} \\
\boldsymbol{u}
\end{bmatrix}
\sim \mathcal{N}
\left(
    \begin{bmatrix}
    \boldsymbol{z} \\
    \boldsymbol{u}
    \end{bmatrix} 
    \mid
    \begin{bmatrix}
    \bar{\boldsymbol{z}} \\
    \bar{\boldsymbol{u}}
    \end{bmatrix},
    \begin{bmatrix}
    \boldsymbol{\Sigma_{zz}} & \boldsymbol{\Sigma_{zu}}\\
    \boldsymbol{\Sigma_{uz}} & \boldsymbol{\Sigma_{uu}}
    \end{bmatrix} 
\right)
$$ (eq:mvn)

***
### Marginal Distributions

We have the marginal distribution for the variable, $\boldsymbol{z}$

$$
\begin{aligned}
p(\boldsymbol{z}) &= 
\mathcal{N}
\left(
    \boldsymbol{z} \mid
    \boldsymbol{\bar{z}},
    \boldsymbol{\Sigma_{zz}}
\right)
\end{aligned}
$$

We have the conditional likelihood for the variable, $\boldsymbol{u}$

$$
\begin{aligned}
p(\boldsymbol{u}) &= 
\mathcal{N}
\left(
    \boldsymbol{u} \mid
    \bar{\boldsymbol{u}},
    \boldsymbol{\Sigma_{uu}}
\right)
\end{aligned}
$$

***
### Conditional Distributions

We have the conditional likelihood for the variable, $\boldsymbol{z}$

$$
\begin{aligned}
p(\boldsymbol{z}|\boldsymbol{u}) &= 
\mathcal{N}
\left(
    \boldsymbol{z} \mid
    \boldsymbol{\mu_{z|u}},
    \boldsymbol{\Sigma_{z|u}}
\right) \\
\boldsymbol{\mu_{z|u}} &= 
\bar{\boldsymbol{z}}  + 
\boldsymbol{\Sigma_{zu}}\boldsymbol{\Sigma_{uu}}^{-1}
(\boldsymbol{u} - \bar{\boldsymbol{u}}) \\
\boldsymbol{\Sigma_{z|u}} &=
\boldsymbol{\Sigma_{zz}} - 
\boldsymbol{\Sigma_{zu}}
\boldsymbol{\Sigma_{zz}}^{-1}
\boldsymbol{\Sigma_{uz}}
\end{aligned}
$$

We have the conditional likelihood for the variable, $\boldsymbol{u}$

$$
\begin{aligned}
p(\boldsymbol{u}|\boldsymbol{z}) &= 
\mathcal{N}
\left(
    \boldsymbol{u} \mid
    \boldsymbol{\mu_{u|z}},
    \boldsymbol{\Sigma_{u|z}}
\right) \\
\boldsymbol{\mu_{u|z}} &= 
\bar{\boldsymbol{u}}  + 
\boldsymbol{\Sigma_{zu}}\boldsymbol{\Sigma_{zz}}^{-1}
(\boldsymbol{z} - \bar{\boldsymbol{z}}) \\
\boldsymbol{\Sigma_{u|z}} &=
\boldsymbol{\Sigma_{uu}} - 
\boldsymbol{\Sigma_{uz}}
\boldsymbol{\Sigma_{uu}}^{-1}
\boldsymbol{\Sigma_{zu}}
\end{aligned}
$$

***
## Scaling 

> there

### Matrix Inversions

The primary thing we want to do when

#### Cholesky Decomposition

We can decompose the matrix into a Cholesky which is an upper (or lower) triangular matrix.

$$
\mathbf{C} = \mathbf{LL}^\top
$$

We can to the inversion

$$
\mathbf{L}^{-1} = \text{Inverse}(\mathbf{L})
$$

Something that is easier to deal with is the matrix solve:

$$
\mathbf{x} = \mathbf{L}^{-1}\mathbf{b}
$$

For this, we need a special solver

```python
A: Array["D D"] = ...
b: Array["D M"] = ...
I: Array["D D"] = eye_like(A)
# cholesky decomposition
L: Array["D D"] = cholesky(K, lower=True)
L_inv: Array["D D"] = cho_solve(L, I, lower=True)
x: Array["D M"] = cho_solve(L, b, lower=True)
```

***
#### Conjugate Gradient

$$
\mathbf{x}^* = \underset{\mathbf{x}}{\text{argmin}} \hspace{2mm}
\mathbf{x}^\top\mathbf{A}\mathbf{x} -
$$

***
#### Woodbury Approximation

We can find some lower dimensional subspace. 
For example, we can use the SVD decomposition

$$
\mathbf{C} \approx \mathbf{U}\boldsymbol{\Lambda}\mathbf{V}^\top + \sigma\mathbf{I}
$$

Looking at equation [](eq:woodbury), we can take the inverse.

$$
\mathbf{C}^{-1} \approx
\mathbf{I}^{-1} - \mathbf{I}^{-1}\mathbf{U}
\left(\boldsymbol{\Lambda}^{-1} + \mathbf{V}^\top\mathbf{I}^{-1}\mathbf{U}\right)^{-1}\mathbf{V}^\top\mathbf{D}^{-1}
$$

***
#### Inducing Points

We can use a subset of the points and calculate th covariance.

$$
\mathbf{C_{yy}} \approx \mathbf{C_{yr}C_{rr}}^{-1}\mathbf{C_{yr}}^\top + \mathbf{I}
$$

Now, we can easily find the inverse 

$$
\mathbf{C_{yy}}^{-1} \approx
\mathbf{C_{yr}C_{rr}}^{-1}\mathbf{C_{yr}}^\top
$$




***
## Approximate Conditional Distributions

$$
p(\boldsymbol{z},\boldsymbol{u}) 
\sim \mathcal{N}
\left(
    \begin{bmatrix}
    \boldsymbol{z}\\
    \boldsymbol{u}
    \end{bmatrix} 
    \mid
    \begin{bmatrix}
    \boldsymbol{\hat{m}_z} \\
    \boldsymbol{\hat{m}_z}
    \end{bmatrix},
    \begin{bmatrix}
    \boldsymbol{\hat{C}_{zz}} & \boldsymbol{\hat{C}_{zu}}\\
    \boldsymbol{\hat{C}_{uz}} & \boldsymbol{\hat{C}_{uu}}
    \end{bmatrix} 
\right)
$$ (eq:mvn-joint-approx)

We have each of the terms as

$$
\begin{aligned}
\text{Mean}: && &&
\boldsymbol{\hat{m}_z} &=
\mathbb{E}\left[\boldsymbol{z}|\mathbf{Y}\right] = 
\int\boldsymbol{f}(\boldsymbol{z})p(\boldsymbol{z})d\boldsymbol{z}\\
\text{Marginal Covariance}: && &&
\boldsymbol{\hat{C}_{zz}} &=
\text{Cov}\left[\boldsymbol{z}\right] = 
\int\left(\boldsymbol{f}(\boldsymbol{z}) - \boldsymbol{\hat{m}_z}\right)
\left(\boldsymbol{f}(\boldsymbol{z}) - \boldsymbol{\hat{m}_z}\right)^\top
p(\boldsymbol{z})d\boldsymbol{z}
\\
\text{Mean}: && &&
\boldsymbol{\hat{y}} &=
\mathbb{E}\left[\boldsymbol{y}|\mathbf{Y}\right] = 
\int\boldsymbol{h}(\boldsymbol{z})p(\boldsymbol{z})d\boldsymbol{z}\\
\text{Marginal Covariance}: && &&
\boldsymbol{\hat{C}_{yy}} &=
\text{Cov}\left[\boldsymbol{z}\right] = 
\int\left(\boldsymbol{h}(\boldsymbol{y}) - \boldsymbol{\hat{y}}\right)
\left(\boldsymbol{h}(\boldsymbol{y}) - \boldsymbol{\hat{y}}\right)^\top
p(\boldsymbol{z})d\boldsymbol{z}
\\
\text{Cross-Covariance}: && &&
\boldsymbol{\hat{C}_{zy}} &=
\text{Cov}\left[\boldsymbol{z}\right] = 
\int\left(\boldsymbol{f}(\boldsymbol{z}) - \boldsymbol{\hat{m}_z}\right)
\left(\boldsymbol{h}(\boldsymbol{z}) - \boldsymbol{\hat{y}}\right)^\top
p(\boldsymbol{z})d\boldsymbol{z}
\end{aligned}
$$

We have the conditional likelihood for the variable, $\boldsymbol{z}$

$$
\begin{aligned}
p(\boldsymbol{z}|\boldsymbol{u}) &= 
\mathcal{N}
\left(
    \boldsymbol{z} \mid
    \boldsymbol{\mu_{z|u}},
    \boldsymbol{\Sigma_{z|u}}
\right) \\
\boldsymbol{\mu_{z|u}} &= 
\bar{\boldsymbol{z}}  + 
\boldsymbol{\Sigma_{zu}}\boldsymbol{\Sigma_{uu}}^{-1}
(\boldsymbol{u} - \bar{\boldsymbol{u}}) \\
\boldsymbol{\Sigma_{z|u}} &=
\boldsymbol{\Sigma_{zz}} - 
\boldsymbol{\Sigma_{zu}}
\boldsymbol{\Sigma_{zz}}^{-1}
\boldsymbol{\Sigma_{uz}}
\end{aligned}
$$

We have the conditional likelihood for the variable, $\boldsymbol{u}$

$$
\begin{aligned}
p(\boldsymbol{u}|\boldsymbol{z}) &= 
\mathcal{N}
\left(
    \boldsymbol{u} \mid
    \boldsymbol{\mu_{u|z}},
    \boldsymbol{\Sigma_{u|z}}
\right) \\
\boldsymbol{\mu_{u|z}} &= 
\bar{\boldsymbol{u}}  + 
\boldsymbol{\Sigma_{zu}}\boldsymbol{\Sigma_{zz}}^{-1}
(\boldsymbol{z} - \bar{\boldsymbol{z}}) \\
\boldsymbol{\Sigma_{u|z}} &=
\boldsymbol{\Sigma_{uu}} - 
\boldsymbol{\Sigma_{uz}}
\boldsymbol{\Sigma_{uu}}^{-1}
\boldsymbol{\Sigma_{zu}}
\end{aligned}
$$


***
## Linear Conditional Gaussian Model

We have a latent variable which is Gaussian distributed:

$$
p(\boldsymbol{z}) \sim \mathcal{N}(\boldsymbol{z}\mid\boldsymbol{\bar{z}},\boldsymbol{\Sigma_z})
$$

We have a QoI which we believe is a linear transformation of the latent variable

$$
p(\boldsymbol{u}) \sim \mathcal{N}
\left(
    \boldsymbol{u}\mid
    \mathbf{A}\boldsymbol{z} + \mathbf{b},
    \boldsymbol{\Sigma_u}
\right)
$$

Recall the joint distribution given in equation [](#eq:mvn). 
We can write each of the terms as:
* $\boldsymbol{\Sigma_{zz}}=\boldsymbol{\Sigma_{z}}$
* $\boldsymbol{\Sigma_{uu}}=\boldsymbol{\Sigma_{u}}$
* $\boldsymbol{\Sigma_{uz}}=\boldsymbol{\Sigma_{u}}$
* $\boldsymbol{\bar{u}}=\mathbf{A}\boldsymbol{z} + \mathbf{b}$


***
### Taylor Expansion

$$
\begin{bmatrix}
    \mathbf{x} \\
    y
    \end{bmatrix}
    \sim \mathcal{N} \left( 
    \begin{bmatrix}
    \mu_\mathbf{x} \\ 
    f(\mathbf{x})
    \end{bmatrix}, 
    \begin{bmatrix}
    \Sigma_\mathbf{x} & C \\
    C^\top & \Pi
    \end{bmatrix}
    \right)
$$


#### Taylor Expansion

$$
\begin{aligned}
f(\mathbf{x}) &= f(\mu_x + \delta_x) \\
&\approx f(\mu_x) + \nabla_x f(\mu_x)\delta_x + \frac{1}{2}\sum_i \delta_x^\top \nabla_{xx}^{(i)}f(\mu_x)\delta_x e_i + \ldots
\end{aligned}
$$


#### Joint Distribution

$$
\mathbb{E}_\mathbf{x}\left[ \tilde{f}(\mathbf{x}) \right], \mathbb{V}_\mathbf{x}\left[ \tilde{f}(\mathbf{x}) \right]
$$


##### Mean Function

$$
\begin{aligned}
\mathbb{E}_\mathbf{x}\left[ \tilde{f}(\mathbf{x}) \right] &=
\mathbb{E}_\mathbf{x}\left[ \tilde{f}(\mu_\mathbf{x})  + \nabla_\mathbf{x}f(\mu_\mathbf{x})\epsilon_\mathbf{x} \right] \\
&= \mathbb{E}_\mathbf{x}\left[ \tilde{f}(\mu_\mathbf{x}) \right]  +
\mathbb{E}_\mathbf{x}\left[ \nabla_\mathbf{x}f(\mu_\mathbf{x})\epsilon_\mathbf{x} \right] \\
&= \tilde{f}(\mu_\mathbf{x})  +
\nabla_\mathbf{x}\mathbb{E}_\mathbf{x}\left[ f(\mathbf{x})\epsilon_\mathbf{x} \right] \\
&= \tilde{f}(\mu_\mathbf{x})\\
\end{aligned}
$$

***
## Sample & Population Moments

$$
\begin{aligned}
\text{Matrix}: && &&
\mathbf{Z} &= 
\left[\mathbf{z}_1,\mathbf{z}_2,\ldots,\mathbf{z}_N\right]^\top,  && &&
\mathbf{Z}\in\mathbb{R}^{N\times D} \\
\text{Sample Mean}: && &&
\hat{\mathbf{Z}} &= 
\frac{1}{N}\sum_{n=1}^N \mathbf{z}_n,  && &&
\hat{\mathbf{Z}}\in\mathbb{R}^{D} \\
\text{Sample Variance}: && &&
\hat{\boldsymbol{\sigma}}_{\mathbf{z}} &= 
\frac{1}{N-1}\sum_{n=1}^N 
\left(\mathbf{z}_n - \hat{\mathbf{z}}_n\right)^2  && &&
\hat{\boldsymbol{\sigma}}_{\mathbf{z}}\in\mathbb{R}^{D} \\
\text{Sample Covariance}: && &&
\hat{\boldsymbol{\Sigma}}_{\mathbf{z}} &= 
\frac{1}{N-1}\sum_{n=1}^N 
\left(\mathbf{z}_n - \hat{\mathbf{z}}_n\right)
\left(\mathbf{z}_n - \hat{\mathbf{z}}_n\right)^\top  && &&
\hat{\boldsymbol{\Sigma}}_{\mathbf{z}}\in\mathbb{R}^{D\times D} \\
\text{Population Mean}: && &&
\hat{\boldsymbol{\mu}}_\mathbf{z} &= 
\frac{1}{D}\sum_{d=1}^D \mathbf{z}_d,  && &&
\hat{\boldsymbol{\mu}}_\mathbf{z}\in\mathbb{R}^{N} \\
\text{Population Variance}: && &&
\hat{\boldsymbol{\nu}}_{\mathbf{z}} &= 
\frac{1}{D}\sum_{d=1}^D
\left(\mathbf{z}_d - \hat{\boldsymbol{\mu}_\mathbf{z}}\right)^2  && &&
\hat{\boldsymbol{\nu}}_{\mathbf{z}}\in\mathbb{R}^{N} \\
\text{Population Covariance}: && &&
\hat{\mathbf{K}}_{\mathbf{z}} &= 
\frac{1}{D}\sum_{d=1}^D
\left(\mathbf{z}_d - \hat{\boldsymbol{\mu}_\mathbf{z}}\right)
\left(\mathbf{z}_d -\hat{\boldsymbol{\mu}_\mathbf{z}}\right)^\top  && &&
\hat{\mathbf{K}}_{\mathbf{z}}\in\mathbb{R}^{N\times N} \\
\end{aligned}
$$

**Examples**:
- Global Mean Surface Temperature, $x\in\mathbb{R}^{N\times D}$, $N=\text{Models}$, $D=\sum D_T D_\Omega$
- Spatial Scene, $x\in\mathbb{R}^{N\times D}$, $N=\text{Ensembles}$, $D=\text{Space}$
- Spatiotemporal Trajectory, $x\in\mathbb{R}^{N\times D}$, $N=\text{Space/Time}$, $D=\text{Time/Space}$
- Ensemble of Trajectories, $x\in\mathbb{R}^{N\times D}$, $N=\text{Ensembles}$, $D=\text{Time x Space}$

***
### Gaussian Approximation Algorithm


***
### Moment Estimation

#### Samples

$$
\begin{aligned}
\text{Matrix}: && &&
\mathbf{Z} &= 
\left[\mathbf{z}_1,\mathbf{z}_2,\ldots,\mathbf{z}_N\right],  && &&
\mathbf{Z}\in\mathbb{R}^{D\times N} \\
\text{Perturbation Matrix}: && &&
\mathbf{P} &= \mathbf{Z} - \hat{\mathbf{z}}, && &&
\mathbf{P}\in\mathbb{R}^{D \times N}
\end{aligned}
$$

We can do all of these operations in matrix form.

$$
\begin{aligned}
\text{Sample Mean}: && &&
\hat{\mathbf{z}} &= \frac{1}{N}\mathbf{Z}\cdot\mathbf{1}, && &&
\hat{\mathbf{z}}\in\mathbb{R}^{D} \\
\text{Perturbation Matrix}: && &&
\hat{\mathbf{P}} &= \mathbf{Z}\cdot\left(\mathbf{I}_N - \frac{1}{N}\mathbf{11}^\top\right), && &&
\hat{\mathbf{P}}\in\mathbb{R}^{D\times D} \\
\text{Sample Covariance}: && &&
\hat{\boldsymbol{\Sigma}}_{\mathbf{z}} &= 
\frac{1}{N-1} \hat{\mathbf{P}}\hat{\mathbf{P}}^\top && &&
\hat{\boldsymbol{\Sigma}}_{\mathbf{z}}\in\mathbb{R}^{D\times D} \\
\end{aligned}
$$

**Note**: the perturbation matrix in this form is equivalent to the kernel centering operation (see [scikit-learn docs](https://scikit-learn.org/stable/modules/generated/sklearn.preprocessing.KernelCenterer.html)).
It allows one to center the gram matrix without explicitly computing the mapping.

***
#### Population

$$
\begin{aligned}
\text{Matrix}: && &&
\mathbf{Z} &= 
\left[\mathbf{z}_1,\mathbf{z}_2,\ldots,\mathbf{z}_N\right]^\top,  && &&
\mathbf{Z}\in\mathbb{R}^{N\times D} \\
\text{Perturbation Matrix}: && &&
\mathbf{P} &= \mathbf{Z} - \hat{\mathbf{z}}, && &&
\mathbf{P}\in\mathbb{R}^{N \times D}
\end{aligned}
$$

We can do all of these operations in matrix form.

$$
\begin{aligned}
\text{Population Mean}: && &&
\hat{\boldsymbol{\mu}}_\mathbf{z} &= 
\frac{1}{D}\mathbf{Z}\cdot\mathbf{1}, && &&
\hat{\boldsymbol{\mu}}_\mathbf{z}\in\mathbb{R}^{N} \\
\text{Perturbation Matrix}: && &&
\hat{\mathbf{P}} &= \mathbf{Z}\cdot\left(\mathbf{I}_N - \frac{1}{D}\mathbf{11}^\top\right), && &&
\hat{\mathbf{P}}\in\mathbb{R}^{N\times N} \\
\text{Population Covariance}: && &&
\hat{\mathbf{K}}_{\mathbf{z}} &= 
\frac{1}{D} \hat{\mathbf{P}}\hat{\mathbf{P}}^\top && &&
\hat{\mathbf{K}}_{\mathbf{z}}\in\mathbb{R}^{N\times N} 
\end{aligned}
$$


***
## Matrix Identities

***
### Woodbury Formula

$$
\left( \mathbf{A}+\mathbf{UCV}^\top\right)^{-1} =
\mathbf{A}^{-1} - \mathbf{A}^{-1}\mathbf{U}
\left(\mathbf{C}^{-1} + \mathbf{V}^\top\mathbf{A}^{-1}\mathbf{U}\right)^{-1}
\mathbf{V}^{\top}\mathbf{A}^{-1}
$$ (eq:woodbury)

***
#### Sherman-Morrison-Woodbury Formula

This is basically the same as the Woodbury formula [](#eq:woodbury) except the matrix, $\mathbf{A}$, is the identity, $\mathbf{I}$ and the decomposition is between

$$
\left( \mathbf{I}+\mathbf{UV}^\top\right)^{-1} =
\mathbf{I}_D - \mathbf{U}
\left(\mathbf{I}_d + \mathbf{V}^\top\mathbf{U}\right)^{-1}
\mathbf{V}^{\top}
$$ (eq:sherman-morrison-woodbury)

There are some lemmas to this which have been shown to be very useful in practice.

$$
\begin{aligned}
\begin{aligned}
\mathbf{AB^\top(C+BAB^\top)^{-1}} &=
\mathbf{A^{-1} - A^{-1}U(C^{-1}+VA^{-1}U)^{-1}VA^{-1}} \\
\mathbf{(C^{-1}+B^\top A^{-1}B)^{-1}} &=
\mathbf{C^{-1} - CB^\top(BCB^\top+A)^{-1}BC} \\
\end{aligned}
\end{aligned}
$$


***
### Sylvester Determinant Lemma

$$
\begin{aligned}
\left| \mathbf{A}+\mathbf{U}\boldsymbol{\Lambda}\mathbf{V}^\top\right| &=
\left|\mathbf{A}\right|
\left|\boldsymbol{\Lambda}\right|
\left|\boldsymbol{\Lambda}^{-1} - \mathbf{U}^\top\mathbf{A}^{-1}\mathbf{V}\right| \\
\left| \mathbf{A}+\mathbf{UV}^\top\right| &=
\left|\mathbf{A}\right|
\left|\mathbf{I}_d - \mathbf{U}^\top\mathbf{A}^{-1}\mathbf{V}\right| \\
\end{aligned}
$$ (eq:sylvester-determinant)

***
#### Weinsten-Aronszajin Identity

$$
\left| \mathbf{I}_D+\mathbf{UV}^\top\right| =
\left|\mathbf{I}_d - \mathbf{U}^\top\mathbf{V}\right| 
$$ (eq:weinstein-aronszajin)

***
## Decompositions

### Eigenvalue Decomposition

$$
\mathbf{K} \approx \mathbf{U}\boldsymbol{\Lambda}\mathbf{V}^\top
$$


***
### Nystrom Approximation

$$
\mathbf{K} \approx \mathbf{U}\boldsymbol{\Lambda}\mathbf{V}^\top
$$ (eq:nystrom)


***
#### Inversion

We can use the matrix inversion properties from equation [](eq:woodbury) to decompose the Nyström approximation into a cheaper inversion.

$$
\begin{aligned}
\mathbf{K}^{-1} &=
\left( \mathbf{K} + \sigma^{2}\mathbf{I}_N\right)^{-1} \\
&\approx
\left( \mathbf{U}\boldsymbol{\Lambda}\boldsymbol{V}^\top + \sigma^{2}\mathbf{I}_N\right)^{-1} \\
&= \sigma^{-2}\mathbf{I}_N + \sigma^{-4}\mathbf{U}
\left( \boldsymbol{\Lambda}^{-1} + \sigma^{-2}\mathbf{V}^\top\mathbf{U}\right)^{-1}
\mathbf{V}^\top
\end{aligned}
$$ (eq:nystrom-inversion)


***
#### Determinant

We can use the determinant inversion properties from equation [](eq:sylvester-determinant) to decompose the Nyström approximation to be cheaper.

$$
\begin{aligned}
\left|\mathbf{K}\right| &=
\left| \mathbf{K} + \sigma^{2}\mathbf{I}_N\right| \\
&\approx
\left| \mathbf{U}\boldsymbol{\Lambda}\boldsymbol{V}^\top + \sigma^{2}\mathbf{I}_N\right| \\
&= 
\sigma^2
\left|\boldsymbol{\Lambda}\right|
\left|\boldsymbol{\Lambda}^{-1} + \sigma^{-2}\mathbf{V}^\top\mathbf{U}\right|
\end{aligned}
$$ (eq:nystrom-determinant)


***
### Random Fourier Features

$$
\mathbf{K} \approx \mathbf{L}\mathbf{L}^\top
$$ (eq:fourier-features-decomposition)


***
#### Inversion

We can use the matrix inversion properties from equation [](eq:woodbury) to decompose the Nyström approximation into a cheaper inversion.

$$
\begin{aligned}
\mathbf{K}^{-1} &=
\left( \mathbf{K} + \sigma^{2}\mathbf{I}_N\right)^{-1} \\
&\approx
\left( \mathbf{U}\boldsymbol{\Lambda}\boldsymbol{V}^\top + \sigma^{2}\mathbf{I}_N\right)^{-1} \\
&= \sigma^{-2}\mathbf{I}_N + \sigma^{-4}\mathbf{U}
\left( \mathbf{I}_d + \sigma^{-2}\mathbf{V}^\top\mathbf{U}\right)^{-1}
\mathbf{V}^\top
\end{aligned}
$$ (eq:fourier-features-inversion)


***
#### Determinant

We can use the determinant inversion properties from equation [](eq:sylvester-determinant) to decompose the Nyström approximation to be cheaper.

$$
\begin{aligned}
\left|\mathbf{K}\right| &=
\left| \mathbf{K} + \sigma^{2}\mathbf{I}_N\right| \\
&\approx
\left| \mathbf{L}\mathbf{L}^\top + \sigma^{2}\mathbf{I}_N\right| \\
&= 
\sigma^2
\left|\mathbf{I}_d + \sigma^{-2}\mathbf{L}^\top\mathbf{L}\right|
\end{aligned}
$$ (eq:fourier-features-determinant)


### Inducing Points

$$
\begin{aligned}
\text{Inducing Point Kernel}: && &&
\mathbf{K}_{\mathbf{uu}} &= \boldsymbol{K}(\mathbf{U}) \\
\text{Cross Kernel}: && &&
\mathbf{K}_{\mathbf{ux}} &= \boldsymbol{K}(\mathbf{U}, \mathbf{X}) \\
\text{Decomposition}: && &&
\mathbf{K_{uu}} &= \mathbf{L_{uu}L_{uu}}^\top \\
\text{Approximate Kernel}: && &&
\mathbf{K_{xx}} &\approx \mathbf{K_{xu}}\mathbf{K_{uu}}^{-1}\mathbf{K_{ux}} \\
\end{aligned}
$$

We can demonstrate the decomposition as:

$$
\begin{aligned}
\mathbf{K_{xx}} 
&\approx \mathbf{K_{xu}}\mathbf{K_{uu}}^{-1}\mathbf{K_{ux}} \\
&= \mathbf{K_{xu}}\left(\mathbf{L_{uu}L_{uu}}^\top\right)^{-1}\mathbf{K_{ux}} \\
&= \mathbf{K_{xu}}\left(\mathbf{L_{uu}}^{-1}\right)\left(\mathbf{L_{uu}}^{-1}\right)^\top\mathbf{K_{ux}} \\
&= \mathbf{WW}^\top\\
\mathbf{W} &= \left( \mathbf{L_{uu}K_{ux}}\right)^\top
\end{aligned}
$$