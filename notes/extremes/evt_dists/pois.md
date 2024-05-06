---
title: Poisson Process
subject: Machine Learning for Earth Observations
short_title: Poisson
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



### Probability Density Function



***
### Log Likelihood


We can write down the log likelihood
$$
\log p(y_n|\theta) = -N\lambda + \log\lambda\sum_{n=1}^Ny_n - \sum_{n=1}^N\log (y_n!)
$$

***
### Extremes

* Likelihood of exactly $K$ floods larger than $y_0$ in a $T$-time record
* Likelihood of exactly $K$ floods have been observed in $y_n$.



***
### Ocurrence

$$
p() = e^{-rt}
$$


---

**Magnitude** - Sum of Daily Precipitation Values

**Intensity** - Maximum Daily Intensity

**Duration** - Number of Days in Event