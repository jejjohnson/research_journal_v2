---
title: Feature Representation
subject: AI 4 Attribution
short_title: Features (Learned)
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


## Whirlwind Tour

### Parametric Model

> For the parametric model, we assume that we can immediate describe the 

**Data Representation**. We assume that all data points are IID.

$$
\mathcal{D} = \{\boldsymbol{y}_n \}_{n=1}^{N}
$$
where $N=N_s N_t$ is the product of all spatiotemporal coordinates.


***

**Data Likelihood**. We assume that the extreme observations, $\boldsymbol{y}$, can be immediately explained by a parametric distribution, $p(\boldsymbol{y}|\boldsymbol{\theta})$.

$$
\boldsymbol{y} \sim p(\boldsymbol{y}|\boldsymbol{\theta})
$$

This distribution could be the GEVD or the GPD depending upon how the maximum values are selected from the dataset.

***

**Posterior**. In this case, our posterior is the best parameters given the observations, $\boldsymbol{y}$.

$$
p(\boldsymbol{\theta}|\boldsymbol{y}) = \frac{1}{Z}p(\boldsymbol{y}|\boldsymbol{\theta})p(\boldsymbol{\theta})
$$

***

#### Extensions I: Conditional Models

We can extend this to include other (possibly multivariate) covariate vectors.
For example, we can include some additional information such as

$$
\boldsymbol{y}|\boldsymbol{u}\sim p(\boldsymbol{y}|\boldsymbol{\theta},\boldsymbol{u})
$$

## Modern Architectures


**Examples**


Spatial Considerations:
* Convolutions
* Spectral Convolutions
* Transformers

Temporal Considerations:
* Recurrent Neural Networks (RNN), Gated Recurrent Units (GRU), Long-Short-Term-Memory (LSTM)
* Autoregressive Methods