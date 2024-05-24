---
title: Exploratory Data Analysis - Spain
subject: Misc. Notes
short_title: EDA - Spain
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

For this first experiment, we are looking at the Spain continent.

***
### Block Maxima

::::{tab-set}

:::{tab-item} Mean
:::{figure}
:label: spain-t2m-bm-mean
:align: center

![Spain Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1OBzt4pIwzYjJfiYE17pYX-DBkFY3YZyf)
A spatial map showing the mean 2m max temperature for each station in  mainland Spain.
:::

:::{tab-item} Standard Deviation
:::{figure}
:label: spain-t2m-bm-stddev
:align: center

![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1TAnay9u4VXJFVifegj-NTzvOgWsKKf39)
A spatial map showing the standard deviation 2m max temperature for each station in  mainland Spain.
:::

:::{tab-item} Kurtosis
:::{figure}
:label: spain-t2m-bm-kurtosis
:align: center

![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1tTNf2SI1tOX1QL_OIyyyvhCDsRU9hHTR)
A spatial map showing the kurtosis 2m max temperature for each station in mainland Spain.
:::

:::{tab-item} Skew
:::{figure}
:label: spain-t2m-bm-skew
:align: center

![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=16zOP6ZvWS1o49mH-pn-0QUzokibdDyXv)
A spatial map showing the kurtosis 2m max temperature for each station in mainland Spain.
:::

::::

***
### Peak-Over-Threshold

In this case, we are using the POT method.
We used the 95% quantile to select the threshold.
We decluster the data by 3 days, i.e., we select the maximum event within a moving 3 day blocks (no overlaps).


::::{tab-set}

:::{tab-item} Threshold
:::{figure}
:label: spain-t2m-pot-mean
:align: center

![Spain Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1GqvZKpb8VA7S5_D6O6vvcRQrfn4DPq1z)
A spatial map showing the 95% threshold for the 2m max temperature for each station in  mainland Spain.
:::

:::{tab-item} Mean
:::{figure}
:label: spain-t2m-pot-mean
:align: center

![Spain Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1ch4nVRIcqbXLnDMSl0ApdWSIEmAN0Xg4)
A spatial map showing the mean 2m max temperature for each station in  mainland Spain.
:::


:::{tab-item} Standard Deviation
:::{figure}
:label: spain-t2m-pot-stddev
:align: center

![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1C5eYJy5f9a8Kd5MKNB4UEMD7PjpeFTpP)
A spatial map showing the standard deviation 2m max temperature for each station in  mainland Spain.
:::

:::{tab-item} Kurtosis
:::{figure}
:label: spain-t2m-pot-kurtosis
:align: center

![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=17TqQx8V-H7RCnvI4z_iGP_IjHh1nQpeU)
A spatial map showing the kurtosis 2m max temperature for each station in mainland Spain.
:::


:::{tab-item} Skew
:::{figure}
:label: spain-t2m-pot-skew
:align: center

![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1N-C1iUFcEio9f-53U_NKD0L_p020GcgO)
A spatial map showing the kurtosis 2m max temperature for each station in mainland Spain.
:::

::::

***
### Point Process

In this case, we are using the PP method.
We used the 95% quantile to select the threshold.
We decluster the data by 3 days, i.e., we select the maximum event within a moving 3 day blocks (no overlaps).


::::{tab-set}


:::{tab-item} Mean
:::{figure}
:label: spain-t2m-pot-mean
:align: center

![Spain Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1G8JZcM_eiEgnqO8K8H2QVjwad0ysqYYA)
A spatial map showing the mean 2m max temperature for each station in  mainland Spain.
:::


:::{tab-item} Standard Deviation
:::{figure}
:label: spain-t2m-pot-stddev
:align: center

![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=10RZY9na7V5qjJtSbC98EsAK16d0jM8sO)
A spatial map showing the standard deviation 2m max temperature for each station in  mainland Spain.
:::

:::{tab-item} Kurtosis
:::{figure}
:label: spain-t2m-pot-kurtosis
:align: center

![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1KxPl8omRcJdRLNNwh6Pm4v_qq4-CTmj4)
A spatial map showing the kurtosis 2m max temperature for each station in mainland Spain.
:::


:::{tab-item} Skew
:::{figure}
:label: spain-t2m-pot-skew
:align: center

![Madrid Daily Maximum Temperature Time Series](https://drive.google.com/uc?id=1vXQPbUdW2lEkpv_deTpx87uOo8BK5SzZ)
A spatial map showing the kurtosis 2m max temperature for each station in mainland Spain.
:::

::::