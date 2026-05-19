#
# First differencing model with multilevel structure
#   Cross classified multilevel structure: year * parties + federal states (Land)


# Reading data

load("BTW_2025/Outputs/First_Differencing/party.selec1_denom1_2026-05-13.RData")


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

options(mc.cores = parallel::detectCores())

output_dir <- "BTW_2025/Outputs/First_Differencing/multilevel"
if (!dir.exists(output_dir)) {
	dir.create(output_dir, recursive = TRUE)
}

raw_csv_dir <- file.path(output_dir, "raw_csv")
if (!dir.exists(raw_csv_dir)) {
	dir.create(raw_csv_dir, recursive = TRUE)
}

full_stan_file <- "Analyse_FD_multilevel_full_interactions.stan"
without_state_stan_file <- "Analyse_FD_multilevel_without_state.stan"

if (!file.exists(full_stan_file)) {
	stop("Stan file not found: ", full_stan_file)
}
if (!file.exists(without_state_stan_file)) {
	stop("Stan file not found: ", without_state_stan_file)
}

full_summary_vars <- c(
	"alpha", "beta_treat", "beta_cross_treat",
	"sigma_party", "sigma_year", "sigma_land",
	"sigma_yp", "sigma_yl", "sigma_pl", "sigma_ypl", "sigma"
)

without_state_summary_vars <- c(
	"alpha", "beta_treat", "beta_cross_treat",
	"sigma_party", "sigma_year", "sigma_yp", "sigma"
)

mod_full <- cmdstanr::cmdstan_model(full_stan_file)
mod_without_state <- cmdstanr::cmdstan_model(without_state_stan_file)

q2.5 <- function(x) posterior::quantile2(x, probs = 0.025)
q97.5 <- function(x) posterior::quantile2(x, probs = 0.975)


for (i.tier in 1:2){


	if (i.tier == 1) {
		data <- all.results.smd[[3]]
		tier_label <- "tier1"
	}
	if (i.tier == 2) {
		data <- all.results.pr[[3]]
		tier_label <- "tier2"
	}


	# -----------------------------------------------------------------------------
	# Preprocessing: create integer indices for nominal random effects
	# -----------------------------------------------------------------------------

	model_data <- data

	model_data <- model_data[complete.cases(
		model_data[, c("votes", "treat", "cross.treat", "party", "year", "land")]
	), ]

	finite_mask <-
		is.finite(model_data$votes) &
		is.finite(model_data$treat) &
		is.finite(model_data$cross.treat)

	removed_non_finite <- sum(!finite_mask)
	if (removed_non_finite > 0) {
		cat("Removed ", removed_non_finite, " rows with non-finite numeric values for ", tier_label, "\n", sep = "")
	}

	model_data <- model_data[finite_mask, ]

	if (nrow(model_data) == 0) {
		stop("No valid rows left after filtering missing/non-finite values for ", tier_label)
	}

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

	stan_data_without_state <- list(
		N = nrow(model_data),
		y = as.numeric(model_data$votes),
		treat = as.numeric(model_data$treat),
		cross_treat = as.numeric(model_data$cross.treat),
		J_party = nlevels(model_data$party),
		J_year = nlevels(model_data$year),
		J_yp = nlevels(model_data$yp),
		party_id = model_data$party_id,
		year_id = model_data$year_id,
		yp_id = model_data$yp_id
	)

	cat("\n=== Running full_interactions for ", tier_label, " ===\n", sep = "")
	fit_full <- mod_full$sample(
		data = stan_data_full,
		chains = 4,
		iter_sampling = 1000,
		iter_warmup = 1000,
		seed = 123,
		adapt_delta = 0.95,
		max_treedepth = 12,
		parallel_chains = min(4, parallel::detectCores())
	)

	cat("\nPosterior summary for full_interactions (", tier_label, ")\n", sep = "")
	full_summary <- posterior::summarise_draws(
		fit_full$draws(variables = full_summary_vars),
		"mean", "median", "sd", "mad", q2.5, q97.5, "rhat", "ess_bulk", "ess_tail"
	)
	print(full_summary)

	saveRDS(fit_full$draws(), file = file.path(output_dir, paste0("posterior_full_interactions_", tier_label, ".rds")))
	write.csv(full_summary, file = file.path(output_dir, paste0("summary_full_interactions_", tier_label, ".csv")), row.names = FALSE)
	write.csv(fit_full$diagnostic_summary(), file = file.path(output_dir, paste0("diagnostics_full_interactions_", tier_label, ".csv")), row.names = FALSE)
	full_csv_files <- fit_full$output_files()
	for (chain_idx in seq_along(full_csv_files)) {
		file.copy(
			from = full_csv_files[[chain_idx]],
			to = file.path(raw_csv_dir, paste0("full_interactions_", tier_label, "_chain", chain_idx, ".csv")),
			overwrite = TRUE
		)
	}
	cat("Saved posterior and summaries for full_interactions_", tier_label, "\n", sep = "")

	cat("\n=== Running without_state for ", tier_label, " ===\n", sep = "")
	fit_without_state <- mod_without_state$sample(
		data = stan_data_without_state,
		chains = 4,
		iter_sampling = 1000,
		iter_warmup = 1000,
		seed = 123,
		adapt_delta = 0.95,
		max_treedepth = 12,
		parallel_chains = min(4, parallel::detectCores())
	)

	cat("\nPosterior summary for without_state (", tier_label, ")\n", sep = "")
	without_state_summary <- posterior::summarise_draws(
		fit_without_state$draws(variables = without_state_summary_vars),
		"mean", "median", "sd", "mad", q2.5, q97.5, "rhat", "ess_bulk", "ess_tail"
	)
	print(without_state_summary)

	saveRDS(fit_without_state$draws(), file = file.path(output_dir, paste0("posterior_without_state_", tier_label, ".rds")))
	write.csv(without_state_summary, file = file.path(output_dir, paste0("summary_without_state_", tier_label, ".csv")), row.names = FALSE)
	write.csv(fit_without_state$diagnostic_summary(), file = file.path(output_dir, paste0("diagnostics_without_state_", tier_label, ".csv")), row.names = FALSE)
	without_state_csv_files <- fit_without_state$output_files()
	for (chain_idx in seq_along(without_state_csv_files)) {
		file.copy(
			from = without_state_csv_files[[chain_idx]],
			to = file.path(raw_csv_dir, paste0("without_state_", tier_label, "_chain", chain_idx, ".csv")),
			overwrite = TRUE
		)
	}
	cat("Saved posterior and summaries for without_state_", tier_label, "\n", sep = "")



}
