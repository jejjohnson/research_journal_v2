# Deep Equilibrium Models


### Model

```python
params:
```


### Inference

Now, we can solve this DEQ.


$$
\boldsymbol{y} = \text{FixedPointSolver}(\boldsymbol{f},\boldsymbol{y},\boldsymbol{y}_{obs},\boldsymbol{\theta})
$$

```python
# initialize
y_obs: Array["Dx Dy"] = ...
y0: Array["Dx Dy"] = zeros_like(y_obs)
solver: Solver = GaussNewton()

# solve fixed point method
y_pred: Array["Dx Dy"] = fixed_point_solver(
    y=y_obs, y0=y0,
    model=model, params=params,
    solver=solver
)
```
