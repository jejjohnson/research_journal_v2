---
title: "A differentiable JAX/Equinox RTM — design and staged roadmap"
subject: "methane — RTM deep design"
short_title: "RTM 4 JAX"
authors:
  - name: J. Emmanuel Johnson
    affiliations:
      - UNEP
      - IMEO
      - MARS
    orcid: 0000-0002-6739-0053
    email: jemanjohnson34@gmail.com
license: CC-BY-4.0
keywords: methane, radiative-transfer, JAX, Equinox, ExoJAX, VLIDORT, ARTS, HITRAN, HAPI, differentiable-RTM, doubling-adding, Mie
---

# RTM 4 JAX — a differentiable JAX/Equinox RTM for methane and multi-gas remote sensing

**Bottom line up front.** Build the RTM as a typed, Equinox-modular pipeline (`atmosphere → spectroscopy → optical_properties → solver → instrument → loss`) that exposes per-layer **{τ, ω, phase moments, surface kernels}** as the canonical differentiation interface — the same interface VLIDORT linearises by hand, but obtained for free from `jax.jacrev`/`jax.vjp`. Stage delivery in five versions that each ship a working retrieval: v0 Beer–Lambert SWIR matched-filter target generator, v1 instrument-aware clear-sky OE retrieval, v2 in-JAX line-by-line (PreMODIT-style), v3 single-scattering with differentiable Mie, v4 multi-stream + doubling-adding with implicit differentiation through linear solves via Lineax. The closest single existing reference is **ExoJAX** (Kawahara et al. 2022/2025), whose `db→opa→art→sop` factoring transfers almost wholesale to Earth remote sensing; the closest non-differentiable architectural reference is **ARTS** (agenda + workspace) and **VLIDORT** (analytical K-matrix). The user-supplied paper (Korkin et al. 2022, *Comp. Phys. Comm.* 271, 108198, *“A practical guide to writing a radiative transfer code”*)  is a pedagogical Gauss–Seidel scalar scattering tutorial — not differentiable, not LBL — but contributes a clean “make-it-right-then-fast” modular skeleton, the Fourier-azimuth decomposition, and the analytic single-scattering + correction trick.

-----

## 1. The reference paper, and how to read it

The DOI fragment `S0010465521003106` resolves to **Korkin, Sayer, Ibrahim & Lyapustin (2022), “A practical guide to writing a radiative transfer code”, *Computer Physics Communications* 271, 108198** (USRA/NASA GSFC; MIT-licensed code at `github.com/korkins/gsit`).  The companion `gsit` is a ~268-line Python+Numba implementation  of a scalar, monochromatic, plane-parallel, Lambertian-surface, multi-stream Gauss–Seidel solver. It is **explicitly not** a differentiable, line-by-line, or HITRAN-aware code, and the authors view spectroscopy and Mie as “plug-ins” outside the RT solver. That framing is itself the most important lesson.

**Transferable design takeaways:**

- **Pipeline of pure functions** (quadrature → polynomials → analytic single scatter → per-Fourier-m iterate → source-function integration → azimuth accumulation). Each becomes a `filter_jit`-able Equinox module; outer loops become `vmap`s.
- **Fourier expansion in azimuth** turns a 3-D RTE into a stack of independent 1-D problems indexed by `m` — a clean `jax.vmap` axis.
- **Keep analytical single scattering as a first-class building block.** Subtract it from the multiple-scattering iterate, iterate the diffuse part only, then add the exact analytic single scatter back. This both improves accuracy at low stream count and produces **cleaner gradients** (single scatter is a closed form whose Jacobian is algebraic).
- **Validate against Rayleigh and aerosol-over-Lambertian benchmarks** at ~0.1% TOA/BOA accuracy; implement two independent versions of single scattering and cross-check.
- **Numerical-method choice is problem-dependent.** Gauss–Seidel / Successive Orders excel for thin atmospheres and many layers; discrete-ordinates / spherical harmonics for thick few-layer cases; doubling–adding for very thick uniform media; Monte Carlo for 3-D. Architect for solver pluggability rather than picking one.
- **“Avoid the monster code.”** DISORT, MODTRAN, libRadtran, SCIATRAN all carry decades of accreted complexity; an open, modular, autodiff-native rewrite is timely.

The Korkin paper is best treated as the **scaffolding lesson** for v0–v1. For algorithmic depth in spectroscopy and scattering you will lean on ExoJAX, py4CAtS, VLIDORT, and SHDOM instead.

-----

## 2. Landscape: what exists, what to inherit, what to displace

### Classical Fortran codes — the algorithmic ancestors

The most consequential of the surveyed classical codes is **VLIDORT (Spurr, RT Solutions)**. It is the gold standard for retrieval-grade RT because it ships **analytical Jacobians (“K-matrix”)** with respect to per-layer extinction Δₙ, single-scattering albedo ωₙ, phase-function moments Bₙₗ, and surface kernels  — exactly what `jax.jacrev` produces for free in a JAX rewrite. VLIDORT’s hand-derived eigenvector-perturbation machinery (and the small-denominator Taylor expansions used when μₖ → μ₀⁻¹ in the streaming multipliers, with ε ≈ 10⁻³ switchover) is **the single biggest implementation pitfall** to anticipate in JAX: `jax.scipy.linalg.eigh` analytical derivatives fail at repeated eigenvalues and the streaming multipliers diverge under naive AD. Reproduce Spurr’s Taylor-series branch as a `jax.lax.cond` with a smoothed switch, or as a `jax.custom_jvp`.

**DISORT (Stamnes et al.)** contributes the canonical 2N→N eigenproblem reduction (use `jax.scipy.linalg.eigh`), the exponential-scaling transformation that prevents `exp(+τ)` overflow in boundary value problems, and **delta-M + Nakajima–Tanaka (TMS) single-scatter correction** for forward-peaked phase functions. These must all survive autodiff cleanly.

**ARTS (Eriksson, Buehler et al.)** contributes the **workspace + agenda architecture**: a strongly-typed registry of physical quantities with user-rewireable function pipelines.   This maps almost one-to-one onto an Equinox-module DAG with `jaxtyping`-annotated pytree workspaces. The right design pattern is: agendas = Equinox-module compositions; workspace methods = `eqx.Module.__call__` returning typed pytree slices. 

