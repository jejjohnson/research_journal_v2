---
title: Problem Category
subject: ML4EO
# subtitle: How can I estimate the state AND the parameters?
short_title: Spatial Operators
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


**Finite Difference**

$$
\partial_x f \approx \frac{f(s+\Delta_s) - f(s)}{\Delta s}
$$

In this case, our encoder is a point average scheme
The reconstructor is a polynomial interpolant.

**Finite Volume**

$$
\partial_x f \approx \int_s^{s+\Delta_s}f(s+\frac{1}{2})ds
$$

In this case, our encoder are cell averages. 
The reconstructor is also a polynomial interpolant of varying complexity.

**Finite Element**

In this case, we have node values.
We reconstructor is a Galerkin basis.

**PsuedoSpectral**

In this case, we have Fourier coefficients.
The reconstructor is Fourier interpolation.

