---
title: Applying Beer-Lambert Models to Remote Sensing Images - A Practical Guide
subject: Methane
short_title: Spatial Considerations
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


## Overview

Remote sensing images present unique challenges and opportunities compared to single-pixel retrievals. Images contain millions of pixels with spatial structure, varying surface properties, and atmospheric conditions. This guide explains how to adapt the Beer-Lambert models for efficient, accurate processing of hyperspectral remote sensing imagery.

***

## 1. Remote Sensing Image Characteristics

### Typical Image Properties

**Satellite hyperspectral image (e.g., GHGSat, EMIT):**
- **Spatial dimensions:** 512×512 to 2048×2048 pixels
- **Spectral dimension:** 200-400 wavelength bands
- **Pixel size (GSD):** 25-60 m ground sample distance
- **Data volume:** 0.5-5 GB per scene
- **Coverage:** 5-50 km × 5-50 km
- **Acquisition time:** Seconds (pushbroom) to minutes (whiskbroom)

**Airborne hyperspectral image (e.g., AVIRIS-NG):**
- **Spatial dimensions:** 600×1000 to 600×10000+ pixels (flightline)
- **Spectral dimension:** 400-600 bands
- **Pixel size:** 3-10 m
- **Data volume:** 5-50 GB per flightline
- **Coverage:** 0.5 km × 10-100 km
- **Acquisition time:** Minutes to hour per flightline

### Key Image-Specific Challenges

| Challenge | Description | Impact on Models |
|-----------|-------------|-----------------|
| **Spatial variability** | Surface reflectance varies across scene | Normalization requires spatial background |
| **Atmospheric gradients** | Water vapor, aerosols change spatially | May need spatial correction |
| **Mixed pixels** | Multiple surface types in one pixel | Complicates background estimation |
| **Plume edges** | Sub-pixel plume structure | Partial coverage effects |
| **Geometric distortions** | Orthorectification needed | Registration for temporal comparison |
| **Data volume** | TB-scale datasets | Computational efficiency critical |

***

## 2. Image-Level Processing Pipeline

### Stage 1: Preprocessing (Radiometric and Geometric)

**Radiometric calibration:**

```
Input: Raw digital numbers (DN)
      ↓
Dark current subtraction
      ↓
Gain application (DN → W·m⁻²·sr⁻¹·nm⁻¹)
      ↓
Wavelength calibration
      ↓
Output: Calibrated radiance cube L_abs(x,y,λ)
```

**Units:** $L_{\text{abs}}(x,y,\lambda)$ [W·m$^{-2}$·sr$^{-1}$·nm$^{-1}$]

**Geometric correction:**

```
Input: Calibrated radiance + navigation data
      ↓
Geolocation (attach lat/lon to each pixel)
      ↓
Orthorectification (correct for terrain, viewing angle)
      ↓
Map projection (project to standard grid)
      ↓
Output: Geolocated radiance cube
```

### Stage 2: Background Estimation (Image-Specific)

**Critical for normalized models.** Several strategies depending on scene:

#### Method 2.1: Spatial Background

**Concept:** Use plume-free pixels from same scene as background.

**Implementation:**

```python
def estimate_background_spatial(image, method='percentile'):
    """
    Estimate background from image statistics.
    
    Parameters:
    -----------
    image : ndarray, shape (height, width, n_wavelengths)
        Radiance cube
    method : str
        'median', 'percentile', or 'mask'
    
    Returns:
    --------
    L_bg : ndarray, shape (n_wavelengths,)
        Background spectrum
    """
    if method == 'median':
        # Global median (simple, robust)
        L_bg = np.median(image, axis=(0,1))
        
    elif method == 'percentile':
        # 10th percentile (conservative, avoids plumes)
        L_bg = np.percentile(image, 10, axis=(0,1))
        
    elif method == 'mask':
        # User-provided mask of background pixels
        background_mask = get_background_mask(image)
        L_bg = np.median(image[background_mask], axis=0)
    
    return L_bg
```

**Advantages:**
- Same illumination and atmospheric conditions
- No temporal changes
- Simple to implement

**Disadvantages:**
- Requires plume-free pixels
- Assumes homogeneous surface (or masks different types)
- Can be biased if plumes widespread

