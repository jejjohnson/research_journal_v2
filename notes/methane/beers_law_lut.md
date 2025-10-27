---
title: Beer-Lambert's Law - LUT
subject: Methane
short_title: RTM LUT
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

**Inputs**
- Target Gas Concentration - CH4, CO2, NO2, H2O

**Parameters**
- Viewing Geometry - SZA, VZA, RAA
- Atmospheric Profiles - Temperature, Pressure
- Surface Variables - Surface Pressure, Surface Albedo

**Output**
- Absorption Cross-Section

**Derived Outputs**
- Absorption Coefficient
- Transmittance
- Spectral Radiance


---
## 1. Background: The Need for a Look-Up Table (LUT)

### The Problem: Line-by-Line (LBL) is Too Slow

A "Forward Model" based on Line-by-Line (LBL) calculations is extremely accurate. However, it is also computationally "expensive" (slow). A single satellite image can contain millions of pixels, and a retrieval algorithm may need to run this complex forward model dozens of times _per pixel_ to find the best-fit gas concentration. This is not computationally feasible for processing large amounts of data in a timely manner.

**ELI5:** 🧠 Your LBL model is like a master chef cooking a complex meal from scratch every time you order. A Look-Up Table (LUT) is like a high-end restaurant that has _pre-cooked_ all the individual ingredients (sauces, proteins, vegetables) and can assemble them into a final dish in seconds.

A **Look-Up Table (LUT)** is the solution. It is a large, pre-calculated database of RTM results. The retrieval process then becomes a simple, ultra-fast _interpolation_ within this table.

### The "Universal" Challenge

The goal is a "universal" LUT that can serve all different types of satellites, each with unique requirements:
- **Hyperspectral (e.g., TROPOMI, IASI, EMIT):** Needs the spectrum at very high resolution.
- **Multispectral (e.g., Sentinel-2, Landsat):** Needs the spectrum averaged over a few, _wide_ spectral bands.
- **Polar-Orbiting (e.g., TROPOMI):** Observes a spot at (roughly) the same local time, but the Viewing Zenith Angle (VZA) changes across the instrument's "swath."
- **Geostationary (e.g., GOES, GEMS):** Observes the same spot, so VZA is constant, but Solar Zenith Angle (SZA) changes throughout the day.

A "universal" LUT must be generated at the _highest resolution required_ and must _decouple_ the atmospheric state from the viewing geometry.

---
## 2. Formulation: The Theory Behind the LUT

### Step 1: From a Single Layer to a Multi-Layer Atmosphere

The "single layer" model (assuming one T, P, and VMR for the whole atmosphere) is a major simplification. To be accurate, we must discretize the atmosphere into multiple vertical layers (e.g., 20-40 layers), each with its own $T_l$, $P_l$, and $\text{VMR}_l$.

**Theory:** The total transmittance is the _product_ of the transmittance of each individual layer ($l$).
$$
T_{\text{total}}(\nu) = 
\prod_{l=1}^{N_{\text{layers}}} T_l(\nu) = 
\prod_{l=1}^{N_{\text{layers}}} \exp\left(-\alpha_l(\nu) \cdot L_l\right)
$$
This is mathematically equivalent to _summing_ the **Optical Depth (**$\tau$**)** of each layer, where $\tau = \alpha \cdot L$.    
$$T_{\text{total}}(\nu) = \exp\left( - \sum_{l=1}^{N_{\text{layers}}} \tau_l(\nu) \right)$$
**The Key Insight:** We can pre-calculate the **Vertical Optical Depth** ($\tau_{\text{vert}, l}$) for each layer. This value depends only on the layer's $T_l$, $P_l$, $\text{VMR}_l$, and vertical thickness ($\Delta z_l$). It is **independent of geometry**. The "slant" optical depth ($\tau_l$) seen by the satellite is simply this vertical value multiplied by a geometric Air Mass Factor (AMF): $\tau_l = \tau_{\text{vert}, l} \times \text{AMF}_l$.
    
