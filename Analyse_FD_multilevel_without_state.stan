data {
  int<lower=1> N;
  vector[N] y;
  vector[N] treat;
  vector[N] cross_treat;

  int<lower=1> J_party;
  int<lower=1> J_year;
  int<lower=1> J_yp;

  array[N] int<lower=1, upper=J_party> party_id;
  array[N] int<lower=1, upper=J_year> year_id;
  array[N] int<lower=1, upper=J_yp> yp_id;
}

parameters {
  real alpha;
  real beta_treat;
  real beta_cross_treat;

  vector[J_party] z_party;
  vector[J_year] z_year;
  vector[J_yp] z_yp;

  real<lower=0> sigma_party;
  real<lower=0> sigma_year;
  real<lower=0> sigma_yp;
  real<lower=0> sigma;
}

transformed parameters {
  vector[J_party] u_party = sigma_party * z_party;
  vector[J_year] u_year = sigma_year * z_year;
  vector[J_yp] u_yp = sigma_yp * z_yp;
}

model {
  // Fixed effects priors
  alpha ~ normal(0, 5);
  beta_treat ~ normal(0, 2.5);
  beta_cross_treat ~ normal(0, 2.5);

  // Random effects & scale priors
  z_party ~ normal(0, 1);
  z_year ~ normal(0, 1);
  z_yp ~ normal(0, 1);

  sigma_party ~ exponential(1);
  sigma_year ~ exponential(1);
  sigma_yp ~ exponential(1);
  sigma ~ exponential(1);

  // Vectorized Mu calculation
  vector[N] mu = alpha
    + beta_treat * treat
    + beta_cross_treat * cross_treat
    + u_party[party_id]
    + u_year[year_id]
    + u_yp[yp_id];

  y ~ normal(mu, sigma);
}

generated quantities {
  vector[N] log_lik;
  vector[N] mu_gen = alpha
      + beta_treat * treat
      + beta_cross_treat * cross_treat
      + u_party[party_id]
      + u_year[year_id]
      + u_yp[yp_id];

  for (n in 1:N) {
    log_lik[n] = normal_lpdf(y[n] | mu_gen[n], sigma);
  }
}
