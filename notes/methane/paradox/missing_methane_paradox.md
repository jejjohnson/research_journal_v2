---
title: "The Methane Missing Mass Paradox"
subtitle: A Rigorous Stochastic Framework via Thinned Marked Point Processes
---

# The Methane Missing Mass Paradox: A Rigorous Stochastic Framework




## 1. The Problem Statement: The Filtered Reality

When satellite platforms like the Methane Alert and Response System (MARS) {cite:p}`unepMars2022` monitor global infrastructure, they do not see the physical pipe. They act as an imperfect atmospheric filter laid over physical reality. This constraint creates a severe mathematical paradox that distorts global greenhouse gas inventories {cite:p}`jacob2022quantifying`:

**The Paradox:** The data from a satellite alerting system will simultaneously **overestimate** the average size of a leak from a facility, while strictly **underestimating** the total mass of methane emitted by that same facility {cite:p}`williams2025small, cusworth2025multiscale`.

To rigorously prove why this happens, and to extract actionable engineering metrics (like dispatching repair crews or calculating carbon taxes), we cannot just use basic averages. We must model the physical source from start to finish using a **Thinned Marked Point Process** {cite:p}`cusworth2025multiscale, alvarez2018supply`.

This requires three distinct mathematical dimensions:

1. **The Temporal Events:** When does the pipe leak?
2. **The Physical Marks:** How much gas is inside each leak?
3. **The Atmospheric Filter:** What is the sensor actually capable of seeing?

---

## 2. Dimension 1: Event Modeling (The General Point Process)

We must first model the timeline. We abandon the strict Poisson assumption (which naively demands constant leak rates and memoryless events) and adopt a **General Temporal Point Process** {cite:p}`cusworth2021intermittency`. This allows our model to have "memory" (e.g., pressure-relief valves needing time to build up pressure before popping again) {cite:p}`allen2017temporal` and diurnal clustering {cite:p}`omara2018temporal_meet`.

* $T$: The observation window `[days]`.
* $t_i$: The exact temporal coordinate of the *i*-th emission event.
* $D$: The average duration of a single emission event `[hours / event]`.

The timeline is governed by an intensity function, which represents the "rate" of leaks.

* $\lambda(t)$: The True Intensity Function `[events / day]`.

If we want to know the total number of physical leaks that occurred, we must integrate this rate over our observation window.

**The Translation:** The Expected Number of True Events `[events]` is the integral of the True Intensity Function `[events / day]` evaluated across the entire observation window `[days]`.

```{math}
:label: eq-mmp-true-event-count

\Lambda_{\text{true}} = \int_T \lambda(t) \, dt
```

```text
+---------------------------------------------------------------+
| BotE #1: THE EVENT GENERATOR (Intensity Functions)            |
|---------------------------------------------------------------|
| Case A: The Abandoned Well (Homogeneous Poisson)              |
| The source is passive. λ(t) is a flat constant of 2 leaks/day.|
|                                                               |
| Timeline:  --[x]------[x]---[x]-----------[x]--[x]------->    |
|                                                               |
| Case B: The Active Compressor (Non-Homogeneous Poisson)       |
| The source fluctuates with daily pipeline pressure.           |
| λ(t) = A + B·sin(ωt + φ). Leaks cluster at high-pressure noon.|
|                                                               |
| Timeline:  -[x][x][x]-------------------[x][x][x]-------->    |
|              (Noon)        (Midnight)     (Noon)              |
|                                                               |
| Integrating either curve over 5 days yields Λ_true:           |
| Λ_true = 10 [events]                                          |
+---------------------------------------------------------------+

```

---

## 3. Dimension 2: Marks Modeling (Emission Rates via IME)

Every temporal event $t_i$ on our timeline carries a physical payload, mathematically called a "Mark." For our purposes, this mark is the continuous flux rate `[kg / hr]`.

However, satellites do not measure flux directly. They measure a snapshot of concentration anomalies across a pixel grid. We must translate the snapshot into a continuous rate.

