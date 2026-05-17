data {
  int<lower=1> N;
  vector[N] y;
  vector[N] treat;
  vector[N] cross_treat;

  int<lower=1> J_party;
  int<lower=1> J_year;
  int<lower=1> J_land;
  int<lower=1> J_yp;
  int<lower=1> J_yl;
  int<lower=1> J_pl;
  int<lower=1> J_ypl;

  array[N] int<lower=1, upper=J_party> party_id;
  array[N] int<lower=1, upper=J_year> year_id;
  array[N] int<lower=1, upper=J_land> land_id;
  array[N] int<lower=1, upper=J_yp> yp_id;
  array[N] int<lower=1, upper=J_yl> yl_id;
  array[N] int<lower=1, upper=J_pl> pl_id;
  array[N] int<lower=1, upper=J_ypl> ypl_id;
}

parameters {
  real alpha;
  real beta_treat;
  real beta_cross_treat;

  vector[J_party] z_party;
  vector[J_year] z_year;
  vector[J_land] z_land;
  vector[J_yp] z_yp;
  vector[J_yl] z_yl;
  vector[J_pl] z_pl;
  vector[J_ypl] z_ypl;

  real<lower=0> sigma_party;
  real<lower=0> sigma_year;
  real<lower=0> sigma_land;
  real<lower=0> sigma_yp;
  real<lower=0> sigma_yl;
  real<lower=0> sigma_pl;
  real<lower=0> sigma_ypl;
  real<lower=0> sigma;
}

transformed parameters {
  vector[J_party] u_party = sigma_party * z_party;
  vector[J_year] u_year = sigma_year * z_year;
  vector[J_land] u_land = sigma_land * z_land;
  vector[J_yp] u_yp = sigma_yp * z_yp;
  vector[J_yl] u_yl = sigma_yl * z_yl;
  vector[J_pl] u_pl = sigma_pl * z_pl;
  vector[J_ypl] u_ypl = sigma_ypl * z_ypl;
}

model {
  // Fixed effects priors
  alpha ~ normal(0, 5);
  beta_treat ~ normal(0, 2.5);
  beta_cross_treat ~ normal(0, 2.5);

  // Random effects & scale priors
  // Random effects: Normal(0, sigma_re)
  z_party ~ normal(0, 1);
  z_year ~ normal(0, 1);
  z_land ~ normal(0, 1);
  z_yp ~ normal(0, 1);
  z_yl ~ normal(0, 1);
  z_pl ~ normal(0, 1);
  z_ypl ~ normal(0, 1);

  // SD priors: Exponential
    sigma_party ~ exponential(1);
    sigma_year ~ exponential(1);
    sigma_land ~ exponential(1);
    sigma_yp ~ exponential(1);
    sigma_yl ~ exponential(1);
    sigma_pl ~ exponential(1);
    sigma_ypl ~ exponential(1);
    sigma ~ exponential(1);

  // Vectorized Mu calculation (Fast!)
  vector[N] mu = alpha 
    + beta_treat * treat 
    + beta_cross_treat * cross_treat
    + u_party[party_id]
    + u_year[year_id]
    + u_land[land_id]
    + u_yp[yp_id]
    + u_yl[yl_id]
    + u_pl[pl_id]
    + u_ypl[ypl_id];

  y ~ normal(mu, sigma);
}

generated quantities {
  vector[N] log_lik;
  vector[N] mu_gen= alpha
      + beta_treat * treat
      + beta_cross_treat * cross_treat
      + u_party[party_id]
      + u_year[year_id]
      + u_land[land_id]
      + u_yp[yp_id]
      + u_yl[yl_id]
      + u_pl[pl_id]
      + u_ypl[ypl_id];

  for (n in 1:N) {

    log_lik[n] = normal_lpdf(y[n] | mu_gen[n], sigma);
  }
}
