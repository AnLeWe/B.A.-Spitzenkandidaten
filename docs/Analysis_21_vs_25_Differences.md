# Analysis 21 vs 25: documented differences and traced behavior

Last updated: 2026-04-18

This note documents the important differences between the 2021 pipeline (legacy replication) and the 2025-extended pipeline, including why old and replicated figure case numbers can differ in turnout panels.

Quick takeaway:
- Party labeling/mapping is correct in both pipelines.
- Masking is literal string matching on party labels (`GRU`, `AFD`) and applies only where those labels exist in `party.index`.
- In turnout estimation, `party.index` is set to `Turnout`, so mask checks do not match turnout rows for switch 1/2/3.
- Turnout still has fewer total rows (collapsed setup), but treated-event counts can be higher because treatment is collapsed as an "any selected party" indicator and main-effect rows can be reduced by party-specific masking.

## 1) Bottom line on party labeling and array filling

Conclusion from direct checks on saved objects:
- Legacy 21 party columns were mapped into arrays correctly.
- Current 25 party columns were mapped into arrays correctly.
- No evidence that parties were read in with wrong labels in array positions.

Validation run (2026-04-18):
- Legacy 2021 SMD mapping check: TRUE
- Legacy 2021 PR mapping check: TRUE
- Current 2025 SMD mapping check: TRUE
- Current 2025 PR mapping check: TRUE
- 2002 missing-by-design positions are NA in expected party slots.

## 2) Preprocessing differences: legacy 21 vs current 25

### 2.1 Years and party universe

Legacy 21 prep:
- Years: 2021, 2017, 2013, 2009, 2005, 2002 (6 years)
- Parties in arrays: 6
- Code evidence:
  - Legacy_Replication/Data_Prep_legacy_21.Rmd:595-596 (party vectors)
  - Legacy_Replication/Data_Prep_legacy_21.Rmd:679-681 (array dimensions)

Current 25 prep:
- Years: 2025, 2021, 2017, 2013, 2009, 2005, 2002 (7 years)
- Parties in arrays: 7 (BSW added)
- Code evidence:
  - Data_Prep.Rmd:661-662 (party vectors)
  - Data_Prep.Rmd:775-777 (array dimensions)

### 2.2 Why the party index order was changed

The party index order was changed because the pooled row-binding order changed.

`rbind.fill()` does not join on a key. It keeps the column layout of the first data frame that is passed in, and then appends the other yearly data frames underneath it while matching columns by name. In the legacy 21 pipeline, the first pooled input is `result2121`, whose party columns are ordered as CDU/CSU, SPD, AfD, FDP, DIE LINKE, GRUENE. In the current 25 pipeline, the first pooled input is `result2525`, whose party columns are ordered as SPD, CDU/CSU, GRUENE, FDP, AfD, DIE LINKE, BSW.

Because the pooled object inherits that first-input layout, the downstream array and index logic had to follow the pooled order to keep the year blocks aligned consistently. So the reindexing was not about a labeling mistake in the raw data; it was about keeping the analysis index order consistent with the changed merge order.

| Pipeline | First input to pooling | Party column order inherited by pooled object |
| --- | --- | --- |
| Legacy 21 | `result2121` | CDU/CSU, SPD, AfD, FDP, DIE LINKE, GRUENE |
| Current 25 | `result2525` | SPD, CDU/CSU, GRUENE, FDP, AfD, DIE LINKE, BSW |

Evidence:
- Legacy_Replication/Data_Prep_legacy_21.Rmd:521-522
- Data_Prep.Rmd:620-621
- Legacy_Replication/Data_Prep_legacy_21.Rmd:105-106
- Data_Prep.Rmd:205-206
- Legacy_Replication/Data_Prep_legacy_21.Rmd:679-681
- Data_Prep.Rmd:775-777

Important:
- Different order does not imply wrong labeling, as long as the later array and factor code uses the same order as the pooled data. That is what the current and legacy scripts do.

### 2.3 2002 handling in arrays

Legacy 21:
- 2002 fills party positions c(1,2,4,5,6), leaving AfD slot empty.
- Evidence: Legacy_Replication/Data_Prep_legacy_21.Rmd:718-721

Current 25:
- 2002 fills party positions c(1,2,3,4,6), leaving AfD and BSW slots empty.
- Evidence: Data_Prep.Rmd:816-821

This is intentional missing-by-design due to party availability in 2002.

### 2.4 Treatment workbook and preprocessing context

