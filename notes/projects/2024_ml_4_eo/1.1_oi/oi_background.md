# Optimal Interpolation

> *Points close together in space are more likely to have similar values than points far apart* - Tobler's First Law of Geography, 1970


---

**Objective**

Our objective is to estimate a scalar or vector value at an unknown location given some known scalar or vector value(s) in some known location(s). 
These known values are often called: *control points*, *sampled points*, or *observations*.
The unknown values are often called *queries* or test points.

$$
\begin{aligned}
\text{Observations}: && &&
\boldsymbol{y} &= \boldsymbol{y}(\mathbf{x},t), 
&& &&
\mathbf{x}\in\Omega_y\in\mathbb{R}^{D_s} \\
\text{Queries}: && &&
\boldsymbol{y} &= \boldsymbol{y}(\mathbf{x},t), 
&& &&
\mathbf{x}\in\Omega_z\in\mathbb{R}^{D_s}
\end{aligned}
$$

Notice how the only difference between these two equations is the domain, $\Omega_y,\Omega_z$.
This class of problems is known as **Spatial Interpolation**, i.e., estimate unknown points by similarity and proximity with known points.
Some example applications include:

* Evaluate new value at an explicit grid point. For example, we may have data in seemingly random locations. However, we are interested in those values at a particular grid point.
* Replace missing or erroneous data.



---

**Problem**

It is impossible to measure continuous variables at all points. 
We have an infinite number of points that make up the entire spatiotemporal domain yet only finite time and resources to do computation. 
Furthermore, it is impossible to observe and store all points in the domain which results in inherently inaccessible points.


---

**Assumption**


We can assume that interpolation works where values are spatially dependent.
In other words, we assume that similar values *cluster* together in a spatiotemporal map.
Another way to state this is that points are *spatially autocorrelated* or have *similar z-values*.
Conversely, we cannot interpolate values which are not spatially autocorrelated.

```{figure} https://climatereanalyzer.org/wx/todays-weather/maps/gfs_world-wt_t2_d1.png
:name: myFigure
:width: 300
:alt: Random image of the beach or ocean!
:align: center

An example image of 2m temperature. [Source](https://climatereanalyzer.org/wx/todays-weather/maps/gfs_world-wt_t2_d1.png).
```





---

**Examples**

Some geographical physical examples include elevation. 
We can also have some derived variables like temperature and precipitation.
We can even include some other variables like property value and crime rate.


---
## Sampling Classifcation

The first question we need to ask is the sampling structure of the points we have available.


### **Systemic Sampling**

This is the easiest and most predictable structure.
We have samples that are uniformly fixed at given $(\mathbf{x},t)$-coordinates.
This results in parallel lines across a given domain.

The advantage is that this is the easiest to understand and assess the strengths and limitations of the data, e.g., the Nyquist sampling theorem.

The disadvantage is that all of the data receives the same attention which may not be applicable.
Real like activitity does not necessarily stay "within the lines".
This can result in inherent biases within the data.

### Random Sampling

This is the least predictable sampling pattern as there is a underlying sampling structure.

The advantage is that it is unlikely to match any specific pattern of data.


The disadvantage is that it does not match any pattern which may be data-specific.
In other words, there may be a need to sample more in specific areas and less in other areas due to hetero-/homogeneity.

### Cluster Sampling

This creates samples are centers.
These centers are systematically or randomly placed.
The samples within each cluster can also be systematically or randomly placed.

The **advantage** is that this can reduce the travel time to all points within the domain. 
This is mainly an algorithmic or storage issue whereby there is some pre-organization done.

The **disadvantage** is that the disadvantages from the systemic or random sampling is still present for cluster placement.


### Adaptive Sampling

This method does higher sampling density where the areas of high variation/entropy are captured.

The **advantage** is that the sampling efficiency can be optimized.
There are also some logistics that can be planned which can be fruitful by reducing costs while improving the interpolation results.
Overall, there is a better representation, i.e., homogeneous data has fewer samples and heterogeneous data has more samples.


The **disadvantage** is that it may be necessary to do some preliminary sampling to discover patterns.
This results in significant prep-time to find the best patterns that are application specific.
It can also be quite subjective and data-dependent which does not offer a generalizable approach.





---
## Method Classification

### Global vs Local

