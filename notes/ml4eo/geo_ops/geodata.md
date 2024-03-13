---
title: Geo0Operations
subject: Machine Learning for Earth Observations
short_title: GeoData
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



**DATASETS**


In general, there are very easy datasets to build which are problem dependent.

**Easy**
Spatiotemporally Independent
- Variable Transformations
Spatially Dependent, Temporally Independent 
* Segmentation, Classification, Regression
* Rasterio, Torchgeo, Raster-Vision
* Spatiotemporal Data - Hard
	* xarray, zarr, rioxarray
	* Weather Prediction
	* XRPatcher

***
**Core Operations**

- Input
- Split
- Apply
- Combine

***
**Concepts**

- DataCube
- Time Series
- Scene, Image
	- Scene —> ROI
	- Image, Tile, Patch
- Area of Interest (AOI), Region
- Resolution, Frequency
- Bounding Box, Period
- Patch, Chip, Cube

***
**Dataset Objects**

- Dataset
- Sampler
- DataLoader
- DataModule

***
## EO Data Problems

**Image File Size**. Often the image file sizes are way too big to fit into memory, let alone do transformations. To combat this, we often do patching whereby we take subsets of the image. However, we need to be careful because its also inefficient to keep loading the entire image into memory just to take a subset. Furthermore, this becomes even more expensive when we consider multiple large images.

**Multiple Files for 1 Image**. We often get a single scene that is split across files. These splits could be partitions of the time, space, or spectral band. It is satellite dependent, e.g., GOES is a geostationary satellite which splits it across bands and MODIS is a … satellite that splits it across space (tiles). So you can imagine when we load the data, we need to combine the files correctly. If you can, one should try to harmonize all datasets to a single format but sometimes this can be infeasible due to computational resources.

**Heterogeneous, Multi-Modal Data**. We often have multi-modal data which we wish to merge. For example, we may have two satellites that share some information in space or spectral channels. We need a way to be able to combine these datasets either as a union or intersection. The most frustrating thing is the fact that have heterogeneity across different datasets. So for example regarding the file split, outlined an example above with GOES and MODIS. In general, it’s always good to have some minimum amount of data homogeneity, i.e., all images are split in the same way and contain the same dimensions. However, there are some cases where this is impossible for example cases where we have limitations of computational resources and memory/storage.

**Heterogeneous Data Types**. Another problem is the data types. For example, rasters and polygons of distinct types. In general, ML works best with discrete, regular data structures. But recently there are a lot of new work with GNNs which are useful for irregular domains.

***
### EO Meta-Data

> The meta-data is the saving grace for EO data. This is because we have access to information that allows us to connect all EO datasets together.

**CRS**. We have a common coordinate reference system which should be present in every georeferenced Dataset. This gives every value of the field a context or reference. 

**Coordinate Transformations**. We often have datasets with different CRS. However, we can easily project our data into any other CRS, ie a coordinate transformation: Fortunately for us, they involve very simple transformations so they are not expensive operations to do before or on-the-fly.

**Resolution**. While each georeferenced dataset has an underlying CRS, they often have different resolutions. The CRS allows us to resample our data according to a different resolution. We simply need to project our data to a common CRS and then apply an interpolation algorithm to the common resolution. 

**Patching**. The CRS system also allows us to patch according to coordinates, not the absolute locations of the pixels within the image. It may not be necessary to use the CRS for training a simple ML model. However they become extremely useful when we deal with multi-modal inputs where we can have unions and intersections between datasets. In addition, inference requires us to combine the patches back together in a meaningful way so the CRS becomes very useful in the combination process.


***
### Examples

The examples are split according to which data structure we choose to save our data.

 **GeoTIFF**

