---
title: "Persistency: The Operational Arsenal"
subtitle: From Stochastic Geometry to Actionable Business Intelligence
---

# Persistency: The Operational Arsenal

We have reached the operational crux of the paradox: **Persistency**.

Once MARS has successfully mathematically inverted the thinned, biased dataset to uncover the latent physical variables—the true timeline rate $\lambda_{\text{true}}$ and the true mark distribution $f_{\text{true}}(Q)$ {cite:p}`cusworth2025multiscale, daniels2025bayesian`—it possesses a statistical crystal ball. MARS is no longer reacting to stale satellite images; it is forecasting physical reality.

Let us cross the bridge from stochastic geometry into operational engineering and business intelligence. To do this with maximum rigor, we will define every metric twice: first establishing the baseline **Homogeneous** assumption (where the leak rate is a flat, memoryless constant), and then elevating it to the **Inhomogeneous** (Non-Stationary) physical reality, where industrial sources violently fluctuate with diurnal cycles, pressures, and human operations {cite:p}`omara2018temporal, frankenberg2024persistence`.

Here is the pedantic, step-by-step translation of the Predictive Arsenal.

---

## 1. Temporal Predictions (The "When")

This suite of metrics translates the abstract true intensity $\lambda_{\text{true}}(t)$ into actionable dispatch logic for Leak Detection and Repair (LDAR) crews {cite:p}`sherwin2023tiered_ldar`.

### 1.1 Expected Wait Time (Mean Time Between Plumes)

* **The Ontology:** $\mathbb{E}[\Delta t]$
* **Units:** `[hours / event]`

**The Translation:** If a technician drives to this facility, how long will they physically stand there before the infrastructure vents?

* **Homogeneous:** If it's a continuously stressed, cracked pipe, the wait time is constant. If $\mathbb{E}[\Delta t]$ is 1.5 hours, you dispatch a crew immediately.

:::{math}
:label: eq-mmp-interarrival-time

\mathbb{E}[\Delta t] = \frac{1}{\lambda_{\text{true}}}
:::

* **Inhomogeneous:** If it is a solar-heated storage tank, the rate changes over time {cite:p}`allen2017temporal, biener2024gulf`. The expected wait time depends entirely on *when* you start the clock ($t_0$). We must integrate the survival function over the future timeline.

:::{math}
:label: eq-mmp-persist-wait-inhomo

\mathbb{E}[\Delta t \mid t_0] = \int_{t_0}^{\infty} \exp\!\left( -\int_{t_0}^{t} \lambda_{\text{true}}(u) \, du \right) dt
:::

```text
+---------------------------------------------------------------+
| BotE #1: THE DYNAMIC DISPATCH (Inhomogeneous Wait Time)       |
|---------------------------------------------------------------|
| Let's look at the solar-heated storage tank.                  |
|                                                               |
| Scenario A: The technician arrives at t₀ = 1:00 PM (Peak Heat)|
| Because λ_true(u) is massive during the afternoon, the        |
| integral rapidly accumulates.                                 |
| E[Δt | 1:00 PM] = 0.5 [hours]  (Crew waits 30 minutes)       |
|                                                               |
| Scenario B: The technician arrives at t₀ = 1:00 AM (Dormant)  |
| Because λ_true(u) is near zero at night, the integral creeps. |
| E[Δt | 1:00 AM] = 11.0 [hours] (Crew waits until noon)       |
|                                                               |
| ACTION: MARS dynamically blocks LDAR dispatch during dormant  |
| cycles, saving thousands in wasted hourly labor.              |
+---------------------------------------------------------------+

```

```text
+---------------------------------------------------------------+
| BotE: OPTIMIZING MARS ORBITAL TASKING                         |
|---------------------------------------------------------------|
| Un-thinned intensity: λ_true = 0.02 [events / hour]           |
|                                                               |
| Expected Inter-Arrival Time between points:                   |
| E[Δt] = 1 / 0.02 = 50 [hours / event]                         |
|                                                               |
| MARS ACTION: MARS will NOT task a high-resolution commercial  |
| satellite for at least 48 hours. Tasking any earlier wastes   |
| orbital resources photographing clean air.                    |
+---------------------------------------------------------------+

```

### 1.2 Probability of Occurrence (The "Wrench-Turning" Metric)

* **The Ontology:** $P(N(t_1, t_2) \geq 1)$
* **Units:** `[Dimensionless Probability, 0.0 to 1.0]`

**The Translation:** If an LDAR crew is on-site for a scheduled maintenance window from 8:00 AM ($t_1$) to 12:00 PM ($t_2$), what is the exact percentage chance that the leak will physically manifest while they are looking at it?

The foundation is the Poisson PMF. Assuming the underlying points have stabilized into a memoryless state, the probability of observing exactly $k$ un-thinned events during a future window $t$ `[hours]` is:

:::{math}
:label: eq-mmp-poisson-pmf

P\bigl(N(t) = k\bigr) = \frac{(\lambda_{\text{true}} \cdot t)^k \; e^{-\lambda_{\text{true}} \cdot t}}{k!}
:::

