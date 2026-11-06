# DEM 5283/7283 Homework Assignments, Spring 2027

## Before you start

**Which data to use.** Starting with Homework 2, students in DEM 7283 do every homework with the complex survey data they chose in week 2. Students in DEM 5283 can do each homework with their own survey or with my data from that week's chapter. Say at the top of each homework which you used. If your survey can't support a week's method (for example, it has no repeated measurements for Homework 10), use my data for that homework and say so.

**What to turn in.** Each homework is a Quarto document that renders from top to bottom without errors, with all your discussion and analysis in that document. Through Canvas, turn in two links: your rendered homework on Posit Connect Cloud (published from Positron with Posit Publisher), and the GitHub repository that holds your code. Homework is due before class on the date listed.

**What I look for.** Every estimate uses the full survey design (weights, and strata and clusters or replicate weights) unless a question says otherwise, and comes with a standard error or confidence interval. Every result is interpreted in a complete sentence in units a reader understands, says which population it describes, and is described as an association unless the question is about causal effects (Homework 14). If you need help figuring out what your PSU, weight and strata variables are called, ask me.

---

## Homework 1: Reproducible Workflow

**Due:** January 28

1. Create a folder for your homework this semester and open it in Positron.
   1. Put it under version control with Git and connect it to a new GitHub repository.
   2. Add `data/` to its `.gitignore`, so your data never end up on GitHub.
   3. Run `usethis::git_sitrep()` and show that it reports no problems.
2. Initialize `renv` in the project, install `tidyverse`, `here` and `survey`, and take a snapshot. Show the output of `renv::status()`.
3. Download the survey you're proposing for your survey data choice (due the same day) into your `data/` folder, and read it into R using `here()` for the file path.
   1. How many respondents and how many variables are in the file?
   2. What is the unit represented by one row of the data?
4. Using the survey's documentation, identify the design variables: the weight, and either the strata and PSU variables or the replicate weights.
   1. Report their names and what the documentation says each one is.
   2. Sum the weight. What population does that total represent?
5. Commit your work, push it to GitHub, and check on GitHub that your commit arrived.

---

## Homework 2: Survey Statistics

**Due:** February 4

1. Define a **binary outcome variable** of your choosing, and explain how you recoded the original variable, including what you did with missing and "don't know" codes.
2. State a research question about what factors you believe will affect your outcome variable.
3. Define **at least three predictor variables**, based on your research question. These can be a mixture of continuous and categorical variables.
4. Create the survey design object for your data with `svydesign()` or `as_survey_design()` (or `svrepdesign()` if your survey uses replicate weights), and explain each argument you used.
5. Calculate descriptive statistics for each variable:
   - using no weights or survey design;
   - using the weights only; and
   - using the full survey design and weights.
6. Calculate percentages or means for each predictor at each level of your outcome variable. Present these results in a table, like Table 1 in a demography journal article, with appropriate survey-corrected test statistics (`svychisq()` for categorical variables, `svyttest()` for continuous ones).
7. Report the **design effect** for the overall prevalence of your outcome, and interpret it as a comparison of variances.
8. Are there substantive differences between the unweighted results and the results that use the survey design?
   1. Which estimates changed the most, and why?
   2. What population do your weighted estimates describe?

---

## Homework 3: Binary Logistic or Probit Regression

**Due:** February 11

1. Specify a research question for your analysis, using the binary outcome from Homework 2 or a new one.
2. Generate appropriate predictor variables to examine your research question, and state the reference group for each categorical predictor.
3. Fit a **logistic regression** with `svyglm()` using the full survey design. Then fit the same model as a **probit regression**.
4. Present the results in tabular form, including:
   - parameter estimates from both models;
   - odds ratios from the logit model; and
   - 95% confidence intervals for the odds ratios.
