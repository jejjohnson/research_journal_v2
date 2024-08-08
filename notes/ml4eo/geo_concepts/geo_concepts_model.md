---
title: Computational Model
subject: ML4EO
subtitle: Computational and Mathematical Modeling
short_title: Modeling
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

* System
* Abstraction
* Analysis + Simulation
* Predictions


***
## Overview

```{figure} https://github.com/AllenDowney/ModSim/raw/main/figs/modeling_framework.png
:label: myFigure
:alt: Sunset at the beach
:align: center

A schematic for Modeling and Simulating Physical Systems. Source: [Book (Modeling and Simulation in Python)](https://allendowney.github.io/ModSimPy/chap01.html)
```

We have a *system* which represents the state, $z$.
We **never** observe the state. **Never**.
We only have *measurements*, $y$, which are a sparse representation of our system. i.e., they don't cover the whole globe at every given point in space and time.

So how do we learn? 
One way to do so is through mathematical modeling:
* Can I recreate what I can measure? 
* Does what I create make sense and can I explain it?



**Note**: that second step is what I would separate **learning** from **estimation/predictions**.
I can easily construct a data-driven model which can emulate something given data.
But I don't consider it really learning unless I have asked a question first and I feel happy with my answer.

**Example**:

$$
\theta^* = \argmax \hspace{2mm} p(\theta|\mathcal{D})
$$

* Can we produce a similar density?
* Can I generate samples that look like what I measure?
* Is there a covariate that can improve our predictability?
* Can I explain my process parameterization? 
* If I add or remove components of my model, does it increase or decrease the predictability or maximize/minimize some given criteria?



***
## What can go wrong

### Data, $\mathcal{D}$

* None
* Sparsity
* Missingness (MCAR, MAR, MNAR)
* High-Dimensional 
* Uncertain

### Domain, $\Omega$

* Outside Spatiotemporal Convex Hull
* Inside Spatiotemporal Convex Hull
* Irregular Hull Shape
* Unstructured Shape, i.e., point clouds

### Transformation, $T,\mathcal{\Theta}$

* Unknown
* Incorrect, i.e., model specification
* Approximate (incomplete)
* Expensive (computation, Memory)
* Uncertain

### Learning, $p(\mathcal{M}|\mathcal{D})$.

* Solution Exists?
* Can We find the Solution?
* How do we find the solution?
* How do we know we've found the solution?
* How fast can we find the solution?
* Where do we start?
