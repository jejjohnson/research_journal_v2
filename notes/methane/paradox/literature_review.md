---
title: "Bibliography: The Methane Missing Mass Paradox"
subtitle: Supporting Literature for the Thinned Marked Temporal Point Process Framework
---

This bibliography groups the foundational and supporting literature for each mathematical and physical dimension of the Missing Mass Paradox document. References are organised by the specific claim or architectural component they justify.

---

## 1. Satellite Methane Retrieval & Remote Sensing Platforms

These references establish the physical basis for satellite-based methane column retrieval — the measurement layer that produces the raw observations our framework operates on.

- {cite:t}`jacob2022quantifying` — *Canonical review*. Defines the taxonomy of area flux mappers vs. point source imagers. Establishes SWIR backscatter retrieval fundamentals, detection limits, and the multi-scale observing system architecture.

- {cite:t}`lorente2021tropomi` — *Justifies the TROPOMI retrieval chain*. Documents the RemoTeC full-physics algorithm, albedo-dependent biases, and validation against TCCON and GOSAT.

- {cite:t}`ehret2022sentinel2` — *Multi-temporal Sentinel-2 detection*. Demonstrates the single-band multi-pass (SBMP) retrieval method and documents how observed emission frequencies diverge from the true power-law distribution at low rates due to detection limits — directly supporting the PoD thinning concept.

- {cite:t}`irakulis2023automated` — *TROPOMI machine-learning detection*. Demonstrates automated plume detection via neural networks and the tip-and-cue workflow with high-resolution instruments (GHGSat, PRISMA, Sentinel-2).

- {cite:t}`shen2022quantification` — *TROPOMI Bayesian inversion*. Basin-level methane quantification using a high-resolution atmospheric inverse analysis validated against field measurements.

- {cite:t}`jervis2025global` — *GHGSat constellation global estimate*. Demonstrates facility-level satellite detection globally, revealing the intermittent nature of emissions — key evidence for the temporal point process model.

- {cite:t}`ruzicka2023semantic` — *Oxford/NIO.space*. Hyperspectral ML detection achieving 81% accuracy for large plumes with significantly reduced false positive rates.

- {cite:t}`dumont2024vision` — *MARS-S2L / Sentinel-2 deep learning*. Detection down to 200–300 kg/hr plumes, an order-of-magnitude improvement in multispectral data, with deployment in 20 countries for MARS notifications.

- {cite:t}`esaeo4soc2024hyperspectral` — *ESA benchmark narrative*. Overview of detection approaches across sensor families (multispectral, hyperspectral, thermal), useful for contextualising why different platforms have fundamentally different PoD curves.

- {cite:t}`deconcepcion2022prisma` — *PRISMA ML detection*. Demonstrates deep learning plume detection on PRISMA hyperspectral imagery, relevant to the expanding family of ML-based retrievals that feed into MARS-style operational systems.

---

## 2. Flux Quantification: IME and Cross-Sectional Methods

These references justify Dimension 2 of the paradox document — the translation from satellite pixel measurements to the continuous emission rate $Q$ [kg hr$^{-1}$] that serves as the mark in the point process.

- {cite:t}`varon2018ime` — *Foundational IME paper*. Introduces the Integrated Mass Enhancement method using WRF-LES simulations. Derives the $Q = \text{IME} \cdot U_{\text{eff}} / L$ relationship and quantifies errors of 0.07–0.17 t/hr + 5–12%.

- {cite:t}`varon2024uplume` — *Automated IME pipeline*. U-Net segmentation + IME/CNN quantification. Demonstrates wind speed as the dominant error source at low speeds and masking error at high speeds, with 2–4 m/s as the optimal detection window.

- {cite:t}`sanchez2022worldview` — *High-resolution IME application*. Demonstrates the column enhancement to kg/m$^2$ conversion step at very fine spatial scales.

- {cite:t}`nist8575_2025` — *Community consensus document*. Defines IME and CSF methods, parametric PoD curves, validation protocols, and open issues in the quantification pipeline.

- {cite:t}`jrc_sentinel_hotspot` — *Application-focused Sentinel-5P/TROPOMI hotspot quantification*. Demonstrates the operational pipeline from TROPOMI column enhancements to source-rate estimates for European hotspots.

- {cite:t}`cusworth2022landfills` — *Satellite plume quantification for non-O&G sources*. Extends IME-based quantification to landfill super-emitters with practical uncertainty discussion, demonstrating that the PoD-thinning framework applies across sectors.