**libRadtran (Mayer & Kylling)** contributes the **solver-pluggability** pattern (DISORT, two-stream, polRadtran, MYSTIC MC,  SHDOM all consume the same optical setup) and the **reptran “representative wavelength”** band parameterisation for broadband applications.

**py4CAtS (Schreier, DLR)** is the closest Python ancestor: a pipeline of typed dataclasses `xs → ac → od → ri` (cross section → absorption coefficient → optical depth → radiance)  wrapping HITRAN/GEISA I/O and Humliček/Weideman Voigt. Copy this typing scheme directly; replace NumPy with `jax.numpy` and the dataclasses with `eqx.Module`.

**RTTOV** contributes the convention that **forward, tangent linear (jvp), adjoint (vjp), and K (jacobian)** belong together as four faces of the same model — JAX provides all four automatically. RTTOV’s regression-coefficient fast model is also the right reference for an eventual “**RTTOV-mode**” in which a small neural network or polynomial replaces explicit LBL during operational throughput.

**SHDOM (Evans)** is the open 3-D RT reference; its Picard fixed-point iteration is a natural fit for `jaxopt.FixedPointIteration` / `optimistix` with implicit differentiation. **6S / OSOAA** (successive orders) are conceptually clean — each scattering order is an explicit operator with an algebraic Jacobian — and useful as alternative engines, especially OSOAA’s Cox-Munk air–sea interface  for ocean coupling.

**SCIATRAN** is the operational reference for UV–Vis–NIR–SWIR trace gas retrievals (GOME, SCIAMACHY, TROPOMI AMF LUTs); it already includes Raman/Ring inelastic scattering and pseudo-spherical geometry but is closed-source. **MODTRAN** is the proprietary band-model standard; do not re-implement it, but support correlated-k as an alternative substitution layer for the optical-depth provider.

### JAX-native and differentiable efforts

**ExoJAX (Kawahara et al., 2022 ApJS 258:31; 2025 ApJ, “ExoJAX2”)** is the closest and most important reference. It already implements in pure JAX everything v0–v2 of this roadmap needs:

|Component            |ExoJAX implementation                                                                                                                             |Lesson                                                                                                                              |
|---------------------|--------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------|
|Voigt profile        |`lpf.voigt` / `voigtone` via Voigt–Hjerting `hjert(x,a)`,  pure `jnp`, no `custom_vjp` needed                                                     |FP64 required at line center; `vmap` over ν is the unit pattern                                                                     |
|LBL many-line opacity|Three tiers: `OpaDirect` (full LPF), `OpaModit` (FFT/DIT on ESLOG grid), `OpaPremodit` (precomputed Line Basis Density, ≳10⁵–10⁸ lines on one GPU)|For SWIR CH₄ ν₃ band (~10⁴–10⁵ HITRAN lines), PreMODIT-class precomputation is essential                                            |
|Memory               |`Opart` layer-wise `jax.lax.scan` makes memory O(1) in N_layer                                                                                    |Adopt for all RT solvers; critical for HMC retrievals                                                                               |
|Line list I/O        |Uses `radis.api` (vaex/HDF5) for HITRAN/HITEMP/ExoMol                                                                                             |Don’t reinvent — wrap `radis` or HAPI                                                                                               |
|RT                   |`ArtEmisPure` (intensity-based n-stream + flux-based 2-stream),  `ArtEmisScat` (Toon flux-adding), `ArtTransPure`                                 |Toon two-stream is the natural v4 starting point                                                                                    |
|Mie                  |`OpaMie` precomputed `miegrid` over log-normal PSDs                                                                                               |Better than recurrence-on-the-fly for retrievals                                                                                    |
|Stack                |Pure functional JAX (NOT Equinox), NumPyro + JAXNS downstream                                                                                     |**The clearest opportunity for the new project: re-frame in Equinox PyTrees for cleaner static/dynamic separation and `filter_jit`**|

ExoJAX is built for **exoplanet transmission/emission with high-T atmospheres**; the Earth-RS use case differs in (i) lower-T line widths and tighter `auto_trange` around 200–320 K, (ii) operational latency requirements, (iii) downstream coupling to instrument noise and plume retrieval rather than HMC posteriors over T-profiles. The algorithmic core is reusable; the surrounding system is not.

**Other JAX/differentiable RT efforts worth knowing:**

- **rte-rrtmgp** has a JAX port branch (alongside Fortran/Julia/C++/Kokkos); useful for broadband Earth GCM-style applications and as a correlated-k reference.
- **Mitsuba 3 / Dr.Jit** (and the **Eradiate** EO toolkit built on it) provide differentiable Monte Carlo path tracing with polarisation; the relevant theory is Zhang et al. 2019 (ACM TOG, “Differential theory of RT”). Salesin et al. 2024 (JQSRT 314) extended Mitsuba 3 to atmosphere–ocean polarimetric RT. These are the long-term references for v5+ Monte Carlo / 3D.
- **PyMieDiff (Jackson et al. 2025, APL Photonics)** is a PyTorch differentiable layered-sphere Mie code with autograd-safe spherical Bessel/Hankel recurrences — port the recurrence stability tricks to JAX for v3.
- **Ray-trax (arXiv:2511.09389)** is a JAX 3-D ray tracer for emission–absorption RT; demonstrates the `vmap` over rays/sources/freq pattern.
- **Emulator-based RT for Earth RS** is mature: **sRTMnet (Brodrick et al. 2021 RSE)** in **ISOFIT** translates 6S → MODTRAN spectra at ~3000× speedup for EMIT operational atmospheric correction; **Verrelst et al. 2016/2017** built GP emulators of MODTRAN/libRadtran with derivative outputs; **Vicent Servera et al. 2022** systematically compared NN/GP/KRR. This is exactly where **gpyroX** belongs in your stack.
- **No mature Equinox-native RT library exists.** That is the gap to fill.

-----

## 3. Staged roadmap

