# Priming & Leader Effects in Germany

Data, code, and files for my Bachelor Thesis on priming and leader effects in German federal elections (Bundestagswahlen 2002–2021).

## Project Overview

This repository contains everything needed to replicate the analyses: data preparation, descriptive statistics, fixed-effects and first-differences regressions, and visualizations. The empirical basis is the **Politbarometer** cumulative dataset (ZA2391/ZA8573, GESIS), supplemented by official BTW structural data from the Bundeswahlleiter.

## Repository Structure

| File / Folder | Description |
|---|---|
| `Data_Prep.Rmd` | Data cleaning and variable construction |
| `Descriptive_Analysis.Rmd` | Descriptive statistics and summary tables |
| `Analyse_FD.Rmd` / `Analyse_FD_25.Rmd` | First-differences (FD) regression models |
| `Analyse_FE.Rmd` | Fixed-effects (FE) regression models |
| `Analyse_FE_RE.Rmd` / `Analyse_FE_RE_25.Rmd` | FE/RE comparison models |
| `Visualization_FD.Rmd` | Coefficient plots and result visualizations |
| `Coverage_Matrix.Rmd` | Politbarometer candidate coverage matrix |
| `Table_Generator.Rmd` | LaTeX/HTML table output |
| `candidate_verification.md` | Sourced verification of all SK/KK (BTW 2002–2021) |
| `Data/` | Raw and processed data files |
| `Outputs/` | Generated tables, figures, and model objects |
| `BTW_Strukturdaten/` | Official BTW structural data (Bundeswahlleiter) |
| `Karten_WK/` | Constituency map files |

## Data

The raw Politbarometer data is **not included** in this repository due to licensing restrictions (GESIS use agreement). It can be downloaded from [GESIS](https://www.gesis.org) (study numbers ZA2391 / ZA8573).

All supplementary files (processed data, outputs, and additional materials) are available on **Google Drive**:

🗂️ **[Open project folder on Google Drive](https://drive.google.com/drive/folders/1DO4jQlf_mEw0-w5F9CJjkiaNFusmemk8?usp=drive_link)**

## Requirements

- R ≥ 4.2
- Key packages: `tidyverse`, `fixest`, `modelsummary`, `haven`, `sf`

## Contact

Anna-Lena Werner — Bachelor Thesis, Political Science