MARS calculates the probability of a successful mitigation trip (catching *at least one* leak in the act) by computing the probability of the void ($k = 0$) and subtracting from 1:

:::{math}
:label: eq-mmp-mitigation-success

P(\text{Mitigation Success}) = 1 - e^{-\lambda_{\text{true}} \cdot t}
:::

* **Homogeneous:** $P(N(T) \geq 1) = 1 - \exp(-\lambda_{\text{true}} \cdot T)$
* **Inhomogeneous:** We replace the flat rate multiplied by duration ($\lambda_{\text{true}} \cdot T$) with the definite integral of the fluctuating intensity curve between the exact start and end of the shift {cite:p}`plant2024geostationary`. By integrating the inhomogeneous curve, MARS aligns the crew's shift with the absolute mathematical peak of the facility's emission probability.

:::{math}
:label: eq-mmp-persist-occur-inhomo

P(N(t_1, t_2) \geq 1) = 1 - \exp\!\left( -\int_{t_1}^{t_2} \lambda_{\text{true}}(t) \, dt \right)
:::

```text
=============================================================================
  VISUALIZING INHOMOGENEOUS OCCURRENCE (Diurnal Shifting)
=============================================================================
  λ_true(t) [events/hr]
   ^
   |        (Peak Heat/Pressure)
   |             .---.
   |            /     \
   |           /       \  <- (Highest probability density)
   |          /         \
   |         /           \
   |        /             \
   |  ------'               '------ (Nighttime Dormancy)
   +--|------|--------------|------|---------------------> Time of Day
      t₁     t₂             t₃     t₄
   (Morning Shift)      (Night Shift)

   * Integrating from t₁ to t₂ captures the curve. HIGH Probability.
   * Integrating from t₃ to t₄ captures flatlines. ZERO Probability.
=============================================================================

```

```text
+---------------------------------------------------------------+
| BotE: THE MARS DISPATCH NOTIFICATION                          |
|---------------------------------------------------------------|
| MARS un-thins the data to find the True Intensity Rate:       |
| λ_true = 0.05 [events / hour]                                 |
|                                                               |
| The operator's repair crew requires a window of t = 48 [hours]|
|                                                               |
| Step 1: Un-thinned points expected (λ_true · t)               |
|         0.05 [events/hr] · 48 [hr] = 2.4 [expected points]    |
|                                                               |
| Step 2: Probability of a wasted trip (k = 0)                  |
|         P(0) = e^(-2.4) = 0.0907 (or ~9%)                     |
|                                                               |
| Step 3: Probability of Successful Mitigation                  |
|         P(Success) = 1 - 0.0907 = 0.9093                      |
|                                                               |
| MARS ACTION: The platform issues a formal Notification. The   |
| operator has a 91% chance of catching the leak. Dispatch crew.|
+---------------------------------------------------------------+

```

---

## 2. Survival Analysis (The "How Long")

Survival analysis is the mathematical heartbeat of **Persistency** {cite:p}`frankenberg2024persistence`. Instead of asking "how many leaks will happen?", MARS asks "what is the mathematical probability that this infrastructure will *survive* (remain perfectly sealed) past time $t$?"

### 2.1 The Survival Function

* **The Ontology:** $S(t \mid t_0)$
* **Units:** `[Dimensionless Probability, 1.0 down to 0.0]`

**The Translation:** If a satellite photographed a massive plume on Monday ($t_0$), $S(t \mid t_0)$ dictates the decaying probability that the source has remained perfectly quiet since that exact moment {cite:p}`cusworth2021intermittency`.

* **Homogeneous:** $S(t) = \exp(-\lambda_{\text{true}} \cdot t)$
* **Inhomogeneous:** The probability of surviving from a known quiet state $t_0$ up to a future time $t$. As time advances, or as the integral passes through a diurnal peak, the survival probability violently collapses toward zero.

:::{math}
:label: eq-mmp-persist-survival-inhomo

S(t \mid t_0) = \exp\!\left( -\int_{t_0}^{t} \lambda_{\text{true}}(u) \, du \right)
:::

### 2.2 The Hazard Function (The Instantaneous Risk)

* **The Ontology:** $h(t)$
* **Units:** `[events / hour]`

**The Translation:** The hazard function isolates the instantaneous, immediate risk of a leak occurring *right now*, given that it hasn't happened yet.

* **Homogeneous (Broken Flange):** $h(t) = \lambda_{\text{true}}$. The risk is a flat constant. The probability of it leaking right now is exactly the same as tomorrow.
* **Inhomogeneous (Valve Recharge):** If the source is a pressure valve that needs to physically "recharge," the timeline has memory {cite:p}`weibull_renewal, chavez_nhpp_airpollution`. $h(t)$ starts at exactly zero right after a leak, and aggressively climbs upward over time as the physical pressure builds back up inside the pipe.

:::{math}
:label: eq-mmp-persist-hazard-memory

