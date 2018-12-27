
---
title: "Fecundity Estimation"
author: "Enoch Ng'oma (EN), Kevin Middleton (KM), and Elizabeth King (EK)"
date: "6/8/2018"
---

## Project Record

The following steps should be followed to reproduce the analysis.

### Estimation of egg counts

1. Extract image dimensions:
`Code/01_get_image_dimensions.R`

    - Loads each image file and outputs the maximum dimension. Each image is (roughly) square, so the maximum dimension is a good estimate.
    - Reads: Image files from the zenodo repository. 
    - Writes: `Data/image_dimensions.csv`

2. Get white area for each image at range of thresholds:
`Code/02_area_summation.py`

    - Processes the full set of images, calculating area for thresholds between 30 and 150).
    - Reads:
        - Images from the zenodo repository.
        - `Data/feclife_with-image-ids.xlsx`: Excel file with information on image names and those that were manually handcounted.
    - Writes:
        - `Data/area_summation.Rda`

3. Optimize threshold: `Code/03_threshold_optimization_linear.R`

    - Performs either coarse or fine (`coarse` flag) optimization on training images to find the threshold value that minimizes MSE between prediction and handcount using a linear model with square root of 'egg' area: `handcount ~ I(area^0.5) + img_size - 1`. Uses a variable percentage of the data (for rarefaction) and a variable train/test split. Analysis of the resulting coarse optimization are used to guide the fine optimization. Results of the fine optimization are used to determine the optimal threshold value to use for the full image set.

    - Reads:
        - `Data/area_summation.Rda`: Areas calculated for all thresholds from 30 to 150
        - `Data/feclife_with-image-ids.xlsx`: Excel file with information on image names and those that were manually handcounted.
    - Writes:
        - `Data/threshold_optimization_linear_coarse.csv`
        - `Data/threshold_optimization_linear_fine.csv`

4. Predict egg counts from images: `Code/04_h2_fec_prediction.Rmd`

    - Predicts egg counts from image areas for the full set using the threshold value (`linear_threshold <- 53`) determined above. Training image data are loaded and used to create a linear model for predicting egg counts for the full set.
    - Reads:
        - `Data/feclife_with-image-ids.xlsx`: Excel file with information for all images
        - `Data/area_summation.Rda`: Areas for the training set
        - `Data/image_dimensions.csv`: Maximum image dimensions for the training set
    - Writes: 
        - `Data/predicted_egg_counts.rda`
    