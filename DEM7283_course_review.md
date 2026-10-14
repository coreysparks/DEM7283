# DEM 5283/7283 Course Review and Revision Plan

Statistics for Demographic Data II, UTSA. Review date: October 12, 2026.

## Scope of the review

The review uses the public repository at github.com/coreysparks/DEM7283 (master branch). This repository holds the Spring 2022 README and calendar, the R Markdown exercises in `/code`, a three-chapter bookdown draft in `/Stats_2_Notes`, and the Python Quarto ports dated April 2026. If the current course materials differ from this repository, some points may not apply.

## Decisions made

The PCA week is removed from the course. Event history content stays out of DEM 7283, because a separate full course covers event history models. The discrete-time hazard week from the first draft of the review is therefore removed.

## Revised calendar

| Week | Topic |
| --- | --- |
| 1 | Course introduction; reproducible workflow with Quarto, renv, and Git |
| 2 | Complex survey design, weights, replicate variance |
| 3 | Binary outcomes: logit and probit, predicted probabilities, AMEs |
| 4 | Model comparison across nested logits (KHB); prediction and cross validation |
| 5 | Ordinal and multinomial models |
| 6 | Counts and rates: Poisson, negative binomial, offsets, zero inflation |
| 7 | Decomposition: Kitagawa and Oaxaca-Blinder |
| 8 | Spring break |
| 9 | Missing data and multiple imputation with survey designs |
| 10 | Longitudinal models: GEE, fixed effects, within-between models |
| 11 | Splines and GAMs |
| 12 | Multilevel models I: centering, random slopes, level-specific weights |
| 13 | Multilevel models II: GLMMs, growth curves, APC identification |
| 14 | Causal inference foundations: DAGs and propensity score weighting |
| 15 | Tree-based machine learning with tidymodels |
| 16 | Final papers due |

Growth curves are in week 13, because a growth curve is a multilevel model with time at level 1, and students learn it more easily after random slopes in week 12. Week 10 stays on marginal and fixed effects approaches to panel data. Week 10 should tell students in one sentence that person-period data and discrete-time hazard models are the next step, and refer them to the event history course.

The PCA exercise was the only place where students built a composite index for places. A short note on how to build and justify a standardized index can go in week 6 or week 12 if students need it for final papers.

## Priority 1: Interpretation of nonlinear models

EX3 and EX4 put most of the emphasis on odds ratios. EX3 uses `emmeans` for predicted probabilities, but the course does not teach average marginal effects as a standard output. Add the `marginaleffects` package (a Python port with the same name exists) and require students to report AMEs or predicted probabilities next to odds ratios.

EX4 adds education to a logit model and interprets the change in race coefficients as attenuation. In logit and probit models, coefficients from nested models are not directly comparable, because the scale of the latent error variance changes when predictors are added. Add a section to EX4 on this problem with a KHB or AME comparison. References: Mood (2010), *European Sociological Review*; Karlson, Holm, and Breen (2012), *Sociological Methodology*. Verify citation details before use.

## Priority 2: Survey design in the advanced models

The multiple imputation exercise runs `mice` without design variables and pools unweighted models with `pool()`. Include strata, PSU, and weight (or functions of them) in the imputation model. Analyze each completed dataset with `svyglm` and combine results with `mitools::MIcombine` or `with(svydesign(...))`. The section "Testing for MAR" needs a caution: observed data can show that missingness is not MCAR, but cannot confirm MAR. For the number of imputations, see von Hippel (2020), *Sociological Methods & Research*. Verify this reference.

EX10 and EX11 fit multilevel models to BRFSS with MMSA as level 2 and do not discuss weights. Add a short section on level-specific weights (Pfeffermann et al. 1998; Rabe-Hesketh and Skrondal 2006) and show the `WeMix` package. Check the current CRAN status of `WeMix`.

## Priority 3: Content updates

