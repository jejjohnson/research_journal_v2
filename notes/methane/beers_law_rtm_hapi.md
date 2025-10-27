---
title: Beer-Lambert's Law - HAPI
subject: Methane
short_title: RTM HAPI
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

# Introduction: HAPI as a Radiative Transfer Model (RTM)

For your goal of gas retrieval, you need a "forward model"—a tool that simulates a spectrum given a set of atmospheric conditions (like gas concentration, temperature, pressure). This forward model is your Radiative Transfer Model (RTM).

**HAPI (HITRAN Application Programming Interface)** is a powerful Python library that functions as the core of an RTM.

**ELI5 (Explain Like I'm 5):** 🧠 Think of the HITRAN database as a giant, hyper-detailed "fingerprint" library for every gas. HAPI is the expert "forensic analyst" that knows how to read this library. You give HAPI a "case" (a specific temperature, pressure, and gas amount), and it generates the exact fingerprint (the spectrum) you should see.

**The Retrieval Goal:** Your retrieval problem is the reverse. You have a "mystery fingerprint" (your measured transmittance spectrum) and you ask HAPI to generate thousands of "known fingerprints" by changing the `gas amount` parameter until the HAPI-generated spectrum _perfectly matches_ your measurement. The `gas amount` that creates the match is your retrieved concentration.


This report will walk through the step-by-step logic of how HAPI builds that spectrum, from the fundamental physics to the practical code.

## 1. The "Line-by-Line" (LBL) Method

This is the core philosophy behind HAPI and the most accurate RTM method.

**ELI5:** A gas's absorption spectrum isn't a smooth band. It's a "forest" made of thousands of individual "trees" 🌳 (the absorption lines). Instead of just estimating the size of the forest, the LBL method meticulously calculates the size, shape, and position of _every single tree_ and adds them all up.
 
**Theory (Continuous Equation):** The total absorption coefficient $\alpha$ at any wavenumber $\nu$ is the linear sum of the absorption coefficients from _all_ ($i$) nearby lines.
    
$$ \alpha(\nu) = \sum_{i} \alpha_i(\nu)$$
**HAPI Implementation (Discretized):** HAPI does this sum automatically. When you call a function like `hapi.absorptionCrossSection_Voigt`, it fetches all the lines in your specified range and performs this summation across your `WavenumberGrid` (a NumPy array).
    
**Assumptions:**
- **Linearity:** The total absorption is the simple sum of individual line absorptions. This is an excellent assumption, except in _extremely_ high-pressure cases (which HAPI can handle with "line mixing" functions, but we'll ignore that for now).  
- **Database Completeness:** We assume the HITRAN database has correctly cataloged _all_ the important lines. For main gases like CH₄, this is a very good assumption.
        

---
## 2. Line Intensity ($S_i(T)$)

This is the first of two components for every line. It defines the "strength" or "height" of the line.

**ELI5:** This is the "volume" of a single note 🎵. This volume changes with temperature. A hot gas "plays" some notes (lines) louder and others softer than a cold gas.
    
**Theory (Continuous Equation):** HAPI scales the reference intensity $S_{ref}$ (from HITRAN, at $T_{ref}=296$ K) to your desired temperature $T$ using this equation from statistical mechanics:
    
$$
S_i(T) = S_i(T_{ref}) \cdot \frac{Q(T_{ref})}{Q(T)} \cdot \frac{\exp(-c_2 E_i''/T)}{\exp(-c_2 E_i''/T_{ref})} \cdot \frac{[1 - \exp(-c_2 \nu_{0,i}/T)]}{[1 - \exp(-c_2 \nu_{0,i}/T_{ref})]}
$$

 **HAPI Implementation:** This complex calculation is done _internally_ when you pass the $T$ parameter.
    
```python
# T is part of the 'Environment' dictionary
env = {'T': 300.0, 'p': 1.0}
# HAPI automatically scales all S_ref from 296K to 300K
sigma = hapi.absorptionCrossSection_Voigt(..., Environment=env) 
```
    
**Variables & Units:**
- $S_i(T)$: Line intensity at temperature $T$. **Units:** $\text{cm}^{-1}/(\text{molecule} \cdot \text{cm}^{-2})$.
- $S_i(T_{ref})$: Line intensity from HITRAN. **Units:** $\text{cm}^{-1}/(\text{molecule} \cdot \text{cm}^{-2})$.
- $Q(T)$: The **Total Internal Partition Sum**. A unitless number HAPI calculates that describes how molecules are "partitioned" among all their energy states at $T$.    
- $E_i''$: The lower-state energy of the transition (from HITRAN). **Units:** $\text{cm}^{-1}$.    
- $\nu_{0,i}$: The central wavenumber of the line (from HITRAN). **Units:** $\text{cm}^{-1}$.  
- $c_2$: The second radiation constant ($hc/k_B \approx 1.4388$). **Units:** $\text{K} \cdot \text{cm}$.
        
**Assumptions:**
- **Local Thermodynamic Equilibrium (LTE):** We assume the gas is in a stable thermal state where the energy distribution is described by the Boltzmann distribution. This is true for almost all of the Earth's lower and middle atmosphere.
        
---
## 3. Line Shape Function ($f_i(\nu)$)

This is the second component. It defines the "shape" or "width" of the line.

**ELI5:** A real musical note isn't just one pure frequency. It's a bit "fuzzy." This function describes the shape of that fuzziness. The fuzziness comes from two things:
1. **Doppler Broadening:** Molecules moving away from you sound lower-pitched (red-shift), and those moving toward you sound higher-pitched (blue-shift). This "smears" the line into a **Gaussian** (bell curve) shape.
2. **Pressure Broadening:** Molecules are constantly "bumping" into each other. These collisions interrupt the absorption, smearing the line into a **Lorentzian** shape. More pressure = more bumps = wider, fuzzier line.
        
**Theory (Continuous Equation):** The line shape function $f$ is not a single simple equation. It's a _profile_ whose _width_ is determined by the Doppler half-width ($\gamma_D$) and the Pressure (Lorentzian) half-width ($\gamma_L$).
- $\gamma_D \propto \nu_0 \sqrt{T}$ (Depends on $T$)    
- $\gamma_L \propto P \cdot (T_{ref}/T)^n \cdot (\text{VMR}_{\text{self}}\gamma_{\text{self}} + \text{VMR}_{\text{air}}\gamma_{\text{air}})$ (Depends on $P$, $T$, and concentration)
        
**HAPI Implementation:** HAPI calculates these widths automatically using $T$, $P$, and the `mole_fractions` dictionary you provide. This is why passing the concentration (VMR) is so important—it correctly balances self-broadening ($\gamma_{\text{self}}$, CH₄-CH₄ collisions) and air-broadening ($\gamma_{\text{air}}$, CH₄-Air collisions).
    
```Python
env = {'T': T, 'p': P_total, 'mole_fractions': {'CH4': VMR_CH4}}
sigma = hapi.absorptionCrossSection_Voigt(..., Environment=env)
```
    

**Assumptions:** The broadening mechanisms (Doppler, Pressure) are independent.
        

---
## 4. The Voigt Profile

This is the "real" line shape, which combines the two broadening effects.

**ELI5:** The Voigt profile is simply what you get when you combine the Gaussian shape (from Doppler) and the Lorentzian shape (from Pressure) together.
    
**Theory (Continuous Equation):** The Voigt profile $f_V$ is the **convolution** of the Gaussian ($G$) and Lorentzian ($L$) functions. This is a complex integral.
$$f_V(\nu) = (G * L)(\nu) = \int_{-\infty}^{\infty} G(\nu') \cdot L(\nu - \nu') \cdot d\nu'$$
**HAPI Implementation:** This is HAPI's specialty. The `_Voigt` in `absorptionCrossSection_Voigt` means HAPI is using highly optimized numerical algorithms (like the Humlíček algorithm) to calculate this difficult convolution for every line at every point in your `WavenumberGrid`.

**Assumptions.** The line shape is fully described by this convolution. This is an excellent assumption for most applications.


---
## 5. Absorption Cross-Section ($\sigma$)

This is the first major output you calculate. It combines Intensity and Shape into a single, per-molecule property.

**ELI5:** The "cross-section" is the **"target size" of a single molecule** 🎯. It combines the "strength" ($S$) and the "shape" ($f$) of all its lines. A molecule with a large cross-section is very effective at blocking light.
    
**Theory (Continuous Equation):** This is the LBL summation (Step 1) of the Intensity (Step 2) multiplied by the Shape (Step 4) for each line.

$$\sigma(\nu) = \sum_{i} S_i(T) \cdot f_{V,i}(\nu)$$
**HAPI Implementation (Discretized):** This is the main HAPI function call.
    
```Python
# nu is a NumPy array, e.g., np.arange(2900, 3100, 0.01)
# sigma will be a NumPy array of the same size as nu

# Get absorption cross-section per molecule
nu, sigma = hapi.absorptionCoefficient_Voigt(
    SourceTables='CH4',
    WavenumberGrid=nu,
    Environment={'T': T, 'p': P_total},
    Diluent={'air': 1.0 - VMR_CH4, 'self': VMR_CH4},
    HITRAN_units=True  # Returns cm²/molecule
)
```
    
**Variables & Units:**
- $\sigma(\nu)$: Absorption Cross-Section. **Units:** $\text{cm}^2 / \text{molecule}$.    
- `WavenumberGrid` (`nu`): The array of wavenumbers. **Units:** $\text{cm}^{-1}$.
- `Environment`: Dictionary of scalar $T$ (**K**), $P$ (**atm**), and `mole_fractions` (unitless VMR).

---
## 6. Number Density ($N$)

Now that we know the "per-molecule" target size, we need to know _how many_ molecules there are.

**ELI5:** This is simply counting how many molecules are packed into a small box (a cubic centimeter). More pressure or colder temperatures will pack more molecules into the same box.
    
**Theory (Continuous Equation):** From the **Ideal Gas Law**, $N = P / (k_B T)$. We calculate the _total_ number density $N_{\text{total}}$ (all air) and then find the CH₄-specific number density $N_{\text{CH4}}$ using the concentration.
    
$$\\ \\ N\_{\text{total}} = \frac{P\_{\text{total}}}{k\_B T}$$
$$
N_{\text{CH4}} = N_{\text{total}} \cdot \text{VMR}_{\text{CH4}}
$$
    
    
**HAPI Implementation (Discretized):**
    
```Python
N_total = hapi.numberDensity(P_total, T)
N_CH4 = N_total * VMR_CH4 
```
    
 **Variables & Units:**
- $N$: Number Density. **Units:** $\text{molecules} / \text{cm}^3$.    
- $P_{\text{total}}$: Total pressure. **Units:** $\text{atm}$ (for the HAPI function).   
- $T$: Temperature. **Units:** $\text{K}$.  
- $k_B$: Boltzmann constant.    
- $\text{VMR}_{\text{CH4}}$: Volume Mixing Ratio (e.g., $1.8 / 1e6$). **Unitless**.
        
**Assumptions:**
- The atmosphere behaves as an **Ideal Gas**. This is an extremely good assumption for Earth's atmosphere.
        
---
## 7. Absorption Coefficient ($\alpha$)

This is the key physical property of the _bulk gas_, not just a single molecule.

**ELI5:** If $\sigma$ is the "target size" of _one_ molecule, $\alpha$ is the _total_ "target size" of _all_ molecules in the box. It's the "per-molecule" size ($\sigma$) times "how many molecules" ($N$).
    
**Theory (Continuous Equation):**
$$\alpha(\nu) = \sigma(\nu) \cdot N_{\text{CH4}}$$
    
**HAPI Implementation (Discretized):** This is a simple NumPy array-scalar multiplication.

```Python
# alpha is a NumPy array, same size as sigma
alpha = sigma * N_CH4
```
    
 **Variables & Units:**
- $\alpha(\nu)$: Absorption Coefficient. **Units:** $\text{cm}^{-1}$.  
- This unit is crucial. It means "the fraction of light absorbed _per centimeter_ of travel." 
- $\sigma(\nu)$: $\text{cm}^2 / \text{molecule}$.    
- $N_{\text{CH4}}$: $\text{molecules} / \text{cm}^3$.   
- Units check: $(\text{cm}^2 / \text{molecule}) \times (\text{molecules} / \text{cm}^3) = \text{cm}^2 / \text{cm}^3 = \text{cm}^{-1}$. It works!
        

---
## 8. Path Length ($L$) & Air Mass Factor (AMF)

Now we know _how much_ the gas absorbs per cm. Next, we need to know _how many centimeters_ the light travels through.

**ELI5:** This is the total distance the light travels through your gas layer. If you look straight down (VZA=0°) at a 1 km thick layer, the path is 1 km. If you look at an angle (e.g., VZA=60°), the light has to "slant" through the layer, so the path is _longer_ (2 km). The **Air Mass Factor (AMF)** is the multiplier (in this case, 2) that accounts for this slant.

**Theory (Continuous Equation):** For a simple remote sensing case (sunlight comes in, bounces off the ground, goes to the satellite), the total path is the sum of the "in" path and the "out" path.
    
$$
\text{AMF} \approx \frac{1}{\cos(\text{SZA})} + \frac{1}{\cos(\text{VZA})}
$$

$$
L = L_{\text{vert}} \cdot \text{AMF}
$$    
**HAPI Implementation (Discretized):** This is standard Python/NumPy math.
    
```Python
SZA_rad = np.deg2rad(SZA)
VZA_rad = np.deg2rad(VZA)
AMF = (1.0 / np.cos(SZA_rad)) + (1.0 / np.cos(VZA_rad))
L = L_vert * AMF 
```
    
**Variables & Units:**
- $L$: Total slant path length. **Units:** $\text{cm}$.
- $L_{\text{vert}}$: The vertical thickness of your gas layer. **Units:** $\text{cm}$.
- `SZA`, `VZA`: Solar and Viewing Zenith Angles. **Units: degrees**.
- `AMF`: Air Mass Factor. **Unitless**.
        
**Assumptions:**    
- **Plane-Parallel Atmosphere:** This assumes the Earth is flat. This is a very common simplification that works well for zenith angles $< 75^\circ$. It breaks down near the horizon.
- **Single Layer:** We assume the _entire_ path has one constant $T$, $P$, and VMR. This is a major simplification. Real RTMs for retrieval split the atmosphere into many layers (e.g., 40) and do this calculation for each layer.
        
---
## 9. Transmittance ($T$)

This is the final simulated spectrum, the "fingerprint" you compare against your measurement.

**ELI5:** Transmittance is the fraction of light (from 0 to 1) that makes it through the gas. If the absorption coefficient  (the "blockiness") is high, or the path  (the "distance") is long, the transmittance will be low.

**Theory (Continuous Equation):** This is the **Beer-Lambert Law**.
    
$$\\ \\ T(\nu) = \exp\left(-\alpha(\nu) \cdot L\right)$$
    
**HAPI Implementation (Discretized):** This is a simple NumPy exponential function.
    
```Python
# tau is your final transmittance spectrum, a NumPy array
tau = np.exp(-alpha * L)
```
    
**Variables & Units:**
- $T(\nu)$: Transmittance. **Unitless** (a ratio from 0 to 1).
- $\alpha(\nu)$: Absorption Coefficient (array). **Units:** $\text{cm}^{-1}$.
- $L$: Total slant path length (scalar). **Units:** $\text{cm}$.
- The exponent $\alpha \cdot L$ is **unitless**: $(\text{cm}^{-1}) \cdot (\text{cm})$.
        
**Assumptions:**
- **Absorption Only:** This model _only_ accounts for light lost to absorption. It **completely ignores scattering** (by air molecules or aerosols/clouds). This is a _major_ simplification. Your real measured spectrum _will_ have scattering effects.
- **No Thermal Emission:** This calculates light _passing through_. It does not calculate light _emitted by_ the warm gas itself (which is what `hapi.radianceSpectrum` is for).
        

---
## Summary: The Full Algorithm for Retrieval

To run your "forward model" and simulate a spectrum for retrieval, you follow this exact chain of logic:

1. **Define Inputs:**
    - `VMR_CH4` (Your "guess" parameter)
    - `T`, `P_total` (Assumed atmospheric state)
    - `L_vert` (Assumed layer thickness)
    - `SZA`, `VZA` (Known geometry)
    - `nu` (Your instrument's spectral grid)
        
2. **Run HAPI & Physics:**
    - `sigma = hapi.absorptionCrossSection_Voigt(...)` (Calculates Steps 1-5)
    - `N_total = hapi.numberDensity(...)` (Step 6a)
    - `N_CH4 = N_total * VMR_CH4` (Step 6b)
    - `alpha = sigma * N_CH4` (Step 7)    
    - `L = L_vert * AMF(...)` (Step 8)
    - `tau = np.exp(-alpha * L)` (Step 9)
        

Your retrieval algorithm will then compare this `tau` to your measured spectrum, and if they don't match, it will go back to Step 1 and try a new `VMR_CH4`.
