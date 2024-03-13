---
title: NASA Earth Access
subject: Data Access for ML4EO
short_title: Earth Access
authors:
  - name: J. Emmanuel Johnson
    affiliations:
      - CSIC
      - UCM
      - IGEO
    orcid: 0000-0002-6739-0053
    email: juanjohn@ucm.es
license: CC-BY-4.0
keywords: notation
---

This is a rather [recent edition](https://www.earthdata.nasa.gov/learn/blog/earthaccess) which gives us access to the NASA Database.
They have a number of new tutorials:
* Why EarthAccess - [Slides](https://nsidc.github.io/earthaccess-gallery/)
* Simple WorkFlows for Accessing NASA NSIDC DAAC Data in the Cloud - [YouTube Video](https://www.youtube.com/watch?v=ILYLKxte44E&pp=ygUQbmFzYSBlYXJ0aGFjY2Vzcw%3D%3D)
* NASA EarthData Cloud and Data Access - Jupyter [Notebook I](https://book.cryointhecloud.com/tutorials/NASA-Earthdata-Cloud-Access/3.earthaccess.html) | [Notebook II](https://book.cryointhecloud.com/tutorials/NASA-Earthdata-Cloud-Access/4.icepyx.html) | [Video](https://www.youtube.com/watch?v=VRG896cMtT0&pp=ygUQbmFzYSBlYXJ0aGFjY2Vzcw%3D%3D)
* Discover and Access Earth Science Data Using Earthdata Search - [YouTube Video](https://www.youtube.com/watch?v=QtfMlkd7kII)

## PseudoCode

### Open Data Links

```python

results = earthaccess.search_data(
    short_name='SEA_SURFACE_HEIGHT_ALT_GRIDS_L4_2SATS_5DAY_6THDEG_V_JPL2205',
    cloud_hosted=True,
    bounding_box=(-10, 20, 10, 50),
    temporal=("1999-02", "2019-03"),
    count=10
)


# if the data set is cloud hosted there will be S3 links available. The access parameter accepts "direct" or "external", direct access is only possible if you are in the us-west-2 region in the cloud.
data_links = [granule.data_links(access="direct") for granule in results]

# or if the data is an on-prem dataset
data_links = [granule.data_links(access="external") for granule in results]

```

### Download Locally

```python
results = earthaccess.search_data(
    short_name='SEA_SURFACE_HEIGHT_ALT_GRIDS_L4_2SATS_5DAY_6THDEG_V_JPL2205',
    cloud_hosted=True,
    bounding_box=(-10, 20, 10, 50),
    temporal=("1999-02", "2019-03"),
    count=10
)
files = earthaccess.download(results, "./local_folder")
```

### Direct S3 Access

```python
import xarray as xr

files = earthaccess.open(results)

ds = xr.open_mfdataset(files)
```
