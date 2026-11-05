# Oaxaca-Blinder and Fairlie decompositions for complex survey data.
#
# Source this file with source(here::here("R", "svy_oaxaca.R")). Then run
# svy_oaxaca_help() to read the documentation below as a help page.

# Remember where this file is, so svy_oaxaca_help() can find its documentation.
.svy_oaxaca_file <- local({
  path <- NULL
  for (i in rev(seq_len(sys.nframe()))) {
    of <- sys.frame(i)$ofile           # set by source() while the file runs
    if (!is.null(of)) { path <- normalizePath(of); break }
  }
  path
})

#' Oaxaca-Blinder and Fairlie decompositions for survey data
#'
#' Splits the gap in a mean, or in a proportion, between two groups into a
#' part *explained* by differences in the groups' characteristics and a part
#' that is *unexplained*. It uses the survey weights for the estimates and the
#' design's replicate weights for the standard errors.
#'
#' @details
#' **Two kinds of outcome.** With `family = gaussian()` (the default) this is
#' the linear Oaxaca-Blinder decomposition (Oaxaca 1973; Blinder 1973). With
#' `family = binomial()` it is the Fairlie (2005) decomposition for a binary
#' outcome. Both use the same counterfactual. The explained part is
#'
#' \deqn{\overline{F(X_A\beta^*)} - \overline{F(X_B\beta^*)}}{mean_A F(X beta*) - mean_B F(X beta*)}
#'
#' where \eqn{\beta^*}{beta*} are the reference coefficients, \eqn{F} is the
#' inverse link function, and each bar is a weighted mean over one group. In a
#' linear model \eqn{F} does nothing, and this is
#' \eqn{(\bar X_A - \bar X_B)\beta^*}{(Xbar_A - Xbar_B) beta*}. The unexplained
#' part is the gap minus the explained part.
#'
#' **The detailed explained part.** In the linear case, each variable's
#' contribution is \eqn{(\bar X_{kA} - \bar X_{kB})\beta^*_k}{(Xbar_kA - Xbar_kB) beta*_k},
#' summed over the columns that belong to it. In the binary case, the
#' explained part is shared out in proportion to those same linear
#' contributions, using the logit coefficients (Yun 2004). Either way, the
#' detail rows add up to the explained total. The unexplained part is reported
#' only as a total, because splitting it by categorical variables depends on
#' which category is omitted (Oaxaca and Ransom 1999).
#'
#' **Standard errors.** The whole decomposition is computed once with the
#' full-sample weights and again with each replicate weight, and the results
#' are combined with the design's own variance formula through
#' [survey::withReplicates()]. If `design` is a linearization design (from
#' [survey::svydesign()]), it is first turned into bootstrap replicates with
#' [survey::as.svrepdesign()], and a message says so. Run [set.seed()] first
#' to make those repeatable.
#'
#' **Negative weights.** The regressions are fit with weighted least squares
#' (linear) or iteratively reweighted least squares (binary), written out
#' rather than with [lm()] or [glm()], because those refuse negative weights
#' and a few ACS replicate weights are negative. The estimates are the same.
#'
#' @param formula The regression model, `outcome ~ predictors`, written as you
#'   would for [survey::svyglm()]. It is fit separately to each group.
#' @param group The variable that defines the two groups, as a one-sided
#'   formula (`~female`) or a string (`"female"`).
#' @param design A survey design: from [survey::svydesign()],
#'   [survey::svrepdesign()], [srvyr::as_survey_design()] or
#'   [srvyr::as_survey_rep()]. Subset it to the analysis sample with
#'   `subset()` or `filter()` first.
#' @param groups The two values of `group` to compare, in the order
#'   `c(A, B)`. The gap is A minus B. By default, the two values in sorted
#'   order, so for a 0/1 variable the gap is group 0 minus group 1. Use this to
#'   flip the gap, or to pick two groups out of more.
#' @param reference Whose coefficients are the benchmark \eqn{\beta^*}{beta*}:
#'   * `"pooled"` (default): a regression on both groups with a group
#'     indicator, which is then left out (Jann 2008; Fortin et al. 2011).
#'   * `"pooled_no_indicator"`: a regression on both groups without one
#'     (Neumark 1988).
#'   * One of the group values, such as `0` or `"Hispanic"`: that group's own
#'     coefficients (Oaxaca 1973).
#' @param family `gaussian()` (default) for a continuous outcome, or
#'   `binomial()` for a 0/1 outcome. `quasibinomial()` gives the same result
#'   as `binomial()`, and `binomial(link = "probit")` also works.
#' @param detail A named list saying how to group the model's terms in the
#'   detailed explained part. Each name becomes a row of the output, and each
#'   value is one or more term labels exactly as they appear in the formula,
#'   such as `list(age = c("AGE", "I(AGE^2)"), education = "educ")`. Terms you
#'   leave out don't get a row (they're still in the model and in the explained
#'   total). By default, each term gets its own row.
#' @param replicates The number of bootstrap replicates to make when `design`
#'   is a linearization design. Ignored for replicate designs.
#' @param conf.level The confidence level for `lower` and `upper`.
#' @param se `FALSE` skips the replicates and returns point estimates only.
#'   That's much faster, for trying out models.
#'
#' @return An object of class `"svy_oaxaca"`. Printing it shows a summary and
#'   the table of estimates. It is a list with:
#'   * `estimates`: a data frame with one row per component. `part` is
#'     `"overall"` for the gap, explained and unexplained parts and
#'     `"explained detail"` for the rows that split the explained part.
#'     `estimate` is in the units of the outcome (a difference in means, or in
#'     proportions). `se`, `lower` and `upper` are the standard error and
#'     confidence interval, and `share_of_gap` is the estimate divided by the
#'     gap. Get it with `as.data.frame()`.
#'   * `group`, `groups`, `reference`, `family`: the settings used.
#'   * `n`: the unweighted number of people in each group.
#'   * `replicates`, `replicate_type`: how the standard errors were computed.
#'
#' @references
#' Blinder, A. S. (1973). Wage discrimination: Reduced form and structural
#' estimates. *Journal of Human Resources*, 8(4), 436-455.
#'
#' Fairlie, R. W. (2005). An extension of the Blinder-Oaxaca decomposition
#' technique to logit and probit models. *Journal of Economic and Social
#' Measurement*, 30(4), 305-316.
#'
#' Fortin, N., Lemieux, T., and Firpo, S. (2011). Decomposition methods in
#' economics. In *Handbook of Labor Economics*, vol. 4A, 1-102.
#'
#' Jann, B. (2008). The Blinder-Oaxaca decomposition for linear regression
#' models. *The Stata Journal*, 8(4), 453-479.
#'
#' Neumark, D. (1988). Employers' discriminatory behavior and the estimation
#' of wage discrimination. *Journal of Human Resources*, 23(3), 279-295.
#'
#' Oaxaca, R. (1973). Male-female wage differentials in urban labor markets.
#' *International Economic Review*, 14(3), 693-709.
#'
#' Oaxaca, R. L., and Ransom, M. R. (1999). Identification in detailed wage
#' decompositions. *Review of Economics and Statistics*, 81(1), 154-157.
#'
#' Yun, M.-S. (2004). Decomposing differences in the first moment.
#' *Economics Letters*, 82(2), 275-280.
#'
#' @seealso [svy_oaxaca_help()] to show this page. The `oaxaca` package does
#'   the linear decomposition without survey weights.
#'
#' @examples
#' library(survey)
#' data(api)   # California schools, in the survey package
#'
#' # A stratified sample of schools. The gap in test scores (api00) between
#' # schools that won an award and schools that didn't.
#' dstrat <- svydesign(ids = ~1, strata = ~stype, weights = ~pw,
#'                     fpc = ~fpc, data = apistrat)
#' set.seed(1)
#' fit <- svy_oaxaca(api00 ~ meals + ell + emer, group = ~awards,
#'                   design = dstrat, groups = c("Yes", "No"))
#' fit
#' as.data.frame(fit)
#'
#' # The same, with the award-winning schools' coefficients as the reference
#' svy_oaxaca(api00 ~ meals + ell + emer, group = ~awards, design = dstrat,
#'            groups = c("Yes", "No"), reference = "Yes", se = FALSE)
#'
#' # A binary outcome: did the school score 700 or more?
#' apistrat$high <- as.numeric(apistrat$api00 >= 700)
#' dstrat <- svydesign(ids = ~1, strata = ~stype, weights = ~pw,
#'                     fpc = ~fpc, data = apistrat)
#' svy_oaxaca(high ~ meals + ell + emer, group = ~awards, design = dstrat,
#'            groups = c("Yes", "No"), family = binomial(), se = FALSE)
#'
#' \dontrun{
#' # The week 7 wage gap, with the ACS replicate weights
#' acs_rep <- wages |>
#'   srvyr::as_survey_rep(weights = PERWT, repweights = matches("REPWTP[0-9]+"),
#'                        type = "JK1", scale = 4 / 80, rscales = rep(1, 80),
#'                        mse = TRUE)
#' svy_oaxaca(lnwage ~ educ + AGE + I(AGE^2) + race_eth + occ,
#'            group = ~female, design = acs_rep,
#'            detail = list(education = "educ", age = c("AGE", "I(AGE^2)"),
#'                          race_eth = "race_eth", occupation = "occ"))
#' }
svy_oaxaca <- function(formula, group, design, groups = NULL,
                       reference = "pooled", family = gaussian(),
                       detail = NULL, replicates = 100, conf.level = 0.95,
                       se = TRUE) {
  if (is.character(family)) family <- get(family, mode = "function")()
  if (is.function(family)) family <- family()
  if (!inherits(design, "survey.design") && !inherits(design, "svyrep.design")) {
    stop("`design` must be a survey design, from svydesign(), svrepdesign() or srvyr.")
  }

  # 1. Replicate design ----------------------------------------------------
  if (se && !inherits(design, "svyrep.design")) {
    message("Converting the design to ", replicates, " bootstrap replicates ",
            "for standard errors. Use set.seed() first to make them repeatable.")
    design <- survey::as.svrepdesign(design, type = "subbootstrap",
                                     replicates = replicates)
  }
  data <- as.data.frame(design$variables)

  # 2. Groups --------------------------------------------------------------
  gname <- if (inherits(group, "formula")) all.vars(group) else group
  if (length(gname) != 1 || !gname %in% names(data)) {
    stop("`group` must name one variable in the design.")
  }
  g <- data[[gname]]
  if (is.null(groups)) groups <- sort(unique(g[!is.na(g)]))
  if (length(groups) != 2) {
    stop("`", gname, "` has ", length(groups), " values. Use `groups = c(A, B)` ",
         "to choose two, or subset the design first.")
  }

  # 3. Analysis sample and design matrix -------------------------------------
  # Rows with a positive full-sample weight, in one of the two groups, and no
  # missing values in the model variables.
  pw <- if (inherits(design, "svyrep.design")) as.vector(design$pweights)
        else as.vector(stats::weights(design))
  cc <- stats::complete.cases(stats::model.frame(formula, data, na.action = stats::na.pass))
  ok <- pw > 0 & g %in% groups & cc
  data_ok <- droplevels(data[ok, , drop = FALSE])   # drop empty factor levels
  mf <- stats::model.frame(formula, data_ok)
  tt <- attr(mf, "terms")
  X <- stats::model.matrix(tt, mf)
  y <- stats::model.response(mf)
  if (is.factor(y) || is.logical(y)) y <- as.numeric(y == max(y))
  a <- data_ok[[gname]] == groups[1]

  ref_type <- if (identical(reference, "pooled")) "pooled"
    else if (identical(reference, "pooled_no_indicator")) "pooled_no_indicator"
    else if (length(reference) == 1 && reference %in% groups)
      if (reference == groups[1]) "A" else "B"
    else stop("`reference` must be \"pooled\", \"pooled_no_indicator\", or one of the group values (",
              paste(groups, collapse = ", "), ").")

  # A dummy with nobody in one group can't be estimated in that group's model.
  for (k in 1:2) {
    idx <- if (k == 1) a else !a
    empty <- colnames(X)[colSums(X[idx, , drop = FALSE] != 0) == 0]
    if (length(empty) > 0) {
      stop("Nobody in group ", gname, " = ", groups[k], " has: ",
           paste(empty, collapse = ", "),
           ". Collapse these categories or drop them before decomposing.")
    }
  }

  # 4. Detailed explained part: which columns of X go with which row ----------
  labels <- attr(tt, "term.labels")
  assign <- attr(X, "assign")
  if (is.null(detail)) detail <- stats::setNames(as.list(labels), labels)
  bad <- setdiff(unlist(detail), labels)
  if (length(bad) > 0) {
    stop("Not term labels in the formula: ", paste(bad, collapse = ", "),
         ". The term labels are: ", paste(labels, collapse = ", "))
  }
  detail_cols <- lapply(detail, function(terms) which(assign %in% match(terms, labels)))

  # 5. The decomposition, as a function of one set of weights ------------------
  theta <- function(w, data) {
    decompose_once(X, y, a, as.vector(w)[ok], family, ref_type, detail_cols)
  }
  full <- theta(pw, data)
  if (anyNA(full)) stop("The model could not be fit with the full-sample weights.")
  if (se) {
    res <- survey::withReplicates(design, theta)
    est <- as.vector(res)
    se_est <- sqrt(diag(as.matrix(attr(res, "var"))))
  } else {
    est <- unname(full)
    se_est <- rep(NA_real_, length(full))
  }

  # 6. Results -------------------------------------------------------------
  z <- stats::qnorm(1 - (1 - conf.level) / 2)
  n_det <- length(detail_cols)
  estimates <- data.frame(
    part = c(rep("overall", 3), rep("explained detail", n_det)),
    component = names(full),
    estimate = est,
    se = se_est,
    lower = est - z * se_est,
    upper = est + z * se_est,
    share_of_gap = est / est[1],
    row.names = NULL
  )

  structure(
    list(estimates = estimates,
         call = match.call(),
         group = gname, groups = groups, reference = reference,
         family = family,
         n = c(sum(a), sum(!a)),
         replicates = if (se) ncol(as.matrix(design$repweights)) else 0,
         replicate_type = if (se) design$type else NA,
         conf.level = conf.level),
    class = "svy_oaxaca"
  )
}

