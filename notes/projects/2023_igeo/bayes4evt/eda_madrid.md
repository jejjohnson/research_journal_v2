---
title: Preliminary Results
subject: Misc. Notes
short_title: Experiment 1 - EDA
authors:
  - name: J. Emmanuel Johnson
    affiliations:
      - CSIC
      - UCM
      - IGEO
    orcid: 0000-0002-6739-0053
    email: juanjohn@ucm.es
license: CC-BY-4.0
keywords: data
---



## Data 

For this first experiment, we are looking at Madrid

::::{tab-set}

:::{tab-item} Time Series
:sync: tab1
:::{figure}
:label: madrid-t2m-ts
:align: center

![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1vYl0h1aB49dI3_QKJzHBOfOsiHdPz9Ga)
A time series of daily maximum 2m temperature in Madrid.
:::

:::{tab-item} Histogram
:sync: tab2
:::{figure}
:label: madrid-t2m-hist
:align: center

![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1Pq_obSbuCc15mWxXbaI7I8BhbSwMxJ2U)
A histogram of daily maximum 2m temperature in Madrid.
:::
::::


In this figure, we are showing different representations for the time series of Madrid.
In [](madrid-t2m-ts), there is a daily time series for the 2m max temperature.
In [](madrid-t2m-hist), there is a histogram for all of the values.
Of course, the distribution does not look like any of the traditional distributions from the GEVD ([](fig:gevd-disttypes)).
Unless we decide to condition on the seasonal cycle and/or other covariates, then we need to use some extreme value parser, e.g., block maximum or peak over threshold.


***
## Block Maxima

In these examples, we are applying the Block Maxima (BM) method on a yearly basis.
So, our block size is of one year which leaves us 62 years in total for our time series.
While this is not a lot of data, we see in [](fig:madrid-t2m-bm-hist) that the distribution does match one of the classical GEVD distributions. 
In particular, the Fréchet distribution where the shape parameter, $\kappa$, is less than 0 ([](fig:gevd-disttypes)).

::::{tab-set}

:::{tab-item} Time Series
:sync: tab1
:::{figure}
:label: fig:madrid-t2m-bm-ts
:align: center
![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1xwwk5C_3lW8kl9yBqw91RvSfzcowZveD)
A scatter plot with boundaries for the maximum temperatures obtained using the yearly Block maxima method.
:::

:::{tab-item} Scatter Plot
:sync: tab2
:::{figure}
:label: fig:madrid-t2m-bm-scatter
:align: center

![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1LIh5BxM9CsyWLqy_8iNikKXY9EtV4bSA)
A scatter plot for the yearly maximum values obtained from the daily 2m max temperature for Madrid.
:::

:::{tab-item} Histogram
:sync: tab3
:::{figure}
:label: fig:madrid-t2m-bm-hist
:align: center

![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1GqRibR58Z1ESy3_BiakGTQCQ5ezLkcXE)
A histogram of all values obtained using the block maxima method.
:::
::::

In this figure, we have different representations for the block maximum method.
We already see a trend line and perhaps a hint of cyclic behaviour.
In our first experiments, we see will assume a unconditional distribution however we can see that this assumption is incorrect as we can clearly see from [](fig:madrid-t2m-bm-scatter).
