---
title: Extreme Value Modeling Evaluation
subject: AI 4 Attribution
short_title: Evaluation
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
abbreviations:
    ERA5: ECMWF Reanalysis Version 5
    CMIP6: Coupled Model Intercomparison Project Phase 6
    AMIP6: Atmospherical Model Intercomparison Project Phase 6
    PDEs: Partial Differential Equations
    RHS: Right Hand Side
    TLDR: Too Long Did Not Read
    SSP: Shared Socioeconomic Pathways
    CDS: Climate Data Store
---


***

## Empirical Fit

### P-P Plot



```{figure} https://upload.wikimedia.org/wikipedia/commons/thumb/6/6c/Probability-Probability_plot%2C_quality_characteristic_data.png/600px-Probability-Probability_plot%2C_quality_characteristic_data.png
:name: earth-sys-decomp
:width: 490px
:alt: Random image of the beach or ocean!
:align: center

Example of p-p plot from wikipedia. [[Source: Wikipedia](https://en.wikipedia.org/wiki/P–P_plot)]
```

This is also known as the *probability-probability plot*, the *percent-percent plot*, or the *p-value* plot.
It is used for assessing how closely two datasets agree and/or the residuals. See [wiki](https://en.wikipedia.org/wiki/P–P_plot) for more details.

**Note**: this plot only works when we have the theoretical cumulative distribution.


***


### Q-Q Plot

```{figure} https://upload.wikimedia.org/wikipedia/commons/thumb/0/08/Normal_normal_qq.svg/600px-Normal_normal_qq.svg.png
:name: earth-sys-decomp
:width: 490px
:alt: Random image of the beach or ocean!
:align: center

Example of Q-Q plot from wikipedia. [[Source: Wikipedia](https://en.wikipedia.org/wiki/Q–Q_plot)]
```

This is the quantile-quantile plot.
This is a graphical tool to compare two probability distributions by comparing their quantiles versus one another.
See [wiki](https://en.wikipedia.org/wiki/Q–Q_plot) for more details.

***

## Predictions

### Return Period

We can extrapolate an distribution by computing the $p$-return level (see [blog](https://www.dataanalysisclassroom.com/lesson34/)).
This represents the high quantile for which the probability that the maximym exceeds this quantile is $1/p$.
This concept is known as the **return period**.
The **return period** of a particular event is the inverse probability that the event will be exceeded in any given year.
For example, the $p$-year return level is associated with a return period of $p$ years.
The $1/p$ return level is the $1-p$ quantile of an arbitrary quantile function for a distribution.([Mahmoudian & Mahammadzadeh, 2014](https://doi.org/10.1007/s10687-014-0180-2)).



To compute the return level of $y_p$ s.t. the distribution, $\text{Quantile}(p)=1-p$.
We can solve for $p$ which results in the following formula.
$$
\begin{aligned}
\text{Distribution}(y_p) &= 1 - p\\
y_p &= \text{Distribution}^{-1}(1-p)=\text{Quantile}(1-p)
\end{aligned}
$$




```{figure} https://www.metoffice.gov.uk/binaries/content/gallery/metofficegovuk/images/industry/diagrameva_article.png
:name: earth-sys-decomp
:width: 490px
:alt: Random image of the beach or ocean!
:align: center

Example of return period for temperature. [[Source: MetOffice](https://www.metoffice.gov.uk/services/research-consulting/weather-climate-consultancy/extreme-value-analysis)]
```

This is also known as the *recurrence interval* or *repeat interval* which is an average time or an estimated average time between events.
In the case of extreme events, these can include floods, heatwaves, or droughts.
See [wiki](https://en.wikipedia.org/wiki/Return_period) for more details.


:::{note} **Interpretations**
:class: dropdown

**Waiting Time** - The average waiting time until next occurrence of the event in $t$ years.

**Number of Events** - The average number of events occurring within a $T$-year period.
:::



:::{note} Example: GEVD
:class: dropdown
The return period is a nifty tool for making predictions of along the tails of the distribution.
We simply need the [quantile function](https://en.wikipedia.org/wiki/Quantile_function) for the arbitrary distribution.
The quantile function maps some input, $u$, to a threshold value $y$ so that the probability of $y$ being less than or equal than $y$ is $p$.
$$
\text{Q}:[0,1] \rightarrow \mathbb{R}
$$
We can an example for the **GEVD**.
For the GEVD, we have the quantile function defined as
$$
\text{Q}_{GEVD}(p;\mu,\sigma,\xi) = 
\begin{cases}
\mu - \frac{\sigma}{\xi}
\left[ 1 - \left( - \log p\right)^{-\xi} \right], && \xi \neq 0 \\
\mu - \sigma\log\left( - \log p\right), && \xi = 0
\end{cases}
$$
One can easily find this function (along with many others) in a [wiki](https://en.wikipedia.org/wiki/Generalized_extreme_value_distribution) or any similar resource.
Now, we simply plug in the return level, i.e., $1-p$, into the quantile function
$$
\text{Q}_{GEVD}(1-p;\mu,\sigma,\xi) 
\begin{cases}
\mu - \frac{\sigma}{\xi}
\left\{ 1 - \left[ - \log(1-p)\right]^{-\xi} \right\}, && \xi \neq 0 \\
\mu - \sigma\log\left\{ - \log(1 - p)\right\}, && \xi = 0
\end{cases}
$$

:::

:::{note} Example: GPD
:class: dropdown
The return period is a nifty tool for making predictions of along the tails of the distribution.
We simply need the [quantile function](https://en.wikipedia.org/wiki/Quantile_function) for the arbitrary distribution.
The quantile function maps some input, $u$, to a threshold value $y$ so that the probability of $y$ being less than or equal than $y$ is $p$.
$$
\text{Q}:[0,1] \rightarrow \mathbb{R}
$$
We can an example for the **GEVD**.
For the GPD, we have to be careful because we don't have an exact expression.
$$
\text{Q}_{GPD}(p;\mu,\sigma,\xi) = 
\begin{cases}
\mu - \frac{\sigma}{\xi}
\left[ 1 - \left( - \log p\right)^{-\xi} \right], && \xi \neq 0 \\
u + \sigma_u \log \left(p\xi_u \right) && \xi = 0
\end{cases}
$$
where $\xi_u$ is the probability of exceeding the threshold. 
We can use this to estimate the return level, $y_p$.
$$
\hat{y}_p = u + \frac{\hat{\sigma}_u}{\hat{\xi}}
\left[ \left(\frac{np}{N_u}\right)^{-\hat{\xi}} - 1 \right]
$$

:::

***


### Mean Excess Function

$$
\mathbb{E}(Y - u|Y>u = \frac{\sigma_u - u\xi}{1 - \xi})
$$

where the scale parameter, $\sigma_u$, varies linearly in the threshold $u$ and the shape parameter $\xi$ is fixed wrt the threshold $u$.

***

### Expected Shortfall

Ultimately, the goal of EVT is to compute the value at risk.
We can derive the expected shortfall (conditional rv).
$$
y_p = \mu - \frac{\sigma}{\xi}\left[ 1 - \left(\frac{N}{N_\mu} (1 - p) \right)^{-\xi} \right]
$$

where:

* $y_p$ - the random variable
* $\mu$ - the threshold (in percentage terms)
* $N$ - number of observations
* $N_\mu$ - # of observations that exceed the threshold

We can define the expected shortfall (ES) as:
$$
\text{ES} = \frac{y_p}{1 -\xi} + \frac{\sigma - \xi\mu}{1 - \xi}
$$