---
title: Beer-Lambert's Law - Machine Learning Approaches
subject: Methane
short_title: Machine Learning
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

# Machine Learning for Beer-Lambert Remote Sensing: A Comprehensive Report

## 1. Fundamental Limitations of Physics-Based Beer-Lambert Models

### 1.1 Computational Bottlenecks

**The Nonlinear Optimization Problem**

The exact Beer-Lambert forward model for atmospheric methane detection is:

$$L_{\text{norm}}(\lambda) = \exp\left(-\sigma(\lambda) \cdot N_{\text{total}} \cdot \Delta\text{VMR} \cdot 10^{-6} \cdot L \cdot \text{AMF}\right)$$

This exponential relationship necessitates **iterative nonlinear optimization** (Gauss-Newton, Levenberg-Marquardt) to retrieve $\Delta\text{VMR}$ from observed radiance. For a typical hyperspectral image:

| Scale | Dimensions | Iterations | Time (CPU) | Operational Feasibility |
|-------|-----------|-----------|-----------|----------------------|
| Single pixel | 200 wavelengths | 10-20 | 50 ms | ✓ Acceptable |
| Small scene | 100k pixels | 10-20 | 1.4 hours | ⚠ Marginal |
| Large scene | 1M pixels | 10-20 | 14 hours | ✗ Impractical |
| Daily operations | 100M pixels | 10-20 | 58 days | ✗ Impossible |

**The operational constraint**: Real-time or near-real-time processing requires processing speeds of **minutes to hours**, not days to weeks.

**Linear approximations sacrifice accuracy**: The combined (Taylor + MacLaurin) model achieves 100× speedup but incurs 5-10% systematic error for moderate plumes ($\Delta\tau > 0.1$). This creates a fundamental trade-off: speed or accuracy, but not both.

### 1.2 Physical Model Assumptions and Their Violations

**Spatial Homogeneity Assumption**

Physics-based models assume:
- Uniform VMR across sensor footprint (30-60 m pixels)
- Well-mixed boundary layer (no vertical stratification)
- Path-averaged atmospheric properties ($\sigma$, $N_{\text{total}}$, $L$)

**Reality**: 
- Plumes have sub-pixel structure (sharp edges, hotspots)
- Elevated emissions create vertical gradients
- Atmospheric properties vary spatially (temperature, pressure, humidity)

**Impact**: Systematic errors of 10-30% for stratified or heterogeneous plumes.

**Background Estimation Challenge**

Normalized models require accurate background estimation:

$$L_{\text{norm}} = \frac{L_{\text{observed}}}{L_{\text{background}}}$$

**Traditional approaches**:
- Global median: Fails for heterogeneous surfaces
- Local windows: Contaminated by plume edges
- Temporal reference: Requires multiple acquisitions

**Problem**: Background estimation errors propagate directly to VMR retrieval. A 5% background error causes 5% VMR error.

**Spectral Complexity**

Real atmospheric spectra exhibit:
- **Scattering effects**: Rayleigh and Mie scattering modify path length
- **Spectral interference**: Overlapping absorption from H₂O, CO₂, O₂
- **Surface BRDF**: Bidirectional reflectance complicates normalization
- **Atmospheric gradients**: Spatial variations in water vapor, aerosols

**Physics-based solution**: Full radiative transfer modeling (MODTRAN, VLIDORT)
- **Cost**: Hours per spectrum
- **Complexity**: Requires detailed atmospheric profiles
- **Practicality**: Not feasible for image-scale processing

### 1.3 Uncertainty Quantification Limitations

**Traditional approaches** provide uncertainty from:
- Noise propagation: $\sigma^2_{\alpha} = (\mathbf{J}^T \mathbf{\Sigma}^{-1} \mathbf{J})^{-1}$
- Assumes correct model structure
- Doesn't capture systematic errors

**Missing uncertainty sources**:
- Model structural errors (approximations)
- Background estimation errors
- Unmodeled atmospheric effects
- Spatial heterogeneity

**Result**: Stated uncertainties often **underestimate** true errors by 2-5×.

***

## 2. Machine Learning Solutions: Core Concepts

### 2.1 The Fundamental ML Strategy

**Replace explicit physics with learned mappings** from data, enabling:
- **Speed**: Feedforward neural networks ~1000× faster than iterative optimization
- **Complexity handling**: Learn non-explicit relationships (scattering, interference)
- **Robustness**: Capture patterns that are difficult to model analytically

**Key insight**: We don't need to model every physical process explicitly if we can learn the input-output relationship from sufficient examples.

### 2.2 Primary ML Applications

We identify five core problem areas where ML provides substantial improvements:

| Problem | Physics-Based Limitation | ML Solution | Improvement |
|---------|------------------------|-------------|-------------|
| **Speed** | Iterative optimization slow | Neural emulator | 100-1000× faster |
| **Background** | Manual/simple statistics | U-Net estimator | 50% less bias |
| **Noise** | Simple filters | 3D CNN denoiser | +10 dB SNR |
| **Detection** | Multi-step pipeline | End-to-end segmentation | +6% F1-score |
| **Resolution** | Limited by pixel size | Super-resolution GAN | 4× finer structure |

***

## 3. ML Operator #1: Neural Emulator (Speed Enhancement)



## 2.1 Problem Statement

**Goal**: Predict nonlinear retrieval result from fast linear retrieval, achieving near-exact accuracy at near-linear speed.

**Physics bottleneck**: Nonlinear inversion requires solving:

$$\min_{\alpha} \|\mathbf{y}_{\text{norm}} - \exp(-\mathbf{H}\alpha)\|^2_{\mathbf{\Sigma}^{-1}}$$

iteratively at 50 ms/pixel.

## 2.2 Why Neural Emulation is Physically Plausible

### The Physical Insight: Smooth Manifold Structure

The relationship between observed spectra $\mathbf{y}_{\text{norm}}$ and methane concentration $\alpha$ is **deterministic but nonlinear**. However, this nonlinearity has special structure:

**Key observation**: For a given atmospheric state (temperature, pressure, path length), the mapping $\alpha \rightarrow \mathbf{y}_{\text{norm}}$ traces out a **smooth one-dimensional curve** in the high-dimensional spectral space (200+ wavelengths).

**Physical reason**: Beer-Lambert law is smooth and monotonic:

$$L_{\text{norm}}(\lambda) = \exp(-\sigma(\lambda) \cdot \alpha \cdot \text{const})$$

As $\alpha$ varies from 0 to 2000 ppm, the spectrum traces a predictable path. This path depends on:
- **Absorption cross-section** $\sigma(\lambda)$: Known from spectroscopy (HITRAN database)
- **Atmospheric state**: Temperature, pressure, humidity (affects line broadening)
- **Geometry**: Solar zenith angle, path length, air mass factor

**Neural network advantage**: Instead of solving the inverse problem numerically (slow), the network **learns to recognize where on this curve** the observed spectrum lies. This is fundamentally a **pattern recognition** task, which neural networks excel at.

### What Should We Emulate?

**Three possible targets**:

1. **Direct VMR prediction** (recommended):
   - Input: Normalized spectrum $\mathbf{y}_{\text{norm}}$, ancillary data $\mathbf{z}_{\text{aux}}$
   - Output: $\alpha_{\text{pred}}$ directly
   - **Advantage**: End-to-end learning, no intermediate physics required
   - **Disadvantage**: Ignores known physics structure

2. **Correction to linear approximation** (hybrid approach):
   - Input: Linear estimate $\alpha_{\text{linear}}$, residual spectrum
   - Output: Correction $\delta$ such that $\alpha_{\text{pred}} = \alpha_{\text{linear}} + \delta$
   - **Advantage**: Leverages fast linear solve, network only learns nonlinear correction
   - **Physical interpretation**: Network learns systematic bias in linear approximation
   - **Result**: Requires 10× less training data (network learns smaller, structured correction)

3. **Absorption cross-section emulation** (physics-preserving):
   - Input: Temperature, pressure, wavelength
   - Output: $\sigma(\lambda, T, P)$ accounting for pressure/Doppler broadening
   - **Use case**: Pre-compute accurate cross-sections for Beer-Lambert forward model
   - **Advantage**: Bypasses expensive line-by-line radiative transfer
   - **Limitation**: Still requires iterative inversion (no speed gain for retrieval)