**Best practice:** 
```python
# Spatially adaptive background (local windows)
def estimate_background_adaptive(image, window_size=50):
    """
    Estimate background using sliding window median.
    
    Accounts for spatial variations in surface reflectance.
    """
    height, width, n_bands = image.shape
    L_bg = np.zeros_like(image)
    
    for i in range(height):
        for j in range(width):
            # Define local window
            i_min = max(0, i - window_size//2)
            i_max = min(height, i + window_size//2)
            j_min = max(0, j - window_size//2)
            j_max = min(width, j + window_size//2)
            
            window = image[i_min:i_max, j_min:j_max, :]
            
            # Local background (10th percentile)
            L_bg[i,j,:] = np.percentile(window, 10, axis=(0,1))
    
    return L_bg
```

**This handles spatially varying surface types** (e.g., transition from ocean to land).

#### Method 2.2: Temporal Background

**Concept:** Use image from different time without plume.

```python
def estimate_background_temporal(current_image, reference_date):
    """
    Use reference image from different date.
    
    Parameters:
    -----------
    current_image : ndarray
        Image to process
    reference_date : datetime
        Date of plume-free reference image
    
    Returns:
    --------
    L_bg : ndarray
        Background from reference date
    """
    # Load reference image
    reference_image = load_image(reference_date)
    
    # Register to current image (geometric correction)
    reference_aligned = register_images(reference_image, current_image)
    
    # Correct for solar angle differences
    reference_corrected = correct_solar_angle(
        reference_aligned,
        current_solar_zenith,
        reference_solar_zenith
    )
    
    return reference_corrected
```

**Advantages:**
- Exact surface matching (same pixels)
- Guaranteed plume-free (temporal separation)
- Handles heterogeneous surfaces

**Disadvantages:**
- Requires multiple acquisitions
- Seasonal changes (vegetation, snow)
- Solar angle corrections needed

**Application:** Persistent monitoring of facilities, time-series analysis.

#### Method 2.3: Surface Type Clustering

**Concept:** Cluster pixels by surface type, estimate background per cluster.

```python
def estimate_background_clustered(image, n_clusters=5):
    """
    Cluster pixels by spectral similarity (surface type).
    Estimate background for each cluster separately.
    """
    from sklearn.cluster import KMeans
    
    height, width, n_bands = image.shape
    pixels_flat = image.reshape(-1, n_bands)
    
    # Cluster based on spectral signature
    kmeans = KMeans(n_clusters=n_clusters, random_state=42)
    labels = kmeans.fit_predict(pixels_flat)
    labels_image = labels.reshape(height, width)
    
    # Background for each cluster
    L_bg = np.zeros_like(image)
    for cluster_id in range(n_clusters):
        mask = (labels_image == cluster_id)
        cluster_pixels = image[mask]
        
        # 10th percentile within cluster
        cluster_bg = np.percentile(cluster_pixels, 10, axis=0)
        
        L_bg[mask] = cluster_bg
    
    return L_bg
```

**Handles heterogeneous scenes** (mixed land cover) automatically.

### Stage 3: Normalization

**Pixel-wise division:**

```python
def normalize_image(image, L_bg):
    """
    Normalize image by background.
    
    Parameters:
    -----------
    image : ndarray, shape (height, width, n_wavelengths)
        Absolute radiance
    L_bg : ndarray, shape (height, width, n_wavelengths) or (n_wavelengths,)
        Background radiance
    
    Returns:
    --------
    image_norm : ndarray, shape (height, width, n_wavelengths)
        Normalized radiance [dimensionless]
    """
    # Handle both global and spatially-varying background
    if L_bg.ndim == 1:
        # Global background: broadcast to image shape
        image_norm = image / L_bg[np.newaxis, np.newaxis, :]
    else:
        # Spatially-varying background
        image_norm = image / L_bg
    
    # Avoid division by zero (dark pixels)
    image_norm = np.where(L_bg > 1e-10, image_norm, 1.0)
    
    return image_norm
```

**Output:** $L_{\text{norm}}(x,y,\lambda)$ [dimensionless]

### Stage 4: Model Application (Vectorized)

**Key principle:** Process all pixels simultaneously using vectorized operations.

#### Combined Model (Fastest)

