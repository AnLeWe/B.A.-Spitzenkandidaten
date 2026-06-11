# Codebook: `politskalo` — Politbarometer Approval Ratings

**Created from:** `Politskalo_Prep.Rmd`  
**Saved as:** `Data/politskalo.RData` (object: `politskalo`)  
**Unit of analysis:** One row per respondent × politician, election-month wave only  
**Years covered:** 2002, 2005, 2009, 2013, 2017, 2021 (no 2025 wave available)  
**Sources:** GESIS Politbarometer ZA3849/3850 (2002), ZA4258/4259 (2005), ZA5431/5432 (2009), ZA5677 (2013), ZA6988 (2017), ZA7856 (2021)

---

## Notes on source data structure

- **2002, 2005, 2009:** Fielded as separate **east** and **west** samples; files are combined with `dplyr::bind_rows()` before computing means (so the national average is sample-size-weighted, not 50/50). A `.src` flag marks origin: 1 = west, 2 = east.
- **2013, 2017, 2021:** Single combined national sample.
- **Wave selection:** September wave (election month). If no respondents fall in September, the latest available pre-election month is used (logged as a note during build).
- **Original documentation for 2009 is missing** from the GESIS variable reports; variable numbers for 2009 are based on the mapping used in `pb.config` and are not independently verified from a printed codebook.

---

## Variable cross-walk

Variable numbers by year. `—` = variable not collected. `(.src)` = derived from file-of-origin flag, not a V-variable.

| R name | 2002 | 2005 | 2009 | 2013 | 2017 | 2021 |
|---|---|---|---|---|---|---|
| `candidates` | — | — | — | — | — | — |
| `rating` | see §3 | see §3 | see §3 | see §3 | see §3 | see §3 |
| `year` | — | — | — | — | — | — |
| `study.id` | V1 | V1 | V1 | V1 | V1 | V1 |
| `respondent.id` | V2 | V2 | V2 | V2 | V2 | V2 |
| `survey.month` | V3 | V3 | V4 | V4 | V4 | V4 |
| `survey.week` | — | — | V5 | V5 | V5 | V5 |
| `survey.number` | V4 | — | — | — | — | — |
| `landline.mobile` | — | — | — | — | V6 | V340 |
| `bundesland` | V5 | V5 | V6 | V6 | V7 | V6 |
| `east.west` | (.src) | (.src) | (.src) | V7 | V8 | V7 |
| `municipality.size` | V6 | V6 | V8 | V8 | V9 | V8 |
| `gender` | V268 | V464 | V355 | V411 | V317 | V324 |
| `age` | V269 | V465 | V356 | V412 | V318 | V325 |
| `marital.status` | V270 | V466 | V357 | V413 | V319 | — |
| `cohabit.partner` | V271 | V467 | V358 | V414 | V320 | — |
| `education` | V287 | V483 | V374 | V430 | V321 | V326 |
| `state.exam` | V288 | V484 | V376 | V432 | V323 | V328 |
| `vocational.train` | V289 | V485 | V377 | V433 | V324 | V329 |
| `employment` | V290 | V486 | V378 | V434 | V325 | V330 |
| `job.at.risk` | V291 | V487 | V379 | V435 | V326 | V331 |
| `occupation` | V292 | V488 | V380 | V436 | V327 | V332 |
| `hh.size` | V293 | V489 | V381 | V437 | V328 | V333 |
| `hh.adults` | V294 | V490 | V382 | V438 | V329 | V334 |
| `union.member` | V298 | V494 | V383 | V439 | V330 | V335 |
| `religion` | V299 | V495 | V384 | V440 | V331 | V336 |
| `church.attendance` | V300 | V496 | V385 | V441 | V332 | V337 |
| `party.id` | V303 | V501 | V388 | V442 | V333 | V338 |
| `party.id.strength` | V304 | V502 | V389 | V443 | V334 | V339 |
| `weight.repr` | V308 | V505 | V392 | V446 | V335 | V341 |
| `weight.total` | V309 | V506 | V393 | V447 | V336 | V342 |

---

## 1. Identifiers and derived variables