Each version ships a runnable retrieval against real data, accumulates regression benchmarks, and adds one fidelity axis at a time. **Never refactor and add features in the same release.**

### v0 — Clear-sky Beer–Lambert SWIR (4–6 weeks)

**Concrete use case:** AVIRIS-NG / EMIT 2210–2410 nm CH₄ matched-filter target spectrum generator, replacing the MODTRAN lookup currently used by MAG1C and EMIT operational. Deliver scene-specific unit absorption spectra t(SZA, VZA, elevation, column H₂O) that drop directly into the user’s existing matched-filter code, with end-to-end gradients of t w.r.t. atmospheric state.

**Deliverables.**

- HAPI / py4CAtS offline precomputation of (p, T) cross-section tables for CH₄, H₂O, CO₂, N₂O, CO on a coarse pressure–temperature grid covering AFGL US Standard ± realistic departures.
- Beer–Lambert forward model: τ_layer = Σ_gas n_gas · σ_gas(p, T, ν) · Δz; transmission = exp(−τ_total / μ); TOA radiance = solar · transmission · Lambertian_albedo / π; convolve with instrument SRF.
- AFGL atmospheres baked in as pytrees (use the `rayference/afgl1986` CSVs).
- Validate transmittance against py4CAtS at 0.01 cm⁻¹ resolution, target relative error <0.1% in the 2300 nm window.
- Jacobians via `jax.jacrev` for {VMR profiles, T profile, surface albedo, instrument shift}; verify with `gradcheck` (finite differences) on a small reduced state.
- A 10–20-line script that produces MAG1C-style unit absorption spectra t(state) and a finite-difference Jacobian ∂t/∂(XCH₄) matching MODTRAN-derived values within 2%.

**Minimal API surface.** See §7 for the actual code sketch.

### v1 — Geometry, surface, instrument, noise (4–6 weeks)

- **Solar geometry:** μ₀ = cos(SZA), μ = cos(VZA), with pseudo-spherical Chapman-factor air-mass correction for SZA > 70°. Closed-form, trivially differentiable.
- **Surface:** start Lambertian; then add **Ross–Li / RPV / Hapke** kernel BRDFs as swappable Equinox modules satisfying a `BRDF` protocol; later **Cox-Munk** for ocean (port from OSOAA).
- **Instrument line shape:** Gaussian / super-Gaussian / measured-SRF convolution with `jax.numpy.convolve` or FFT; differentiable w.r.t. FWHM and central wavelength shift (essential for spectral calibration retrievals).
- **Noise model:** photon-shot + read-noise + dark + relative spectral covariance; expose as a `NoiseModel` Equinox module returning `Σ_y` for OE.
- **First end-to-end retrieval:** Rodgers OE for {XCH₄, XH₂O, surface albedo polynomial, spectral shift} on EMIT pixels, with Levenberg–Marquardt and `jax.jacrev` providing the K matrix. Benchmark against MAG1C and Thorpe et al. 2023 EMIT operational on the Permian and Turkmenistan plume scenes.

### v2 — Differentiable line-by-line in JAX (8–12 weeks)

The most spectroscopically demanding stage. Implement three opacity engines behind a common `OpacityProvider` protocol:

1. **OpaDirect-style LPF:** per-line Voigt profile via Voigt–Hjerting `hjert(x,a)` (port from ExoJAX `lpf.voigt`), `vmap` over lines and ν. For ν grids ≲10⁴ and lines ≲10⁴, this is fine; useful for high-resolution validation.
2. **MODIT-style DIT/FFT:** lineshape-density matrix on ESLOG ν grid + FFT convolution. Adopt van den Bekerom–Pannier formulation; include Lorentzian-wing aliasing correction.
3. **PreMODIT-style LBD:** precompute Line Basis Density over coarse (E_lower, γ_self/γ_air) grid; runtime cost becomes O(N_grid_cells · N_ν log N_ν), independent of N_lines.

**Physics components, all in pure JAX:**

- **Partition functions** Q(T) from ExoMol/HITRAN states files (`Qr_line(T)`), interpolated/computed differentiably in T.
- **Line strength** S(T) = S(T_ref) · (Q(T_ref)/Q(T)) · exp(−c₂ E″(1/T − 1/T_ref)) · (1 − exp(−c₂ ν₀/T))/(1 − exp(−c₂ ν₀/T_ref)).
- **Broadening:** γ_L(p, T) = (p/p_ref) · [(1−χ_self) γ_air + χ_self γ_self] · (T_ref/T)^n_air ; γ_D from thermal Doppler.
- **Line mixing:** Rosenkranz first-order coefficients for CO₂ Q-branches and O₂ A-band; full relaxation matrix as a v2.5 extension.
- **Continua:** MT_CKD v4.x for H₂O self+foreign continuum (Mlawer et al. 2023, JQSRT 306, 108645);  N₂–N₂ and N₂–O₂ CIA from HITRAN; CO₂ continuum from MT_CKD. **Do not skip the continuum** — even small MT_CKD errors translate to several ppb XCH₄ bias (Mascio et al. 2024, JQSRT 322).
- **HITRAN/HITEMP I/O** via `radis.api` (auto-converts to Vaex/HDF5);  do not reinvent line-list parsing.

**Validation:** transmittance through AFGL US-Standard, Tropical, Sub-Arctic-Winter against py4CAtS and HAPI at 0.01 cm⁻¹, target relative error <0.1% in 2210–2410 nm, 1590–1690 nm (MethaneSAT band), 760 nm (O₂ A-band). Use FP64 throughout; FP32 produces ~10⁻⁷ cm⁻¹ line-center truncation that aliases at TROPOMI resolution.

**Gradient validation:** finite-difference check of ∂(transmittance)/∂(VMR, T, p, line strength) on a coarse grid; this is the most important regression test in the entire roadmap.

### v3 — Single scattering + Rayleigh + aerosols (8–10 weeks)