---

## 3. Emission Rate Distributions: The Heavy Tail and Lognormal Prior

These references establish the statistical foundation for the mark distribution $f(Q)$ — the lognormal (or heavier-tailed) distributions that create the conditions for the paradox.

- {cite:t}`brandt2016extreme` — *Seminal extreme-value analysis*. Analyses ~15,000 measurements from 18 studies. Proves all natural gas leakage datasets are statistically heavy-tailed. Establishes the "5/50 rule" (top 5% of leaks $\rightarrow$ >50% of volume). Notes that lognormal fits underrepresent the true tail severity.

- {cite:t}`frankenberg2016fourgcorners` — *First airborne heavy-tail confirmation*. Over 250 point sources following a lognormal distribution, with top 10% explaining ~50% of total point source flux.

- {cite:t}`alvarez2018supply` — *National supply chain estimate*. Facility-level probability distributions capturing the heavy tail. Finds U.S. O&G methane emissions ~60% higher than EPA inventory, largely due to missed super-emitters.

- {cite:t}`zavala2017superemitters` — *Mechanistic super-emitter explanation*. Monte Carlo aggregation of component-level emissions showing that abnormal process conditions (equipment malfunctions, stuck valves) — not design operations — explain the heavy tail.

- {cite:t}`zavala2015functional` — *Functional super-emitter framework*. Defines super-emitters via proportional loss rates; functionally super-emitting sites account for ~75% of total emissions in the Barnett Shale.

- {cite:t}`chen2023extension` — *Extended distribution via LiDAR*. Joint lognormal/generalised-lognormal fits combining Bridger LiDAR (low-rate sensitivity) with Carbon Mapper (heavy tail). Directly estimates the $P_{50}$ detection threshold of the CM 2019 campaign at 280 kg/hr at 50% PoD.

- {cite:t}`duren2019california` — *Statewide super-emitter survey*. 272,000 infrastructure elements surveyed; 564 point sources detected; 10% of sources $\rightarrow$ 60% of emissions. Lognormal fits to the emission distribution. Detection limits explicitly acknowledged as truncating the observed distribution.

- {cite:t}`williams2025small` — *Challenges the super-emitter-only mitigation narrative*. Shows 70% of total U.S. O&G methane comes from facilities emitting below typical satellite detection limits — quantifying the "invisible mass" the paradox describes.

- {cite:t}`zimmerle2015transmission` — *T&S sector distributions*. Equipment-level emission data are highly skewed with long tails; super-emitters modeled at the facility level using tracer flux measurements.

- {cite:t}`lauvaux2022ultraemitters` — *Global TROPOMI ultra-emitter census*. Ultra-emitters contribute 8–12% of global O&G production methane emissions (~8 Mt/yr). Establishes the power-law regime at the extreme tail.

- {cite:t}`og_supply_chain2025` — *Contemporary review of O&G methane measurement frameworks*. Provides broad context for how emission distributions are constructed from heterogeneous measurement campaigns, and how inventory methods interact with the heavy-tail problem.

- {cite:t}`global_survey2025landfill` — *Direct empirical manifestation of the paradox in the waste sector*. Global satellite survey showing that uncertainty in landfill methane is driven by the unobserved tail of small/transient sources — exactly the "missing mass" the paradox framework describes. Demonstrates that the thinning problem is cross-sectoral, not limited to O&G.

- {cite:t}`zavala2017reconciling` — *Bottom-up/top-down reconciliation via component distributions*. Tabulates facility-type emission rate distributions and shows how aggregating component-level skewed distributions produces the observed site-level heavy tail. A key reference for justifying the FacilityConfig parameter ranges ($\mu$, $\sigma$) in the paradox scenarios.

- {cite:t}`jakkala2022probgas` — *GEV Type II and Gaussian priors for leak-rate estimation*. Demonstrates how prior choice (GEV vs Gaussian) drives posterior convergence to true leak rate using in-situ sensors — directly relevant to the Bayesian un-thinning inversion where the assumed $f(Q)$ prior determines the recovered "missing" tail.

- {cite:t}`nordstrom2022pipeline_dispersion` — *Fence-line sensor PoD characterisation*. Detection time and quantification accuracy as function of emission rate and atmospheric stability at typical O&G well-pad sizes. Provides ground-level PoD evidence complementing the satellite-based characterisations.

---