### `candidates`
Politician name, taken from the key of `pb.config$vars`. String. Format: `"Lastname, Firstname"`.

### `rating`
Skalometer score for `candidates` in the election-month wave. Integer 1–11.  
Mapped from the raw Politbarometer scale of −5 to +5: raw value + 6 = stored value.

> **Question wording (consistent 2002–2021):**  
> *"Bitte sagen Sie mir wieder mit dem Thermometer von plus 5 bis minus 5, was Sie von einigen führenden Politikern und Politikerinnen halten. 'Plus 5' bedeutet, dass Sie sehr viel von dem Politiker halten. 'Minus 5' bedeutet, dass Sie überhaupt nichts von ihm halten."*  
> (2002/2005: "ihm halten" only; 2013+: gender-inclusive wording)

| Stored value | Original scale | Label |
|---|---|---|
| 1 | −5 | halte überhaupt nichts von dem Politiker |
| 2 | −4 | |
| 3 | −3 | |
| 4 | −2 | |
| 5 | −1 | |
| 6 | 0 | |
| 7 | +1 | |
| 8 | +2 | |
| 9 | +3 | |
| 10 | +4 | |
| 11 | +5 | halte sehr viel von dem Politiker |
| NA | 99 (KA) | keine Angabe — set to NA in `extract.raw.ratings()` |

**Out-of-range values** (< 1 or > 11 after conversion) are set to NA.

### `year`
Numeric, derived from the `pb.config` list key: 2002, 2005, 2009, 2013, 2017, 2021.

### `study.id` (V1 all years)
GESIS/ZA archive study number. Identifies the specific Politbarometer wave file.

### `respondent.id` (V2 all years)
Within-file respondent serial number.

### `survey.month` (V3 in 2002/2005; V4 in 2009–2021)
Month the interview was conducted (1–12). Used to select the election-month wave (September = 9).

### `survey.week`
Week number of interview. Not collected in 2002 and 2005.  
2009–2021: V5.

### `survey.number` (2002 only, V4)
Survey sequence number within 2002 (replaces `survey.week` in 2002, which has no V5).

### `.src`
Internal file-of-origin flag added before combining east/west files.  
1 = west sample (Festnetz west), 2 = east sample (Festnetz east).  
Present only in 2002, 2005, 2009; also used to populate `east.west` for those years.

---

## 2. Geography

### `bundesland`
Raw Politbarometer state code (integer, varies by year). Not recoded.

### `bundesland.label`
State name (character), mapped from `bundesland` via `bl.label.map`.  
Berlin West (code 11) and Berlin Ost (code 12) are both mapped to `"Berlin"`.  
2002 east uses codes 21–26 for the new Bundesländer; these are also mapped.

### `state`
Standardised 1–16 state number, mapped from `bundesland.label` via `bl.num.map`.

| Code | State |
|---|---|
| 1 | Schleswig-Holstein |
| 2 | Hamburg |
| 3 | Niedersachsen |
| 4 | Bremen |
| 5 | NRW |
| 6 | Hessen |
| 7 | Rheinland-Pfalz |
| 8 | Baden-Württemberg |
| 9 | Bayern |
| 10 | Saarland |
| 11 | Berlin |
| 12 | Brandenburg |
| 13 | Mecklenburg-Vorpommern |
| 14 | Sachsen |
| 15 | Sachsen-Anhalt |
| 16 | Thüringen |

### `east.west`
Respondent region.

> ⚠️ **Coding direction differs between years — do not compare raw values directly.**

| Year | Variable | 1 = | 2 = |
|---|---|---|---|
| 2002 | (.src) | west | east |
| 2005 | (.src) | west | east |
| 2009 | (.src) | west | east |
| 2013 | V7 | alte Bundesländer (West) | neue Bundesländer (Ost) |
| 2017 | V8 | neue Bundesländer (Ost) | alte Bundesländer (West) |
| 2021 | V7 | neue Bundesländer (Ost) | alte Bundesländer (West) |

**2013 is the reverse of 2017/2021.** Harmonise before pooling across years.

### `municipality.size`
Population size of municipality of residence.