- **Rayleigh:** closed-form cross-section σ_R(ν) = (24π³/N²λ⁴) · ((n²−1)/(n²+2))² · F_King, with King-correction; differentiable in pressure/density profile.
- **Aerosols:** start with parametric **Henyey–Greenstein** and **double-HG** phase functions (one-line Equinox modules). Then add a **JAX differentiable Mie solver** following PyMieDiff’s autograd-safe spherical Bessel recurrence pattern; ExoJAX’s precomputed `miegrid` over log-normal PSDs is the better operational pattern for retrievals (the size-parameter integral is computed once per refractive index / PSD shape, then interpolated differentiably in PSD parameters).
- **Single-scatter solver:** analytic Beer–Lambert with single-scatter source term integrated along the line of sight; Nakajima–Tanaka TMS correction. Implement exactly per Korkin §3 — analytic single scattering is the gold differentiable building block.
- **Surface coupling:** for non-Lambertian BRDFs include the surface-scattered direct beam in the single-scatter source.

**Validation:** Rayleigh + Lambertian against Coulson–Dave–Sekera analytic tables; Mie cross-sections against `miepython`; AERONET aerosol cases against 6SV.

### v4 — Multiple scattering with implicit differentiation (12–16 weeks)

Add solvers behind a common `RTSolver` protocol, all consuming the same `OpticalProperties` pytree.

1. **Two-stream (Eddington / delta-Eddington / hemispheric mean / quadrature):** closed-form `2×2` per-layer matrices with multi-layer adding (Toon et al. 1989). Implement as `jax.lax.scan` over layers; fully AD-safe.
2. **Toon flux-adding with delta-scaling:** the ExoJAX `ArtEmisScat`/`ArtReflectEmis` scheme (Robinson & Crisp 2018). Differentiable end-to-end.
3. **Doubling–adding** for plane-parallel atmospheres: doubling kernel `R, T = combine(R,T,R,T)` is a chain of small dense linear ops on `(N_streams)²` matrices, AD-friendly; the adding step composes layer (R,T) pairs.
4. **Discrete ordinates (DISORT-like) with N streams:** layer eigendecomposition + block-tridiagonal boundary-value solve. **This is where implicit differentiation matters.** Three sub-decisions:
- Eigendecomposition: use `jax.scipy.linalg.eigh` for symmetric reduced problems; for near-degenerate eigenvalues install a Taylor-series fallback as a `jax.custom_jvp` (per VLIDORT). Use the reduced N×N form (Stamnes & Conklin 1984).
- Boundary-value solve: build the block-tridiagonal system explicitly and solve via **Lineax** (`lineax.linear_solve` with a tridiagonal operator). Lineax provides `custom_vjp` through the solver via `jax.lax.custom_linear_solve`, so backward pass costs one extra solve, never an unrolled differentiation through factorisation.
- Numerical stability: implement DISORT’s exponential-scaling transformation (factor out the homogeneous-solution exponentials before applying boundary conditions) inside a `jax.custom_jvp` so that downstream AD sees only the scaled quantities.
1. **Successive orders of scattering (SOS):** each iteration is an explicit operator → `jax.lax.scan`; can be wrapped in a fixed-point solver with implicit differentiation (`optimistix.FixedPointSolver` or `jaxopt.FixedPointIteration`).
2. **Delta-M scaling + TMS single-scatter correction** as separate modules; both algebraically differentiable.

**Differentiability strategy summary for v4:** scan-based solvers (two-stream, SOS) need no special treatment; the discrete-ordinates block-tridiagonal solve uses Lineax-mediated implicit differentiation; eigendecompositions need a degeneracy-safe `custom_jvp` branch.

### v5+ — Polarisation, ocean–atmosphere, 3-D, emulators

Vector RT (Stokes I, Q, U, V) by promoting scalars to length-4 pytrees and replacing scalar phase functions with 4×4 phase matrices; OSOAA-style Cox-Munk air–sea interface as a boundary operator; 3-D RT via either an SHDOM-like spherical-harmonics + discrete-ordinates iteration (Picard fixed point + Lineax) or differentiable Monte Carlo via Mitsuba 3 / a JAX MC port (use `jax.random` keys and the replay trick); **emulator integration via gpyroX** — train GP/NN surrogates on the v4 forward model for operational throughput, expose them behind the same `RTSolver` protocol so retrievals can pick LBL vs surrogate at runtime.

-----

## 4. Equinox-specific design patterns

### Module structure vs pure functions

Use `eqx.Module` for objects that **carry calibration state** (instrument SRF, noise covariances, surface BRDF kernel parameters, precomputed cross-section tables, PreMODIT LBDs, line lists). Use plain functions for **stateless transforms** (Voigt evaluation given line parameters, Chapman factor, delta-M scaling). The rule is: if you would want to `vmap` the same operation across many *instances*, it’s a module; if across many *inputs* with one set of parameters, it’s a function.

### Pytree design

```
AtmosphericState (eqx.Module)
  ├─ pressure: Float[Array, "n_layer"]
  ├─ temperature: Float[Array, "n_layer"]
  ├─ vmr: dict[str, Float[Array, "n_layer"]]   # 'CH4', 'CO2', 'H2O', ...
  └─ altitude: Float[Array, "n_layer+1"]       # level grid

Geometry (eqx.Module)
  ├─ sza, vza, raa: Float[Array, "n_pix"]
  └─ surface_elevation: Float[Array, "n_pix"]

Surface (eqx.Module, abstract)
  └─ subclasses: Lambertian, RossLi, RPV, Hapke, CoxMunk

Instrument (eqx.Module)
  ├─ srf: Callable                              # static
  ├─ wavelength_grid: Float[Array, "n_band"]   # static
  ├─ spectral_shift: Float[Array, ""]           # learnable
  ├─ fwhm: Float[Array, ""]                     # learnable
  └─ noise: NoiseModel                          # eqx submodule

OpticalProperties (eqx.Module)         # the canonical differentiable interface
  ├─ tau: Float[Array, "n_layer n_nu"]
  ├─ ssa: Float[Array, "n_layer n_nu"]
  └─ phase_moments: Float[Array, "n_layer n_nu n_mom"]
```

Make all numeric fields `Float[Array, ...]` (use `jaxtyping`). Mark genuinely static fields (line-list arrays after loading, SRF samples, ν grid) with `eqx.field(static=True)` so JIT does not retrace.

