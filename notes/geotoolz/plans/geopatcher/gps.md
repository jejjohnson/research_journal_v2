---
title: "Fitting Gaussian Processes with the Patcher framework"
subject: geopatcher plan
short_title: "GP fitting"
authors:
  - name: J. Emmanuel Johnson
    affiliations:
      - UNEP
      - IMEO
      - MARS
    orcid: 0000-0002-6739-0053
    email: jemanjohnson34@gmail.com
license: CC-BY-4.0
keywords: geopatcher, Gaussian-processes, patcher, hierarchical, sparse-GP, inverse-variance-pooling
---

# Fitting Gaussian Processes with the Patcher Framework

The framework supports the full spectrum of GP fitting strategies through one uniform interface: configure a Patcher, define an operator, choose an aggregation. The differences between strategies show up in which pooling regime you commit to, which geometry fits your data, and how you merge per-patch posteriors. This section walks through the six canonical configurations and three predict-side patterns.

> **Primitives.** This page assumes the patcher / operator / aggregation
> primitives introduced in the geopatcher [design](design.md), with
> [scaling](scaling.md) for parallelism and pooling strategy. The architectural
> placement in the broader stack is described in
> [Report 7 — `geopatcher`](../../master_plan/toolz_5_geopatcher.md).

## The design space

Four orthogonal choices define a GP workflow:

| Axis | Options |
|------|---------|
| **Pooling regime** | Complete (shared θ) / None (per-patch θᵢ) / Partial (hierarchical φ + {θᵢ}) |
| **Fit scope** | Global / Per patch / Joint hierarchical / Amortized (sparse, spectral) |
| **Predict scope** | Global field / Specific points / Streaming reconstruction |
| **Geometry** | Rectangular, SphericalCap (gridded) / RadiusGraph, KNNGraph (unstructured) |

Two framework features carry most of the GP-specific weight:

- **`InvVarWeightedMean` aggregation** — the natural way to merge overlapping GP posteriors while preserving uncertainty (the Kalman-style inverse-variance combination).
- **Local Cholesky** — a per-patch GP with `n ≪ N` points solves an O(n³) system instead of O(N³). The Patcher *is* that decomposition.

---

## Mode 1: Global GP — complete pooling, no patching

The textbook case. One θ, one big Gram matrix. The Patcher is degenerate (one patch covering the whole field) so the interface stays uniform, but no real patching happens.

```python
patcher = Patcher(
    geometry    = Rectangular(size=field.shape),
    sampler     = Explicit(anchors_=[field.domain.origin]),
    window      = Boxcar(),
    aggregation = OverlapAdd(),
)

[patch] = patcher.split(training_field)
gp = GP(kernel=Matern()).fit(patch.coords, patch.values)

[query] = patcher.split(query_field)
mu, var = gp.predict_with_var(query.coords)
```

**Assumption**: stationarity across the entire field. **Cost**: O(N³) at fit, O(N²) per query — doesn't scale past ~10⁴ points. **Use when**: N is small enough that scaling isn't a concern.

---

## Mode 2: Local Cholesky with shared θ — complete pooling, local compute

The same θ as Mode 1, but factorized through patches for computational scaling. θ is fit jointly via a pooled likelihood across all training patches; each prediction uses only its local patch.

```
                 ┌─── pooled marginal likelihood ───┐
   training      ▼                                   │
   patches:    P₁ ── log p(y₁|x₁,θ) ─────────────────┤
               P₂ ── log p(y₂|x₂,θ) ─────────────────┤── argmax_θ ──▶ θ*
               P₃ ── log p(y₃|x₃,θ) ─────────────────┤
                                                     │
                                                     └─── shared θ

   prediction:  P_q ── local Cholesky with θ* ──▶ (μ_q, σ²_q)
                                                       │
                                                       ▼
                                            InvVarWeightedMean merge
```

