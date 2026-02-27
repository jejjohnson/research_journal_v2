---
title: "The Thinned Marked Temporal Point Process"
subtitle: A Pedantic Construction from Temporal Events to Observational Bias
---

# The Thinned Marked Temporal Point Process

This section constructs the mathematical architecture of a Thinned Marked Temporal Point Process (TMTPP) from the ground up {cite:p}`cusworth2025multiscale, alvarez2018supply`. To understand a TMTPP in the context of global methane infrastructure, we assemble it piece by piece: defining the physical reality, assigning strict mathematical variables, and visualizing how each atmospheric layer transforms the one below it.

---

## 1. The Temporal Point Process (The "When")

Before we care about how big a leak is, or if a satellite can see it, we must first mathematically model the sheer existence of events in time {cite:p}`cusworth2021intermittency`.

Physically, imagine a pressure-relief valve on a liquid natural gas storage tank. As pressure builds and drops, the valve periodically vents methane into the atmosphere {cite:p}`allen2017temporal`. Each vent is a discrete, instantaneous event occurring at a specific moment.

### The Ontology (The Temporal Truth)

* $t$: The continuous timeline `[hours]`. This operates on the domain $[0, \infty)$.
* $t_i$: The exact timestamp of the *i*-th emission event.
* $N_{\text{true}}(t)$: The True Counting Process `[events]`. The total accumulated number of physical events that have occurred from time 0 up to time $t$. Mathematically, it is a right-continuous step function that jumps by exactly +1 at every $t_i$.
* $\lambda_{\text{true}}(t)$: The True Intensity Function `[events / hour]`. This governs how rapidly events are physically arriving. If the tank heats up at noon, $\lambda_{\text{true}}(t)$ increases. If it cools at night, $\lambda_{\text{true}}(t)$ decreases.

**The Translation:** The True Cumulative Intensity Function `[events]` is the expected total number of physical events up to time $t$. It is the fundamental link between the rate and the count, defined strictly as the integral of the intensity over the time window (cf. Eq. {eq}`eq-mmp-true-event-count`).

```{math}
:label: eq-mmp-tpp-cumulative-intensity

\Lambda_{\text{true}}(t) = \int_0^t \lambda_{\text{true}}(u) \, du
```

```text
=============================================================================
  STEP 1: THE TEMPORAL POINT PROCESS (The Pure Chronology)
=============================================================================
  The pure chronology of the methane valve venting.
  Every "x" is an event occurring at a specific time t_i.

  Timeline:
  --x-------x-----------x----x--x----------x-----------------x------x---> t [hours]
    t₁      t₂          t₃   t₄ t₅         t₆                t₇     t₈

  NOTICE: We know exactly WHEN they happened, but we know nothing else.
  The points have no mass. They are purely temporal coordinates.
=============================================================================
```

---

## 2. Adding the "Marks" (The "What")

A timestamp alone is physically meaningless for a greenhouse gas inventory. To model reality, every temporal event must carry a physical payload. In stochastic geometry, this payload is called a "Mark."

Physically, the mark is the severity of the valve's vent---the exact mass flux or emission rate of the methane plume {cite:p}`brandt2016extreme`.

### The Ontology (The Physical Truth)

* $Q_i$: The True Mark `[kg/hr]`. The specific, actual emission rate associated with the event at time $t_i$. It exists in the Mark Space (a set of all possible emission rates, typically all real numbers > 0).
* $f_{\text{true}}(Q)$: The True Mark Distribution (PDF) `[unitless]`. The underlying probability distribution that dictates the physical size of these vents. For methane, this is famously a heavy-tailed Lognormal distribution---most vents are tiny, a few are massive blowouts {cite:p}`brandt2016extreme, zavala2017superemitters`.
* *Constraint:* The total area under the curve must equal exactly 1.0 ($\int_0^{\infty} f_{\text{true}}(Q) \, dQ = 1.0$).