| Code | Label |
|---|---|
| 1 | bis 2.000 Einwohner |
| 2 | bis 5.000 Einwohner |
| 3 | bis 10.000 Einwohner |
| 4 | bis 20.000 Einwohner |
| 5 | bis 50.000 Einwohner |
| 6 | bis 100.000 Einwohner |
| 7 | bis 500.000 Einwohner |
| 8 | über 500.000 Einwohner |
| 9 | KA |

Identical across all years. Not collected in 2005 west (V6 in east only; 2005 west V6 = different variable). See cross-walk.

### `landline.mobile`
Sample frame. Only collected from 2017 onward; set to 2 (= Festnetz) for earlier years in `Politskalo_Prep.Rmd` to allow pooling.

| Code | Label |
|---|---|
| 1 | Mobilfunkstichprobe |
| 2 | Festnetzstichprobe |
| 0 | not collected in this wave (TNZ, 2017 early weeks only) |

---

## 3. Politician approval ratings (Skalometer)

Politicians included per year. KK = Kanzlerkandidat/in.

| Year | Candidate (key in `politskalo`) | Party | V-number | KK? |
|---|---|---|---|---|
| 2002 | Fischer, Joschka | Grüne | V94 | |
| 2002 | Schröder, SPD | SPD | V103 | KK |
| 2002 | Stoiber, CDU | CDU/CSU | V105 | KK |
| 2002 | Westerwelle, Guido | FDP | V108 | |
| 2005 | Fischer, Joschka | Grüne | V143 | |
| 2005 | Gysi, Gregor | Linke | V144 | |
| 2005 | Lafontaine, Oskar | Linke | V147 | |
| 2005 | Merkel, CDU | CDU/CSU | V148 | KK |
| 2005 | Schröder, SPD | SPD | V154 | KK |
| 2005 | Westerwelle, Guido | FDP | V158 | |
| 2009 | Gysi, Gregor | Linke | V105 | |
| 2009 | Lafontaine, Oskar | Linke | V108 | |
| 2009 | Merkel, CDU | CDU/CSU | V109 | KK |
| 2009 | Steinmeiner, SPD | SPD | V116 | KK |
| 2009 | Westerwelle, Guido | FDP | V117 | |
| 2013 | Brüderle, Rainer | FDP | V114 | |
| 2013 | Merkel, Angela | CDU/CSU | V119 | KK |
| 2013 | Gysi, Gregor | Linke | V121 | |
| 2013 | Steinbrück, Peer | SPD | V124 | KK |
| 2013 | Trittin, Jürgen | Grüne | V126 | |
| 2017 | Lindner, Christian | FDP | V104 | |
| 2017 | Merkel, Angela | CDU/CSU | V107 | KK |
| 2017 | Özdemir, Cem | Grüne | V109 | |
| 2017 | Schulz, Martin | SPD | V111 | KK |
| 2017 | Wagenknecht, Sarah | Linke | V114 | |
| 2021 | Baerbock, Annalena | Grüne | V106 | KK |
| 2021 | Laschet, Armin | CDU/CSU | V110 | KK |
| 2021 | Lindner, Chrisitan | FDP | V112 | |
| 2021 | Scholz, Olaf | SPD | V116 | KK |
| 2021 | Wagenknecht, Sarah | Linke | V122 | |

**Missing by design:** AfD politicians not included in the Politbarometer in any year. Several Linke candidates in 2013 not rated (Göring-Eckardt, Wagenknecht, Bartsch, Ernst, van Aken, Lay, Gohlke, Golze). Weidel and Gauland (AfD, 2017), Wissler and Bartsch (Linke, 2021) also absent.

---

## 4. Demographics — personal

### `gender`
Interviewer-coded (asked only in case of doubt).

| Code | Label |
|---|---|
| 1 | männlich |
| 2 | weiblich |
| 9 | KA |

Identical across all years 2002–2021. No "divers" (code 3) introduced in any of these waves.

### `age`
*Fragetext:* "Wie alt sind Sie?"

