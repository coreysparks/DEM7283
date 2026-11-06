# Figures for the DEM 5283/7283 Spring 2027 flyer
library(tidyverse)
library(here)
library(survey)
library(sparkscolors)

theme_flyer <- theme_minimal(base_size = 11) +
  theme(text = element_text(colour = utsa_cols("midnight")),
        axis.text = element_text(colour = utsa_cols("midnight")),
        panel.grid.major = element_line(colour = utsa_cols("concrete")),
        panel.grid.minor = element_blank(),
        plot.title = element_text(face = "bold", size = 12),
        plot.subtitle = element_text(size = 9.5),
        plot.caption = element_text(size = 7.5, hjust = 0),
        legend.position = "bottom", legend.title = element_blank(),
        plot.background = element_rect(fill = "white", colour = NA))

# 1. ECLS-K:2011 math growth, kindergarten to grade 5 ---------------------
eclsk <- readRDS(here("data", "eclsk2011_k5.rds"))
age_vars  <- c("x1kage_r", "x2kage_r", paste0("x", 3:9, "age"))
math_vars <- paste0("x", 1:9, "mscalk5")

long <- eclsk |>
  filter(x12par1ed_i > 0) |>
  mutate(par_ed = if_else(x12par1ed_i >= 6, "Parent has a bachelor's degree",
                          "Parent has less than a bachelor's")) |>
  select(childid, par_ed, all_of(age_vars), all_of(math_vars)) |>
  pivot_longer(-c(childid, par_ed),
               names_to = c("wave", ".value"),
               names_pattern = "x(\\d)(.*)") |>
  mutate(age = coalesce(kage_r, age) / 12, math = mscalk5) |>
  filter(age >= 5, age <= 11.5, math > 0) |>
  select(childid, par_ed, wave, age, math)

set.seed(7283)
kids <- long |> distinct(childid) |> slice_sample(n = 60) |> pull()

p1 <- ggplot(long, aes(age, math)) +
  geom_line(data = filter(long, childid %in% kids), aes(group = childid),
            colour = utsa_cols("smoke"), linewidth = 0.35) +
  geom_smooth(aes(colour = par_ed, linetype = par_ed), method = "gam",
              formula = y ~ s(x, k = 6), se = FALSE, linewidth = 1.3) +
  scale_colour_manual(values = unname(utsa_cols("midnight", "orange"))) +
  labs(title = "Children's math growth, K to grade 5",
       subtitle = "60 children (grey) and average growth by parent education",
       x = "Age (years)", y = "Math score",
       caption = "Data: ECLS-K:2011") +
  guides(colour = guide_legend(nrow = 2), linetype = guide_legend(nrow = 2)) +
  theme_flyer

ggsave(here("flyer", "fig_growth.png"), p1, width = 4.4, height = 3.7, dpi = 300)

# 2. BRFSS 2024: fair/poor health by age and education ---------------------
source(here("R", "recode_mmsa.R"))
brfss <- readRDS(here("data", "mmsa2024.rds")) |> recode_mmsa() |>
  filter(!is.na(badhealth), !is.na(agec), !is.na(educ))
options(survey.lonely.psu = "adjust")
des <- svydesign(ids = ~1, strata = ~ststr, weights = ~mmsawt, data = brfss)
est <- svyby(~badhealth, ~agec + educ, des, svymean, na.rm = TRUE) |>
  as_tibble()

p2 <- ggplot(est, aes(agec, badhealth, colour = educ, group = educ, shape = educ)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2.4) +
  scale_shape_manual(values = c(16, 17, 15, 18)) +
  scale_colour_manual(values = unname(utsa_cols("midnight", "orange", "talavera_blue", "brass"))) +
  scale_y_continuous(labels = scales::percent) +
  labs(title = "Fair or poor health by age and education",
       subtitle = "Survey-weighted estimates for U.S. metro areas",
       x = "Age group", y = NULL,
       caption = "Data: BRFSS SMART MMSA, 2024") +
  guides(colour = guide_legend(nrow = 2, byrow = TRUE), shape = guide_legend(nrow = 2, byrow = TRUE)) +
  theme_flyer

ggsave(here("flyer", "fig_health.png"), p2, width = 4.4, height = 3.7, dpi = 300)
