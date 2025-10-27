---
title: Beer-Lambert's Law RTM
subject: Methane
short_title: Radiative Transfer Model
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


## Introduction and Physical Motivation

### The Absolute Radiance Model

The **absolute radiance formulation** represents the fundamental forward model for atmospheric methane detection using passive remote sensing in the shortwave infrared (SWIR). This model describes how radiance measured at a satellite or airborne sensor relates to atmospheric methane concentration through the Beer-Lambert law of absorption.

### Physical Context

When solar radiation reflects off Earth's surface and travels through the atmosphere to reach a sensor, it is attenuated by atmospheric absorption. Methane absorbs strongly in specific SWIR bands (notably 1650 nm and 2300 nm). The Beer-Lambert law quantifies this exponential attenuation as a function of:

1. **Molecular properties**: Absorption cross-section (temperature and pressure dependent)
2. **Atmospheric state**: Total number density (from temperature and pressure via ideal gas law)
3. **Methane concentration**: Volume mixing ratio along the optical path
4. **Geometric factors**: Path length and viewing geometry (air mass factor)
5. **Scene properties**: Surface reflectance and solar illumination

### Applications

This model is essential for:
- **Flux quantification**: Converting observed radiance to emission rates requires absolute calibration
- **Full-physics retrievals**: Simultaneous estimation of methane, aerosols, and surface properties
- **Radiative transfer validation**: Benchmark for testing atmospheric forward models
- **Fundamental understanding**: Direct physical relationship between radiance and concentration

### Treatment Relative to Observations

Absolute radiance measurements require:
- **Radiometric calibration**: Conversion from digital counts to physical radiance units (W/m²/sr/cm⁻¹)
- **Known solar irradiance**: Top-of-atmosphere spectral irradiance (varies with Earth-Sun distance and solar zenith angle)
- **Surface reflectance estimation**: Often the largest uncertainty in operational retrievals
- **Atmospheric correction**: Account for scattering by molecules and aerosols

These requirements make absolute retrievals challenging but provide physically interpretable quantities needed for quantitative emission estimation.

---

## 1. Concentration 

* What is concentration?
* How do we measure it? ELI5
* What are the units? Link the units to the measurment
* Talk about different places (lab vs ground vs remote sensing)


### Total Concentration - Background + Enhancement

The total methane volume mixing ratio is the sum of background and enhancement:

$$\text{VMR}_{\text{total}} = \text{VMR}_{\text{bg}} + \Delta\text{VMR}$$

**Components:**

- $\text{VMR}_{\text{bg}}$: background atmospheric methane concentration
  - **Units:** ppm (parts per million by volume)
  - **Typical value:** 1.85-1.90 ppm (global average, Northern Hemisphere ~1.90 ppm, Southern Hemisphere ~1.75 ppm)
  - **Temporal variation:** Increasing ~8-10 ppb/year (0.008-0.010 ppm/year)
  - **Spatial variation:** ±50-100 ppb between regions
  - **Physical meaning**: Well-mixed greenhouse gas concentration under normal atmospheric conditions
  
- $\Delta\text{VMR}$: plume enhancement above background
  - **Units:** ppm
  - **Range:** 
    - Weak sources: 10-100 ppm at sensor footprint
    - Moderate emissions: 100-1000 ppm 
    - Strong point sources: 1000-10,000+ ppm near source
  - **Physical meaning**: Spatially localized excess methane from emission sources (leaks, vents, natural seeps)
  
- $\text{VMR}_{\text{total}}$: total methane concentration
  - **Units:** ppm
  - **Physical meaning**: Combined atmospheric and plume methane along optical path

**Relationship to column-averaged quantities:**

For column measurements:
$$\text{XCH}_4 = \frac{\int_0^{z_{\text{top}}} n_{\text{CH}_4}(z) \, dz}{\int_0^{z_{\text{top}}} n_{\text{air}}(z) \, dz}$$

where $n$ denotes number density profiles. For boundary layer plumes:
$$\text{XCH}_4 \approx \text{VMR}_{\text{bg}} + \Delta\text{VMR} \cdot \frac{h_{\text{plume}}}{H_{\text{atm}}}$$

where $h_{\text{plume}}$ is plume vertical extent and $H_{\text{atm}}$ is atmospheric scale height (~8 km).

---

## 2. Optical Depth + Jacobian

### Optical Depth

The **optical depth** (also called optical thickness or extinction) quantifies the total absorption along the atmospheric path. It is dimensionless and represents the natural logarithm of the attenuation factor.

$$\tau(\text{VMR}) = \sigma(\lambda,T,P) \cdot N_{\text{total}} \cdot \text{VMR} \cdot 10^{-6} \cdot L \cdot \text{AMF}$$

Notice how we have many control vectors, $(\lambda,T,P)$, where we condition our prediction of the optical depth.
**Physical parameters with full definitions:**

- $\sigma(\lambda, T, P)$: **absorption cross-section**
  - **Units:** cm²/molecule
  - **Typical value:** $10^{-20}$ to $10^{-18}$ cm²/molecule at 2300 nm
  - **Wavelength dependence:** Peaked at line centers, nearly zero between lines
  - **Temperature dependence:** 
    - Line strength: $S(T) = S(T_0) \frac{Q(T_0)}{Q(T)} \left(\frac{T_0}{T}\right)^{n_{\text{rot}}} \exp\left[-\frac{hcE''}{k_B}\left(\frac{1}{T} - \frac{1}{T_0}\right)\right]$
    - $Q(T)$: partition function
    - $n_{\text{rot}}$: rotational quantum number
    - $E''$: lower state energy (cm⁻¹)
  - **Pressure dependence:**
    - Line width: $\gamma(P,T) = \gamma_0(T_0) \left(\frac{P}{P_0}\right) \left(\frac{T_0}{T}\right)^{n_{\text{air}}}$
    - $\gamma_0$: reference line width (cm⁻¹/atm)
    - $n_{\text{air}}$: temperature exponent (typically 0.5-1.0)
    - Line shape: Voigt profile (convolution of Doppler and Lorentz profiles)
  - **Data source:** HITRAN or GEISA spectroscopic databases
  
- $N_{\text{total}}$: **total number density**
  - **Units:** molecules/m³
  - **Definition:** $N_{\text{total}} = \frac{P}{k_B T}$ (from ideal gas law)
  - **Typical value:** $2.5 \times 10^{25}$ molecules/m³ at sea level (T=288 K, P=1 atm)
  - **Components:**
    - $P$: pressure (Pa)
      - Convert from atm: $P_{\text{Pa}} = P_{\text{atm}} \times 101325$
      - Altitude dependence: $P(z) \approx P_0 \exp(-z/H)$ where $H \approx 8$ km
    - $k_B = 1.380649 \times 10^{-23}$ J/K: Boltzmann constant (exact, 2019 SI definition)
    - $T$: temperature (K)
      - Typical range: 250-300 K for troposphere
      - Altitude dependence: $T(z) \approx T_0 - \Gamma z$ where $\Gamma \approx 6.5$ K/km (tropospheric lapse rate)
  
- $10^{-6}$: **ppm to volume fraction conversion**
  - **Units:** dimensionless
  - **Physical meaning:** 1 ppm = 1 molecule per million air molecules = $10^{-6}$ volume fraction
  
- $L$: **atmospheric path length**
  - **Units:** cm (centimeters, for consistency with cross-section units)
  - **Typical values:**
    - Nadir satellite observation: $10^5$ cm = 1 km (boundary layer)
    - Total column: $10^6$ cm = 10 km (tropospheric average)
    - Aircraft observation: $10^4$ - $10^5$ cm (altitude dependent)
    - Ground-based column: $10^6$ - $10^7$ cm (full atmospheric column)
  - **Physical meaning:** Effective absorption path through methane-containing atmosphere
  - **For vertically stratified atmosphere:**
    $$L_{\text{eff}} = \int_0^{z_{\text{top}}} \frac{n_{\text{CH}_4}(z)}{n_{\text{CH}_4,\text{avg}}} \, dz$$
  