## 4. Probability of Detection (PoD): The Atmospheric Filter

These references directly justify Dimension 3 — the logistic sigmoid PoD curve $P_d(Q)$ and the concept of size-dependent detection probability acting as a stochastic thinning operator.

- {cite:t}`ayasse2025probability` — *Direct PoD empirical estimation*. Coincident GAO airborne + EMIT satellite observations. Derives logistic PoD models; finds EMIT 90% PoD at ~1060 kg/hr at 3 m/s wind. Derives a Bayesian model for inferring whether non-detections are "truly off" — directly relevant to the thinning framework.

- {cite:t}`cusworth2025multiscale` — *PoD–area emission bridge*. Explicitly models the logistic PoD as $P_d(Q)$ with $P_{50}$ parameter. Shows how the tail of the observed distribution, filtered through the PoD, still correlates with area emissions. Directly frames the emission rate PDF $\times$ PoD product that defines the thinned process.

- {cite:t}`roger2025offshore` — *Parametric PoD models for EnMAP and EMIT*. Generates PoD as a function of emission rate, at-sensor radiance, and wind speed. Demonstrates that spatial resolution and retrieval precision are the two dominant factors.

- {cite:t}`delfonso2025offshore` — *Explicit PoD sigmoid parameters*. Reports PoD at 10%, 50%, and 90% thresholds across wind speed $\times$ flux space for both EnMAP and EMIT. EnMAP PoD$_{50}$ $\approx$ 7 t/h; EMIT PoD$_{50}$ $\approx$ 7 t/h with complementary trade-offs (minimum detectable plume area: EnMAP 9,000 m$^2$, EMIT 36,000 m$^2$). **Directly feeds the logistic model parameters for these two sensors.**

- {cite:t}`sherwin2024singleblind` — *Multi-platform PoD validation*. Controlled release experiments testing detection thresholds across platforms, establishing empirical basis for the logistic PoD assumption.

- {cite:t}`sherwin2022multiblind` — *Earlier multi-blind validation*. Large-volume controlled releases testing Bridger, Carbon Mapper GAO, MethaneAIR, and satellite sensors; 78% of quantification estimates fell within $\pm$50% of metered values. Establishes the quantification error distribution that propagates into the mark uncertainty budget.

- {cite:t}`sherwin2023tiered_ldar` — *Two-state Markov + PoD model for LDAR*. Models leak creation/repair as a two-state Markov chain; draws from known frequency/size distributions at production facilities. Bridges PoD curves to operational LDAR design and provides a renewal process framework for the paradox's inter-event time model.

- {cite:t}`guanter2024mars_ai` — *MARS-S2L operational PoD*. Documents the MARS AI system's detection performance across 12 geographic regions, explicitly modelling observed emission frequencies as the true power-law distribution filtered through the PoD logistic function.

---

## 5. Emission Intermittency, Persistence & Temporal Point Processes

These references justify Dimension 1 — modelling the emission timeline as a general temporal point process with variable intensity, intermittency, and memory effects.

- {cite:t}`cusworth2021intermittency` — *Key intermittency study*. 1100 unique heavy-tailed sources in the Permian sampled $\geq$3 times (avg 8). Average persistence only 26%. Sources at 50–100% persistence represent 11% of infrastructure but 29% of quantified emissions — motivating the non-homogeneous intensity function.

- {cite:t}`biener2024gulf` — *Longitudinal Gulf persistence*. Multi-year aircraft + GHGSat study. Defines "Chance of Subsequent Detection" (CSD): 74% average for emitting hubs. Eight facilities contribute 50% of total emissions at >80% persistence — justifying the compound Poisson framework with heterogeneous rates.

- {cite:t}`plant2024geostationary` — *Sub-hourly temporal resolution*. 5-minute GOES imagery tracking a 3-hour pipeline release at 260–550 t/hr. Demonstrates that extreme events can last less than an hour with variable source rates — fundamentally challenging the constant-$\lambda$ Poisson assumption for ultra-emitters.

- {cite:t}`johnson2021temporal` — *4-year single-site longitudinal study*. 17 audits showing emissions varying from 78 g/hr to 43 kg/hr — lognormally distributed. A single tank measurement represented 60% of cumulative emissions, demonstrating extreme within-site temporal variability.

