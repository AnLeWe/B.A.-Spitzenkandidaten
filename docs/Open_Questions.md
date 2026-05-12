# Open Questions

## Data Issue: `all.land[,7]` Wrong for 2002

`all.land[,i.year]` is filled from `temp.dat[,3]` for all years. For years 1–6, `temp.dat` is a slice of `data_now` where col 3 is the state index (1–16). For year 7 (2002), `temp.dat = result0202` which has a different column layout — col 3 is Wahlberechtigte (eligible voters, ~150k–250k), not the state index. `all.land[,7]` therefore contains garbage state assignments.

**Consequences:** None for any current analysis. FD uses only `all.land[,1:6]`; FE does not use `all.land` at all. Would become a silent error if state-level analysis of 2002 is added (e.g., state-clustered SEs in an extended FE model including 2002, or subgroup analysis by state for 2002).

**Fix needed in `Data_Prep.Rmd`:** Read the state index for 2002 from `result0202` explicitly using its correct column rather than relying on col 3.

---

## Spillover Analysis

**Q: Should directly treated units be included or excluded in the spillover treatment indicator?**

Currently `diag(temp.mat) <- 1` means directly treated districts are included in the combined "in treated neighbourhood" indicator, conflating direct and spillover effects. This was reportedly intentional.

- If intentional: document the rationale explicitly in the paper. The estimand is "effect of being in a treated area" not "pure spillover effect."
- Alternative: keep `diag = 0`, add `spill.treat` as a *separate* regressor alongside `treat` → estimates direct and spillover effects simultaneously.

---

## Standard Errors / Inference

**Q: Should wild cluster bootstrap be implemented for FPTP in both FD and FE?**

FPTP identification comes from 36 ever-treated district×party cells. With this few treated clusters, `vcovHC(type='HC')` (current) and standard `vcovCL` are both unreliable for the `treat` coefficient — SEs are likely too narrow.

- FD FPTP: wild cluster bootstrap at district level (`fwildclusterboot::boottest()`) — most urgent, primary estimator
- FE FPTP: same
- PR (both): cluster at district level (299 clusters), standard `vcovCL` sufficient; note within-state correlation as caveat

The FD script already has commented-out `vcovCL` code as a placeholder.

---

## Parallel Trends / Exogeneity

**Q: Are parallel trends and strict exogeneity the same assumption here?**

They are related but not identical. Strict exogeneity additionally rules out feedback from past vote shares to current candidacy decisions (if parties put candidates in districts where they recently did well, this violates strict exogeneity but not necessarily parallel trends). The Wooldridge test (future treatment ≠ predictor of current vote shares) tests a key implication of strict exogeneity and serves as the parallel trends check in this setting.

---

## Staggered DiD: Callaway–Sant'Anna, Sun–Abraham, de Chaisemartin–D'Haultfœuille

**Q: Should heterogeneity-robust staggered DiD estimators be implemented as robustness checks?**

The standard TWFE estimator can produce negatively-weighted averages of cohort-specific effects when treatment timing is staggered and effects are heterogeneous (Goodman-Bacon). Three estimators address this:

**Callaway–Sant'Anna (`did` package):** Estimates group-time ATT(g,t) using clean 2×2 DiDs between cohort g and never/not-yet-treated units. **Problem for this paper:** CS assumes absorbing treatment (once treated, always treated). Treatment here is explicitly non-absorbing — candidates run in some elections but not others (e.g., Merkel runs 2005–2017 but not 2021). This violates the CS setup and `first_treat` is not well-defined.

**Sun–Abraham (`fixest::sunab()`):** Cohort×event-time interaction approach, aggregated with cohort shares as weights. Same limitation: assumes absorbing treatment. Less applicable here.

**de Chaisemartin–D'Haultfœuille (`DIDmultiplegtDYN`):** Specifically designed for treatment reversal and on/off policies. Compares switchers (Δd ≠ 0) to stayers (Δd = 0) at each t — which is conceptually very close to the existing FD estimator. This is the most applicable of the three.

**Assessment:** The existing FD estimator is already close in spirit to DiDmultiplegt — it computes first differences for switcher units against a year×party fixed effect. The main value of implementing DiDmultiplegt would be as a formal robustness check with event-time dynamics (leads and lags) and bootstrap SEs. CS and SA are not directly applicable due to treatment reversal.

**Decision needed:** Is DiDmultiplegt worth implementing as a robustness check, or is the FD + Wooldridge test sufficient for the paper?

---

## FE Model Residual Diagnostic

**Q: What drives the residual-fitted correlation among treated observations in the FE model?**

The static FE shows residuals significantly correlated with fitted values for treated obs (β = 0.09, R² = 0.21, p < 2.2e-16). Two candidate explanations:

1. **Omitted AR dynamics**: vote shares are persistent; static FE doesn't capture recent trajectories; candidates run in years when districts are on an upswing. FD handles this by differencing (implicit AR = 1 constraint). FD residuals also show moderate autocorrelation, suggesting vote share persistence is not fully removed by first-differencing either.
2. **Treatment effect heterogeneity**: candidate boost may be larger in already-strong districts. Single `treat` coefficient averages over this.

These are not mutually exclusive. Worth checking whether the pattern replicates in FD residuals and whether it is party- or election-specific.