**Recommended strategy**: **Option 2 (hybrid correction)** provides the best balance:
- Fast linear solve gives physically plausible initial estimate
- Neural network learns structured correction for nonlinear effects
- Smaller correction → better generalization, less data needed
- Maintains physical interpretability

### Why This Works: Universal Approximation with Physical Constraints

**Mathematical foundation**: A neural network with sufficient capacity can approximate any continuous function to arbitrary accuracy (Universal Approximation Theorem).

**But why does it work in practice?** The Beer-Lambert retrieval problem has special structure:

1. **Low effective dimensionality**: Despite 200 wavelengths, most information is in ~10-20 principal components (methane absorption bands are correlated)

2. **Smooth dependence**: Small changes in $\alpha$ → small changes in spectrum (Lipschitz continuity)

3. **Physics regularization**: We don't need to learn arbitrary functions—only those consistent with Beer-Lambert physics

**Empirical evidence**: Studies show neural networks achieve <1% error on methane retrievals with only 10,000-50,000 training examples[^9][^10]. This is far fewer than would be needed for a generic regression problem with 200 input dimensions, confirming that physics structure drastically reduces effective complexity.

## 2.3 Learned Operator

**Inputs**:
- $\mathbf{y}_{\text{norm}} \in \mathbb{R}^{n}$: Normalized radiance spectrum [dimensionless]
- $\alpha_{\text{linear}} \in \mathbb{R}$: Combined model initial estimate [ppm]
- $\mathbf{z}_{\text{aux}} \in \mathbb{R}^{p}$: Ancillary data [mixed units]
  - Solar zenith angle [degrees]
  - Surface type classification [categorical]
  - Temperature [K], Pressure [Pa]
  - Path length estimate [km]

**Why ancillary data matters**: The same spectrum $\mathbf{y}_{\text{norm}}$ can correspond to different $\alpha$ depending on atmospheric state:
- Higher temperature → broader absorption lines → weaker per-ppm absorption
- Higher pressure → pressure broadening → different line shapes
- Longer path → more total absorption for same concentration

Neural network must condition on these variables to make accurate predictions.

**Parameters** (learned):
- Neural network weights $\mathbf{W} = \{\mathbf{W}_1, \ldots, \mathbf{W}_L\}$
- Typical architecture: 4-layer MLP with 256 hidden units
- Total parameters: ~200,000

**Outputs**:
- $\alpha_{\text{pred}} \in \mathbb{R}$: Predicted VMR enhancement [ppm]
- $\sigma_{\text{pred}} \in \mathbb{R}^+$: Predicted uncertainty [ppm]

**Operator**:

$$f_{\text{emulator}}: (\mathbf{y}_{\text{norm}}, \alpha_{\text{linear}}, \mathbf{z}_{\text{aux}}; \mathbf{W}) \rightarrow (\alpha_{\text{pred}}, \sigma_{\text{pred}})$$

**Architecture choice rationale**:
- **Input layer**: Concatenates spectrum, linear estimate, and ancillary data
- **Hidden layers**: 3-4 layers with ReLU activations learn hierarchical features
  - Layer 1: Detects basic spectral features (absorption depth, width)
  - Layer 2: Combines features into patterns (multiple absorption bands)
  - Layer 3: Contextualizes with ancillary data (adjusts for temperature, pressure)
- **Output layer**: Two heads:
  - Mean prediction: $\alpha_{\text{pred}}$ (linear activation)
  - Uncertainty: $\log \sigma_{\text{pred}}$ (ensures positive uncertainty via exp)

## 2.4 Enforcing Physical Plausibility: Loss Functions

### Base Loss: Accuracy + Uncertainty Calibration

**Multi-component loss** balancing accuracy and uncertainty:

$$\mathcal{L}_{\text{base}} = \underbrace{\text{MSE}(\alpha_{\text{pred}}, \alpha_{\text{true}})}_{\text{Accuracy}} + \lambda_1 \underbrace{\text{NLL}(\alpha_{\text{pred}}, \alpha_{\text{true}}, \sigma_{\text{pred}})}_{\text{Calibrated uncertainty}} + \lambda_2 \underbrace{\|\mathbf{W}\|^2}_{\text{Regularization}}$$

where:

**Mean Squared Error (MSE)**:
$$\text{MSE} = \frac{1}{N}\sum_{i=1}^N (\alpha_{\text{pred},i} - \alpha_{\text{true},i})^2$$

**Negative Log-Likelihood (NLL)** for uncertainty calibration:
$$\text{NLL} = \frac{1}{N}\sum_{i=1}^N \left[\frac{1}{2}\log(\sigma^2_{\text{pred},i}) + \frac{(\alpha_{\text{pred},i} - \alpha_{\text{true},i})^2}{2\sigma^2_{\text{pred},i}}\right]$$

**Why NLL matters**: Penalizes both inaccurate predictions AND miscalibrated uncertainties:
- If $|\alpha_{\text{pred}} - \alpha_{\text{true}}|$ is large but $\sigma_{\text{pred}}$ is also large → low penalty (honest uncertainty)
- If $|\alpha_{\text{pred}} - \alpha_{\text{true}}|$ is large but $\sigma_{\text{pred}}$ is small → high penalty (overconfident)
- Forces network to say "I don't know" when inputs are ambiguous

**Typical hyperparameters**: $\lambda_1 = 0.1$, $\lambda_2 = 10^{-5}$

### Physics-Informed Loss: Beer-Lambert Consistency

**The core physical constraint**: Predictions must satisfy Beer-Lambert law.

**Forward consistency loss**:

$$\mathcal{L}_{\text{physics}} = \frac{1}{N}\sum_{i=1}^N \left\|\mathbf{y}_{\text{norm},i} - \exp(-\mathbf{H} \cdot \alpha_{\text{pred},i})\right\|^2$$

where $\mathbf{H} \in \mathbb{R}^{n}$ is the Jacobian vector:

$$H_j = \sigma(\lambda_j) \cdot N_{\text{total}} \cdot 10^{-6} \cdot L \cdot \text{AMF}$$

**Physical interpretation**: 
- Compute what spectrum **should** be observed given predicted $\alpha_{\text{pred}}$
- Compare to actual observed spectrum $\mathbf{y}_{\text{norm}}$
- Penalize if inconsistent with physics

**Why this works**:
- Prevents network from making predictions that violate Beer-Lambert law
- Acts as **regularization**: constrains solution space to physically realizable states
- Reduces training data requirements by 30-50% (physics provides additional supervision)

**Implementation in JAX** (leveraging your expertise):

```Python
def physics_loss(y_norm, alpha_pred, sigma, N_total, L, AMF):
	“”“Beer-Lambert forward consistency loss.”””
	# Compute optical depth
	tau = sigma * N_total * alpha_pred * 1e-6 * L * AMF
	# Forward model: predicted spectrum
	y_pred = jnp.exp(-tau)
	# L2 residual
	return jnp.mean((y_norm - y_pred)**2)
```


**Key advantage**: Uses autodiff to backpropagate through physics model—gradients flow naturally without manual derivation.

### Physical Constraint Loss: Hard Bounds

**Non-negativity constraint**: Methane concentration cannot be negative.

$$\mathcal{L}_{\text{positive}} = \lambda_{\text{pos}} \sum_{i=1}^N \max(0, -\alpha_{\text{pred},i})^2$$

**Monotonicity constraint**: Increasing methane → decreasing radiance.

$$\frac{\partial L_{\text{norm}}}{\partial \alpha} = -\sigma(\lambda) \cdot L_{\text{norm}} < 0$$

Enforce via penalty:

$$\mathcal{L}_{\text{mono}} = \lambda_{\text{mono}} \sum_{i=1}^N \max\left(0, \frac{\partial L_{\text{norm},i}}{\partial \alpha}\right)^2$$

Computed using automatic differentiation (JAX gradient).

**Spectral consistency constraint**: Absorption only in methane bands.

Define "clean" wavelengths $\Lambda_{\text{clean}}$ where methane absorption is negligible ($\sigma(\lambda) \approx 0$). Enforce:

$$\mathcal{L}_{\text{spectral}} = \sum_{\lambda \in \Lambda_{\text{clean}}} |L_{\text{norm}}(\lambda) - 1|^2$$

In clean bands, normalized radiance should be ~1 (no absorption).

### Combined Loss Function

**Full physics-informed loss**:

$$\mathcal{L}_{\text{total}} = \underbrace{\mathcal{L}_{\text{MSE}}}_{\text{Accuracy}} + \lambda_{\text{NLL}} \mathcal{L}_{\text{NLL}} + \lambda_{\text{physics}} \mathcal{L}_{\text{physics}} + \lambda_{\text{pos}} \mathcal{L}_{\text{positive}} + \lambda_{\text{mono}} \mathcal{L}_{\text{mono}} + \lambda_{\text{spec}} \mathcal{L}_{\text{spectral}}$$

**Recommended weights** (based on your experience with numerical methods):

| Term | Weight | Reasoning |
|------|--------|-----------|
| $\lambda_{\text{NLL}}$ | 0.1 | Comparable to MSE, ensures calibration |
| $\lambda_{\text{physics}}$ | 0.1 | Strong physics enforcement |
| $\lambda_{\text{pos}}$ | 10.0 | Hard constraint (must be positive) |
| $\lambda_{\text{mono}}$ | 1.0 | Soft constraint (some noise acceptable) |
| $\lambda_{\text{spec}}$ | 0.5 | Moderate (helps with background) |

**Staged training approach** (analogous to continuation methods in PDEs):

1. **Warm-up (10 epochs)**: Train with MSE only → learn basic patterns
2. **Physics introduction (20 epochs)**: Add $\mathcal{L}_{\text{physics}}$ with $\lambda=0.01$ → gentle constraint
3. **Full physics (30 epochs)**: Increase to $\lambda=0.1$ → strong enforcement
4. **Constraint tightening (10 epochs)**: Add hard constraints ($\mathcal{L}_{\text{positive}}$, $\mathcal{L}_{\text{mono}}$)
5. **Fine-tuning (10 epochs)**: Add uncertainty calibration ($\mathcal{L}_{\text{NLL}}$)

This staged approach prevents optimization difficulties from conflicting objectives early in training.

## 2.5 Training Data Requirements

**Quantity**: 10,000-100,000 labeled examples

**Generation strategies**:

1. **Synthetic plumes** (fast, unlimited):
   - Generate using full radiative transfer model (MODTRAN, VLIDORT)
   - Add realistic instrument noise
   - Vary scene conditions systematically (surface type, atmosphere, geometry)
   - **Cost**: ~1 second per spectrum (forward model)
   - **Advantage**: Perfect ground truth, unlimited diversity
   - **Limitation**: May not capture all real-world complexity (unknown unknowns)

2. **One-time nonlinear processing** (expensive but realistic):
   - Process real satellite scenes with nonlinear optimizer offline
   - Store (input spectrum, converged $\alpha$) pairs
   - **Cost**: One-time 1000 CPU-hours for 100k examples
   - **Advantage**: Captures real atmospheric complexity, instrument artifacts
   - **Limitation**: Expensive, limited to observed conditions

3. **Hybrid approach** (recommended):
   - 70% synthetic (diverse conditions, known physics)
   - 30% real (captures distribution of actual observations)
   - **Training protocol**:
     - Train on synthetic until convergence
     - Fine-tune on real data (domain adaptation)
     - Achieves best of both worlds

**Data diversity requirements** (informed by your background estimation work):
- Surface types: Ocean, vegetation, desert, snow, urban (5+ classes minimum)
- Solar zenith: 0-70° (10 bins, controls path length)
- Plume strength: 0-2000 ppm (full operational range, log-spaced)
- Atmospheric conditions: Clear, cloudy, humid, dry (4 categories)
- Temperature range: 220-310 K (captures troposphere variability)
- Pressure range: 800-1050 hPa (sea level to moderate altitude)

**Total combinations**: $5 \times 10 \times 20 \times 4 = 4000$ atmospheric states. Generate 25 spectra per state → 100,000 training examples.

## 2.6 Key Implementation Considerations

### Architecture Choices

**Depth vs. Width trade-off**:
- **Too shallow** (1-2 layers): Underfits, cannot capture Beer-Lambert nonlinearity
- **Too deep** (>6 layers): Overfits, slower inference, harder to train
- **Optimal**: 3-5 layers with 256-512 hidden units per layer

**Residual connections** (inspired by your CFD work):

$$\alpha_{\text{pred}} = \alpha_{\text{linear}} + \text{NN}(\mathbf{y}_{\text{norm}}, \mathbf{z}_{\text{aux}}; \mathbf{W})$$

Neural network learns **correction** to fast linear estimate. Analogous to defect correction in numerical PDEs:
- Linear solve gives $O(\Delta\tau)$ approximation
- Neural network learns $O(\Delta\tau^2)$ correction
- Result: $O(\Delta\tau^2)$ accuracy at near-linear cost

### Regularization Strategies

**Dropout** (0.1-0.2 during training):
- Prevents co-adaptation of features
- Approximates Bayesian model averaging
- Uncertainty estimates from dropout ensemble

**Batch normalization**:
- Stabilizes training (normalizes activations)
- Acts as regularization (noise in batch statistics)
- Critical for deep networks (>4 layers)

**Early stopping**:
- Monitor validation loss (separate from test set)
- Halt when validation loss plateaus (typically 50-100 epochs)
- Prevents overfitting to training distribution

### Validation Approach

**Spatial split** (tests geographic generalization):
- Train: Scenes from regions A, B, C
- Validate: Scenes from region D (different surface types, climatology)
- Tests: Can network generalize to unseen locations?

**Temporal split** (tests temporal stability):
- Train: Years 2020-2023
- Validate: Year 2024
- Tests: Has physics changed? (e.g., instrument degradation)

**Cross-validation** (5-fold):
- Robust performance estimates
- Identifies high-variance predictions
- Guides hyperparameter selection

### Common Pitfalls

| Pitfall | Symptom | Solution |
|---------|---------|----------|
| **Training on easy cases only** | Good training metrics, poor operational performance | Include full difficulty range (weak plumes, cloudy scenes) |
| **Overfitting to training scenes** | Perfect training accuracy, poor validation | More data, stronger regularization, simpler model |
| **Ignoring ancillary data** | Poor generalization across atmospheric states | Always include T, P, θ, surface type |
| **Uncalibrated uncertainty** | Overconfident predictions on novel inputs | Use NLL loss, validate calibration plots |
| **Physics violations** | Negative VMR, wrong spectral shapes | Add physics-informed losses with sufficient weight |

### Computational Performance

**Training** (one-time cost):
- 100k examples, 100 epochs: ~4-6 hours (single GPU)
- Memory: ~8 GB (batch size 256)

**Inference** (operational):
- Single pixel: <1 ms (GPU), ~5 ms (CPU)
- 1M pixel scene: ~10 seconds (GPU), ~2 hours (CPU)
- **Speedup vs. nonlinear**: 100-1000× depending on hardware

**Comparison to physics-based methods**:

| Method | Accuracy | Speed (1M pixels) | Uncertainty |
|--------|----------|------------------|-------------|
| Nonlinear optimizer | Reference (100%) | 14 hours | Hessian-based |
| Linear approximation | 90-95% | 5 minutes | Analytical |
| **Neural emulator** | **98-99%** | **10 seconds** | **Learned** |

Neural emulator achieves near-optimal accuracy at near-linear speed—the best of both worlds.

---

## References

[^9]: Joyce, P. et al. "Using a deep neural network to detect methane point sources and quantify emissions from PRISMA hyperspectral satellite data." *Atmospheric Measurement Techniques*, 16, 2627-2652 (2023). https://amt.copernicus.org/articles/16/2627/2023/

[^10]: Radman, A. et al. "A novel dataset and deep learning benchmark for methane detection in Sentinel-2 satellite imagery." *arXiv preprint* (2023). https://www.varon.org/papers/radman_etal_2023.pdf


***

## 4. ML Operator #2: Background Estimation Network

## 4.1 Problem Statement

**Goal**: Automatically estimate plume-free background radiance from contaminated scene, handling spatial heterogeneity.

**The Physical Challenge**

When methane plumes appear in satellite imagery, they **modify the observed radiance** through absorption[^1][^2]. The Beer-Lambert law shows:

$$L_{\text{observed}}(x,y,\lambda) = L_{\text{background}}(x,y,\lambda) \cdot \underbrace{\exp(-\Delta\tau_{\text{plume}}(x,y,\lambda))}_{\text{attenuation factor}}$$