h(t) = \frac{f_{\text{time}}(t)}{S(t)}
:::

where $f_{\text{time}}(t)$ is the PDF of the wait times.

```text
=============================================================================
  VISUALIZING THE HAZARD FUNCTION: RANDOM VS RECHARGE
=============================================================================
  Hazard Rate h(t) [events/hr]
   ^
   |                           /   (Weibull: Valve Recharge)
   |                          /    Risk violently increases as
   |                         /     pipe pressure builds.
   |------------------------/--------- (Poisson: Broken Flange)
   |                       /           Risk is a flat constant.
   |                      /
   |                     /
   +--------------------+-------------------> Time (t) since last leak
   0
=============================================================================

```

---

## 3. Mass Predictions (The "How Big")

These metrics translate the true, un-thinned mark distribution $f_{\text{true}}(Q)$ into financial ledgers and regulatory reality.

### 3.1 Expected Mass per Event

* **The Ontology:** $\mathbb{E}[M_{\text{event}}]$
* **Units:** `[kg / event]`

**The Translation:** When the Hazard Function (Eq. {eq}`eq-mmp-persist-hazard-memory`) triggers an event at time $t$, this is the discrete "chunk" of methane (in kilograms) that enters the atmosphere.

* **Homogeneous Marks:**

:::{math}
:label: eq-mmp-persist-mass-event-homo

\mathbb{E}[M_{\text{event}}] = \left[ \int_0^{\infty} Q \cdot f_{\text{true}}(Q) \, dQ \right] \cdot \mathbb{E}[D]
:::

where $\mathbb{E}[D]$ is the expected duration in hours {cite:p}`cusworth2026duration, brandt2016extreme`.

* **Inhomogeneous Marks:** If the *size* of the leak depends on the time of day (e.g., higher pressure at noon forces larger physical blowouts), the true mark distribution becomes a dynamic function of time: $f_{\text{true}}(Q, t)$.

:::{math}
:label: eq-mmp-persist-mass-event-inhomo

\mathbb{E}[M_{\text{event}}(t)] = \mathbb{E}[D] \cdot \left[ \int_0^{\infty} Q \cdot f_{\text{true}}(Q, t) \, dQ \right]
:::

```text
+---------------------------------------------------------------+
| BotE: THE MITIGATION ROI (Gas Saved per Event)                |
|---------------------------------------------------------------|
| True Expected Mark:      E[Q_true] = 250 [kg / hr]            |
| Expected Event Duration: E[D]      =   3 [hours / event]      |
|                                                               |
| E[Mass_per_event] = 250 · 3 = 750 [kg] of methane per point.  |
|                                                               |
| MARS ACTION: If natural gas is $2.00/kg, MARS notifies the    |
| operator: "Mitigating this specific valve will save you       |
| exactly $1,500 of lost product every single time it cycles."  |
+---------------------------------------------------------------+

```

### 3.2 Total Accumulated Mass (The Aggregate Risk)

* **The Ontology:** $\mathbb{E}[M_{\text{total}}]$
* **Units:** `[kg]` or `[metric tons]`

**The Translation:** This is the compounded physical truth. Over the next year, accounting for diurnal cycles, nighttime downtime, and the true average mark, this is the forecasted total physical mass the operator will lose {cite:p}`omara2018temporal`.

* **Homogeneous:** $\mathbb{E}[M_{\text{total}}] = \lambda_{\text{true}} \cdot T \cdot \mathbb{E}[M_{\text{event}}]$
* **Inhomogeneous:** We replace the flat count with the true cumulative intensity function (Eq. {eq}`eq-mmp-true-event-count`), integrating the fluctuating rate over the operational year $T$.

:::{math}
:label: eq-mmp-persist-mass-total-inhomo

\mathbb{E}[M_{\text{total}}] = \left[ \int_0^{T} \lambda_{\text{true}}(t) \, dt \right] \cdot \mathbb{E}[M_{\text{event}}]
:::

```text
+---------------------------------------------------------------+
| BotE #2: THE INHOMOGENEOUS LEDGER (Total Mass)                |
|---------------------------------------------------------------|
| A naïve model assumes the facility leaks 24/7.                |
| Homogeneous: 1 [event/hr] · 8760 [hrs/yr] = 8,760 events.     |
|                                                               |
| But MARS knows the facility is dormant for 12 hours a night.  |
| Inhomogeneous Integral: ∫₀^8760 λ_true(t) dt = 4,380 events.  |
|                                                               |
| If E[M_event] = 500 [kg]:                                     |
| Naïve Mass : 8,760 · 500 = 4,380,000 [kg]                     |
| True Mass  : 4,380 · 500 = 2,190,000 [kg]                     |
|                                                               |
| ACTION: By enforcing inhomogeneous bounds, MARS prevents      |
| over-taxing the operator by millions of kilograms.            |
+---------------------------------------------------------------+

```

### 3.3 Extreme Value Risk (The Blowout Probability)

* **The Ontology:** $P(Q > Q_{\text{crit}})$
* **Units:** `[Dimensionless Probability]`

