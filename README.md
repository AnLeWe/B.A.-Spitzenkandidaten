# Priming & Leader Effects in Germany

Replication repository for the research paper on priming and leader effects in German federal elections (Bundestagswahlen 2002–2021/2025).

**Paper (Overleaf):** https://www.overleaf.com/project/64466dbd557b25b030dea621  
**Supplementary files (Google Drive):** https://drive.google.com/drive/folders/1DO4jQlf_mEw0-w5F9CJjkiaNFusmemk8?usp=drive_link  
**Related data repository:** [SuShikano/BTW-districts](https://github.com/SuShikano/BTW-districts)

## Abstract

In parliamentary systems, research has demonstrated the substantial impact of party leaders on voter decisions depending on the institutional context, the degree of person-centered campaigning style of political parties, and further factors. However, previous studies paid less attention to the mechanisms under which such campaign styles affect voter decisions. At least two different mechanisms are possible: priming and mobilization. To examine which of these mechanisms is at work, the mixed-member system offers an interesting case since leading politicians can run in two different ways for office while their candidacy can affect the results of both tiers through contamination effects. This makes it possible to derive the implications of different mechanisms from district-level election results. By applying the first-differenced estimator to district-level election results from German Bundestag elections since 2002, we demonstrate that the priming effect is more likely than the mobilization effect.

## Data

### Bundeswahlleiter constituency vote results

The BTW Kerg CSV files (*Endgültige Ergebnisse nach Wahlkreisen*) are the backbone of all analyses. They contain first- and second-vote (*Erst-/Zweitstimmen*) counts by constituency (*Wahlkreis*) for each election year. Files for 2002–2025 are included in `Data/btw_kerg/` and are publicly available from the [Federal Returning Officer](https://www.bundeswahlleiter.de/bundestagswahlen/2021/ergebnisse.html).

### Politbarometer

Individual-year Politbarometer survey files from GESIS are included in `Data/politbarometer/` for all election years 2002–2021 (both `.dta` and `.sav` formats). These are used to construct the candidate-coverage treatment variable (whether a *Spitzenkandidat*/*Kanzlerkandidat* ran as a direct candidate in a constituency).

| GESIS study | Year | Coverage |
|---|---|---|
| ZA3849 / ZA3850 | 2002 | East / West |
| ZA4258 / ZA4259 | 2005 | East / West |
| ZA5431 / ZA5432 | 2009 | East / West |
| ZA5677 | 2013 | Combined |
| ZA6988 | 2017 | Combined |
| ZA7856 | 2021 | Combined |

### ARD Deutschlandtrend

`Data/ARD_Deutschlandtrend/` contains the questionnaire/codebook PDFs only (ZA4594, ZA4597, ZA5448, ZA5915, ZA6987, ZA7863, ZA9050). The actual survey data is not included in this repository.

### Structural data

`BTW_Strukturdaten/` contains official constituency structural data (*Strukturdaten*) from the Bundeswahlleiter for all election years 2002–2025.

## Repository Structure

### Analysis scripts

| File | Description |
|---|---|
| `Data_Prep.Rmd` | Data cleaning and variable construction |
| `Descriptive_Analysis.Rmd` | Descriptive statistics and summary tables |
| `Analyse_FD_25.Rmd` | First-differences (FD) regression models (BTW 2002–2025) |
| `Analyse_FE_RE_25.Rmd` | FE/RE comparison models (BTW 2002–2025) |
| `Visualization_FD.Rmd` | Coefficient plots and result visualizations |
| `Table_Generator.Rmd` | LaTeX/HTML table output |
| `run_fd_combos.R` | Batch render script for all 9 FD switch combinations |

### `docs/`

| File | Description |
|---|---|
| `candidate_verification.md` | Sourced verification of all SK/KK direct candidacies (BTW 2002–2021) |
| `data_inspection_summary.txt` | Column and NA summary of processed datasets |
| `Analysis_21_vs_25_Differences.md` | Traced comparison of 2021 legacy vs 2025 pipelines |
| `Analysis_Implementation_Notes.md` | Treatment matching logic, data issues, and diagnostic notes |

### `BTW_2021/` — BTW 2002–2021 archive

All scripts, outputs, and figures for the 2002–2021 analysis.

**`BTW_2021/Legacy_Replication/`** — runnable replication pipeline and archived pre-2025 scripts:

| File | Description |
|---|---|
| `Data_Prep_legacy_21.Rmd` / `.html` | Legacy data preparation for BTW 2002–2021 |
| `Analyse_FD_legacy_replication.Rmd` / `.html` | Legacy first-differences replication analysis |
| `Visualization_FD_legacy_replication_full.Rmd` / `.html` | Legacy replication figures and result visualizations |
| `Analyse_FD.Rmd` / `.html` | Archived FD script (superseded by `Analyse_FD_25.Rmd`) |
| `Analyse_FE.Rmd` | Archived FE script (superseded) |
| `Analyse_FE_RE.Rmd` / `.html` | Archived FE/RE script (superseded by `Analyse_FE_RE_25.Rmd`) |

**`BTW_2021/Outputs/`** — estimation results and figures for BTW 2002–2021:

| Path | Contents |
|---|---|
| `First_Differencing/` | FD estimation results |
| `Figures/` | Coefficient plots and visualizations (incl. H3a/H3b) |
| `Exogeneity/` | Exogeneity check results |
| `FD_Incumbency/` | Incumbency model results |
| `Legacy_Replication/` | Legacy replication outputs and rerun artifacts |
| `Legacy_Replication/Figures/` | Final legacy replication figures |

### `BTW_2025/` — BTW 2002–2025 current analysis

**`BTW_2025/Outputs/`** — estimation results for the current analysis including BTW 2025:

| Path | Contents |
|---|---|
| `First_Differencing/` | FD estimation results and `.RData` files |
| `First_Differencing/Figures/` | Coefficient plots and result visualizations |
| `Fixed_Effects/` | FE estimation results |
| `Diagnostics/` | Treatment variable diagnostics (2021 vs 2025 comparison) |

### `Data/`

#### Current analysis data
| Path | Contents |
|---|---|
| `btw_kerg/` | Bundeswahlleiter Kerg CSVs, BTW 2002–2025 |
| `Politbarometer/` | Politbarometer survey files for BTW 2002–2021 (`.dta` and `.sav` formats) from GESIS |
| `ARD_Deutschlandtrend/` | Deutschlandtrend questionnaire PDFs (no data) |
| `Misc_BTW2025/` | BTW 2025 auxiliary files (party list, Wahlkreis names, municipality mapping) |
| `analysis_dat.RData` | Final pooled analysis dataset |
| `data_now.RData` / `data_then.RData` | Processed election-result datasets |
| `btw_all_shape.RData` | Spatial data for constituencies |
| `Treatment_WK.xlsx` | Current treatment variable assignment per Wahlkreis |
| `Wahlkreis_names.xlsx` | Constituency name lookup |
| `data_now_WK_Einteilung.xlsx` | Wahlkreis assignment table |
| `ModelSummaries.xlsx` | Model coefficient summary table |

#### Legacy data files (BTW 2002–2021 replication)
| Path | Contents |
|---|---|
| `analysis_dat_legacy21.RData` | Prepared analysis dataset for legacy BTW 2002–2021 replication pipeline |
| `Treatment_WK_pre2025_from_git.xlsx` | Recovered legacy treatment workbook used in original 2021-based models |

### `BTW_Strukturdaten/`

Structural data CSVs from the Bundeswahlleiter for 2002, 2005, 2009, 2013, 2017, 2021, and 2025.

### `Karten_WK/`

Constituency map PDFs from the Bundeswahlleiter for BTW 2002–2021.

## Requirements

- R >= 4.2 (developed on R 4.6.0)
- Key packages: `tidyverse`, `fixest`, `modelsummary`, `haven`, `readxl`, `sandwich`, `lmtest`, `sf`, `spdep`, `rmarkdown`
- See `docs/r_session_info.txt` for versions. For a fully pinned environment, run `renv::init()` + `renv::snapshot()` from within the project.