- {cite:t}`allen2017temporal` — *Design-driven intermittency*. Documents that liquid unloadings, blowdowns, and startups are highly intermittent by design with predictable diurnal variations — supporting the non-homogeneous Poisson intensity $\lambda(t) = A + B\sin(\omega t + \varphi)$.

- {cite:t}`zhu2022temporal` — *Emission grade categorization*. Introduces a temporal grading scheme for methane sources based on emission variability, providing a discrete framework for classifying the persistence parameter space.

- {cite:t}`alden2021longterm` — *Multi-year single-site temporal variability*. Complements {cite:t}`johnson2021temporal` with an independent longitudinal dataset showing that within-site emission variability spans orders of magnitude over months to years.

- {cite:t}`escape2021model` — *Atmospheric transport variability independent of source*. Surface CH$_4$ concentrations above a pipeline leak vary up to 4$\times$ with atmospheric stability changes alone, independent of the true leak rate. This is a direct atmospheric-layer contribution to the mark observation noise — even if $Q$ is constant, the measured $\hat{Q}$ fluctuates due to transport, compounding the PoD thinning.

- {cite:t}`omara2018temporal_meet` — *Temporally and spatially resolved inventory emission model*. Captures diurnal and event-driven $\lambda(t)$ structure for compressor stations. Provides the emission process model that generates the non-homogeneous intensity function underlying the paradox's temporal dimension.

- {cite:t}`pipeline_leak2022dispersion` — *Minimum duration constraint for $D$*. Finds that at least 6 hours of continuous data are needed for representative emission estimates from subsurface pipeline leaks ($\pm$27% accuracy). Directly constrains the "event duration $D$" parameter — events shorter than this monitoring threshold produce biased $Q$ estimates.

- {cite:t}`nordstream2024` — *Compound Poisson event reconstruction*. Time-varying source rate inversion from a large-scale impulsive emission event; the observation model is effectively a compound Poisson process with Gaussian atmospheric transport. Demonstrates how the marked temporal point process framework applies to extreme, singular events.

---

## 14. Temporal Point Processes: Theoretical Foundations

These references justify the formal mathematical vocabulary of the paradox document — intensity functions $\lambda(t)$, thinning of point processes, self-exciting processes, renewal theory, and compound Poisson total mass. This section anchors the applied methane framework to the broader statistical literature on temporal point processes.

### 14.1 Non-Homogeneous Poisson Processes (NHPP)

- {cite:t}`chavez_nhpp_airpollution` — *Direct atmospheric-science NHPP reference*. Asymptotic theory supporting the NHPP approximation for non-stationary pollution events; step-rate $\lambda(t)$ estimation via MCMC. The closest methodological ancestor to the paradox's treatment of emission event arrival rates.

- {cite:t}`nhpp_air_quality` — *Bayesian NHPP for count data*. Compares multiple prior distributions for NHPP inference. Motivates the Bayesian treatment of $\lambda(t)$ in the MARS un-thinning inversion, showing how prior choice affects posterior intensity estimates.

### 14.2 Hawkes / Self-Exciting Processes

- {cite:t}`hawkes_applications2024` — *Comprehensive Hawkes review*. Exponentially decaying excitation kernel, cluster structures, MLE estimation. Relevant if valve pressure-relief events are self-exciting — each blowout can trigger follow-on events before the system re-pressurises, creating the temporal clustering observed in intermittency data.

- {cite:t}`hawkes_env2021` — *Inhibitory + self-exciting components in environmental contexts*. Extends the standard Hawkes process to include environmental covariates that can suppress or amplify the intensity. Bridges ecological/environmental time-series modelling to leak clustering, where atmospheric conditions may modulate both the true emission rate and the detection probability.

- {cite:t}`hawkes_coating2025` — *Marked TPP factored form*. Derives the factored intensity $\lambda(t, m \mid \mathcal{H}_t) = \lambda_g(t \mid \mathcal{H}_t) \cdot f(m \mid t, \mathcal{H}_t)$ for discrete degradation events. This is exactly the mathematical structure underlying the paradox's Sections 4–6: the ground-process intensity (temporal arrival) and conditional mark density (flux given arrival) are treated as separable factors, with the PoD acting as a thinning operator on the joint process.

- {cite:t}`stelfi2024hawkes` — *Practical implementation reference*. R package for Hawkes and LGCP models for ecological and environmental spatiotemporal data. Provides ready-made tools for fitting the self-exciting and Cox process variants of the emission arrival model.

### 14.3 Marked Point Processes and Thinning