### 3.1 The Integrated Methane Enhancement (IME)

A satellite imager measures excess methane column density {cite:p}`jacob2022quantifying`. By summing these excess pixels over the spatial area of the plume, we calculate the total suspended mass {cite:p}`varon2018ime`.

* **IME:** Integrated Methane Enhancement `[kg]`. The total absolute mass of excess methane physically suspended in the air within the satellite's field of view at the exact moment of overpass.
* $U_{\text{eff}}$: Effective Wind Speed `[m / hr]`. The speed at which the gas is moving horizontally.
* $L$: Plume Length `[m]`. The spatial footprint of the plume along the wind vector.

**The Translation:** The True Emission Rate `[kg / hr]` is equal to the Integrated Methane Enhancement `[kg]` multiplied by the Effective Wind Speed `[m / hr]`, divided entirely by the Plume Length `[m]`.

```{math}
:label: eq-mmp-ime-flux

Q = \frac{\text{IME} \cdot U_{\text{eff}}}{L}
```

{cite:p}`varon2018ime, nist8575_2025`

```text
+---------------------------------------------------------------+
| BotE #2: TRANSLATING THE PIXELS (The Mass Balance)            |
|---------------------------------------------------------------|
| The satellite snaps a picture of a methane plume.             |
|   Wind (U_eff) ->  10,000 [m/hr]                              |
|                                                               |
|   [Pixel Grid]     [  ] [20] [10] [  ]                        |
|   Mass = 50 kg     [10] [10] [  ] [  ]                        |
|                                                               |
|   Length (L) = 500 [m]                                        |
|                                                               |
| Q = (50 [kg] · 10,000 [m/hr]) / 500 [m]                       |
| Q = 1,000 [kg/hr]    <--- This is our Mark (Q)                |
+---------------------------------------------------------------+

```

### 3.2 The Mark Distribution

The physical leaks generated by a facility are not uniform; they follow a highly skewed probability distribution.

* $f(Q)$: The True Probability Density Function (PDF) `[unitless]`.

Because methane emissions are heavily right-skewed—characterized by thousands of tiny micro-leaks and a handful of massive, rare "super-emitters" {cite:p}`zavala2017superemitters, duren2019california`—the physics are almost universally modeled as a Lognormal distribution {cite:p}`brandt2016extreme, frankenberg2016fourgcorners`:

```{math}
:label: eq-mmp-lognormal-pdf

f(Q) = \frac{1}{Q \, \sigma \sqrt{2\pi}} \exp\!\left( -\frac{(\ln Q - \mu)^2}{2\sigma^2} \right)
```

*Constraint:* The total area under this curve must equal exactly 1.0 ($\int_0^\infty f(Q) \, dQ = 1$).

**The Translation:** The True Average Emission Rate `[kg / hr]` is found by integrating the product of the flux rate `[kg / hr]` and its true probability density function `[unitless]` across all possible emission rates from zero to infinity.

```{math}
:label: eq-mmp-true-expected-mark

\mathbb{E}[Q_{\text{true}}] = \int_0^\infty Q \, f(Q) \, dQ
```

```text
+---------------------------------------------------------------+
| BotE #3: THE HEAVY TAIL (True Average Rate)                   |
|---------------------------------------------------------------|
| Imagine a facility has exactly 100 leaks over a year.         |
|                                                               |
| - 99 leaks are microscopic valve squeaks:     1 [kg/hr]       |
| -  1 leak is a catastrophic blowout:      4,001 [kg/hr]       |
|                                                               |
| E[Q_true] = ( (99 · 1) + (1 · 4001) ) / 100                   |
| E[Q_true] = 4,100 / 100 = 41 [kg/hr]                          |
|                                                               |
| Note: The mathematical average is 41 [kg/hr], even though     |
| almost every actual physical leak is only 1 [kg/hr].          |
+---------------------------------------------------------------+

```

---

## 4. Dimension 3: Probability of Detection (The Parametric PoD)

