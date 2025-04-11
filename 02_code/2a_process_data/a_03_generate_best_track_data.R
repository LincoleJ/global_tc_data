rm(list=ls())
library(dplyr)
library(lubridate)
library(sp)
library(stormwindmodel)

all_ibtracs = readr::read_csv("./raw-data/IBTrACS-data/ibtracs.since1980.list.v04r01.csv")
all_storms = all_ibtracs %>% 
  filter(ISO_TIME <= as.POSIXct("2025-02-01"))
hurr_tracks = data.frame(unique_identifier = all_storms$SID,
                         storm_id = all_storms$NAME,
                         usa_atcf_id = all_storms$USA_ATCF_ID,
                         date = all_storms$ISO_TIME,
                         latitude = all_storms$USA_LAT,
                         longitude = all_storms$USA_LON,
                         wind = all_storms$USA_WIND) %>%
  na.omit() %>%
  dplyr::mutate(latitude = as.numeric(latitude),
                longitude = as.numeric(longitude),
                wind = as.numeric(wind)) %>%
  dplyr::mutate(storm_id = paste0(tools::toTitleCase(tolower(storm_id)),
                                  "-", substr(date, 1, 4)))