---
### Step 2: Defining the LUT Dimensions (The "Axes")

A LUT is an N-dimensional grid. We must choose our axes, which are the parameters that vary in the real world and affect the spectrum.

1. **Atmospheric Profiles (**$T(z)$**,** $P(z)$**,** $\text{VMR}_{\text{H2O}}(z)$**):** A full profile at 40 levels is an "infinite-dimensional" problem.
    - **Solution:** Use **Principal Component Analysis (PCA)** on a large ensemble of representative atmospheric profiles (from weather models). Instead of storing $T_l$ at 40 layers, you store the _first 3-5 PCA coefficients_ ($c_{T,1}, c_{T,2}, c_{T,3}$) that can reconstruct the entire profile.
        
2. **Surface Parameters:**
    - **Surface Pressure (**$P_{\text{surf}}$**):** This is a key variable, as it defines the altitude of the surface and how many atmospheric layers are "seen" below the sensor.
    - **Surface Albedo (**$A$**):** The reflectivity of the ground.
        
3. **Target Gas Concentration (**$\text{VMR}_{\text{CH4}}$**):**
    - This is the parameter we want to retrieve. We must simulate a range of realistic values. This is often done as a _scaling factor_ on a background profile.
        
4. **Viewing Geometry (SZA, VZA, RAA):**
    - **The "Universal" Trick:** To make the LUT truly universal, you **DO NOT** use geometry as LUT dimensions. You build a LUT of _atmospheric properties_ only ($\tau_{\text{vert}, l}$) and apply geometry _at runtime_. This decouples the physics from the observation.
        
---
## 3. Building the LUT: The Offline Generation

This is the slow, one-time computation.

### 1. Define Grids with Reasonable Parameters

You must define the grid points for each LUT dimension. The number of points is a trade-off between accuracy (more points) and LUT size (fewer points).
- **`T` Profile (PCA):** e.g., 5 grid points for 1st PCA coefficient, 3 for 2nd.
- **`P_surf` (Surface Pressure):** e.g., 10 levels from 1050 hPa to 600 hPa.
- **`VMR_H2O` Profile (PCA):** e.g., 5 grid points for 1st PCA coefficient.
- **`VMR_CH4` Scaling Factor:** e.g., 20 points from 0.5 (background) to 2.5 (plume).
- **`Surface Albedo`:** e.g., 10 points from 0.0 (dark) to 1.0 (bright).
    
### 2. Iterate and Store

You then write a script that iterates through _every single combination_ of these grid points. For each combination:
1. **Reconstruct:** Reconstruct the full atmospheric profiles ($T(z), P(z)$, VMRs) from the PCA coefficients and surface pressure.
2. Iterate Layers: For each layer $l$ in the profile (from top to bottom):
    a. Get the layer's $T_l, P_l, \text{VMRs}$.
    b. Run HAPI (Steps 1-7 from the previous report) to calculate the high-resolution absorption coefficient $\alpha_l(\nu)$.
    c. Calculate the Vertical Optical Depth (VOD) for that layer: $\tau_{\text{vert}, l}(\nu) = \alpha_l(\nu) \cdot \Delta z_l$ (where $\Delta z_l$ is the vertical thickness of the layer in $\text{cm}$).
3. **Store in LUT:** Save the resulting _vector_ of VODs $[\tau_{\text{vert}, 1}(\nu), \tau_{\text{vert}, 2}(\nu), \dots, \tau_{\text{vert}, N}(\nu)]$ at this specific N-dimensional grid location.    

The final LUT's "value" for any given atmospheric state is an array of high-resolution VODs, one for each atmospheric layer.


---
## 4. Naive Application: Using the LUT Per-Pixel

This is the fast, online process done for every pixel during retrieval.

### 1. Get Pixel Inputs

Get the pixel's `SZA`, `VZA`, `RAA` (from satellite geometry), `P_surf` (from a Digital Elevation Model), and the best-guess atmospheric profiles ($T, \text{VMR}_{\text{H2O}}$) from a weather forecast model (e.g., ECMWF).

