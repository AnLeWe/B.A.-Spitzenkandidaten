# Priming & Leader Effects in Germany

Working repository for the research paper on priming and leader effects in German federal elections (Bundestagswahlen 2002–2021/2025).

## Abstract

In parliamentary systems, research has demonstrated the substantial impact of party leaders on voter decisions depending on the institutional context, the degree of person-centered campaigning style of political parties, and further factors. However, previous studies paid less attention to the mechanisms under which such campaign styles affect voter decisions. At least two different mechanisms are possible: priming and mobilization. To examine which of these mechanisms is at work, the mixed-member system offers an interesting case since leading politicians can run in two different ways for office while their candidacy can affect the results of both tiers through contamination effects. This makes it possible to derive the implications of different mechanisms from district-level election results. By applying the first-differenced estimator to district-level election results from German Bundestag elections since 2002, we demonstrate that the priming effect is more likely than the mobilization effect.

## Related Repository

This project is connected to **[SuShikano/BTW-districts](https://github.com/SuShikano/BTW-districts)**, which provides the prepared district-level BTW data used as an input here.

## Data Overview

### Primary: Bundeswahlleiter constituency vote results ✅ present

The BTW Kerg CSV files (*Endgültige Ergebnisse nach Wahlkreisen*) are the backbone of all analyses. They contain first- and second-vote (*Erst-/Zweitstimmen*) counts by constituency (*Wahlkreis*) for each election year. Files for 2002–2025 are included in `Data/btw_kerg/` and are publicly available from the [Federal Returning Officer](https://www.bundeswahlleiter.de/bundestagswahlen/2021/ergebnisse.html).

### Supplementary: Politbarometer ✅ present

Individual-year Politbarometer survey files from GESIS are included in `Data/politbarometer/` for all election years 2002–2021 (both `.dta` and `.sav` formats):

| GESIS study | Year | Coverage |
|---|---|---|
| ZA3849 / ZA3850 | 2002 | East / West |
| ZA4258 / ZA4259 | 2005 | East / West |
| ZA5431 / ZA5432 | 2009 | East / West |
| ZA5677 | 2013 | Combined |
| ZA6988 | 2017 | Combined |
| ZA7856 | 2021 | Combined |

These are used to construct the candidate-coverage treatment variable (whether a *Spitzenkandidat*/*Kanzlerkandidat* ran as a direct candidate in a constituency).

### ARD Deutschlandtrend ⚠️ questionnaire PDFs only — no data

`Data/ARD_Deutschlandtrend/` contains only the **questionnaire/codebook PDFs** (ZA4594, ZA4597, ZA5448, ZA5915, ZA6987, ZA7863, ZA9050). The actual survey data is **not available** in this repository.

### Structural data ✅ present

`BTW_Strukturdaten/` contains official constituency structural data (*Strukturdaten*) from the Bundeswahlleiter for all election years 2002–2025.

### Supplementary processed files & outputs

All additional materials (processed data, model outputs, figures) are available on **Google Drive**:

🗂️ **[Open project folder on Google Drive](https://drive.google.com/drive/folders/1DO4jQlf_mEw0-w5F9CJjkiaNFusmemk8?usp=drive_link)**

## Repository Structure

### Analysis scripts (root)

| File | Description |
|---|---|
| `Data_Prep.Rmd` | Data cleaning and variable construction |
| `Descriptive_Analysis.Rmd` | Descriptive statistics and summary tables |
| `Analyse_FD.Rmd` / `Analyse_FD_25.Rmd` | First-differences (FD) regression models (BTW 2002–2021 / +2025) |
| `Analyse_FE.Rmd` | Fixed-effects (FE) regression models |
| `Analyse_FE_RE.Rmd` / `Analyse_FE_RE_25.Rmd` | FE/RE comparison models |
| `Visualization_FD.Rmd` | Coefficient plots and result visualizations |
| `Coverage_Matrix.Rmd` | Politbarometer candidate coverage matrix |
| `Table_Generator.Rmd` | LaTeX/HTML table output |
| `candidate_verification.md` | Sourced verification of all SK/KK (BTW 2002–2021) |
| `data_inspection_summary.txt` | Column and NA summary of processed datasets |

### `Data/`

| Path | Contents | Present |
|---|---|---|
| `btw_kerg/` | Bundeswahlleiter Kerg CSVs, BTW 2002–2025 | ✅ |
| `politbarometer/` | Politbarometer year files, 2002–2021 (.dta/.sav) | ✅ |
| `ARD_Deutschlandtrend/` | Deutschlandtrend questionnaire PDFs (no data) | ⚠️ PDFs only |
| `Misc_BTW2025/` | BTW 2025 auxiliary files (party list, Wahlkreis names, municipality mapping) | ✅ |
| `analysis_dat.RData` | Final pooled analysis dataset | ✅ |
| `data_now.RData` / `data_then.RData` | Processed election-result datasets | ✅ |
| `btw_all_shape.RData` | Spatial / shape data for constituencies | ✅ |
| `Treatment_WK.xlsx` | Treatment variable per Wahlkreis | ✅ |
| `Wahlkreis_names.xlsx` | Constituency name lookup | ✅ |
| `data_now_WK_Einteilung.xlsx` | Wahlkreis assignment table | ✅ |
| `ModelSummaries.xlsx` | Model coefficient summary table | ✅ |
| `coverage_matrix.md` | Candidate coverage matrix (markdown) | ✅ |

### `BTW_Strukturdaten/`

Structural data CSVs for 2002, 2005, 2009, 2013, 2017, 2021, 2025.

### `Outputs/`

| Path | Contents |
|---|---|
| `Estimation_Results_21/` | Full FD/FE estimation results, exogeneity checks, incumbency models, and figures for BTW 2002–2021 |
| `Estimation_Results_21/Figures/` | Coefficient plots and visualizations |
| `Estimation_Results_25/First_Differencing/` | FD estimation results including BTW 2025 |

### `Karten_WK/`

Constituency map PDFs (Bundeswahlleiter) for BTW 2002–2021.

## Requirements

- R ≥ 4.2
- Key packages: `tidyverse`, `fixest`, `modelsummary`, `haven`, `sf`

## Contact

Anna-Lena Werner
