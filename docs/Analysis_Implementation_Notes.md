tags: #leader-paper

---

## Data and Implementation Issues

### Issue 1 — Silent treatment drops via `na.omit`

After first-differencing, `lm.dat` is built and `na.omit()` is called. If the **outcome variable** (vote share FD) is `NA` for a treated row, that row is silently dropped from the regression — the treatment count in the data check still looks right, but the regression never sees those observations.

**Affected cases:**

| Tier        | Year | Party | Dropped +1s                      | Dropped -1s | Reason                                        |
| ----------- | ---- | ----- | -------------------------------- | ----------- | --------------------------------------------- |
| Erststimme  | 2017 | AfD   | 2 (Gauland WK 63, Weidel WK 293) | 0           | AfD 2013 Erststimmen missing from `data_then` |
| Zweitstimme | 2025 | BSW   | 64 (all NRW WKs)                 | 0           | BSW has no 2021 baseline (party didn't exist) |

**Root cause for AfD/Erststimme:** The `data_then` slot for year 2017 comes from `result1713` — the "previous 2013 results" columns embedded in `btw2017_kerg.csv`. The Bundeswahlleiter only includes comparison columns for parties that entered the Bundestag. AfD got 4.7% in 2013 but won no seats, so their Erststimmen are absent from those columns → `data_then` AfD 2013 = `NA` → vote FD = `NA` → `na.omit` drops the row.

**Consequence for figures:** In `All_Estimated_Effects.pdf`, the FPTP-candidacy treatment count differs between tiers: **54 (Erststimme) vs 56 (Zweitstimme)** in the All-parties model, **40 vs 42** in the Minor-parties model. The 2 extra observations in the PR model are precisely Gauland (WK 63) and Weidel (WK 293) from the 2017–2013 FD period — their Zweitstimme FD is valid so they enter the PR model, but their Erststimme FD is NA so they are dropped from the FPTP model. The FPTP and PR models are thus fit on slightly different samples; this is unavoidable given data constraints and worth noting in a footnote.

---

### Issue 2 — Spillover matrix multiplication propagates NAs (RESOLVED)

**Status: Fixed** upstream by the hybrid treatment matching (Issue 3). Zero NAs in `all.treat.dummy.fd` across all years/parties/tiers, so matrix multiplication never propagates NAs.

**Why this was critical:** In the GitHub commit c16744b approach (canonical matching in `Analyse_FD_25.Rmd` with no fallback for NA keys), `key[i] = NA` for ~51 WK-year boundary-change rows causes `all.treat.dummy[NA,,,t+1]` = NA. When spillover runs `temp.mat %*% temp.treat` and `temp.treat` contains NAs, matrix multiplication propagates each NA across an entire column of the result — potentially making most of the 299 rows NA. `na.omit` then drops those rows, making model estimation infeasible under spillover.

**How the current implementation avoids this:** `data_treat_then` is built with hybrid canonical + same-row fallback matching in `Data_Prep.Rmd`. NA-key rows (boundary-change territories) receive their predecessor's treatment via same-row fallback, which is 0 for all ~51 affected rows (verified). FD = treat_now − 0 = treat_now — a valid integer. The spillover matrix multiplication receives a fully clean array and produces a clean result.

---

### Issue 3 — Treatment FD key matching (RESOLVED 2026-05-07)

**Status: Fixed** with hybrid canonical matching in `Data_Prep.Rmd`.

#### History of implementations

**Stage 1 — pre-c16744b (broken):** `all.treat` was 4D (no previous-year dimension). Treatment FD computed in `Analyse_FD_25.Rmd` as direct row subtraction:
```r
all.treat.dummy.fd[,,,t] <- all.treat.dummy[,,,t] - all.treat.dummy[,,,t+1]
```
WK i in year t blindly subtracted from WK i in year t+1 regardless of geography. **Wrong for renumbered territories** (e.g. Bartsch WK12→WK14 between 2013 and 2017 gives spurious +1 at WK14 and −1 at WK12 instead of 0 and −1).

**Stage 2 — c16744b (mostly correct, but drops observations):** Added canonical matching in `Analyse_FD_25.Rmd`:
```r
key <- match(simple.district.idx[, t], simple.district.idx[, t + 1])
all.treat.dummy.fd[,,,t] <- all.treat.dummy[,,,t] - all.treat.dummy[key,,,t+1]
```
Fixes renumbered territories. But `key[i] = NA` for ~51 boundary-change rows → `all.treat.dummy[NA,,,]` = NA → NA treatment FD → those observations dropped by `na.omit`, and under spillover the NA propagates through matrix multiplication making model estimation infeasible. No fallback.

**Stage 3 — current (correct, no drops):** Matching moved into `Data_Prep.Rmd` via `data_treat_then`. `all.treat` is now 5D (dim5: current=1 / previous=2). FD in analysis script is simple dim5 subtraction:
```r
all.treat.dummy.fd <- all.treat.dummy[,,,1:6,1] - all.treat.dummy[,,,1:6,2]
```

#### The problem `data_treat_then` solves

`data_treat_then[row i, year t]` must hold the previous-year treatment for the territory at row i in year t. Three territory types must be handled:

1. **Stable:** same canonical ID at same row. Direct subtraction would work; canonical match also works.
2. **Stable renumbering:** same territory, different WK number (e.g. Trittin WK54 in 2009 → WK53 in 2013). Canonical match finds the right predecessor row. Direct row would give wrong result.
3. **Boundary change:** canonical ID > 299 (territory redefined), match returns NA. Direct row fallback used — WK numbers are stable (`Nr.XX.orig == 1:299` for all years), so same row = same WK number = reasonable prior.

#### The fix: hybrid approach

```r
key     <- match(nr_cols[, t], nr_cols[, t + 1])
matched <- !is.na(key)
data_treat_then[curr_rows[matched],  ] <- data_treat[prev_rows[key[matched]], ]
data_treat_then[curr_rows[!matched], ] <- data_treat[prev_rows[!matched], ]
```

`nr_cols` is loaded from `data_now_WK_Einteilung.xlsx` sheet 6, columns `Nr.25`, `Nr.21`, … `Nr.02` (canonical IDs, not original WK numbers).

#### Known structural limitation: collision

8 collision cases exist (one per year transition except 2021←2017) where a boundary-change row's same-row fallback reads from the same predecessor row as a canonical match for a different current-year row. Both current-year rows copy treatment from the same previous-year WK. Verified safe: all 8 collision predecessor WKs have direct treatment = 0 for all parties and tiers, no treated neighbors (FPTP spillover), same-Land PR treatment (PR spillover). No effect on any FD value in this dataset.

---

## Verified FPTP (Erststimme) Treatment FD Counts (2026-05-07)

These are the treatment first-differences in the **array** (before `na.omit` in the regression). Note: 2017 AfD drops 2 from regression due to Issue 1.

| Year | Array +1 | Array −1 | Enters regression +1 | Notes |
|------|----------|----------|----------------------|-------|
| 2005 | 3 | 4 | 3 | |
| 2009 | 3 | 2 | 3 | |
| 2013 | 9 | 3 | 9 | Merkel WK15 correctly FD=0 (continuous) |
| 2017 | 6 | 10 | **4** | Gauland WK63 + Weidel WK293 dropped (Issue 1) |
| 2021 | 4 | 5 | 4 | Merkel WK15 retirement = 5th −1 |
| 2025 | 3 | 4 | 3 | |

**2025 FPTP detail:**

| FD | WK | Party | Who |
|----|-----|-------|-----|
| +1 | 1 | GRU | Habeck (new) |
| +1 | 39 | LIN | Reichinnek (new) |
| +1 | 146 | CDU | Merz (new) — territory was WK147 in 2021 |
| −1 | 14 | LIN | Bartsch territory (moved to WK14 in 2021, now gone) |
| −1 | 61 | GRU | Baerbock (not running 2025) |
| −1 | 156 | AfD | Chrupalla territory (was WK157 in 2021, renumbered) |
| −1 | 181 | LIN | Wißler territory (was WK182 in 2021, renumbered) |

Note: Lindner FDP correctly FD=0 — territory renumbered WK100→WK99 between 2021 and 2025, continuous treatment. Scholz SPD WK61 also FD=0 (continuous). Weidel AfD WK293 FD=0 (continuous).

**2021 FPTP detail:**

| FD | WK | Party | Who |
|----|-----|-------|-----|
| +1 | 61 | SPD | Scholz (new) |
| +1 | 61 | GRU | Baerbock (new) |
| +1 | 157 | AfD | Chrupalla (new) — territory was WK158 in 2017 |
| +1 | 182 | LIN | Wißler (new) — territory was WK183 in 2017 |
| −1 | 15 | CDU | Merkel retired |
| −1 | 63 | AfD | Gauland didn't run |
| −1 | 107 | LIN | Wagenknecht left WK |
| −1 | 193 | GRU | Göring-Eckardt didn't run |
| −1 | 258 | GRU | Özdemir left WK |

**2017 FPTP detail (array, before na.omit):**

| FD | WK | Party | Who |
|----|-----|-------|-----|
| +1 | 14 | LIN | Bartsch (moved from WK12→WK14) |
| +1 | 63 | AfD | Gauland (new) — *dropped from regression, Issue 1* |
| +1 | 100 | FDP | Lindner (new at WK100) |
| +1 | 193 | GRU | Göring-Eckardt (new) |
| +1 | 258 | GRU | Özdemir (new) |
| +1 | 293 | AfD | Weidel (new) — *dropped from regression, Issue 1* |
| −1 | 12 | LIN | Bartsch territory (WK12, now at WK14) |
| −1 | 19 | LIN | van Aken left |
| −1 | 53 | GRU | Trittin territory (WK54→WK53, now gone in 2017) |
| −1 | 60 | LIN | Golze territory (WK61→WK60, lost treatment) |
| −1 | 84 | LIN | Gysi territory (WK85→WK84, now gone in 2017) |
| −1 | 104 | SPD | Steinbrück left |
| −1 | 156 | LIN | Lay left |
| −1 | 205 | FDP | Brüderle territory (WK206→WK205) |
| −1 | 219 | LIN | Wagenknecht territory (WK220→WK219) |
| −1 | 250 | LIN | Ernst left |

**2013 FPTP detail:**

| FD | WK | Party | Who |
|----|-----|-------|-----|
| +1 | 12 | LIN | Bartsch (new at WK12) |
| +1 | 19 | LIN | van Aken (new) |
| +1 | 60 | LIN | Golze (new — territory was WK61 in 2009 = Steinmeier's) |
| +1 | 104 | SPD | Steinbrück (new) |
| +1 | 107 | LIN | Wagenknecht (new) |
| +1 | 156 | LIN | Lay (new) |
| +1 | 206 | FDP | Brüderle (new) |
| +1 | 220 | LIN | Gohlke (new) |
| +1 | 250 | LIN | Ernst (new) |
| −1 | 60 | SPD | Steinmeier territory lost (WK61→WK60, now Golze) |
| −1 | 81 | GRU | Künast territory lost (WK82→WK81) |
| −1 | 96 | FDP | Westerwelle territory lost (WK97→WK96) |

Note: Merkel CDU WK15 FD=0 (continuous 2009→2013 despite canonical ID change 15→330 — hybrid fallback used). Trittin GRU WK53 FD=0 (same territory as 2009 WK54, renumbered). Gysi LIN WK84 FD=0 (same territory as 2009 WK85, renumbered).

**2009 FPTP detail:**

| FD | WK | Party | Who |
|----|-----|-------|-----|
| +1 | 54 | GRU | Trittin (new — territory was WK55 in 2005) |
| +1 | 61 | SPD | Steinmeier (new — territory was WK62 in 2005) |
| +1 | 82 | GRU | Künast (new — territory was WK83 in 2005) |
| −1 | 183 | GRU | Fischer territory lost (WK184→WK183) |
| −1 | 296 | LIN | Lafontaine left |

Note: Merkel CDU WK15 FD=0 (continuous). Westerwelle FDP WK97 FD=0 (continuous).

**2005 FPTP detail:**

| FD | WK | Party | Who |
|----|-----|-------|-----|
| +1 | 15 | CDU | Merkel (new) |
| +1 | 85 | LIN | Gysi (new) |
| +1 | 296 | LIN | Lafontaine (new) |
| −1 | 13 | LIN | Claus lost treatment |
| −1 | 74 | LIN | Claus/Zimmer territory lost |
| −1 | 86 | LIN | Pau territory lost |
| −1 | 198 | LIN | Zimmer territory lost |

---

## PR (Zweitstimme) Treatment FD Counts (2026-05-07)

PR treatment is Land-level: when a Spitzenkandidat runs in any WK of a Land, all WKs in that Land get party PR treatment. FD counts are therefore much larger.

| Year | PR +1 | PR −1 |
|------|-------|-------|
| 2005 | 11 | 60 |
| 2009 | 52 | 51 |
| 2013 | 236 | 90 |
| 2017 | 150 | 136 |
| 2021 | 138 | 196 |
| 2025 | 111 | 64 |

The large counts reflect Land-level treatment propagation (e.g. NRW alone has ~128 WKs). The hybrid matching applies equally to PR — Land membership is stable across WK renumberings, so the hybrid fix correctly handles both cases.

---

## Spillover Analysis (2026-05-07)

**Status: Clean.** After the hybrid treatment matching fix:
- Zero NAs in `all.treat.dummy.fd` across all years, parties, and tiers
- Adjacency matrices (`all.nb.mat`) are 299×299, rownames/colnames = `1:299` — consistent with treatment array ordering
- Issue 2 zero-imputation (`temp.treat[is.na(temp.treat)] <- 0`) is retained as a safety net but not currently needed

The spillover computation spreads already-correctly-computed FDs through the adjacency matrix. No indexing mismatches. When `spill.over.switch = 1`, the increased number of "treated" districts (neighbors of direct treatment districts) will all be correctly attributed to the right territories.

### Collision safety under spillover (verified 2026-05-07)

8 structural collisions exist across all year transitions (one per non-2021 transition): a boundary-change row's same-row fallback reads from the same predecessor as a canonical match for a different current-year row. Verified safe for spillover:

- **FPTP spillover:** All 8 collision predecessor WKs have no directly-treated FPTP neighbors in the relevant previous year → no spillover FPTP treatment would reach them.
- **PR direct:** All 8 predecessor WKs either have no direct PR treatment (0) or are in the same Land as the current collision row (so the copied value is correct regardless).
- **PR spillover:** 4 predecessor WKs neighbor PR-treated WKs (Neu-Ulm/AfD 2021; Rosenheim/LIN 2013; Osnabrück-Land/SPD+FDP 2005; Harz/SPD 2005). All same-Land for the relevant party except Osnabrück-Land/FDP. Under the current implementation (spillover applied to direct FD, not per-year), this is harmless: direct PR FD at those rows is unaffected by the collision. Would only matter under a per-year spillover methodology.

---

## Diagnostics II: Exogeneity (treat.t1) Matching Fix (2026-05-07)

**Status: Fixed** in `Analyse_FD_25.Rmd`.

### What was wrong

The `treat.t1` reordering loop (Wooldridge's test: include t+1 treatment as regressor) used eligible-voter counts from `data_now`/`data_then` columns 4 and 6 as a matching key to align the t+1 treatment FD into year-t row ordering. This was the old pre-hybrid approach, inconsistent with the fixed main treatment FD.

Compared to canonical matching (forward direction: `match(canon.idx[,t], canon.idx[,t-1])`):
- Produced 28–34 NA keys per transition vs 5–22 with canonical → more observations silently dropped from the exogeneity regression
- 1 wrong assignment per year transition (4 of 5 transitions) where keys disagreed — all on zero-treatment rows, so no material effect on coefficients for this dataset

### The fix

Replaced with hybrid canonical matching (forward direction) using `all.wkr.index[,1,1,]` (canonical IDs, already in `analysis_dat.RData`):

```r
canon.idx <- all.wkr.index[, 1, 1, ]
key     <- match(canon.idx[, i.btw], canon.idx[, i.btw - 1])
matched <- !is.na(key)
# matched rows: use canonical predecessor in t+1 year ordering
# unmatched rows: same-row fallback (boundary-change territories)
```

Applied identically to `treat.t1`, `treat.incumb.t1`, `cross.treat.t1`, `cross.treat.incumb.t1`.
