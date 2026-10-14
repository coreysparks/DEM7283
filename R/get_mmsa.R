# Read the CDC BRFSS SMART MMSA file for a given year.
#
# The function looks for a cached .rds in data/ first. If there is none, it
# uses data/MMSA<year>_XPT.zip when present and downloads the zip from CDC
# when it is not. Variable names are lower-cased and leading underscores are
# removed, so _STSTR becomes ststr and _MMSAWT becomes mmsawt.
#
# The download URL follows the pattern CDC used for the 2024 release. Check
# https://www.cdc.gov/brfss/smart/ if a different year fails to download.

mmsa_md5 <- c("2024" = "ff5b705ce8cba8fac43582018b2e305c")

get_mmsa <- function(year = 2024, data_dir = here::here("data"), refresh = FALSE) {
  rds <- file.path(data_dir, sprintf("mmsa%d.rds", year))
  if (file.exists(rds) && !refresh) {
    return(readRDS(rds))
  }

  zip <- file.path(data_dir, sprintf("MMSA%d_XPT.zip", year))
  if (!file.exists(zip)) {
    url <- sprintf("https://www.cdc.gov/brfss/annual_data/%d/files/MMSA%d_XPT.zip",
                   year, year)
    message("Downloading ", url)
    old <- options(timeout = max(900, getOption("timeout")))
    on.exit(options(old), add = TRUE)
    utils::download.file(url, zip, mode = "wb")
  }

  # CDC sometimes reissues files, so a mismatch is a warning, not an error
  key <- as.character(year)
  if (key %in% names(mmsa_md5)) {
    md5 <- unname(tools::md5sum(zip))
    if (!identical(md5, mmsa_md5[[key]])) {
      warning("Checksum for ", basename(zip), " does not match the course copy. ",
              "CDC may have reissued the file; results can differ slightly.")
    }
  }

  xpt <- utils::unzip(zip, exdir = tempdir())
  on.exit(unlink(xpt), add = TRUE)
  d <- haven::read_xpt(xpt)
  names(d) <- tolower(gsub("_", "", names(d)))
  # MMSA names are stored as latin1 (for example San Juan-Bayamón, PR)
  d$mmsaname <- iconv(d$mmsaname, from = "latin1", to = "UTF-8")
  d <- haven::zap_labels(d)

  saveRDS(d, rds)
  d
}
