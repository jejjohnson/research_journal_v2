---
title: Missing Values - Likelihoods
subject: ML4EO
short_title: Missing Values - Likelihoods
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


## PseudoCode


### Masked Operator

$$
\mathbf{H} \in \mathbb{R}^{D_y \times D_z}
$$

```python
# the operator
operator: Array["Dy Dz"] = ...

# the mask for missing values
mask: Array["Dz"] = ...

# enable broadcasting
mask: Array["Dz 1"] = rearrange("..., ... -> ... 1", mask)

# mask all unobserved observations
operator = where(mask == 1.0, 0.0, operator)
```

### Masked Observation Noise