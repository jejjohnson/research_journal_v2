# OI Module


```bash
# choose by region
python oi.py dataset=alongtrack region=NA outputdir="./"
# choose by box
python oi.py region.lon_min=0.1
```

***

1. Sanity Checks on Inputs
1. Create Target Grid
2. Loop Through Target Grid
1. PreFilter Files with Target
2. Open Subset Files
2. Dataset Validations
2. Subset (try/except) - lat, lon, height, time
3. Dataset Unit Conversions - e.g. deg2rad, datetime seconds
1. Apply Global Coordinate Transformations - MinMax, StandardScaler
7. Predict Onto Target Grid

***
