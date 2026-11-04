data {
  int<lower=0> K; // number of covariates
  int<lower=1> N; // total observations
  int<lower=1> J; // number of census tracts
  int<lower=1> T; // number of time periods
  array[N] int<lower=1, upper=J> tract_id; // tract ID for each observation
  array[N] int<lower=1, upper=T> time_id; // time ID for each observation
  vector[N] y; // outcome variable
  matrix[N, K] X; // covariates (no intercept column)
}

parameters {
  real alpha; // global intercept
  vector[K] beta; // fixed effects coefficients
  vector[J] u_raw; // tract-level intercepts (raw)
  real<lower=-1, upper=1> phi; // AR(1) coefficient
  real<lower=0> sigma_u; // between-tract SD
  real<lower=0> sigma_e; // residual SD
}

transformed parameters {
  vector[J] u; // non-centered tract initial values
  matrix[J, T] theta; // tract-time random effects
  vector[N] mu;

  // Non-centered parameterization of tract intercepts
  u = sigma_u * u_raw;

  // First period random effects are just tract intercepts
  for (j in 1:J) {
    theta[j, 1] = u[j];
  }

  // Autoregressive component for subsequent periods
  for (t in 2:T) {
    for (j in 1:J) {
      theta[j, t] = phi * theta[j, t-1] + sigma_e * normal_rng(0, 1);
    }
  }

  // Linear predictor
  for (n in 1:N) {
    mu[n] = alpha + X[n] * beta + theta[tract_id[n], time_id[n]];
  }
}

model {
  // Priors
  alpha ~ normal(0, 2.5);
  beta ~ normal(0, 2.5);
  sigma_u ~ cauchy(0, 2.5);
  sigma_e ~ cauchy(0, 2.5);
  phi ~ uniform(-1, 1);
  u_raw ~ normal(0, 1);

  // Likelihood
  y ~ normal(mu, sigma_e);
}

// Optional: generated quantities for predictions
generated quantities {
  vector[N] log_lik;
  for (n in 1:N) {
    log_lik[n] = normal_lpdf(y[n] | mu[n], sigma_e);
  }
}