**Global Interpolation**. 
This method uses every observation available to estimate an unknown value.
For example, we use a single mathematical function that takes in all coordinate and function values to predict a single unknown value.
This tends to produce smooth surfaces.

**Local Interpolation**.
This method uses a sample of observations to estimate an unknown value.
For example, we can use a single mathematical function that is repeatedly applied on the subsets of all observations.
Afterwards, one can link regional surfaces into a composite surface.
This tends to produce locally varying results within windows.


<!-- Example Plot with xarray:
* Square with all points
* Partition using a circle
* Partition using a subset -->


### Exact vs Inexact

**Exact Interpolation**.
This method will interpolate each of the observations exactly.

**Inexact Interpolation**.
This method will interpolate each of the observations approximately.


### Deterministic vs Stochastic

**Deterministic Interpolation**
This method will provide no predictive uncertainty.

**Stochastic Interpolation**.
This method will provide predictive uncertainty.


---
## Method Whirlwind Tour


**Thiessen**.
These methods are locally, exact, deterministic methods.


**Density Estimation**.
These methods are locally, inexact, deterministic methods.


**Inverse Distance Weighting**.
This is a locally, exact, deterministic method.


**Splines**.
These methods are locally, exact, deterministic methods.


**Kriging / OI / GPs**. 
These methods are stochastic which attempt to estimate

---
## Estimation Problems

$$
\begin{aligned}
\text{Spatial Domain}: && && 
\mathbf{x}&\in\Omega_y\in\mathbb{R}^{D_s}\\
\text{Temporal Domain}: && && 
t&\in[t_0, t_1]\in\mathbb{R}^{+}\\
\text{Function Range}: && && 
\boldsymbol{y}&\in\mathbb{R}^{D_y}: 
\boldsymbol{y}_a\leq \boldsymbol{y}\leq \boldsymbol{y}_b
\end{aligned}
$$

```{list-table} Table with idealized configuration
:header-rows: 1
:name: tb:qg_idealized

* - Estimation Problem
  - Spatial Domain
  - Temporal Domain
  - Value Range
* - Interpolation
  - Inside 
  - Inside
  - Inside
* - Extrapolation
  - Outside 
  - Outside
  - Inside
* - Forecasting
  - Inside/Outside 
  - Outside
  - Inside/Outside
```


---
### Interpolation

We can classify interpolation as predicting something inside the convex hull of your spatial domain, inside the range of your temporal domain, and inside the range of our data.

$$
\begin{aligned}
\text{Spatial Domain}: && && 
\mathbf{x}&\in\Omega_y\\
\text{Temporal Domain}: && && 
t&\in[t_0, t_1]\\
\text{Function Range}: && && 
\boldsymbol{y}&\in\mathbb{R}^{D_y}: 
\boldsymbol{y}_a\leq \boldsymbol{y}\leq \boldsymbol{y}_b
\end{aligned}
$$

### Extrapolation

We can classify interpolation as predicting a value outside the convex hull of your spatial domain, inside the range domain and the range of our data.

$$
\begin{aligned}
\text{Spatial Domain}: && && 
\mathbf{x}&\notin\Omega_y\\
\text{Temporal Domain}: && && 
t&\in[t_0, t_1]\\
\text{Function Range}: && && 
\boldsymbol{y}&\notin\mathbb{R}^{D_y}: 
\boldsymbol{y}_a\leq \boldsymbol{y}\leq \boldsymbol{y}_b
\end{aligned}
$$


### Forecasting

$$
\begin{aligned}
\text{Spatial Domain}: && && 
\mathbf{x}&\notin\Omega_y\\
\text{Temporal Domain}: && && 
t&\notin[t_0, t_1]\\
\text{Function Range}: && && 
\boldsymbol{y}&\notin\mathbb{R}^{D_y}: 
\boldsymbol{y}_a\leq \boldsymbol{y}\leq \boldsymbol{y}_b
\end{aligned}
$$




---
## Mathematical Formulation


**Spatiotemporal Interpolation**



$$
\boldsymbol{y}(\mathbf{x}_{n_s},t_{n_t}) = 
\sum_{{n_s}=1}^{N_s} \sum_{{n_t}=1}^{N_t}
\boldsymbol{w}(\mathbf{x}_{n_s}, t_{n_t})
\cdot 
\boldsymbol{y}(\mathbf{x}_{n_s},t_{n_t})
$$

The weight matrix