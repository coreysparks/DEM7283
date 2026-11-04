/**
 * Hierarchical Logistic Regression (Multilevel)
 * A Bernoulli GLMM with logistic link: fixed effects for individual-level
 * predictors + random intercepts grouped by clusters.
 * Non-centered parameterization avoids the funnel geometry and
 * divergent transitions from a centered normal(0, sigma_u) on u.
 * See Gelman (2006) for Cauchy priors; Stan Ref. Manual for syntax details.
 */
data {
    int<lower=1> J;        // number of clusters (must be >= 1)
    int<lower=0> N;        // number of observations
    int<lower=0> K;        // number of predictors in X (incl. intercept col)
    array[N] int<lower=1, upper=J> z;  // cluster index for obs n
    matrix[N, K] X;        // design matrix (column 1 = intercept)
    array[N] int<lower=0, upper=1> y;  // binary outcome: 0 or 1
}

parameters {
    vector[K] beta;        // fixed-effects coefficients
    real<lower=0> sigma_u;  // cluster-level SD for random intercepts
    vector[J] u_raw;       // non-centered cluster deviations
}

transformed parameters {
    vector[J] u = sigma_u * u_raw;  // cluster deviations on logit scale
}

model {
    beta ~ normal(0, 2.5);  // weakly informative priors
    sigma_u ~ cauchy(0, 2.5); // half-Cauchy (>=0 from bound; Gelman 2006)
    u_raw ~ normal(0, 1);   // standard-Normal on non-centered deviations
    y ~ bernoulli_logit_glm(X, u[z], beta);
}

generated quantities {
    array[N] real log_lik;
    array[N] int y_rep;
    for (n in 1:N) {
        log_lik[n] = bernoulli_logit_lpmf(y[n] | X[n,] * beta + u[z[n]]);
        y_rep[n] = bernoulli_logit_rng(X[n,] * beta + u[z[n]]);
    }
}
