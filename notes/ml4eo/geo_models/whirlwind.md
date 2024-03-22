---
title: Geo-Modeling
subject: ML4EO
short_title: Whirlwind Tour
authors:
  - name: J. Emmanuel Johnson
    affiliations:
      - CSIC
      - UCM
      - IGEO
    orcid: 0000-0002-6739-0053
    email: juanjohn@ucm.es
license: CC-BY-4.0
keywords: data
---


## Unconditional Density Estimation

#### **Data**
$$
\begin{aligned}
\mathcal{D} &=\left\{y_n \right\}, && &&
y_n\in\mathbb{R}^{D_y}
\end{aligned}
$$

***
#### Parametric 

$$
\begin{aligned}
\text{Joint Distribution}: && &&
p(y,\theta) &= p(y|\theta)p(\theta)
\end{aligned}
$$

***
#### Generative

$$
\begin{aligned}
\text{Joint Distribution}: && &&
p(y,z,\theta) &= p(y|z,\theta)p(z|\theta)p(\theta)
\end{aligned}
$$

***
## Conditional Density Estimation


#### **Data**
$$
\begin{aligned}
\mathcal{D} &=\left\{y_n, x_n \right\}, && &&
y_n\in\mathbb{R}^{D_y} &&
x_n\in\mathbb{R}^{D_x}
\end{aligned}
$$


***
#### Parametric 


$$
\begin{aligned}
\text{Joint Distribution}: && &&
p(y,x,\theta) &= p(y|x,\theta)p(\theta)
\end{aligned}
$$

***
#### Generative

$$
\begin{aligned}
\text{Joint Distribution I}: && &&
p(y,x,z,\theta) &= p(y|z,x,\theta)p(z|\theta)p(\theta) \\
\text{Joint Distribution II}: && &&
p(y,x,z,\theta) &= p(y|z,\theta)p(z|x,\theta)p(\theta) \\
\text{Joint Distribution III}: && &&
p(y,x,z,\theta) &= p(y|x,z,\theta)p(z|x,\theta)p(\theta) \\
\end{aligned}
$$


***
## Dynamical Models

### Observations


$$
\begin{aligned}
\mathcal{D} &=\left\{y_t \right\}_{t=1}^T, && &&
y_t\in\mathbb{R}^{D_y}
\end{aligned}
$$



***
#### Parametric (Global, IID)

$$
\begin{aligned}
p(y_{1:T},\theta) &= p(\theta)\prod_{t=1}^T p(y_t|\theta)
\end{aligned}
$$


***
#### Parametric (Local)

$$
\begin{aligned}
p(y_{1:T},\theta_{0:T}) &= p(\theta_0)\prod_{t=1}^T p(y_t|\theta_t)
\end{aligned}
$$


***
#### Generative

$$
\begin{aligned}
p(y_{1:T},z_{1:T},\theta) &= p(\theta)p(z_0)\prod_{t=1}^T p(y_t|z_t,\theta)p(z_t|z_{t-1},\theta)
\end{aligned}
$$


***
#### Conditional Generative


$$
\begin{aligned}
p(y_{1:T},x_{1:T},z_{1:T},\theta) &= p(\theta)p(z_0)\prod_{t=1}^T p(y_t|z_t,\theta)p(z_t|z_{t-1}, x_{t},\theta)
\end{aligned}
$$

***
#### Dynamical

$$
\begin{aligned}
p(y_{1:T},u_{0:T},\theta) &= p(\theta)p(u_0)\prod_{t=1}^T p(y_t|u_t,\theta)p(u_t|u_{t-1},\theta)
\end{aligned}
$$

***
#### Conditional Dynamical

$$
\begin{aligned}
p(y_{1:T},x_{1:T}, u_{0:T},\theta) &= p(\theta)p(u_0)\prod_{t=1}^T p(y_t|u_t,x_t,\theta)p(u_t|u_{t-1}, x_{t},\theta)
\end{aligned}
$$

***
#### Generative Dynamical

$$
\begin{aligned}
p(y_{1:T},u_{1:T}, z_{0:T},\theta) &= p(\theta)p(z_0)\prod_{t=1}^T p(y_t|u_t,\theta)p(u_t|z_{t}, \theta)p(z_t|z_{t-1},\theta)
\end{aligned}
$$

***
#### Conditional Generative Dynamical

$$
\begin{aligned}
p(y_{1:T},u_{1:T}, x_{1:T},z_{0:T},\theta) &= p(\theta)p(z_0)\prod_{t=1}^T p(y_t|u_t,x_t,\theta)p(u_t|z_{t}, x_{t},\theta)p(z_t|z_{t-1},\theta)
\end{aligned}
$$