### Filter-transforms

`eqx.filter_jit` and `eqx.filter_grad` are the default everywhere — they automatically partition pytrees into inexact (traced) and static. Batched retrievals over EMIT swaths use:

```python
@eqx.filter_jit
def retrieve_pixel(state, instrument, surface, geom, y_obs):
    ...

retrieve_swath = eqx.filter_vmap(retrieve_pixel, in_axes=(None, None, None, 0, 0))
```

For Jacobians, use `eqx.filter_jacrev` when the state vector is small (≲ a few hundred entries — typical OE retrievals) and `eqx.filter_jacfwd` when the input dimension is smaller than the output (rare in retrievals). Always `vmap` *outside* `jacrev` over pixel batches, not inside.

### Protocol-based solver swapping

Define abstract base classes / `typing.Protocol` for `OpacityProvider`, `RTSolver`, `BRDF`, `NoiseModel`. A retrieval driver then accepts any concrete combination at construction time, and `eqx.filter_jit` happily compiles distinct combinations. Concrete subclasses:

- `OpacityProvider`: `LookupTableOpacity` (v0), `LPFOpacity`, `ModitOpacity`, `PreModitOpacity` (v2).
- `RTSolver`: `BeerLambertSolver` (v0), `SingleScatteringSolver` (v3), `TwoStreamSolver`, `ToonFluxAdding`, `DiscreteOrdinatesSolver(streams=N)`, `DoublingAdding`, `SOSSolver`, `MonteCarloSolver` (v5+).

### Integration with the user’s stack

- **Optax** → variational/MAP retrieval drivers (Adam for warm-start, L-BFGS via `optax-contrib` or `jaxopt.LBFGS` for refinement, Levenberg–Marquardt as a custom routine using Lineax for the normal equations).
- **NumPyro** → Bayesian retrievals with informative HITRAN-uncertainty priors; HMC-NUTS for plume-emission posteriors with ≲50 unknowns; SVI for swath-scale.
- **BlackJAX** → as alternative MCMC, especially nested sampling for model comparison (full-physics vs proxy retrievals on the same scene).
- **Lineax** → every linear solve (block-tridiagonal in discrete ordinates, normal-equations in Gauss–Newton/LM, preconditioned CG in large-scale retrievals); implicit differentiation through solvers is free.
- **Diffrax** → optional ODE-form RTE along curved paths (limb geometries, pseudo-spherical paths beyond Chapman approximation, line-of-sight integration with refractive bending). Probably not needed v0–v4 for nadir Earth-RS; useful for an eventual limb extension.
- **finitevolx** → the layer-discretisation and grid handling, ensuring optical-depth integration uses the same numerics as your transport solvers.
- **spectraldiffx** → spectral convolution kernels (SRF), high-resolution-to-sensor-grid resampling.
- **geotoolz** → EMIT/PRISMA/EnMAP/Sentinel-2/Sentinel-5P sensor I/O, geometry computation, swath orthorectification.
- **gaussx / gpyroX** → GP-based emulators of the v4 forward model; gpyroX hosts the operational surrogate that mirrors the `RTSolver` protocol so retrieval code is unchanged.
- **plumax** → downstream coupling: the RTM produces the observation operator H(c, e), plumax produces concentration fields c(e, wind, location), composing both gives an end-to-end differentiable emission-rate retrieval (∂y/∂e).
- **somax** → atmospheric correction / scene-level fitting if relevant for sea-surface targets.

-----

## 5. Concrete retrieval applications

### Hyperspectral multi-gas (EMIT, PRISMA, EnMAP, AVIRIS-NG, Tanager-1)

The v0 forward model already replaces the MODTRAN/6S lookup that generates the matched-filter target spectrum t in MAG1C and Foote et al. 2021’s generalised MF. Because t now has analytic gradients in atmospheric state, you can implement an **albedo- and water-corrected MF** that linearises t around per-pixel (or per-cluster) state estimates — a smooth interpolation between MAG1C-class MFs and full IMAP-DOAS. v1+v2 enables full **Rodgers optimal estimation** (state = layer VMRs of CH₄/CO₂/H₂O/N₂O/CO, T-shift, surface polynomial, spectral shift) with K-matrix Jacobians for free. Benchmark against Thorpe et al. 2023 (*Sci. Adv.*) on EMIT plume scenes, Thorpe et al. 2017 IMAP-DOAS on AVIRIS-NG,   and MAG1C on synthetic plumes.

### TROPOMI-style operational (Sentinel-5P)

v3–v4 is required: TROPOMI retrievals need aerosol/cirrus scattering and the O₂ A-band 760 nm + SWIR 2.3 µm joint inversion (RemoTeC/SRON; Lorente et al. 2021 AMT). Build the SCIATRAN/VLIDORT analogue: pseudo-spherical multi-stream discrete ordinates + Raman/Ring (v5), with retrieval state {profile XCH₄, aerosol height/AOT/effective size, surface polynomial}. DOAS-style retrievals fall out as a special case: WFM-DOAS = linearised differential cross-section + low-order polynomial baseline; IMAP-DOAS = full OE in a narrow SWIR window. Use the same Equinox forward model and pick the loss function and regularisation accordingly.

### Multispectral methane (Sentinel-2, Landsat)

v0 suffices: Beer–Lambert with effective AMF (1/μ₀ + 1/μ) and Sentinel-2 B11/B12 SRFs. Implement Varon et al. 2021 (AMT 14, 2771)  SBMP/MBSP/MBMP exactly; the advantage of doing this in your differentiable stack is that **the same forward model trains a Sentinel-2 NN detector** (MethaNet/STARCOP-style) end-to-end with physical regularisation. Connect to plumax for synthetic plume injection.

### Cloud screening / detection

Downstream classifier on top of v3 outputs: cloud-fraction retrieval from the v3 single-scattering forward model, with detection thresholds calibrated against MODIS/VIIRS cloud masks. Differentiable forward enables joint cloud-fraction + trace-gas retrieval rather than sequential masking.

### Plume-to-emission coupling (the MARS payoff)