```python
def apply_combined_model_image(image_norm, H, Sigma_norm):
    """
    Apply combined model to entire image.
    
    Parameters:
    -----------
    image_norm : ndarray, shape (height, width, n_wavelengths)
        Normalized radiance
    H : ndarray, shape (n_wavelengths,)
        Sensitivity vector [ppm⁻¹]
    Sigma_norm : ndarray, shape (n_wavelengths,) or (n_wavelengths, n_wavelengths)
        Noise covariance [dimensionless²]
    
    Returns:
    --------
    alpha : ndarray, shape (height, width)
        VMR enhancement map [ppm]
    uncertainty : ndarray, shape (height, width)
        Retrieval uncertainty [ppm]
    """
    height, width, n_bands = image_norm.shape
    
    # Innovation: d = 1 - y_norm
    innovation = 1.0 - image_norm  # shape: (height, width, n_bands)
    
    if Sigma_norm.ndim == 1:
        # Diagonal covariance (fast path)
        Sigma_inv = 1.0 / Sigma_norm
        
        # Matched filter: alpha = (H^T Sigma^-1 d) / (H^T Sigma^-1 H)
        # Vectorized over spatial dimensions
        numerator = np.einsum('k,ijk,k->ij', H, innovation, Sigma_inv)
        denominator = np.sum(H * H * Sigma_inv)
        
        alpha = numerator / denominator
        
        # Uncertainty
        uncertainty = np.sqrt(1.0 / denominator) * np.ones((height, width))
        
    else:
        # Full covariance (slower but more accurate)
        Sigma_inv = np.linalg.inv(Sigma_norm)
        
        # Reshape for batch matrix operations
        innovation_flat = innovation.reshape(-1, n_bands)  # (N_pixels, n_bands)
        
        # Batch computation
        Sigma_inv_d = innovation_flat @ Sigma_inv  # (N_pixels, n_bands)
        numerator = Sigma_inv_d @ H  # (N_pixels,)
        denominator = H @ Sigma_inv @ H  # scalar
        
        alpha = (numerator / denominator).reshape(height, width)
        uncertainty = np.sqrt(1.0 / denominator) * np.ones((height, width))
    
    return alpha, uncertainty
```

**Computational complexity:**
- Diagonal covariance: $O(HWN)$ where $H×W$ = spatial size, $N$ = bands
- Full covariance: $O(HWN^2)$

**Typical timing:**
- 1000×1000 pixels, 200 bands, diagonal covariance: **0.5 seconds** on CPU
- Same with GPU: **0.01 seconds**

#### Taylor Model (Iterative, but Vectorized)

```python
def apply_taylor_model_image(image_norm, H, Sigma_norm, max_iter=10):
    """
    Apply Taylor model to entire image with vectorized iteration.
    
    Forward model: L_norm = exp(-H * alpha)
    """
    height, width, n_bands = image_norm.shape
    n_pixels = height * width
    
    # Reshape to (n_pixels, n_bands) for batch processing
    y_flat = image_norm.reshape(n_pixels, n_bands)
    
    # Initialize with combined model estimate
    alpha_flat, _ = apply_combined_model_image(image_norm, H, Sigma_norm)
    alpha_flat = alpha_flat.flatten()  # (n_pixels,)
    
    # Gauss-Newton iteration (vectorized over pixels)
    for iteration in range(max_iter):
        # Forward model: y_pred = exp(-H * alpha)
        tau = np.outer(alpha_flat, H)  # (n_pixels, n_bands)
        y_pred = np.exp(-tau)  # (n_pixels, n_bands)
        
        # Residual
        residual = y_flat - y_pred  # (n_pixels, n_bands)
        
        # Jacobian: J = -exp(-H*alpha) * H
        # Shape: (n_pixels, n_bands)
        jacobian = -y_pred * H[np.newaxis, :]
        
        # Gauss-Newton update (per pixel, diagonal covariance)
        if Sigma_norm.ndim == 1:
            Sigma_inv = 1.0 / Sigma_norm
            
            # JT Sigma^-1 J (scalar per pixel)
            JT_Sigma_J = np.sum(jacobian**2 * Sigma_inv[np.newaxis, :], axis=1)
            
            # JT Sigma^-1 r (scalar per pixel)
            JT_Sigma_r = np.sum(jacobian * residual * Sigma_inv[np.newaxis, :], axis=1)
            
            # Update
            delta_alpha = JT_Sigma_r / JT_Sigma_J
            alpha_flat += delta_alpha
        
        # Convergence check
        if np.max(np.abs(delta_alpha)) < 1.0:  # 1 ppm threshold
            break
    
    # Reshape to image
    alpha = alpha_flat.reshape(height, width)
    
    # Uncertainty from final Jacobian
    uncertainty = 1.0 / np.sqrt(JT_Sigma_J).reshape(height, width)
    
    return alpha, uncertainty
```

**Computational complexity:** $O(k \cdot HWN)$ where $k$ = iterations (5-10 typical)

**Typical timing:**
- 1000×1000 pixels, 200 bands, 10 iterations: **10 seconds** on CPU
- Same with GPU: **0.5 seconds**