| Code | Label (2002–2017) | Label (2021) |
|---|---|---|
| 1 | 18–20 Jahre | 18–20 Jahre |
| 2 | 21–24 Jahre | 21–24 Jahre |
| 3 | 25–29 Jahre | 25–29 Jahre |
| 4 | 30–34 Jahre | 30–34 Jahre |
| 5 | 35–39 Jahre | 35–39 Jahre |
| 6 | 40–44 Jahre | 40–44 Jahre |
| 7 | 45–49 Jahre | 45–49 Jahre |
| 8 | 50–59 Jahre | 50–59 Jahre |
| 9 | 60–69 Jahre | 60–69 Jahre |
| 10 | 70 Jahre und älter | 70–79 Jahre |
| 11 | — | **80 Jahre und älter** |
| 99 | KA | KA |

> ⚠️ **2021 splits code 10 (70+) into two categories.** Harmonise to 10-category scheme (recode 11→10) before pooling if needed.

### `marital.status`
*Fragetext:* "Was ist Ihr Familienstand? (Vorlesen!)"

| Code | Label |
|---|---|
| 1 | verheiratet |
| 2 | verheiratet, aber getrennt lebend |
| 3 | ledig |
| 4 | geschieden |
| 5 | verwitwet |
| **6** | **eingetragene Lebenspartnerschaft** (2005+ only) |
| 9 | KA |

> ⚠️ **Code 6 absent in 2002.** Not collected in 2021.

### `cohabit.partner`
*Fragetext:* "Wohnen Sie mit einem/r Lebensgefährten/-in zusammen?"  
Asked only if respondent is not married/partnered (TNZ = 0).

| Code | Label |
|---|---|
| 0 | TNZ (verheiratet / eingetragene LP) |
| 1 | ja |
| 2 | nein |
| 9 | KA |

Identical across all years where collected. Not collected in 2021.

---

## 5. Education and employment

### `education`
*Fragetext:* "Welchen Schulabschluss haben Sie selbst?"

**2002 (west), 2005 (west), 2013–2021 — 5-category scheme:**

| Code | Label |
|---|---|
| 1 | Hauptschulabschluss / Volksschule (Ost: frühere 8-klassige Schule) |
| 2 | Mittlere Reife / Realschulabschluss (Ost: frühere 10-klassige POS) |
| 3 | Abitur / Hochschulreife / Fachhochschulreife (Ost: frühere 12-klassige EOS) |
| 4 | kein Schulabschluss |
| 5 | noch in der Schule |
| 9 | KA |

**2005 east — 7-category scheme (different, not harmonised in source):**

| Code | Label |
|---|---|
| 1 | Hauptschulabschluss (frühere 8-klassige Schule) |
| 2 | Mittlere Reife (frühere 10-klassige POS) |
| 3 | Abitur (frühere 12-klassige EOS) |
| 4 | abgeschlossenes Fachschulstudium |
| 5 | abgeschlossenes Universitäts-/Hochschul-/FH-Studium |
| 6 | kein Hauptschulabschluss |
| 7 | noch in der Schule |
| 9 | KA |

> ⚠️ **2005 east has 7 categories** including "Fachschulstudium" (code 4) and "Uni/FH-Studium" (code 5) that are absent from all other years. The raw variable for east respondents in 2005 uses this scheme.

### `state.exam`
*Fragetext:* "(Falls Abitur/Hochschulreife): Haben Sie ein abgeschlossenes Studium an einer Universität, Hochschule oder Fachhochschule?"

| Code | Label |
|---|---|
| 0 | TNZ (kein Abitur) |
| 1 | ja |
| 2 | nein |
| 9 | KA |

Identical across all years. **Note:** The 2005 variable number is V484 (not V284, which is an attitudinal item).

### `vocational.train`
*Fragetext:* "(Falls nicht mehr in der Schule): Haben Sie eine abgeschlossene Lehre?"

| Code | Label |
|---|---|
| 0 | TNZ (noch in der Schule) |
| 1 | ja |
| 2 | nein |
| 9 | KA |

Identical across all years.

### `employment`
*Fragetext:* "Sind Sie zur Zeit berufstätig? (Nicht vorlesen!)"