The end-to-end gradient `∂y/∂e` (TOA radiance with respect to emission rate) is the unique capability that motivates the entire stack. Construction: plumax(e, u, x_source) → ΔVMR(x); RTM(state + ΔVMR, geometry, instrument) → y_pred; loss(y_pred, y_obs). One call to `eqx.filter_grad` gives ∂loss/∂{e, u, x_source, atmospheric_nuisance, instrument_nuisance}. This is the basis for **maximum-likelihood emission retrieval** that does not pass through the IME/CSF heuristics of Varon et al. 2018  — those become Gauss–Newton initialisations.

-----

## 6. Validation strategy

**Per-stage validation matrix:**

|Stage|Reference                      |Benchmark                                                                   |Target accuracy                   |
|-----|-------------------------------|----------------------------------------------------------------------------|----------------------------------|
|v0   |py4CAtS, HAPI                  |AFGL US Standard transmittance, 2210–2410 nm                                |<0.1% relative                    |
|v0   |MAG1C / Foote 2020             |Synthetic plume RMSE on Permian/Turkmenistan                                |<2% of MAG1C                      |
|v1   |EMIT operational (Thorpe 2023) |Real plume XCH₄ retrievals                                                  |<5 ppb median bias                |
|v2   |py4CAtS, HAPI, LBLRTM          |AFGL Tropical/MidLatSummer/SubArcticWinter at 0.01 cm⁻¹ across 700–4000 cm⁻¹|<0.1% relative                    |
|v2   |HITRAN line-by-line            |Single-line Voigt at edge cases (high γ_L/γ_D, near continuum)              |<10⁻⁶ absolute                    |
|v3   |6SV, Coulson tables            |Rayleigh + Lambertian TOA radiance                                          |<0.05%                            |
|v3   |miepython                      |Mie efficiencies and asymmetry parameter                                    |<10⁻⁴ relative                    |
|v4   |DISORT, VLIDORT                |AFGL + aerosol cases, K-matrix Jacobians                                    |<0.5% radiance, <2% Jacobian      |
|v4   |CIRC Case 1–7 (Oreopoulos 2012)|Clear-sky LW/SW fluxes                                                      |match LBLRTM within CIRC tolerance|
|v5   |I3RC, Mitsuba 3 / Eradiate     |3-D cumulus cases                                                           |tolerable MC noise band           |
|All  |finite differences             |`gradcheck` on small reduced states                                         |<10⁻⁴ relative gradient error     |

**Standard benchmarks beyond the table:** AFGL 1986 atmospheres (`rayference/afgl1986`);  CIRC clear-sky cases (Oreopoulos et al. 2012 JGR D06118); RAMI for surface BRDF; HITRAN-2020/2024 (Gordon et al. 2022 JQSRT 277, 107949); MT_CKD v4 H₂O continuum (Mlawer et al. 2023); Coulson–Dave–Sekera tables for polarised Rayleigh.

**Differentiability tests:** `gradcheck` on every public forward function; reciprocity (BRDF and bidirectional radiance); energy conservation in non-absorbing limits (sum of fluxes = 1); reproducibility of VLIDORT analytical Jacobians on Spurr’s published test suite where accessible.

-----

## 6b. Differentiability strategy, component by component

**Where naive AD works:** Voigt–Hjerting function via `jnp` (per ExoJAX), all line-strength/broadening formulas, Chapman factor, Rayleigh σ, Henyey–Greenstein, Lambertian and most kernel BRDFs, layer-wise `jax.lax.scan` for two-stream/SOS, FFT convolution for SRF and MODIT-style opacity. Use `eqx.filter_grad` directly.

**Where `custom_jvp` / `custom_vjp` is needed:**

- Streaming multipliers in discrete-ordinates RT (small denominator μₖ − μ₀⁻¹): install Taylor-series fallback per VLIDORT, ε ≈ 10⁻³, as `jax.custom_jvp`.
- Eigendecomposition with near-degenerate eigenvalues: `jax.scipy.linalg.eigh` is differentiable but fails at degeneracies; wrap with degeneracy-safe `custom_jvp`.
- Mie spherical Bessel/Hankel recurrences at large size parameters: backward recurrence may need a `custom_jvp` to preserve gradient stability (PyMieDiff pattern).
- Voigt at extreme `a, x`: optional `custom_jvp` for asymptotic regimes if pure-`jnp` produces NaN gradients.

**Where implicit differentiation through linear/non-linear solvers is needed:**

- Discrete-ordinates boundary-value problem: block-tridiagonal solve via **Lineax**, which uses `jax.lax.custom_linear_solve` so backward pass is one extra solve.
- Successive-orders / Picard fixed-point iteration: **optimistix** `FixedPointSolver` or `jaxopt.FixedPointIteration` provide implicit differentiation.
- Gauss–Newton / LM inner loops in OE: Lineax for normal-equations solve, optionally with CG/GMRES preconditioning for large state vectors.
- 3-D SHDOM-like iteration in v5+: same pattern.

**Where checkpointing / `jax.checkpoint` is needed for memory:**

- LBL on dense ν grids over many layers: use ExoJAX’s `Opart` pattern (`jax.lax.scan` with checkpointed body) so memory is O(1) in N_layer.
- ν-stitching in PreMODIT: chunk ν into segments with `wing_cut` margin; `scan` over chunks with checkpoint between.
- Discrete-ordinates with many streams and many wavelengths: checkpoint per-layer eigendecomposition.

**Jacobians (K-matrix) vs adjoint:**

- For typical OE retrievals with `n_state ≲ 200` and `n_obs ∼ 10²–10³`, `eqx.filter_jacrev` computes K in one batched pass; this is the right default and replaces VLIDORT’s hand-derived linearisation entirely.
- For very large state vectors (full-profile retrievals, joint atmospheric+emission), use Gauss–Newton with **Lineax CG/GMRES** on the normal equations, never forming K explicitly; the forward model’s `vjp` is the adjoint.
- For analytical Jacobians w.r.t. spectroscopic line parameters (HITRAN uncertainty propagation, à la PyRTlib): autodiff through the line list itself; this is **a unique capability** that lookup-table codes cannot provide.

