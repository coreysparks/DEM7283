# Builds data/eclsk2011_k5.rds, the ECLS-K:2011 subset used in weeks 10 and 13.
#
# The full K-5 public-use file (eclskk5.rds, about 600 MB, 26,000 variables)
# is too large for the repository, so this script keeps the child IDs, the
# design variables for the K-5 longitudinal weight, and the variables the
# longitudinal examples use. It only needs to be run once, by the instructor.
# Missing-value codes (-1, -7, -8, -9) are left as they are; the weekly
# documents recode them.

library(dplyr)
library(here)

full_file <- file.path("C:/Users/ozd504/OneDrive - University of Texas at San Antonio",
                       "Teaching/classes/dem7223/dem7223_22/data/eclskk5.rds")

eclsk <- readRDS(full_file)

keep <- c(
  # IDs and school identifiers
  "childid", "s1_id",
  # K-5 longitudinal weight (child assessment and parent interview, all
  # nine rounds) with its strata and PSU
  "w9c29p_9a0", "w9c29p_9astr", "w9c29p_9apsu",
  # time-constant child and family characteristics
  "x_chsex_r", "x_raceth_r", "x12par1ed_i", "p1curmar", "x1locale",
  # rounds 1-9: fall K, spring K, fall 1st, spring 1st, fall 2nd,
  # spring 2nd, spring 3rd, spring 4th, spring 5th
  sprintf("x%dmscalk5", 1:9), sprintf("x%drscalk5", 1:9),
  "x1kage_r", "x2kage_r", sprintf("x%dage", 3:9),
  sprintf("x%dbmi", 1:9), sprintf("x%dheight", 1:9),
  # family poverty, measured in rounds 2, 4, 6, 7, 8 and 9
  "x2povty", sprintf("x%dpovty_i", c(4, 6:9)),
  # SES and household food security
  "x12sesl", "x4sesl_i", "x9sesl_i",
  "x2fsstat2", "x4fsstat2", "x9fsstat2",
  # parent-rated child health, rounds 1, 2, 4, 6, 7, 8, 9
  sprintf("p%dhscale", c(1, 2, 4, 6:9))
)

eclsk |>
  select(all_of(keep)) |>
  haven::zap_labels() |>
  saveRDS(here("data", "eclsk2011_k5.rds"))