**The Translation:** If a catastrophic threshold $Q_{\text{crit}}$ is 5,000 `[kg/hr]`, this represents the heavy-tail risk {cite:p}`lauvaux2022ultraemitters, zavala2015functional`. A site might have a tiny average mass per event, but if its underlying true Lognormal curve has a "fat tail," the probability of a headline-making blowout remains dangerously high {cite:p}`brandt2016extreme, zavala2017superemitters`.

:::{math}
:label: eq-mmp-persist-extreme-risk

P(Q > Q_{\text{crit}}) = \int_{Q_{\text{crit}}}^{\infty} f_{\text{true}}(Q) \, dQ
:::

```text
+---------------------------------------------------------------+
| BotE: MARS EMERGENCY ALERT (The Heavy Tail)                   |
|---------------------------------------------------------------|
| Let's look at the true un-thinned Marks f(Q) for a site.      |
| The average Mark is a tiny 5 [kg/hr].                         |
|                                                               |
|       ^                                                       |
|   99% | |\                                                    |
|  Safe | | \                           1% Blowout Risk         |
| Marks | |  \____                      (The Survival Tail)     |
|       +-+-------\-----------------------+----------> Q        |
|                  \______________________|///////              |
|                                       5,000 [kg/hr]           |
|                                                               |
| MARS ACTION: Even if the thinned satellite data mostly shows  |
| nothing, if the inverted tail integral (∫₅₀₀₀^∞) evaluates to |
| > 1%, MARS triggers an Emergency Super-Emitter Alert to the   |
| operator for immediate structural mitigation.                 |
+---------------------------------------------------------------+

```

### 3.4 The Missing Mass Scaling Factor (MMSF)

How does MARS systematically correct historical national greenhouse gas inventories that were built on structurally flawed, thinned satellite data {cite:p}`williams2025small, alvarez2018supply`? MARS deploys the exact ratio of the invisible mass to the visible mass.

**The Translation:** The Missing Mass Scaling Factor `[unitless multiplier]` is the ratio of the True Expected Total Mass `[kg]` divided by the observed, Thinned Expected Total Mass `[kg]`.

:::{math}
:label: eq-mmp-mmsf

\text{MMSF} = \frac{\mathbb{E}[M_{\text{total,true}}]}{\mathbb{E}[M_{\text{total,obs}}]}
:::

Because the Points ($\Lambda_{\text{true}}$) and Duration ($D$) cancel out (as proven in the paradox document), MARS defines the correction purely as the ratio of the un-thinned Marks divided by the thinned Marks {cite:p}`conrad2023alberta, daniels2025bayesian`.

:::{math}
:label: eq-mmp-mmsf-expanded

\text{MMSF} = \frac{\displaystyle\int_0^\infty Q \, f(Q) \, dQ}{\displaystyle\int_0^\infty Q \, P_d(Q) \, f(Q) \, dQ}
:::

```text
+---------------------------------------------------------------+
| BotE: THE MARS CORRECTION PROTOCOL                            |
|---------------------------------------------------------------|
| 1. Evaluate the Top Integral (Un-thinned Marks):              |
|    ∫₀^∞ Q · f(Q) dQ = 140 [kg/hr]                             |
|                                                               |
| 2. Evaluate the Bottom Integral (Thinned Marks):              |
|    ∫₀^∞ Q · P_d(Q) · f(Q) dQ = 40 [kg/hr]                     |
|                                                               |
| 3. Calculate the Correction Ratio:                            |
|    MMSF = 140 / 40 = 3.5                                      |
|                                                               |
| MARS ACTION: MARS issues an inventory correction to the UN:   |
| "The satellite filter destroyed 71% of the physical reality   |
| here. Take the historical mass logged for this site, multiply |
| it strictly by 3.5, and update the global climate models."    |
+---------------------------------------------------------------+

```

---

This is where the stochastic geometry becomes a living, breathing compliance engine. A site manager does not care about the integral of a heavy-tailed Lognormal distribution; they care if they are going to be fined by a regulator tomorrow. We must translate our latent variables—the thinned marks, the fluctuating timeline, and the atmospheric filter—into an automated, mathematically bulletproof UI.

Before we finalize the MARS logic tree, we must address the most common and dangerous pitfall that software engineers make when building these dashboards: confusing a discrete Binomial probability with a continuous Point Process intensity.

Let's lock in the rigorous physical units, perform the continuous limit proof, and then map out the final UI logic tree.

---

## 4. The Fundamental Shift: Binomial vs. Point Process (The Continuous Limit)

When engineers first attempt to build a persistency dashboard, they almost always default to a discrete Binomial model (e.g., "The satellite passed over 10 times, and we saw a leak 3 times. The probability of a leak is 30%").

This is structurally incorrect for physical pipeline infrastructure, and it will destroy the accuracy of your MARS predictions {cite:p}`cusworth2025multiscale`. We must strictly define the difference between a unitless probability ($p$) and a continuous intensity ($\lambda$).