| Code | Label (2002/2005) | Label (2013+) |
|---|---|---|
| 0 | TNZ (noch in der Schule) | TNZ |
| 1 | voll beschäftigt | voll beschäftigt |
| 2 | teilzeit beschäftigt | teilzeit beschäftigt |
| 3 | in Kurzarbeit | in Kurzarbeit |
| 4 | Erziehungsurlaub / Mutterschutz | Elternzeit / Mutterschutz |
| 5 | arbeitslos, in Umschulungsmaßnahme | arbeitslos, in Umschulungsmaßnahme |
| 6 | arbeitslos, ohne Umschulungsmaßnahme | arbeitslos, ohne Umschulungsmaßnahme |
| 7 | Rente / Pension / Vorruhestand | Rente / Pension / Vorruhestand |
| 8 | in Ausbildung / (Hoch-)Schule | in Ausbildung / (Hoch-)Schule |
| 9 | **Wehr-/Zivildienst** | **Bundesfreiwilligendienst / Freiwilliges Soz./Ökol. Jahr** |
| 10 | nicht berufstätig / Hausfrau / Hausmann | nicht berufstätig / Hausfrau / Hausmann |
| 99 | KA | KA |

> ⚠️ **Code 9 changes content:** "Wehr-/Zivildienst" in 2002/2005; "Bundesfreiwilligendienst" in 2013+. Do not pool code 9 across the break without recoding.

### `job.at.risk`
*Fragetext:* "(Falls berufstätig): Halten Sie Ihren Arbeitsplatz für sicher oder für gefährdet?"

| Code | Label |
|---|---|
| 0 | TNZ (nicht berufstätig) |
| 1 | für sicher |
| 2 | für gefährdet |
| 9 | KA |

Identical codes in all years.

### `occupation`
*Fragetext:* "(Falls berufstätig oder war berufstätig): Sind/Waren Sie...? (nur Haupttätigkeit)"

**2002 and 2005 — two-digit codes 01–15:**

| Code | Label |
|---|---|
| 01 | Arbeiter/in: ungelernt oder angelernt / Landarbeiter |
| 02 | Facharbeiter |
| 03 | Meister |
| 04 | Angestellte/r, einfache Tätigkeit |
| 05 | Angestellte/r, gehobene Tätigkeit |
| 06 | Angestellte/r, leitende Tätigkeit |
| 07 | Beamter, einfacher Dienst |
| 08 | Beamter, mittlerer Dienst |
| 09 | Beamter, gehobener Dienst |
| 10 | Beamter, höherer Dienst |
| 11 | Richter/in |
| 12 | Soldat/in |
| 13 | Selbständig |
| 14 | Landwirt/in (selbständig) |
| 15 | Hausfrau / Hausmann |
| 99 | KA |
| 00 | TNZ |

**2013, 2017, 2021 — single-digit codes 1–16:**

| Code | Label |
|---|---|
| 0 | TNZ |
| 1 | Arbeiter/in (ungelernt/angelernt — merged) |
| 2 | Facharbeiter/in |
| 3 | Meister/in |
| 4 | Angestellte/r, einfache Tätigkeit |
| 5 | Angestellte/r, gehobene Tätigkeit |
| 6 | Angestellte/r, leitende Tätigkeit |
| 7 | Beamter/Beamtin, einfacher Dienst |
| 8 | Beamter/Beamtin, mittlerer Dienst |
| 9 | Beamter/Beamtin, gehobener Dienst |
| 10 | Beamter/Beamtin, höherer Dienst |
| 11 | Richter/in |
| 12 | Soldat/in / Freiwilliger Wehrdienst (2017+) |
| 13 | Selbständig |
| 14 | Landwirt/in (selbständig) |
| 15 | Hausfrau / Hausmann |
| **16** | **hatte noch nie einen Beruf** (2013+ only) |
| 99 | KA |

> ⚠️ **Coding break between 2002/2005 and 2013+:** two-digit vs. one-digit codes; code 16 added. Harmonise before pooling.

---

## 6. Household composition

### `hh.size`
*Fragetext:* "Wieviele Personen leben insgesamt in Ihrem Haushalt, Sie selbst mit eingeschlossen?"