5. Do the logit and probit models lead you to the same substantive conclusions? Compare them on the probability scale, not by their coefficients.
6. Generate **predicted probabilities** for some interesting cases from your analysis to highlight the effects from the model and your stated research question.
7. Calculate the **average marginal effect** of your key predictor with `avg_comparisons()`.
   1. Report it in percentage points with a confidence interval.
   2. Explain in two or three sentences why the odds ratio and the average marginal effect answer different questions.

---

## Homework 4: Nested Models, Interactions, Stratification and Prediction

**Due:** February 18

### Part 1: Nested models and interactions

1. Use your binary outcome from Homework 3, and choose one key predictor (for example, race and ethnicity, sex, or nativity) whose association with the outcome you want to understand.
2. Construct relevant control variables for your outcome, based on the literature in your area of interest, and group them into two sets: basic demographic controls, and variables that might account for part of the key predictor's association (for example, education and income).
3. Fit two nested models: one with the key predictor and basic controls, and one that adds the second set.
   1. Report the average marginal effects of the key predictor from both models, for the same complete-case sample.
   2. How does the association change when the second set is added?
   3. Why can't you compare the logit coefficients from the two models directly? Use the **KHB method** to make the comparison on a common scale.
4. Examine an **interaction** between your key predictor and one other predictor.
   1. Test the interaction terms jointly with `regTermTest()`.
   2. Present predicted probabilities that show what the interaction means.
5. **Stratify** your model by one predictor.
   1. What evidence do you use to justify the stratification?
   2. Is there evidence for **homogeneity of regression effects across the strata**? How do you know?
   3. Explain and discuss the implications, interpreting the models both within and between the strata.

### Part 2: Prediction

6. Treat your outcome as something to predict, rather than explain. Split your data into training and test sets, and fit a logistic regression on the training data with `tidymodels`.
7. Use 10-fold cross-validation on the training data to estimate how well the model predicts.
8. On the test data, report:
   - the area under the ROC curve (discrimination);
   - a calibration plot (calibration); and
   - the sensitivity and specificity at a threshold you choose, and why you chose it (classification).
9. In two or three sentences, explain why a good model for explanation (Part 1) isn't necessarily a good model for prediction, and the reverse.

---

## Homework 5: Ordinal or Multinomial Logistic Regression

**Due:** February 25

1. Define an **ordinal or multinomial outcome variable** of your choosing, and explain how you recoded the original variable.
   1. Is your outcome ordered or unordered? Explain why in a sentence or two.
   2. If it's ordered, why shouldn't its categories be treated as equally spaced numbers?
2. State a research question about the factors you believe will affect your outcome variable.
3. Fit either an **ordinal logistic regression** (proportional odds model) or a **multinomial logistic regression** model to your outcome, using the survey design (`svyolr()` or `svy_vglm()`).
   1. If you use an ordinal model, are the assumptions of the **proportional odds model** met?
   2. How did you evaluate the proportional odds assumption? Fit the model with `parallel = FALSE` and use Wald tests to identify which variables violate it.
   3. If a variable violates the assumption, fit a partial proportional odds model and say how your conclusions change.
4. For the best-fitting model from the previous step:
   - describe the results; and
   - present a table showing **odds ratios and confidence intervals for all model parameters**.
5. Report **predicted probabilities for every category** of your outcome for at least two groups that matter for your research question, and check that each group's probabilities add up to 1.

---

## Homework 6: Count Data Models

**Due:** March 4

1. Define a **count outcome** for your data (for example, the number of days of poor health, the number of children ever born, or the number of doctor visits).
   1. State a research question about your outcome.
   2. Describe its distribution: the mean, the variance, the share of zeros, and any heaping or ceiling.
   3. Is an **offset term** necessary? Why or why not? If it is, what is the exposure?
2. Consider a **Poisson regression model** for the outcome.
   1. Evaluate the level of dispersion in the outcome.
   2. Is the Poisson model a good choice?
