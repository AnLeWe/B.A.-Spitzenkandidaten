#
# First differencing model with multilevel structure
#   Cross classified multilevel structure: year * parties + federal states (Land)


# Reading data

load("BTW_2025/Outputs/First_Differencing/party.selec1_denom1_2026-05-13.RData")




data <- all.results.pr[[3]]


# Required packages
if (!requireNamespace("cmdstanr", quietly = TRUE)) {
	stop("Package 'cmdstanr' is required. Please install it first.")
}
if (!requireNamespace("posterior", quietly = TRUE)) {
	stop("Package 'posterior' is required. Please install it first.")
}

cmdstan_path <- tryCatch(
	cmdstanr::cmdstan_path(),
	error = function(e) NULL
)

if (is.null(cmdstan_path) || !nzchar(cmdstan_path)) {
	stop("CmdStan is not configured. Run cmdstanr::install_cmdstan() once, then re-run this script.")
}


# -----------------------------------------------------------------------------
# Preprocessing: create integer indices for nominal random effects
# -----------------------------------------------------------------------------

model_data <- data

model_data <- model_data[complete.cases(
	model_data[, c("votes", "treat", "cross.treat", "party", "year", "land")]
), ]

model_data$party <- as.factor(model_data$party)
model_data$year <- as.factor(model_data$year)
model_data$land <- as.factor(model_data$land)

model_data$party_id <- as.integer(model_data$party)
model_data$year_id <- as.integer(model_data$year)
model_data$land_id <- as.integer(model_data$land)

# Two-way interaction indices
model_data$yp <- interaction(model_data$year, model_data$party, drop = TRUE)
model_data$yl <- interaction(model_data$year, model_data$land, drop = TRUE)
model_data$pl <- interaction(model_data$party, model_data$land, drop = TRUE)

model_data$yp_id <- as.integer(model_data$yp)
model_data$yl_id <- as.integer(model_data$yl)
model_data$pl_id <- as.integer(model_data$pl)

# Three-way interaction index: year x party x land
model_data$ypl <- interaction(model_data$year, model_data$party, model_data$land, drop = TRUE)
model_data$ypl_id <- as.integer(model_data$ypl)

stan_data_full <- list(
	N = nrow(model_data),
	y = as.numeric(model_data$votes),
	treat = as.numeric(model_data$treat),
	cross_treat = as.numeric(model_data$cross.treat),
	J_party = nlevels(model_data$party),
	J_year = nlevels(model_data$year),
	J_land = nlevels(model_data$land),
	J_yp = nlevels(model_data$yp),
	J_yl = nlevels(model_data$yl),
	J_pl = nlevels(model_data$pl),
	J_ypl = nlevels(model_data$ypl),
	party_id = model_data$party_id,
	year_id = model_data$year_id,
	land_id = model_data$land_id,
	yp_id = model_data$yp_id,
	yl_id = model_data$yl_id,
	pl_id = model_data$pl_id,
	ypl_id = model_data$ypl_id
)


# -----------------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------------

full_stan_file <- "Analyse_FD_multilevel_full_interactions.stan"
full_summary_vars <- c(
	"alpha", "beta_treat", "beta_cross_treat",
	"sigma_party", "sigma_year", "sigma_land",
	"sigma_yp", "sigma_yl", "sigma_pl", "sigma_ypl", "sigma"
)

run_diagnostics <- function(fit_obj, max_treedepth = 12) {
	diag <- fit_obj$diagnostic_summary()
	print(diag)

	all_summary <- fit_obj$summary()
	rhats <- all_summary$rhat
	ess_bulk <- all_summary$ess_bulk
	ess_tail <- all_summary$ess_tail

	cat("\nDiagnostics checks:\n")
	cat("Max Rhat:", max(rhats, na.rm = TRUE), "\n")
	cat("Min bulk ESS:", min(ess_bulk, na.rm = TRUE), "\n")
	cat("Min tail ESS:", min(ess_tail, na.rm = TRUE), "\n")

	sampler_diag <- fit_obj$sampler_diagnostics(format = "df")
	total_divergences <- sum(sampler_diag$divergent__, na.rm = TRUE)
	max_treedepth_hits <- sum(sampler_diag$treedepth__ >= max_treedepth, na.rm = TRUE)

	cat("Total divergences:", total_divergences, "\n")
	cat("Transitions at max treedepth:", max_treedepth_hits, "\n")

	ebfmi_by_chain <- with(
		sampler_diag,
		tapply(energy__, chain_id__, function(x) {
			n <- length(x)
			if (n < 2) {
				return(NA_real_)
			}
			sum(diff(x)^2) / ((n - 1) * stats::var(x))
		})
	)

	cat("E-BFMI by chain:\n")
	print(ebfmi_by_chain)

	if (any(ebfmi_by_chain < 0.3, na.rm = TRUE)) {
		cat("Warning: At least one chain has E-BFMI < 0.3.\n")
	}
}

fit_full_model <- function() {
	if (!file.exists(full_stan_file)) {
		stop("Stan file not found: ", full_stan_file)
	}

	mod <- cmdstanr::cmdstan_model(full_stan_file)

	fit <- mod$sample(
		data = stan_data_full,
		chains = 4,
		iter_sampling = 1000,
		iter_warmup = 1000,
		seed = 123,
		adapt_delta = 0.95,
		max_treedepth = 12,
		parallel_chains = min(4, parallel::detectCores())
	)

	cat("\nPosterior summary for full_interactions\n")
	print(fit$summary(variables = full_summary_vars))

	cat("\nDiagnostics for full_interactions\n")
	run_diagnostics(fit, max_treedepth = 12)

	fit
}


# -----------------------------------------------------------------------------
# Fit model
# -----------------------------------------------------------------------------

options(mc.cores = parallel::detectCores())

fit <- fit_full_model()


