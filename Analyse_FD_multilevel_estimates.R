#
# Plot multilevel posterior effects for treat and cross_treat
#   - Two panels: tier1 and tier2
#   - Within each panel: model with vs. without three-way interaction
#

base_dir <- "BTW_2025/Outputs/First_Differencing/multilevel"

files <- data.frame(
  tier = c("tier1", "tier1", "tier2", "tier2"),
  model_key = c("full_interactions", "without_state", "full_interactions", "without_state"),
  file = c(
    "summary_full_interactions_tier1.csv",
    "summary_without_state_tier1.csv",
    "summary_full_interactions_tier2.csv",
    "summary_without_state_tier2.csv"
  ),
  stringsAsFactors = FALSE
)

extract_effects <- function(path, tier, model_key) {
  if (!file.exists(path)) {
    stop("Summary file not found: ", path)
  }

  x <- read.csv(path, stringsAsFactors = FALSE)

  keep <- x$variable %in% c("beta_treat", "beta_cross_treat")
  x <- x[keep, c("variable", "mean", "q5", "q95")]

  if (nrow(x) != 2) {
    stop("Expected beta_treat and beta_cross_treat in: ", path)
  }

  x$tier <- tier
  x$model_key <- model_key

  x$effect <- ifelse(
    x$variable == "beta_treat",
    "Treat",
    "Cross-treat"
  )

  x$model <- ifelse(
    x$model_key == "full_interactions",
    "With 3-way interaction",
    "Without 3-way interaction"
  )

  x
}

pieces <- vector("list", nrow(files))
for (i in seq_len(nrow(files))) {
  fpath <- file.path(base_dir, files$file[i])
  pieces[[i]] <- extract_effects(
    path = fpath,
    tier = files$tier[i],
    model_key = files$model_key[i]
  )
}

effects_df <- do.call(rbind, pieces)

# Display ordering in plot
# Keep tiers in numerical order and effects in requested order.
effects_df$tier <- factor(effects_df$tier, levels = c("tier1", "tier2"), labels = c("Tier 1", "Tier 2"))
effects_df$effect <- factor(effects_df$effect, levels = c("Treat", "Cross-treat"))
effects_df$model <- factor(
  effects_df$model,
  levels = c("With 3-way interaction", "Without 3-way interaction")
)

# Save a compact table used by the figure for reproducibility
write.csv(
  effects_df[, c("tier", "model", "variable", "mean", "q5", "q95")],
  file = file.path(base_dir, "effect_estimates_treat_cross_treat.csv"),
  row.names = FALSE
)

plot_file <- file.path(base_dir, "effect_estimates_treat_cross_treat.png")

tier_levels <- levels(effects_df$tier)
effect_levels <- levels(effects_df$effect)
model_levels <- levels(effects_df$model)
model_colors <- c("With 3-way interaction" = "#1b9e77", "Without 3-way interaction" = "#d95f02")

overall_ylim <- range(c(effects_df$q5, effects_df$q95), finite = TRUE)
pad <- 0.08 * diff(overall_ylim)
if (!is.finite(pad) || pad == 0) {
  pad <- 0.01
}
overall_ylim <- c(overall_ylim[1] - pad, overall_ylim[2] + pad)

png(filename = plot_file, width = 3200, height = 1500, res = 320)
op <- par(no.readonly = TRUE)
on.exit({
  par(op)
  dev.off()
}, add = TRUE)

par(mfrow = c(1, 2), mar = c(4.5, 4.5, 3.2, 1.2), oma = c(0, 0, 1.7, 0))

for (tier_now in tier_levels) {
  tier_dat <- effects_df[effects_df$tier == tier_now, ]

  x_base <- seq_along(effect_levels)
  x_offsets <- c(-0.12, 0.12)

  plot(
    NA,
    xlim = c(0.5, length(effect_levels) + 0.5),
    ylim = overall_ylim,
    xaxt = "n",
    xlab = "",
    ylab = "Coefficient estimate",
    main = tier_now
  )

  axis(1, at = x_base, labels = effect_levels)
  abline(h = 0, col = "gray70", lwd = 1)

  for (m in seq_along(model_levels)) {
    model_now <- model_levels[m]
    dd <- tier_dat[tier_dat$model == model_now, ]
    dd <- dd[match(effect_levels, dd$effect), ]

    x_now <- x_base + x_offsets[m]

    segments(x_now, dd$q5, x_now, dd$q95, col = model_colors[[model_now]], lwd = 2)
    points(x_now, dd$mean, pch = 16, cex = 1.05, col = model_colors[[model_now]])
  }

  legend(
    "bottom",
    legend = model_levels,
    col = model_colors[model_levels],
    pch = 16,
    bty = "n",
    horiz = FALSE,
    cex = 0.85
  )
}

mtext("Estimated Effects of Treat and Cross-treat", outer = TRUE, cex = 1.1, font = 2, line = 0.8)
mtext("Posterior mean with 90% credible interval (q5 to q95)", outer = TRUE, cex = 0.9, line = -0.15)

dev.off()

cat("Saved plot to: ", plot_file, "\n", sep = "")
cat("Saved estimate table to: ", file.path(base_dir, "effect_estimates_treat_cross_treat.csv"), "\n", sep = "")
