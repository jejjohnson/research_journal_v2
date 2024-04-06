---
title: PCA
subject: Machine Learning for Earth Observations
short_title: PCA
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

$$
\boldsymbol{u}(\mathbf{s},t) = \sum_{k=1}^{\infty}\alpha_k(t)\boldsymbol{\phi}_k(\mathbf{s})
$$

where $\boldsymbol{\phi}_k(\mathbf{s})$ are the spatial coefficients and $a_k(t)$ are the time coefficients.
We want a case whereby we can maximize the kinetic energy that can be captured by the first $D_z$ spatial nodes.

$$
\boldsymbol{u}(\mathbf{s},t) \approx \sum_{k=1}^{D_z}\alpha_k(t)\boldsymbol{\phi}_k(\mathbf{s})
$$

In linear algebra form we can decompose the signal:

$$
\begin{aligned}
\text{Singular Value Decomposition}: && &&
\mathbf{U} &= \mathbf{LSR}^\top \\
\end{aligned}
$$

We notice that the time coefficients vector is given by:


$$
\begin{aligned}
\text{Time Coefficients}: && &&
\mathbf{A_s} &= \mathbf{L} \\
\text{Spatial Covariance Matrix}: && &&
\mathbf{C_s} &= \frac{1}{m-1}\mathbf{UU}^\top \\
\end{aligned}
$$

$$

$$

$$
\mathbf{U} = \mathbf{A}\boldsymbol{\phi}^{-1}=\mathbf{A}\boldsymbol{\phi}^\top
$$

where $\mathbf{A_s}=\mathbf{S}_T\boldsymbol{\Lambda}\mathbf{S}_T^\top$


## Snapshot

```python
# calculate correlation matrix
C_s = cov(Y, rowvar=True)
# solve eigenvalue problem
A_s, lam_s = eig(C_s)
# sort eigenvalues and eigenvectors
ilam_s = argsort(lam_s)[::-1]
lam_s = lam_s[ilam_s]
A_s = A_s[:, ilam_s]

# calculate spatial coefficients
```


## SVD


```python
# normalize
Y_norm = Y / sqrt(Nt - 1)
# calculate SVD
U, eigs, VT = svd(Y_norm)
# get spatial nodes
PHI = VT
# Calculate the time coefficients
A = Y @ PHI
# calculate the eigenvalues
Eigs = diag(eigs) ** 2
```