# One decomposition with one set of weights (length = rows in the analysis
# sample). Returns NA for every component if a model can't be fit, which
# svrVar() then drops with a warning.
decompose_once <- function(X, y, a, w, family, ref_type, detail_cols) {
  out_names <- c("gap", "explained", "unexplained", names(detail_cols))
  keep <- w != 0             # bootstrap replicates leave some people out
  X <- X[keep, , drop = FALSE]; y <- y[keep]; a <- a[keep]; w <- w[keep]
  b <- !a

  b_a <- wfit(X[a, , drop = FALSE], y[a], w[a], family)
  b_b <- wfit(X[b, , drop = FALSE], y[b], w[b], family)
  b_ref <- switch(ref_type,
    A = b_a,
    B = b_b,
    pooled_no_indicator = wfit(X, y, w, family),
    pooled = {
      bp <- wfit(cbind(X, .group = as.numeric(a)), y, w, family)
      if (is.null(bp)) NULL else bp[colnames(X)]   # drop the group indicator
    })
  if (is.null(b_a) || is.null(b_b) || is.null(b_ref)) {
    return(stats::setNames(rep(NA_real_, length(out_names)), out_names))
  }

  wmean <- function(v, wt) sum(v * wt) / sum(wt)
  gap <- wmean(y[a], w[a]) - wmean(y[b], w[b])
  # counterfactual means: each group's characteristics, reference coefficients
  cf_a <- wmean(family$linkinv(drop(X[a, , drop = FALSE] %*% b_ref)), w[a])
  cf_b <- wmean(family$linkinv(drop(X[b, , drop = FALSE] %*% b_ref)), w[b])
  explained <- cf_a - cf_b

  # detailed explained part: (Xbar_A - Xbar_B) * beta*, column by column
  xbar_a <- colSums(X[a, , drop = FALSE] * w[a]) / sum(w[a])
  xbar_b <- colSums(X[b, , drop = FALSE] * w[b]) / sum(w[b])
  lin <- (xbar_a - xbar_b) * b_ref
  det <- vapply(detail_cols, function(cols) sum(lin[cols]), numeric(1))
  # linear model: these already add up to `explained`. Otherwise use Yun's
  # weights, sharing out the explained part in proportion to them.
  if (!is_linear(family)) det <- det / sum(lin) * explained

  stats::setNames(c(gap, explained, gap - explained, det), out_names)
}