- $\text{AMF}$: **air mass factor**
  - **Units:** dimensionless
  - **Definition:** $\text{AMF} = \frac{1}{\cos(\theta_{\text{zenith}})}$ (plane-parallel atmosphere approximation)
  - **Typical values:**
    - Nadir (0°): AMF = 1.0
    - 30° zenith: AMF = 1.15
    - 45° zenith: AMF = 1.41
    - 60° zenith: AMF = 2.0
    - 70° zenith: AMF = 2.92
    - 85° zenith: AMF = 11.5 (approaching grazing incidence)
  - **Physical meaning:** Factor by which slant path exceeds vertical path
  - **More accurate formulation** (spherical atmosphere):
    $$\text{AMF}(\theta) = \frac{1}{\sqrt{\cos^2\theta + 2\frac{R_E}{H} + \left(\frac{R_E}{H}\right)^2} - \frac{R_E}{H}\cos\theta}$$
    where $R_E = 6371$ km (Earth radius) and $H \approx 8$ km (scale height)

**Linearity property:**

The optical depth is **linear in VMR**:
$$\frac{\partial \tau}{\partial \text{VMR}} = \text{constant}$$

This fundamental property enables analytical solutions and is exploited in linear inversions.

---
### Enhancement Optical Depth

**Additive decomposition:**
$$\tau_{\text{total}} = \tau_{\text{bg}} + \Delta\tau$$

where:

**Background optical depth:**
$$\tau_{\text{bg}} = \sigma(\lambda,T,P) \cdot N_{\text{total}} \cdot \text{VMR}_{\text{bg}} \cdot 10^{-6} \cdot L \cdot \text{AMF}$$

- **Units:** dimensionless
- **Typical value:** 0.01-0.10 for SWIR methane bands (2300 nm)
- **Physical meaning:** Cumulative absorption due to normal atmospheric methane concentration
- **Wavelength dependent:** Strong absorption lines have larger $\tau_{\text{bg}}$

**Enhancement optical depth:**
$$\Delta\tau = \sigma(\lambda,T,P) \cdot N_{\text{total}} \cdot \Delta\text{VMR} \cdot 10^{-6} \cdot L \cdot \text{AMF}$$

- **Units:** dimensionless
- **Typical value:** 0.001-0.50 depending on plume strength
- **Physical meaning:** Additional absorption due to plume only
- **Linear in enhancement:** $\Delta\tau \propto \Delta\text{VMR}$

---
### Jacobian of Optical Depth

The **sensitivity** of optical depth to VMR changes:

$$\frac{\partial \tau}{\partial \text{VMR}} = \sigma(\lambda,T,P) \cdot N_{\text{total}} \cdot 10^{-6} \cdot L \cdot \text{AMF}$$

**Units:** ppm⁻¹ (dimensionless per ppm)

**Physical interpretation:**
- Represents the change in optical depth per unit change in VMR
- Larger values indicate higher sensitivity (stronger absorption)
- Proportional to absorption cross-section (wavelength dependent)
- Independent of current VMR (linearity)

**Alternative notation for enhancement:**
$$\frac{\partial \tau}{\partial (\Delta\text{VMR})} = \sigma(\lambda,T,P) \cdot N_{\text{total}} \cdot 10^{-6} \cdot L \cdot \text{AMF}$$

This is mathematically identical, emphasizing that the Jacobian with respect to enhancement equals the Jacobian with respect to total VMR.

**Wavelength dependence:**

The Jacobian varies across wavelengths due to $\sigma(\lambda)$:
- **Line centers**: Large $|\frac{\partial \tau}{\partial \text{VMR}}|$ (strong sensitivity, may saturate)
- **Line wings**: Moderate sensitivity (optimal for linear regime)
- **Continuum**: Near-zero sensitivity (little information)

**Typical values at 2300 nm:**
- Strong lines: $10^{-3}$ to $10^{-2}$ ppm⁻¹
- Moderate lines: $10^{-4}$ to $10^{-3}$ ppm⁻¹

---

## 3. Transmittance + Jacobian

### Transmittance

The **transmittance** is the fraction of incident radiation that passes through the atmosphere without being absorbed:

$$T(\text{VMR}) = \exp(-\tau(\text{VMR}))$$

**Units:** dimensionless (range: 0 to 1, where 1 = no absorption, 0 = complete absorption)

**Multiplicative decomposition:**
$$T_{\text{total}} = T_{\text{bg}} \cdot T_{\text{enh}}$$

where:

**Background transmittance:**
$$T_{\text{bg}} = \exp(-\tau_{\text{bg}})$$

- **Units:** dimensionless
- **Typical value:** 0.90-0.99 for SWIR methane bands (depends on line strength)
- **Physical meaning:** Fraction of light transmitted through normal atmospheric methane
- **Wavelength dependent:** 
  - Strong lines: $T_{\text{bg}} \approx 0.90-0.95$ (10-5% background absorption)
  - Weak lines: $T_{\text{bg}} \approx 0.98-0.99$ (2-1% background absorption)

**Enhancement transmittance:**
$$T_{\text{enh}} = \exp(-\Delta\tau)$$

- **Units:** dimensionless
- **Physical meaning:** Additional attenuation factor due to plume only
- **Typical values:**
  - Weak plume ($\Delta\tau = 0.01$): $T_{\text{enh}} \approx 0.990$ (1% additional absorption)
  - Moderate plume ($\Delta\tau = 0.10$): $T_{\text{enh}} \approx 0.905$ (9.5% additional absorption)
  - Strong plume ($\Delta\tau = 0.50$): $T_{\text{enh}} \approx 0.607$ (39% additional absorption)

**Multiplicative property:**

Using the exponential identity $\exp(a + b) = \exp(a) \cdot \exp(b)$:

$$T_{\text{total}} = \exp(-(\tau_{\text{bg}} + \Delta\tau)) = \exp(-\tau_{\text{bg}}) \cdot \exp(-\Delta\tau) = T_{\text{bg}} \cdot T_{\text{enh}}$$

**Physical interpretation:**
- Total transmission is the **product** of background and enhancement transmission
- Plume acts as an additional filter applied to background-attenuated light
- Enables separation of scene-dependent (background) and plume-dependent (enhancement) effects

**Saturation effects:**

For large optical depths ($\tau > 1$), transmittance approaches zero exponentially:
- $\tau = 1$: $T = 0.368$ (63% absorption)
- $\tau = 2$: $T = 0.135$ (87% absorption)
- $\tau = 3$: $T = 0.050$ (95% absorption)

This **saturation** limits the dynamic range for quantification at strong absorption lines.

### Jacobian of Transmittance

**With respect to total VMR:**

$$\frac{\partial T}{\partial \text{VMR}} = \frac{\partial}{\partial \text{VMR}}\left[\exp(-\tau)\right] = -\exp(-\tau) \cdot \frac{\partial \tau}{\partial \text{VMR}}$$

**Explicit form:**
$$\frac{\partial T}{\partial \text{VMR}} = -\exp(-\tau) \cdot \sigma \cdot N_{\text{total}} \cdot 10^{-6} \cdot L \cdot \text{AMF}$$

**Units:** ppm⁻¹

**At background:**
$$\frac{\partial T}{\partial \text{VMR}}\bigg|_{\text{bg}} = -T_{\text{bg}} \cdot \sigma \cdot N_{\text{total}} \cdot 10^{-6} \cdot L \cdot \text{AMF}$$

**With respect to enhancement (more natural for plume detection):**

$$\frac{\partial T_{\text{enh}}}{\partial (\Delta\text{VMR})} = -\exp(-\Delta\tau) \cdot \sigma \cdot N_{\text{total}} \cdot 10^{-6} \cdot L \cdot \text{AMF}$$

**At background ($\Delta\tau = 0$):**
$$\frac{\partial T_{\text{enh}}}{\partial (\Delta\text{VMR})}\bigg|_0 = -\sigma \cdot N_{\text{total}} \cdot 10^{-6} \cdot L \cdot \text{AMF}$$

**Key properties:**

