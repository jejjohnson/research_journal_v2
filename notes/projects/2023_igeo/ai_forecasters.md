# AI-Forecast

> In general, we have a few candidate models that were proposed by different organisations. The architectures are:
> 1. Neural Operator
> 2. Graphical Model
> 3. Transformer



## Model Architectures

### Spherical Fourier Neural Operator (SFNO) - NVidia

[**Software**](https://neuraloperator.github.io/neuraloperator/dev/index.html) (PyTorch)

[**Paper**](https://arxiv.org/abs/2306.03838) (ARXIV)



They use a subset of the 26/73 variables used within the ERA5 Dataset.

| Variable | Description | ECMWF ID |
|:---------|:------------|:--------:|
| 10u | 10 m zonal wind | 165|
| 10v | 10 m meridional wind | 166 |
| 2T | 2 m temperature | 167
| sp | surface pression | 135 |
| msl | mean sea level pressure | 151 |
| tcwv | total column vertically-integrated water vapour | 137 |
| 100u | 100 m zonal wind | 228,248 |
| 100v | 100 m meridional wind component | 228,247 |
| z--- | geoponential (at pressure level ---) | 129 |
| T--- | temperature (at pressure level ---) | 130 |
| U--- | zonal wind (at pressure level ---) | 131 |
| V--- | meridional wind (at pressure level ---) | 132 |
| R--- | relative humidity (at pressure level ---) | 157 |

Pressure Levels: `50, 100, 150, 200, 250, 300, 400, 500, 600, 700, 850, 925, 1000` hPa


### GraphCast

[**Paper**](https://arxiv.org/abs/2212.12794) [ARXIV]

| Variable | Description | ECMWF ID |
|:---------|:------------|:--------:|
| 10u | 10 m zonal wind | 165|
| 10v | 10 m meridional wind | 166 |
| 2T | 2 m temperature | 167
| sp | surface pression | 135 |
| msl | mean sea level pressure | 151 |
| tp | total precipitation | ... |
| tcwv | total column vertically-integrated water vapour | 137 |
| 100u | 100 m zonal wind | 228,248 |
| 100v | 100 m meridional wind component | 228,247 |
| z--- | geoponential (at pressure level ---) | 129 |
| T--- | temperature (at pressure level ---) | 130 |
| U--- | zonal wind (at pressure level ---) | 131 |
| V--- | meridional wind (at pressure level ---) | 132 |
| VZ--- | Vertical wind speed | |
| R--- | specific humidity (at pressure level ---) | 157 |

Pressure Levels: `1,2,3,5,7,10,20,30,50,70,100,125,150,175,200,225,250,300,350,400,450,500,550,600,650,700,750,775,800,825,850,875,900,925,950,975,100` hPa

### Neural-LAM

[**Paper**](https://arxiv.org/abs/2309.17370) [ARXIV]

[**Code**](https://github.com/joeloskarsson/neural-lam)


### Pangu-Weather