is_linear <- function(family) family$family == "gaussian" && family$link == "identity"

# Weighted least squares (linear) or IRLS (GLM). Solves (X'WX) b = X'Wz
# directly, so negative weights are allowed. Returns NULL if the system is
# singular or the IRLS doesn't converge.
wfit <- function(X, y, w, family, maxit = 50, tol = 1e-10) {
  solve_wls <- function(z, ww) {
    tryCatch(drop(solve(crossprod(X, X * ww), crossprod(X, z * ww))),
             error = function(e) NULL)
  }
  if (is_linear(family)) return(solve_wls(y, w))

  mu <- (y + 0.5) / 2                      # same start as glm() for binomial
  eta <- family$linkfun(mu)
  dev_old <- Inf
  for (i in seq_len(maxit)) {
    d <- family$mu.eta(eta)
    z <- eta + (y - mu) / d
    beta <- solve_wls(z, w * d^2 / family$variance(mu))
    if (is.null(beta)) return(NULL)
    eta <- drop(X %*% beta)
    mu <- family$linkinv(eta)
    dev <- sum(family$dev.resids(y, mu, abs(w)) * sign(w))
    if (abs(dev - dev_old) / (abs(dev) + 0.1) < tol) return(beta)
    dev_old <- dev
  }
  NULL
}