### 4.1 The Ontology and Units

**1. The Binomial Probability ($p$)**

* **The Definition:** The chance of a "Success" in a single, discrete trial (e.g., a coin flip).
* **Units:** `[Unitless fraction, strictly between 0.0 and 1.0]`
* **The Flaw:** Time does not exist here. A pipeline does not "flip a coin" once a day. It is under continuous, relentless physical pressure every single second.

**2. The Point Process Intensity ($\lambda$)**

* **The Definition:** The physical rate at which events are generated over a continuous timeline.
* **Units:** `[Events / Time]` (e.g., `[events/hour]`).
* **The Advantage:** Intensity can exceed 1.0. A source can have an intensity of 5 `[events/hour]`. It accounts for the actual physical flow of time and allows for instantaneous rates of change {cite:p}`chavez_nhpp_airpollution`.

### 4.2 The Mathematical Proof: Collapsing the Binomial into the Poisson

How do we prove that a continuous Point Process is just the ultimate, infinite evolution of the discrete Binomial model? We take the mathematical limit.

**The Translation:** Imagine an observation window $T$. We slice $T$ into $n$ tiny, discrete intervals of length $\Delta t$. The probability $p$ of a leak occurring in one tiny slice is the continuous rate $\lambda$ multiplied by the length of the slice $(T / n)$. As we slice time infinitely thin (as $n$ approaches infinity), the discrete Binomial equation flawlessly collapses into the continuous Poisson equation.

**The Setup:**

1. Time window: $T$
2. Number of slices: $n$
3. Length of one slice: $\Delta t = T / n$
4. Probability of a leak in one slice: $p = \lambda \cdot (T / n)$

**The Limit Equation:**
We start with the standard Binomial probability of exactly $k$ events occurring in $n$ slices:

:::{math}
:label: eq-mmp-persist-binomial-pmf

P(X = k) = \binom{n}{k} \cdot p^k \cdot (1 - p)^{n - k}
:::

Substitute our definition of $p$:

:::{math}
:label: eq-mmp-persist-binomial-sub

P(X = k) = \binom{n}{k} \cdot \left(\frac{\lambda T}{n}\right)^k \cdot \left(1 - \frac{\lambda T}{n}\right)^{n - k}
:::

Now, we take the limit as $n \to \infty$. We can break this into three interacting pieces:

1. The factorials: $(n! / (n - k)!) / n^k$ approaches $1$ as $n$ gets infinitely large.
2. The continuous compound interest rule: $(1 - \lambda T / n)^n$ approaches $e^{-\lambda T}$.
3. The remainder: $(1 - \lambda T / n)^{-k}$ approaches $1$ because $\lambda T / n$ goes to zero.

**The Result:** When we multiply the surviving pieces together, the discrete Binomial formula perfectly transforms into the continuous Poisson PMF (cf. Eq. {eq}`eq-mmp-poisson-pmf`):

:::{math}
:label: eq-mmp-persist-poisson-result

P(X = k) = \frac{(\lambda T)^k \cdot e^{-\lambda T}}{k!}
:::

```text
+---------------------------------------------------------------+
| BotE #1: WHY BINOMIAL FAILS THE MARS PLATFORM                 |
|---------------------------------------------------------------|
| A satellite passes over a facility once a week for 4 weeks.   |
| It sees a leak on Week 1. It sees clean air on Weeks 2, 3, 4. |
|                                                               |
| The Naive Binomial Engineer:                                  |
| "1 detection out of 4 trials. The probability is p = 0.25."   |
|                                                               |
| The MARS Point Process Engineer:                              |
| "The satellite only looks for 5 seconds per week. We have     |
| 20 seconds of observational data across a 2,419,200-second    |
| continuous timeline. The true rate λ_true(t) requires us to   |
| integrate the atmospheric blind spot E[P_d] across the whole  |
| month."                                                       |
|                                                               |
| ACTION: The Binomial model assumes the universe ceases to     |
| exist when the satellite looks away. The Point Process        |
| mathematically models the silence between the images.         |
+---------------------------------------------------------------+

```

---

## 5. The MARS Business Translation Engine (The UI Logic)

Now that we are strictly operating in continuous, un-thinned point process space, we can map our business logic {cite:p}`unepMars2022, irakulis2024marsOps`.

A government regulator does not want to integrate an inhomogeneous hazard function manually. They want a dashboard with color-coded labels that command specific mitigations. We must translate our core variables—$\lambda_{\text{obs}}$ (the thinned detections), $\lambda_{\text{true}}(t)$ (the un-thinned, fluctuating physical rate), and $\mathbb{E}[P_d]$ (our atmospheric confidence scalar, Eq. {eq}`eq-mmp-expected-pod`)—into an automated logic tree {cite:p}`schneising2024tropomi_persistent`.

**The Ontology of MARS Business Labels:**