- TorchGeo
	- Scene - RasterDataset, [RandomSampler](https://torchgeo.readthedocs.io/en/stable/api/samplers.html#torchgeo.samplers.RandomGeoSampler), Training
	- Tiles - RasterDataset, [RandomBatchSampler](https://torchgeo.readthedocs.io/en/stable/api/samplers.html#torchgeo.samplers.RandomBatchGeoSampler), Training
	- Pre-Patched - RasterDataset, [PreChippedSampler](https://torchgeo.readthedocs.io/en/stable/api/samplers.html#torchgeo.samplers.RandomGeoSampler), Training
	- RasterDataset, GridSampler, Inference
- RasterVision
	- Simple
	- Separate Bands in Different Files
	- Separate Tiles

***
**NetCDF/ZARR**

- XRPatcher - TorchData
- Rastervision - XArraySource

***
**Pre-Patched Files** (Numpy)

- mlx-data - functional
- TorchGeo - NonGeoDataset
- RasterVision - ImageSource

***
**Polygons**

- TorchGeo
- RasterVision


***
**CSV Files**

- Custom Dataloader
- Merlin DataLoader

***
#### **MLX-Data**

> This is a neat little library that is purely functional and cross-platform. I think its a great way to create dataloaders while doing a lot of preprocessing stuff on the fly.

- Domain Files + Domain-Processing Chain + Normalize + Patching
- Domain-Processed Files + Normalize + Patching
- Pre-Patched Files + Normalize

**Use Cases**
- **Helio-Physics** - FITS Files
- **Remote Sensing** - GeoTIFF
- **Geoscience** - NetCDF




***
## EO Datasets

When dealing with an ML-Compatible dataset, we have two choices: a geodataset and a nongeodataset. Essentially, we have to decide whether we want to build a custom dataset which accounts for georeference meta-data or do we want a generic dataset which does not necessarily account for the georeference meta-data.

### GeoDataset

This is the new meta. We are essentially blurring the lines between geoprocessing and ml-processing. We can now do some of the things on the fly like CRS projections, light resampling, and patching. 

**Advantage**: We keep all meta-data which could be useful like the static variables, e.g. coordinates, masks, CRS. It also makes experimenting with different aspects more flexible, eg patch size, different regions/aoi. It also makes the engineering much eaiser for users. We only have to worry about some like data homogenization and then the dataset will take care of the rest under the hood.

**Disadvantage**: We have to create our own custom datasets which take into account the meta-data. This requires a lot morr SWE than many people are qualified to do. However, this is changing as we see many new libraries coming up to try and handle this problem, e.g., TorchGeo, Raster-Vision, XRPatcher, 

*Personal Take I*: I think this is akin to *operator learning* where we treat all data as a function instead of just discrete values.

*Personal Take II*: I think dealing with rasters is almost a solved problem. However, dealing with spatiotemporal datacubes is not… The main reason is that we don’t have a nice API for slicing subregions of the dataset without opening the full dataset or collisions.

***
### NonGeoDataset

This was the way for many years. We essentially do all of our processing with georeferenced data and save it to a bucket. So CRS projections, resampling, normalization, pre-patching, and saving. Once its in this form, we no longer have to think about the geostuff and now we can focus solely in the machine learning.

The advantage is that these are conceptually much easier to code and modify because the majority of the ML methods use this kind of data. 

The disadvantage is that we lose a lot of information. We also have to make hard decisions about the geo-preprocessing which are difficult to change in the future.


***

Pieces

- Parameters
- Operators
- Buckets


***
### **Params**

- Region
- Spatial Resolution
- Temporal Period
- Temporal Frequency

***
###  **Operators**

- Download Data from Server
- Preprocessing Data Structure
- Subset - Region, Period
- Data Harmonization - Time, Space, Spectral Channels
- CRS - Reprojection
- Variable Transformations - Radiance/Reflectance, Velocity, FFT
- Resampling, Regridding,
- Interpolation - Gap/NAN-Filling
- Normalization
- Patching - Space, Time, Spectral Channel
- ML Data Structure

### Buckets

- Raw Data
- Analysis-Ready
- ML-Ready
- Results



***
## **Normalization-Patching-ML-Ready**

This part is the most flexible part of the pipeline. It is basically a balance between storage, RAM, and processing power.

###  **Option I**: *Pre-Chipping*

> In this case, we will pre-chip the images to have consistent chipped datasets. Some advantages to this method is that we are free to choose the data structure of choice to save. This will allow flexibility for when people create their custom datasets provided they are simple data structures like `.tif`, `.png` or `numpy` arrays. In addition, the user will not have to worry about making patches.


Part I - Get ML-Ready Data
- Load Analysis-Ready Data
- Initialize Normalizer
- Pre-Patching
- Save ML-Ready Data
- Save Normalizer

```python
# select analysis-ready files
analysis_ready_files: List[str] = …
# load data
ds: Dataset = load_dataset(analysis_ready_files)
# calculate transformation parameters
transform_params: Dict = calculate_transform_params(ds, **params)
save_normalizer(…, transform_params)
# define patch parameters
patch_size: Dict = dict(lon=256, lat=256)
stride: Dict = dict(lon=64, lat=64)
# define patcher
patcher: Patcher = Patcher(patch_size, stride)
# save patches to ML Ready Bucket
file_path: Path = Path(…)
save_name_id: str = …
num_workers: int = …
save_patches(patcher, num_workers, file_path, save_name_id)
```

Part II - Create ML Dataset
- Load ML-Ready Data
- Load Normalizer
- Apply Normalizer
- Create Dataset

```Python
# get ml ready data files
ml_ready_data_files: List[str] = […]
# load transform params, init transform
transform_params = load_tranform_params(…)
transformer = init_transformer(transform_params)
# create dataset
ds = Dataset(files, transformer)
# demo item 
num_samples: int = …
sample: Tensor[“B C H W”] = ds.sample(num_samples)
```

### **Option II:** Patching Data Module

> In this case, we will create a dataset that does some preprocessing on-the-fly. We just need to save the scenes to a chosen data structure and then we need a custom dataset which allows us to subset AOI and take p


- Load Analysis-Ready Data
- Initialize Normalizer
- Apply Normalizer
- Patch On The Fly


```Python
# get analysis ready data files
analysis_ready_files: List[str] = […]
# load transform params, init transform
transform_params: Dict = …
Transformer = init_transformer(transform_params)
# initialize patch parameters
patch_size = dict(lon=256, lat=256)
stride = dict(lon=64, lat=64)
# initialize dataset
ds: Dataset = Dataset(
	analysis_ready_files, 
	transformer, 
	patch_size, 
	stride, 
	**kwargs
)
# demo item
sample: Tensor[“1 C 256 256”] = ds.sample(1)
```


***
### Helio-Physics Examples

#### **Minimal Data Harmonization**

```Python
# download 
raw_file = download(**params)
# filter files for anomalies
good_raw_files = list(filter(criteria, raw_file))
# open
data: Map = open(good_raw_files)
# validate data
data: Map = validate(data, **params)
# save to analysis ready bucket
analysis_file = save(data, **params)
```


#### **Full ML Inference Loop**

```python
# open file
data: Map = open(analysis_ready_file)
# do helio-preprocessing - limb darkening, calibration
data: Map = helio_preprocess(data, **params)
# change data structure - Map —> NDArray
data: NDArray = change_ds(data, **params)
# apply the split operation - patching
data: NDArray = patcher(data, **params)
# machine learning pre-processing - normalize, patching
data: MLTensor = ml_preprocess(data, **params)
# load machine learning model
model: Model = load_model(**params)
# apply machine learning model
out: MLTensor = model(data)
# machine learning pre-processing
data: NDArray = ml_preprocess(data, inverse=True, **params)
# apply the combine operarptiom
data: NDArray = patcher(data, inverse=True, **params)
# change data structure
data: Map = change_ds(data, inverse=True, **params)
# apply helio post-processing
out: Map = helio_preprocess(data, inverse=True, **params)
```

***
#### ML-Ready PipeLine

**Creating ML-Ready Data**
```Python
# open file
data: Map = open(analysis)
# do helio-preprocessing - limb darkening, calibration
data: Map = helio_preprocess(data, **params)
# change data structure - Map —> NDArray
data: NDArray = change_ds(data, **params)
# initialize normalizer
normalizer_params = initialize_normalizer(data, **params)
# save normalizer 
normalizer_file = save_normalizer(normalizer_params, **params)
# apply the split operation - patching (OPTIONAL)
data: NDArray = patcher(data, **params)
# save to analysis ready bucket
ml_ready_file = save(data, **params)
```

**ML Training Loop**

```Python
# create dataset
ds: MLDataset = MLDataset(ml_ready_file, ml_preprocess, **params)
# create a sampler
sampler: Sampler = Sampler(ds, **params)
# create a DataLoader
dl: DataLoader = DataLoader(ds, sampler, **params)
# initialize model
model: Model = Model(**params)
# initialize trainer
model.compile(opt, loss, callbacks, **params)
# fit model
model.fit(dl)
# save model
model_hub = model.save(**params)
```

***

```Python
@dataclass
class HelioProcessing:
    limb_darkening: float = 0.1
    
    def __call__(self, data: Map) -> Map:
        # do something
        data: Map = fn(data, **self)
        return data
    
    def post_processing(self, data) -> Map:
        # do something
        return data
```

```python
# make an inference step
def inference_step(data):
    data = normalize(data)
    data = iti_model(data)
    data = unnormalize(data)
    return data
```



***
**Inference Pipeline**

```python
# make an inference step
def inference_step(data):
    data: ND = normalize(data)
    data = iti_model(data)
    data = unnormalize(data)
    return data
```

Get some samples

```Python
samples: List[str] = […]
```

Loop through the chain



```Python
for isample in dset:
    # apply helio-pipeline
    data = helio_pipeline(isample, **params)
    # create patches
    patches = patcher(data, **params)
    # apply inference step on patches
    patches = list(map(inference_step, patches))
    # unpatch patches
    data = patcher(patches, reverse=True, **params)
    # un-process helio-pipeline
    data = helio_postprocess(data, **params)
```

**Create a Dataset Loader
```python
dset = (
	dset.to_buffer(open(files))
	.key_transform(“key”, helio_pipeline)
	.key_transform(“key”, sampler)
	.batch(1)
)
```

## Examples


**Level I**
Domain Specific DS + Pre-Patching + NDArray

- Satellite Data X-Y - h5/tif/nc, rasterio/rioxarray/geotensor - sentinel, landsat 
- Satellite Data Lat-Lon - h5/nc, xarray, npy  - modis, goes
- Ocean Data Lat-Lon - nc, xarray, npy - glorys, hycom
- Heliophysics Data - fits, sunpy, npy/png - sdo

***
**Level II**
Domain Specific + Pre-Patching + Domain Specific DS

- xrpatcher - netcdf
- torchgeo - tif
- 