**The Translation:** The True Expected Mark `[kg/hr]` is the mathematical center of mass of the true physical leaks. It is the integral of the flux rate multiplied by its true probability distribution (cf. Eq. {eq}`eq-mmp-true-expected-mark`).

```{math}
:label: eq-mmp-tpp-expected-mark

\mathbb{E}[Q_{\text{true}}] = \int_0^{\infty} Q \cdot f_{\text{true}}(Q) \, dQ
```

* $\lambda_{\text{true}}(t, Q)$: The True Joint Intensity Function. Assuming the size of the leak is independent of when it happens, the entire physical system is defined by multiplying the temporal rate by the mark distribution:

```{math}
:label: eq-mmp-tpp-joint-intensity

\lambda_{\text{true}}(t, Q) = \lambda_{\text{true}}(t) \cdot f_{\text{true}}(Q)
```

```text
=============================================================================
  STEP 2: THE MARKED TEMPORAL POINT PROCESS (Adding Mass)
=============================================================================
  Every event t_i now carries a true physical weight Q_i.
  Our 1D timeline gains a Y-axis. Every event becomes a vertical stem.

  Q [kg/hr]
   ^
   |        [Q₂]                                             [Q₇]
   |         |                                                |
   |         |          [Q₃]                                  |
   |         |           |   [Q₄]                             |
   |   [Q₁]  |           |    |            [Q₆]               |
   |    |    |           |    |  [Q₅]       |                 |     [Q₈]
 --+----x----x-----------x----x---x---------x-----------------x------x---> t [hours]
        t₁   t₂          t₃   t₄  t₅        t₆                t₇     t₈
=============================================================================
```

---

## 3. Independent Thinning (The "Filter")

Now we introduce the observer (e.g., the MARS satellite network) {cite:p}`unepMars2022`. The observer is imperfect. It cannot see every plume {cite:p}`ayasse2025probability`. The physical reality must pass through an observational filter.

Physically, a tiny puff of methane (a small mark) will be immediately dispersed by wind shear and fall below the satellite's pixel resolution. A massive blowout (a large mark) will almost certainly trigger an anomaly.

This process of selective deletion is called **Thinning**. Mathematically, it invokes a fundamental theorem: Independent Thinning splits the original point process into two entirely separate, independent point processes---the "Observed" process and the "Hidden" process {cite:p}`cusworth2025multiscale`.

### The Ontology (The Sensor Limit)

* $P_d(Q)$: The Probability of Detection `[unitless fraction]`. This is a conditional probability function. Given a true plume of size $Q$, what is the mathematical probability $[0.0, 1.0]$ that the sensor registers it? (cf. Eq. {eq}`eq-mmp-pod-logistic`).

**The Bernoulli Trial:** For every single marked point $(t_i, Q_i)$ generated by the source, the universe flips a weighted coin. The probability of "Heads" (surviving the atmospheric filter) is exactly $P_d(Q_i)$. If it lands "Tails", the point is permanently deleted from our observed dataset and banished to the Hidden process.

```text
=============================================================================
  STEP 3: THE THINNING PROCESS (The Observational Sieve)
=============================================================================
  The sensor applies the P_d(Q) filter.
  Small leaks have a near-zero chance of survival.

  Q [kg/hr]
   ^
   |        [Q₂] <---- (Massive leak. P_d = 0.99. SURVIVES)  [Q₇] <-(SURVIVES)
   |         |                                                |
   |         |          [Q₃] <---- (Medium. P_d = 0.40. LOST) |
   |         |           |   [Q₄] <--- (Small. P_d = 0.05. LOST)
   |   [Q₁]  |           |    |            [Q₆] <--- (Medium. SURVIVES)
   |    |    |           |    |  [Q₅]       |                 |     [Q₈]
 --+----x----x-----------x----x---x---------x-----------------x------x---> t [hours]
       LOST SURVIVED    LOST LOST LOST   SURVIVED          SURVIVED LOST
=============================================================================
```

