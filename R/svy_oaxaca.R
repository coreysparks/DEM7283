# Oaxaca-Blinder and Fairlie decompositions for complex survey data.
#
# svy_oaxaca() splits the gap in a mean (or a proportion) between two groups
# into a part explained by differences in characteristics and an unexplained
# part, using survey weights, and gets standard errors from replicate weights.
#
#   * family = gaussian() gives the linear Oaxaca-Blinder decomposition.
#   * family = binomial() (or quasibinomial()) gives the Fairlie (2005)
#     decomposition for a binary outcome, with the detailed explained part
#     split using Yun's (2004) weights.
#
# Both use the same counterfactual: the explained part is
#
#   mean over A of F(X beta*)  -  mean over B of F(X beta*)
#
# where beta* are the reference coefficients and F is the inverse link. With a
# linear model F is the identity, and this is (Xbar_A - Xbar_B) beta*.
#
# Standard errors: if `design` is a replicate-weight design (svrepdesign(),
# srvyr::as_survey_rep()), the whole decomposition is recomputed with each
# replicate weight and combined with the design's own variance formula, via
# survey::withReplicates(). If `design` is a linearization design (svydesign()),
# it is first converted to a bootstrap replicate design with as.svrepdesign().
#
# The regressions are fit with weighted least squares / IRLS written out here
# rather than lm()/glm(), because lm() and glm() refuse negative weights and a
# few ACS replicate weights are negative. The estimates are identical.
#
# Arguments
#   formula     outcome ~ predictors, as in svyglm().
#   group       the grouping variable, as a one-sided formula (~female) or a
#               string ("female"). It must have exactly two values in the
#               analysis sample (or use `groups` to pick two).
#   design      a survey design object.
#   groups      the two group values, in order c(A, B). The gap is A minus B.
#               Default: the sorted unique values, so for a 0/1 variable the
#               gap is group 0 minus group 1.
#   reference   whose coefficients are the benchmark:
#                 "pooled"              pooled model with a group indicator
#                                       (default; Jann 2008, Fortin 2011)
#                 "pooled_no_indicator" pooled model without one (Neumark 1988)
#                 a group value         that group's own coefficients,
#                                       e.g. reference = 0
#   family      gaussian() (default), binomial() or quasibinomial().
#   detail      named list saying how to group terms in the detailed explained
#               part, using the term labels from the formula, e.g.
#               list(age = c("AGE", "I(AGE^2)"), education = "educ").
#               Default: one row per term.
#   replicates  number of bootstrap replicates when `design` is not already a
#               replicate design.
#   conf.level  confidence level for the intervals.
#   se          FALSE skips the replicates and returns point estimates only
#               (quick, for trying out models).
#
# Value: an object of class "svy_oaxaca". Print it for a summary, or use
# as.data.frame() to get the table of estimates.

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
  cat("Gap: ", x$group, " = ", x$groups[1], " (n = ", format(x$n[1], big.mark = ","),
      ") minus ", x$group, " = ", x$groups[2], " (n = ", format(x$n[2], big.mark = ","),
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
