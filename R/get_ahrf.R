# Read selected county variables from the HRSA Area Health Resources File.
#
# The 2024-2025 AHRF county file is a SAS dataset inside a zip archive:
# https://data.hrsa.gov/topics/health-workforce/ahrf
# The function uses data/AHRF_2024-2025_SAS.zip when present, downloads it
# when it is not, and caches the variables used in class as an .rds file.
# Variable descriptions are in the AHRF technical documentation on the same
# page. Note that NCHS suppresses birth counts below 10, so those counties
# are missing, not zero.

get_ahrf <- function(data_dir = here::here("data"), refresh = FALSE) {
  rds <- file.path(data_dir, "ahrf_2024_2025.rds")
  if (file.exists(rds) && !refresh) {
    return(readRDS(rds))
  }

  zip <- file.path(data_dir, "AHRF_2024-2025_SAS.zip")
  if (!file.exists(zip)) {
    url <- "https://data.hrsa.gov/DataDownload/AHRF/AHRF_2024-2025_SAS.zip"
    message("Downloading ", url)
    old <- options(timeout = max(900, getOption("timeout")))
    on.exit(options(old), add = TRUE)
    utils::download.file(url, zip, mode = "wb")
  }

  sas <- grep("\\.sas7bdat$", utils::unzip(zip, list = TRUE)$Name, value = TRUE)
  path <- utils::unzip(zip, files = sas, exdir = tempdir(), junkpaths = TRUE)
  on.exit(unlink(path), add = TRUE)

  d <- haven::read_sas(path) |>
    dplyr::select(fips_st_cnty, st_name_abbrev, cnty_name,
                  popn_est_23,
                  births = births_3yr_avg_23,          # 3-year total births, 2020-2023
                  lbw = lo_birth_wgt_3yr_avg_23,       # 3-year total low birth weight births
                  pov_pct = pers_povty_pct_23,         # percent of persons in poverty, 2023
                  rucc = rural_urban_contnm_23,        # USDA rural-urban continuum code, 2023
                  hpsa = hpsa_prim_care_25,            # primary care shortage area, 2025
                  obgyn = md_nf_obgyn_gen_23) |>       # non-federal general OB-GYNs, 2023
    haven::zap_labels() |>
    haven::zap_formats()

  saveRDS(d, rds)
  d
}