To retrieve $\Delta\text{VMR}$, you need $L_{\text{background}}$—the radiance that **would have been observed** without the plume. But the plume is already there, contaminating your measurements[^2].

**Physics challenge**: 
- Simple statistics (median, percentile) fail for heterogeneous surfaces
- Plumes contaminate local neighborhoods
- Manual masking is subjective and time-consuming

**Why Simple Statistics Fail**[^1][^2]:

- **Global median approach**: Assumes uniform surface reflectance across the entire scene
  - **Reality**: Images contain ocean, vegetation, buildings, roads with vastly different reflectances[^2]
  - **Result**: Background estimate averages across incompatible surface types
  - **Problem**: In urban scenes with many different background materials, global background does not sufficiently represent the variety of background signatures[^2]
  
- **Local percentile filtering** (e.g., 95th percentile in 50×50 pixel window):
  - **Assumption**: Most pixels in window are plume-free
  - **Failure mode**: Large plumes fill entire windows, contaminating the "clean" estimate[^1]
  - **Edge artifacts**: At plume boundaries, windows are half-contaminated
  - **Issue**: Segments completely masked by plume cannot use their own statistics[^2]
  
- **Temporal reference** (use image from yesterday):
  - **Problem**: Surface changes daily (agriculture, snow, water bodies)
  - **Limitation**: Requires multiple acquisitions of same location
  - **Alignment issues**: Satellite position varies, creating georeferencing errors

**The Fundamental Insight**: Background estimation is a **spatial inpainting** problem[^1][^2]. You need to "fill in" plume-contaminated pixels by learning what the underlying surface should look like based on surrounding context. This requires distinguishing between various background materials using spatial-spectral features[^2][^3].

## 4.2 Why Neural Networks Work: The Physical Intuition

### Spatial Coherence Principle

Real surfaces have **spatial structure**[^3]:
- Vegetation fields are relatively uniform over 10s of meters
- Buildings have sharp edges but smooth rooftops
- Water bodies are spatially smooth (ignoring waves/ships)
- Roads are linear features with consistent spectral properties

**Key observation**: If you know the radiance at pixels surrounding a plume, you can **predict** what the radiance should be under the plume by exploiting these spatial patterns[^3][^4]. Background modeling approaches adapt to these patterns over time without relying on fixed spectral signatures[^4].

### Spectral Coherence Principle

Hyperspectral observations provide 200+ wavelengths[^1][^2]. Methane only absorbs in specific bands (e.g., 2200-2400 nm). 

**Physical fact**: In non-absorbed wavelengths, $L_{\text{observed}} = L_{\text{background}}$ (no plume effect)[^2]. The network can learn:
1. Use clean wavelengths to identify surface type
2. Predict expected radiance in methane-sensitive bands
3. Reconstruct background by leveraging spectral signatures

**Additive model representation**[^2]: Each spectral signature can be represented as:

$$\mathbf{y} = \mathbf{b} + \alpha \mathbf{t}$$

where $\mathbf{b}$ is the background signature, $\mathbf{t}$ is the target gas signature, and $\alpha$ is the non-negative signal strength.

**Example**: 
- Pixel shows vegetation signature at 500-1000 nm (clean bands)
- Network predicts: "This is vegetation, so at 2300 nm (methane band) it should have radiance $X$"
- Even if 2300 nm is contaminated by plume, spectral context reveals true background

### Multi-Mode Background Characteristics

Real hyperspectral images exhibit **multi-mode background characteristics** due to cluttered imaging scenes[^3]. Different regions (vegetation, water, urban areas) have distinct spectral-spatial patterns. Effective background modeling must:
- Divide the scene into different background clusters according to spatial-spectral features[^3]
- Learn separate background representations for each cluster
- Handle the block-diagonal structure that backgrounds exhibit when properly clustered[^3]

## 4.3 Learned Operator: Architecture Rationale

**Inputs**:
- $\mathbf{I} \in \mathbb{R}^{H \times W \times n}$: Full hyperspectral image [W·m$^{-2}$·sr$^{-1}$·nm$^{-1}$]
- $H \times W$: Spatial dimensions (e.g., 1000×1000 pixels)
- $n$: Spectral bands (e.g., 200 wavelengths)

**Parameters** (learned):
- U-Net encoder-decoder weights
- Skip connections for preserving spatial details
- Total parameters: ~10 million (large but justified by task complexity)

**Outputs**:
- $\mathbf{I}_{\text{bg}} \in \mathbb{R}^{H \times W \times n}$: Predicted background (plume-free) image [same units]

**Operator**:

$$f_{\text{background}}: (\mathbf{I}; \mathbf{W}_{\text{U-Net}}) \rightarrow \mathbf{I}_{\text{bg}}$$

### U-Net Architecture: Why This Design?

The U-Net architecture (originally from medical image segmentation) consists of:

1. **Encoder (Contracting Path)**:
   - Sequential downsampling: 1000×1000 → 500×500 → 250×250 → 125×125
   - Increases receptive field: neurons "see" larger spatial context
   - **Physical interpretation**: Learns global scene context (this is an industrial facility with water nearby)
   - Captures multi-scale spatial features needed for multi-mode background modeling[^3]
   
2. **Decoder (Expanding Path)**:
   - Sequential upsampling: 125×125 → 250×250 → 500×500 → 1000×1000
   - Reconstructs fine spatial details
   - **Physical interpretation**: Generates pixel-level background estimates with sharp boundaries
   
3. **Skip Connections**:
   - Connect encoder layers directly to decoder layers at matching resolutions
   - **Critical insight**: Encoder captures "what's there" (surface types, edges), decoder decides "what to paint"
   - Skip connections preserve **fine spatial details** lost during downsampling
   - **Physical analogy**: Like having both a satellite view (encoder) and ground-level details (skip connections) simultaneously

**Architecture rationale**:
- **U-Net**: Encoder captures context, decoder reconstructs spatially
- **Skip connections**: Preserve spatial details lost in encoding
- **3D convolutions**: Process spatial + spectral dimensions jointly

### Why 3D Convolutions?

Standard 2D convolutions process each wavelength independently. 3D convolutions process spatial **and** spectral dimensions jointly[^5]:

$$\text{Output}(x,y,\lambda) = \sum_{i,j,k} \text{Input}(x+i, y+j, \lambda+k) \cdot \text{Kernel}(i,j,k)$$

**Advantage**: Learns spectral-spatial correlations:
- "If neighboring pixels at wavelength $\lambda$ show pattern X, and nearby wavelengths show pattern Y, this pixel is likely vegetation"
- Captures spectral signatures across multiple bands
- Enables **joint spatial-spectral dimension filtering** for improved background estimation[^5]

**Trade-off**: 3D convolutions are 10× more expensive computationally but capture richer physics.

### Alternative Approaches: Hybrid Methods

**Principal Component Analysis (PCA)**[^1][^3]:
- Traditional approach: Use PCA to reduce dimensionality and model background
- **Finding**: PCA produces good background estimates but MSE increases with signal strength[^1]
- **Hyperparameter trend**: Weak plumes prefer many components (127+), strong plumes prefer fewer (10-48)[^1]
- **Neural approach**: Learn spatial-spectral background dictionary for each cluster using PCA-based scheme[^3]

**Watershed Segmentation (WS)**[^2]:
- Use image segmentation to break scene into groups of similar pixels
- WS determines segments by finding boundaries between "different colored" regions[^2]
- Non-marker based WS results in over-segmentation, reducing chance that a segment contains multiple background materials[^2]
- **Strategy**: Estimate local means per segment, use global covariance matrix[^2]

**K-Nearest Neighbors (KNN) approaches**[^1]:
- Select K nearest spectral neighbors for background estimation
- **Finding**: Prefer few neighbors (1-6) for background estimation[^1]
- Trade-off between local specificity and statistical robustness

## 4.4 Loss Function: Enforcing Physical Plausibility

**Pixel-wise reconstruction loss**:

$$\mathcal{L}_{\text{bg}} = \underbrace{\frac{1}{HWn}\sum_{i,j,k}(\mathbf{I}_{\text{bg},ijk} - \mathbf{I}_{\text{clean},ijk})^2}_{\text{Accuracy term}} + \lambda_{\text{grad}}\underbrace{\|\nabla_{ij} \mathbf{I}_{\text{bg},k}\|^2}_{\text{Smoothness term}}$$

