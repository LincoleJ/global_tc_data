# Global Hurricane Exposure Data (1980-Now)

Work in progress by Lingke Jiang, G. Brooke Anderson, Xiao Wu, Robbie M. Parks

This repository generates hazard-based exposure data for second-level administrative units from historical tropical storms worldwide from IBTrACS best-track data, spanning from 1980 to the present. The code may be used to update the dataset annually with the most recent data.

## Code (in progress)

### 0. Description

Methods to calculate population centroids for each exposure year; methods to generate hurricane tracks data for each ADM2

### 1. Raw data

GHSL: https://human-settlement.emergency.copernicus.eu/download.php

GRDI: https://www.earthdata.nasa.gov/data/catalog/sedac-ciesin-sedac-pmp-grdi-2010-2020-1.00

ADM2: https://www.geoboundaries.org/

IBTrACS: https://www.ncei.noaa.gov/data/international-best-track-archive-for-climate-stewardship-ibtracs/v04r01/access/csv/

### 2. Code

### 3. Processed data

## Other stuff

note: please run create_folder_structure.R first to create folders which may not be there when first loaded.

note: to run an R Markdown file from command line, run\
Rscript -e "rmarkdown::render('SCRIPT_NAME.Rmd')"
