---
title: Climatology in EO
subject: Anomalies with Spatiotemporal Data
short_title: Climatology
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


**Definition**.
The climatology of a variable is a variables condition averaged over a period of time.

**Climatological Averages** - These are monthly mean values of a climate variable over a specific period of time.
This period will change depending upon the availability of the data.
The typical range can span 2-20 years.

**Climatological Normals**. 
These are monthly averages computed for a prolonged period of *at least* 30 consecutive years.
In the community, the default climatological standard normal is the average of the period from 1981-01-01 to 2010-12-31.


## Formulation

$$
\begin{aligned}
\text{Climatology Equation}: && && \bar{y}_c(t) &= \frac{1}{N_s}\sum_{n=1}^{Ns}\boldsymbol{y}(\mathbf{x}_n,t) \\
\text{Climatology Function}: && && \bar{y}_c&: \Omega_\text{Globe}\times\mathcal{T}_\text{Reference} \rightarrow \mathbb{R}^{D_y} \\
\text{Spatial Domain}: && && \mathbf{x}&\in\Omega_\text{Globe}\subseteq\mathbb{R}^{D_s}\\
\text{Temporal Domain}: && && t&\in\mathcal{T}_\text{Reference}\subseteq\mathbb{R}^+
\end{aligned}
$$

:::{seealso} Tutorials
:class: dropdown

[**ClimateMatch**](https://comptools.climatematch.io/tutorials/W1D1_ClimateSystemOverview/student/W1D1_Tutorial5.html).
An simple tutorial showcasing how the `groupby` function works wrt monthly/seasonal means.

[**Xarray**](https://docs.xarray.dev/en/stable/examples/monthly-means.html).
A tutorial that showcases how to calculate seasonal averages from time series of monthly means.

:::


## Pseudo-Code

Get the spatio temporal dataset

```python
# get a spatiotemporal dataset, e.g. ["time", "lat", "lon"]
ds: xr.Dataset["Nt Nx Ny"] = ...
```

Now, we need to choose the parameters for calculating the climatology.
Remember, the climatology is basically the weighted spatiotemporal mean at some frequency.

* **Region**: We need to define the region where we want to grab the signal.
* **Period**: We need to define the period where we want to grab the signal.
* **Frequency**: We need to define the frequency of when we want the signal.
* **Percentiles**: The percentiles



```python
# choose frequency of climatology 
freq: str = "monthly" # "daily", "yearly", "seasonal"
# choose the region where we 
region: str = "globe" # "spain", "europe", "globe" 
# choose the reference period
reference = ["1981","2010"]
# percentiles
percentiles: List[float] = [5., 95.]
# other function 'cooking' parameters
params: Dict = dict(
    region=region,
    period=period,
    freq=freq,
    percentiles=percentiles,
    ...
)
# calculate climatology, i.e., weighted spatial mean per time step
ds_clim: xr.Dataset = calculate_climatology(ds, **params)
```

Now, we can calculate the anomalies which works by removing the 


## Resources

* Calculating Seasonality with selectors and masks - [Notebook](https://climate-cms.org/posts/2023-11-04-seasonal-means.html)
* Removing Climatology with mapping - [Notebook](https://earth-env-data-science.github.io/lectures/xarray/xarray-part2.html)
* Calculating ENSO with xarray - [Pythia](https://foundations.projectpythia.org/core/xarray/enso-xarray.html)
* Simple Example with Hostorical Period - [Notebook](https://tutorials.dkrz.de/use-case_ensemble-analysis_intake-xarray_cmip6.html)
* Simple Climatology - [Notebook](https://comptools.climatematch.io/tutorials/W1D1_ClimateSystemOverview/student/W1D1_Tutorial5.html)
* xcdat for climatologies - [Notebook](https://xcdat.readthedocs.io/en/latest/examples/climatology-and-departures.html)
* Extended Tutorial - [CDS Docs](https://ecmwf-projects.github.io/copernicus-training-c3s/reanalysis-climatology.html)
* Example of different means (daily, monthly, seasonly, yearly) - [geocat docs](https://geocat-comp.readthedocs.io/en/stable/examples/calendar_average.html)
* code with climatology and anomaly abstraction - [Geocat ](https://github.com/andersy005/geocat-comp/blob/eb5352209ff2ced8c1885ede7d60008dea5fc0c7/src/geocat/comp/climatology.py#L148)