### 2. Interpolate LUT

1. Convert the pixel's $T$ and $\text{VMR}_{\text{H2O}}$ profiles into their PCA coefficients.
2. Perform a rapid N-dimensional interpolation in the LUT (using $P_{\text{surf}}$, $T$ PCA, $\text{VMR}_{\text{H2O}}$ PCA, etc.) to get the high-resolution VOD vectors $[\tau_{\text{vert}, l}(\nu)]$ for that pixel's atmosphere.
3. This is done for each grid point of your "guess" `VMR_CH4` scaling factor, giving you a set of potential VODs.
    

### 3. Apply Geometry

1. Calculate the Air Mass Factor (AMF) for each layer $l$: $\text{AMF}_l \approx 1/\cos(\text{SZA}) + 1/\cos(\text{VZA}_l)$.
2. Calculate the total slant optical depth for the _entire_ atmosphere:

$$
\tau_{\text{total}}(\nu) = \sum_{l=1}^{N_{\text{layers}}} \tau_{\text{vert}, l}(\nu) \cdot \text{AMF}_l
$$


---
### 4. Calculate Final Spectrum & Apply Instrument Model

1. Calculate the high-resolution transmittance: $T_{\text{high\_res}}(\nu) = \exp(-\tau_{\text{total}}(\nu))$.
2. **Apply Instrument Model:** This is the final "universal" step. You convolve the high-resolution spectrum with the specific **Instrument Spectral Response Function (ISRF)** of your satellite.
    - **For Hyperspectral (TROPOMI):** Convolve $T_{\text{high\_res}}(\nu)$ with the TROPOMI ISRF (a narrow, pre-defined shape). 
    - **For Multispectral (Sentinel-2):** "Convolve" $T_{\text{high\_res}}(\nu)$ with the S2 band-pass filter (a wide, weighted average).

This workflow allows a single, pre-computed, high-resolution VOD LUT to generate spectra for _any_ satellite, simply by applying the correct geometry (AMF) and instrument model (ISRF) at runtime.

|                                                      |                                                       |                                                                                                                                   |
| ---------------------------------------------------- | ----------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| **Satellite Type**                                   | **Key Challenge**                                     | **"Universal" LUT Strategy**                                                                                                      |
| Hyperspectral (Polar)<br>(e.g., TROPOMI, IASI)       | High spectral resolution, changing VZA across swath.  | 1. Interpolate high-res VODs from LUT.<br><br>2. Apply layer-by-layer AMF.<br><br>3. Convolve with narrow ISRF.                   |
| Hyperspectral (Geo)<br>(e.g., GEMS, TEMPO)           | High spectral resolution, constant VZA, changing SZA. | 1. Interpolate high-res VODs from LUT.<br><br>2. Apply layer-by-layer AMF (VZA is constant).<br><br>3. Convolve with narrow ISRF. |
| Multispectral (Polar)<br>(e.g., Sentinel-2, Landsat) | Wide, discrete spectral bands.                        | 1. Interpolate high-res VODs from LUT.<br><br>2. Apply layer-by-layer AMF.<br><br>3. Convolve with wide band-pass filter.         |

---
## 5. Advanced Application: Retrieving Concentration Enhancements (Plumes)

The "Naive Application" (Section 4) retrieves the _total column_ of gas. For plume detection (e.g., from a specific source like a landfill or pipeline), we are often interested only in the _enhancement_—the _extra_ gas _above_ the regional background.

**ELI5:** ⚖️ This is like using a tare function on a scale. First, you weigh an empty jar (this is your "background" pixel). Then, you hit "tare" to set the scale to zero. Finally, you add cookies to the jar and weigh it again (this is your "plume" pixel). The scale now shows you _only_ the weight of the cookies (the "enhancement"), not the combined weight of the jar and cookies.

### Formulation: The Differential Beer-Lambert Law

This method works by modeling the transmittance _ratio_ between a plume pixel and a nearby background pixel.