3. Fit a population-average model with `svyglm()` and `family = quasipoisson`, and interpret the exponentiated coefficients for your key predictor as rate ratios in full sentences.
4. Fit a **negative binomial model** with `glm.nb()`, using rescaled weights as in the chapter.
5. Fit a **zero-inflated or hurdle negative binomial model**.
   1. Compare how well the Poisson, negative binomial and zero-inflated or hurdle models reproduce the observed distribution of your outcome, especially the share of zeros and the upper tail.
   2. Why don't we compare these weighted models by AIC?
6. Which model would you use for your research question, and why?

---

## Homework 7: Decomposition Analysis

**Due:** March 18 (after spring break)

1. Choose an outcome (continuous or binary) and two groups that differ on it, and state a research question about the gap between them.
2. **Kitagawa decomposition.** Choose a composition variable that differs between the two groups (for example, age group or education).
   1. Calculate the weighted rate (or mean) of your outcome within each category of the composition variable, and the weighted share of each group in each category.
   2. Decompose the difference into a rate effect and a composition effect, and show that they add up to the total difference.
   3. Interpret each effect in a sentence.
3. **Oaxaca-Blinder decomposition.** Use `svy_oaxaca()` (with `family = binomial()` for a binary outcome) and the predictors from your earlier models.
   1. Report the total gap, the explained and unexplained parts, and the detailed explained part by variable group, all in the units of the outcome and with standard errors.
   2. Show that the components add up to the gap, allowing for rounding.
   3. Name the reference coefficients you used.
4. Redo the decomposition with a different reference.
   1. How do the explained and unexplained parts change?
   2. Explain in two or three sentences how the reference can change the parts without changing the observed gap.
5. In a paragraph, explain why the explained part isn't a causal effect and the unexplained part isn't a measure of discrimination. Name one variable that's missing from your model and how leaving it out could change the results.

---

## Homework 9: Missing Data and Multiple Imputation

**Due:** March 25

1. Use your survey data.
2. Measure an **outcome variable and at least five predictors**.
3. Report the **pattern of missingness** among all of these variables.
   1. What share of cases would a complete-case analysis drop?
   2. Make a flag for missingness on the variable with the most missing data, and model the flag with the other variables. Is that variable MCAR? Who is less likely to answer it?
   3. Describe one plausible reason for the missing data that would make it MAR, and one that would make it MNAR.
4. Perform a **mean imputation** for numeric data or a **modal imputation** for categorical data for all missing values.
   - Perform the analysis using the imputed data and the survey design.
   - What are your results?
5. Perform a **multiple imputation** of all missing values with `mice()`, including the design variables (weight, strata and PSU) in the imputation model.
   - Check the convergence of the imputations.
   - Perform the analysis on each imputed dataset with the survey design, and combine the results with Rubin's rules.
   - What are your results?
6. Compare the approaches:
   - Were the results similar between the mean/modal-imputed and multiply imputed datasets? Compare the standard errors as well as the estimates.
   - How do these results compare with the complete-case model fit using the original data with missing values?
   - Explain why agreement (or disagreement) between the analyses doesn't prove that the data are MAR.

---

## Homework 10: Longitudinal Models

**Due:** April 1

This homework needs repeated measurements of the same people. If your survey doesn't have them, use the ECLS-K data from the chapter.

1. Define an outcome that is measured at least three times for each person, and a time-varying predictor of interest. State a research question about how they're related.
2. Reshape your data to long format (one row per person per wave), and describe:
   1. how many people and how many person-waves you have; and
   2. how much of the variation in your outcome and your key predictor is between people and how much is within people.
3. Fit a **GEE** model with an exchangeable working correlation and with an AR(1) working correlation.
   1. Compare them with QIC. Which do you prefer, and why?
   2. Interpret the coefficient for your key predictor.
4. Fit a **fixed effects** model with person fixed effects.
   1. Interpret the coefficient for your key predictor. What variation identifies it?
   2. What happened to the time-constant predictors, and why?