-----

## 7. v0 starter code sketch

```python
from __future__ import annotations
from typing import Protocol
import equinox as eqx
import jax
import jax.numpy as jnp
from jaxtyping import Array, Float

# --- Pytree state ---------------------------------------------------------

class AtmosphericState(eqx.Module):
    pressure:    Float[Array, "n_layer"]
    temperature: Float[Array, "n_layer"]
    altitude:    Float[Array, "n_layer_plus_one"]
    vmr_ch4:     Float[Array, "n_layer"]
    vmr_h2o:     Float[Array, "n_layer"]
    vmr_co2:     Float[Array, "n_layer"]
    vmr_n2o:     Float[Array, "n_layer"]

class Geometry(eqx.Module):
    mu0: Float[Array, ""]          # cos(SZA)
    mu:  Float[Array, ""]          # cos(VZA)

class LambertianSurface(eqx.Module):
    albedo: Float[Array, "n_nu"]   # spectral albedo

class Instrument(eqx.Module):
    nu_hi:        Float[Array, "n_nu_hi"]      = eqx.field(static=True)
    nu_sensor:    Float[Array, "n_band"]       = eqx.field(static=True)
    srf_kernel:   Float[Array, "n_band n_nu_hi"] = eqx.field(static=True)
    spectral_shift: Float[Array, ""]           # learnable wavenumber shift

    def convolve(self, radiance_hi):
        # SRF integration; SRF kernel pre-normalised
        shifted = jnp.interp(self.nu_hi + self.spectral_shift,
                             self.nu_hi, radiance_hi)
        return self.srf_kernel @ shifted

# --- Opacity provider (v0: precomputed cross-section LUT) -----------------

class OpacityProvider(Protocol):
    def __call__(self, state: AtmosphericState,
                 nu: Float[Array, "n_nu"]) -> Float[Array, "n_layer n_nu"]:
        ...

class LookupTableOpacity(eqx.Module):
    # cross sections σ_g(p, T, ν) precomputed on a coarse (p,T) grid
    p_grid:  Float[Array, "n_p"]              = eqx.field(static=True)
    T_grid:  Float[Array, "n_T"]              = eqx.field(static=True)
    nu_grid: Float[Array, "n_nu"]             = eqx.field(static=True)
    sigma:   dict[str, Float[Array, "n_p n_T n_nu"]]    # static after loading

    def __call__(self, state, nu):
        # bilinear interpolation in (log p, T) for each layer and gas
        layer_tau = jnp.zeros((state.pressure.shape[0], nu.shape[0]))
        dz = jnp.diff(state.altitude)
        N_air = state.pressure / (1.380649e-23 * state.temperature)  # m^-3
        for gas, vmr in [("CH4", state.vmr_ch4), ("H2O", state.vmr_h2o),
                         ("CO2", state.vmr_co2), ("N2O", state.vmr_n2o)]:
            sig = bilinear(self.sigma[gas], jnp.log(state.pressure),
                           state.temperature, self.p_grid, self.T_grid)
            #  sig shape: (n_layer, n_nu)
            layer_tau = layer_tau + sig * (vmr * N_air * dz)[:, None]
        return layer_tau

def bilinear(table, x, y, x_grid, y_grid):
    # placeholder: AD-safe bilinear interpolator over (x, y) per layer
    ...

# --- v0 forward model: Beer–Lambert TOA radiance --------------------------

class BeerLambertSolver(eqx.Module):
    solar_irradiance: Float[Array, "n_nu_hi"]  = eqx.field(static=True)

    def __call__(self, tau_layer, surface, geom):
        tau_col = tau_layer.sum(axis=0)                  # (n_nu_hi,)
        amf = 1.0 / geom.mu0 + 1.0 / geom.mu
        T = jnp.exp(-amf * tau_col)
        # Lambertian TOA radiance (no scattering)
        L = self.solar_irradiance * geom.mu0 / jnp.pi * surface.albedo * T
        return L

class ForwardModel(eqx.Module):
    opacity:    eqx.AbstractVar[OpacityProvider]
    solver:     BeerLambertSolver
    instrument: Instrument

    def __call__(self, state, surface, geom):
        tau = self.opacity(state, self.instrument.nu_hi)
        L_hi = self.solver(tau, surface, geom)
        L_sensor = self.instrument.convolve(L_hi)
        return L_sensor

# --- JIT + Jacobians ------------------------------------------------------

@eqx.filter_jit
def predict(fm: ForwardModel, state, surface, geom):
    return fm(state, surface, geom)

# K-matrix Jacobian w.r.t. selected scalar parameters of the state
def K_xch4_shift_albedo(fm, state, surface, geom):
    def f(xch4_scale, shift, alb_scale):
        s = eqx.tree_at(lambda s: s.vmr_ch4, state, state.vmr_ch4 * xch4_scale)
        i = eqx.tree_at(lambda i: i.spectral_shift, fm.instrument, shift)
        srf = eqx.tree_at(lambda s: s.albedo, surface, surface.albedo * alb_scale)
        fm2 = eqx.tree_at(lambda m: m.instrument, fm, i)
        return fm2(s, srf, geom)
    return jax.jacrev(f, argnums=(0, 1, 2))(1.0, 0.0, 1.0)

# Batched retrieval over an EMIT swath
batched_predict = eqx.filter_vmap(predict, in_axes=(None, 0, 0, 0))
```

This skeleton is JIT-compatible, `jacrev`/`jacfwd`-clean, and structurally extends to v1–v4: replace `LookupTableOpacity` with `PreModitOpacity`; replace `BeerLambertSolver` with `SingleScatteringSolver` or `DiscreteOrdinatesSolver`; replace `LambertianSurface` with `RossLiBRDF`. The retrieval driver (Levenberg–Marquardt with Lineax for normal equations, or NumPyro HMC) sits on top unchanged.

-----

## 8. Reading list and benchmarks