| Code | Label |
|---|---|
| 1 | 1 Person |
| 2 | 2 Personen |
| 3 | 3 Personen |
| 4 | 4 Personen |
| 5 | 5 und mehr Personen |
| 9 | KA |

Identical across all years.

### `hh.adults`
*Fragetext:* "(Falls mehr als eine Person im Haushalt): Wieviele Personen in Ihrem Haushalt sind 18 Jahre und älter?"

| Code | Label |
|---|---|
| 0 | TNZ (single-person household) |
| 1 | 1 Person |
| 2 | 2 Personen |
| 3 | 3 Personen |
| 4 | 4 Personen |
| 5 | 5 und mehr Personen |
| 9 | KA |

Identical across all years.

### `union.member`
*Fragetext:* "Sind Sie selbst oder jemand anderes in Ihrem Haushalt Mitglied einer Gewerkschaft?"

| Code | Label |
|---|---|
| 1 | ja, selbst |
| 2 | ja, nur andere(r) |
| 3 | ja, selbst und andere(r) |
| 4 | nein |
| 9 | KA |

Identical codes in all years.

---

## 7. Religion

### `religion`
*Fragetext:* "Welcher Konfession oder Glaubensgemeinschaft gehören Sie an? (Nicht vorlesen!)"

**Harmonised in `Politskalo_Prep.Rmd`** to the 6-category 2005+ scheme. 2002 originally had only 5 categories (no separate "Jude/Jüdin"); codes 4 ("andere") and 5 ("keiner") were shifted to 5 and 6 respectively. Code 4 (jüdisch/Jude/Jüdin) has no 2002 observations by construction.

| Code | Label | Notes |
|---|---|---|
| 1 | katholisch | |
| 2 | protestantisch/evangelisch | |
| 3 | muslimisch/Islam | 2002/2005 original wording: "Moslem/Moslime" |
| 4 | jüdisch / Jude/Jüdin | No 2002 observations (was absorbed into "andere" in 2002) |
| 5 | andere / anderer | Includes any Jewish respondents from 2002 |
| 6 | keiner | |
| 9 | KA |  |

### `church.attendance`
*Fragetext:* "(Falls einer Konfession angehörig): Wie oft gehen Sie im allgemeinen zur Kirche? Gehen Sie..."  
**Filter (2013+):** Asked only for Catholics and Protestants/Evangelicals (codes 1–2 in `religion`). In 2002/2005 the filter was any Konfession (codes 1–4/5).

| Code | Label (2002/2005) | Label (2013+) |
|---|---|---|
| 0 | TNZ (keine Konfession) | TNZ |
| 1 | jeden Sonntag | **jede Woche** |
| 2 | fast jeden Sonntag | **fast jede Woche** |
| 3 | ab und zu | ab und zu |
| 4 | einmal im Jahr | einmal im Jahr |
| 5 | seltener | seltener |
| 6 | nie | nie |
| 9 | KA | KA |

> ⚠️ Minor wording change 2013+ ("jede/fast jede Woche" vs. "jeden/fast jeden Sonntag"). TNZ population changes because 2013+ excludes non-Christian religions from the question.

---

## 8. Political affiliation

### `party.id`
*Fragetext:* "In Deutschland neigen viele Leute längere Zeit einer bestimmten politischen Partei zu, obwohl sie auch ab und zu eine andere Partei wählen. Wie ist das bei Ihnen: Neigen Sie - ganz allgemein gesprochen - einer bestimmten Partei zu? Wenn ja, welcher? (Nicht vorlesen!)"

| Code | 2002 | 2005 | 2013 | 2017 | 2021 |
|---|---|---|---|---|---|
| 01 | SPD | SPD | SPD | SPD | SPD |
| 02 | CDU | CDU | CDU | CDU | CDU |
| 03 | CDU/CSU | CDU/CSU | CDU/CSU | CDU/CSU | CDU/CSU |
| 04 | CSU | CSU | CSU | CSU | CSU |
| 05 | FDP | FDP | FDP | FDP | FDP |
| 06 | Bündnis 90/Grüne | Bündnis 90/Grüne | Bündnis 90/Grüne | die Grünen | Bündnis 90/Grüne |
| 07 | PDS | PDS | die Linke | die Linke | die Linke |
| 08 | Republikaner | Republikaner | NPD/DVU/Republikaner | **AfD** | **AfD** |
| 09 | andere | andere | andere | NPD/DVU/Republikaner | NPD/Republikaner |
| 10 | nein | nein | nein | andere | andere |
| 11 | weiß nicht | weiß nicht | weiß nicht | nein | nein |
| 12 | — | — | — | weiß nicht | weiß nicht |
| 99 | KA/verweigert | KA/verweigert | KA | KA | KA |

