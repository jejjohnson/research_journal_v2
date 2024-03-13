---
title: Sensitivity Analysis
subject: Misc. Notes
short_title: Sensitivity Analysis
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


## Gradient-Based Sensitivity Analysis


***
### Spatial Field
Consider an arbitrary spatial field

$$
\begin{aligned}
u &= \boldsymbol{u}(\mathbf{s}) && && u: \mathbb{R}^{D_s}\rightarrow\mathbb{R} && && \mathbf{s}\in\Omega\subseteq\mathbb{R}^{D_s}
\end{aligned}
$$


We can take the gradient of that field

$$
\begin{aligned}
\text{Gradient}: && &&
\boldsymbol{J}[\boldsymbol{u}, \mathbf{s}] &= 
\partial_s \boldsymbol{u} && &&
\partial_s \boldsymbol{u}: \mathbb{R}^{D_s}\rightarrow\mathbb{R}^{D_s}
\end{aligned}
$$


#### Example

An example would be a simple sine with an additive term

$$
\begin{aligned}
u(s) &= s + \sin(s) && &&
u: \mathbb{R}\rightarrow \mathbb{R}
\end{aligned}
$$


```python
# get data
x: Array["N"] = ...
# create a function
f = lambda x: x + sin(x)
y: Array["N"] = vmap(f)(x)
```

Now, we can take the gradient of that field.

$$
\begin{aligned}
\partial_s u &= \cos(s) && &&
u: \mathbb{R}\rightarrow \mathbb{R}
\end{aligned}
$$


```python
# take the gradient 
df = grad(f)
dx: Array["N"] = vmap(df)(x)
```


***
### Parameterized Spatial Field
Suppose we have some sample from the arbitrary spatial field with some parameters

$$
\begin{aligned}
u &= \boldsymbol{u}(\mathbf{s},\boldsymbol{\theta}) && && 
u: \mathbb{R}^{D_s}\times\mathbb{R}^{D_\theta}\rightarrow\mathbb{R} && &&
\mathbf{s}\in\Omega\subseteq\mathbb{R}^{D_s}
\end{aligned}
$$

Now, we have a few options.
We can take the gradient of 

$$
\begin{aligned}
\text{Gradient wrt Coords}: && && 
\boldsymbol{J}[\boldsymbol{u}, \mathbf{s}] &= 
\partial_s \boldsymbol{u} && &&
\partial_s \boldsymbol{u}: \mathbb{R}^{D_s}\times\mathbb{R}^{D_\theta}\rightarrow\mathbb{R}^{D_s}\\
\text{Gradient wrt Parameters}: && &&
\boldsymbol{J}[\boldsymbol{u}, \mathbf{\theta}] &= 
\partial_\theta \boldsymbol{u} && &&
\partial_\theta \boldsymbol{u}: \mathbb{R}^{D_s}\times\mathbb{R}^{D_\theta}\rightarrow\mathbb{R}^{D_\theta}\\
\end{aligned}
$$

#### Example

An example would be a simple periodic sine function with some amplitude and frequency parameters

$$
\begin{aligned}
u(s;\boldsymbol{\theta}) &= a\sin(bs + c) + d && &&
u: \mathbb{R}\times\mathbb{R}^{D_\theta}\rightarrow \mathbb{R}
\end{aligned}
$$

