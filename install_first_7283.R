# DEM 7283 package installer, Spring 2027
# Run once, before the first class:
#   source("https://raw.githubusercontent.com/coreysparks/Rcode/master/install_first_7283.R")
# Packages you already have are skipped, so it is safe to re-run.

message("Installing DEM 7283 packages. This may take a while the first time.")

if (!requireNamespace("pak", quietly = TRUE)) {
  install.packages("pak")
}

pkgs <- c(
  # workflow: Quarto, renv, Git (week 1)
  "knitr", "rmarkdown", "quarto", "here", "renv", "usethis", "gitcreds",
  # data access and wrangling
  "tidyverse", "haven", "ipumsr", "tidycensus", "tigris", "skimr", "scales",
  # survey design (week 2 onward)
  "survey", "srvyr", "svyVGAM",
  # model output and interpretation
  "modelsummary", "marginaleffects", "gtsummary", "broom", "car", "Hmisc",
  # categorical, ordinal and count models (weeks 3-6)
  "VGAM", "pscl", "betareg",
  # decomposition (week 7)
  "oaxaca",
  # missing data (week 9)
  "mice", "mitools",
  # longitudinal, GEE and fixed effects (week 10)
  "geepack", "fixest",
  # multilevel models (weeks 12-13)
  "lme4", "WeMix", "brms",
  # causal inference (week 14)
  "dagitty", "ggdag", "MatchIt", "WeightIt", "cobalt", "EValue",
  # machine learning (week 15)
  "tidymodels", "probably", "ranger", "xgboost", "rpart.plot",
  # UTSA color palettes (GitHub)
  "coreysparks/sparkscolors"
)

pak::pak(pkgs, upgrade = FALSE, ask = FALSE)

# brms compiles Stan models, which needs a C++ toolchain:
# Rtools on Windows, Xcode command line tools on macOS.
if (.Platform$OS.type == "windows" && !nzchar(Sys.which("make"))) {
  message("Rtools not found. Install it before week 12: https://cran.r-project.org/bin/windows/Rtools/")
}

message("Done. Restart R before you start working.")