**Foundational textbooks.** Liou, *An Introduction to Atmospheric Radiation* (2nd ed., 2002); Thomas & Stamnes, *Radiative Transfer in the Atmosphere and Ocean* (Cambridge, 2nd ed., 2017) — the canonical pedagogical references for v1–v4; Mishchenko, Travis & Lacis, *Scattering, Absorption, and Emission of Light by Small Particles* (Cambridge, 2002, free PDF) for vector RT and particle scattering; Bohren & Huffman, *Absorption and Scattering of Light by Small Particles* (Wiley, 1983) for Mie; Rodgers, *Inverse Methods for Atmospheric Sounding* (World Scientific, 2000) — every retrieval choice in this design ultimately answers to chapter 4 of Rodgers; Chandrasekhar, *Radiative Transfer* (Dover, 1960) for the analytic single-scattering and Rayleigh foundations the Korkin paper builds on.

**Spectroscopy.** Gordon et al. 2022 *JQSRT* 277, 107949 (HITRAN-2020); Rothman et al. 2010 *JQSRT* 111, 2139 (HITEMP); Mlawer et al. 2023 *JQSRT* 306, 108645 (MT_CKD v4);  Schreier et al. 2019 *Atmosphere* 10 (py4CAtS);  Kochanov et al. 2016 *JQSRT* 177, 15 (HAPI).

**Classical RT codes.** Stamnes et al. 1988 *Appl. Opt.* 27, 2502 (DISORT);  Spurr 2006 *JQSRT* 102, 316 (VLIDORT  — read this for the linearisation playbook); Spurr & Christi 2014 (profile vs bulk Jacobians); Eriksson et al. 2011 *JQSRT* 112, 1551 and Buehler et al. 2005 (ARTS); Mayer & Kylling 2005 *ACP* 5, 1855  and Emde et al. 2016 *GMD* 9, 1647 (libRadtran);  Rozanov et al. 2014 *JQSRT* 133, 13 (SCIATRAN); Bourassa et al. 2008 *JQSRT* 109, 52 (SASKTRAN);  Saunders et al. 2018 *GMD* 11, 2717 (RTTOV); Evans 1998 *JAS* 55, 429 (SHDOM); Kotchenova & Vermote 2007 *Appl. Opt.* 46, 4455 (6SV);  Berk et al. 2014 *SPIE* 9088 (MODTRAN6). 

**Differentiable / modern.** Kawahara et al. 2022 *ApJS* 258, 31 and Kawahara et al. 2025 *ApJ* (ExoJAX I, II); Ukkonen 2020 *JAMES* and Ukkonen et al. 2023 *GMD* 16, 3241 (RRTMGP-NN); Zhang et al. 2019 *ACM TOG* 38, “Differential theory of radiative transfer”; Salesin et al. 2024 *JQSRT* 314, 108847 (differentiable atmosphere–ocean Mitsuba 3); Doicu & Efremenko 2019 *MDPI Atmosphere* (linearised 3-D SHDOM); Brodrick et al. 2021 *RSE* (sRTMnet); Verrelst et al. 2016 *RSE* (GP emulators); Larosa et al. 2024 *GMD* 17, 2053 (PyRTlib);   Jackson et al. 2025 *APL Photonics* 11, 046114 (PyMieDiff).

**Methane retrievals.** Foote et al. 2020 *IEEE TGRS* 58 (MAG1C); Foote et al. 2021 *RSE* (scene-specific MF); Thorpe et al. 2014, 2017 *AMT* (IMAP-DOAS for AVIRIS-NG);  Thorpe et al. 2023 *Sci. Adv.* 9, eadh2391 (EMIT operational); Lorente et al. 2021 *AMT* 14, 665 (RemoTeC TROPOMI); Varon et al. 2018 *AMT* 11, 5673 (IME)  and 2021 *AMT* 14, 2771 (Sentinel-2);  Jongaramrungruang et al. 2022 *RSE* (MethaNet); Cusworth et al. 2022 *PNAS* (PRISMA point sources); Chan Miller et al. 2024 *AMT* 17, 5429 (MethaneSAT proxy).

**Benchmarks.** Anderson et al. 1986 AFGL-TR-86-0110 (atmospheres; CSV at `github.com/rayference/afgl1986`);  Oreopoulos et al. 2012 *JGR* 117, D06118 (CIRC); Cahalan et al. 2005 *BAMS* 86 (I3RC); RAMI at `rami-benchmark.jrc.ec.europa.eu`.

**The user’s reference paper.** Korkin, Sayer, Ibrahim & Lyapustin 2022 *Comp. Phys. Comm.* 271, 108198.   Code: `github.com/korkins/gsit`. Read for the modular skeleton and the “make it right then make it fast” philosophy; do not expect spectroscopy or differentiability lessons.

-----

## Conclusion: where the bets are

The strongest single bet in this design is to **make `OpticalProperties = {τ, ω, B_ℓ, surface_kernels}` the canonical differentiable interface** and let `jax.jacrev` replace VLIDORT’s hand-derived K-matrix machinery. This is the architectural insight that makes a JAX/Equinox RTM strictly better than the heritage Fortran codes for retrievals — not faster (VLIDORT is fast), not more accurate (DISORT is the reference), but **vastly easier to evolve**: every change in spectroscopy, surface model, or aerosol parameterisation gets exact Jacobians for free, with no derivative-code refactor. The risks are concentrated in two places — eigendecomposition near-degeneracy in v4 and Voigt/Mie gradient stability — and both have published mitigations (VLIDORT Taylor branches, PyMieDiff recurrences) that port cleanly into `jax.custom_jvp`.

The closest existing system is **ExoJAX**, and the cleanest description of the project’s contribution is *“ExoJAX for Earth, in Equinox, coupled to plumax for end-to-end emission retrieval”*. The largest gap in the literature it fills is an open, autodiff-native, retrieval-grade Earth-RS RTM that the methane community can iterate without proprietary or registration-gated tools. Stage v0 ships in weeks and immediately replaces MODTRAN/6S in matched-filter target generation; v2 closes the spectroscopy gap with HITRAN; v4 closes the scattering gap with DISORT/VLIDORT-equivalence; v5+ opens the door to differentiable 3-D RT for cloud tomography and joint plume/atmosphere inversion that no operational code currently offers.