- {cite:t}`daniels2025bayesian` — *Spike-and-slab Bayesian hierarchical model*. Validated against METEC controlled releases; models intermittent O&G emissions as a sparse marked process. Directly implements the $\lambda_{\text{obs}} \rightarrow \lambda_{\text{true}}$ un-thinning inversion. The spike-and-slab prior naturally handles the zero-inflation (non-emission) vs active-emission dichotomy.

### 14.4 Renewal Processes and Inter-Arrival Times

- {cite:t}`weibull_renewal` — *Weibull renewal process theory*. Motivates the Weibull inter-arrival model for mechanical pressure-relief valve recharge times (Section 7.2 of the paradox document). When the shape parameter $\beta > 1$, events exhibit increasing hazard (wear-out), consistent with degrading equipment; $\beta < 1$ implies decreasing hazard (post-repair infant mortality), relevant to freshly serviced infrastructure.

- {cite:t}`sherwin2023tiered_ldar` — *Two-state Markov as renewal process*. The leak creation/repair model is effectively a renewal process with two absorbing states, providing the inter-event time distribution that feeds into the compound Poisson total mass calculation.

### 14.5 Compound Poisson and Total Mass

- {cite:t}`omara2018temporal` — *Basin-scale compound Poisson structure*. The basin emission rate as a sum of independent random marks on a Poisson timeline is the implicit structure of the episodic venting model. The total mass $\mathbb{E}[M] = \Lambda \cdot \mathbb{E}[Q] \cdot D$ follows directly from the compound Poisson expectation.

- {cite:t}`nordstream2024` — *Reconstructed time-varying source rate*. The observation model for the Nord Stream event is effectively a compound Poisson with Gaussian transport — a single massive "mark" observed through the atmospheric filter.

---

## 6. Survivorship Bias & Observational Selection Effects

These references provide the conceptual and statistical foundation for the core paradox — that size-dependent detection creates a survivorship bias that simultaneously inflates the observed mean while deflating the total mass.

- {cite:t}`wald1943survivorship` — *The original survivorship bias framework*. Wald's WWII bomber armour analysis is the direct conceptual ancestor of the Missing Mass Paradox: damage observed on returning aircraft (= surviving marks) systematically misrepresents the full population.

- {cite:t}`cusworth2025multiscale` — *Explicit formulation of PoD $\times$ $f(Q)$*. The paper directly writes the product of the emission rate PDF and the PoD function, shows how instruments with different $P_{50}$ values sample different tails of the same distribution — formalising the thinned marked process in the methane context.

- {cite:t}`williams2025small` — *Quantifies the "missing mass" empirically*. Shows that 70% of emissions come from sources below typical satellite detection limits — the "destroyed" events in Phase 1 of the paradox.

- {cite:t}`ayasse2025probability` — *Bayesian non-detection model*. Derives a posterior probability that a non-detection is a true absence vs. a detection failure — the statistical inverse of the thinning operator.

---

## 7. The MARS Platform & Operational Notification System

These references anchor the paradox framework to the real-world MARS system that motivates the engineering metrics in Section 7 of the document.

- {cite:t}`unepMars2022` — *System description*. MARS is the first public global satellite detection-and-notification system for methane, combining data from >12 satellite instruments with AI-driven detection.

- {cite:t}`irakulis2024marsOps` — *MARS operational status*. Documents the notification pipeline, stakeholder response rates, and confirmed mitigations across four continents.

- {cite:t}`guanter2024mars_ai` — *MARS-S2L deployment*. 1,015 notifications in 20 countries, 6 verified permanent mitigations including a 25-year emitter in Algeria. Documents the operational PoD performance that the paradox framework is designed to correct.

---

## 8. Bayesian Inversion, Priors & Atmospheric Transport

These references justify the statistical inversion framework — using Bayesian methods with prior emission distributions to "un-thin" the observed data and recover the true emission field.

- {cite:t}`maasakkers2021global` — *Global Bayesian inversion with priors*. GOSAT-based global emission estimates using prior inventories and posterior optimisation — the large-scale analogue of our point-source inversion.

- {cite:t}`lu2022emissions` — *Multi-scale inversion*. Demonstrates how prior emission distributions and their uncertainties propagate through the inversion to posterior estimates.

- {cite:t}`varon2022continuous` — *Temporal averaging with wind rotation*. Addresses the challenge of intermittent plumes by averaging over multiple passes — implicitly correcting for the temporal thinning.

