---
title: Missing Values Types
subject: ML4EO
short_title: Missing Values - Types
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

> In this blog, we discuss some different types of missing values.

* Missing Completely At Random (MCAR)
* Missing Not At Random (MNAR)
* Missing


***
### Definitions

```{figure} https://gmd.copernicus.org/articles/15/4569/2022/gmd-15-4569-2022-f01-thumb.png
:scale: 50 %
:align: center
:alt: map to buried treasure

A simple schematic for different types of *missingness*.
Source: [Bessenbacher, 2022](https://doi.org/10.5194/gmd-15-4569-2022).
```

**Missing Completely At Random**.
If the missingness is a completely independent of any process, then we consider it MCAR.
This process could be physical or instrumental.

$$
m_{n} \sim p(m)
$$

where $n$ is the spatiotemporal coordinate.

**Missing At Random**.
If the missing is completely independent of the underlying physical process that we are measuring but it could be dependent on some other auxillary process then we consider this to be **Missing At Random** (MAR).
An example would be satellite swaths that are measuring the spectral channels or the alongtrack data.
The missing data is not dependent on any underlying physical process.




**Steps**

**Interpolation Step** - Create Initial Estimates by Spatial Interpolation.
For example, we can divide the signal into climatology and monthly anomalies.
They can use some gap-filling with splines and/or kriging.

$$
\begin{aligned}
\text{Monthly Anomalies}: && &&
\bar{\mathbf{y}}_m &= 
\sum_{t=1} \mathbf{k}_m * \mathbf{y} 
&& &&
\bar{\mathbf{y}}_m\in\mathbb{R}^{D_\Omega\times 12}\\
\text{Climatology}: && &&
\bar{\mathbf{y}}_c &= \frac{1}{T_c}\sum_{t=1}^{T_c}\mathbf{y}_t
&& &&
\bar{\mathbf{y}}_m\in\mathbb{R}^{D_\Omega\times 12}\\
\end{aligned}
$$
where $T_c$ is the period of a considered climatology, e.g., 30 years, and $\mathbf{k}_m$ is a kernel for a month.

**Feature Engineering**