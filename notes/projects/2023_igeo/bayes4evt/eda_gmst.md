---
title: Exploratory Data Analysis - GMST
subject: Misc. Notes
short_title: EDA - GMST
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

> Some figures for exploring the relationship between the GMST and Madrid.


## Time Series


::::{tab-set}

:::{tab-item} Time Series (All)
:::{figure}
:label: madrid-t2m-ts
:align: center

![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1LjGx4NtKnigHmFidxBJXqsfTLjo-vDdM)
A time series of daily maximum 2m temperature in Madrid.
:::

:::{tab-item} Time Series Period
:::{figure}
:label: madrid-t2m-hist
:align: center

![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1CksGAuCFpMWvWK4huwy_3yz9-ylWAj3G)
A histogram of daily maximum 2m temperature in Madrid.
:::
::::


***
## Block Maximum


::::{tab-set}

:::{tab-item} Linear Relationship
:::{figure}
:label: madrid-t2m-ts
:align: center

![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1JBLiTy_dwZFIAlLfduQY57zPRgjWA2vq)
A figure showing a linear regression fitted to the annual maximums per year.
:::

:::{tab-item} Non-Linear Relationship
:::{figure}
:label: madrid-t2m-hist
:align: center

![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1lPKt_6XRSGofxZZwH2PGik6tz2SCqTPt)
A figure showing a linear regression and polynomial regression fitted to the annual maximums per year.
:::
::::


***
## Peaks-Over-Threshold

::::{tab-set}

:::{tab-item} Linear Relationship
:::{figure}
:label: madrid-t2m-ts
:align: center

![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1QWpzDy7b2l_r5900Xp1uEGcBnGtDk-Y0)
A figure showing a linear regression fitted to all of the counts of events above the threshold.
:::

:::{tab-item} Non-Linear Mean Relationship
:::{figure}
:label: madrid-t2m-hist
:align: center

![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1Cd-jlWYAamZGKSxkPE9VMS9bAAI_elON)
A figure showing a linear regression and polynomial regression fitted to the annual mean events above the threshold.
The annual mean is the binned observations per year.
:::
::::


***
## Point Process


::::{tab-set}

:::{tab-item} Relationship
:::{figure}
:label: madrid-t2m-ts
:align: center

![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1JBLiTy_dwZFIAlLfduQY57zPRgjWA2vq)
A figure showing a linear regression and polynomial regression fitted to all of the counts of events above the threshold.

:::

:::{tab-item} Mean Relationship
:::{figure}
:label: madrid-t2m-hist
:align: center

![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1nvMGdpk25UcPxZoerKRxbzQAZWelZIt4)
A figure showing a linear regression and polynomial regression fitted to the annual mean number counts of events above the threshold.
The annual mean is the binned observations per year.
:::
::::