5. Fit a **within-between** (hybrid) model, with the person mean and the deviation from the person mean of your key predictor.
   1. Interpret the within and between coefficients in the units of the outcome.
   2. Are they different? What would it mean substantively if they were?
6. Explain one source of bias that the person fixed effects would *not* remove.

---

## Homework 11: Splines and Generalized Additive Models

**Due:** April 8

1. Choose an outcome and a continuous predictor (for example, age or income) whose relationship you suspect isn't a straight line, and state a research question about it.
2. Fit a model with the predictor entered as a straight line, and a model with a natural spline `ns(x, df = k)` for `k` = 2, 3, 4 and 6, using the survey design.
   1. Plot the predicted curves on one graph.
   2. Where do the curves agree, and where do they differ (especially at the extremes of the predictor)?
   3. How many degrees of freedom would you use, and why?
3. Fit a **GAM** with `mgcv::gam()` and a smooth term for the predictor, using rescaled weights as in the chapter.
   1. What effective degrees of freedom does it choose?
   2. Plot the smooth and compare it with your spline models.
4. Does the shape of the curve differ between two groups (for example, by sex or education)? Fit a model that allows it to, show the curves, and interpret the difference.
5. Interpret your preferred curve in two or three sentences, and say what it holds fixed. If your predictor is age and your data are cross-sectional, explain why the curve can't tell you how an individual's outcome changes as that person ages.

---

## Homework 12: Multilevel Models I

**Due:** April 15

This homework needs a grouping variable with enough groups (at least 30 or so). If your survey doesn't have one, use the BRFSS metro-area data from the chapter.

1. Identify the grouping variable in your data (for example, state, county, metro area or survey cluster), and how many people are in each group.
2. Construct at least one **group-level variable**, either by aggregating your survey data or by merging contextual data (for example, from the ACS with `tidycensus`). Explain how you scaled it.
3. Fit a **null (random intercept only) model** for a continuous outcome.
   1. Report the variance components and the **intraclass correlation**.
   2. Interpret the ICC in a sentence.
4. Add individual-level predictors, then your group-level variable.
   1. How do the variance components change at each step?
   2. Interpret the coefficient for your group-level variable.
5. **Centering.** Choose one individual-level predictor and fit the model with it grand-mean centered and then group-mean centered (with the group mean added as a level-2 predictor). How do the coefficients and their interpretations differ?
6. Fit a **random slope** for one individual-level predictor.
   1. Is there evidence that its association varies across groups? How do you know?
   2. Plot the group-specific slopes.
7. Fit your final model with **level-specific weights** using `WeMix`, if your survey supplies them, and compare it with the unweighted model. If your survey doesn't supply weights at each level, explain what you would need, and what that means for the population your estimates describe.

---

## Homework 13: Multilevel Models II

**Due:** April 22

