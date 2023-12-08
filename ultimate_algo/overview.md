# Full DA Pipeline

## Interpolate Observations


### Simple Case


**DataModule Steps**

* Load Data from `xarray.Dataset`
* Convert to `pandas.DataFrame`
* Rescale Data
* Subsample Data
* Create Dataset
* Create DataLoader

**Model Steps**

* Init Model
* Train Model
* 

**Save Steps**
* Save - Scaler, Model, Params


---

```python
# load xarray
ds: xr.Dataset = ...
# run preprocessing steps
ds: xr.Dataset = hydra.instantiate(CONFIG.preprocess)
# convert to xarray
df: pd.DataFame = ds.to_dataframe()

# get coordinates & values
coords: Array["Ntrain Ds"] = ... 
outputs: Array["Ntrain Dy"] = ...

# RESCALE DATA
spatial_rescale: Pipeline = hydra.instantiate(CONFIG.spatial_rescale)
time_rescale: Pipeline = hydra.instantiate(CONFIG.time_rescale)
outputs_rescale: Pipeline = hydra.instantiate(CONFIG.outputs_rescale)

spatial_coords: Array["Ntrain Ds"] = spatial_rescale.fit_transform(coords)
temporal_coords: Array["Ntrain Ds"] = time_rescale.fit_transform(coords)
outputs: Array["Ntrain Dy"] = outputs_rescale.fit_transform(outputs)

# CREATE DATASETS
train_ds: torch.Dataset(spatial_coords, temporal_coords, outputs)
valid_ds: torch.Dataset(spatial_coords, temporal_coords, outputs)

# CREATE DATALOADERS
train_dl: torch.DataLoader(train_ds, *args, **kwargs)
valid_dl: torch.DataLoader(valid_ds, *args, **kwargs)

#
model.fit(...)

# UNRESCALE Data
coords_pred: Array["Ntest Ds"] = coords_rescale.inverse_transform(coords_pred)
values_pred: Array["Ntest Ds"] = values_rescale.inverse_transform(values_pred)
```


### SpatioTemporal Encoding