1. **[ PERSISTENT ]**: The infrastructure is continuously or highly frequently failing. The un-thinned $\lambda_{\text{true}}$ is high. Emergency dispatch required.
2. **[ INTERMITTENT ]**: The infrastructure is failing, but sporadically or cyclically. Log for routine, timed maintenance based on diurnal peaks.
3. **[ MITIGATED ]**: We have mathematical proof that the source is physically quiet.
4. **[ UNKNOWN ]**: We see nothing, but only because we are mathematically blind. The ticket remains open.

Here is the pedantic, inhomogeneous logic tree that powers the UI.

```text
=============================================================================
  THE MARS INHOMOGENEOUS PERSISTENCY LOGIC ENGINE
=============================================================================

INPUTS FOR REVIEW PERIOD 'T':
- λ_obs     (Observed, thinned event count from satellite)
- E[P_d]    (Expected Probability of Detection: Sensor limits + Weather)
- λ_true(t) (Calculated un-thinned dynamic rate: λ_obs(t) / E[P_d])

[ START NODE ]
   |
   +-- Condition A: Did we observe ANY leaks? (λ_obs > 0)
   |     |
   |     +-- [ YES ] ---> Evaluate Inhomogeneous Persistency
   |     |                  |
   |     |                  | Calculate expected un-thinned events
   |     |                  | over the next 48-hour operational window:
   |     |                  | Λ_future = ∫_{now}^{now+48} λ_true(t) dt
   |     |                  |
   |     |                  +-- Is Λ_future ≥ 2.0 events? (High frequency)
   |     |                  |     |
   |     |                  |     +-->> LABEL: [ PERSISTENT ]
   |     |                  |           UI Hook: Display Expected Total Mass
   |     |                  |           (E[M_total]) and trigger emergency alert.
   |     |                  |
   |     |                  +-- Is Λ_future < 2.0 events? (Low frequency)
   |     |                        |
   |     |                        +-->> LABEL: [ INTERMITTENT ]
   |     |                              UI Hook: Display optimal dispatch time
   |     |                              by targeting the peak of λ_true(t).
   |     |
   |     +-- [ NO ]  ---> Evaluate Atmospheric Confidence (The Filter)
   |                        |
   |                        | We saw nothing. But WHY did we see nothing?
   |                        |
   |                        +-- Is E[P_d] > 0.85? (High confidence, clear skies)
   |                        |     |
   |                        |     +-->> LABEL: [ MITIGATED ]
   |                        |           Logic: If it was physically leaking,
   |                        |           we absolutely would have seen it.
   |                        |
   |                        +-- Is E[P_d] < 0.15? (Low confidence, cloudy)
   |                              |
   |                              +-->> LABEL: [ UNKNOWN / BLIND SPOT ]
   |                                    Logic: Silence means nothing here.
   |                                    The sensor is blinded by the atmosphere.
   |                                    UI Hook: Lock the "Close Ticket" button
   |                                    to prevent false compliance logging.
=============================================================================

```

---

## 6. The Power of the "Unknown" State (The Blind Spot)

We must heavily emphasize the pedagogical and regulatory importance of the **[ UNKNOWN ]** state in business applications. It is the ultimate safeguard against greenwashing {cite:p}`williams2025small`.

In naive systems, operators rely on binary logic: *If I see a leak, it is broken. If I do not see a leak, it is fixed.* By explicitly calculating the Expected Probability of Detection (Eq. {eq}`eq-mmp-expected-pod`), you mathematically quantify your blindness {cite:p}`ayasse2025probability, sherwin2024singleblind`. If $\mathbb{E}[P_d]$ collapses to 5% because the region has high wind shear, dense cloud cover, or a low-albedo background (like dark water or snow), your software actively forbids the stakeholder from labeling the site as "Mitigated."

```text
+---------------------------------------------------------------+
| BotE #2: PREVENTING FALSE COMPLIANCE                          |
|---------------------------------------------------------------|
| Facility X had a massive blowout last month.                  |
| Today, the satellite image is completely clear. No methane.   |
|                                                               |
| Operator: "Great, the leak stopped. I'm closing the ticket."  |
|                                                               |
| MARS Backend Check:                                           |
| 1. True distribution f_true(Q) indicates small valve leaks.   |
| 2. Weather data shows 30 km/hr wind shear today.              |
| 3. Calculating integral: E[P_d] = 0.04 (4% confidence).       |
|                                                               |
| ACTION: The UI overrides the operator. It displays [UNKNOWN]. |
| The dashboard reads: "Cannot verify mitigation. Wind shear    |
| has destroyed the sensor's probability of detection. Awaiting |
| future overpass with E[P_d] > 0.80."                          |
+---------------------------------------------------------------+

```

By wrapping Survival Analysis, Expected Mass derivations, and Inhomogeneous Calculus strictly into this automated, unit-perfect logic tree, you transform a stochastic paradox into a bulletproof global compliance engine.

---

## 7. The Two Paradigms: Discrete Looks vs. Continuous Reality

**The Traditional Approach (The Empirical Ratio)**
Calculating "Detections over Observations" (e.g., "we saw a plume on 3 out of 5 clear satellite overpasses") models the system as a series of discrete Bernoulli trials. It naturally forms a Binomial distribution.