print.svy_oaxaca <- function(x, digits = 4, ...) {
  model <- if (is_linear(x$family)) "Oaxaca-Blinder (linear)"
           else paste0("Fairlie (", x$family$family, ", ", x$family$link, " link)")
  ref <- switch(as.character(x$reference),
    pooled = "pooled model with a group indicator",
    pooled_no_indicator = "pooled model without a group indicator",
    paste0("coefficients of ", x$group, " = ", x$reference))
  cat(model, "decomposition with survey weights\n")
  grp <- as.character(x$groups)   # factors would print as numbers in cat()
  cat("Gap: ", x$group, " = ", grp[1], " (n = ", format(x$n[1], big.mark = ","),
      ") minus ", x$group, " = ", grp[2], " (n = ", format(x$n[2], big.mark = ","),
      ")\n", sep = "")
  cat("Reference coefficients:", ref, "\n")
  if (x$replicates > 0) {
    cat("Standard errors:", x$replicates, x$replicate_type, "replicates\n")
  } else {
    cat("Point estimates only (se = FALSE)\n")
  }
  cat("Detail rows (indented) split the explained part by variable.\n\n")
  tab <- x$estimates
  tab$part <- NULL
  num <- c("estimate", "se", "lower", "upper")
  tab[num] <- lapply(tab[num], function(v) formatC(v, format = "f", digits = digits))
  tab$share_of_gap <- formatC(tab$share_of_gap, format = "f", digits = 3)
  tab$component <- ifelse(x$estimates$part == "overall", tab$component,
                          paste0("  ", tab$component))   # indent the detail rows
  print(tab, row.names = FALSE, right = FALSE)
  invisible(x)
}