1. Using the grouping variable from Homework 12 (or the chapter's data), fit a **generalized linear mixed model** for a binary outcome with `glmer()`.
   1. Start with a random intercept only model and report the ICC on the latent scale.
   2. Add individual-level and group-level predictors, and present the results as odds ratios with confidence intervals.
2. Report **predicted probabilities** for some interesting cases, and explain the difference between predictions for a typical group (random effect set to zero) and predictions averaged over groups.
3. Compare the GLMM's fixed effects with a `svyglm()` logit for the same outcome and predictors. Why are the GLMM's coefficients typically larger in magnitude?
4. **Growth curves.** Using repeated measurements (from your data, or the ECLS-K data from the chapter), fit a **growth curve model** with time as a level-1 variable.
   1. Fit random intercepts, then random intercepts and slopes for time.
   2. Does the shape of growth need to be nonlinear? Try a quadratic or spline term for time.
   3. Add a time-constant predictor and its interaction with time, and interpret it.
   4. Plot the predicted trajectories for two groups.

---

## Homework 14: Causal Inference

**Due:** April 29

1. Choose a binary **exposure** (treatment) and an **outcome** in your data, and state a causal question about them. Define the target population and whether you want the average treatment effect (ATE) or the average treatment effect on the treated (ATT).
2. Draw a **DAG** for your question with `dagitty` and `ggdag`.
   1. Include the confounders you think matter, and at least one mediator or collider if your question has one.
   2. Find a minimal adjustment set. Which variables should you *not* adjust for, and why?
   3. Which important confounders aren't measured in your data?
3. Estimate **propensity scores** for the exposure with the variables in your adjustment set, and the survey weights, using `WeightIt`.
   1. Plot the distribution of propensity scores for the exposed and unexposed groups. Is there good overlap?
   2. Check **balance** before and after weighting with `cobalt`, and show a Love plot. Is balance acceptable?
4. Estimate the effect of the exposure using the combined propensity score and survey weights, and report it on the scale of the outcome (for example, in percentage points with `avg_comparisons()`) with a confidence interval.
5. Compare it with the estimate from an ordinary survey-weighted regression with the same covariates. Are they similar?
6. Calculate an **E-value** for your estimate, and interpret it. How strong would an unmeasured confounder need to be to explain away your result? Is that plausible for the confounders you named in step 2?
7. In a paragraph, state the assumptions your estimate depends on (exchangeability, positivity, consistency) and how believable each one is here.

---

## Homework 15: Tree-Based Machine Learning

**Due:** May 6

1. Choose a binary outcome to **predict**, and say who would use the predictions and what they would do with them.
2. Split your data into training and test sets, stratified on the outcome, and write a `recipe` to prepare your predictors.
3. Fit three models on the training data:
   - a logistic regression;
   - a **random forest**; and
   - a **boosted tree** model.
4. **Tune** the random forest and boosted tree with 5- or 10-fold cross-validation, and compare all three models by cross-validated ROC AUC. Which do you choose?
5. Evaluate your chosen model on the test data:
   1. Report the ROC AUC and show the ROC curve.
   2. Show a calibration plot. Are the predicted probabilities trustworthy?
   3. Choose a classification threshold for the use you described in step 1, justify it, and report the confusion matrix, sensitivity, specificity and positive predictive value.
6. Show the **variable importance** for your chosen model. Explain why importance isn't the same as a causal effect.
7. Compare the model's performance across two or more groups (for example, by race and ethnicity or sex). Does it perform equally well for everyone? What would the consequences be if it didn't?
8. These models don't use the survey design. What population does your model's performance describe, and how would you adjust your evaluation to describe the population the survey represents?

---

## Assignment Sequence at a Glance

1. **Reproducible workflow:** Git, GitHub, renv, and reading your survey and its design variables.
2. **Survey statistics:** descriptive analysis with and without the survey design and weights, design effects.
3. **Binary regression:** logistic and probit regression, odds ratios, predicted probabilities and average marginal effects.
4. **Nested models and prediction:** KHB comparisons, interactions, stratification, cross-validation, discrimination and calibration.
5. **Ordinal/multinomial models:** alternative logit specifications, the proportional odds assessment and predicted probabilities.
6. **Count data models:** Poisson, negative binomial, zero-inflated and hurdle models, dispersion and offsets.
7. **Decomposition:** Kitagawa and Oaxaca-Blinder decompositions, and the choice of reference.
8. *(No Homework 8: spring break.)*
9. **Missing data:** missingness patterns, simple imputation, multiple imputation with the survey design.
10. **Longitudinal models:** GEE, fixed effects and within-between models.
11. **Splines and GAMs:** nonlinear relationships and choosing flexibility.
12. **Multilevel models I:** ICC, contextual variables, centering, random slopes and level-specific weights.
13. **Multilevel models II:** GLMMs for binary outcomes and growth curve models.
14. **Causal inference:** DAGs, propensity score weighting, balance and E-values.
15. **Machine learning:** random forests, boosted trees, tuning, calibration and performance across groups.