---

## 9. Review Articles & Synthesis

These comprehensive reviews place the individual components in context and provide additional entry points into the literature.

- {cite:t}`jacob2022quantifying` — *The* review paper for satellite methane.

- {cite:t}`brandt2014north` — *Seminal perspective*. Established the top-down vs. bottom-up discrepancy narrative.

- {cite:t}`erland2022advances` — *Transparency review*. Surveys the state of the art in measurement, reporting, and verification (MRV) for methane.

- {cite:t}`jiang2024retrieval` — *Retrieval algorithm taxonomy*. Comprehensive review of full-physics, CO$_2$ proxy, optimal estimation, and ML retrieval approaches.

- {cite:t}`falaki2025advancements` — *Most recent systematic review*. Covers detection, quantification, and monitoring from a broad survey of the satellite methane literature.

- {cite:t}`pinto2025monitoring` — *Cross-sector review*. Covers oil & gas, coal, agriculture, and waste sectors with an integrated assessment of instruments, retrievals, and sector-specific applications.

---

## 10. Controlled Release Validation & Multi-Platform Benchmarks

These references provide the empirical ground truth for PoD curves and quantification accuracy — the controlled experiments that validate the logistic detection model.

- {cite:t}`sherwin2024singleblind` — *Multi-platform PoD benchmark*. Controlled release experiments comparing detection thresholds, false alarm rates, and quantification accuracy across nine satellite/airborne systems. Directly validates the logistic PoD assumption.

- {cite:t}`tadi2026controlled` — *Updated controlled release results*. Extends {cite:t}`sherwin2024singleblind` with emphasis on detection/quantification variability drivers under different environmental conditions.

---

## 11. Platform Families (The MARS Multi-Satellite Architecture)

These references justify why the MARS system draws from >12 satellite instruments with heterogeneous PoD curves — each instrument samples a different region of the $f(Q) \times P_d(Q)$ product space.

### Sentinel-5P / TROPOMI

- {cite:t}`lorente2021tropomi` — TROPOMI retrieval chain and validation.

- {cite:t}`maasakkers2022national` — National-scale methane quantification using TROPOMI high-resolution inversions.

- {cite:t}`tropomi_pum` — *Official L2 methane product documentation*. Defines retrieval specifications, quality flags, and known limitations that determine the instrument's effective PoD at coarse resolution.

- {cite:t}`schneising2024tropomi_persistent` — *Multi-year TROPOMI persistence survey*. Identifies 217 persistent plume source regions accounting for ~20% of bottom-up emissions. Demonstrates a strongly size-dependent TROPOMI detection filter — only the largest, most persistent sources survive TROPOMI's coarse PoD, directly illustrating the thinning mechanism at the area-mapper scale.

- {cite:t}`segers2025tropomi_trust` — *Sensitivity and robustness analysis*. Examines systematic uncertainties in TROPOMI-based inversions, directly relevant to understanding how prior assumptions propagate into "un-thinned" emission estimates.

- {cite:t}`esa_medusa2024` — *Comprehensive ESA retrieval methods review*. Covers column retrieval methods across the full MARS sensor fleet. Canonical institutional reference for the state-of-art as of 2024.

### Sentinel-2 / Sentinel-3 (Tiered Monitoring)

- {cite:t}`varon2023sentinel3` — *Tiered observation architecture*. Demonstrates how combining platforms with different spatial/temporal/spectral characteristics improves coverage of the full emission rate distribution.

### Hyperspectral Imagers (EnMAP, PRISMA, EMIT)

- {cite:t}`roger2025offshore` — Parametric PoD models for EnMAP and EMIT in offshore contexts.

- {cite:t}`guanter2025enmap_tight` — *Uncertainty reduction for hyperspectral IME*. Directly relevant to the quantification error bars on the mark $Q$.

- {cite:t}`guanter2025hyperspectral_ssrn` — *Cross-platform comparison*. Benchmark across EnMAP, PRISMA, EMIT showing how different $P_{50}$ thresholds sample different parts of the tail.

- {cite:t}`nasasvs2022emit` — *EMIT capability demonstration*. Visualisation of EMIT methane detections from the ISS, illustrating the instrument's role in the multi-platform MARS architecture.

### MethaneAIR / MethaneSAT