> ⚠️ **Party landscape changes substantially.** AfD added from 2017. PDS renamed to Linke in 2013. Do not treat codes as comparable across years without a party-name lookup.

### `party.id.strength`
*Fragetext:* "(Falls einer Partei zuneigend): Wie stark oder wie schwach neigen Sie - alles zusammengenommen - dieser Partei zu? (Vorlesen!)"

| Code | Label |
|---|---|
| 0 | TNZ (keine Parteineigung) |
| 1 | sehr stark |
| 2 | ziemlich stark |
| 3 | mäßig |
| 4 | ziemlich schwach |
| 5 | sehr schwach |
| 9 | KA |

Identical across all years.

---

## 9. Survey weights

### `weight.repr`
Faktor Repräsentativgewicht. Continuous (float). Corrects for differential sampling probabilities within the design (e.g., household size weighting in single-number RLD sampling). Apply for nationally representative estimates of individual attitudes.

### `weight.total`
Faktor Gesamtgewicht. Continuous (float). Combines representativity weight with a post-stratification rim weight (gender × age × education × Bundesland). Use for frequency distributions of socio-demographic variables.

---

## 10. Derived variables (computed in `Politskalo_Prep.Rmd`)

The following are not sourced from the SAV files but computed during processing:

| Variable | How derived |
|---|---|
| `bundesland.label` | `bl.label.map[as.character(bundesland)]` — maps Politbarometer state codes to state names |
| `state` | `bl.num.map[bundesland.label]` — standardised 1–16 code |
| `year` | From the `pb.config` list key (character year cast to numeric) |
| `candidates` | From the `pb.config$vars` key (politician name as string) |
| `rating` | Raw V-variable value; out-of-range (< 1 or > 11) and KA (99) set to NA |
| `landline.mobile` (fill) | Set to 2L (Festnetz) for 2002–2013 in `Politskalo_Prep.Rmd` after build (mobile sampling began 2017) |
| `.src` | 1L (west file) or 2L (east file), added before `bind_rows()` for split years |

---

## Summary of cross-year comparability issues

| Variable | Issue | Recommendation |
|---|---|---|
| `east.west` | Coding reversed in 2013 vs. 2017/2021 | Recode 2013: 1→2, 2→1 before pooling |
| `age` | 2021 splits 70+ into two categories | Recode 11→10 in 2021 for pooled analysis |
| `marital.status` | Code 6 (Lebenspartnerschaft) absent in 2002; variable absent in 2021 | Treat 2002 as 5-category; handle 2021 as missing |
| `religion` | 2002 originally 5 categories; **harmonised to 6-category scheme in prep script** (codes 4→5, 5→6 for 2002). Code 4 (jüdisch) has no 2002 obs. | |
| `church.attendance` | TNZ filter changes 2013 (Catholics + Protestants only) | TNZ population is smaller in 2013+ |
| `education` | 2005 east uses 7-category scheme | Recode 2005 east to 5-category if pooling west + east |
| `occupation` | Two-digit codes 01–15 (2002/2005) vs. one-digit 1–16 (2013+) | Recode to common scheme; add NA for code 16 in 2002/2005 |
| `employment` | Code 9 = Wehr-/Zivildienst (2002/2005) vs. Bundesfreiwilligendienst (2013+) | Note content change; small N category in either case |
| `party.id` | Parties change across elections; AfD from 2017 | Use party labels not codes |
| `state.exam` | 2005 mapping was erroneously set to V284 (attitudinal item) | Corrected to V484 in `Politskalo_Prep.Rmd` |