Legacy replication prep:
- Uses Data/Treatment_WK_21.xlsx if available, else Data/Treatment_WK.xlsx.
- Evidence: Legacy_Replication/Data_Prep_legacy_21.Rmd:572-576

Current prep:
- Uses Data/Treatment_WK.xlsx.
- Evidence: Data_Prep.Rmd:654

### 2.5 Current Treatment_WK vs retrieved pre-2025 Treatment_WK: full change log

Compared files:
- `Data/Treatment_WK.xlsx` (current workbook used by current pipeline)
- `Data/Treatment_WK_pre2025_from_git.xlsx` (retrieved pre-2025 workbook)

Added vs removed rows in `Tabelle2`:
- Added in current workbook: `13` rows total.
  - `8` rows in year `2025` (expected year extension).
  - `5` rows in year `2002`.
- Removed from current workbook: `1` row.
  - `2002 | CDU/CSU | WK=0 | Land=B`.

Important added-row examples:
- 2025 leaders newly present in current workbook:
  - `2025 | SPD | WK=61 | BB`
  - `2025 | CDU/CSU | WK=146 | NRW`
  - `2025 | Bündnis 90/Die Grünen | WK=1 | SH`
  - `2025 | FDP | WK=99 | NRW`
  - `2025 | AfD | WK=293 | BW`
  - `2025 | Die Linke | WK=39 | NI`
  - `2025 | Die Linke | WK=0 | HH`
  - `2025 | BSW | WK=0 | NRW`
- 2002 additions in current workbook:
  - `2002 | CDU/CSU | WK=0 | BY` (paired with removal of `Land=B` row)
  - `2002 | Die Linke | WK=74 | ST`
  - `2002 | Die Linke | WK=199 | TH`
  - `2002 | Die Linke | WK=13 | MV`
  - `2002 | Die Linke | WK=86 | B`

Changed (not newly added) rows in `Tabelle2`:
- Matched keys with detected changes: `31`.
- Most are documentation/provenance-only edits:
  - Column `...17`: `30` cell edits (URLs/notes/comments).
- Material value changes among matched keys:
  - Column `Partei`: `3` edits (label normalization, e.g., `Linke` -> `Die Linke`, `CDU` -> `CDU/CSU`).
  - Column `T_DM`: `1` edit.
  - Column `T_LP`: `1` edit.
- Row with substantive treatment recode:
  - `2013 | Die Linke | WK=12 | MV`: `T_DM` changed from `6` to `4`, `T_LP` changed from `6` to `4`, and the provenance field `...17` changed from `NA` to the Abgeordnetenwatch Bartsch link.

Interpretation (added vs changed):
- Added rows are dominated by explicit 2025 extension and several 2002 completions/corrections.
- Changed-but-not-added rows are mainly documentation updates (`...17`) plus a small number of real coding/label corrections.
- Therefore, differences are not only row additions; there are also genuine updates in existing records.

### 2.6 Analysis-level mapping differences relevant for treatment application

Clarification on "column 3 / Land" in election-result preprocessing:
- In both current and legacy prep, `Land` is assigned from column position `3` after harmonization.
  - Current prep examples:
    - `Data_Prep.Rmd:109` (`colnames(result2525)[3] <- "Land"`)
    - `Data_Prep.Rmd:195` (`colnames(result2121)[3] <- "Land"`)

Relevant difference is in treatment workbook field names (not election-result column index):
- Current prep maps state treatment via `Land.neu`:
  - `Data_Prep.Rmd:690`
- Legacy/pre-2025 prep maps state treatment via `Land`:
  - `Legacy_Replication/Data_Prep_legacy_21.Rmd:622`

Implication:
- The key analysis-level change is `Land.neu` vs `Land` in treatment-sheet parsing logic; it is not a change in using column 3 for `Land` in election-result tables.

Practical effect on treatment case numbers:
- Moving from `Land` to `Land.neu` does not change district-level treatment assignment (`T_DM`) for the affected rows.
- It mainly changes whether the party-list treatment (`T_LP`) can be matched to a state name at all.
- In the current workbook, `Land` and `Land.neu` are identical whenever both are populated, but `Land.neu` fills several rows where `Land` is blank.
- Rows with a missing `Land` but populated `Land.neu` in the current workbook:
  - `2021 | AfD | WK=293 | BW`
  - `2021 | AfD | WK=157 | SN`
  - `2013 | Die Linke | WK=250 | BY`
  - `2013 | Die Linke | WK=19 | HH`
  - `2013 | Die Linke | WK=220 | BY`
  - `2009 | Die Linke | WK=0 | SL`
  - `2009 | Die Linke | WK=85 | B`
  - `2005 | SPD | WK=0 | NI`
  - `2005 | Die Linke | WK=296 | SL`
