---
title: Transfer Learning
subject: AI 4 Attribution
short_title: VI - Transfer Learning
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

> **TLDR**: 
> It is very evident that large scale DL methods have had great success in predicting weather. 
> However, very little attention has been paid to predicting climate and even less has been explored for extremes. 
> Nevertheless, there is a wealth of information present within these models as they input large amounts of Multivariate, spatiotemporal data. 
> We will look at using these pretrained models as dynamical models which can be included as relevant covariates to our extremes models. 
> We can use standard nonlinear SSM to apply them, e.g., EKF, UKF, or ADF. 
> We can also include methods like ensemble Kalman filters or particle filters. 
> Lastly, we can explore retraining these models to predict the appropriate scales necessary for climate projections and extremes.