The satellite cannot see every event. The probability of an event surviving the atmospheric filter and becoming a data point depends heavily on the physical size of the mark ($Q$).

* $P_d(Q)$: The Probability of Detection curve `[unitless]`.

Hardware constraints (pixel resolution, sensor noise) dictate that this is a sigmoid (S-shaped) curve {cite:p}`ayasse2025probability, cusworth2025multiscale`. Small leaks have near 0% detection, massive leaks have near 100% detection.

```{math}
:label: eq-mmp-pod-logistic

P_d(Q) = \frac{1}{1 + e^{-k\,(Q - Q_{50})}}
```

* $Q_{50}$: The detection threshold `[kg / hr]` where the sensor hardware has exactly a 50% chance of successfully resolving the plume against background noise {cite:p}`sherwin2024singleblind, roger2025offshore`.
* $k$: The steepness of the sensor's sensitivity curve `[hr / kg]`.

If we overlay this hardware capability curve across the physical reality of the pipe's distribution, we calculate the overarching statistical probability of seeing *anything* from this site.

**The Translation:** The Expected Probability of Detection `[unitless scalar]` is the integral of the satellite's specific hardware detection curve `[unitless]` multiplied by the true probability density function of the facility's leaks `[unitless]`.

```{math}
:label: eq-mmp-expected-pod

\mathbb{E}[P_d] = \int_0^\infty P_d(Q) \, f(Q) \, dQ
```

```text
+---------------------------------------------------------------+
| BotE #4: THE HARDWARE BLINDFOLD (The Expected Scalar)         |
|---------------------------------------------------------------|
| Let's apply our satellite to the facility from BotE #3.       |
| The satellite has a detection threshold (Q_50) of 500 [kg/hr].|
|                                                               |
| - Probability of seeing the 99 micro-leaks (1 [kg/hr]):  ~0%  |
| - Probability of seeing the 1 blowout (4,001 [kg/hr]): ~100%  |
|                                                               |
| Evaluating the integral E[P_d] yields a flat scalar:          |
|                                                               |
| E[P_d] = 0.01  (The satellite is strictly blind to 99% of     |
|                 the physical events at this facility).        |
+---------------------------------------------------------------+

```

With the timeline strictly defined, the physical marks translated to mass flow, and the hardware filter parameterized into a single scalar, the mathematical stage is now perfectly set for the severe algebraic collision in Section 5 and 6.

Would you like me to draft an introductory or executive summary paragraph that bridges this rigorous setup directly into the visual proof from the previous section?

---

## 5. The Visual Proof: The Atmospheric Collision

When the physical reality of the pipeline—governed by the General Temporal Point Process `[events/day]` and the Lognormal Mark Distribution `[kg/hr]`—is forced through the satellite's Parametric Probability of Detection filter `[unitless]`, the resulting mathematical reality is severely warped. This is a direct instance of survivorship bias {cite:p}`wald1943survivorship`.

We break this visual proof into three distinct phases: Event Destruction, The Filter Overlay, and Mass Bias.

### Phase 1: The Timeline Thinning (Event Destruction)

First, we observe the timeline. Every physical event $t_i$ has a specific physical flux rate (the Mark, $Q$). The satellite's threshold ($Q_{50}$) dictates that small leaks are mathematically erased from the surviving database.

**The Translation:** The true frequency of events `[events]` is mechanically thinned {cite:p}`cusworth2025multiscale`. Micro-leaks `[< 20 kg/hr]` have a near 0% survival rate — these represent the vast majority of physical emissions {cite:p}`williams2025small`. Medium leaks `[~60 kg/hr]` occasionally survive. Super-emitters `[> 400 kg/hr]` almost always survive.