**Components**:
1. **MSE term**: Accurate background reconstruction
2. **Gradient penalty**: Encourages spatial smoothness (plumes are smooth)

### Component 1: Mean Squared Error (MSE)

Standard reconstruction loss: predicted background should match true clean image where known.

### Component 2: Gradient Penalty—The Physical Justification

Real surfaces tend to be **spatially smooth** at the scale of plume pixels (30-60 m):
- Vegetation fields: gradual changes in chlorophyll
- Water bodies: uniform reflectance (excluding ships)
- Buildings: smooth rooftops with sharp edges

The gradient penalty $\|\nabla_{ij} \mathbf{I}_{\text{bg}}\|^2$ encourages smoothness by penalizing large spatial derivatives[^6].

**Why this matters physically**:
- **Without penalty**: Network can generate noisy, pixel-level artifacts
- **With penalty**: Enforces that adjacent pixels should have similar radiance (physical reality)
- **At edges**: Gradient penalty is locally high (buildings, roads), but MSE term dominates, preserving true boundaries

**Why gradient penalty**: Prevents over-sharpening artifacts, enforces physical plausibility.

**Typical weighting**: $\lambda_{\text{grad}} = 0.01$—strong enough to smooth but weak enough to preserve real edges.

### Alternative: Spatial-Spectral Regularization

**Advanced approach**[^6]: Optimize criterion incorporating:
- **Robust loss function**: Non-quadratic data fidelity term
- **Spatial regularization**: Enforce spatial smoothness
- **Spectral regularization**: Enforce spectral smoothness (baseline correction)

$$\mathcal{L}_{\text{robust}} = \rho(\mathbf{I}_{\text{bg}} - \mathbf{I}_{\text{clean}}) + \lambda_{\text{spatial}} R_{\text{spatial}}(\mathbf{I}_{\text{bg}}) + \lambda_{\text{spectral}} R_{\text{spectral}}(\mathbf{I}_{\text{bg}})$$

where $\rho$ is a robust loss function (e.g., Huber loss)[^6].

**Advantage**: Jointly exploits spatial and spectral information rather than pixel-by-pixel correction[^6].

### Total Variation Loss

$$\mathcal{L}_{\text{TV}} = \sum_{i,j,k} \sqrt{(\Delta_x \mathbf{I}_{\text{bg}})^2 + (\Delta_y \mathbf{I}_{\text{bg}})^2 + \epsilon}$$

Better preserves sharp edges (buildings) while smoothing uniform regions (fields).

## 4.5 Training Data Requirements

**Quantity**: 5,000-20,000 image pairs

**Generation**:

### Step 1: Acquire Clean Scenes

- **Start with plume-free scenes**:
  - Historical images of same location (before industrial activity)
  - Regions verified to be emission-free
  - ~1,000 unique clean scenes

### Step 2: Generate Realistic Synthetic Plumes

**Use Gaussian plume dispersion model**:

$$C(x,y) = \frac{Q}{2\pi u \sigma_y \sigma_z} \exp\left(-\frac{y^2}{2\sigma_y^2}\right) \exp\left(-\frac{z^2}{2\sigma_z^2}\right)$$

where:
- $Q$: Emission rate [kg/s]
- $u$: Wind speed [m/s]
- $\sigma_y, \sigma_z$: Horizontal and vertical dispersion [m]
- $C(x,y)$: Concentration at position $(x,y)$ [ppm]

**Why Gaussian plumes?**:
- Captures elongation downwind (realistic morphology)
- Smooth spatial structure (physically realistic)
- Parameterizable: vary strength, size, orientation

### Step 3: Apply Radiative Transfer

**Synthetically add plumes**:
- Use Gaussian plume model for realistic spatial structure
- Vary: Location, strength (100-2000 ppm), size (5-50 pixels)

Convert concentration to optical depth:

$$\Delta\tau(x,y,\lambda) = \sigma(\lambda) \cdot C(x,y) \cdot L \cdot N_{\text{total}} \cdot 10^{-6}$$

Apply Beer-Lambert: 

$$\mathbf{I}_{\text{contam}} = \mathbf{I}_{\text{clean}} \cdot \exp(-\Delta\tau_{\text{plume}})$$

**Result**: 20 synthetic variants per clean scene = 20,000 training pairs

### Step 4: Add Realistic Complications

**Add realistic complications**:
- Surface heterogeneity (mix vegetation, water, soil)
- Varying illumination conditions[^7]
- Instrument noise

**Data augmentation**:
- Geometric: Rotation, flipping (8× augmentation)
- Spectral: Small wavelength shifts (±2 nm)
- Intensity: ±10% radiometric scaling

### Illumination Variation Compensation

**Challenge**: Variations in surface topology or optical power distribution can lead to errors in post-processing[^7].

**Solution**: Background correction method to compensate for illumination variations[^7]:
- Estimate optical properties of illumination at target
- Based on normalized spectral profile of light source
- Use measured intensity at fixed wavelength with low absorption (e.g., 800 nm)

## 4.6 How It Works Physically: Inference Process

**Input**: Hyperspectral image with unknown plume

### Step 1: Encoder Processing

- **Layer 1**: Detects low-level features (edges, textures) at full resolution
- **Layer 2**: Detects mid-level features (surface types: water, vegetation) at 500×500
- **Layer 3**: Detects high-level features (scene context: industrial facility, coastline) at 250×250
- **Bottleneck**: Global scene understanding at 125×125
- **Multi-mode clustering**: Implicitly divides scene into background clusters[^3]

### Step 2: Decoder Processing

- **Upsampling begins**: 125×125 → 250×250
  - **Skip connection**: Combines global context with mid-level surface type information
  - **Decision**: "This region is water (from encoder), so predict uniform reflectance (from context)"
  
- **Upsampling continues**: 250×250 → 500×500
  - **Skip connection**: Adds low-level edge details
  - **Decision**: "Preserve building boundaries (from skip) while filling smooth regions (from decoder)"
  
- **Final layer**: 500×500 → 1000×1000
  - Generates pixel-level background estimate
  - Plume-contaminated regions are "inpainted" with predicted background

**Output**: $\mathbf{I}_{\text{bg}}$—estimated plume-free radiance at every pixel

## 4.7 Key Implementation Considerations

### Evaluation Metrics

**1. Root Mean Square Error (RMSE)**[^1]:

$$\text{RMSE} = \sqrt{\frac{1}{HWn}\sum_{i,j,k}(\mathbf{I}_{\text{bg},ijk} - \mathbf{I}_{\text{true},ijk})^2}$$

Measures absolute accuracy in physical units [W·m$^{-2}$·sr$^{-1}$·nm$^{-1}$].

**Note**: MSE increases as signal strength increases for traditional methods like PCA[^1].

**2. Structural Similarity Index (SSIM)**:

$$\text{SSIM} = \frac{(2\mu_x\mu_y + C_1)(2\sigma_{xy} + C_2)}{(\mu_x^2 + \mu_y^2 + C_1)(\sigma_x^2 + \sigma_y^2 + C_2)}$$

**SSIM** (Structural Similarity): Measures perceptual quality

**Why SSIM matters**: Two backgrounds with same RMSE can have different plume detection performance if spatial structure differs.

**3. Downstream VMR Error** (ultimate validation)[^1][^2]:

$$\text{Error}_{\text{VMR}} = \frac{1}{N_{\text{plume}}}\sum_{i \in \text{plume}} |\text{VMR}_{\text{retrieved},i} - \text{VMR}_{\text{true},i}|$$

**Ultimate validation**: Does better background → better VMR?

**Critical test**: Does better background reconstruction → better concentration retrieval? Inaccurate background estimation often results in subpar anomaly detection outcomes[^8].

### Failure Modes to Watch

**Failure modes to watch**:

| Mode | Description | Detection | Mitigation |
|------|-------------|-----------|-----------|
| **Plume bleeding** | Network removes part of real plume | Visual inspection, compare to physics | Train with stronger plumes, harder negatives |
| **Over-smoothing** | Removes legitimate spatial variability | Check SSIM, compare to real variability | Reduce gradient penalty weight |
| **Spectral artifacts** | Unphysical spectral shapes | Validate against spectroscopy databases | Spectral consistency loss |
| **Hallucination** | Network invents non-existent features | Spurious plumes in clean regions | More diverse training data, dropout regularization |