**Key optimization:** Vectorize over all pixels simultaneously (no pixel loop).

#### Nonlinear Model (Selective Processing)

**Don't process all pixels** — too slow. Instead:

```python
def apply_nonlinear_selective(image_norm, H, Sigma_norm, 
                              alpha_initial, threshold=0.10):
    """
    Apply nonlinear model selectively to strong plumes only.
    
    Parameters:
    -----------
    alpha_initial : ndarray, shape (height, width)
        Initial estimate from combined or Taylor model
    threshold : float
        delta_tau threshold for nonlinear processing
    """
    height, width = alpha_initial.shape
    
    # Compute optical depth from initial estimate
    delta_tau_map = alpha_initial * np.sum(H)  # Approximate
    
    # Identify pixels needing nonlinear
    strong_mask = (delta_tau_map > threshold)
    n_strong = np.sum(strong_mask)
    
    print(f"Processing {n_strong} strong pixels ({100*n_strong/(height*width):.1f}%) with nonlinear")
    
    # Copy initial estimates
    alpha_final = alpha_initial.copy()
    uncertainty = np.zeros_like(alpha_initial)
    
    # Extract strong pixels
    y_strong = image_norm[strong_mask]  # (n_strong, n_bands)
    alpha_strong_init = alpha_initial[strong_mask]  # (n_strong,)
    
    # Process in batches (avoid memory issues)
    batch_size = 1000
    for i in range(0, n_strong, batch_size):
        batch_end = min(i + batch_size, n_strong)
        
        # Nonlinear optimization for batch
        alpha_batch, unc_batch = nonlinear_batch_optimize(
            y_strong[i:batch_end],
            alpha_strong_init[i:batch_end],
            H, Sigma_norm
        )
        
        # Update results
        strong_indices = np.where(strong_mask.flatten())[0][i:batch_end]
        alpha_final.flat[strong_indices] = alpha_batch
        uncertainty.flat[strong_indices] = unc_batch
    
    return alpha_final, uncertainty
```

**Computational savings:**
- Typical: 1-5% of pixels need nonlinear
- **50-100× faster** than full nonlinear

### Stage 5: Detection and Quantification Maps

**Generate detection map:**

```python
def generate_detection_map(alpha, uncertainty, threshold_sigma=3):
    """
    Binary detection map based on statistical threshold.
    
    Parameters:
    -----------
    alpha : ndarray, shape (height, width)
        Retrieved VMR [ppm]
    uncertainty : ndarray, shape (height, width)
        Uncertainty [ppm]
    threshold_sigma : float
        Number of sigma for detection (3-5 typical)
    
    Returns:
    --------
    detection_map : ndarray, shape (height, width), dtype=bool
        True where plume detected
    confidence : ndarray, shape (height, width)
        Detection confidence (SNR)
    """
    # Detection statistic (signal-to-noise ratio)
    snr = alpha / uncertainty
    
    # Threshold
    detection_map = (snr > threshold_sigma) & (alpha > 0)
    
    # Confidence
    confidence = snr
    
    return detection_map, confidence
```

**Spatial filtering:**

```python
from scipy.ndimage import label, binary_opening

def filter_detections_spatial(detection_map, min_size=5):
    """
    Remove isolated false positives using spatial coherence.
    
    Parameters:
    -----------
    detection_map : ndarray, dtype=bool
        Binary detection map
    min_size : int
        Minimum cluster size (pixels)
    
    Returns:
    --------
    filtered_map : ndarray, dtype=bool
        Spatially filtered detections
    """
    # Morphological opening (remove small isolated pixels)
    cleaned = binary_opening(detection_map, structure=np.ones((3,3)))
    
    # Connected components
    labeled, n_features = label(cleaned)
    
    # Size filter
    filtered = np.zeros_like(detection_map)
    for i in range(1, n_features + 1):
        component = (labeled == i)
        if np.sum(component) >= min_size:
            filtered |= component
    
    return filtered
```

***

## 3. Parallelization and Optimization

### CPU Parallelization

**Tile-based processing:**