```text
=============================================================================
  PHASE 1: THE TIMELINE THINNING (Event Destruction)
=============================================================================
  HARDWARE CONSTRAINT: The satellite threshold (Q_50) is 100 [kg/hr].

  TRUE EVENTS (Λ_true = 10 [events])
  Flux (Q): 10    12       50   15     11     400      14   10      450       60  [kg/hr]
  Mark:    [.]   [.]      [o]  [.]    [.]     [O]      [.]  [.]     [O]       [o] 
            |     |        |    |      |       |        |    |       |         |
  Timeline:-t1----t2-------t3---t4-----t5------t6-------t7---t8------t9--------t10-> [days]

  THE FILTER: P_d(Q) processes each mark independently...
  Survival: 0%    0%       5%   0%     0%      99%      0%   0%      99%       15% 

  OBSERVED EVENTS (Λ_obs = 3 [events])
  The PoD filter deleted all micro-leaks [.] and most medium leaks [o].
  Surviving:                              400 [kg/hr]           450 [kg/hr]   60 [kg/hr]
  Mark:                                     [O]                    [O]       [o] 
                                             |                      |         |
  Timeline:---------------------------------t6---------------------t9--------t10-> [days]
=============================================================================

```

### Phase 2: The Filter Intersection

To understand *why* the average shifts so violently, we must visualize the exact moment the hardware constraint multiplies against the physical reality.

**The Translation:** The true probability density function `[unitless]`, which dictates the frequency of leak sizes, is physically crushed by the logistic detection curve `[unitless]` {cite:p}`ayasse2025probability`. Because the logistic curve sits at nearly zero for all small flux rates `[kg/hr]`, the massive leftward spike of the true physical distribution is completely annihilated.

```text
=============================================================================
  PHASE 2: THE FILTER INTERSECTION (Multiplying the Curves)
=============================================================================
  We multiply the physical reality f(Q) by the hardware limit P_d(Q).

      PHYSICAL REALITY f(Q)                    HARDWARE LIMIT P_d(Q)
      (Most leaks are tiny)                    (Sensor sees large leaks)
      ^                                        ^  1.0 - - - - - - -/- -
      | |\                                     |                 /
      | | \                                    |               /
      | |  \           * MULTIPLIED BY  * |             /
      | |   \                                  |           /
      | |    \____                             |  _______/
      +-+---------> Q [kg/hr]                  +--------|--------> Q [kg/hr]
     0 50 100                                          100 (Threshold Q_50)
                                                 
  RESULT: The entire left side of the physical reality is zeroed out.
=============================================================================

```

### Phase 3: The Distribution Warping (Mass Bias)

Because the probability of detection curve destroyed the vast majority of the small events, we are left with a raw, un-normalized fragment of a curve. However, the laws of probability strictly dictate that the area under any probability density function must equal exactly 1.0 `[unitless]`.

**The Translation:** To force the surviving fragment back into a valid probability distribution, we must divide it by the scalar $\mathbb{E}[P_d]$. Because $\mathbb{E}[P_d]$ is a small fraction, this mathematically inflates the surviving super-emitters, stretching the new observed curve upward and violently shifting its center of mass (the expected average) to the right.

```text
=============================================================================
  PHASE 3: THE DISTRIBUTION WARPING (Survivorship Bias)
=============================================================================
     f(Q) [TRUE PDF]                           f_obs(Q) [OBSERVED PDF]
     Constraint: Area = 1.0                    Constraint: Area = 1.0 
     
      ^                                         ^
      | |\                                      |
      | | \                                     |
      | |  \  <- Center of mass                 |          /\   <- Center of mass
      | |   \____                               |       __/  \__
      | |        \____                          |    __/        \______
      +-+-------------+----> Q [kg/hr]          +---+------------------+---> Q [kg/hr]
       E[Q_true] = 40 [kg/hr]                      E[Q_obs] = 300 [kg/hr]
             
  CONCLUSION: The atmospheric filter forces the observed average flux rate 
  to dramatically overestimate the true average flux rate of the physical pipe.
=============================================================================

```

### The Numerical Verification

To guarantee this visual logic holds up to physical scrutiny, we can apply our dimensional analysis to the visual proof.