1. **Nonlinear**: Jacobian depends on current transmittance (or optical depth) through the $\exp(-\tau)$ term
2. **Negative sign**: Increasing VMR decreases transmittance (absorption effect)
3. **Maximum sensitivity at zero optical depth**: $|\frac{\partial T}{\partial \text{VMR}}|$ is largest when $\tau = 0$
4. **Saturation**: As $\tau$ increases, $|\frac{\partial T}{\partial \text{VMR}}|$ decreases exponentially (diminishing sensitivity)

**Sensitivity vs. optical depth:**

$$\left|\frac{\partial T}{\partial \text{VMR}}\right| = \exp(-\tau) \cdot \left|\frac{\partial \tau}{\partial \text{VMR}}\right|$$

- At $\tau = 0$: Full sensitivity (100%)
- At $\tau = 0.1$: 90.5% of maximum sensitivity
- At $\tau = 1$: 36.8% of maximum sensitivity (significant saturation)
- At $\tau = 2$: 13.5% of maximum sensitivity (severe saturation)

This motivates using **moderate absorption lines** (not the strongest) for quantitative retrievals to avoid saturation.

---

## 4. Beer's Law + Jacobian

### Beer's Law (Forward Model)

The **at-sensor radiance** observed by a hyperspectral instrument follows the Beer-Lambert law:

$$L(\text{VMR}) = \frac{F_0 R}{\pi} \cdot T(\text{VMR}) = \frac{F_0 R}{\pi} \cdot \exp(-\tau(\text{VMR}))$$

**Units:** W/m²/sr/cm⁻¹ (spectral radiance)
- W: watts (power)
- m²: per unit area perpendicular to ray
- sr: per unit solid angle (steradian)
- cm⁻¹: per unit wavenumber (spectral density)

**Alternative units:** W/m²/sr/nm (per wavelength), μW/(cm²·sr·cm⁻¹) (atmospheric science convention)

**Decomposed form using multiplicative transmittance:**

$$L(\text{VMR}_{\text{total}}) = \frac{F_0 R}{\pi} \cdot T_{\text{bg}} \cdot T_{\text{enh}}$$

$$L(\text{VMR}_{\text{total}}) = \underbrace{\frac{F_0 R}{\pi} \cdot \exp(-\tau_{\text{bg}})}_{L_{\text{bg}}} \cdot \underbrace{\exp(-\Delta\tau)}_{T_{\text{enh}}}$$

$$\boxed{L(\text{VMR}_{\text{total}}) = L_{\text{bg}} \cdot \exp(-\Delta\tau)}$$

**Physical components with full definitions:**

- $F_0(\lambda)$: **top-of-atmosphere solar irradiance**
  - **Units:** W/m²/cm⁻¹ (or W/m²/nm)
  - **Typical value at 2300 nm:** ~0.15 W/m²/nm
  - **Wavelength dependence:** Solar Planck spectrum (~5800 K blackbody) modulated by Fraunhofer lines
  - **Temporal variation:** 
    - Earth-Sun distance: ±3.4% annually (perihelion/aphelion)
    - Solar cycle: <0.1% variation (11-year cycle)
  - **Geometric correction:** $F_0(\text{actual}) = F_0(\text{mean}) \cdot (d_{\text{mean}}/d_{\text{actual}})^2$
  - **Data source:** Solar reference spectra (e.g., Kurucz, TSIS)
  
- $R(\lambda, \theta_i, \theta_r, \phi)$: **surface reflectance** (bidirectional reflectance)
  - **Units:** dimensionless (0 to 1, though can exceed 1 for specular reflection)
  - **Definition:** Ratio of reflected to incident irradiance
  - **Typical values:**
    - Ocean/water: 0.02-0.10 (very dark)
    - Dense vegetation: 0.10-0.30 (moderate, higher in NIR)
    - Bare soil: 0.15-0.35 (varies with moisture and composition)
    - Desert/sand: 0.30-0.50 (bright)
    - Snow/ice: 0.70-0.95 (very bright, but lower in SWIR than visible)
    - Urban: 0.10-0.30 (highly variable)
  - **Angular dependence:** Full BRDF (Bidirectional Reflectance Distribution Function)
    - $\theta_i$: solar zenith angle
    - $\theta_r$: viewing zenith angle
    - $\phi$: relative azimuth angle
  - **Lambertian approximation:** $R(\lambda)$ independent of angles (isotropic reflection)
    - Valid for diffuse surfaces
    - Typical error: 10-30% for natural surfaces
  - **Spectral features:**
    - Absorption edges (e.g., "red edge" at 700 nm for vegetation)
    - Water absorption bands
    - Mineral absorption features
  - **Largest uncertainty** in absolute radiance retrievals (often 20-50% uncertainty)
  
- $\pi$: **Lambertian normalization factor**
  - **Units:** dimensionless (sr)
  - **Physical meaning:** For Lambertian reflector, converts hemispherical reflectance to directional radiance
  - **Derivation:** $L = \frac{M}{\pi} = \frac{R \cdot E_{\text{incident}}}{\pi}$
    where $M$ is exitance (W/m²) and $E$ is irradiance (W/m²)
  
- $L_{\text{bg}}$: **background radiance** (with normal atmospheric absorption)
  - **Units:** W/m²/sr/cm⁻¹
  - **Definition:** $L_{\text{bg}} = \frac{F_0 R}{\pi} \exp(-\tau_{\text{bg}})$
  - **Physical meaning:** Expected radiance at sensor under background methane conditions
  - **Typical values at 2300 nm:**
    - Dark surface (R=0.1): ~0.003 W/m²/sr/nm
    - Moderate surface (R=0.3): ~0.010 W/m²/sr/nm
    - Bright surface (R=0.5): ~0.015 W/m²/sr/nm
  - **Wavelength dependent:** Varies with both $F_0(\lambda)$, $R(\lambda)$, and $\tau_{\text{bg}}(\lambda)$

**Physical interpretation of decomposed form:**

The observed radiance is the **background radiance attenuated by the plume enhancement factor** $\exp(-\Delta\tau)$.

- **No plume** ($\Delta\tau = 0$): $L = L_{\text{bg}}$ (observe background)
- **Weak plume** ($\Delta\tau = 0.01$): $L = 0.99 \cdot L_{\text{bg}}$ (1% reduction)
- **Moderate plume** ($\Delta\tau = 0.10$): $L = 0.905 \cdot L_{\text{bg}}$ (9.5% reduction)
- **Strong plume** ($\Delta\tau = 1.0$): $L = 0.368 \cdot L_{\text{bg}}$ (63% reduction)

**Assumptions and approximations:**

1. **Single scattering**: Neglects multiple scattering by molecules and aerosols
   - Valid for clear atmospheres and moderate optical depths
   - Error: <5% for $\tau < 1$ in clean air

2. **Lambertian surface**: Isotropic reflection (BRDF approximated as constant)
   - Error depends on surface type and viewing geometry
   - Typical error: 10-30% in absolute radiance

3. **Plane-parallel atmosphere**: Horizontal homogeneity
   - Valid for satellite footprints < 10 km
   - Breaks down near cloud edges or strong horizontal gradients

4. **Neglects atmospheric scattering**: Rayleigh and aerosol scattering not included
   - Valid in SWIR where scattering is weak
   - More important in visible/near-IR

5. **Path-averaged concentration**: Assumes vertically well-mixed plume
   - For boundary layer plumes, reasonable approximation
   - Breaks down for elevated plumes or vertical gradients

### Jacobian of Radiance

The **sensitivity** of radiance to VMR changes:

$$\frac{\partial L}{\partial \text{VMR}} = \frac{F_0 R}{\pi} \cdot \frac{\partial T}{\partial \text{VMR}} = \frac{F_0 R}{\pi} \cdot \left(-\exp(-\tau)\right) \cdot \frac{\partial \tau}{\partial \text{VMR}}$$

**Explicit form:**
$$\frac{\partial L}{\partial \text{VMR}} = -\frac{F_0 R}{\pi} \cdot \exp(-\tau) \cdot \sigma \cdot N_{\text{total}} \cdot 10^{-6} \cdot L \cdot \text{AMF}$$

