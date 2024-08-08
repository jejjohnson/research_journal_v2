---
title: Probability Graphical Models
subject: ML4EO
subtitle: How can I estimate the state AND the parameters?
short_title: State Space Models
authors:
  - name: J. Emmanuel Johnson
    affiliations:
      - CNRS
      - MEOM
    orcid: 0000-0002-6739-0053
    email: jemanjohnson34@gmail.com
license: CC-BY-4.0
keywords: data-assimilation, open-science
---



## Things we can do

**Predictions**

$$
z_t \sim p(z_t|y_{1:t-1}) = 
\int_0^t 
p(z_t|z_{t-1})p(z_{t-1}|y_{1:t-1})dz_{t-1}
$$

**Filtering**

$$
p(z_t|y_{1:t}) \propto p(z_t|y_{1:t-1})p(y_t|z_t)
$$

**Data Likeihood**

$$
p(y_t|y_{1:t-1})
$$

**Smoothing**

$$
p(z_t|y_{1:T})
$$


### Learning

**Transition Step**

$$
z_t \sim p(z_t|z_{t-1},x_t)
$$

**Assimilation Step**

$$
z_t^a \sim p(z_t^a|y_t,z_t)
$$

**Update Step**

$$
z_t \sim p(z_t|z_t, z_{t-1},y_t)
$$

**Prediction Step**

$$
u_t \sim p(u_t|z_t)
$$