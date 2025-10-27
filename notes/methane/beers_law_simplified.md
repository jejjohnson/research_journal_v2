---
title: Beer-Lambert's Law - Simplified
subject: Methane
short_title: Simplified
authors:
  - name: J. Emmanuel Johnson
    affiliations:
      - United Nations Environmental Programme
    orcid: 0000-0002-6739-0053
    email: juan.johnson@un.org
license: CC-BY-4.0
keywords: methane
abbreviations:
  PSF: Point Spread Function
  SRF: Spectral Response Function
  GSD: Ground Sample Distance
  AMF: Air Mass Factor
  ODE: Ordinary Differential Equation
  RTE: Radiative Transfer Equation
---

Combined Approximation (Taylor + MacLaurin) - Relative/Normalized Radiance

## Introduction: The Operational Standard

The **relative combined linearized model** represents the most widely used formulation in operational atmospheric methane detection. This model applies **two sequential approximations**—Taylor expansion of optical depth followed by MacLaurin approximation of the exponential—to the normalized Beer-Lambert law, resulting in a **fully linear** relationship between observations and methane enhancement.

### Historical Context and Adoption

This formulation emerged from the practical needs of satellite and airborne hyperspectral methane detection in the 2010s. Early systems struggled with:

1. **Computational constraints**: Processing millions of pixels in real-time
2. **Calibration uncertainties**: Absolute radiometric calibration errors of 5-10%
3. **Scene variability**: Surface reflectance variations of 2-10× across footprints

The relative combined model addressed all three challenges by providing a **fast, calibration-independent, linear detection algorithm** with acceptable accuracy for moderate plumes.

**Key operational systems using this approach:**
- AVIRIS-NG (NASA/JPL airborne)
- GHGSat constellation (commercial satellites)
- Sentinel-5P TROPOMI (in some retrieval algorithms)
- EnMAP methane product
- Carbon Mapper constellation

### Relationship to Model Family

This model sits at the **"sweet spot"** in the approximation hierarchy:


Exact ←────────── Approximation Level ──────────→ Simplified
│                                                          │
Nonlinear          Taylor Only        Combined         MacLaurin Only
(Models 1, 1B)     (Models 3, 3B)    (Models 4, 4B)    (Models 2, 2B)
│                  │                  │                  │
Most Accurate      Good Accuracy     Practical         Theoretical
Slowest            Moderate Speed    Fast              Fastest
Iterative          Iterative         Closed-Form       Closed-Form
All Plumes         τ < 0.3           τ < 0.1           τ < 0.05



**Model 4B combines:**

1. **Taylor expansion** (Model 3B): Linearizes optical depth around background → handles concentration perturbations
2. **MacLaurin approximation** (Model 2B): Linearizes exponential transmittance → enables closed-form solution
3. **Normalization**: Divides by background radiance → eliminates calibration dependencies

**Result:** A **fully linear, calibration-independent, closed-form** detection algorithm.

### The Two Approximations: Physical Justification

#### Approximation 1: Taylor Expansion of Optical Depth

**Mathematical form:**

$$\tau(\text{VMR}) = \tau(\text{VMR}_0 + \Delta\text{VMR}) \approx \tau_0 + \frac{d\tau}{d\text{VMR}}\bigg|_0 \cdot \Delta\text{VMR}$$

**Physical justification:**

Optical depth is defined as:

$$\tau = \int_0^L \sigma(s) n_{\text{CH}_4}(s) \, ds$$

where $s$ is path coordinate. For well-mixed plumes over a sensor footprint:

$$\tau = \sigma \cdot N_{\text{total}} \cdot \text{VMR} \cdot 10^{-6} \cdot L \cdot \text{AMF}$$

This is **exactly linear in VMR** (no approximation needed for $\tau$ itself). The Taylor expansion becomes exact:

$$\tau(\text{VMR}_0 + \Delta\text{VMR}) = \tau_0 + \frac{d\tau}{d\text{VMR}} \cdot \Delta\text{VMR}$$

because $\frac{d^2\tau}{d\text{VMR}^2} = 0$ (second derivative vanishes).

**Key insight:** This isn't really an approximation—it's an **exact representation** of the linear relationship between concentration and optical depth. The "approximation" comes from assuming:

- **Spatial homogeneity**: VMR constant over footprint
- **Vertical well-mixing**: Concentration uniform through boundary layer
- **Path-averaged properties**: Single effective $\sigma$, $N_{\text{total}}$

**When it breaks down:**

- Vertically stratified plumes (elevated sources)
- Strong horizontal gradients within pixel
- Sub-pixel plume structure

**Typical accuracy:** 1-5% error for boundary layer plumes, 10-20% for elevated plumes

#### Approximation 2: MacLaurin Expansion of Exponential

**Mathematical form:**

$$\exp(-\Delta\tau) \approx 1 - \Delta\tau$$

**Physical justification:**

The exponential represents the **multiplicative attenuation** through the atmosphere. For weak absorption:

Full series:

$$\exp(-\Delta\tau) = 1 - \Delta\tau + \frac{(\Delta\tau)^2}{2!} - \frac{(\Delta\tau)^3}{3!} + \cdots$$

Truncate at first order:

$$\exp(-\Delta\tau) \approx 1 - \Delta\tau$$

**Truncation error:**

$$\text{Error} = \frac{(\Delta\tau)^2}{2!} - \frac{(\Delta\tau)^3}{3!} + \cdots \approx \frac{(\Delta\tau)^2}{2}$$