**Units:** (W/m²/sr/cm⁻¹)/ppm

**At background:**
$$\frac{\partial L}{\partial \text{VMR}}\bigg|_{\text{bg}} = -L_{\text{bg}} \cdot \sigma \cdot N_{\text{total}} \cdot 10^{-6} \cdot L \cdot \text{AMF}$$

**Alternative form using enhancement:**

$$\frac{\partial L}{\partial (\Delta\text{VMR})} = -L_{\text{bg}} \cdot \exp(-\Delta\tau) \cdot \sigma \cdot N_{\text{total}} \cdot 10^{-6} \cdot L \cdot \text{AMF}$$

**At background ($\Delta\tau = 0$):**
$$\frac{\partial L}{\partial (\Delta\text{VMR})}\bigg|_0 = -L_{\text{bg}} \cdot \sigma \cdot N_{\text{total}} \cdot 10^{-6} \cdot L \cdot \text{AMF}$$

**Key properties:**

1. **Nonlinear**: Depends on current radiance level (or optical depth) through exponential term
2. **Negative sign**: Increasing methane decreases radiance (absorption)
3. **Proportional to background radiance**: Brighter scenes have larger absolute sensitivity
4. **Wavelength dependent**: Follows absorption cross-section spectrum
5. **Saturation**: Sensitivity decreases exponentially as plume strengthens

**Physical interpretation:**

The Jacobian represents the expected change in observed radiance for a 1 ppm increase in methane concentration:

- **Strong absorption line, bright surface**: $|\frac{\partial L}{\partial \text{VMR}}| \approx 10^{-5}$ W/m²/sr/nm/ppm
- **Moderate absorption, moderate surface**: $|\frac{\partial L}{\partial \text{VMR}}| \approx 10^{-6}$ W/m²/sr/nm/ppm
- **Weak absorption or dark surface**: $|\frac{\partial L}{\partial \text{VMR}}| \approx 10^{-7}$ W/m²/sr/nm/ppm

**Signal-to-noise considerations:**

For detection, require:
$$\left|\frac{\partial L}{\partial \text{VMR}} \cdot \Delta\text{VMR}\right| > k \cdot \sigma_{\text{noise}}$$

where $k = 3-5$ for 3σ-5σ detection threshold and $\sigma_{\text{noise}}$ is the instrument noise.

**Typical instrument noise:**
- High-quality spectrometer: $\sigma_{\text{noise}} \approx 10^{-6}$ W/m²/sr/nm (SNR ~1000)
- Moderate spectrometer: $\sigma_{\text{noise}} \approx 10^{-5}$ W/m²/sr/nm (SNR ~100)

---

## 5. Observations

### Observation Model

The measured radiance spectrum at each pixel:

$$\mathbf{y} = L(\text{VMR}_{\text{total}}) + \boldsymbol{\epsilon}$$

**Explicit form:**
$$\mathbf{y} = \frac{F_0 R}{\pi} \exp\left(-\sigma N_{\text{total}} \text{VMR}_{\text{total}} \cdot 10^{-6} L \cdot \text{AMF}\right) + \boldsymbol{\epsilon}$$

**Using enhancement formulation:**
$$\mathbf{y} = \mathbf{L}_{\text{bg}} \odot \exp(-\boldsymbol{\Delta\tau}(\alpha)) + \boldsymbol{\epsilon}$$

where $\alpha = \Delta\text{VMR}$ is the unknown enhancement parameter.

**Components with full definitions:**

- $\mathbf{y}$: **observed radiance spectrum**
  - **Dimensions:** (n_wavelengths,) vector
  - **Units:** W/m²/sr/cm⁻¹ (or W/m²/sr/nm)
  - **Typical n_wavelengths:** 
    - Hyperspectral: 200-400 bands in SWIR
    - Multispectral: 1-10 bands in methane-sensitive regions
  - **Typical values:** $10^{-3}$ to $10^{-2}$ W/m²/sr/nm at 2300 nm
  - **Data source:** Calibrated Level-1B product from sensor
  
- $L(\text{VMR}_{\text{total}})$: **forward model radiance**
  - **Dimensions:** (n_wavelengths,) vector
  - **Units:** W/m²/sr/cm⁻¹
  - **Physical meaning:** Expected radiance based on atmospheric state and surface properties
  
- $\alpha = \Delta\text{VMR}$: **unknown enhancement** (to be estimated)
  - **Type:** Scalar (assuming spatially uniform enhancement over pixel)
  - **Units:** ppm
  - **Prior range:** 0 (background) to 10,000+ ppm (strong sources)
  
- $\boldsymbol{\epsilon} \sim \mathcal{N}(\mathbf{0}, \mathbf{\Sigma})$: **additive Gaussian measurement noise**
  - **Dimensions:** (n_wavelengths,) vector
  - **Units:** W/m²/sr/cm⁻¹
  - **Distribution:** Multivariate Gaussian with zero mean
  - **Covariance:** $\mathbf{\Sigma}$ (n_wavelengths × n_wavelengths matrix)
  
- $\odot$: **element-wise (Hadamard) multiplication**
  - Applies component-by-component: $(\mathbf{a} \odot \mathbf{b})_i = a_i \cdot b_i$
  
- **Bold symbols** indicate wavelength-dependent vectors

### Noise Characteristics

**Covariance matrix** $\mathbf{\Sigma}$:

$$\mathbf{\Sigma} = \mathbb{E}[\boldsymbol{\epsilon}\boldsymbol{\epsilon}^T]$$

- **Dimensions:** (n_wavelengths × n_wavelengths)
- **Units:** (W/m²/sr/cm⁻¹)²
- **Structure:**

**Diagonal elements** $\Sigma_{ii} = \sigma^2_i$:
- **Physical meaning:** Noise variance at wavelength $i$
- **Components:**
  - **Shot noise** (photon counting): $\sigma^2_{\text{shot}} \propto L$ (proportional to signal)
  - **Read noise** (detector): $\sigma^2_{\text{read}}$ (constant)
  - **Dark current** (thermal): $\sigma^2_{\text{dark}}$ (temperature dependent)
  - **Quantization**: $\sigma^2_{\text{quant}} = \Delta^2/12$ where $\Delta$ is bit resolution
  - **Calibration uncertainty**: Systematic errors in radiometric calibration

**Off-diagonal elements** $\Sigma_{ij}$ ($i \neq j$):
- **Physical meaning:** Spectral correlation between wavelengths
- **Sources:**
  - **Optical**: Point spread function in spectrometer (nearest-neighbor correlation)
  - **Detector**: Cross-talk between pixels
  - **Atmospheric**: Correlated scattering effects
- **Typical structure:** Tri-diagonal or band-diagonal (short-range correlations)
- **Often approximated:** $\Sigma_{ij} = 0$ for $|i-j| > 2$ (diagonal or tri-diagonal matrix)

**Simplified models:**

1. **White noise** (diagonal, equal variance):
   $$\mathbf{\Sigma} = \sigma^2 \mathbf{I}$$
   - Simplest assumption
   - Often reasonable for well-calibrated instruments

2. **Diagonal heteroscedastic** (wavelength-dependent variance):
   $$\mathbf{\Sigma} = \text{diag}(\sigma^2_1, \sigma^2_2, \ldots, \sigma^2_n)$$
   - Accounts for wavelength-dependent SNR
   - Common practical choice

3. **Full covariance**:
   $$\mathbf{\Sigma} = \text{full matrix}$$
   - Most accurate but computationally expensive
   - Required for optimal weighted least squares

**Noise estimation methods:**

- **Pre-launch calibration**: Lab measurements of noise statistics
- **Dark frames**: Repeated measurements with shutter closed
- **Homogeneous scenes**: Variance over spatially uniform targets
- **Empirical**: Residual statistics from retrievals over plume-free regions

### Relationship to Raw Measurements

**Sensor measurement chain:**

1. **Photon flux** → Detector
2. **Photoelectrons** → Readout
3. **Digital counts** (DN) → Calibration
4. **At-sensor radiance** (W/m²/sr/nm) → Atmospheric correction
5. **Surface-leaving radiance** → (not needed for absolute methane detection)