- {cite:t}`jong2025methaneair` — *Area flux mapping at high resolution*. Matched-filter + IME pipeline at 5$\times$25 m resolution; ~120 kg/h conservative detection limit; hundreds of Permian Basin point sources characterised. Bridges the gap between point-source imagers and area flux mappers, relevant to detecting the "diffuse" component missed by point-source PoD curves.

- {cite:t}`zhang2024methaneSAT` — *MethaneSAT operational algorithm*. Describes the discrete-source detection and quantification pipeline for MethaneSAT, defining the instrument's operational PoD curve parameters.

- {cite:t}`methaneair_egusphere2025` — *Extended MethaneAIR characterisation*. Includes controlled-release validation flights, providing empirical PoD calibration for the MethaneAIR/MethaneSAT sensor family.

### Carbon Mapper / Tanager-1

- {cite:t}`carbonmapper2024tanager` — *Operational imaging spectroscopy*. First results from the dedicated Carbon Mapper constellation designed to close the gap between airborne and satellite detection limits.

### VIIRS / GOES (Thermal & Geostationary)

- {cite:t}`plant2024geostationary` — *Sub-hourly GOES monitoring*. 5-minute cadence tracking of extreme transient releases, establishing that event durations can be <1 hour.

- {cite:t}`nasa_firms` — *Thermal anomaly detection context*. VIIRS flaring/fire products provide independent constraint on flaring-associated methane events.

- {cite:t}`vfei2022` — *VIIRS fire emission inventory*. Provides the thermal emission baseline against which flaring-associated methane can be contextualised.

- {cite:t}`eumetsat2026fire` — *Operational thermal product framing*. Describes the broader context of geostationary and polar-orbiting thermal monitoring.

- {cite:t}`flaring_toolkit_viirs` — *VIIRS for flaring detection*. Practitioner-oriented explainer of how VIIRS thermal anomalies map to flaring events.

- {cite:t}`flaring_toolkit_single` — *Flare efficiency estimation*. Documents how incomplete combustion (low flare efficiency) translates thermal detections into methane emission estimates.

- {cite:t}`gordan2025flaring` — *Flaring underestimation with named detection floor*. VIIRS flare detection floor at surface area < 0.26 m$^2$; shows systematic undercount at small flares — another empirical size-dependent PoD argument paralleling the methane plume thinning. Notes that VIIRS cannot see cold/unlit flares, directly motivating the "missed detection" argument in the paradox.

- {cite:t}`irakulis2021permian` — *TROPOMI + VIIRS multi-sensor synergy*. Bayesian inversion of TROPOMI XCH$_4$ constrained by VIIRS radiant heat for flaring volumes. Demonstrates how combining column retrievals with thermal anomaly data improves both spatial attribution and emission partitioning between flaring and venting.

---

## 12. Event Duration & the $D$ Parameter

These references specifically constrain the duration parameter $D$ [hr event$^{-1}$] that converts flux rates to total emitted mass — a critical multiplier in $M = \Lambda \cdot \mathbb{E}[Q] \cdot D$.

- {cite:t}`cusworth2026duration` — *The most direct constraint on $D$*. Carbon Mapper aerial surveys over the NM Permian (276,000 wells, 1100 compressor stations). 500+ super-emitters with 300 observed repeatedly. Quantifies the gap between integrated event-duration estimates (5.98–14.7 Gg CH$_4$) and snapshot-based basin averages (12.7 $\pm$ 0.92 Gg CH$_4$) — directly measuring the "missing mass" arising from duration assumptions.

- {cite:t}`varon2021anomalous` — *Default duration assumptions*. Notes that {cite:t}`lauvaux2022ultraemitters` assumed a default 24-hr duration for TROPOMI plumes detected on consecutive days, while actual events can be much shorter — directly relevant to the MMSF correction.

- {cite:t}`omara2022methane` — *Low-production well emissions*. Shows that 80% of U.S. well sites (low producers, 6% of output) emit ~50% of total well-site methane — these persistent, low-rate sources are systematically below satellite detection limits, contributing to the missing mass.

---

## 13. Bayesian / Hierarchical Models & Statistical Inversion

These references support the "un-thinning" step — the statistical inversion that recovers the true emission field from the observed, thinned data using Bayesian priors.

- {cite:t}`daniels2025bayesian` — *Hierarchical inference framework*. Directly relevant to estimating the latent true distribution $f(Q)$ from the observed thinned distribution $f_{\text{obs}}(Q)$ using structured priors and sparsity assumptions.