as.data.frame.svy_oaxaca <- function(x, ...) x$estimates


#' Show the documentation for svy_oaxaca()
#'
#' `svy_oaxaca()` comes from a file you `source()`, not from a package, so
#' `?svy_oaxaca` doesn't find it. This function reads the documentation
#' written at the top of `svy_oaxaca.R` and shows it as a help page.
#'
#' If the `roxygen2` package is installed, you get a formatted help page, in
#' the Viewer pane in RStudio or Positron, or in your web browser otherwise.
#' Without `roxygen2`, or with `format = "text"`, the documentation is printed
#' in the console.
#'
#' @param topic Which page to show: `"svy_oaxaca"` (default) or
#'   `"svy_oaxaca_help"`.
#' @param format `"html"` (default) for a help page, or `"text"` to print it
#'   in the console.
#' @param file The path to `svy_oaxaca.R`. You only need this if the function
#'   can't find the file on its own.
#'
#' @return The path to the HTML file, invisibly, or `NULL` for text.
#'
#' @examples
#' \dontrun{
#' svy_oaxaca_help()
#' svy_oaxaca_help(format = "text")
#' }
svy_oaxaca_help <- function(topic = c("svy_oaxaca", "svy_oaxaca_help"),
                            format = c("html", "text"), file = NULL) {
  topic <- match.arg(topic)
  format <- match.arg(format)

  # 1. Find the file the documentation lives in
  if (is.null(file)) file <- .svy_oaxaca_file
  if (is.null(file) || !file.exists(file)) {
    file <- file.path(if (requireNamespace("here", quietly = TRUE)) here::here() else ".",
                      "R", "svy_oaxaca.R")
  }
  if (!file.exists(file)) {
    stop("Can't find svy_oaxaca.R. Tell me where it is, for example ",
         "svy_oaxaca_help(file = \"R/svy_oaxaca.R\").")
  }
  src <- readLines(file, warn = FALSE)

  # 2. Without roxygen2, print the comments as plain text
  if (!requireNamespace("roxygen2", quietly = TRUE)) {
    if (format == "html") {
      message("Install roxygen2 for a formatted help page: install.packages(\"roxygen2\")")
    }
    print_roxygen_text(src, topic)
    return(invisible(NULL))
  }

  # 3. With roxygen2, build a real help page. roc_proc_text() turns the #'
  #    comments into R's help format (.Rd), the way it does for a package.
  topics <- roxygen2::roc_proc_text(roxygen2::rd_roclet(), paste(src, collapse = "\n"))
  rd_file <- tempfile(fileext = ".Rd")
  writeLines(format(topics[[paste0(topic, ".Rd")]]), rd_file)

  if (format == "text") {
    tools::Rd2txt(rd_file, options = list(underline_titles = FALSE))
    return(invisible(NULL))
  }

  # The viewer only shows files in the session's temporary folder
  dir <- file.path(tempdir(), "svy_oaxaca_help")
  dir.create(dir, showWarnings = FALSE)
  file.copy(file.path(R.home("doc"), "html", "R.css"), dir, overwrite = TRUE)
  writeLines(c(
    "body { color: #032044; }",                         # UTSA Midnight
    "h2, h3 { color: #032044; border-bottom: 2px solid #F15A22; }",
    "a { color: #265BF7; }",                            # Talavera Blue
    "pre, code { background: #F8F4F1; }"                # Limestone
  ), file.path(dir, "utsa.css"))
  html <- file.path(dir, paste0(topic, ".html"))
  tools::Rd2HTML(rd_file, out = html, stylesheet = c("R.css", "utsa.css"))

  viewer <- getOption("viewer")
  if (is.function(viewer)) viewer(html) else utils::browseURL(html)
  invisible(html)
}

# Fallback for svy_oaxaca_help(): print one roxygen block as plain text.
print_roxygen_text <- function(src, topic) {
  start <- grep(paste0("^", topic, " <- function"), src)
  if (length(start) == 0) stop("No documentation found for ", topic, ".")
  # the #' lines directly above the function
  i <- start[1] - 1
  while (i > 0 && grepl("^#'", src[i])) i <- i - 1
  block <- sub("^#' ?", "", src[(i + 1):(start[1] - 1)])
  # "@param x text" becomes "  x: text"; other tags become headings
  block <- sub("^@param ([^ ]+) ?", "  \\1: ", block)
  tags <- grepl("^@[a-z]+", block)
  block[tags] <- sub("^@([a-z]+) ?(.*)$", "\n\\U\\1\\E\n\\2", block[tags], perl = TRUE)
  cat(block, sep = "\n")
  invisible(NULL)
}