**Radiometric calibration:**

$$L(\lambda) = \text{Gain}(\lambda) \cdot (\text{DN}(\lambda) - \text{DN}_{\text{dark}}(\lambda)) + \text{Offset}(\lambda)$$

where:
- Gain: converts counts to radiance (from pre-flight calibration)
- $\text{DN}_{\text{dark}}$: dark current offset
- Offset: any residual bias

**Uncertainty propagation:**

Total noise includes:
$$\sigma^2_{\text{total}} = \sigma^2_{\text{radiometric}} + \sigma^2_{\text{shot}} + \sigma^2_{\text{systematic}}$$

Typical allocation for well-calibrated instrument:
- Radiometric: 1-2% of signal
- Shot noise: 0.1-1% of signal (depends on integration time)
- Systematic: 2-5% of signal (largest contributor)

---

## 6. Measurement Model

### Forward Measurement Model

The relationship between unknown VMR enhancement and observations:

$$\mathbf{y} = g(\alpha) + \boldsymbol{\epsilon}$$

where the **forward operator** is:

$$g(\alpha) = \mathbf{L}_{\text{bg}} \odot \exp(-\boldsymbol{\Delta\tau}(\alpha))$$

with:
$$\boldsymbol{\Delta\tau}(\alpha) = \boldsymbol{\sigma} \odot N_{\text{total}} \cdot \alpha \cdot 10^{-6} L \cdot \text{AMF}$$

**Model structure:**

- **State space**: $\alpha \in \mathbb{R}$ (scalar enhancement, units: ppm)
- **Observation space**: $\mathbf{y} \in \mathbb{R}^{n}$ (measured spectrum, units: W/m²/sr/cm⁻¹)
- **Forward operator**: $g: \mathbb{R} \to \mathbb{R}^{n}$ (nonlinear mapping)
- **Noise**: $\boldsymbol{\epsilon} \sim \mathcal{N}(\mathbf{0}, \mathbf{\Sigma})$ (Gaussian)

**Properties of forward operator:**

1. **Nonlinear**: $g(\alpha_1 + \alpha_2) \neq g(\alpha_1) + g(\alpha_2)$ due to exponential
2. **Monotonic**: $\frac{\partial g}{\partial \alpha} < 0$ (increasing VMR decreases radiance)
3. **Bounded**: $0 < g(\alpha) < \mathbf{L}_{\text{bg}}$ for $\alpha \geq 0$
4. **Smooth**: Infinitely differentiable
5. **Wavelength-coupled**: All wavelengths depend on same scalar $\alpha$

### Inverse Problem (Maximum Likelihood Estimation)

**Goal**: Estimate $\alpha$ from observations $\mathbf{y}$

**Likelihood function** (Gaussian noise assumption):

$$p(\mathbf{y}|\alpha) = \frac{1}{(2\pi)^{n/2}|\mathbf{\Sigma}|^{1/2}} \exp\left(-\frac{1}{2}(\mathbf{y} - g(\alpha))^T \mathbf{\Sigma}^{-1} (\mathbf{y} - g(\alpha))\right)$$

**Maximum likelihood estimate:**

$$\hat{\alpha}_{\text{ML}} = \arg\max_{\alpha} p(\mathbf{y}|\alpha) = \arg\min_{\alpha} \left\{-\log p(\mathbf{y}|\alpha)\right\}$$

**Cost function** (negative log-likelihood):

$$J(\alpha) = \frac{1}{2}(\mathbf{y} - g(\alpha))^T \mathbf{\Sigma}^{-1} (\mathbf{y} - g(\alpha)) + \frac{1}{2}\log|\mathbf{\Sigma}| + \frac{n}{2}\log(2\pi)$$

Since last two terms are independent of $\alpha$:

$$\boxed{\hat{\alpha}_{\text{ML}} = \arg\min_{\alpha} \left\{(\mathbf{y} - \mathbf{L}_{\text{bg}} \odot \exp(-\boldsymbol{\Delta\tau}(\alpha)))^T \mathbf{\Sigma}^{-1} (\mathbf{y} - \mathbf{L}_{\text{bg}} \odot \exp(-\boldsymbol{\Delta\tau}(\alpha)))\right\}}$$

**Units:** dimensionless (cost function), ppm (estimated $\hat{\alpha}$)

**Properties of cost function:**

1. **Non-convex**: Multiple local minima possible (though typically one dominant minimum)
2. **Smooth**: Differentiable, enabling gradient-based optimization
3. **Weighted least squares**: $\mathbf{\Sigma}^{-1}$ weights wavelengths by inverse noise variance

**Optimality conditions:**

Taking derivative and setting to zero:

$$\frac{\partial J}{\partial \alpha} = -\mathbf{H}(\alpha)^T \mathbf{\Sigma}^{-1} (\mathbf{y} - g(\alpha)) = 0$$

where:
$$\mathbf{H}(\alpha) = \frac{\partial g}{\partial \alpha} = -\mathbf{L}_{\text{bg}} \odot \exp(-\boldsymbol{\Delta\tau}(\alpha)) \odot \left(\boldsymbol{\sigma} \odot N_{\text{total}} \cdot 10^{-6} L \cdot \text{AMF}\right)$$

is the Jacobian matrix (n_wavelengths × 1).

**Solution methods:**

1. **Gauss-Newton iteration:**
   $$\alpha^{(k+1)} = \alpha^{(k)} + \left(\mathbf{H}^T \mathbf{\Sigma}^{-1} \mathbf{H}\right)^{-1} \mathbf{H}^T \mathbf{\Sigma}^{-1} (\mathbf{y} - g(\alpha^{(k)}))$$
   
2. **Levenberg-Marquardt:**
   $$\alpha^{(k+1)} = \alpha^{(k)} + \left(\mathbf{H}^T \mathbf{\Sigma}^{-1} \mathbf{H} + \lambda \mathbf{I}\right)^{-1} \mathbf{H}^T \mathbf{\Sigma}^{-1} (\mathbf{y} - g(\alpha^{(k)}))$$
   where $\lambda$ is damping parameter (adjusted each iteration)
   
3. **Gradient descent:**
   $$\alpha^{(k+1)} = \alpha^{(k)} - \eta \frac{\partial J}{\partial \alpha}\bigg|_{\alpha^{(k)}}$$
   where $\eta$ is learning rate

**Initialization:**
- $\alpha^{(0)} = 0$ (assume background initially)
- Or use linearized estimate (see Section 7) for better starting point

**Convergence criteria:**
- $|\alpha^{(k+1)} - \alpha^{(k)}| < \epsilon_{\alpha}$ (parameter change)
- $|J(\alpha^{(k+1)}) - J(\alpha^{(k)})| < \epsilon_J$ (cost change)
- $\|\frac{\partial J}{\partial \alpha}\| < \epsilon_g$ (gradient norm)

Typical thresholds: $\epsilon_{\alpha} = 1$ ppm, $\epsilon_J = 10^{-6}$, $\epsilon_g = 10^{-4}$

**Computational cost:**
- Per iteration: $O(n^2)$ for covariance matrix-vector product
- Total: 5-20 iterations typical for convergence
- Can exploit sparse structure if $\mathbf{\Sigma}$ is diagonal or banded

---

## 7. Taylor Expanded Measurement Model (Useful for 3DVar)

### First-Order Taylor Expansion

Linearize the forward operator around a reference state $\alpha_0$ (typically 0 for background):

$$g(\alpha) \approx g(\alpha_0) + \mathbf{H}(\alpha_0) \cdot (\alpha - \alpha_0)$$

where $\mathbf{H}(\alpha_0) = \frac{\partial g}{\partial \alpha}\bigg|_{\alpha_0}$ is the **observation operator** (Jacobian).

**Units:**
- $g(\alpha)$: W/m²/sr/cm⁻¹ (radiance)
- $\mathbf{H}(\alpha_0)$: (W/m²/sr/cm⁻¹)/ppm (sensitivity)
- $(\alpha - \alpha_0)$: ppm (perturbation)

