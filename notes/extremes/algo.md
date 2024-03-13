---
title: Extremes
subject: Machine Learning for Earth Observations
short_title: Extremes
authors:
  - name: J. Emmanuel Johnson
    affiliations:
      - CSIC
      - UCM
      - IGEO
    orcid: 0000-0002-6739-0053
    email: juanjohn@ucm.es
license: CC-BY-4.0
keywords: simulations
---

## 2.1 - Extreme Value Theory

**Three Interpretations**

> There are three interpretations of extreme value theory which are complementary. In a nutshell, there are three ways of selecting extreme values from data and then defining a likelihood function.


- Max Values —> GEVD
- Threshold + Max Values —> GPD
- Threshold + Max Values + Counts + Summary Statistic —> PP

**Problems**
- Spatiotemporal Dependencies - representation
- Measurements - very little, rare/extremely rare # of observations and complex
- Modeling - difficult with little measurements, even with simulations, things are complex and heavy, lose interpretability
- Experiment - what’s counterfactual?
- Causality - event attribution and direction

## Calculating Extremes

### **Block Maxima**

We define a spatiotemporal block and we take the maximum count within a spatiotemporal block. 

**Algorithm**
1. Define spatiotemporal block
2. Select maximum/minimum values

```python
Clon_coords: Array[“”] = …
Clat_coords: Array[“”] = …
```

***
### **Peak-Over-Threshold**

We select the values that are over a predefined threshold and discard the rest. We also have the option to discretize this further by taking the maximum within a pre-defined spatiotemporal block. The POT method is a discretized version of the block maxima method, i.e., it is the infinite limit as the size of spatiotemporal block goes to zero whereby each individual point is a maximum. This will result in an irregular grid because there is no guarantee that only one maximum occurrence above a pre-defined threshold within a pre-defined spatiotemporal block. In addition, one could have irregular blocks/shapes but this makes processing much harder. One could further discretize this to count exceedences (and intensity).

***
**Algorithm**
1. Define maximum/minimum threshold values
2. Select values above/below threshold
3. Define spatiotemporal block (Optional)
4. Summary statistic of values within spatiotemporal block (Optional)


***
### **Point Processes**

This method is similar to the POT method with the spatiotemporal blocks. However, we also count the number of exceedences and take a summary statistic of the values within the block.
- [Point Process Analysis](https://geographicdata.science/book/notebooks/08_point_pattern_analysis.html) | [Point Process NBs](https://github.com/MatthewDaws/PointProcesses) | [PP w/ PyTorch](https://github.com/HongtengXu/PoPPy) | [Marked Spatiotemporal Point Process Simulator](https://github.com/meowoodie/Spatio-Temporal-Point-Process-Simulator)
- [neural spatial temporal point process](https://arxiv.org/abs/2011.04583) | [point process and models](https://arxiv.org/abs/1910.00282)
- [spatial point process w Paula](https://www.paulamoraga.com/tutorial-point-patterns/)

***
**Algorithm**
1. Define maximum/minimum threshold values
2. Select values above/below threshold
3. Define spatiotemporal block
4. Count the number of occurrences within spatiotemporal block
5. Summary statistic of values within spatiotemporal block


## Core Operations

### Resampling

> We need to choose the temporal frequency we wish to choose.

* [Example Resamplings](https://github.com/Timh37/projectESL/blob/main/projectESL/preprocessing.py#L12)

### Declustering

> We need to merge the observations.

* Method I - we take non-lapping blocks of the data to the minimum spatiotemporal resolution we accept by taking maximum values.
* Method II - we take a radius neighbors based approach on non-overlapping spatial regions at a desired temporal frequency.

**Examples**

* [Declustering Example - Heatwaves](https://github.com/nicrie/HWMId/blob/main/hwmid.py)
* 

***
> In this section, we will do a deeper dive into how one can further preprocess the data to remove extreme values


* Spatially Aggregate Data (Optional)
* Temporally Aggregate Data (Optional)
* Stitching, SuperImposing, Aggregating, Batch Sampling - [PoPPY](https://arxiv.org/pdf/1810.10122.pdf)

**Examples**
- 1D Data Recorded in a sequence of distance or time
- 2D sampling for spatial interpolation
- 3D sampling for spatial interpolation
- Spatiotemporal

**Spatial Scale**
- Changes —> Mean, Variance, Tails, Range, Distribution Shape
- Tools —> Variogram, Predict the scale
- Recale:
	- DownScale/SuperResolution/UpSample
	- Upscaling/Coarsen/DownSample —> Average Arithmetic, Power Law Average, Harmonic, Geometric
- Aggregations
- Creating location weights - https://youtu.be/k9VbyqafnPk?si=biWcgcqwuXVe8RfG 

```python
# filtering - remove high/low frequency signals
# spatiotemporal peaks - spatial,temporal dependencies
# remove climatology - temporal dependencies
# spatial aggregation - spatial dependencies
# rolling mean - spatial, temporal dependencies
```
**Cookbook**
- Spatial Statistics with Declustering Weights —> Grid Cell Size vs Declustered Mean
- Lat-Lon Spatial Averages using weights at poles

## Example PsuedoCode

First, we need some spatiotemporal data.
This data could be any spatiotemporal field, $y=y(\mathbf{s},t)$, representing the extreme values we wish to extract.

```python
y: Array["Dt Dy"] = ...
```

Now, we need to do some preprocessing steps to ensure that we get an iid dataset.
We will remove some of the excess effects.

```python
# filter high frequency signals
y: Array["Dt Dy"] = low_pass_filter(y, params)
# remove climatology
climatology["Dclim"] = calculate_climatology(y, reference_period, params)
y: Array["Dt Dy"] = remove_climatology(y, climatology, params)
# spatial aggregation
y: Array["Dt"] = spatial_aggregator(y, params)
```

Now, we need to select some extreme values.

```python
y_max: Array["Dt"] = block_maximum(y, params)
```