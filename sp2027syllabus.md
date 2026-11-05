---
title: "DEM 5283/7283: Statistics for Demographic Data II"
subtitle: "Course Syllabus, Spring 2027"
author: "Corey S. Sparks, PhD"
bibliography: references.bib
link-citations: true
format:
  pdf:
    documentclass: article
    geometry: margin=1in
    colorlinks: true
    toc: false
---

# Course information

**Course:** DEM 5283/7283, Statistics for Demographic Data II\
**Credit hours:** 3\
**Modality:** Traditional in-person\
**Meeting time:** Thursdays, 6:00--8:45 PM\
**Location:** [Room TBD]\
**Dates:** January 21, 2027 to May 6, 2027

**Prerequisite:** Statistics for Demographic Data I, or an equivalent graduate course in linear regression, or consent of the instructor.

## Course description

This course is an in-depth treatment of the generalized linear model framework as demographers use it, including models for binary, ordinal, multinomial and count outcomes, models for longitudinal and multilevel data, and nonlinear regression with splines and GAMs. Model fit, model comparison and regression diagnostics are covered for each method. Students are also introduced to the analysis of complex survey data, decomposition methods, multiple imputation, the foundations of causal inference, tree-based machine learning, and a reproducible research workflow. Every method is illustrated with demographic survey data and applied examples from real research.

## Learning objectives

By the end of the course, you will be able to:

1. **Analyze complex survey data correctly.** Specify a survey design with weights, strata and clusters (or replicate weights), and produce estimates and standard errors that describe the population rather than the sample.
2. **Choose and fit the right model for the outcome.** Fit and interpret models for binary, ordinal, multinomial, count, longitudinal and multilevel data, and explain the results on the scale your audience cares about, using predicted probabilities and average marginal effects.
3. **Compare, decompose and diagnose models.** Compare nested models correctly, decompose differences between groups, assess model fit, and handle missing data with multiple imputation.
4. **Reason carefully about causes and predictions.** Draw and use a causal diagram, estimate effects with propensity score weighting, assess sensitivity to unmeasured confounding, and tell when a prediction model is and is not the right tool.
5. **Work reproducibly.** Carry out a complete analysis in R with Quarto, renv and Git, so that someone else can run your files and get the same numbers.

# Instructor

**Instructor:** Corey S. Sparks, PhD\
**Department:** Demography\
**Email:** corey.sparks@utsa.edu\
**Office:** MB 2.248J\
**Office hours:** Thursdays, 3:00--5:00 PM, or by appointment (email me to set one up)

Email is the best way to reach me. I'll usually answer within one business day. Put "DEM 7283" in the subject line so your message doesn't get lost among the rest.

# Software