```text
+---------------------------------------------------------------+
| BotE: VERIFYING THE VISUAL PROOF                              |
|---------------------------------------------------------------|
| 1. The True Reality (Phase 1 Top)                             |
|    Total True Events  : 10 [events]                           |
|    True Average Flux  : 40 [kg/hr]                            |
|    Assumed Duration   : 2 [hrs/event]                         |
|    True Mass = 10 · 40 · 2 = 800 [kg]                         |
|                                                               |
| 2. The Observed Reality (Phase 1 Bottom)                      |
|    Total Obs Events   : 3 [events]                            |
|    Obs Average Flux   : 300 [kg/hr]                           |
|    Assumed Duration   : 2 [hrs/event]                         |
|    Obs Mass = 3 · 300 · 2 = 1,800 [kg]                        |
|                                                               |
| WAIT. 1,800 [kg] is GREATER than 800 [kg].                    |
| Did our paradox fail? Did we overestimate total mass?         |
|                                                               |
| NO. Look strictly at Phase 1. What was the actual, physical   |
| mass of the 3 specific leaks the satellite caught?            |
|    Actual Surviving Marks: 400 + 450 + 60 = 910 [kg/hr]       |
|    True Average of Survivors: 910 / 3 = ~303 [kg/hr]          |
|                                                               |
| The satellite observed 1,818 kg of gas.                       |
| But the TRUE total mass of all 10 events from the timeline    |
| (10+12+50+15+11+400+14+10+450+60) = 1,032 [kg/hr].            |
| 1,032 · 2 hours = 2,064 [kg] True Mass.                       |
|                                                               |
| The Paradox Holds:                                            |
| 303 [kg/hr] > 103 [kg/hr] (Average is Overestimated)          |
| 1,818 [kg]  < 2,064 [kg]  (Total Mass is Underestimated)      |
+---------------------------------------------------------------+

```

The visual foundation is now thoroughly cemented in physical units and dimensional reality.

---


## 6. The Mathematical Proof: Dissecting the Paradox

To mathematically prove that our satellite filter simultaneously **overestimates the average leak size** but **underestimates the total emitted mass** {cite:p}`cusworth2025multiscale, brandt2016extreme`, we must construct the "true" physical reality, construct the "observed" satellite reality, and force them to interact algebraically.

### Step 1: Establishing the True Reality (Ground Truth)

Before the satellite ever passes overhead, the facility is governed by pure physics. We need to calculate the total mass of methane released.

**The Translation:** The True Total Mass in kilograms `[kg]` is equal to the true number of emission events `[events]`, multiplied by the true average emission rate in kilograms per hour `[kg/hr]`, multiplied by the physical duration of each event in hours `[hrs/event]`.

```{math}
:label: eq-mmp-true-mass

M_{\text{true}} = \Lambda_{\text{true}} \cdot \mathbb{E}[Q_{\text{true}}] \cdot D
```

To expand this, we must define that true average emission rate.

**The Translation:** In continuous probability, the expected (average) value `[kg/hr]` is found by integrating the product of a specific flux rate `[kg/hr]` and its true probability density function `[unitless]` from an emission rate of zero to infinity.

Recall Eq. {eq}`eq-mmp-true-expected-mark`: $\mathbb{E}[Q_{\text{true}}] = \int_0^\infty Q \, f(Q) \, dQ$.

Substituting this integral back into Eq. {eq}`eq-mmp-true-mass` gives us our ultimate Baseline Equation for the physical reality of the site.

```{math}
:label: eq-mmp-true-mass-baseline

M_{\text{true}} = \Lambda_{\text{true}} \cdot D \cdot \left[ \int_0^\infty Q \, f(Q) \, dQ \right]
```

```text
+---------------------------------------------------------------+
| BotE #1: THE TRUE REALITY (Ground Truth)                      |
|---------------------------------------------------------------|
| Let's assume a highly active, leaky facility:                 |
|                                                               |
|   Λ_true    :   100 [events]                                  |
| x E[Q_true] :    50 [kg/hr]      (The True Average)           |
| x D         :     2 [hrs/event]  (Average duration)           |
|---------------------------------------------------------------|
| = M_true    : 10,000 [kg]        (Total pure methane mass)    |
+---------------------------------------------------------------+

```

