---
title: coordax — tutorials
short_title: coordax
subject: coordax tutorial
subtitle: Pedagogical tutorials for coordax, the coordinate-aware JAX array library
authors:
  - name: J. Emmanuel Johnson
    affiliations:
      - UNEP
      - IMEO
      - MARS
    orcid: 0000-0002-6739-0053
    email: jemanjohnson34@gmail.com
license: CC-BY-4.0
keywords: [coordax, tutorials, jax, xarray, fields, derivatives, dynamics]
---

# coordax notebooks

Showcase notebooks ported from [jej_vc_snippets/jax/coordax](https://github.com/jejjohnson/jej_vc_snippets/tree/main/jax/coordax) —
pedagogical tutorials for [coordax](https://github.com/neuralgcm/coordax), a
coordinate-aware array library for JAX that sits between raw `jax.numpy`
arrays and the full `xarray` {cite}`hoyer2017xarray` stack.

Each notebook is executed end-to-end with outputs embedded, so everything
(prints, tables, numeric checks) renders inline in the MyST docs site without
re-execution.

Each sub-section is a curated landing page that leads with the math,
numerics, and references before pointing at the notebooks themselves.

## [Foundations](./content/foundations/README.md)

| Notebook | Topic |
|---|---|
| [`foundations/01_create_datasets.ipynb`](./content/foundations/01_create_datasets.ipynb) | Wrapping arrays as `Field` objects with `LabeledAxis` / `SizedAxis` |
| [`foundations/02_ops_unary_binary.ipynb`](./content/foundations/02_ops_unary_binary.ipynb) | Arithmetic, comparison, and unary ops on `Field`; broadcasting rules |
| [`foundations/03_ops_coordinates.ipynb`](./content/foundations/03_ops_coordinates.ipynb) | `isel`, `sel`, reindexing, `CartesianProduct`, coordinate composition |
| [`foundations/04_reductions.ipynb`](./content/foundations/04_reductions.ipynb) | Coordinate-aware reductions: sum, mean, max over named dims |

## [Derivatives](./content/derivatives/README.md)

| Notebook | Topic |
|---|---|
| [`derivatives/05_finite_difference.ipynb`](./content/derivatives/05_finite_difference.ipynb) | Periodic + non-uniform finite-difference derivatives; `cmap` pattern |
| [`derivatives/06_spherical_harmonics_derivatives.ipynb`](./content/derivatives/06_spherical_harmonics_derivatives.ipynb) | Spherical-harmonic derivatives on a Gauss-Legendre lat-lon grid (no FD pole singularity); Laplacian; vorticity and divergence |
| [`derivatives/07_finite_volume.ipynb`](./content/derivatives/07_finite_volume.ipynb) | Cell-centred FV operators; flux divergence; conservative schemes |

## [Dynamics](./content/dynamics/README.md)

| Notebook | Topic |
|---|---|
| [`dynamics/08_ode_integration.ipynb`](./content/dynamics/08_ode_integration.ipynb) | Integrating ODEs (advection-diffusion) with `diffrax`; state as `Field` |
| [`dynamics/09_ode_parameter_state_estimation.ipynb`](./content/dynamics/09_ode_parameter_state_estimation.ipynb) | Joint parameter/state estimation via `optax` + `jax.value_and_grad` |
| [`dynamics/10_pde_parameter_estimation.ipynb`](./content/dynamics/10_pde_parameter_estimation.ipynb) | Learning PDE parameters from data; coordinate-aware residuals |

## Running locally

These notebooks depend on `coordax` and its ML stack (JAX, diffrax, optax,
equinox). The committed `.ipynb` files carry their cell outputs, so MyST
renders them inline without needing the kernel installed — no extra setup
is required to view the site.

Re-executing the notebooks is not part of this repo's tooling. The source
environment lives in [`jej_vc_snippets/jax/coordax`](https://github.com/jejjohnson/jej_vc_snippets/tree/main/jax/coordax),
which ships a pixi environment with `coordax`, JAX, diffrax, optax, and
equinox pinned together.