The APC example in EX11 fits a hierarchical APC model with cross-classified random effects for period and cohort (the Yang and Land approach). This approach is contested; Bell and Jones, and Luo and Hodges, among others, show that the random effects do not solve the identification problem and impose a constraint that is hard to see. Add a section on the identification problem and these critiques.

The longitudinal unit is only GEE. Add fixed effects and within-between (hybrid) models after Allison (2009) and Bell and Jones (2015), with the `fixest` package. Growth curve models with `lmer` go in week 13.

The multilevel weeks need more on centering (grand mean against group mean, after Enders and Tofighi 2007), random slopes, and diagnostics. A short Bayesian alternative with `brms` helps with few level-2 units and `glmer` convergence problems.

Add decomposition methods in week 7: Kitagawa decomposition and Oaxaca-Blinder decomposition, with the nonlinear extension of Fairlie or the `oaxaca` package.

Add one week on causal inference: DAGs, confounding, and propensity score weighting with `WeightIt` and `MatchIt`.

The 2022 calendar lists regression trees, but the repository has no exercise for this topic. Build the week 15 exercise with `tidymodels`, not `caret`, which is in maintenance mode to the best of my knowledge. The prediction section in EX4 also uses `caret` and should move to `tidymodels`. Include cross validation, random forests or gradient boosting, calibration, and a short discussion of fairness and the limits of prediction for policy use.

The count models unit is in good shape. Make offsets for rates explicit in every aggregate example and add zero-inflated and hurdle models briefly.

## Priority 4: Materials and reproducibility

Several exercises load data from hard-coded local paths, for example `C:/Users/ozd504/OneDrive...` in EX8 and EX11. Use `here::here()` with data in the repository, or download scripts with a checksum, and lock package versions with `renv`.

The README is out of date. It specifies R 4.1 and Rtools 4.0, points to the DEM7093 repository, and the calendar refers to a text abbreviated "AL" that is not in the book table. Week 5 has an unresolved citation, "2 ch 2".

The repository has duplicate versions of exercises: EX2 in three forms, EX6 in two forms, and PCA in two forms. The bookdown notes have three chapters and template files (`hello-bookdown`, `etcfiles`). Choose one format, preferably a Quarto book, and remove old versions. The PCA files can be removed under the new calendar.

`stargazer` appears in most exercises; I believe it has had no substantial update for several years, and `modelsummary` is a current option that handles survey and mixed models. In EX10, `sjstats::icc` may no longer exist; I believe the function moved to `performance::icc`. Verify both points.

The data are BRFSS 2017 and 2020. Update to a current BRFSS year; the newer race and ethnicity variables give a teaching example about changes in measurement.

## Python ports

In `EX10_MLM1_python.qmd`, the data load and recode chunks are commented out, so the document does not run from start to end. The survey port depends on the `svy` package and `utils.py`. The maturity of `svy` is uncertain and its documentation is limited; `samplics` is a more established option. Test both against `survey` output in R on the same BRFSS design before use in class.

Add a parity check to each Python file: a small table that compares Python estimates and standard errors to the R estimates. Python has no good equivalent of `svyVGAM`, `glmer` for binary outcomes, or KHB, so tell students where R stays the primary tool.

## Next steps

1. Revise EX4 with marginal effects and the KHB comparison, in R and Python.
2. Update the README with the new calendar, reading assignments, and current software requirements.
3. Remove the PCA files and duplicate exercise versions.
4. Replace hard-coded paths and add `renv`.
5. Build new exercises for decomposition (week 7), within-between models (week 10), causal inference (week 14), and tidymodels (week 15).
6. Revise the multiple imputation and multilevel exercises for survey design and weights.

## References to verify

All references in this file come from general knowledge, not from a search. Verify each one against the original source before it goes on the syllabus: Mood (2010); Karlson, Holm, and Breen (2012); von Hippel (2020); Pfeffermann et al. (1998); Rabe-Hesketh and Skrondal (2006); Allison (2009); Bell and Jones (2015); Enders and Tofighi (2007); Yang and Land; Luo and Hodges.