```python
from concurrent.futures import ProcessPoolExecutor
import numpy as np

def process_image_parallel(image_norm, H, Sigma_norm, n_workers=16):
    """
    Process image in parallel using tiling.
    
    Splits image into tiles, processes on multiple cores.
    """
    height, width, n_bands = image_norm.shape
    tile_size = 128  # pixels per tile
    
    # Generate tiles
    tiles = []
    for i in range(0, height, tile_size):
        for j in range(0, width, tile_size):
            i_end = min(i + tile_size, height)
            j_end = min(j + tile_size, width)
            tiles.append((i, i_end, j, j_end))
    
    def process_tile(tile_bounds):
        i, i_end, j, j_end = tile_bounds
        tile_data = image_norm[i:i_end, j:j_end, :]
        alpha_tile, unc_tile = apply_combined_model_image(tile_data, H, Sigma_norm)
        return (i, i_end, j, j_end), alpha_tile, unc_tile
    
    # Parallel processing
    alpha = np.zeros((height, width))
    uncertainty = np.zeros((height, width))
    
    with ProcessPoolExecutor(max_workers=n_workers) as executor:
        results = executor.map(process_tile, tiles)
        
        for (i, i_end, j, j_end), alpha_tile, unc_tile in results:
            alpha[i:i_end, j:j_end] = alpha_tile
            uncertainty[i:i_end, j:j_end] = unc_tile
    
    return alpha, uncertainty
```

**Speedup:** Near-linear with cores (16 cores → 15× faster)

### GPU Acceleration

**Using CuPy (CUDA) for massive parallelism:**

```python
import cupy as cp

def apply_combined_model_gpu(image_norm, H, Sigma_norm):
    """
    GPU-accelerated matched filter.
    
    All operations on GPU (no CPU-GPU transfers in loop).
    """
    # Transfer to GPU
    image_norm_gpu = cp.asarray(image_norm)
    H_gpu = cp.asarray(H)
    Sigma_inv_gpu = cp.asarray(1.0 / Sigma_norm)  # Diagonal
    
    # Innovation
    innovation_gpu = 1.0 - image_norm_gpu
    
    # Matched filter (fully vectorized)
    # numerator = einsum('k,ijk,k->ij', H, innovation, Sigma_inv)
    numerator_gpu = cp.einsum('k,ijk,k->ij', 
                             H_gpu, innovation_gpu, Sigma_inv_gpu)
    
    denominator = cp.sum(H_gpu * H_gpu * Sigma_inv_gpu)
    
    alpha_gpu = numerator_gpu / denominator
    
    # Transfer back to CPU
    alpha = cp.asnumpy(alpha_gpu)
    
    return alpha
```

**Speedup:** 100-500× faster than single-threaded CPU

**When to use:**
- Image size > 1M pixels
- Real-time requirements
- Batch processing large datasets

***

## 4. Spatial Extensions and Advanced Techniques

### 4.1 Spatial Regularization

**Problem:** Individual pixel retrievals can be noisy.

**Solution:** Enforce spatial smoothness.

**Total variation regularization:**

$$\min_{\alpha} \|y - g(\alpha)\|^2_{\Sigma^{-1}} + \lambda \|\nabla \alpha\|_1$$

where $\|\nabla \alpha\|_1 = \sum_{i,j} |\alpha_{i+1,j} - \alpha_{i,j}| + |\alpha_{i,j+1} - \alpha_{i,j}|$

**Implementation (proximal gradient):**

```python
def retrieve_with_spatial_regularization(image_norm, H, Sigma_norm, lambda_tv=10.0):
    """
    Retrieve VMR with total variation spatial regularization.
    """
    from skimage.restoration import denoise_tv_chambolle
    
    # Initial retrieval (pixel-wise)
    alpha_initial, _ = apply_combined_model_image(image_norm, H, Sigma_norm)
    
    # TV denoising (enforces spatial smoothness)
    alpha_smooth = denoise_tv_chambolle(alpha_initial, weight=lambda_tv)
    
    return alpha_smooth
```

**Advantages:**
- Reduces noise
- Preserves plume edges
- More physically realistic (plumes are spatially continuous)

### 4.2 Multi-Pixel Joint Retrieval

**Concept:** Retrieve multiple pixels simultaneously with spatial constraints.

**State vector:** $\mathbf{x} = [\alpha_{1,1}, \alpha_{1,2}, \ldots, \alpha_{H,W}]^T$

**Too large for full image!** Use **local patches**:

```python
def retrieve_patch_jointly(image_patch, H, Sigma_norm, prior_covariance):
    """
    Joint retrieval for small patch (e.g., 10×10 pixels).
    
    Parameters:
    -----------
    image_patch : ndarray, shape (patch_h, patch_w, n_bands)
    prior_covariance : ndarray, shape (patch_h*patch_w, patch_h*patch_w)
        Spatial correlation structure
    """
    patch_h, patch_w, n_bands = image_patch.shape
    n_pixels = patch_h * patch_w
    
    # Flatten spatial dimensions
    y = (1 - image_patch).reshape(n_pixels, n_bands)
    
    # Observation operator (block diagonal)
    H_block = np.kron(np.eye(n_pixels), H)  # (n_pixels*n_bands, n_pixels)
    
    # Prior: alpha ~ N(0, B) where B encodes spatial correlation
    # E.g., B[i,j] = exp(-distance(i,j)/length_scale)
    
    # Posterior mean (Bayesian):
    # alpha_hat = B H^T (H B H^T + Sigma)^-1 y
    
    # ... implement Bayesian retrieval ...
    
    return alpha_map
```

**Computationally expensive** but gives optimal spatial estimates.

### 4.3 Super-Resolution

**Problem:** Plumes smaller than pixel size (sub-pixel structure).

**Solution:** Use spatial oversampling or physics-based super-resolution.

```python
def super_resolve_plume(image_norm, H, Sigma_norm, oversample_factor=4):
    """
    Retrieve VMR on finer grid than observed pixels.
    
    Uses spatial regularization and overlapping pixel footprints.
    """
    height, width, n_bands = image_norm.shape
    
    # Create high-resolution grid
    hr_height = height * oversample_factor
    hr_width = width * oversample_factor
    
    # Forward model: Low-res pixel = average of high-res sub-pixels
    def forward_model(alpha_hr):
        # Downsample by averaging
        alpha_lr = block_reduce(alpha_hr, (oversample_factor, oversample_factor), func=np.mean)
        # Then apply Beer's law
        y_pred = 1 - H * alpha_lr[:,:,np.newaxis]
        return y_pred
    
    # Inverse problem with TV regularization
    alpha_hr = optimize_super_resolution(
        image_norm, forward_model, tv_weight=1.0
    )
    
    return alpha_hr
```

**Advantage:** Resolve plume structure finer than pixel size.

***

## 5. Time-Series Analysis

**Multiple images of same area over time:**

### Change Detection

**Identify new or changing plumes:**

```python
def detect_changes(image_t1, image_t2, H, Sigma_norm):
    """
    Detect changes between two time points.
    """
    # Retrieve VMR for both times
    alpha_t1, _ = apply_combined_model_image(image_t1, H, Sigma_norm)
    alpha_t2, _ = apply_combined_model_image(image_t2, H, Sigma_norm)
    
    # Change map
    delta_alpha = alpha_t2 - alpha_t1
    
    # Significance test
    # (assumes independent retrievals)
    delta_uncertainty = np.sqrt(unc_t1**2 + unc_t2**2)
    change_detected = (np.abs(delta_alpha) > 3 * delta_uncertainty)
    
    return delta_alpha, change_detected
```

### Persistent Emission Identification

**Find sources active across multiple images:**

```python
def identify_persistent_sources(image_stack, H, Sigma_norm, min_detections=3):
    """
    Identify locations with repeated detections.
    
    Parameters:
    -----------
    image_stack : list of ndarrays
        Multiple images over time
    min_detections : int
        Minimum number of detections required
    """
    n_images = len(image_stack)
    height, width, _ = image_stack[0].shape
    
    # Process each image
    detection_count = np.zeros((height, width), dtype=int)
    
    for image in image_stack:
        image_norm = normalize_image(image, estimate_background(image))
        alpha, unc = apply_combined_model_image(image_norm, H, Sigma_norm)
        
        # Detection
        detected = (alpha / unc > 3) & (alpha > 0)
        detection_count += detected.astype(int)
    
    # Persistent sources
    persistent = (detection_count >= min_detections)
    
    # Confidence based on detection frequency
    confidence = detection_count / n_images
    
    return persistent, confidence
```

***

## 6. Multi-Gas Imaging

**Retrieve CH₄, CO₂, H₂O simultaneously across entire image:**

### Approach 1: Independent Processing

```python
def retrieve_multigas_independent(image_norm, H_CH4, H_CO2, H_H2O, Sigma_norm):
    """
    Retrieve each gas independently.
    
    Fast but ignores spectral correlations.
    """
    alpha_CH4, _ = apply_combined_model_image(image_norm, H_CH4, Sigma_norm)
    alpha_CO2, _ = apply_combined_model_image(image_norm, H_CO2, Sigma_norm)
    alpha_H2O, _ = apply_combined_model_image(image_norm, H_H2O, Sigma_norm)
    
    return alpha_CH4, alpha_CO2, alpha_H2O
```

### Approach 2: PCA Decorrelation