where $a$ is the amplitude, $b$ is the period, $c$ is the phase shift and $d$ is the vertical shift.
So the parameters of the field are $\boldsymbol{\theta}= \{a,b,c,d\}$. 
See [webpage](https://www.mathsisfun.com/algebra/amplitude-period-frequency-phase-shift.html) for a visual demonstration.

```python
# create a function
def f(x: Scalar, params: Dict) -> Scalar:
    a, b, c, d = params["a"], params["b"], params["c"], params["d"]
    return a sin(b * s + c) + d

# Define parameters
params = dict(a=0.1,b=0.01,c=1.0,d=10)
# get data
x: Array["N"] = np.linspace(-2*pi, 2*pi, 100)

# apply function
y: Array["N"] = vmap(f, axis=0)(x, params)
```

Now, we can take the gradient of that field. 
First, the gradient wrt the coordinate, $s$.

$$
\begin{aligned}
\text{Gradient wrt Coords}: && && 
\partial_s \boldsymbol{u} &= ab\cos(bs+d) && &&
\partial_s \boldsymbol{u}: \mathbb{R}\times\mathbb{R}^{D_\theta}\rightarrow\mathbb{R}
\end{aligned}
$$

Now, we can take the gradient wrt each of the parameters 

$$
\begin{aligned}
\text{Gradient wrt }a: && && 
\partial_a \boldsymbol{u} &= \sin(bs + c) && &&
\partial_a \boldsymbol{u}: \mathbb{R}\times\mathbb{R}^{D_\theta}\rightarrow\mathbb{R} \\
\text{Gradient wrt }b: && && 
\partial_b \boldsymbol{u} &= as\cos(bs+c) && &&
\partial_b \boldsymbol{u}: \mathbb{R}\times\mathbb{R}^{D_\theta}\rightarrow\mathbb{R} \\
\text{Gradient wrt }c: && && 
\partial_c \boldsymbol{u} &= a\cos(bs+c) && &&
\partial_c \boldsymbol{u}: \mathbb{R}\times\mathbb{R}^{D_\theta}\rightarrow\mathbb{R} \\
\text{Gradient wrt }d: && && 
\partial_d \boldsymbol{u} &= 1 && &&
\partial_d \boldsymbol{u}: \mathbb{R}\times\mathbb{R}^{D_\theta}\rightarrow\mathbb{R} \\
\end{aligned}
$$

```python
# take the gradient 
dxf = grad(f, axis=0)
dx: Array["N"] = vmap(dxf, axis=0)(x)

# gradient wrt parameters
dpf = jacobian(f, axis=1)
dp: Array["N Ds"] = vmap(dpf, axis=1)(x)
```

***
### Conditional Spatial Field
Suppose we have some sample from the arbitrary spatial field with some parameters

$$
\begin{aligned}
u &= \boldsymbol{u}(\mathbf{s},\boldsymbol{x},\boldsymbol{\theta}) && && 
u: \mathbb{R}^{D_s}\times\mathbb{R}^{D_x}\times\mathbb{R}^{D_\theta}\rightarrow\mathbb{R} && &&
\mathbf{s}\in\Omega\subseteq\mathbb{R}^{D_s}
\end{aligned}
$$

Now, we have a few options.
We can take the gradient of 

$$
\begin{aligned}
\text{Gradient wrt Coords}: && && 
\boldsymbol{J}[\boldsymbol{u}, \mathbf{s}] &= 
\partial_s \boldsymbol{u} && &&
\partial_s \boldsymbol{u}: \mathbb{R}^{D_s}\times\mathbb{R}^{D_\theta}\rightarrow\mathbb{R}^{D_s}\\
\text{Gradient wrt Parameters}: && &&
\boldsymbol{J}[\boldsymbol{u}, \boldsymbol{\theta}] &= 
\partial_\theta \boldsymbol{u} && &&
\partial_\theta \boldsymbol{u}: \mathbb{R}^{D_s}\times\mathbb{R}^{D_\theta}\rightarrow\mathbb{R}^{D_\theta}\\
\text{Gradient wrt Covariate}: && &&
\boldsymbol{J}[\boldsymbol{u}, \boldsymbol{x}] &= 
\partial_\theta \boldsymbol{u} && &&
\partial_\theta \boldsymbol{u}: \mathbb{R}^{D_s}\times\mathbb{R}^{D_\theta}\rightarrow\mathbb{R}^{D_\theta}\\
\end{aligned}
$$

#### Example (TODO)


***
## Toy Examples

**Temporal Signals**

$$
\begin{aligned}
\text{Linear}: && &&
\boldsymbol{u}(t,\boldsymbol{\theta}) &= at + b && &&
t\in\mathbb{R}\\
\text{NonLinear}: && &&
\boldsymbol{u}(t,\boldsymbol{\theta}) &= a\sin(bt+c)+d && &&
t\in\mathbb{R}\\
\end{aligned}
$$

**Spatial Signals**

$$
\begin{aligned}
\text{2D Linear}: && &&
\boldsymbol{u}(\mathbf{s},\boldsymbol{\theta}) &= as_1 + bs_2\\
\text{2D NonLinear}: && &&
\boldsymbol{u}(\mathbf{s},\boldsymbol{\theta}) &= as_1\cos(bs_2)+d\\
\text{3D NonLinear}: && &&
\boldsymbol{u}(\mathbf{s},\boldsymbol{\theta}) &= a\lambda + b\phi + c r\\
\end{aligned}
$$

**Spatiotemporal Signals**


$$
\begin{aligned}
\text{1D+T Linear}: && &&
\boldsymbol{u}(\mathbf{s},t,\boldsymbol{\theta}) &= ...\\
\text{2D+T Linear}: && &&
\boldsymbol{u}(\mathbf{s},t,\boldsymbol{\theta}) &= ... \\
\text{2D+T Non-Linear}: && &&
\boldsymbol{u}(\mathbf{s},t,\boldsymbol{\theta}) &= ...
\end{aligned}
$$