### Linearization at Background ($\alpha_0 = 0$)

**Forward model at background:**

$$g(0) = \mathbf{L}_{\text{bg}} \odot \exp(-\boldsymbol{\Delta\tau}(0)) = \mathbf{L}_{\text{bg}} \odot \exp(\mathbf{0}) = \mathbf{L}_{\text{bg}}$$

- **Units:** W/m²/sr/cm⁻¹
- **Physical meaning:** Expected radiance under background conditions (no plume)

**Jacobian at background:**

$$\mathbf{H} = \mathbf{H}(0) = \frac{\partial g}{\partial \alpha}\bigg|_{\alpha=0}$$

$$\mathbf{H} = \frac{\partial}{\partial \alpha}\left[\mathbf{L}_{\text{bg}} \odot \exp(-\boldsymbol{\Delta\tau}(\alpha))\right]\bigg|_{\alpha=0}$$

Using chain rule:

$$\mathbf{H} = \mathbf{L}_{\text{bg}} \odot \frac{\partial}{\partial \alpha}\left[\exp(-\boldsymbol{\Delta\tau}(\alpha))\right]\bigg|_{\alpha=0}$$

$$\mathbf{H} = \mathbf{L}_{\text{bg}} \odot \left[-\exp(-\boldsymbol{\Delta\tau}(0)) \cdot \frac{\partial \boldsymbol{\Delta\tau}}{\partial \alpha}\right]$$

Since $\boldsymbol{\Delta\tau}(0) = \mathbf{0}$ and $\exp(\mathbf{0}) = \mathbf{1}$:

$$\mathbf{H} = -\mathbf{L}_{\text{bg}} \odot \frac{\partial \boldsymbol{\Delta\tau}}{\partial \alpha}$$

$$\mathbf{H} = -\mathbf{L}_{\text{bg}} \odot \left(\boldsymbol{\sigma} \odot N_{\text{total}} \cdot 10^{-6} L \cdot \text{AMF}\right)$$

$$\boxed{\mathbf{H} = -\mathbf{L}_{\text{bg}} \odot \boldsymbol{\sigma} \odot N_{\text{total}} \cdot 10^{-6} L \cdot \text{AMF}}$$

- **Dimensions:** (n_wavelengths,) vector
- **Units:** (W/m²/sr/cm⁻¹)/ppm
- **Physical meaning:** Expected radiance change per unit VMR enhancement at each wavelength
- **Sign:** Negative (absorption reduces radiance)
- **Wavelength dependence:** Follows product of background radiance and absorption cross-section

**Typical magnitudes:**
- Strong lines, bright surface: $|\mathbf{H}| \approx 10^{-5}$ W/m²/sr/nm/ppm
- Moderate lines, moderate surface: $|\mathbf{H}| \approx 10^{-6}$ W/m²/sr/nm/ppm

### Linearized Observation Model

$$\mathbf{y} \approx \mathbf{L}_{\text{bg}} + \mathbf{H} \cdot \alpha + \boldsymbol{\epsilon}$$

- **Units:** W/m²/sr/cm⁻¹
- **Validity:** Small enhancements where $\Delta\tau(\alpha) \ll 1$
  - Quantitatively: $\alpha < 500$ ppm typically (depends on $\sigma$, $L$, AMF)
  - Equivalent to: fractional radiance change < 10%

**Rearranged form (innovation):**

Define the **innovation vector** (observation minus background):

$$\mathbf{d} = \mathbf{y} - \mathbf{L}_{\text{bg}}$$

- **Dimensions:** (n_wavelengths,)
- **Units:** W/m²/sr/cm⁻¹
- **Physical meaning:** Observed deviation from expected background radiance
- **Typical values:** 
  - No plume: $\mathbf{d} \approx \boldsymbol{\epsilon}$ (pure noise, ~$10^{-5}$ W/m²/sr/nm)
  - Weak plume: $|\mathbf{d}| \approx 10^{-5}$ to $10^{-4}$ W/m²/sr/nm
  - Strong plume: $|\mathbf{d}| \approx 10^{-4}$ to $10^{-3}$ W/m²/sr/nm

**Linearized model:**
$$\mathbf{d} \approx \mathbf{H} \cdot \alpha + \boldsymbol{\epsilon}$$

This is a **linear relationship** between innovation and enhancement.

**Matrix form:**
$$\underbrace{\mathbf{d}}_{n \times 1} = \underbrace{\mathbf{H}}_{n \times 1} \underbrace{\alpha}_{1 \times 1} + \underbrace{\boldsymbol{\epsilon}}_{n \times 1}$$

Since $\alpha$ is scalar, this is equivalent to:
$$d_i = H_i \cdot \alpha + \epsilon_i, \quad i = 1, \ldots, n$$

### 3DVar Formulation

**Three-Dimensional Variational Data Assimilation** combines observations with prior information to estimate atmospheric state.

**Cost function with background constraint:**

$$J(\alpha) = J_b(\alpha) + J_o(\alpha)$$

where:

**Background term:**
$$J_b(\alpha) = \frac{1}{2}(\alpha - \alpha_b)^T B^{-1} (\alpha - \alpha_b) = \frac{1}{2B}(\alpha - \alpha_b)^2$$

(since $\alpha$ is scalar, $B$ is scalar variance)

- $\alpha_b$: background (prior) estimate of enhancement
  - **Units:** ppm
  - **Typical value:** 0 (assume no plume a priori)
  - **Source:** Climatology, previous analysis, or model forecast
  
- $B$: background error variance
  - **Units:** ppm²
  - **Physical meaning:** Prior uncertainty in enhancement
  - **Typical value:** $(500 \text{ ppm})^2 = 2.5 \times 10^5$ ppm² (large uncertainty → weak constraint)
  - **Interpretation:** Standard deviation $\sigma_b = \sqrt{B} = 500$ ppm means we're uncertain about plume presence/strength

**Observation term:**
$$J_o(\alpha) = \frac{1}{2}(\mathbf{d} - \mathbf{H}\alpha)^T \mathbf{\Sigma}^{-1} (\mathbf{d} - \mathbf{H}\alpha)$$

- **Physical meaning:** Weighted squared misfit between observations and model predictions
- $\mathbf{\Sigma}$: observation error covariance (units: (W/m²/sr/cm⁻¹)²)

**Total cost function:**

$$J(\alpha) = \frac{1}{2B}(\alpha - \alpha_b)^2 + \frac{1}{2}(\mathbf{d} - \mathbf{H}\alpha)^T \mathbf{\Sigma}^{-1} (\mathbf{d} - \mathbf{H}\alpha)$$

**Units:** dimensionless (both terms normalized by respective covariances)

**Physical interpretation:**
- $J_b$: Penalizes deviations from prior estimate (regularization)
- $J_o$: Penalizes deviations from observations (data fitting)
- Balance determined by ratio of $B$ to $\mathbf{H}^T\mathbf{\Sigma}^{-1}\mathbf{H}$

**Optimal solution (analytical):**

Taking derivative:

$$\frac{\partial J}{\partial \alpha} = \frac{1}{B}(\alpha - \alpha_b) - \mathbf{H}^T \mathbf{\Sigma}^{-1} (\mathbf{d} - \mathbf{H}\alpha) = 0$$

Rearranging:

$$\frac{1}{B}(\alpha - \alpha_b) = \mathbf{H}^T \mathbf{\Sigma}^{-1} (\mathbf{d} - \mathbf{H}\alpha)$$

$$\frac{1}{B}\alpha - \frac{1}{B}\alpha_b = \mathbf{H}^T \mathbf{\Sigma}^{-1} \mathbf{d} - \mathbf{H}^T \mathbf{\Sigma}^{-1} \mathbf{H}\alpha$$

$$\left(\frac{1}{B} + \mathbf{H}^T \mathbf{\Sigma}^{-1} \mathbf{H}\right)\alpha = \mathbf{H}^T \mathbf{\Sigma}^{-1} \mathbf{d} + \frac{1}{B}\alpha_b$$

