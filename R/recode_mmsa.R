# Standard recodes for the 2024 BRFSS SMART MMSA file, used from week 3 on.
#
# Expects the output of get_mmsa(), with lower-case names and no leading
# underscores. Codes follow the 2024 calculated variables codebook:
# https://www.cdc.gov/brfss/annual_data/2024/pdf/2024-calculated-variables-version4-508.pdf
# Week 2 walks through these recodes one at a time.

recode_mmsa <- function(d) {
  d |>
    dplyr::mutate(
      # self-rated health
      badhealth = dplyr::case_when(genhlth %in% 4:5 ~ 1,
                                   genhlth %in% 1:3 ~ 0),
      genhlth3 = factor(dplyr::case_when(genhlth %in% 1:2 ~ "Excellent/very good",
                                         genhlth == 3 ~ "Good",
                                         genhlth %in% 4:5 ~ "Fair/poor"),
                        levels = c("Excellent/very good", "Good", "Fair/poor"),
                        ordered = TRUE),

      # demographics
      female = dplyr::if_else(sexvar == 2, 1, 0),
      race_eth = factor(dplyr::case_when(racegr3 == 1 ~ "NH White",
                                         racegr3 == 2 ~ "NH Black",
                                         racegr3 == 3 ~ "NH Other",
                                         racegr3 == 4 ~ "NH Multiracial",
                                         racegr3 == 5 ~ "Hispanic"),
                        levels = c("NH White", "NH Black", "NH Other",
                                   "NH Multiracial", "Hispanic")),
      agec = factor(ageg, levels = 1:6,
                    labels = c("18-24", "25-34", "35-44", "45-54", "55-64", "65+")),

      # socioeconomic status
      educ = factor(dplyr::case_when(educag == 1 ~ "Less than HS",
                                     educag == 2 ~ "HS graduate",
                                     educag == 3 ~ "Some college",
                                     educag == 4 ~ "College graduate"),
                    levels = c("Less than HS", "HS graduate",
                               "Some college", "College graduate")),
      income = factor(dplyr::case_when(incomg1 %in% 1:2 ~ "Under $25k",
                                       incomg1 %in% 3:4 ~ "$25k-$50k",
                                       incomg1 == 5 ~ "$50k-$100k",
                                       incomg1 %in% 6:7 ~ "$100k+"),
                      levels = c("Under $25k", "$25k-$50k", "$50k-$100k", "$100k+")),
      insured = dplyr::case_when(hlthpl2 == 1 ~ 1,
                                 hlthpl2 == 2 ~ 0),

      # behaviors and health
      smoke = factor(dplyr::case_when(smoker3 %in% 1:2 ~ "Current",
                                      smoker3 == 3 ~ "Former",
                                      smoker3 == 4 ~ "Never"),
                     levels = c("Never", "Former", "Current")),
      bmi = bmi5 / 100,
      obese = dplyr::if_else(bmi >= 30, 1, 0),
      # days of poor mental / physical health in the past 30 (88 = none)
      ment_days = dplyr::case_when(menthlth == 88 ~ 0,
                                   menthlth %in% 1:30 ~ menthlth),
      phys_days = dplyr::case_when(physhlth == 88 ~ 0,
                                   physhlth %in% 1:30 ~ physhlth),

      # geography
      texas = stringr::str_detect(mmsaname, ", TX"),
      place = stringr::str_remove(mmsaname, ", [A-Z]{2}(-[A-Z]{2})*, .*$")
    )
}
