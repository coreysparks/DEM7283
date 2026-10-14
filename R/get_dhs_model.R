# Read the DHS model individual recode (women's) file, ZZIR62FL.
#
# The DHS Program publishes model datasets that look like a real DHS but
# describe no real country, so anyone can use them without an application:
# https://dhsprogram.com/data/Model-Datasets.cfm
# The course copy lives in the coreysparks/data GitHub repository. The
# function caches a smaller .rds with the variables used in class.

get_dhs_model <- function(data_dir = here::here("data"), refresh = FALSE) {
  rds <- file.path(data_dir, "dhs_model_ir.rds")
  if (file.exists(rds) && !refresh) {
    return(readRDS(rds))
  }

  dta <- file.path(data_dir, "ZZIR62FL.DTA")
  if (!file.exists(dta)) {
    url <- "https://github.com/coreysparks/data/blob/master/ZZIR62FL.DTA?raw=true"
    message("Downloading ", url)
    utils::download.file(url, dta, mode = "wb")
  }

  d <- haven::read_dta(dta) |>
    dplyr::select(caseid,
                  v005, v021, v022, v023,       # weight, PSU, strata
                  v012, v024, v025, v106, v190, # age, region, residence, education, wealth
                  v201, v218,                   # children ever born, living children
                  v213, v313, v364, v502, v536) |>
    haven::zap_labels()

  saveRDS(d, rds)
  d
}