**Solution:**

$$\boxed{\hat{\alpha} = \frac{B \mathbf{H}^T \mathbf{\Sigma}^{-1} \mathbf{d} + \alpha_b}{\mathbf{H}^T \mathbf{\Sigma}^{-1} \mathbf{H} + B^{-1}}}$$

or equivalently:

$$\boxed{\hat{\alpha} = \alpha_b + \frac{B\mathbf{H}^T \mathbf{\Sigma}^{-1}(\mathbf{d} - \mathbf{H}\alpha_b)}{B\mathbf{H}^T \mathbf{\Sigma}^{-1}\mathbf{H} + 1}}$$

**For $\alpha_b = 0$ (no prior plume):**

$$\hat{\alpha} = \frac{B \mathbf{H}^T \mathbf{\Sigma}^{-1} \mathbf{d}}{B\mathbf{H}^T \mathbf{\Sigma}^{-1}\mathbf{H} + 1} = \frac{\mathbf{H}^T \mathbf{\Sigma}^{-1} \mathbf{d}}{\mathbf{H}^T \mathbf{\Sigma}^{-1}\mathbf{H} + B^{-1}}$$

**Units check:**
- Numerator: (W/m²/sr/cm⁻¹)/ppm × (W/m²/sr/cm⁻¹)⁻² × W/m²/sr/cm⁻¹ = ppm⁻¹
- Denominator: (W/m²/sr/cm⁻¹)/ppm × (W/m²/sr/cm⁻¹)⁻² × (W/m²/sr/cm⁻¹)/ppm + ppm⁻² = ppm⁻²
- Result: ppm⁻¹ / ppm⁻² = ppm ✓

**Posterior error variance:**

The uncertainty in the estimate is:

$$\sigma^2_{\alpha} = \left(\mathbf{H}^T \mathbf{\Sigma}^{-1} \mathbf{H} + B^{-1}\right)^{-1}$$

- **Units:** ppm²
- **Physical meaning:** Posterior variance (reduced from prior $B$)
- **Properties:**
  - $\sigma^2_{\alpha} < B$ (observations reduce uncertainty)
  - As observations improve ($\mathbf{\Sigma} \to 0$): $\sigma^2_{\alpha} \to 0$ (perfect constraint)
  - As prior becomes uninformative ($B \to \infty$): $\sigma^2_{\alpha} \to (\mathbf{H}^T \mathbf{\Sigma}^{-1}\mathbf{H})^{-1}$ (observation-only constraint)

**Standard deviation:**
$$\sigma_{\alpha} = \sqrt{\sigma^2_{\alpha}}$$

Typical values: 50-200 ppm for good observations, 200-500 ppm for noisy observations

---

## 8. Pedagogical Connection to Matched Filter

### From 3DVar to Matched Filter

The **matched filter** emerges as a special limiting case of 3DVar under specific assumptions about prior knowledge.

**Assumption 1: Uninformative prior** (infinite prior uncertainty)

Set $B \to \infty$, which implies:
- $B^{-1} \to 0$ (zero prior precision)
- **Physical meaning:** No prior knowledge about plume presence or strength
- **Mathematical effect:** Background term $J_b(\alpha)$ vanishes from cost function

**Assumption 2: Zero background** (no prior plume expectation)

Set $\alpha_b = 0$, which means:
- **Physical meaning:** Assume background conditions initially (no plume expected)
- Combined with $B^{-1} = 0$, this completely removes the background constraint

**Resulting cost function:**

$$J(\alpha) = \frac{1}{2}(\mathbf{d} - \mathbf{H}\alpha)^T \mathbf{\Sigma}^{-1} (\mathbf{d} - \mathbf{H}\alpha)$$

This is pure **weighted least squares** without regularization.

**3DVar solution with $B \to \infty$:**

$$\hat{\alpha} = \frac{\mathbf{H}^T \mathbf{\Sigma}^{-1} \mathbf{d}}{\mathbf{H}^T \mathbf{\Sigma}^{-1}\mathbf{H}}$$

This is the **generalized least squares (GLS)** or **maximum likelihood estimate** under Gaussian noise.

- **Units:** ppm
- **Interpretation:** Optimal linear unbiased estimator (BLUE) that minimizes mean squared error

### Matched Filter Formulation

**Define the target spectrum:**

The target is simply the Jacobian evaluated at background:

$$\mathbf{t} = \mathbf{H} = -\mathbf{L}_{\text{bg}} \odot \boldsymbol{\sigma} \odot N_{\text{total}} \cdot 10^{-6} L \cdot \text{AMF}$$

- **Dimensions:** (n_wavelengths,)
- **Units:** (W/m²/sr/cm⁻¹)/ppm
- **Physical meaning:** Expected radiance signature for 1 ppm methane enhancement
- **Alternative names:** Template, replica, filter, or signature

**For specific target enhancement $\Delta\text{VMR}_{\text{target}}$ (e.g., 1000 ppm):**

$$\mathbf{t}_{\Delta\text{VMR}} = \mathbf{H} \cdot \Delta\text{VMR}_{\text{target}}$$

- **Units:** W/m²/sr/cm⁻¹
- **Physical meaning:** Expected signature for this specific plume strength
- **Usage:** Can design filter for different assumed plume strengths

**Define the innovation:**

$$\mathbf{d} = \mathbf{y} - \mathbf{L}_{\text{bg}}$$

- **Units:** W/m²/sr/cm⁻¹
- **Physical meaning:** Observed radiance deviation from expected background
- **Sign convention:** Negative for absorption features

**Matched filter estimate:**

$$\hat{\alpha} = \frac{\mathbf{t}^T \mathbf{\Sigma}^{-1} \mathbf{d}}{\mathbf{t}^T \mathbf{\Sigma}^{-1} \mathbf{t}}$$

- **Units:** ppm
- **Interpretation:** Projection of observation onto target direction in whitened space

**Detection statistic (unnormalized):**

$$\delta = \mathbf{t}^T \mathbf{\Sigma}^{-1} \mathbf{d} = \mathbf{t}^T \mathbf{\Sigma}^{-1} (\mathbf{y} - \mathbf{L}_{\text{bg}})$$

- **Units:** (W/m²/sr/cm⁻¹)/ppm × (W/m²/sr/cm⁻¹)⁻² × W/m²/sr/cm⁻¹ = ppm⁻¹
  - Can be rescaled to be dimensionless by multiplying by a reference VMR
- **Physical meaning:** Weighted correlation between observed deviation and expected signature
- **Properties:**
  - $\delta > 0$: Evidence for plume (recall $\mathbf{t} < 0$ and expect $\mathbf{d} < 0$ for plumes)
  - $\delta = 0$: No plume signal
  - $\delta < 0$: Anti-correlation (unlikely for absorption)

**Relationship between estimate and statistic:**

$$\hat{\alpha} = \frac{\delta}{\mathbf{t}^T \mathbf{\Sigma}^{-1} \mathbf{t}}$$

The denominator normalizes the statistic to give VMR units.

### White Noise Simplification

**For white (uncorrelated, equal variance) noise:**

$$\mathbf{\Sigma} = \sigma^2_{\text{noise}} \mathbf{I}$$

where $\sigma^2_{\text{noise}}$ is the noise variance (assumed equal at all wavelengths).

**Estimate simplifies to:**

$$\hat{\alpha} = \frac{\mathbf{t}^T \mathbf{d}}{\mathbf{t}^T \mathbf{t}} = \frac{\mathbf{t}^T (\mathbf{y} - \mathbf{L}_{\text{bg}})}{\|\mathbf{t}\|^2}$$

- **Units:** ppm
- **Interpretation:** Simple correlation divided by target power
- **Computational cost:** $O(n)$ (inner products only, no matrix inversion)

**Detection statistic:**

$$\delta = \frac{1}{\sigma^2_{\text{noise}}} \mathbf{t}^T (\mathbf{y} - \mathbf{L}_{\text{bg}})$$

- **Units:** dimensionless (if $\sigma_{\text{noise}}$ has radiance units)
- **Physical meaning:** SNR-like quantity