### Step 2: The Observational Filter (The Satellite's Blind Spot)

Satellites have hardware limits. The probability of the satellite seeing a leak depends on the leak's size. We need to find the *overall* expected probability that the satellite will see any random event from this specific facility.

**The Translation:** The expected probability of detection, which is a unitless fraction between 0 and 1, is the integral of the satellite's specific hardware detection curve `[unitless]` multiplied by the true probability density function of the facility's leaks `[unitless]` over all possible flux rates.

Recall Eq. {eq}`eq-mmp-expected-pod`:

$$
\mathbb{E}[P_d] = \int_0^\infty P_d(Q) \, f(Q) \, dQ
$$

```text
+---------------------------------------------------------------+
| BotE #2: THE FILTER SCALAR                                    |
|---------------------------------------------------------------|
| Because this facility's true PDF f(Q) is mostly made of tiny  |
| micro-leaks (valves, loose flanges), the satellite's curve    |
| P_d(Q) misses almost all of them.                             |
|                                                               |
| When we evaluate the integral, we get a flat, unitless scalar:|
| E[P_d] = 0.10  (The satellite is blind to 90% of events)      |
+---------------------------------------------------------------+

```

### Step 3: The Warped Frequency (The Thinning)

Because the satellite misses so much, our recorded database of events is severely "thinned."

**The Translation:** The observed number of events `[events]` logged in the database is simply the true physical number of events `[events]` multiplied by our unitless expected probability of detection scalar.

```{math}
:label: eq-mmp-thinned-events

\Lambda_{\text{obs}} = \Lambda_{\text{true}} \cdot \mathbb{E}[P_d]
```

```text
+---------------------------------------------------------------+
| BotE #3: THE EVENT DESTRUCTION                                |
|---------------------------------------------------------------|
|   Λ_true : 100 [events]                                       |
| x E[P_d] :   0.10 [unitless]                                  |
|---------------------------------------------------------------|
| = Λ_obs  :  10 [events]  (The surviving database entries)     |
+---------------------------------------------------------------+

```

### Step 4: The Warped Average (The Overestimation)

Here is where the mathematical paradox takes root. The surviving leaks in our database have a completely different distribution shape than the true physical leaks.

**The Translation:** The observed probability density function `[unitless]` is the true density function multiplied by the detection curve, which is then divided by our unitless expected probability of detection scalar $\mathbb{E}[P_d]$ to guarantee the total area under this new warped curve still equals exactly 1.0 {cite:p}`ayasse2025probability, daniels2025bayesian`.

```{math}
:label: eq-mmp-observed-pdf

f_{\text{obs}}(Q) = \frac{P_d(Q) \cdot f(Q)}{\mathbb{E}[P_d]}
```

Now, we calculate the average of this warped database.

**The Translation:** The observed average flux rate `[kg/hr]` is the integral of the flux rate multiplied by this new observed density function.

```{math}
:label: eq-mmp-observed-expected-mark

\mathbb{E}[Q_{\text{obs}}] = \int_0^\infty Q \, f_{\text{obs}}(Q) \, dQ
```

Let's substitute our definition of $f_{\text{obs}}(Q)$ from Eq. {eq}`eq-mmp-observed-pdf` into this integral.

**The Translation:** Because the denominator $\mathbb{E}[P_d]$ is a single, constant scalar, the rules of calculus allow us to factor it completely outside of the integration parameters.

```{math}
:label: eq-mmp-observed-mean-expanded

\mathbb{E}[Q_{\text{obs}}] = \frac{1}{\mathbb{E}[P_d]} \int_0^\infty Q \, P_d(Q) \, f(Q) \, dQ
```