```python
def retrieve_multigas_pca(image_norm, H_matrix, Sigma_norm):
    """
    Retrieve multiple gases using PCA decorrelation.
    
    Parameters:
    -----------
    H_matrix : ndarray, shape (n_bands, n_gases)
        Sensitivity matrix for all gases
    """
    n_gases = H_matrix.shape[1]
    
    # SVD of sensitivity matrix
    U, S, Vt = np.linalg.svd(H_matrix, full_matrices=False)
    
    # Transform to principal components
    PC = Vt.T  # (n_gases, n_gases)
    
    # Retrieve in PC space
    height, width, n_bands = image_norm.shape
    alpha_PC = np.zeros((height, width, n_gases))
    
    for i in range(n_gases):
        H_pc = H_matrix @ PC[:, i]
        alpha_PC[:,:,i], _ = apply_combined_model_image(image_norm, H_pc, Sigma_norm)
    
    # Back-transform to gas space
    alpha_gases = alpha_PC @ PC.T
    
    return {
        'CH4': alpha_gases[:,:,0],
        'CO2': alpha_gases[:,:,1],
        'H2O': alpha_gases[:,:,2]
    }
```

***

## 7. Validation and Quality Control

### Spatial Consistency Checks

```python
def quality_control_spatial(alpha, detection_map):
    """
    Flag suspicious retrievals based on spatial patterns.
    """
    flags = np.zeros_like(alpha, dtype=int)
    
    # Flag 1: Isolated single-pixel detections
    from scipy.ndimage import label
    labeled, n_features = label(detection_map)
    for i in range(1, n_features + 1):
        if np.sum(labeled == i) == 1:
            flags[labeled == i] |= 0x01  # Bit 0: isolated
    
    # Flag 2: Unrealistic spatial gradients
    grad_x = np.diff(alpha, axis=1)
    grad_y = np.diff(alpha, axis=0)
    high_gradient = (np.abs(grad_x) > 500) | (np.abs(grad_y) > 500)  # >500 ppm/pixel
    flags[:, 1:][high_gradient] |= 0x02  # Bit 1: high gradient
    
    # Flag 3: Negative VMR
    flags[alpha < 0] |= 0x04  # Bit 2: unphysical
    
    return flags
```

### Spectral Residual Analysis

```python
def compute_spectral_residuals(image_norm, alpha, H):
    """
    Check goodness of fit using spectral residuals.
    """
    height, width, n_bands = image_norm.shape
    
    # Forward model prediction
    tau_pred = alpha[:,:,np.newaxis] * H[np.newaxis, np.newaxis, :]
    y_pred = np.exp(-tau_pred)  # or 1 - tau for combined
    
    # Residuals
    residuals = image_norm - y_pred
    
    # Chi-squared statistic
    chi2 = np.sum(residuals**2, axis=2)  # Simplified
    
    # Flag poor fits
    chi2_threshold = 3 * n_bands  # 3x expected value
    poor_fit = (chi2 > chi2_threshold)
    
    return residuals, chi2, poor_fit
```

***

## 8. Output Products and Visualization

### Standard Output Products

```python
def generate_output_products(alpha, uncertainty, detection_map, metadata):
    """
    Generate standard output products from retrieval.
    """
    import xarray as xr
    
    # Create xarray Dataset
    ds = xr.Dataset(
        {
            'vmr_enhancement': (['y', 'x'], alpha, {
                'units': 'ppm',
                'long_name': 'Methane VMR enhancement',
                'valid_range': [0, 10000]
            }),
            'vmr_uncertainty': (['y', 'x'], uncertainty, {
                'units': 'ppm',
                'long_name': 'Retrieval uncertainty (1-sigma)'
            }),
            'detection_flag': (['y', 'x'], detection_map.astype(np.uint8), {
                'flag_values': [0, 1],
                'flag_meanings': 'no_plume plume_detected'
            }),
            'quality_flag': (['y', 'x'], quality_flags, {
                'flag_masks': [0x01, 0x02, 0x04],
                'flag_meanings': 'isolated high_gradient negative_vmr'
            })
        },
        coords={
            'x': (['x'], x_coords, {'units': 'meters', 'long_name': 'Easting'}),
            'y': (['y'], y_coords, {'units': 'meters', 'long_name': 'Northing'}),
            'lat': (['y', 'x'], lat_grid, {'units': 'degrees_north'}),
            'lon': (['y', 'x'], lon_grid, {'units': 'degrees_east'})
        },
        attrs=metadata
    )
    
    return ds
```

### Visualization