- {cite:t}`conrad2023alberta` — *Hybrid aerial-inventory framework*. Combines top-down aerial measurements with bottom-up estimates using continuous PoD and quantification models — explicitly considers skewed source distributions and finite facility populations. The methodology directly implements the "un-thinning" correction.

- {cite:t}`omara2018temporal` — *Temporal variability as inventory gap driver*. Demonstrates that intermittent emissions explain much of the top-down/bottom-up discrepancy — the temporal analogue of the PoD-driven spatial thinning.



---

## Practitioner's Quick-Reference: Where to Cite What

These clusters map directly to the six core components of the paradox write-up:

1. **IME / plume mass-balance $\rightarrow$ mark $Q$**: {cite:p}`varon2018ime`, {cite:p}`nist8575_2025`, {cite:p}`jrc_sentinel_hotspot`, {cite:p}`guanter2025enmap_tight`, {cite:p}`jong2025methaneair`

2. **PoD as size-dependent thinning $\rightarrow$ logistic $P_d(Q)$**: {cite:p}`sherwin2024singleblind`, {cite:p}`sherwin2022multiblind`, {cite:p}`tadi2026controlled`, {cite:p}`delfonso2025offshore`, {cite:p}`ayasse2025probability`, {cite:p}`nordstrom2022pipeline_dispersion`

3. **Heavy-tail mark priors $\rightarrow$ $f(Q)$**: {cite:p}`frankenberg2016fourgcorners`, {cite:p}`brandt2016extreme`, {cite:p}`zavala2017reconciling`, {cite:p}`jakkala2022probgas`, {cite:p}`global_survey2025landfill`

4. **Temporal variability and persistence $\rightarrow$ $\lambda(t)$, $D$**: {cite:p}`omara2018temporal`, {cite:p}`cusworth2026duration`, {cite:p}`biener2024gulf`, {cite:p}`escape2021model`, {cite:p}`omara2018temporal_meet`, {cite:p}`pipeline_leak2022dispersion`, {cite:p}`nordstream2024`

5. **Temporal point process theory $\rightarrow$ NHPP, Hawkes, renewal, compound Poisson**: {cite:p}`chavez_nhpp_airpollution`, {cite:p}`hawkes_applications2024`, {cite:p}`hawkes_coating2025`, {cite:p}`weibull_renewal`, {cite:p}`sherwin2023tiered_ldar`

6. **Platform roster justification $\rightarrow$ why MARS uses "all satellites"**: {cite:p}`esa_medusa2024`, {cite:p}`schneising2024tropomi_persistent`, {cite:p}`sherwin2024singleblind`, {cite:p}`guanter2025hyperspectral_ssrn`, {cite:p}`zhang2024methaneSAT`, {cite:p}`gordan2025flaring`, {cite:p}`irakulis2021permian`

---

## Notes on Source Quality

- **Peer-reviewed core**: The bibliography is built primarily around journal articles (*EST*, *ACP*, *AMT*, *Nature*, *Science*, *PNAS*, *Nature Communications*, *IEEE RAL*, *Elementa*, *Methods in Ecology and Evolution*, *Annals of the ISM*). These should be prioritised for formal citations.
- **Technical reports**: {cite:t}`nist8575_2025`, {cite:t}`jrc_sentinel_hotspot`, and {cite:t}`esa_medusa2024` carry institutional authority and are appropriate for methods citations.
- **Grey literature / programme pages**: {cite:t}`nasasvs2022emit`, {cite:t}`nasa_firms`, {cite:t}`carbonmapper2024tanager`, {cite:t}`eumetsat2026fire`, {cite:t}`flaring_toolkit_viirs`, {cite:t}`tropomi_pum`, and {cite:t}`zhang2024methaneSAT` provide operational context but should be cited as supplementary/institutional sources rather than primary evidence.
- **Preprints**: {cite:t}`segers2025tropomi_trust`, {cite:t}`methaneair_egusphere2025`, {cite:t}`daniels2025bayesian`, and the arXiv Hawkes papers should be flagged as preprints and updated with final publication details when available.
- **Textbook / foundational**: {cite:t}`wald1943survivorship`, {cite:t}`weibull_renewal`, and {cite:t}`chavez_nhpp_airpollution` provide the mathematical foundations — these are stable references that will not change.

---

*Bibliography compiled February 2026. ~95 references across 14 thematic sections + TPP theory foundations.*

```{bibliography}
:filter: docname in docnames
```