We use R for everything in this course, through [Positron](https://positron.posit.co/download). Please install the current release of R (4.6.2 as of this writing), Positron and Git before the first class. On Windows, also install [Rtools](https://cran.r-project.org/bin/windows/Rtools/), which you'll need for week 12.

To install the packages we'll use this semester, paste this line into the Positron console:

```r
source("https://raw.githubusercontent.com/coreysparks/DEM7283/master/install_first_7283.R")
```

The script skips anything you already have, so it's safe to run again if it gets interrupted. All the course materials, data and exercises are in the course repository at <https://github.com/coreysparks/DEM7283>. We'll go over the setup, including `renv` and Git, in the first class.

# Course materials

There is no single textbook that covers everything we do, so readings come from several books and journal articles. The weekly readings are listed in the schedule below, and the full citations are at the end of this syllabus.

| Title | Author | ISBN | Status |
|---|---|---|---|
| *Statistical Methods for Categorical Data Analysis*, 2nd ed. | Powers and Xie | 9780123725622 | Required |
| [*Exploring Complex Survey Data Analysis Using R*](https://tidy-survey-r.github.io/tidy-survey-book/) | Zimmer, Powell and Velásquez | 9781032302867 | Recommended |
| [*Regression and Other Stories*](https://avehtari.github.io/ROS-Examples/) | Gelman, Hill and Vehtari | 9781107676510 | Recommended |
| [*Extending the Linear Model with R*, 2nd ed.](https://julianfaraway.github.io/faraway/ELM/) | Faraway | 9781498720960 | Recommended |
| [*Tidy Modeling with R*](https://www.tmwr.org/) | Kuhn and Silge | 9781492096481 | Recommended |
| *Multilevel Modeling* | Luke | 9781412985147 | Recommended |
| *Missing Data* | Allison | 9780761916727 | Recommended |

Several excellent books are free online, and I'll point you to chapters from them:

- *R for Data Science*, 2nd ed. [@wickham_r4ds2023]: <https://r4ds.hadley.nz>
- *Flexible Imputation of Missing Data*, 2nd ed. [@vanbuuren2018]: <https://stefvanbuuren.name/fimd>
- *An Introduction to Statistical Learning* [@james2021]: <https://www.statlearning.com>
- *Causal Inference: What If* [@hernan_robins2020]: <https://miguelhernan.org/whatifbook>

Journal articles are available through the [UTSA Libraries](https://lib.utsa.edu).

# Assessments and grading

| Component | Weight |
|---|---|
| Homework (weekly exercises) | 60% |
| Final paper proposal | 10% |
| Final paper presentation | 10% |
| Final paper | 20% |
| **Total** | **100%** |

**Homework (60%).** Each week's materials end with a set of exercises, and those exercises are the homework. There are 14 sets (weeks 1--7 and 9--15). I drop your lowest score, and the remaining 13 count equally. Each homework is a Quarto document that renders from top to bottom without errors. Submit the rendered HTML file, published with Posit Publisher, and a link to the GitHub repository that holds your homework, through Canvas. Homework is due before class one week after it's assigned. I grade on whether the code runs and is correct, and just as much on whether your written interpretation is correct and says what the numbers mean.

**Final paper (40% total).** The final paper is an original analysis of demographic data using one or more of the methods from this course. It should read like a short research article: a research question and its motivation, a brief literature review, data and methods, results, and a discussion. I expect about 15--20 double-spaced pages, plus tables and figures, along with the Quarto document and code that produce every number in the paper. The paper has three graded parts:

- **Proposal (10%), due February 25 (week 6).** One to two pages: your research question, the data you'll use, the outcome and key predictors, and the model you expect to fit. Talk to me before then if you're unsure about any of it.
- **Presentation (10%), May 6 (week 16).** A 15-minute presentation of your analysis and results, followed by questions from the class.
- **Paper (20%), due May 6 (week 16).** The written paper and the files that reproduce it.

## Grade distribution

| Letter grade | Grade range |
|---|---|
| A | 90--100 |
| B | 80--89 |
| C | 70--79 |
| D | 60--69 |
| F | 0--59 |

# Course schedule

Readings should be done before the class meeting in the week they're listed. The materials for each week are chapters of the course book, <https://coreysparks.github.io/DEM7283/>, and the source files are in the `chapters/` folder of the course repository.

| Week | Date | Topic | Due |
|:---:|---|---|---|
| 1 | Jan 21 | Course introduction; reproducible workflow with Quarto, renv and Git | |
| 2 | Jan 28 | Complex survey design, weights, replicate variance | Homework 1 |
| 3 | Feb 4 | Binary outcomes: logit and probit, predicted probabilities, average marginal effects | Homework 2 |
| 4 | Feb 11 | Comparing nested logit models (KHB); prediction and cross validation | Homework 3 |
| 5 | Feb 18 | Ordinal and multinomial models | Homework 4 |
| 6 | Feb 25 | Counts and rates: Poisson, negative binomial, offsets, zero inflation | Homework 5; **paper proposal** |
| 7 | Mar 4 | Decomposition analysis: Kitagawa and Oaxaca-Blinder | Homework 6 |
| 8 | Mar 11 | **Spring break, no class** | |
| 9 | Mar 18 | Missing data and multiple imputation with survey designs | Homework 7 |
| 10 | Mar 25 | Longitudinal models: GEE, fixed effects, within-between models | Homework 9 |
| 11 | Apr 1 | Nonlinear regression: splines and GAMs | Homework 10 |
| 12 | Apr 8 | Multilevel models I: centering, random slopes, level-specific weights | Homework 11 |
| 13 | Apr 15 | Multilevel models II: GLMMs, growth curves, age-period-cohort models | Homework 12 |
| 14 | Apr 22 | Causal inference foundations: DAGs and propensity score weighting | Homework 13 |
| 15 | Apr 29 | Tree-based machine learning with tidymodels | Homework 14 |
| 16 | May 6 | **Final paper presentations** | Homework 15; **final paper** |

Homework is numbered by the week it's assigned, so there is no Homework 8.

## Weekly readings

**Week 1. Reproducible workflow.** @wickham_r4ds2023, the chapters on workflow and projects; @wickham2019.

**Week 2. Complex survey design.** @zimmer2024, chapters 2 and 10; @kish1992; @cdc_smart2024.

**Week 3. Logit and probit.** @mood2010; @breen2018.

**Week 4. Nested logits and prediction.** @allison1999; @khb2012; @lumley_scott2015; @kuhn_silge2022, the chapters on resampling.

**Week 5. Ordinal and multinomial models.** @long_freese2014, the chapters on ordinal and nominal outcomes.

**Week 6. Counts and rates.** @zeileis2008; @cameron_trivedi2013, chapters 1--3; @lambert1992.

**Week 7. Decomposition.** @kitagawa1955; @oaxaca1973; @jann2008; @fairlie2005.

**Week 9. Missing data.** @vanbuuren2018, chapters 1--2; @vonhippel2020; @reiter2006.

**Week 10. Longitudinal models.** @allison2009; @bell_jones2015; @liang_zeger1986.

**Week 11. Splines and GAMs.** @wood2017, chapters 4--5; @harrell2015, chapter 2.

**Week 12. Multilevel models I.** @enders_tofighi2007; @rabe_hesketh_skrondal2006.

**Week 13. Multilevel models II.** @austin_merlo2017; @singer_willett2003, chapters 3--4; @fosse_winship2019; @bell_jones2014.

**Week 14. Causal inference.** @hernan_robins2020, chapters 1--7; @austin2011; @elwert_winship2014; @vanderweele_ding2017.

**Week 15. Machine learning.** @james2021, chapter 8; @kuhn_silge2022, chapters 5--7; @molina_garip2019; @obermeyer2019.

# Course policies

## Attendance and participation

I expect you to come to every class. Most of each meeting is working through the week's analysis together, and that's hard to make up from the slides. If you have to miss a class, let me know beforehand when you can, and then work through that week's materials on your own and come see me with questions.

Questions in class are always welcome, and the ones you think are basic are usually the ones half the room was wondering about. I expect everyone to treat classmates with respect, in disagreements about methods and in everything else.

## Late work

Homework turned in up to one week late loses 10%. After that I won't accept it unless we've made an arrangement in advance, and the dropped homework is there for the week when something goes wrong. The final paper and presentation can't be late, because they fall at the end of the semester. If you have a serious problem (illness, a family emergency), talk to me as early as you can, and we'll work something out.

## Collaboration

You're welcome to work with classmates on the homework, and I encourage it. But each of you writes and submits your own code and your own answers. If you worked with someone, put their names at the top of your homework. The final paper is individual work.

## Guidelines for the use of generative AI

You may use generative AI tools to help you write or debug R code. They are genuinely useful for explaining an error message or a block of code, and they also make up function arguments with total confidence, so run what they give you and read the help page for anything you don't recognize.

Everything you write in prose must be your own work, in your own words. That includes the interpretation of results in your homework, the paper proposal, the final paper and your presentation. Never paste restricted or confidential data (for example, data covered by a data use agreement) into an AI tool.

## Instructor-initiated drops

Academic freedom[^1] is a cornerstone of the University. Academic freedom in its teaching aspect is fundamental for the protection of the rights of the teacher in teaching and of the student to freedom in learning.[^2] Each faculty member is entitled to full freedom in the classroom discussing the subject that the faculty member teaches.[^3] The University of Texas at San Antonio will not penalize or discipline members of the faculty because of their exercise of academic freedom.

Along with this freedom comes responsibility. It is the responsibility of faculty members to ensure that topics taught are related to the classroom subject. Students should be free to take reasoned exception to the data or views offered in any course of study and to reserve judgment about matters of opinion, but they are responsible for learning the content of any course of study for which they are enrolled.[^4] It is not the proper role of the university or any outside agency to attempt to shield individuals from ideas and opinions they find unwelcome, disagreeable, or even deeply offensive.[^5] Engaging with new ideas and perspectives helps students grow intellectually and is beneficial to the educational process.

[^1]: Statement adapted from Texas A&M University's Syllabus Statement Regarding Academic Freedom.
[^2]: 1940 Statement of Principles on Academic Freedom and Tenure.
[^3]: Board of Regents Rule 31004; HOP Policy 4.02.
[^4]: American Association of University Professors, Joint Statement on Rights and Freedoms of Students.
[^5]: The Chicago Statement.

## Our commitment to inclusivity

The University of Texas at San Antonio, a Hispanic Serving Institution situated in a global city that has been a crossroads of peoples and cultures for centuries, values diversity and inclusion in all aspects of university life. As an institution expressly founded to advance the education of Mexican Americans and other underserved communities, our university is committed to promoting access for all. UTSA, a premier public research university, fosters academic excellence through a community of dialogue, discovery and innovation that embraces the uniqueness of each voice.

## Syllabus changes

The syllabus is subject to change at the instructor's discretion. Any changes or corrections to the course materials, assignment dates or other policies will be announced in class and on Canvas ahead of time. You are responsible for checking Canvas for updates to the syllabus.

# Essential student information

- **Important:** Bookmark and visit the [Common Syllabus Information](https://provost.utsa.edu/syllabus.html) page (<https://provost.utsa.edu/syllabus.html>). It has information on counseling services, minor medical issues, supplemental instruction, tutoring, academic success coaching, sexual harassment and sexual misconduct, campus safety and emergency preparedness, and the Roadrunner Creed.
- **Disability accommodations:** UTSA provides reasonable accommodations to students through Student Disability Services. For eligibility, policies and requirements, visit <https://www.utsa.edu/disability> or call (210) 458-4157.
- **Academic integrity:** You are responsible for making sure your work is consistent with UTSA's standards for academic integrity. Review Section 203 of the UTSA Student Code of Conduct for those standards.
- **Student services:** UTSA provides many services for students, from counseling to tutoring to a food pantry. See Student Affairs Programs and Services and Student Success for more information.
- **Libraries:** The [UTSA Libraries](https://lib.utsa.edu) have journals, research tutorials and technology you can borrow, and a librarian for your department.
- **Technical support:** For technical requirements, support and resources, see Academic Innovation's Student Technical Support page.

# References

::: {#refs}
:::
