# Builds data/nhis_2000_2014_adults.rds, the NHIS subset used for the
# age-period-cohort example in week 13.
#
# The source is IPUMS NHIS extract nhis_00011 (2000-2014). The full extract
# is about 1.4 million people and lives outside the repository, so this
# script keeps the sample adults (the only people asked about BMI and
# smoking) and the variables the example uses. It only needs to be run once,
# by the instructor. IPUMS codes are left as they are; week 13 recodes them.

library(ipumsr)
library(dplyr)
library(here)

nhis_dir <- file.path("C:/Users/ozd504/OneDrive - University of Texas at San Antonio",
                      "Teaching/classes/dem7473/data")

ddi <- read_ipums_ddi(file.path(nhis_dir, "nhis_00011.xml"))

read_ipums_micro(ddi, data_file = file.path(nhis_dir, "nhis_00011.dat.gz"),
                 verbose = FALSE) |>
  filter(SAMPWEIGHT > 0, AGE >= 18) |>
  select(YEAR, STRATA, PSU, SAMPWEIGHT, AGE, BIRTHYR, SEX, RACEA, HISPETH,
         EDUCREC2, HEALTH, BMICALC, SMOKESTATUS2) |>
  zap_labels() |>
  saveRDS(here("data", "nhis_2000_2014_adults.rds"))
