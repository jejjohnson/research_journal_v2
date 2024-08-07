---
title: Concepts - Function Apprximate
subject: ML4EO
short_title: Function Approximation
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


## Formulation

$$
\begin{aligned}
y_n &= \boldsymbol{y}(\mathbf{s}_n, t_n)
\end{aligned}
$$

## Examples

**State Variables**:
* Binary - Ocean/Land Masks (Differentiable Mask)
* Continuous: Orography, Topography (Compressed Differentiable Topogrophy)


**Summary Statistics**:
* Mean Climate Fields, $u(\mathbf{s}), u(t)$

**Data Compresssion**:
* L2 - Interpolated Data (SST, SSH, SSS, OC)
* L3 - Reanalysis Data (Compressed Reanalysis)

**Unstructured**
* L1 - Weather Stations (Observations Interpolation)