**Relative error:**

$$\frac{|\text{Error}|}{\exp(-\Delta\tau)} \approx \frac{(\Delta\tau)^2/2}{1 - \Delta\tau} \approx \frac{(\Delta\tau)^2}{2}$$ (for small $\Delta\tau$)

**Numerical accuracy table:**

| $\Delta\tau$ | Fractional Absorption | Relative Error | Acceptable? |
|--------------|----------------------|----------------|-------------|
| 0.01 | 1.0% | 0.005% | ✓ Excellent |
| 0.05 | 4.9% | 0.13% | ✓ Very good |
| 0.10 | 9.5% | 0.5% | ✓ Good (threshold) |
| 0.15 | 13.9% | 1.1% | ⚠ Marginal |
| 0.20 | 18.1% | 2.0% | ✗ Poor |
| 0.30 | 25.9% | 4.7% | ✗ Very poor |

**Operational threshold:** Most systems require $\Delta\tau < 0.1$ (< 10% absorption) for this approximation.

**Physical interpretation of validity:**

The MacLaurin approximation assumes **weak absorption** where:

1. **Most photons survive**: $T = \exp(-\Delta\tau) \approx 1 - \Delta\tau > 0.9$
2. **Linear regime**: Fractional change proportional to optical depth
3. **No saturation**: Absorption doesn't significantly deplete the radiation field

**When it breaks down:**

- Strong absorption lines (line centers at high resolution)
- Very large plumes (>2000 ppm for typical SWIR conditions)
- Long path lengths (thick boundary layers, oblique viewing)

**Typical accuracy:** 0.5% for $\Delta\tau < 0.1$, degrades rapidly beyond

### Combined Effect: Why Two Approximations Work Together

**Synergistic simplification:**

Starting from exact normalized radiance:

$$L_{\text{norm}} = \exp(-\Delta\tau(\Delta\text{VMR}))$$

Apply both approximations:

$$L_{\text{norm}} \approx \exp\left(-\frac{d\tau}{d\text{VMR}} \cdot \Delta\text{VMR}\right) \approx 1 - \frac{d\tau}{d\text{VMR}} \cdot \Delta\text{VMR}$$

**Result:** Linear in $\Delta\text{VMR}$!

**Computational advantage:**

- **Exact model**: Requires iterative nonlinear optimization (5-20 iterations)
- **Taylor only** (Model 3B): Still requires iteration (exponential is nonlinear)
- **MacLaurin only** (Model 2B): Linear but uses total optical depth (less accurate)
- **Combined**: Closed-form solution (single matrix operation)

**Speed comparison:**

- Exact: ~10-100 ms/pixel (iterative)
- Taylor only: ~5-20 ms/pixel (fewer iterations)
- **Combined: ~0.1-1 ms/pixel** (direct solve)
- MacLaurin only: ~0.1-1 ms/pixel (but worse accuracy)

For a 1000×1000 pixel hyperspectral cube:

- Exact: ~3-28 hours
- Taylor only: ~1.5-6 hours
- **Combined: ~2-17 minutes** ← Practical for operations
- MacLaurin only: ~2-17 minutes (but unacceptable errors)

**This 100× speedup enables real-time processing** essential for operational systems.

### Accuracy vs. Computational Cost Trade-off

**The Pareto frontier:**
Accuracy
↑
│  Exact Nonlinear ●
│                    ╲
│                     ╲
│                      ╲ Taylor Only
│                       ●
│                        ╲╲
│                          ╲╲
│                  Combined ●●●●  ← Optimal trade-off
│                              ╲╲╲╲
│                                  ╲╲╲╲
│                        MacLaurin Only ●
└────────────────────────────────────────→ Speed


**Model 4B occupies the "knee" of the curve**: Maximum gain in speed for minimum loss in accuracy.

**Quantitative comparison for $\Delta\text{VMR} = 500$ ppm (typical moderate plume):**

| Model | Retrieval Error | Computation Time | Operational? |
|-------|----------------|------------------|--------------|
| Exact Nonlinear | 0% (reference) | 50 ms/pixel | ✗ Too slow |
| Taylor Only | ~2-5% | 10 ms/pixel | ⚠ Borderline |
| **Combined (4B)** | **~5-10%** | **0.5 ms/pixel** | **✓ Optimal** |
| MacLaurin Only | ~15-20% | 0.5 ms/pixel | ✗ Too inaccurate |

**Decision rationale for operational systems:**

- 5-10% retrieval error is **acceptable** (within other uncertainties like wind speed for flux estimation)
- 100× speedup is **essential** for real-time large-area surveys
- Combined model provides **best balance**

---

## 1. Concentration (Background + Enhancement)

**Same as all models:**

$$\text{VMR}_{\text{total}} = \text{VMR}_{\text{bg}} + \Delta\text{VMR}$$

No approximation applied to this fundamental relationship.

---

## 2. Optical Depth + Jacobian

### Optical Depth (Taylor Expansion Applied)

**Background optical depth** (exact):

$$\tau_{\text{bg}} = \sigma \cdot N_{\text{total}} \cdot \text{VMR}_{\text{bg}} \cdot 10^{-6} \cdot L \cdot \text{AMF}$$

**Differential optical depth** (Taylor expansion around background):

Since $\tau$ is linear in VMR, the Taylor expansion is **exact**:

$$\Delta\tau = \tau(\text{VMR}_{\text{total}}) - \tau_{\text{bg}} = \frac{\partial \tau}{\partial \text{VMR}}\bigg|_{\text{bg}} \cdot \Delta\text{VMR}$$

**Explicit form:**

$$\boxed{\Delta\tau = \sigma \cdot N_{\text{total}} \cdot \Delta\text{VMR} \cdot 10^{-6} \cdot L \cdot \text{AMF}}$$

**Units:** dimensionless

**Physical interpretation:**

- $\Delta\tau$ is the **additional optical depth** due to plume enhancement only
- Independent of background conditions ($\tau_{\text{bg}}$ doesn't appear)
- **Linear in enhancement**: $\Delta\tau \propto \Delta\text{VMR}$

**This is where the first "approximation" enters**, but it's really the assumption that:

$$\Delta\tau = \Delta\text{VMR} \cdot \underbrace{\sigma \cdot N_{\text{total}} \cdot 10^{-6} \cdot L \cdot \text{AMF}}_{\text{constant over footprint}}$$

**Validity requires:**

1. **Spatially uniform** enhancement over sensor footprint
2. **Single effective path length** $L$ (not vertically varying)
3. **Constant atmospheric state** ($T$, $P$ uniform → $\sigma$, $N_{\text{total}}$ uniform)

**Typical operational conditions where this holds:**

- Boundary layer plumes (well-mixed below 1-2 km)
- Footprint sizes 30-60 m (smaller than typical plume scale)
- Moderate wind conditions (promotes mixing)

**Where it breaks down:**

- Elevated plumes with vertical structure
- Sub-footprint plume edges (sharp gradients)
- Very large footprints (>100 m) relative to plume size

### Jacobian of Optical Depth

$$\frac{\partial (\Delta\tau)}{\partial (\Delta\text{VMR})} = \sigma \cdot N_{\text{total}} \cdot 10^{-6} \cdot L \cdot \text{AMF}$$

**Units:** ppm⁻¹

**Key property:** **Constant** (independent of VMR, exact for linear $\tau$)

This constant Jacobian is what enables the **closed-form solution** later.

---

## 3. Transmittance + Jacobian

### Transmittance (Both Approximations Combined)

**Normalized transmittance** (definition, exact):

$$T_{\text{norm}} = \frac{T_{\text{total}}}{T_{\text{bg}}} = \frac{\exp(-\tau_{\text{total}})}{\exp(-\tau_{\text{bg}})} = \exp(-\Delta\tau)$$

**Apply MacLaurin approximation:**

$$T_{\text{norm}} \approx 1 - \Delta\tau$$

**With Taylor-expanded $\Delta\tau$:**

$$\boxed{T_{\text{norm}} \approx 1 - \sigma \cdot N_{\text{total}} \cdot \Delta\text{VMR} \cdot 10^{-6} \cdot L \cdot \text{AMF}}$$

**Units:** dimensionless

**Physical interpretation of combined approximation:**

Starting from exact physics:

$$T_{\text{norm}}(\Delta\text{VMR}) = \exp\left(-\sigma N_{\text{total}} \Delta\text{VMR} \cdot 10^{-6} L \cdot \text{AMF}\right)$$

The combined approximation replaces:

- **Exponential decay** → **Linear decay**
- **Multiplicative attenuation** → **Additive reduction**

**Why this works for weak absorption:**

Plot of $\exp(-x)$ vs. $1-x$:

1.0 ●────────────────
│╲  
│ ╲              Exponential
│  ╲             ───
0.9 │   ●            Linear approximation
│    ╲           ─ ─ ─
│     ╲  
│      ╲  
0.8 │       ●        Good match
│        ╲       for x < 0.1
│         ╲  
0.7 │          ●  
└─────────────→ Δτ
0   0.1  0.2  0.3


For $\Delta\tau < 0.1$: curves nearly identical → approximation excellent.

**Saturation effects (what we're missing):**

The exponential $\exp(-\Delta\tau)$ captures that:

- As $\Delta\tau \to \infty$: $T_{\text{norm}} \to 0$ (complete absorption, physical)
- Linear $1 - \Delta\tau$: Can become **negative** for $\Delta\tau > 1$ (unphysical)

The MacLaurin approximation **assumes we stay far from saturation** ($\Delta\tau \ll 1$).

**Operational impact:**

- For $\Delta\tau < 0.1$: Excellent approximation, <1% error
- For $\Delta\tau = 0.2$: ~2% error, acceptable for screening
- For $\Delta\tau > 0.3$: >5% error, should use Model 3B or 1B instead

### Jacobian of Transmittance

$$\frac{\partial T_{\text{norm}}}{\partial (\Delta\text{VMR})} = \frac{\partial}{\partial (\Delta\text{VMR})}[1 - \Delta\tau] = -\frac{\partial (\Delta\tau)}{\partial (\Delta\text{VMR})}$$

**Explicit form:**

$$\frac{\partial T_{\text{norm}}}{\partial (\Delta\text{VMR})} = -\sigma \cdot N_{\text{total}} \cdot 10^{-6} \cdot L \cdot \text{AMF}$$

**Units:** ppm⁻¹

**Key property:** **Constant** - does not vary with VMR or optical depth.

**Physical consequence:**

The constant Jacobian means the model predicts:

- **No saturation**: Sensitivity same at 100 ppm as at 5000 ppm
- **Linear response**: Double the VMR → double the signal

**Reality** (from exact model):

- **Saturation occurs**: $\frac{\partial T}{\partial \text{VMR}} = -\exp(-\Delta\tau) \cdot \frac{\partial \tau}{\partial \text{VMR}}$ decreases as $\Delta\tau$ increases
- **Nonlinear response**: Signal gain decreases for strong plumes

**Operational consequence:**

For moderate plumes ($\Delta\tau < 0.1$):

- Exact: $\exp(-0.1) \approx 0.905$ → Sensitivity reduced by 9.5%
- Combined model: Assumes sensitivity at 100% → **Slight overestimate**

This causes a **systematic bias**: The combined model will slightly **underestimate VMR** for moderate-to-strong plumes because it overestimates sensitivity.

**Correction factor:**

Empirical studies show the bias is approximately:

$$\text{Bias} \approx -\frac{(\Delta\tau)^2}{2} \cdot \hat{\alpha}_{\text{combined}}$$

For $\Delta\tau = 0.1$: Bias ≈ 0.5% underestimation (negligible).
For $\Delta\tau = 0.2$: Bias ≈ 2% underestimation (small).

**This is acceptable** given other uncertainties (wind speed, path length, etc. often 10-20%).

---

## 4. Beer's Law + Jacobian

### Beer's Law (Normalized, Linearized Form)

**Starting from normalized radiance:**

$$L_{\text{norm}} = T_{\text{norm}}$$

**Apply combined approximation:**

$$\boxed{L_{\text{norm}} \approx 1 - \Delta\tau = 1 - \sigma \cdot N_{\text{total}} \cdot \Delta\text{VMR} \cdot 10^{-6} \cdot L \cdot \text{AMF}}$$

**Units:** dimensionless

**This is the fundamental forward model:** Linear relationship between normalized radiance and VMR enhancement.

**Physical interpretation:**

$$L_{\text{norm}} = \underbrace{1}_{\text{background}} - \underbrace{\sigma N_{\text{total}} \cdot 10^{-6} L \cdot \text{AMF}}_{\text{sensitivity factor}} \cdot \underbrace{\Delta\text{VMR}}_{\text{plume strength}}$$

**Three components:**

1. **Unity baseline**: Background normalized to 1 (by definition)
2. **Sensitivity factor**: Depends on molecular physics ($\sigma$), atmosphere ($N_{\text{total}}$), geometry ($L$, AMF)
3. **Plume strength**: The unknown to estimate

**Advantages of this form:**

1. **Calibration-free**: No $F_0$ or $R$ appears
2. **Scene-independent**: Doesn't depend on $\tau_{\text{bg}}$ or $\text{VMR}_{\text{bg}}$
3. **Linear**: Simple structure enables closed-form inversion
4. **Physically interpretable**: Each term has clear meaning
5. **Computationally efficient**: Single matrix multiply for forward model

**Comparison across model hierarchy:**

| Model | Forward Model | Complexity | Accuracy |
|-------|---------------|------------|----------|
| Exact | $L_{\text{norm}} = \exp(-\sigma N \Delta\text{VMR} \cdot 10^{-6} L \cdot \text{AMF})$ | Nonlinear | Highest |
| Taylor only | $L_{\text{norm}} = \exp(-\Delta\tau)$ | Nonlinear | High |
| **Combined** | $L_{\text{norm}} = 1 - \sigma N \Delta\text{VMR} \cdot 10^{-6} L \cdot \text{AMF}$ | **Linear** | **Good** |
| MacLaurin only | $L_{\text{norm}} = 1 - \sigma N \text{VMR}_{\text{total}} \cdot 10^{-6} L \cdot \text{AMF}$ | Linear | Poor |

The combined model achieves the **optimal balance**.

### Jacobian of Normalized Radiance

$$\frac{\partial L_{\text{norm}}}{\partial (\Delta\text{VMR})} = -\sigma \cdot N_{\text{total}} \cdot 10^{-6} \cdot L \cdot \text{AMF}$$

**Units:** ppm⁻¹

**Key insight:** The Jacobian **is** the negative of the sensitivity factor.

**Wavelength dependence:**

Since $\sigma(\lambda)$ varies strongly with wavelength:

$$\mathbf{H}(\lambda) = -\boldsymbol{\sigma}(\lambda) \cdot N_{\text{total}} \cdot 10^{-6} \cdot L \cdot \text{AMF}$$

The Jacobian is a **vector** with different values at each wavelength:

- **Strong absorption lines**: Large $|\mathbf{H}|$ (high sensitivity)
- **Weak lines or continuum**: Small $|\mathbf{H}|$ (low sensitivity)

**This spectral structure is what enables detection**: The plume signal has a **characteristic spectral shape** matching the methane absorption spectrum.

**Matched filter exploits this** by correlating observations with the expected spectral signature.

---

## 5. Observations

### Observation Model

$$\mathbf{y}_{\text{norm}} = L_{\text{norm}}(\Delta\text{VMR}) + \boldsymbol{\epsilon}_{\text{norm}}$$

**With combined approximation:**

$$\mathbf{y}_{\text{norm}} = \mathbf{1} - \mathbf{H} \cdot \alpha + \boldsymbol{\epsilon}_{\text{norm}}$$

where:

- $\alpha = \Delta\text{VMR}$ (unknown, ppm)
- $\mathbf{H} = \boldsymbol{\sigma} \odot N_{\text{total}} \cdot 10^{-6} L \cdot \text{AMF}$ (known, ppm⁻¹)
- $\mathbf{1}$: vector of ones (n_wavelengths,)
- $\boldsymbol{\epsilon}_{\text{norm}} \sim \mathcal{N}(\mathbf{0}, \mathbf{\Sigma}_{\text{norm}})$: Gaussian noise

**Model structure:** This is a **standard linear Gaussian model**:

$$\mathbf{y}_{\text{norm}} = \boldsymbol{\mu} + \mathbf{H}\alpha + \boldsymbol{\epsilon}$$

where $\boldsymbol{\mu} = \mathbf{1}$ is the known mean.

**This enables textbook statistical inference:**

- Maximum likelihood estimation
- Least squares
- Bayesian inference
- Hypothesis testing

All have **closed-form analytical solutions**.

### Constructing Normalized Observations

**From absolute radiance:**

$$\mathbf{y}_{\text{norm}} = \frac{\mathbf{y}_{\text{abs}}}{\mathbf{L}_{\text{bg}}}$$

**Estimating background** $\mathbf{L}_{\text{bg}}$:

**Method 1: Spatial background** (most common)

- Select background pixels in scene (no plume)
- Options:
  - **Median**: Robust to outliers
  - **Mean of lowest 10%**: Conservative (avoids plume contamination)
  - **Gaussian mixture model**: Identify background cluster
- Typical: 50-100 background pixels averaged

**Method 2: Temporal background**

- Same location at different time (before/after plume)
- Requires persistent observation or plume variability

**Method 3: Model-based**

- Predict $\mathbf{L}_{\text{bg}}$ from atmospheric/surface model
- Less common (introduces model errors)

**Operational consideration:**

Choice of background estimation has **large impact** on performance:

- **Too few pixels**: Noisy background estimate
- **Contaminated pixels**: Biased background (underestimates plumes)
- **Different surface types**: Spectral differences can mimic plumes

**Best practice:** Use **spatially local, spectrally matched** background from **plume-free regions** with **median aggregation**.

### Noise Characteristics

**Normalized noise covariance:**

If absolute noise is $\boldsymbol{\epsilon}_{\text{abs}} \sim \mathcal{N}(\mathbf{0}, \mathbf{\Sigma}_{\text{abs}})$:

$$\boldsymbol{\epsilon}_{\text{norm}} = \frac{\boldsymbol{\epsilon}_{\text{abs}}}{\mathbf{L}_{\text{bg}}} \sim \mathcal{N}\left(\mathbf{0}, \text{diag}\left(\frac{1}{\mathbf{L}_{\text{bg}}}\right) \mathbf{\Sigma}_{\text{abs}} \text{diag}\left(\frac{1}{\mathbf{L}_{\text{bg}}}\right)\right)$$

**For diagonal $\mathbf{\Sigma}_{\text{abs}}$:**

$$\Sigma_{\text{norm},ii} = \frac{\Sigma_{\text{abs},ii}}{L^2_{\text{bg},i}}$$

**Physical interpretation:**

- **Darker scenes** (small $L_{\text{bg}}$): Higher fractional noise
- **Brighter scenes** (large $L_{\text{bg}}$): Lower fractional noise
- **Signal-to-noise ratio** inversely proportional to scene brightness in absolute units
- But **fractional SNR** is scene-independent in normalized units

**Typical values:**

- Bright scene: $\sigma_{\text{norm}} \approx 0.001$ (0.1% fractional noise)
- Moderate scene: $\sigma_{\text{norm}} \approx 0.003$ (0.3% fractional noise)
- Dark scene: $\sigma_{\text{norm}} \approx 0.01$ (1% fractional noise)

**Operational impact:**

- Detection easier over bright surfaces (deserts, snow)
- Harder over dark surfaces (ocean, dense vegetation)
- This is a **fundamental physics constraint**, not a model limitation

---

## 6. Measurement Model

### Forward Measurement Model (Linear)

$$\mathbf{y}_{\text{norm}} = g(\alpha) + \boldsymbol{\epsilon}_{\text{norm}}$$

where:

$$g(\alpha) = \mathbf{1} - \mathbf{H}\alpha$$

**Linearity is the key:**

$$g(\alpha_1 + \alpha_2) = g(\alpha_1) + g(\alpha_2) - \mathbf{1}$$

Actually, better to write:

$$g(\alpha) - \mathbf{1} = -\mathbf{H}\alpha$$

So the **deviation from background** is linear in $\alpha$:

$$\mathbf{d} = \mathbf{y}_{\text{norm}} - \mathbf{1} = -\mathbf{H}\alpha + \boldsymbol{\epsilon}_{\text{norm}}$$

### Inverse Problem: Maximum Likelihood Estimation

**Likelihood function:**

$$p(\mathbf{y}_{\text{norm}} | \alpha) = \frac{1}{(2\pi)^{n/2}|\mathbf{\Sigma}_{\text{norm}}|^{1/2}} \exp\left(-\frac{1}{2}(\mathbf{y}_{\text{norm}} - g(\alpha))^T \mathbf{\Sigma}_{\text{norm}}^{-1} (\mathbf{y}_{\text{norm}} - g(\alpha))\right)$$

**Log-likelihood:**

$$\log p(\mathbf{y}_{\text{norm}} | \alpha) = -\frac{1}{2}(\mathbf{d} + \mathbf{H}\alpha)^T \mathbf{\Sigma}_{\text{norm}}^{-1} (\mathbf{d} + \mathbf{H}\alpha) + \text{const}$$

**Maximize by taking derivative:**

$$\frac{\partial \log p}{\partial \alpha} = -\mathbf{H}^T \mathbf{\Sigma}_{\text{norm}}^{-1} (\mathbf{d} + \mathbf{H}\alpha) = 0$$

**Solve for $\alpha$:**

$$\mathbf{H}^T \mathbf{\Sigma}_{\text{norm}}^{-1} \mathbf{H} \cdot \alpha = -\mathbf{H}^T \mathbf{\Sigma}_{\text{norm}}^{-1} \mathbf{d}$$

$$\boxed{\hat{\alpha}_{\text{ML}} = -\frac{\mathbf{H}^T \mathbf{\Sigma}_{\text{norm}}^{-1} \mathbf{d}}{\mathbf{H}^T \mathbf{\Sigma}_{\text{norm}}^{-1} \mathbf{H}} = \frac{\mathbf{H}^T \mathbf{\Sigma}_{\text{norm}}^{-1} (\mathbf{1} - \mathbf{y}_{\text{norm}})}{\mathbf{H}^T \mathbf{\Sigma}_{\text{norm}}^{-1} \mathbf{H}}}$$

**Units:** ppm

**This is a closed-form, single-step solution!** No iteration, no convergence issues, no initial guess needed.

**Computational cost breakdown:**

For $n$ wavelengths:

1. **Compute innovation**: $\mathbf{d} = \mathbf{y}_{\text{norm}} - \mathbf{1}$ → $O(n)$
2. **Matrix-vector product**: $\mathbf{\Sigma}_{\text{norm}}^{-1}\mathbf{d}$ → $O(n^2)$ (or $O(n)$ if diagonal)
3. **Inner products**: $\mathbf{H}^T(\cdots)$ → $O(n)$
4. **Division**: Scalar / scalar → $O(1)$

**Total: $O(n^2)$ general, $O(n)$ for diagonal covariance**

**Typical values:**

- $n = 200$ wavelengths
- Diagonal covariance: ~200 operations
- Time: **~0.1-1 ms/pixel** on modern CPU
- For 1M pixel scene: **~2-17 minutes total**

**Compare to iterative methods:**

- Gauss-Newton: 10-20 iterations × $O(n^2)$ per iteration
- Time: **~50-100× slower**

**This speed enables real-time** operations for airborne and satellite missions.

### Statistical Properties of the Estimate

**Variance:**

$$\text{Var}(\hat{\alpha}_{\text{ML}}) = \left(\mathbf{H}^T \mathbf{\Sigma}_{\text{norm}}^{-1} \mathbf{H}\right)^{-1}$$

**Standard error:**

$$\sigma_{\hat{\alpha}} = \sqrt{\left(\mathbf{H}^T \mathbf{\Sigma}_{\text{norm}}^{-1} \mathbf{H}\right)^{-1}}$$

**This is the Cramér-Rao lower bound**: No unbiased estimator can have lower variance. The matched filter achieves **optimal statistical efficiency**.

**For white noise** ($\mathbf{\Sigma}_{\text{norm}} = \sigma^2_{\text{norm}} \mathbf{I}$):

$$\sigma_{\hat{\alpha}} = \frac{\sigma_{\text{norm}}}{\sqrt{\mathbf{H}^T\mathbf{H}}} = \frac{\sigma_{\text{norm}}}{\|\mathbf{H}\|}$$

**Physical interpretation:**

- Uncertainty decreases with **stronger absorption** (larger $\|\mathbf{H}\| \propto \sigma$)
- Uncertainty decreases with **more wavelengths** ($\|\mathbf{H}\|^2 = \sum_i H_i^2$ increases with $n$)
- Uncertainty proportional to **noise level** ($\sigma_{\text{norm}}$)

**Typical uncertainty:**

- Good conditions: $\sigma_{\hat{\alpha}} \approx 50-100$ ppm
- Moderate conditions: $\sigma_{\hat{\alpha}} \approx 100-200$ ppm
- Poor conditions (dark surface, high noise): $\sigma_{\hat{\alpha}} \approx 200-500$ ppm

**Detection threshold:**

For 3σ detection: Need $\hat{\alpha} > 3\sigma_{\hat{\alpha}}$ → Minimum detectable enhancement ~150-600 ppm depending on conditions.

---

## 7. Taylor Expanded Measurement Model (Useful for 3DVar)

### Exact Representation (No Additional Approximation)

Since the forward model is already linear, the "Taylor expansion" is **exact**:

$$g(\alpha) = g(\alpha_0) + \mathbf{H}(\alpha - \alpha_0)$$

This is not an approximation—it's the **exact representation of a linear function**.

**At background ($\alpha_0 = 0$):**

- $g(0) = \mathbf{1}$
- $\mathbf{H} = \frac{\partial g}{\partial \alpha} = -\boldsymbol{\sigma} \odot N_{\text{total}} \cdot 10^{-6} L \cdot \text{AMF}$

**Linearized model:**

$$\mathbf{y}_{\text{norm}} = \mathbf{1} + \mathbf{H}\alpha + \boldsymbol{\epsilon}_{\text{norm}}$$

**Innovation:**

$$\mathbf{d} = \mathbf{y}_{\text{norm}} - \mathbf{1} = \mathbf{H}\alpha + \boldsymbol{\epsilon}_{\text{norm}}$$

**This is already in the standard linear form** for data assimilation.

### 3DVar Formulation

**Cost function with prior constraint:**

$$J(\alpha) = \frac{1}{2B}(\alpha - \alpha_b)^2 + \frac{1}{2}(\mathbf{d} - \mathbf{H}\alpha)^T \mathbf{\Sigma}_{\text{norm}}^{-1} (\mathbf{d} - \mathbf{H}\alpha)$$

where:

- $\alpha_b$: background (prior) VMR enhancement estimate (typically 0)
- $B$: background error variance (prior uncertainty, units: ppm²)

**Physical interpretation:**

- **First term**: Penalizes deviation from prior estimate (regularization)
- **Second term**: Penalizes misfit to observations (data fitting)
- Balance controlled by ratio $B / (\mathbf{H}^T\mathbf{\Sigma}_{\text{norm}}^{-1}\mathbf{H})^{-1}$

**Analytical solution:**

Taking derivative and setting to zero:

$$\frac{\partial J}{\partial \alpha} = \frac{1}{B}(\alpha - \alpha_b) - \mathbf{H}^T\mathbf{\Sigma}_{\text{norm}}^{-1}(\mathbf{d} - \mathbf{H}\alpha) = 0$$

Rearranging:

$$\left(\frac{1}{B} + \mathbf{H}^T\mathbf{\Sigma}_{\text{norm}}^{-1}\mathbf{H}\right)\alpha = \frac{\alpha_b}{B} + \mathbf{H}^T\mathbf{\Sigma}_{\text{norm}}^{-1}\mathbf{d}$$

$$\boxed{\hat{\alpha}_{3\text{DVar}} = \frac{B\mathbf{H}^T\mathbf{\Sigma}_{\text{norm}}^{-1}\mathbf{d} + \alpha_b}{B\mathbf{H}^T\mathbf{\Sigma}_{\text{norm}}^{-1}\mathbf{H} + 1}}$$

**For no prior plume** ($\alpha_b = 0$):

$$\hat{\alpha}_{3\text{DVar}} = \frac{B\mathbf{H}^T\mathbf{\Sigma}_{\text{norm}}^{-1}\mathbf{d}}{B\mathbf{H}^T\mathbf{\Sigma}_{\text{norm}}^{-1}\mathbf{H} + 1} = \frac{\mathbf{H}^T\mathbf{\Sigma}_{\text{norm}}^{-1}\mathbf{d}}{\mathbf{H}^T\mathbf{\Sigma}_{\text{norm}}^{-1}\mathbf{H} + B^{-1}}$$

**Posterior variance:**

$$\sigma^2_{\alpha,\text{post}} = \left(\frac{1}{B} + \mathbf{H}^T\mathbf{\Sigma}_{\text{norm}}^{-1}\mathbf{H}\right)^{-1} = \left(B^{-1} + \mathbf{H}^T\mathbf{\Sigma}_{\text{norm}}^{-1}\mathbf{H}\right)^{-1}$$

**Physical interpretation:**

- Combines prior uncertainty ($B$) and observational constraint ($(\mathbf{H}^T\mathbf{\Sigma}_{\text{norm}}^{-1}\mathbf{H})^{-1}$)
- Posterior uncertainty **always less than or equal** to both prior and observation-only uncertainties
- As $B \to \infty$ (uninformative prior): $\hat{\alpha}_{3\text{DVar}} \to \hat{\alpha}_{\text{ML}}$ (matched filter)
- As $B \to 0$ (perfect prior): $\hat{\alpha}_{3\text{DVar}} \to \alpha_b$ (ignore observations)

**Operational use:**

- Include prior when plume location/strength expected (e.g., known facility)
- Use uninformative prior ($B \to \infty$) for blind detection → reduces to matched filter

---

## 8. Pedagogical Connection to Matched Filter

### From Linear Model to Matched Filter

The **matched filter** is simply the maximum likelihood estimator for the linear-Gaussian model with no prior constraint:

$$\boxed{\text{Combined Linear Model} \xrightarrow{B \to \infty} \text{Matched Filter}}$$

**No approximation involved in this step**—it's a direct consequence of the model structure.

### The Matched Filter Formula

**Define target spectrum:**

$$\mathbf{t} = -\mathbf{H} = \boldsymbol{\sigma} \odot N_{\text{total}} \cdot 10^{-6} L \cdot \text{AMF}$$

**Note the sign:** We define $\mathbf{t}$ as the negative of $\mathbf{H}$ so that $\mathbf{t} > 0$ (absorption causes positive values in standard convention).

**Matched filter estimate:**

$$\hat{\alpha}_{\text{MF}} = \frac{\mathbf{t}^T\mathbf{\Sigma}_{\text{norm}}^{-1}\mathbf{d}}{\mathbf{t}^T\mathbf{\Sigma}_{\text{norm}}^{-1}\mathbf{t}}$$

where $\mathbf{d} = \mathbf{1} - \mathbf{y}_{\text{norm}}$ (note sign: we want positive $\mathbf{d}$ for absorption).

**For white noise:**

$$\hat{\alpha}_{\text{MF}} = \frac{\mathbf{t}^T\mathbf{d}}{\mathbf{t}^T\mathbf{t}} = \frac{\mathbf{t}^T(\mathbf{1} - \mathbf{y}_{\text{norm}})}{\|\mathbf{t}\|^2}$$

**Physical interpretation:**

- **Numerator**: Projection of observation onto target (correlation)
- **Denominator**: Power of target (normalization)
- **Result**: "How much of the target is present in the observation?"

### Detection Statistic

**Define detection statistic:**

$$\delta = \mathbf{t}^T\mathbf{\Sigma}_{\text{norm}}^{-1}\mathbf{d}$$

**Relationship to estimate:**

$$\hat{\alpha}_{\text{MF}} = \frac{\delta}{\mathbf{t}^T\mathbf{\Sigma}_{\text{norm}}^{-1}\mathbf{t}}$$

**Under null hypothesis** ($\alpha = 0$, no plume):

$$\delta \sim \mathcal{N}(0, \mathbf{t}^T\mathbf{\Sigma}_{\text{norm}}\mathbf{t})$$

**Standard deviation:**

$$\sigma_{\delta} = \sqrt{\mathbf{t}^T\mathbf{\Sigma}_{\text{norm}}\mathbf{t}}$$

**For white noise:**

$$\sigma_{\delta} = \sigma_{\text{norm}} \|\mathbf{t}\|$$

**Detection threshold:**

Declare plume if $\delta > \lambda \sigma_{\delta}$ where:

- $\lambda = 3$: 3σ (99.7% confidence, 0.3% false alarm rate)
- $\lambda = 4$: 4σ (99.99% confidence)
- $\lambda = 5$: 5σ (99.9999% confidence)

**Operational choice:** Typically $\lambda = 3-4$ balancing false alarms vs. missed detections.

### Why It's Called "Matched" Filter

The filter is **matched** to the expected signal in two senses:

1. **Spectral matching**: The target $\mathbf{t}$ has the same spectral shape as the expected plume signature (methane absorption spectrum)

2. **Statistical matching**: The weighting by $\mathbf{\Sigma}_{\text{norm}}^{-1}$ **whitens** the noise, making the filter optimal in the signal-to-noise ratio sense

**Matched filter theorem:** For detecting a known signal in Gaussian noise, the matched filter maximizes SNR and minimizes probability of error.

### Computational Implementation

**Pseudocode for operational system:**

```Python
## Preprocessing (once per scene)
L_bg = median(background_pixels, axis=0)  # #Estimate background
y_norm = y_absolute / L_bg                # Normalize radiance
## Matched filter (per pixel)
d = 1 - y_norm                            # Innovation
numerator = t.T @ Sigma_inv @ d           # Correlation
denominator = t.T @ Sigma_inv @ t         # Normalization
alpha_hat = numerator / denominator        # VMR estimate
## Detection
sigma_delta = sqrt(t.T @ Sigma_norm @ t)  # Detection threshold
delta = numerator                          # Detection statistic
detected = (delta > 3 * sigma_delta)      # 3-sigma detection

```


**Optimizations:**

- Precompute $\mathbf{\Sigma}_{\text{norm}}^{-1}\mathbf{t}$ (shared across pixels)
- Precompute denominator (constant for scene)
- Use diagonal $\mathbf{\Sigma}_{\text{norm}}$ → $O(n)$ instead of $O(n^2)$
- Vectorize over pixels (process batch simultaneously)

**With these optimizations:** ~0.1 ms/pixel on GPU, enabling real-time processing.

---

## Summary: Model 4B in Context

### The Optimal Operational Choice

Model 4B achieves the **best trade-off** for operational methane detection:

| Criterion | Model 4B Performance |
|-----------|---------------------|
| **Accuracy** | Good (5-10% error for moderate plumes) |
| **Speed** | Excellent (100× faster than exact) |
| **Calibration** | None required (self-calibrating) |
| **Robustness** | High (immune to multiplicative errors) |
| **Implementation** | Simple (closed-form solution) |
| **Validity range** | Moderate plumes ($\Delta\tau < 0.1$, ~1000 ppm) |

### When to Use Model 4B

✓ **Recommended for:**

- Operational detection systems
- Real-time processing requirements
- Large-area surveys (satellites, aircraft)
- Moderate plumes (100-1000 ppm typical)
- Scenes with calibration uncertainty
- Initial screening before detailed retrieval

✗ **Not recommended for:**

- Strong plumes (>2000 ppm) → use Model 3B or 1B
- Very weak signals (<50 ppm) → below detection threshold anyway
- Flux quantification requiring <5% accuracy → use Model 1 or 1B
- Elevated/stratified plumes → spatial assumptions break down

### Hierarchy Position

Most Accurate ←──────────────────→ Fastest
Model 1B          Model 3B      Model 4B       Model 2B
(Exact)         (Taylor only)  (Combined)    (MacLaurin only)
●──────────────●──────────────●──────────────●
│              │              │              │
0% error      2-5% error    5-10% error   15-20% error
50 ms/px      10 ms/px       0.5 ms/px      0.5 ms/px
Iterative     Iterative     Closed-form    Closed-form
All τ         τ < 0.3        τ < 0.1        τ < 0.05


**Model 4B occupies the "sweet spot"** where accuracy is good enough and speed is fast enough for practical operations.

### Future Directions

**Extensions of Model 4B:**

- **Adaptive matched filter**: Estimate $\mathbf{\Sigma}_{\text{norm}}$ locally from data
- **Multi-gas detection**: Simultaneous CH₄, CO₂, H₂O retrieval
- **Spatial regularization**: Enforce plume smoothness across pixels
- **Machine learning augmentation**: Train detector on Model 4B + corrections
- **Hybrid approach**: Use Model 4B for detection, Model 1B for quantification

The combined linearized model will remain the **foundation** of operational methane detection for the foreseeable future.

---

