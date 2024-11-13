---
title: Blog - Image Convolutions
subject: ML4EO
short_title: Conv - Resampling
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


In this example, we are applying 2x2 patches with a stride of 2.
The resulting image will transform this into a checkboard pattern of 00, 01, 10, 11.

```python
# initialize kernel
kernel: Array["H W Cin Cout"] = zeros((H, W, Cin, Cout))
kernel[0,0,0,0] = 1
kernel[0,0,0,1] = 1
kernel[0,0,0,2] = 1
kernel[0,0,0,3] = 1
```


### Haar Matrix

```python
# initialize kernel
kernel: Array["H W"] = ones((H, W,))
kernel[1,1] = -1
```


***
## Resources

**Haar Matrix** [Wikipedia](https://en.wikipedia.org/wiki/Haar_wavelet#Haar_matrix)