```python
patcher = Patcher(
    geometry    = Rectangular(size=(64, 64)),
    sampler     = RegularStride(step=(48, 48)),
    window      = Hann(),
    aggregation = InvVarWeightedMean(),
)

# ── Fit: shared θ via pooled marginal likelihood ──
training_patches = list(patcher.split(training_field))

def joint_nll(theta):
    return sum(GP(kernel=Matern(theta)).nll(p.coords, p.values)
               for p in training_patches)

theta_star = minimize(joint_nll, theta_init)

# ── Predict: per-patch posterior with shared θ, merge with uncertainty ──
def operator(patch):
    gp = GP(kernel=Matern(theta_star)).fit(patch.coords, patch.values)
    return gp.predict_with_var(patch.query_coords)        # → (μ, σ²)

mu, var = patcher.merge(
    (operator(p) for p in patcher.split(query_field)),
    query_field.domain,
)
```

**Assumption**: stationarity (same as Mode 1). **Cost**: O(n³) per patch, embarrassingly parallel. **Why it works**: when θ is genuinely stationary, a sufficiently large local Gram matrix captures the same local posterior as a global GP would, with negligible accuracy loss.

This is the most common production setup for "GP on a big field."

---

## Mode 3: Per-patch GP — no pooling

Each patch fits its own θᵢ independently. Maximum local adaptivity, no shared structure.

```
   training      P₁ ──▶ fit θ₁ from (x₁, y₁) only
   patches:      P₂ ──▶ fit θ₂ from (x₂, y₂) only
                 P₃ ──▶ fit θ₃ from (x₃, y₃) only

                 (no information flow between patches)

   prediction:   each query patch uses its locally-fit θᵢ
                 InvVarWeightedMean to merge overlapping posteriors
```

```python
patcher = Patcher(
    geometry    = Rectangular(size=(64, 64)),
    sampler     = RegularStride(step=(48, 48)),
    window      = Hann(),
    aggregation = InvVarWeightedMean(),
)

# ── Fit: independent θᵢ per patch ──
training_patches = list(patcher.split(training_field))
thetas = [fit_gp_hyperparams(p.coords, p.values) for p in training_patches]

# ── Predict: per-patch GP with its own θᵢ, merge ──
def operator(patch, theta_i):
    return GP(kernel=Matern(theta_i)).fit(patch.coords, patch.values) \
                                     .predict_with_var(patch.query_coords)

mu, var = patcher.merge(
    (operator(p, t) for p, t in zip(patcher.split(query_field), thetas)),
    query_field.domain,
)
```

**Assumption**: arbitrary non-stationarity. **Cost**: O(n³) per patch, embarrassingly parallel. **Watch out for**: small/sparse patches give noisy θᵢ; boundaries between patches with very different θᵢ show discontinuities the Hann window only partially hides. If either is a real problem, Mode 4 fixes it.

---

## Mode 4: Hierarchical GP — partial pooling

Per-patch θᵢ tied through a shared hyperprior φ. Joint Bayesian fit; θᵢ adapts locally but is shrunk toward the population φ.

```
                        ┌─────┐
                        │  φ  │  hyperprior, fit jointly across patches
                        └──┬──┘
            ┌──────────────┼──────────────┐
            ▼              ▼              ▼
         p(θ₁|φ)       p(θ₂|φ)        p(θ₃|φ)
            │              │              │
            ▼              ▼              ▼
          GP(θ₁)         GP(θ₂)         GP(θ₃)
            │              │              │
          Patch 1        Patch 2        Patch 3
```

```python
patcher = Patcher(
    geometry    = Rectangular(size=(64, 64)),
    sampler     = RegularStride(step=(48, 48)),
    window      = Hann(),
    aggregation = InvVarWeightedMean(),
)

# ── Fit: joint hierarchical posterior ──
training_patches = list(patcher.split(training_field))

# Probabilistic model (NumPyro-style):
#   φ ~ p(φ)
#   θᵢ | φ ~ p(θᵢ | φ)
#   yᵢ | xᵢ, θᵢ ~ GP(0, k_θᵢ)(xᵢ)
posterior = run_hmc(hierarchical_gp_model, training_patches)

# ── Predict: marginalize over the posterior of θᵢ ──
def operator(patch, theta_samples_i):
    mus, vars_ = zip(*[
        GP(Matern(t)).fit(patch.coords, patch.values).predict_with_var(patch.query_coords)
        for t in theta_samples_i
    ])
    return law_of_total_variance(mus, vars_)              # → (μ, σ²) marginalized

mu, var = patcher.merge(
    (operator(p, posterior.theta_samples(i))
     for i, p in enumerate(patcher.split(query_field))),
    query_field.domain,
)
```