### Normalized Matched Filter (Unit Target)

**Normalize target to unit L2 norm:**

$$\mathbf{t}_{\text{unit}} = \frac{\mathbf{t}}{\|\mathbf{t}\|} = \frac{\mathbf{t}}{\sqrt{\mathbf{t}^T \mathbf{t}}}$$

- **Dimensions:** (n_wavelengths,)
- **Units:** Technically (W/m²/sr/cm⁻¹)/ppm, but with $\|\mathbf{t}_{\text{unit}}\| = 1$ (dimensionless in practice)
- **Physical meaning:** Unit direction vector pointing towards plume signature

**Detection statistic (normalized):**

$$\delta_{\text{norm}} = \mathbf{t}_{\text{unit}}^T (\mathbf{y} - \mathbf{L}_{\text{bg}})$$

- **Units:** W/m²/sr/cm⁻¹ (or can be made dimensionless by dividing by typical radiance scale)
- **Physical meaning:** Projection of innovation onto unit target direction
- **Interpretation:** Magnitude of deviation in target direction

**For white noise:**

$$\delta_{\text{norm}} = \frac{1}{\|\mathbf{t}\|} \mathbf{t}^T (\mathbf{y} - \mathbf{L}_{\text{bg}})$$

**Threshold for detection:**

Declare plume detected if:

$$\delta_{\text{norm}} > \lambda \cdot \sigma_{\text{eff}}$$

where:

- $\lambda$: **threshold multiplier**
  - **Units:** dimensionless
  - **Typical values:** 
    - $\lambda = 3$: 3σ detection (0.13% false alarm rate)
    - $\lambda = 4$: 4σ detection (0.003% false alarm rate)
    - $\lambda = 5$: 5σ detection (0.00003% false alarm rate)
  - **Choice depends on**: Acceptable false alarm rate, prior probability of plumes
  
- $\sigma_{\text{eff}}$: **effective noise standard deviation** in target direction
  - **Units:** W/m²/sr/cm⁻¹ (same as radiance)
  - **Definition:** $\sigma_{\text{eff}} = \sqrt{\mathbf{t}_{\text{unit}}^T \mathbf{\Sigma} \mathbf{t}_{\text{unit}}}$
  - **Physical meaning:** RMS noise projected onto target direction
  - **For white noise:** $\sigma_{\text{eff}} = \sigma_{\text{noise}}$
  - **For colored noise:** Accounts for noise anisotropy

**False alarm probability:**

Under null hypothesis ($\alpha = 0$, no plume):

$$P_{\text{FA}} = P(\delta_{\text{norm}} > \lambda \sigma_{\text{eff}} | H_0) = 1 - \Phi(\lambda)$$

where $\Phi$ is the standard normal CDF.

Values:
- $\lambda = 3$: $P_{\text{FA}} = 0.0013$ (1.3 per 1000 pixels)
- $\lambda = 5$: $P_{\text{FA}} = 2.9 \times 10^{-7}$ (essentially zero)

**Missed detection probability:**

Under alternative hypothesis ($\alpha = \alpha_{\text{true}}$, plume present):

$$P_{\text{MD}} = P(\delta_{\text{norm}} < \lambda \sigma_{\text{eff}} | H_1) = \Phi\left(\lambda - \frac{\mu_{\text{signal}}}{\sigma_{\text{eff}}}\right)$$

where $\mu_{\text{signal}} = \mathbf{t}_{\text{unit}}^T \mathbf{H} \alpha_{\text{true}} = \|\mathbf{t}\| \alpha_{\text{true}}$ is the expected signal.

This depends on:
- True plume strength $\alpha_{\text{true}}$
- Target spectrum magnitude $\|\mathbf{t}\|$
- Noise level $\sigma_{\text{eff}}$

### Key Insights and Connections

**1. Matched filter = Maximum likelihood** under specific assumptions

- **Assumption**: Gaussian noise, linear forward model
- **Equivalence**: MLE = GLS = Matched filter (without prior constraint)
- **Optimality**: Minimizes mean squared error among linear estimators

**2. Target = Jacobian** at linearization point

- $\mathbf{t} = \mathbf{H}(0) = \frac{\partial g}{\partial \alpha}\bigg|_{\alpha=0}$
- Linearization provides the template for detection
- Represents sensitivity of observations to state parameter

**3. Innovation = Mean subtraction**

- $\mathbf{d} = \mathbf{y} - \mathbf{L}_{\text{bg}}$
- Removes expected background signal
- Isolates anomaly/plume component
- Critical preprocessing step

**4. Covariance weighting = Optimal combination**

- $\mathbf{\Sigma}^{-1}$ down-weights noisy wavelengths
- Accounts for spectral correlations
- Whitens the residuals (makes errors i.i.d.)
- White noise special case: all wavelengths weighted equally

**5. Linear approximation required**

- Valid only for $\Delta\tau < 0.1$ (typically $\alpha < 500-1000$ ppm)
- Violations cause:
  - Biased estimates (underestimation due to saturation)
  - Reduced sensitivity
  - Suboptimal detection
- For strong plumes: must use nonlinear model (Section 6)

**6. Computational efficiency**

- Matched filter: $O(n^2)$ (if $\mathbf{\Sigma}^{-1}$ precomputed) or $O(n)$ (white noise)
- Nonlinear inversion: $O(kn^2)$ where $k$ is number of iterations (typically 10-50)
- Speed advantage: 10-100× faster for matched filter
- Trade-off: Accuracy vs. computational cost

**7. Extensions**

- **Adaptive matched filter**: Estimate $\mathbf{\Sigma}$ locally from data
- **Constrained matched filter**: Add non-negativity constraint ($\alpha \geq 0$)
- **Multi-target**: Detect multiple gases simultaneously
- **Spatial regularization**: Smoothness constraints for neighboring pixels

### Connection Summary

$$\boxed{
\begin{aligned}
\text{Nonlinear Model} &\xrightarrow{\text{Taylor expand at } \alpha=0} \text{Linearized Model: } \mathbf{y} \approx \mathbf{L}_{\text{bg}} + \mathbf{H}\alpha + \boldsymbol{\epsilon} \\
&\xrightarrow{\text{Define } \mathbf{d} = \mathbf{y} - \mathbf{L}_{\text{bg}}} \text{Innovation Model: } \mathbf{d} \approx \mathbf{H}\alpha + \boldsymbol{\epsilon} \\
&\xrightarrow{\text{Add prior}} \text{3DVar: } J(\alpha) = \frac{1}{2B}(\alpha - \alpha_b)^2 + \frac{1}{2}(\mathbf{d}-\mathbf{H}\alpha)^T\mathbf{\Sigma}^{-1}(\mathbf{d}-\mathbf{H}\alpha) \\
&\xrightarrow{B \to \infty, \alpha_b = 0} \text{GLS/MLE: } \hat{\alpha} = \frac{\mathbf{H}^T\mathbf{\Sigma}^{-1}\mathbf{d}}{\mathbf{H}^T\mathbf{\Sigma}^{-1}\mathbf{H}} \\
&\xrightarrow{\text{Identify } \mathbf{t} = \mathbf{H}} \text{Matched Filter: } \hat{\alpha} = \frac{\mathbf{t}^T\mathbf{\Sigma}^{-1}\mathbf{d}}{\mathbf{t}^T\mathbf{\Sigma}^{-1}\mathbf{t}} \\
&\xrightarrow{\text{Normalize}} \text{Normalized MF: } \delta = \mathbf{t}_{\text{unit}}^T \mathbf{d}
\end{aligned}
}$$

The matched filter is the **optimal linear detector** when:
- Signal is a known spectral signature
- Embedded in Gaussian noise with known covariance
- Forward model is approximately linear
- No prior information (uninformative prior)

For operational methane detection, matched filter serves as:
- **Fast screening**: Identify candidate plume pixels
- **Initial estimate**: Provide starting point for nonlinear inversion
- **Detection map**: Binary classification of plume presence
- **Quantitative estimate**: Approximate VMR for weak-to-moderate plumes

---