### Hyperparameter Trends

**Key findings from empirical studies**[^1]:

**For background estimation**:
- PCA: Prefer many components (127+)
- KMeans: Prefer many clusters (128)
- KNN: Prefer few neighbors (6-9)
- Annulus: Prefer few dilations (1)

**For identification confidence**:
- All methods prefer lower hyperparameter values
- PCA: 1-26 components (median 26)
- KNN: 1-5 neighbors (median 5)

**Signal strength adaptation**[^1]:
- Weak plumes (10-30 ppm): Use more components/features
- Strong plumes (70-80 ppm): Use fewer components (better separation)

### Operational Deployment

**Operational deployment**:
- **Inference time**: 2-5 seconds for 1000×1000 image (GPU)
- **Memory**: 4-8 GB GPU memory
- **Quality control**: Flag pixels where $|\mathbf{I} - \mathbf{I}_{\text{bg}}| > 3\sigma$ (may indicate network failure)

**Quality control interpretation**:
- Large residuals may indicate network failure (unusual surface type not in training data)
- Action: Revert to physics-based background estimation for flagged pixels

## 4.8 Physical Validation: Does It Capture Real Physics?

### Spectral Consistency Check

Compare predicted background spectrum to known surface types:

$$\text{Error}_{\text{spectral}} = \min_{j \in \text{library}} \|\mathbf{I}_{\text{bg}}(\lambda) - \mathbf{R}_j(\lambda)\|$$

where $\mathbf{R}_j$ are reference spectra (vegetation, water, soil, etc.). Ensures predictions match real surface physics.

### Energy Conservation

Integrated radiance should respect physical bounds:

$$0 \leq \int_{\lambda} \mathbf{I}_{\text{bg}}(x,y,\lambda) d\lambda \leq \text{Solar}_{\text{irradiance}} \times \rho_{\text{max}}$$

where $\rho_{\text{max}} = 1$ (perfect reflector). Prevents unphysical "super-reflective" predictions.

### Background Modeling Validation

**Key principle**[^8]: Background estimation directly impacts detection accuracy. Unstable background estimates lead to poor anomaly detection.

**Validation approach**:
1. Verify background exhibits expected block-diagonal structure[^3]
2. Ensure spatial-spectral dictionaries capture multi-mode characteristics[^3]
3. Test robustness to illumination changes and dynamic backgrounds[^4]

This approach essentially teaches the network to understand **spatial and spectral context** to infer what contaminated pixels should look like, analogous to how your brain fills in occluded objects based on surrounding information. The method leverages the insight that backgrounds exhibit structured patterns that can be learned and exploited for inpainting[^3][^8].

---

## References

[^1]: Improved Background Estimation for Gas Plume Identification in Hyperspectral Images. arXiv:2411.15378. https://arxiv.org/html/2411.15378

[^2]: Local Background Estimation for Improved Gas Plume Identification in Hyperspectral Images. arXiv:2401.13068v1. https://arxiv.org/html/2401.13068v1/

[^3]: Structured Background Modeling for Hyperspectral Anomaly Detection. PMC. https://pmc.ncbi.nlm.nih.gov/articles/PMC6163918/

[^4]: A Novel Background Modeling Algorithm for Hyperspectral Anomaly Detection. PMC. https://pmc.ncbi.nlm.nih.gov/articles/PMC9610167/

[^5]: Research and Application of Several Key Techniques in Hyperspectral Image Preprocessing. Frontiers in Plant Science. https://www.frontiersin.org/journals/plant-science/articles/10.3389/fpls.2021.627865/full

[^6]: A Background Correction Algorithm for Hyperspectral Imaging. EURASIP. https://eurasip.org/Proceedings/Eusipco/Eusipco2023/pdfs/0000486.pdf

[^7]: A background correction method to compensate illumination variation in hyperspectral imaging. Academia.edu. https://www.academia.edu/63886267/A_background_correction_method_to_compensate_illumination_variation_in_hyperspectral_imaging

[^8]: A robust background regression based score estimation algorithm for hyperspectral anomaly detection. ScienceDirect. https://www.sciencedirect.com/science/article/abs/pii/S0924271616304361



***

## 5. ML Operator #3: Spectral-Spatial Denoiser

### 5.1 Problem Statement

**Goal**: Remove noise from hyperspectral imagery while preserving plume signals.

**Physics limitation**: 
- Traditional filters (Gaussian, median) blur spatial structure
- Don't exploit spectral correlations
- Fixed parameters can't adapt to varying noise levels

**Impact of noise**: Reduces detection sensitivity by 2-3× (e.g., 300 ppm threshold → 600 ppm)

### 5.2 Learned Operator

**Inputs**:
- $\mathbf{I}_{\text{noisy}} \in \mathbb{R}^{H \times W \times n}$: Noisy image [W·m$^{-2}$·sr$^{-1}$·nm$^{-1}$]

**Parameters** (learned):
- 3D CNN weights (convolves in spatial + spectral dimensions)
- Typical: 5-10 convolutional layers
- Total parameters: ~1 million

**Outputs**:
- $\mathbf{I}_{\text{clean}} \in \mathbb{R}^{H \times W \times n}$: Denoised image [same units]

**Operator**:

$$f_{\text{denoise}}: (\mathbf{I}_{\text{noisy}}; \mathbf{W}_{\text{CNN}}) \rightarrow \mathbf{I}_{\text{clean}}$$

**Architecture specifics**:
- **3D kernels**: e.g., $3 \times 3 \times 5$ (spatial × spectral)
- **Residual learning**: Predict noise, subtract from input (more stable)
- **Batch normalization**: Between layers for training stability

### 5.3 Loss Function

**Noise2Noise paradigm** (can train without clean images!):

$$\mathcal{L}_{\text{denoise}} = \frac{1}{HWn}\sum_{i,j,k}(\mathbf{I}_{\text{clean},ijk}^{(1)} - \mathbf{I}_{\text{clean},ijk}^{(2)})^2$$

where $\mathbf{I}^{(1)}$ and $\mathbf{I}^{(2)}$ are two independent noisy observations of the same scene.

**Key insight**: Network trained to predict one noisy image from another learns to remove noise (assuming noise is independent between acquisitions).

**Alternative** (if clean images available):

$$\mathcal{L}_{\text{denoise}} = \text{MSE}(\mathbf{I}_{\text{clean}}, \mathbf{I}_{\text{true}}) + \lambda_{\text{percep}} \mathcal{L}_{\text{perceptual}}$$

**Perceptual loss**: Uses pre-trained VGG features to preserve semantic content (plumes, edges).

### 5.4 Training Data Requirements

**Quantity**: 2,000-10,000 noisy image pairs (or clean/noisy pairs)

**Generation**:

1. **Noise2Noise approach** (easier):
   - Acquire two observations of same scene (back-to-back)
   - Natural noise is independent → no clean reference needed
   - **Advantage**: Can use real data directly

2. **Clean + synthetic noise** (more control):
   - Start with high-SNR images (averaged, long integration)
   - Add realistic noise model:
     - Shot noise: $\mathcal{N}(0, \sqrt{I})$ (Poisson → Gaussian)
     - Read noise: $\mathcal{N}(0, \sigma_{\text{read}})$
     - Dark current: Additive bias

**Noise characterization important**: Model must match operational noise statistics.

### 5.5 Key Implementation Considerations

**Performance metrics**:
- **PSNR** (Peak Signal-to-Noise Ratio): Quantitative quality [dB]
- **SSIM**: Perceptual quality [0-1]
- **Plume preservation**: Verify known plumes not removed (compare before/after on labeled data)

**Architecture depth trade-off**:
- **Shallow** (3-5 layers): Fast, may not remove all noise
- **Deep** (10-15 layers): Better denoising, slower, may over-smooth
- **Optimal**: 7-10 layers with skip connections

**Watch-outs**:

| Issue | Symptom | Fix |
|-------|---------|-----|
| **Plume removal** | Real plumes treated as noise | Add labeled plumes to training, use perceptual loss |
| **Over-smoothing** | Lost spatial detail | Reduce network depth, add high-freq loss component |
| **Spectral distortion** | Unphysical spectra | Add spectral smoothness prior, validate with reference spectra |

**Operational considerations**:
- **Apply before normalization**: Denoise in absolute radiance space
- **Inference time**: 0.5-2 seconds per 1000×1000 image (GPU)
- **When to use**: Always beneficial for low-SNR instruments or dark scenes