- So, switching from `Land` to `Land.neu` increases the number of state-level treatment rows that can be mapped in those cases; it does not create new districts, but it prevents otherwise-valid list treatments from being dropped as unmapped.

## 3) Analysis-code differences (FD/FE)

### 3.1 Party selection switch definitions updated for 7-party setup

Legacy FD uses 6-party indexing:
- Evidence: Legacy_Replication/Analyse_FD_legacy_replication.Rmd:44-54

Current FD/FE uses 7-party indexing and switch definitions adapted to 2025/BSW:
- Evidence:
  - Analyse_FD_25.Rmd:55-66
  - Analyse_FE_RE_25.Rmd:55-66

### 3.2 Year span updates in FD arrays

Legacy FD first-difference time dimension:
- 5 transitions (6 election years)
- Evidence: Legacy_Replication/Analyse_FD_legacy_replication.Rmd:152 and 156

Current FD first-difference time dimension:
- 6 transitions (7 election years)
- Evidence: Analyse_FD_25.Rmd:187 and 191

### 3.3 Greens/AfD masking logic in current 25 scripts

Current scripts include explicit time-dependent masks for GRUENE and AfD in switch 2 and 3:
- Evidence:
  - Analyse_FD_25.Rmd:288-301
  - Analyse_FE_RE_25.Rmd:160-174

Legacy script contains the original Greens-only style mask:
- Evidence: Legacy_Replication/Analyse_FD_legacy_replication.Rmd:241-247

### 3.4 Masking is literal label matching (and therefore bypassed in turnout mode)

Masking is implemented via exact string checks on `party.index` values, i.e. literal comparisons such as:
- `party.index == "GRU"`
- `party.index == "AFD"`

Evidence:
- Current script: Analyse_FD_25.Rmd:288-301
- Legacy script: Legacy_Replication/Analyse_FD_legacy_replication.Rmd:246-257

In turnout mode, `party.index` is overwritten to a single label (`"Turnout"`) for all rows:
- Current script: Analyse_FD_25.Rmd:279-280
- Legacy script: Legacy_Replication/Analyse_FD_legacy_replication.Rmd:233-234

Implication by switch in turnout estimation:
- `party.selec.switch == 1`: no masking branch exists.
- `party.selec.switch == 2`: masking code block exists, but it does not match because labels are `"Turnout"`, not `"GRU"`/`"AFD"`.
- `party.selec.switch == 3`: same as switch 2; masking block exists but does not match any turnout rows.

So, in turnout estimation, masking is effectively not applied in either legacy 21 or current 25.

## 4) Why turnout and treatment case numbers differ

Two traced reasons:

1. Turnout mode changes treatment definition (not only outcome):
- In turnout mode, treatment is collapsed with max across selected parties.
- Evidence:
  - Legacy_Replication/Analyse_FD_legacy_replication.Rmd:105-108
  - Analyse_FD.Rmd:96-99
  - Analyse_FD_25.Rmd:124-129

2. The turnout panel in legacy visualization mixes baseline and turnout specifications:
- For i.turnout == 1, code filters by i.spillover == 0, not by i.turnout == 1.
- This intentionally compares baseline vs turnout in one panel.
- Evidence:
  - Legacy_Replication/Visualization_FD_legacy_replication_full.Rmd:70-75

3. Party masks that reduce main-effect rows do not carry over to turnout rows:
- Main effects can be reduced by GRU/AFD mask conditions in switch 2/3.
- Turnout rows are labeled `"Turnout"`, so those same literal mask checks do not fire.
- This contributes to the observed pattern where treated turnout counts can be higher than treated main-effect counts despite fewer total rows.

So labels like (39) and (42) can appear together because they come from different specifications shown in the same turnout panel.

## 5) Implication for the published figure

The greens-minor-only replication for the combined main effects and turnout figure reproduces the figure in the original paper draft.

That means:
- the paper does not use the alternative version where Greens are treated as major in 2021,
- the `green.mask.switch = 0` version in the legacy replication is the one that matches the published visual,
- and the `green.mask.switch = 1` version is the counterfactual figure that would differ.
