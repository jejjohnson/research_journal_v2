---
title: Latent Effects
subject: AI 4 Attribution
short_title: II - Latent Variables
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

> **TLDR**: 
> We can include more flexibility by considering latent variables. 
> We can use flexible flow transformations (bijective, Surjective, stochastic) to encode the covariates or other observations. 
> These could provide more expressive representations and possibly more scalability by reducing the dimension drastically. 
> We could use a library of pre-trained relevant covariate Embeddings for more expressive representations. 
> These transformations are fully compatible with state space models.



### Generative Parametric Model

For this model, we assume that there is some underlying latent variable, $\boldsymbol{z}$, that underlines our process.

$$
p(\boldsymbol{y},\boldsymbol{z}) = p(\boldsymbol{y}|\boldsymbol{z})p(\boldsymbol{z})
$$

So, the data likelihood will be:

$$
\begin{aligned}
\boldsymbol{z} &\sim p(\boldsymbol{z}|\boldsymbol{\theta}) \\
\boldsymbol{y}|\boldsymbol{z} &\sim p(\boldsymbol{y}|\boldsymbol{\theta},\boldsymbol{z})
\end{aligned}
$$


**Example Prediction**

$$
\begin{aligned}
\text{Sample Hyperparameter}: && &&
\boldsymbol{\alpha}_n &\sim p(\boldsymbol{\alpha}) \\
\text{Sample Latent Variable}: && &&
\boldsymbol{z}_n &\sim p(\boldsymbol{z}) \\
\text{Process Likelihood}: && &&
\boldsymbol{\theta}_n &\sim p(\boldsymbol{\theta}|\boldsymbol{z}_n,\alpha_n) \\
\text{Data Likelihood}: && &&
y_n &\sim p(y_n|\boldsymbol{\theta}_n,\boldsymbol{z}_n) \\
\end{aligned}
$$