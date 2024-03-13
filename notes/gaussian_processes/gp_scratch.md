# Gaussian Processes from Scratch



```python
# initialize data
X: Array["Nx D"] = ...
Y: Array["Ny D"] = ...
```


## Kernel Function

$$
\boldsymbol{k}(\mathbf{x},\mathbf{y}) = \exp 
\left( - \gamma ||\mathbf{x} - \mathbf{y}||_2^2 \right)
$$


```python
# create kernel function
k: Callable = ...

# apply kernel function
Kxx: Array["Nx Nx"] = gram_matrix(k, xtrain, xtrain, *args, **kwargs)
Kxx = cola.ops.Dense(Kxx)
# train-test kernel
Kzx: Array["Nz Nx"] = gram_matrix(k, xtest, xtrain, *args, **kwargs)
Kzx = cola.ops.Dense(Kzx)
# test-test kernel
Kzz: Array["Nz Nz"] = gram_matrix(k, xtest, xtest, *args, **kwargs)
Kzz = cola.ops.Dense(Kzz)
```

$$
[\mathbf{K_{xx}}]_{ij} = \boldsymbol{k}(\mathbf{X}_i, \mathbf{X}_i')
$$

$$
\boldsymbol{k}(\mathbf{X},\mathbf{x}') = \boldsymbol{k_X}(\mathbf{x}) = ...
$$

