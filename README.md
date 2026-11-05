# DEM 5283/7283: Statistics for Demographic Data II

Course materials for the Spring 2027 graduate course in the Department of Demography at the University of Texas at San Antonio. Instructor: Dr. Corey S. Sparks (corey.sparks@utsa.edu).

**Read the course book at <https://coreysparks.github.io/DEM7283/>.**

The syllabus and schedule are in [`sp2027syllabus.pdf`](sp2027syllabus.pdf) and [`sp2027schedule.pdf`](sp2027schedule.pdf).

## Contents

| Week | Chapter | Main data |
|:----:|---|---|
| 1 | [Course introduction and a reproducible workflow](chapters/01-intro-workflow.qmd) | BRFSS MMSA 2024 |
| 2 | [Complex survey design, weights, and replicate variance](chapters/02-survey-design.qmd) | BRFSS, DHS model data, ACS PUMS |
| 3 | [Binary outcomes with logit and probit models](chapters/03-logit-probit.qmd) | BRFSS |
| 4 | [Comparing nested logit models, and logits for prediction](chapters/04-nested-logits-prediction.qmd) | BRFSS, DHS |
| 5 | [Ordinal and multinomial logit models](chapters/05-ordinal-multinomial.qmd) | BRFSS, DHS |
| 6 | [Counts and rates](chapters/06-count-models.qmd) | AHRF, CDC WONDER, BRFSS |
| 7 | [Decomposition](chapters/07-decomposition.qmd) | CDC WONDER, IPUMS USA, BRFSS |
| 8 | Spring break | |
| 9 | [Missing data and multiple imputation](chapters/09-missing-data.qmd) | BRFSS |
| 10 | [Longitudinal models](chapters/10-longitudinal.qmd) | ECLS-K:2011 |
| 11 | [Splines and generalized additive models](chapters/11-splines-gams.qmd) | BRFSS, IPUMS USA |
| 12 | [Multilevel models I](chapters/12-multilevel-1.qmd) | BRFSS, ACS metro context |
| 13 | [Multilevel models II](chapters/13-multilevel-2.qmd) | BRFSS, ECLS-K:2011, IPUMS NHIS |
| 14 | [Causal inference foundations](chapters/14-causal-inference.qmd) | BRFSS |
| 15 | [Tree-based machine learning with tidymodels](chapters/15-machine-learning.qmd) | BRFSS |
| 16 | Final papers due | |

## Student setup

Install R, Positron (or RStudio) and, on Windows, Rtools. Then paste this line into the R console to install the course packages:

```r
source("https://raw.githubusercontent.com/coreysparks/DEM7283/master/install_first_7283.R")
```

The [Before the First Class](https://coreysparks.github.io/DEM7283/setup.html) page has the step-by-step version. If you'd rather not install anything, the repository includes a development container (`.devcontainer/`) that runs in GitHub Codespaces or VS Code.

## Data

The files the chapters use are in `data/`, and the scripts in `R/` read them (or rebuild them from the original sources). All the data are public:

- BRFSS SMART MMSA 2024, CDC: <https://www.cdc.gov/brfss/smart/smart_2024.html>
- DHS model datasets: <https://dhsprogram.com/data/Model-Datasets.cfm>
- ACS PUMS and county estimates, U.S. Census Bureau, through `tidycensus` (needs a free [API key](https://api.census.gov/data/key_signup.html))
- IPUMS USA and IPUMS NHIS extracts: <https://www.ipums.org>. If you use them, follow the [IPUMS citation requirements](https://www.ipums.org/about/citation).
- Area Health Resources File 2024-2025, HRSA: <https://data.hrsa.gov/topics/health-workforce/ahrf>
- Compressed Mortality File, CDC WONDER: <https://wonder.cdc.gov>
- ECLS-K:2011, NCES: <https://nces.ed.gov/ecls/>

## Repository layout

```
_quarto.yml          book configuration
index.qmd            preface
setup.qmd            "Before the First Class" page
chapters/            one .qmd file per week
references.bib       bibliography for the whole book
_common.R            shared chapter setup (seed and plot colors)
utsa.scss            book theme in UTSA colors
_freeze/             saved results for each chapter (committed)
R/                   data access and helper functions (get_mmsa(), svy_oaxaca(), ...)
data/                course data
images/              figures used in the text
install_first_7283.R student package installer
renv.lock            package versions used to build the book
*_python.qmd, code/  Python versions of some exercises, and the 2022 R Markdown exercises
archive/             the 2022 bookdown draft
```

## Building the book locally

```r
renv::restore()   # once, to install the package versions in renv.lock
```

```bash
quarto render                          # whole book, into docs/
quarto render chapters/06-count-models.qmd   # one chapter
quarto preview                         # live preview while editing
```

`freeze: auto` in `_quarto.yml` saves each chapter's results in `_freeze/`, and Quarto reruns a chapter only when its source file changes. Several chapters take minutes to run (week 9's imputations, week 12's weighted multilevel models, week 15's tuning), so this matters.

## How publishing works

Every push to `master` runs [`.github/workflows/publish.yml`](.github/workflows/publish.yml), which renders the book with Quarto and deploys `docs/` to GitHub Pages. The workflow does **not** install R or run any R code. It uses the frozen results in `_freeze/`. So after you change a chapter:

1. render it locally (`quarto render chapters/<file>.qmd`, or the whole book),
2. commit the chapter **and** the updated `_freeze/` folder,
3. push.

If you push a changed chapter without its frozen results, the workflow tries to run R, can't, and fails. Check the run under the **Actions** tab. `docs/` is not committed; the workflow builds it.

## Changes from the 2022 course

- The weekly handouts are now chapters of one Quarto book, published with GitHub Actions. The 2022 R Markdown exercises (`code/`) and the bookdown draft (`archive/`) are kept for reference.
- New calendar: decomposition, missing data with survey designs, fixed effects and within-between models, causal inference, and machine learning with `tidymodels` are new; principal components and event history models are out.
- BRFSS examples use the 2024 SMART MMSA file instead of 2017 and 2020.
- Predicted probabilities and average marginal effects (`marginaleffects`) are reported alongside odds ratios throughout, and `modelsummary` replaces `stargazer`.
- The package installer moved from the `coreysparks/Rcode` repository to this one.

## License

See [LICENSE](LICENSE).