```python
import matplotlib.pyplot as plt
from matplotlib.colors import LogNorm

def visualize_results(alpha, detection_map, background_rgb=None):
    """
    Create multi-panel visualization.
    """
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))
    
    # Panel 1: VMR map
    im1 = axes[0].imshow(alpha, cmap='YlOrRd', vmin=0, vmax=np.percentile(alpha[detection_map], 95))
    axes[0].set_title('VMR Enhancement [ppm]')
    plt.colorbar(im1, ax=axes[0])
    
    # Panel 2: Detection overlay on background
    if background_rgb is not None:
        axes[1].imshow(background_rgb)
    axes[1].contour(detection_map, levels=[0.5], colors='cyan', linewidths=2)
    axes[1].set_title('Detected Plumes (cyan contours)')
    
    # Panel 3: Detection confidence
    confidence = alpha / uncertainty
    im3 = axes[2].imshow(confidence, cmap='viridis', vmin=0, vmax=10)
    axes[2].set_title('Detection Confidence (SNR)')
    plt.colorbar(im3, ax=axes[2], label='Signal-to-Noise Ratio')
    
    plt.tight_layout()
    return fig
```

***

## 9. Complete End-to-End Example

```python
def process_remote_sensing_image_complete(
    image_file,
    model='combined',
    output_dir='./results/'
):
    """
    Complete pipeline from raw image to products.
    """
    # Step 1: Load and calibrate
    print("Loading image...")
    image_raw = load_image(image_file)
    image_calibrated = apply_radiometric_calibration(image_raw)
    image_geocorrected = apply_geometric_correction(image_calibrated)
    
    # Step 2: Estimate background
    print("Estimating background...")
    L_bg = estimate_background_adaptive(image_geocorrected, window_size=50)
    
    # Step 3: Normalize
    print("Normalizing...")
    image_norm = normalize_image(image_geocorrected, L_bg)
    
    # Step 4: Compute sensitivity
    print("Computing sensitivity...")
    H = compute_sensitivity_vector(wavelengths, absorption_database='HITRAN')
    Sigma_norm = estimate_noise_covariance(image_norm)
    
    # Step 5: Apply model
    print(f"Applying {model} model...")
    if model == 'combined':
        alpha, uncertainty = apply_combined_model_image(image_norm, H, Sigma_norm)
    elif model == 'taylor':
        alpha, uncertainty = apply_taylor_model_image(image_norm, H, Sigma_norm)
    elif model == 'hybrid':
        alpha_init, _ = apply_combined_model_image(image_norm, H, Sigma_norm)
        alpha, uncertainty = apply_nonlinear_selective(
            image_norm, H, Sigma_norm, alpha_init, threshold=0.10
        )
    
    # Step 6: Detection
    print("Generating detection map...")
    detection_map, confidence = generate_detection_map(alpha, uncertainty, threshold_sigma=3)
    detection_filtered = filter_detections_spatial(detection_map, min_size=5)
    
    # Step 7: Quality control
    print("Quality control...")
    quality_flags = quality_control_spatial(alpha, detection_filtered)
    
    # Step 8: Generate products
    print("Generating output products...")
    metadata = extract_metadata(image_file)
    ds = generate_output_products(alpha, uncertainty, detection_filtered, metadata)
    
    # Step 9: Save
    output_file = f"{output_dir}/{Path(image_file).stem}_retrieval.nc"
    ds.to_netcdf(output_file)
    print(f"Saved to {output_file}")
    
    # Step 10: Visualize
    fig = visualize_results(alpha, detection_filtered)
    fig.savefig(f"{output_dir}/{Path(image_file).stem}_visualization.png", dpi=300)
    
    return ds
```

***

## Summary: Key Takeaways for Image Processing

1. **Normalization is critical** - Estimate background carefully (spatial/temporal/clustered)
2. **Vectorize everything** - Process all pixels simultaneously, avoid loops
3. **Use appropriate model** - Combined for most, Taylor for moderate, Nonlinear selectively
4. **Leverage parallelism** - Multi-core CPU or GPU for large images
5. **Spatial context matters** - Use regularization, filtering, clustering
6. **Quality control essential** - Spatial consistency, spectral residuals, physical checks
7. **Standard products** - xarray/NetCDF with metadata, flags, uncertainties

The Beer-Lambert models scale elegantly from single pixels to full images when implemented with modern scientific computing practices (vectorization, parallelization, GPU acceleration). The combined model remains the workhorse for operational image processing due to its speed and reasonable accuracy.

Sources