**Assumption**: structured non-stationarity — patches differ but are drawn from a shared population. **Cost**: significant — joint hierarchical inference (HMC, SVI) is more expensive than per-patch MAP. **Why it's worth it**: sparse patches inherit reasonable θᵢ from φ rather than overfitting; boundaries are softer because neighboring θᵢ's are pulled toward the same φ; uncertainty in φ propagates correctly into the predictions.

The marginalized predictor (averaging over the posterior of θᵢ) gives properly calibrated uncertainty — the variance accounts for hyperparameter uncertainty, not just observation noise.

---

## Mode 5: Sparse / inducing-point GP — global model, patched likelihood

Truly global GP at O(NM² + M³) instead of O(N³): M inducing points u shared across the whole field, patches feed in likelihood contributions.

```
   M inducing points u ─── shared globally, optimized jointly
                │
                │ contributes to every patch's likelihood
                ▼
   training:  patches ──▶ each contributes log p(yᵢ | xᵢ, u, θ)
              P₁,P₂,...    summed across patches → ELBO → update {u, θ, q(u)}

   prediction: every query point uses the same global q(u)
               local conditional p(y* | x*, q(u)) per patch
```

```python
fit_patcher = Patcher(
    geometry    = Rectangular(size=(64, 64)),
    sampler     = Random(n_samples=BATCH),                # training augmentation
    window      = Boxcar(),
    aggregation = None,                                    # no reconstruction at fit
)

q_u, theta = init_sparse_gp(M=512)
for epoch in range(N_EPOCHS):
    for patch in fit_patcher.split(training_field):
        elbo_term = sparse_gp_elbo_term(patch.coords, patch.values, q_u, theta)
        q_u, theta = update((q_u, theta), elbo_term)

# Predict: globally, using shared q_u
predict_patcher = fit_patcher.replace(sampler=RegularStride(step=(48, 48)),
                                      window=Hann(),
                                      aggregation=InvVarWeightedMean())

def operator(patch):
    return sparse_gp_predict(patch.query_coords, q_u, theta)   # → (μ, σ²)

mu, var = predict_patcher.merge(
    (operator(p) for p in predict_patcher.split(query_field)),
    query_field.domain,
)
```

**Assumption**: a global model with M inducing points captures the field. **Cost**: O(M³) per update plus O(nM²) per patch; scales to massive N. **Watch out for**: M-too-small underfits; placement of inducing points matters (k-means init, random subset, or learned).

The natural mode when you want one model (Case 1, complete pooling) but the dataset is far too big for Mode 1's dense Cholesky.

---

## Mode 6: Spectral / Hilbert-Space GP — feature-space scaling

Alternative to Mode 5: project to a finite spectral basis (RFF, HSGP, spherical harmonics) and learn weights in feature space. Same global-model spirit, different scaling mechanism — and notably, **the fit itself is a streaming aggregation**.

```python
# Features shared globally — e.g. HSGP basis on the sphere, RFF in Euclidean space
phi = HSGP(num_basis=2048, domain=field.domain)

fit_patcher = Patcher(
    geometry    = Rectangular(size=(64, 64)),
    sampler     = RegularStride(step=(64, 64)),           # non-overlapping for fit
    window      = Boxcar(),
    aggregation = None,
)

# Streaming accumulation of sufficient statistics: ΦᵀΦ and Φᵀy are monoidal
phi_t_phi = np.zeros((phi.n_basis, phi.n_basis))
phi_t_y   = np.zeros(phi.n_basis)
for patch in fit_patcher.split(training_field):
    Phi = phi(patch.coords)                               # (n, n_basis)
    phi_t_phi += Phi.T @ Phi
    phi_t_y   += Phi.T @ patch.values

# One global linear solve in feature space
w_mean, w_cov = bayesian_linear_solve(phi_t_phi, phi_t_y, sigma2_prior)

# Predict
def operator(patch):
    Phi_q = phi(patch.query_coords)
    mu    = Phi_q @ w_mean
    var   = (Phi_q @ w_cov * Phi_q).sum(-1)
    return mu, var
```