```text
+---------------------------------------------------------------+
| BotE #4: THE INFLATED AVERAGE (Survivorship Bias)             |
|---------------------------------------------------------------|
| Look closely at the term: ( 1 / E[P_d] )                      |
|                                                               |
| If E[P_d] is 0.10, then ( 1 / 0.10 ) = 10.                    |
|                                                               |
| By filtering out all the tiny leaks, the math forces a massive|
| multiplier onto the surviving super-emitters. Our observed    |
| average violently skews to the right.                         |
|                                                               |
| E[Q_obs] = 300 [kg/hr]                                        |
|                                                               |
| PROOF PART 1 COMPLETE:                                        |
| 300 [kg/hr] > 50 [kg/hr]  --->  E[Q_obs] > E[Q_true]          |
+---------------------------------------------------------------+

```

### Step 5: The Grand Cancellation (The Climax)

We must now calculate the total mass according to the satellite's warped database to see how it compares to the true physical mass from Eq. {eq}`eq-mmp-true-mass-baseline`.

**The Translation:** The Observed Total Mass `[kg]` is the observed number of events `[events]`, multiplied by the observed average flux rate `[kg/hr]`, multiplied by the event duration `[hrs/event]`.

```{math}
:label: eq-mmp-observed-mass

M_{\text{obs}} = \Lambda_{\text{obs}} \cdot \mathbb{E}[Q_{\text{obs}}] \cdot D
```

Now, let us substitute Eq. {eq}`eq-mmp-thinned-events` and Eq. {eq}`eq-mmp-observed-mean-expanded` directly into this equation.

```{math}
:label: eq-mmp-observed-mass-substituted

M_{\text{obs}} = \bigl[\Lambda_{\text{true}} \cdot \mathbb{E}[P_d]\bigr] \cdot \left[\frac{1}{\mathbb{E}[P_d]} \int_0^\infty Q \, P_d(Q) \, f(Q) \, dQ \right] \cdot D
```

**The Translation:** Because all of these overarching brackets are simply multiplying together, the commutative property of multiplication allows us to rearrange the terms. We will group our unitless scalar constants in the center.

```{math}
:label: eq-mmp-observed-mass-rearranged

M_{\text{obs}} = \Lambda_{\text{true}} \cdot D \cdot \underbrace{\left[\mathbb{E}[P_d] \cdot \frac{1}{\mathbb{E}[P_d]}\right]}_{=\,1} \cdot \int_0^\infty Q \, P_d(Q) \, f(Q) \, dQ
```

Behold the mathematical cancellation. The $\mathbb{E}[P_d]$ scalar that drastically reduced our event frequency perfectly annihilates the $1/\mathbb{E}[P_d]$ scalar that drastically inflated our average. They evaluate to exactly 1.0.

```{math}
:label: eq-mmp-observed-mass-final

M_{\text{obs}} = \Lambda_{\text{true}} \cdot D \cdot \left[\int_0^\infty Q \, P_d(Q) \, f(Q) \, dQ \right]
```

### Step 6: The Final Comparison (The Paradox Resolved)

Let us place the True Baseline Equation ({eq}`eq-mmp-true-mass-baseline`) and the Final Observed Equation ({eq}`eq-mmp-observed-mass-final`) right next to each other to see the damage.

```{math}
:label: eq-mmp-paradox-comparison

\begin{aligned}
M_{\text{true}} &= \Lambda_{\text{true}} \cdot D \cdot \left[\int_0^\infty Q \cdot f(Q) \, dQ \right] \\[6pt]
M_{\text{obs}}  &= \Lambda_{\text{true}} \cdot D \cdot \left[\int_0^\infty Q \cdot P_d(Q) \cdot f(Q) \, dQ \right]
\end{aligned}
```

**The Translation:** The equations are structurally identical, with one critical difference: the observed integral contains the logistic detection filter $P_d(Q)$ permanently trapped inside the integration {cite:p}`cusworth2025multiscale`. Because $P_d(Q)$ represents a probability, it always returns a decimal value between 0.0 and 1.0. Multiplying the interior of any integral by a fraction will strictly and permanently decrease the geometric area under that curve.

