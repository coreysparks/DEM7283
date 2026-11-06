// DEM 5283/7283 course flyer, Spring 2027
// Build: quarto typst compile flyer/DEM7283_flyer_sp2027.typ
// Figures come from flyer/make_flyer_figures.R

#let midnight = rgb("#032044")
#let orange = rgb("#F15A22")
#let orange-a11y = rgb("#D3430D")
#let river-mist = rgb("#C8DCFF")
#let limestone = rgb("#F8F4F1")
#let concrete = rgb("#EBE6E2")

#set page(paper: "us-letter", margin: 0pt)
#set text(font: ("Helvetica Neue", "Helvetica", "Arial"), size: 10.5pt, fill: midnight)
#set par(leading: 0.5em, spacing: 0.7em, justify: false)

// Header band, stripe and details strip, stacked with no gaps
#stack(dir: ttb,
block(width: 100%, fill: midnight, inset: (x: 0.7in, top: 0.38in, bottom: 0.26in))[
  #text(fill: orange, weight: "bold", size: 11pt, tracking: 0.12em)[COURSE ANNOUNCEMENT · SPRING 2027]
  #v(0.08in)
  #text(fill: white, weight: "bold", size: 28pt)[Statistics for Demographic Data II]
  #v(0.06in)
  #text(fill: river-mist, size: 15pt)[DEM 5283/7283 · Department of Sociology and Demography]
],
block(width: 100%, height: 5pt, fill: orange),
block(width: 100%, fill: limestone, inset: (x: 0.7in, y: 0.12in))[
  #set text(size: 10.5pt)
  #grid(columns: (1.35fr, 1.1fr, 1.2fr, 0.6fr), column-gutter: 12pt,
    [*When* \ Thursdays, 6:00--8:45 PM],
    [*Where* \ UTSA Main Campus],
    [*Instructor* \ Dr. Corey S. Sparks],
    [*CRNs* \ 5283: 40173 \ 7283: 40174],
  )
])

#block(inset: (x: 0.7in, top: 0.14in))[
  #text(size: 10.5pt)[
    This course is a hands-on tour of the regression models population researchers actually use. You'll learn how to analyze complex survey data correctly, fit and interpret models for binary, ordinal, count, longitudinal and multilevel outcomes, and present the results in terms your audience cares about. Every method is taught with real demographic and health survey data, from the BRFSS and ECLS-K to the American Community Survey, and every analysis is built in a reproducible workflow you can carry into your own thesis or dissertation.
  ]

  #v(0.1in)
  #grid(columns: (1.15fr, 1fr), column-gutter: 0.3in,
    [
      #text(fill: orange-a11y, weight: "bold", size: 12.5pt)[What you'll learn] \
      #set list(marker: text(fill: orange)[▪], spacing: 0.4em)
      - Complex survey design, weights and replicate variance
      - Logit and probit models, predicted probabilities and marginal effects
      - Ordinal, multinomial and count models for rates
      - Kitagawa and Oaxaca-Blinder decomposition
      - Multiple imputation for missing data
      - Longitudinal models: GEE and fixed effects
      - Splines and generalized additive models
      - Multilevel and growth curve models
      - Causal inference with propensity score weighting
      - Tree-based machine learning with tidymodels
    ],
    [
      #text(fill: orange-a11y, weight: "bold", size: 12.5pt)[Who should take it] \
      Graduate students in demography, sociology, public health, economics, social work, education, geography and related fields who work with survey or population data.

      #v(0.06in)
      #text(fill: orange-a11y, weight: "bold", size: 12.5pt)[Prerequisites] \
      Graduate standing and a course in statistics through linear regression, or consent of the instructor.

      #v(0.06in)
      #text(fill: orange-a11y, weight: "bold", size: 12.5pt)[Software] \
      Everything is done in R, which is free. We start in week 1 with setup and a reproducible workflow in Quarto and Git.
    ],
  )

  #v(0.12in)
  #grid(columns: (1fr, 1fr), column-gutter: 0.2in,
    image("fig_growth.png", width: 100%),
    image("fig_health.png", width: 100%),
  )
]

// Footer
#place(bottom, block(width: 100%, fill: midnight, inset: (x: 0.7in, y: 0.2in))[
  #set text(fill: white, size: 11pt)
  #grid(columns: (1fr, auto),
    [*Questions?* Email Dr. Sparks at #text(fill: river-mist)[corey.sparks\@utsa.edu]],
    align(right)[#text(fill: river-mist)[github.com/coreysparks/DEM7283]],
  )
])