---

## 4. The Final State (The Thinned Marked Process)

We have arrived at the final dataset sitting on the MARS servers {cite:p}`unepMars2022, irakulis2024marsOps`.

The physical process has been temporally sparsified (events appear to occur much less frequently) and its marks have been violently biased (only the large vents remain) {cite:p}`williams2025small`. To calculate exactly how the data is warped, we must integrate out the dependencies and compare them to the True ontology defined in Steps 1 and 2.

### The Ontology (The Observed Reality)

**The Translation:** The Expected Probability of Detection `[unitless scalar]` is the denominator that anchors our skewed distribution, found by integrating the detection curve against the true physical leak sizes (cf. Eq. {eq}`eq-mmp-expected-pod`).

```{math}
:label: eq-mmp-tpp-expected-pd

\mathbb{E}[P_d] = \int_0^{\infty} P_d(Q) \cdot f_{\text{true}}(Q) \, dQ
```

* $\lambda_{\text{obs}}(t)$: The Observed Intensity `[events / hour]`. The rate at which MARS actually records detections. It is the true intensity severely crippled by the overall expectation of detection (cf. Eq. {eq}`eq-mmp-thinned-events`):

```{math}
:label: eq-mmp-tpp-observed-intensity

\lambda_{\text{obs}}(t) = \lambda_{\text{true}}(t) \cdot \mathbb{E}[P_d]
```

**The Translation:** The Observed Mark Distribution `[unitless]` is the skewed distribution of the plumes MARS caught. We multiply the physical truth by the hardware filter, and divide by the expectation scalar to force the area under the new curve to remain 1.0 (cf. Eq. {eq}`eq-mmp-observed-pdf`).

```{math}
:label: eq-mmp-tpp-observed-mark-dist

f_{\text{obs}}(Q) = \frac{P_d(Q) \cdot f_{\text{true}}(Q)}{\mathbb{E}[P_d]}
```

**The Translation:** The Observed Expected Mark `[kg/hr]` is the center of mass of the leaks the satellite *actually saw*. Because the small leaks were deleted by the Bernoulli trial, this is mathematically forced to be drastically larger than $\mathbb{E}[Q_{\text{true}}]$ {cite:p}`williams2025small, jacob2022quantifying` (cf. Eq. {eq}`eq-mmp-observed-expected-mark`).

```{math}
:label: eq-mmp-tpp-expected-obs-mark

\mathbb{E}[Q_{\text{obs}}] = \int_0^{\infty} Q \cdot f_{\text{obs}}(Q) \, dQ
```

```text
=============================================================================
  STEP 4: THE THINNED MARKED TEMPORAL POINT PROCESS (The MARS Data)
=============================================================================
  This is the final mathematical object you are forced to work with.
  The source appears to vent rarely, but when it does, the vents
  appear massive.

  Q_obs [kg/hr]
   ^
   |        [Q₂]                                             [Q₇]
   |         |                                                |
   |         |                                                |
   |         |                                                |
   |         |                             [Q₆]               |
   |         |                              |                 |
 --+---------x------------------------------x-----------------x----------> t [hours]
             t₂                             t₆                t₇
=============================================================================
```

## The Pedagogical Summary

* **Temporal:** The physical infrastructure creates a true, un-thinned timeline of events ($t$).
* **Marked:** Physics dictates that every event must carry a true, physical emission mass ($Q$).
* **Thinned:** The atmosphere and the satellite sensor act as a probabilistic sieve, discarding events based on their mass ($P_d$), leaving MARS with a mathematically warped Observed timeline and heavily biased Mark distribution.

To successfully mitigate a methane facility, you cannot trust Step 4. You must take the biased, sparse data from Step 4 and use stochastic inversion to mathematically reverse-engineer it all the way back to the physical reality of Step 2 {cite:p}`cusworth2025multiscale`.

```{bibliography}
:filter: docname in docnames
```