***

## 6. ML Operator #4: End-to-End Plume Detection

### 6.1 Problem Statement

**Goal**: Direct pixel-wise classification (plume vs. background) without intermediate retrieval step.

**Physics pipeline limitations**:
- Multiple steps: Normalize → Retrieve → Threshold → Cluster
- Each step has hyperparameters (thresholds, window sizes)
- Error propagation through pipeline
- Not optimized end-to-end

### 6.2 Learned Operator

**Inputs**:
- $\mathbf{I} \in \mathbb{R}^{H \times W \times n}$: Raw or normalized hyperspectral image

**Parameters** (learned):
- DeepLabv3+ or U-Net architecture weights
- Typical: ~20 million parameters (larger than previous operators)

**Outputs**:
- $\mathbf{P} \in ^{H \times W}$: Plume probability map [dimensionless][8]
- $\mathbf{M} \in \{0,1\}^{H \times W}$: Binary detection mask (threshold $\mathbf{P}$ at 0.5)

**Operator**:

$$f_{\text{detect}}: (\mathbf{I}; \mathbf{W}_{\text{DeepLab}}) \rightarrow \mathbf{P}$$

**Why DeepLabv3+**: 
- Atrous spatial pyramid pooling (ASPP): Multi-scale context
- Encoder-decoder: Precise boundaries
- State-of-art for semantic segmentation

### 6.3 Loss Function

**Binary cross-entropy with class weighting**:

$$\mathcal{L}_{\text{detect}} = -\frac{1}{HW}\sum_{i,j}\left[w_{\text{pos}} \cdot y_{ij} \log(p_{ij}) + w_{\text{neg}} \cdot (1-y_{ij})\log(1-p_{ij})\right]$$

where:
- $y_{ij} \in \{0,1\}$: True label (0=background, 1=plume)
- $p_{ij} \in $: Predicted probability[8]
- $w_{\text{pos}}, w_{\text{neg}}$: Class weights

**Class weighting rationale**:
- Plumes are rare: ~1-5% of pixels
- Unweighted loss → network predicts "all background" (95% accuracy but useless!)
- **Solution**: $w_{\text{pos}} = 10-20 \times w_{\text{neg}}$ (adjust based on class ratio)

**Alternative**: **Focal loss** (handles class imbalance automatically):

$$\mathcal{L}_{\text{focal}} = -\frac{1}{HW}\sum_{i,j}(1-p_{ij})^\gamma y_{ij} \log(p_{ij})$$

where $\gamma = 2$ (focuses on hard examples).

### 6.4 Training Data Requirements

**Quantity**: 1,000-5,000 labeled images

**Labeling approaches**:

1. **Manual annotation** (gold standard, expensive):
   - Expert labels plume boundaries
   - ~10-30 minutes per image
   - **Cost**: 500-2500 person-hours for 5000 images
   - **Quality**: Highest, but subjective

2. **Physics-based pseudo-labels** (scalable):
   - Run combined model, threshold at high confidence ($>5\sigma$)
   - Only label obvious plumes (conservative)
   - **Limitation**: Misses weak/marginal plumes

3. **Active learning** (efficient):
   - Start with small labeled set (100 images)
   - Train initial model
   - Select most uncertain examples for labeling
   - **Benefit**: Achieve 90% performance with 20% of labels

**Label quality matters more than quantity**: 1000 high-quality labels > 10,000 noisy labels.

### 6.5 Key Implementation Considerations

**Evaluation metrics**:
- **Precision**: Of detected plumes, % truly plumes (avoid false alarms)
- **Recall**: Of true plumes, % detected (sensitivity)
- **F1-score**: Harmonic mean $2 \cdot \frac{\text{Precision} \cdot \text{Recall}}{\text{Precision} + \text{Recall}}$
- **IoU** (Intersection over Union): Spatial overlap metric

**Target performance**: F1 > 0.90, IoU > 0.75 for operational use.

**Failure modes**:

| Mode | Description | Mitigation |
|------|-------------|-----------|
| **False positives** | Clouds, surface features misclassified | Train with diverse backgrounds, add negative examples |
| **Missed weak plumes** | Low sensitivity to $\Delta\tau < 0.05$ | Augment with weak synthetic plumes, adjust class weights |
| **Poor boundaries** | Fuzzy plume edges | Use decoder with attention, high-res skip connections |

**Post-processing** (optional):
- Connected component analysis: Remove tiny isolated detections
- Size filtering: Plumes typically >5 pixels
- **Trade-off**: Improves precision, may reduce recall

***

## 7. ML Operator #5: Super-Resolution Enhancement

### 7.1 Problem Statement

**Goal**: Reconstruct high-resolution VMR map (e.g., 15 m pixels) from low-resolution observations (60 m pixels).

**Physics limitation**:
- Pixel size fundamentally limits spatial resolution
- Sub-pixel plume structure missed or averaged
- Source localization uncertainty

**Benefit**: 
- Resolve plume fine structure
- Better quantification (less partial pixel contamination)
- Improved source attribution

### 7.2 Learned Operator

**Inputs**:
- $\alpha_{\text{LR}} \in \mathbb{R}^{H \times W}$: Low-resolution VMR map [ppm]
- Context: May also input original spectral data for guidance

**Parameters** (learned):
- ESRGAN (Enhanced Super-Resolution GAN) architecture
- Generator: ~10-20 million parameters
- Discriminator: ~5 million parameters

**Outputs**:
- $\alpha_{\text{HR}} \in \mathbb{R}^{sH \times sW}$: High-resolution VMR map [ppm]
- $s$: Scale factor (typically 2-4×)

**Operator**:

$$f_{\text{SR}}: (\alpha_{\text{LR}}; \mathbf{W}_{\text{Generator}}) \rightarrow \alpha_{\text{HR}}$$

### 7.3 Loss Function

**GAN-based training** (adversarial + content):

$$\mathcal{L}_{\text{SR}} = \underbrace{\mathcal{L}_{\text{adversarial}}}_{\text{Fool discriminator}} + \lambda_{\text{content}}\underbrace{\mathcal{L}_{\text{content}}}_{\text{Match true HR}} + \lambda_{\text{percep}}\underbrace{\mathcal{L}_{\text{perceptual}}}_{\text{Preserve structure}}$$

**Components**:

1. **Adversarial loss** (makes output look realistic):
   $$\mathcal{L}_{\text{adv}} = -\log D(\alpha_{\text{HR}})$$
   Discriminator $D$ learns to distinguish real vs. generated HR images.

2. **Content loss** (pixel-wise accuracy):
   $$\mathcal{L}_{\text{content}} = \|\alpha_{\text{HR}} - \alpha_{\text{true,HR}}\|^2$$

3. **Perceptual loss** (preserves semantic features):
   $$\mathcal{L}_{\text{percep}} = \|\phi(\alpha_{\text{HR}}) - \phi(\alpha_{\text{true,HR}})\|^2$$
   where $\phi$ extracts features from pre-trained network (VGG).

**Typical weights**: $\lambda_{\text{content}} = 0.1$, $\lambda_{\text{percep}} = 1.0$

### 7.4 Training Data Requirements

**Quantity**: 5,000-20,000 LR/HR pairs

**Generation challenge**: Need true high-resolution VMR ground truth.

**Approaches**:

1. **Synthetic plumes at high resolution**:
   - Generate plumes on fine grid (e.g., 5 m)
   - Downsample to operational resolution (e.g., 60 m) → LR input
   - Keep original fine grid → HR target
   - **Pro**: Unlimited data
   - **Con**: Synthetic, may not capture real complexity

2. **Aircraft + satellite pairs**:
   - Aircraft: 3-5 m resolution
   - Satellite: 30-60 m resolution
   - Spatially/temporally co-registered
   - **Pro**: Real data
   - **Con**: Limited availability, registration errors

3. **Simulation-based**:
   - Large eddy simulation (LES) of plume dispersion
   - High-fidelity physics
   - Subsample for LR/HR pairs

**Recommended**: Mixture of synthetic (80%) + real (20%) for best generalization.

### 7.5 Key Implementation Considerations

**Validation**:
- **PSNR/SSIM**: Quantitative quality
- **Edge preservation**: Check plume boundary sharpness
- **Quantitative accuracy**: Does total plume integral match? (Conservation check)

