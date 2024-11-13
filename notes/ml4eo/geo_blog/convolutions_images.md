---
title: Blog - Image Convolutions
subject: ML4EO
short_title: Image Convolutions
authors:
  - name: J. Emmanuel Johnson
    affiliations:
      - CSIC
      - UCM
      - IGEO
    orcid: 0000-0002-6739-0053
    email: juanjohn@ucm.es
license: CC-BY-4.0
keywords: notation
---


In addition, we will showcase some connections to other cases where we have 1x1 convolutions which include finite differences and linear layers.


***
### Pseudo-Code (Jax)

```python
# initialize array
x: Array["H W C"] = ...

# initialize kernel
kernel: Array["H W"] = ...

# adjust kernel
kernel: Array["H W 1 1"] = ...

# convolution parameters
dimension_numbers = ("HWC", "IOHW", "HWC")
padding = "VALID"

# apply convolution
out = conv_general_dilated(
    lhs=x,
    rhs=kernel,
    padding=padding,
    lhs_dilation=(1, 1),
    rhs_dilation=(1, 1),
    dimension_numbers=dimension_numbers
)
```

### Pseudo-Code (Keras)

```python
# inputs
x: Array["B H W C"] = ...
# kernel
kernel: Array["H W"] = ...

# adjust kernel
kernel: Array["H W 1 1"] = ...

# convolution parameters
padding = "valid"
data_format = "channels_last"
dilation_rate = 1
strides = 1


# apply convolution
out = conv(
    inputs=x,
    kernel=kernel,
    strides=strides,
    padding=padding
    )
```

## Connections


***
### Finite Differences

$$
\partial_x f(x) \approx \frac{f(x+\Delta x) - f(x)}{\Delta x}
$$

$$
\mathbf{k} =
\begin{bmatrix}
-1 & 1
\end{bmatrix}
\in 
\mathbb{R}^2
$$


***
### Fully Connected


***
## Resources

**Animated AI** [YouTube Channel](https://www.youtube.com/@animatedai/videos).
They give a really good introduction with visualizations.