* **The Translation:** "What is the probability of seeing the source exactly when I happen to look?"
* **The Metric:** A unitless probability fraction ($p$).

**The Stochastic Approach (The Point Process)**
Treating the emissions as a Temporal Point Process shifts the perspective from the satellite's arbitrary orbital schedule back to the source's continuous physical reality {cite:p}`cusworth2021intermittency, schneising2024tropomi_persistent`.

* **The Translation:** "At what physical rate does this infrastructure emit gas into the atmosphere, and what is the probability of exactly $k$ events occurring over a continuous timeframe?"
* **The Metric:** The true intensity parameter ($\lambda$).

```text
=============================================================================
  PARADIGM 1: BINOMIAL AVERAGE (Discrete Satellite Overpasses)
=============================================================================
  You only evaluate the universe at the exact moment the satellite is overhead.
  The spaces between the brackets mathematically do not exist.

  Overpass 1    Overpass 2    Overpass 3    Overpass 4    Overpass 5
  [ PLUME ]     [  CLEAR ]    [ PLUME ]     [ PLUME ]     [  CLEAR ]
      1             0             1             1             0

=============================================================================
  PARADIGM 2: TEMPORAL POINT PROCESS (Continuous Physical Reality)
=============================================================================
  You evaluate the continuous timeline. The source operates strictly
  independent of the satellite's schedule.

  Time ----->
  |-------*----*-----------------*---------*-------*-------|
          |    |                 |         |       |
         t₁   t₂                t₃        t₄      t₅
=============================================================================

```

---

## 8. A 1-to-1 Comparison: The Probability ($p$) vs. The Intensity ($\lambda$)

The confusion between these two models almost always stems from a failure to track physical units. These two parameters measure fundamentally different realities.

**The Binomial Parameter: $p$**

* **The Definition:** The chance of a "Success" on a single, discrete trial.
* **Units:** `[Detections / Overpass]` or `[Dimensionless Fraction, 0.0 to 1.0]`.
* **The Flaw:** It is a ratio of counts to *opportunities*. If you say a leak has a persistency of $p = 0.20$, that number contains absolutely zero physics. It only means that for every 100 times your specific satellite flies over, it happens to catch the plume 20 times.

**The Point Process Parameter: $\lambda$ (Lambda)**

* **The Definition:** The expected arrival rate of events over a continuous physical timeline.
* **Units:** `[Events / Day]` or `[Plumes / Hour]`.
* **The Power:** It is a ratio of counts to *continuous time*. If you say a leak has an intensity of $\lambda = 1.5$ `[plumes/day]`, you have defined the physical, thermodynamic reality of the infrastructure, completely independent of who is looking at it or when {cite:p}`cusworth2021intermittency`. Furthermore, unlike a probability, an intensity can vastly exceed 1.0 (e.g., $\lambda = 50$ `[events/day]` is perfectly valid).

---

## 9. The Proof of Convergence: From Binomial to Poisson

If these two paradigms measure different things, how are they related?

The profound truth of stochastic geometry is that the Poisson Point Process is simply the Binomial distribution taken to its absolute, infinite limit. We can mathematically prove that if you make your satellite overpasses infinitely fast, the discrete empirical ratio flawlessly collapses into the continuous intensity parameter.

**The Setup:**
Imagine your satellite observes a site for 1 whole day. It currently takes $n$ discrete pictures per day.
The probability of seeing a leak in one exact picture is $p$.
Therefore, the expected total number of physical leaks you see in a day is your rate, $\lambda$.

:::{math}
:label: eq-mmp-persist-lambda-rate

\lambda = n \cdot p \qquad \Longleftrightarrow \qquad p = \frac{\lambda}{n}
:::

Now, we calculate the Binomial probability of seeing exactly $k$ leaks in $n$ total pictures.

:::{math}
:label: eq-mmp-persist-binom-standard

P(X = k) = \binom{n}{k} \cdot p^k \cdot (1 - p)^{n - k}
:::

**The Limit ($n \to \infty$):**
What happens if we upgrade our satellite to take an infinite number of pictures per day ($n \to \infty$)? Because $\lambda$ (total leaks per day) is a physical constant bound by the pipe's pressure, as the number of pictures $n$ goes to infinity, the chance of catching a leak in any exact microsecond ($p$) must approach zero.

Let's substitute $p = \lambda / n$ into the Binomial equation and take the limit as $n \to \infty$:

:::{math}
:label: eq-mmp-persist-limit-expansion

\lim_{n \to \infty} \frac{n(n-1)(n-2)\cdots(n-k+1)}{k!} \cdot \left(\frac{\lambda}{n}\right)^k \cdot \left(1 - \frac{\lambda}{n}\right)^n \cdot \left(1 - \frac{\lambda}{n}\right)^{-k}
:::

To see the mathematical collapse, we group the interacting terms and evaluate them as $n$ becomes infinitely large:

1. **The Constant Term:** $(\lambda^k / k!)$ contains no $n$, so it remains perfectly unaffected.
2. **The Fraction Term:** We pair the $n$ terms from the combinatorial expansion with the $n^k$ in the denominator: $(n/n) \cdot ((n-1)/n) \cdot ((n-2)/n) \cdots$ As $n$ goes to infinity, subtracting a tiny number like 1 or 2 from infinity is meaningless. Every single one of these fractions evaluates to exactly $1$.
3. **The Negative Exponent Term:** $(1 - \lambda/n)^{-k}$. Because $\lambda$ divided by infinity is $0$, this becomes $(1 - 0)^{-k}$, which is just $1$.
4. **The Euler Term:** By the fundamental limit definition of Euler's number ($e$), the term $(1 - \lambda/n)^n$ mathematically converges perfectly to $e^{-\lambda}$.

**The Result:**
When the dust settles and all the $1$s multiply out, the discrete, clunky Binomial formula has collapsed into the exact PMF for a continuous Poisson Point Process:

:::{math}
:label: eq-mmp-persist-poisson-converged

P(X = k) = \frac{\lambda^k \cdot e^{-\lambda}}{k!}
:::

```text
=============================================================================
  VISUALIZING THE CONVERGENCE (Squeezing the Binomial)
=============================================================================
  n = 5 overpasses/day (Binomial is rigid, discrete, and blind to the gaps)
  [   ]  [ * ]  [   ]  [ * ]  [   ]

  n = 20 overpasses/day (The gaps shrink. It starts to look like a timeline)
  [ ][ ][*][ ][ ][ ][ ][*][ ][ ][ ][*][ ][ ][ ][ ][ ][*][ ][ ]

  n = ∞ overpasses/day (The Poisson Limit)
  The discrete brackets vanish. You are left with pure physical time.
  |------*--------------*-----------*------------------*-------| -> Continuous t
=============================================================================

```

---

## 10. Why the Point Process is Operationally Superior

Relying on a simple Binomial average ($p$) is highly dangerous for global environmental alerting systems like MARS {cite:p}`unepMars2022`. Here is exactly why the Thinned Point Process is strictly superior for methane monitoring:

* **Independence from Sensor Revisit Rates:** The simple average heavily depends on the satellite's specific orbit. If Sentinel-2 passes over every 5 days, a "60% persistency" is entirely coupled to that arbitrary 5-day cadence. Switch to a daily satellite, and the empirical ratio will wildly skew. A point process rate ($\lambda$) models the physical pipe, completely independent of the sensor's polling rate {cite:p}`schneising2024tropomi_persistent`.
* **Handling Asynchronous and Multi-Sensor Data:** If you monitor a site using Sentinel-2 (every 5 days), Landsat (every 8 days), and a continuous ground sensor, averaging "detections per observation" across different instruments creates a mathematically incoherent mess. A Point Process gracefully merges asynchronous data {cite:p}`sherwin2024singleblind, sherwin2022multiblind`. Every sensor simply applies its own specific atmospheric thinning filter ($\mathbb{E}[P_d]$) to update the single, universal ground-truth rate ($\lambda$).
* **Predictive Power for Wait Times:** A Binomial average looks backward; it only tells you what happened. A Point Process looks forward. Because the time between continuous events follows a probability distribution, once you invert your data to establish $\lambda$, you can calculate the exact expected wait time ($\mathbb{E}[\Delta t] = 1 / \lambda$, Eq. {eq}`eq-mmp-persist-wait-inhomo`) to optimize when to dispatch your LDAR repair crews {cite:p}`sherwin2023tiered_ldar`.
* **Isolating the Environment from the Asset:** A simple Binomial average mathematically penalizes a site for being cloudy. The Thinned Point Process strictly isolates the environmental filter from the source's physical intensity {cite:p}`ayasse2025probability`, allowing the UI dashboard to accurately label a site as **[ UNKNOWN / BLIND SPOT ]** rather than falsely granting it a **[ MITIGATED ]** compliance status.

## 11. Cross-Domain Equivalencies

This stochastic leap is not a novel academic exercise; it is the gold standard for dynamic systems. If stakeholders are skeptical of abandoning simple ratios, point them to how other rigorous engineering disciplines handle persistency:

* **Radar and Sonar Tracking (FISST):** In Finite Set Statistics, targets entering a sensor's field of view (and the false alarms generated by background clutter) are never modeled as simple ratios. They are modeled as Spatial Poisson Point Processes using Probability Hypothesis Density (PHD) filters.
* **Network Queueing Theory:** Network routers and server farms never use "average hits per observation window" to manage bandwidth. They model persistent request sources using Poisson or Markov-modulated point processes to gracefully handle asynchronous traffic spikes.
* **Geospatial Intelligence (GEOINT):** Persistent activity hotspots (like maritime loitering, illegal fishing, or illicit transshipments) are strictly modeled as spatial-temporal point processes to generate predictive risk heatmaps that account for satellite revisit blind spots.

---

:::{bibliography}
:filter: docname in docnames
:::