No minibatch ELBO needed — the sufficient statistics `ΦᵀΦ` and `Φᵀy` are exact monoidal reductions across patches. This is one of the cleanest mappings of GP scaling onto the streaming framework.

---

## Predict-side patterns

Three useful predict-side patterns cut across all six modes.

### Pattern A: Global field prediction with uncertainty

Use `InvVarWeightedMean` instead of `OverlapAdd`. It costs one extra accumulator (precision) but propagates uncertainty through the merge.

```python
predict_patcher = Patcher(..., aggregation=InvVarWeightedMean())
mu_field, var_field = predict_patcher.merge(
    (operator(p) for p in predict_patcher.split(query_field)),
    query_field.domain,
)
```

A caveat worth knowing: inverse-variance merging assumes the per-patch posteriors are conditionally independent given the parameters. They aren't exactly — overlapping patches see overlapping training data. This is the standard composite-likelihood approximation in the local-GP literature; it works well in practice for moderate overlap and is asymptotically equivalent to the exact posterior in the limit of large patches.

### Pattern B: Prediction at specific query points

Sometimes you want predictions at facility locations, station coordinates, or polygon centroids — not a dense grid. The Patcher's geometry becomes a `RadiusGraph` or `KNNGraph` defining the *training* neighborhood per query point.

```python
predict_patcher = Patcher(
    geometry    = RadiusGraph(radius=50_000),             # training data near each query
    sampler     = Explicit(anchors_=query_points),
    window      = Gaussian(sigma=20_000),
    aggregation = ByIndex(),                               # dict keyed by query id
)

def operator(patch):
    return GP(Matern(theta_star)).fit(patch.coords, patch.values) \
                                 .predict_with_var(patch.anchor)   # single point

predictions: dict[int, tuple[float, float]] = {
    p.anchor: operator(p) for p in predict_patcher.split(training_field)
}
```

The natural pattern for **predicting at a fixed set of locations from scattered data** — one of the most common geoscience GP workflows (oceanography in-situ, environmental monitoring, methane facility-level inversion).

### Pattern C: Streaming global inference

For inference over a global field too big to hold in RAM, combine `InvVarWeightedMean` with `streaming=True` and optionally a hierarchical outer Patcher.

```python
predict_patcher = Patcher(
    geometry    = Rectangular(size=(64, 64)),
    sampler     = RegularStride(step=(48, 48)),
    window      = Hann(),
    aggregation = InvVarWeightedMean(streaming=True,
                                     target_path="global_gp.zarr"),
)

result = predict_patcher.merge(
    (operator(p) for p in predict_patcher.split(field)),
    field.domain,
)
# result is a ZarrField with mean and variance bands on disk
```

---

## Summary: which mode for which problem

| Problem | Mode | Geometry | Aggregation |
|---------|------|----------|-------------|
| Small N, stationary, no scaling worry | 1 | n/a (one patch) | n/a |
| Big N, stationary, want local compute | 2 | Rectangular / SphericalCap | `InvVarWeightedMean` |
| Big N, non-stationary, abundant data | 3 | Rectangular / RadiusGraph | `InvVarWeightedMean` |
| Big N, non-stationary, sparse patches | 4 | Rectangular / RadiusGraph | `InvVarWeightedMean` |
| Massive N, stationary, want one model | 5 | Rectangular (random fit, regular predict) | `InvVarWeightedMean` |
| Massive N, sphere or structured basis | 6 | matched to feature space | streaming sum + `InvVarWeightedMean` |
| Predicting at known query points | A/B | RadiusGraph / KNNGraph | `ByIndex` |

The throughline: **`InvVarWeightedMean` is the right merge for every mode that produces a posterior**, which is essentially every mode. Once that's in the toolkit, the differences between modes reduce to fit-time choices — what's pooled, what's per-patch, what's amortized — and the Patcher framework hides everything else.
