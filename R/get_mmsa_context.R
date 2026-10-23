# Metro-level context for the BRFSS SMART MMSA file, from the 2019-2023 ACS.
#
# The BRFSS identifies metropolitan statistical areas (CBSAs) and, for the
# largest metros, metropolitan divisions. The ACS doesn't publish data for
# divisions, so this function downloads county estimates and adds them up to
# both CBSAs and divisions, using the OMB delineation file that says which
# counties belong to which. Every rate is computed from summed counts, never
# by averaging county rates.
#
# Needs a Census API key (see week 2). The result is cached in data/.

get_mmsa_context <- function(data_dir = here::here("data"), refresh = FALSE) {
  rds <- file.path(data_dir, "mmsa_context_acs2023.rds")
  if (file.exists(rds) && !refresh) return(readRDS(rds))

  xlsx <- file.path(tempdir(), "list1_2023.xlsx")
  utils::download.file(
    paste0("https://www2.census.gov/programs-surveys/metro-micro/geographies/",
           "reference-files/2023/delineation-files/list1_2023.xlsx"),
    xlsx, mode = "wb", quiet = TRUE)

  counties <- readxl::read_excel(xlsx, skip = 2) |>
    dplyr::filter(!is.na(`FIPS County Code`)) |>
    dplyr::transmute(GEOID = paste0(`FIPS State Code`, `FIPS County Code`),
                     cbsa = `CBSA Code`,
                     division = `Metropolitan Division Code`)

  vars <- c(pov_tot = "B17001_001", pov_n = "B17001_002",
            lf = "B23025_003", unemp_n = "B23025_005",
            pop = "B03003_001", hisp_n = "B03003_003",
            ed_tot = "B15003_001", ba = "B15003_022", ma = "B15003_023",
            prof = "B15003_024", phd = "B15003_025")

  acs <- tidycensus::get_acs(geography = "county", variables = vars,
                             year = 2023, survey = "acs5", output = "wide") |>
    dplyr::select(GEOID, dplyr::all_of(paste0(names(vars), "E"))) |>
    dplyr::rename_with(~ sub("E$", "", .x), -GEOID) |>
    dplyr::inner_join(counties, by = "GEOID")

  add_up <- function(d, code) {
    d |>
      dplyr::filter(!is.na({{ code }})) |>
      dplyr::group_by(mmsa = {{ code }}) |>
      dplyr::summarise(dplyr::across(pov_tot:phd, sum), .groups = "drop")
  }

  context <- dplyr::bind_rows(add_up(acs, cbsa), add_up(acs, division)) |>
    dplyr::transmute(mmsa,
                     pct_poverty = 100 * pov_n / pov_tot,
                     pct_unemp = 100 * unemp_n / lf,
                     pct_hisp = 100 * hisp_n / pop,
                     pct_ba = 100 * (ba + ma + prof + phd) / ed_tot)

  saveRDS(context, rds)
  context
}