**Total Optical Depth (**$\tau_{\text{total}}$**):** This is the sum of the background optical depth and the enhancement's optical depth.
$$
\tau_{\text{total}}(\nu) = \tau_{\text{background}}(\nu) + \tau_{\text{enhancement}}(\nu)
$$
**Total Transmittance (**$T_{\text{total}}$**):** Following the rules of exponents, this becomes a product:
$$
\begin{aligned}
T_{\text{total}}(\nu) &= \exp(-\tau_{\text{total}}) = \exp(-(\tau_{\text{background}} + \tau\_{\text{enhancement}})) \\
 &= \exp(-\tau_{\text{background}}) \cdot \exp(-\tau_{\text{enhancement}}) \\
&= T_{\text{background}}(\nu) \cdot T_{\text{enhancement}}(\nu)
\end{aligned}
$$
**The Signal:** The signal we want to isolate is the enhancement transmittance, which is just the ratio:
$$
T_{\text{enhancement}}(\nu) = \frac{T_{\text{total}}(\nu)}{T_{\text{background}}(\nu)}
$$

---
### Using the LUT for Enhancement Retrieval

The retrieval algorithm will fit a _simulated_ ratio to a _measured_ ratio. The `VMR_CH4` scaling factor in the LUT is now split into two parts: a _fixed_ background and a _fitted_ enhancement.

1. **Get Inputs:**
    - **Measured Signal:** From the satellite, calculate the measured ratio: $I_{\text{measured\_ratio}}(\nu) = I_{\text{plume\_pixel}}(\nu) / I_{\text{background\_pixel}}(\nu)$.
    - **Background State:** Get all atmospheric inputs (T, P, VZA, SZA...) for the background pixel. Define a _fixed_ background methane concentration (e.g., `VMR_CH4_bg_scale = 1.0`).
    - **Enhancement Guess:** This is your _new fitting parameter_. For example, a scaling factor `VMR_CH4_enhance_scale` (e.g., 1.05, 1.1, 1.2...).
        
2. **Interpolate LUT for Background:**
    - Run the **full process from Section 4** (Steps 1-4) using the background state and `VMR_CH4_bg_scale = 1.0`.
    - This gives you the simulated background spectrum: $T_{\text{background}}(\nu)$.
        
3. **Interpolate LUT for Total (Background + Plume):**
    - Run the **full process from Section 4** again, but this time use the _total_ methane scaling factor: `VMR_CH4_total_scale = VMR_CH4_bg_scale \times VMR_CH4_enhance_scale`.
    - This gives you the simulated total spectrum: $T_{\text{total}}(\nu)$.
        
4. **Calculate Simulated Ratio & Fit:**
    - Calculate the simulated signal for this "guess": $T_{\text{simulated\_ratio}}(\nu) = T_{\text{total}}(\nu) / T_{\text{background}}(\nu)$.
    - The retrieval algorithm's job is to find the `VMR_CH4_enhance_scale` that makes $T_{\text{simulated\_ratio}}(\nu)$ best match $I_{\text{measured\_ratio}}(\nu)$.
        
**Why is this better?** This ratio method is extremely powerful because any factor that is _identical_ in both the plume and background pixel gets cancelled out. This includes:
- The solar spectrum ($I_0$).
- Broad, spectrally-flat surface albedo.
- Broadband aerosol scattering.
- Many instrument calibration artifacts.

This technique isolates the _narrow-band_ absorption signature of the methane enhancement, making it possible to detect very small increases in concentration.


---
## 6. Final Caveat: The Scattering Problem

The model in this report (and the LUT described above) **ignores scattering** by aerosols, clouds, and air molecules (Rayleigh scattering). This is a _major_ simplification. A truly robust retrieval LUT must also pre-compute scattering properties, which requires a much more complex "Vector" RTM (like VLIDORT or SASKTRAN) instead of just HAPI. The resulting LUT would store coefficients (e.g., Fourier components of the radiance field) that combine both absorption and scattering.