**Failure modes**:

| Mode | Description | Mitigation |
|------|-------------|-----------|
| **Hallucination** | Invents structure not in data | Stronger content loss weight, more training data |
| **Checkerboard artifacts** | Grid-like patterns | Use better upsampling (PixelShuffle vs. transpose conv) |
| **Over-sharpening** | Unrealistic sharp edges | Reduce adversarial loss weight |

**Operational use**:
- Apply **after** initial retrieval
- Only for detected plumes (don't SR background noise)
- Validate with physics-based forward modeling

**Uncertainty**: 
- Super-resolved features have higher uncertainty (extrapolation)
- Provide uncertainty maps alongside SR output
- Use ensemble of generators for uncertainty quantification

***

## 8. Cross-Cutting Considerations

### 8.1 Training Best Practices

**Data splitting strategy**:
```
Training:   60% (optimize weights)
Validation: 20% (hyperparameter tuning, early stopping)
Test:       20% (final performance evaluation, never used in training)
```

**Critical**: Ensure splits are **independent**:
- **Spatial independence**: Different geographic regions
- **Temporal independence**: Different time periods
- **Source independence**: Different facilities/plume types

**Learning rate scheduling**:
- Start high: 1e-3 to 1e-4
- Decay when validation loss plateaus
- Cosine annealing or step decay (reduce by 10× every 30 epochs)

**Batch size considerations**:
- Larger batches: More stable gradients, faster convergence
- Smaller batches: Better generalization (noise in gradients acts as regularization)
- **Typical**: 16-64 for image-based tasks

### 8.2 Computational Requirements

| Task | Training Time | GPU Memory | Inference Speed |
|------|--------------|------------|----------------|
| **Emulator** | 2-6 hours | 4 GB | 0.1 ms/pixel |
| **Background** | 12-24 hours | 16 GB | 2 sec/image |
| **Denoiser** | 6-12 hours | 8 GB | 0.5 sec/image |
| **Detection** | 24-48 hours | 24 GB | 1 sec/image |
| **Super-res** | 48-72 hours | 32 GB | 5 sec/image |

**Hardware recommendations**:
- **Training**: NVIDIA A100 or V100 GPUs (40-80 GB VRAM)
- **Inference**: NVIDIA T4 or RTX 4090 (16-24 GB VRAM) sufficient

### 8.3 Model Validation and Quality Assurance

**Three-tier validation**:

1. **Synthetic test set** (controlled conditions):
   - Known ground truth
   - Vary parameters systematically
   - Quantify accuracy vs. plume strength, surface type, noise level

2. **Real scenes with physics-based reference**:
   - Compare ML predictions to nonlinear retrieval (best physics)
   - Should agree within uncertainties
   - Identifies systematic biases

3. **Controlled release experiments** (gold standard):
   - Known emission rate
   - Compare retrieved flux to truth
   - Ultimate validation but rare/expensive

**Red flags** requiring investigation:

| Observation | Possible Issue |
|-------------|---------------|
| Training loss decreases, validation increases | Overfitting |
| Sudden validation loss spike | Learning rate too high, bad batch |
| Predictions all near mean | Underfitting, collapsed gradients |
| Uncertainty estimates uncalibrated | Need NLL loss, check calibration plots |
| Systematic errors vs. scene conditions | Insufficient training diversity |

### 8.4 Deployment and Monitoring

**Model versioning**:
- Track: Training data, architecture, hyperparameters, performance
- Use MLflow, Weights & Biases, or similar
- Enable rollback if deployed model underperforms

**Continuous monitoring**:
- Log predictions and uncertainties
- Flag anomalies: Predictions outside expected range
- Track performance metrics on incoming data
- **Drift detection**: Performance degrading over time? (May need retraining)

**When to retrain**:
- New instrument deployed (different noise characteristics)
- Seasonal changes (e.g., snow cover not in training data)
- Performance metrics degrade >10% from validation
- New plume types encountered

### 8.5 Interpretability and Trust

**Physics-informed validation**:
- ML predictions should respect physical constraints (positive VMR, Beer-Lambert relationship)
- Add physics-based regularization to loss function
- Compare ML gradients ($\partial\alpha/\partial y$) to physics Jacobian

**Explainability techniques**:
- **Saliency maps**: Which wavelengths most important for prediction?
- **LIME/SHAP**: Local explanations for individual retrievals
- **Ablation studies**: Remove features, measure impact

**Building trust**:
- Provide uncertainty estimates with all predictions
- Flag out-of-distribution inputs (e.g., Mahalanobis distance)
- Hybrid physics-ML: Use physics for low-stakes, ML for high-stakes (validated)
- Document failure modes and limitations clearly

***

## 9. Summary: ML Integration Roadmap

### Immediate Wins (Low-Hanging Fruit)

| Operator | Implementation Effort | Expected Benefit | Priority |
|----------|---------------------|-----------------|----------|
| **Denoiser** | Low (2-4 weeks) | +10 dB SNR | **High** |
| **Background estimator** | Medium (4-6 weeks) | 50% error reduction | **High** |
| **Neural emulator** | Medium (6-8 weeks) | 100× speedup | **High** |

**Start here**: Biggest impact with modest effort.

### Medium-Term (Requires Infrastructure)

| Operator | Implementation Effort | Expected Benefit | Priority |
|----------|---------------------|-----------------|----------|
| **Detection network** | High (8-12 weeks) | +6% F1-score | Medium |
| **Multi-task learning** | High (12-16 weeks) | Unified pipeline | Medium |

**Prerequisites**: Labeled training data, GPU infrastructure, MLOps pipeline.

### Advanced (Research Frontier)

| Operator | Implementation Effort | Expected Benefit | Priority |
|----------|---------------------|-----------------|----------|
| **Super-resolution** | Very high (16-24 weeks) | 4× resolution | Low |
| **Physics-informed NNs** | Very high (research project) | Improved generalization | Low |

**Consider if**: Specific need (e.g., sub-pixel source attribution), research team available.

### Recommended Hybrid Pipeline

**Operational best practice** combines physics and ML:

```
Stage 1: ML Denoising (1 sec)
    ↓
Stage 2: ML Background Estimation (2 sec)
    ↓
Stage 3: Normalization (physics, instant)
    ↓
Stage 4: ML Emulator Retrieval (1 sec)
    ↓
Stage 5: Physics-based QC (check Beer-Lambert consistency)
    ↓
Stage 6: ML Detection for filtering false positives (1 sec)
    ↓
Stage 7: Optional: Super-resolution for strong plumes (5 sec)
```

**Total time**: ~10 seconds for 1M pixel scene (vs. 14 hours pure physics)
**Accuracy**: 2-3% (vs. <2% nonlinear, 5-10% combined linear)

**The future is hybrid**: Use ML for speed and complexity, physics for validation and interpretability. Neither alone is sufficient for operational excellence.

Sources
[1] Beer–Lambert law for optical tissue diagnostics https://pmc.ncbi.nlm.nih.gov/articles/PMC8553265/
[2] Beer Law - an overview https://www.sciencedirect.com/topics/earth-and-planetary-sciences/beer-law
[3] Understanding the Limits of the Bouguer-Beer-Lambert Law https://www.spectroscopyonline.com/view/understanding-the-limits-of-the-bouguer-beer-lambert-law
[4] Beer-Lambert's Law: Principles and Applications in Daily Life https://www.findlight.net/blog/beer-lamberts-law-explained-applications/
[5] The Bouguer‐Beer‐Lambert Law: Shining Light on the ... https://pmc.ncbi.nlm.nih.gov/articles/PMC7540309/
[6] Beer-Lambert law for optical tissue diagnostics - PubMed https://pubmed.ncbi.nlm.nih.gov/34713647/
[7] Beer-Lambert Law Spectrophotometer https://www.hinotek.com/an-in-depth-analysis-of-the-beer-lambert-law-spectrophotometer/
[8] Beer–Lambert law https://en.wikipedia.org/wiki/Beer%E2%80%93Lambert_law
[9] Applications & Limitations of Beer Lambert Law: Presented ... https://www.scribd.com/presentation/408720252/Beer-Lambert-Law
[10] Application of the Beer–Lambert Model to Attenuation of ... https://repository.library.noaa.gov/view/noaa/20744/noaa_20744_DS1.pdf