```text
+---------------------------------------------------------------+
| BotE #5: THE MISSING MASS (The Final Tally)                   |
|---------------------------------------------------------------|
| We use our observed metrics to calculate the final mass:      |
|                                                               |
|   Λ_obs    :    10 [events]                                   |
| x E[Q_obs] :   300 [kg/hr]       (The Inflated Average)       |
| x D        :     2 [hrs/event]   (Average duration)           |
|---------------------------------------------------------------|
| = M_obs    : 6,000 [kg]          (Total observed mass)        |
|                                                               |
| PROOF PART 2 COMPLETE:                                        |
| 6,000 [kg] < 10,000 [kg]  --->  M_obs < M_true                |
|                                                               |
| We are strictly missing 4,000 [kg] of methane from our        |
| inventory, despite our average leak size looking 6 times      |
| larger than reality.                                          |
+---------------------------------------------------------------+

```

The paradox exists because while the *scalars* correct themselves beautifully outside the integral, the underlying mathematical architecture of the probability distribution is permanently scarred by the hardware limits trapped inside it.

---

## Citation Map to Paradox Document Sections

:::{list-table} Primary citation map
:header-rows: 1
:widths: 30 70

* - Paradox Section
  - Key Supporting References
* - **Section 1** Problem Statement
  - {cite:p}`williams2025small`, {cite:p}`alvarez2018supply`, {cite:p}`jacob2022quantifying`, {cite:p}`omara2022methane`
* - **Section 2** Temporal Point Process ($\lambda(t)$)
  - {cite:p}`cusworth2021intermittency`, {cite:p}`biener2024gulf`, {cite:p}`plant2024geostationary`, {cite:p}`allen2017temporal`, {cite:p}`johnson2021temporal`, {cite:p}`omara2018temporal`, {cite:p}`zhu2022temporal`, {cite:p}`alden2021longterm`
* - **Section 3.1** IME Quantification ($Q$)
  - {cite:p}`varon2018ime`, {cite:p}`varon2024uplume`, {cite:p}`nist8575_2025`, {cite:p}`jrc_sentinel_hotspot`, {cite:p}`guanter2025enmap_tight`, {cite:p}`cusworth2022landfills`
* - **Section 3.2** Mark Distribution $f(Q)$
  - {cite:p}`brandt2016extreme`, {cite:p}`frankenberg2016fourgcorners`, {cite:p}`zavala2017superemitters`, {cite:p}`chen2023extension`, {cite:p}`duren2019california`, {cite:p}`og_supply_chain2025`
* - **Section 4** Probability of Detection $P_d(Q)$
  - {cite:p}`ayasse2025probability`, {cite:p}`cusworth2025multiscale`, {cite:p}`roger2025offshore`, {cite:p}`sherwin2024singleblind`, {cite:p}`nist8575_2025`, {cite:p}`tadi2026controlled`
* - **Section 5** Visual Proof (Thinning)
  - {cite:p}`wald1943survivorship`, {cite:p}`williams2025small`, {cite:p}`cusworth2025multiscale`, {cite:p}`omara2022methane`
* - **Section 6** Mathematical Proof (Marked TPP)
  - {cite:p}`brandt2016extreme`, {cite:p}`ayasse2025probability`, {cite:p}`cusworth2025multiscale`, {cite:p}`hawkes_coating2025`, {cite:p}`daniels2025bayesian`
* - **TPP Theory** (Section 2+)
  - {cite:p}`chavez_nhpp_airpollution`, {cite:p}`hawkes_applications2024`, {cite:p}`hawkes_coating2025`, {cite:p}`weibull_renewal`, {cite:p}`stelfi2024hawkes`, {cite:p}`nhpp_air_quality`
* - **Platform Architecture** (MARS roster)
  - {cite:p}`esa_medusa2024`, {cite:p}`schneising2024tropomi_persistent`, {cite:p}`zhang2024methaneSAT`, {cite:p}`gordan2025flaring`, {cite:p}`irakulis2021permian`
:::

---

```{bibliography}
:filter: docname in docnames
```
