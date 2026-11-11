The Global Evolution and Clinical Translation of Therapeutic Neoantigen NSCLC Vaccines
A scoping review of the historical evolution, global clinical-trial landscape, and translational readiness of therapeutic vaccines for non-small cell lung cancer (NSCLC).
![Review](https://img.shields.io/badge/Study-Scoping%20Review-235789)
![Trials](https://img.shields.io/badge/Unique%20Trials-184-007C78)
![Neoantigen](https://img.shields.io/badge/Personalized%20Neoantigen%20Trials-39-B65C50)
![Registry Cutoff](https://img.shields.io/badge/Registry%20Cutoff-17%20Aug%202026-666666)
About this repository
This repository accompanies the research manuscript “The Global Evolution and Clinical Translation of Therapeutic Neoantigen Non-Small Cell Lung Cancer Vaccines – A Scoping Review.” It contains research materials supporting the identification, classification, descriptive analysis, and visualization of registered therapeutic NSCLC vaccine trials.
Therapeutic NSCLC vaccine development has progressed from approaches targeting conventional tumor-associated antigens toward individualized neoantigen strategies enabled by tumor sequencing, computational antigen prioritization, and novel vaccine delivery platforms. This review maps that transition while evaluating clinical-development phases, geographic participation, vaccine platforms, therapeutic combinations, outcome measures, and cross-registry reporting consistency.
Scope: This is a registry-based evidence synthesis, not an experimentally validated vaccine-design pipeline, a meta-analysis of treatment efficacy, or a source of clinical treatment recommendations.
Study at a glance
Metric	Manuscript finding
Registry search cutoff	17 August 2026
Records identified before screening/deduplication	323
Unique eligible therapeutic NSCLC vaccine trial protocols	184
Conventional tumor-associated antigen vaccine trials	145 (78.80%)
Personalized neoantigen vaccine trials	39 (21.20%)
Personalized neoantigen Phase III protocols identified	3
Neoantigen trials evaluating combination regimens	27/39 (69.23%)
Neoantigen trials involving vaccine monotherapy ± adjuvant	12/39 (30.77%)
Personalized trials found in both ClinicalTrials.gov and WHO ICTRP	16/39 (41.03%)
Personalized trials found only through ClinicalTrials.gov	19/39 (48.72%)
Personalized trials found only through WHO ICTRP search	4/39 (10.26%)
The counts above describe the manuscript's defined trial-level dataset. A unique trial protocol is not the same as a registry record or a distinct vaccine product. Percentages use the denominators indicated.
Research objectives
Trace the historical development of therapeutic NSCLC vaccine trials, comparing conventional antigen approaches with personalized neoantigen strategies.
Map the global geographic distribution and temporal registration trends of eligible trials.
Characterize vaccine platforms, clinical phases, treatment combinations, recruitment status, and outcomes.
Compare ClinicalTrials.gov and the WHO International Clinical Trials Registry Platform (ICTRP) for trial coverage and reporting discrepancies.
Examine barriers to clinical translation, including efficacy evidence, manufacturing reproducibility, reporting completeness, and representation across regions.
Methods
The study followed the Joanna Briggs Institute (JBI) approach to scoping reviews and the PRISMA Extension for Scoping Reviews (PRISMA-ScR). Registered trials were identified through ClinicalTrials.gov and WHO ICTRP, with supplementary searches using vaccine product names and development codes. The historical registry search covered records from inception to 17 August 2026.
Eligible records were interventional therapeutic vaccine trials involving NSCLC, including trials of mixed solid tumors that explicitly enrolled an NSCLC population. The personalized neoantigen subset was analyzed separately from the wider historical conventional-vaccine cohort. Observational, preclinical, prophylactic, non-NSCLC, and otherwise ineligible records were excluded as specified in the study protocol.
Trial identifiers and study characteristics were reconciled to remove duplicate registry records while retaining distinct trial protocols. Extracted variables included registration dates, phase, recruitment status, enrollment, vaccine platform, location, sponsor, treatment regimen, and safety, immunogenicity, or clinical endpoints. Missing fields were coded as “Not reported.”
Descriptive analyses and visualizations were performed in R 4.5.2 using packages including tidyverse and ggplot2. No efficacy meta-analysis was performed.
Interpretation of dates: The review maintains a registry inclusion cutoff of 17 August 2026. Where the revised manuscript discusses subsequent registry updates or milestones (for example, a September 2026 recruitment update), those updates should be interpreted separately from the original inclusion snapshot and are not evidence that the search cutoff was extended.
Main findings
1. Evolution of the therapeutic vaccine landscape
The manuscript distinguishes three broad historical periods:
1991–1999: Early cellular and shared-antigen vaccine investigations.
2000–2015: Expansion of conventional tumor-associated antigen approaches.
2016–2026: Emergence and growth of sequencing-informed personalized neoantigen vaccine trials.
2. Clinical development and vaccine platforms
Among the 39 personalized neoantigen trial protocols, most were early-stage investigations. The review describes peptide/synthetic long-peptide, dendritic-cell, and mRNA/nucleic-acid approaches, including the emergence of late-stage individualized mRNA vaccine studies.
Three Phase III trial protocols are highlighted for V940/mRNA-4157 (intismeran autogene):
Trial	Registry identifier	Clinical-development focus
INTerpath-002	NCT06077760	Adjuvant individualized neoantigen therapy in resected NSCLC
INTerpath-009	NCT06623422	Resectable NSCLC without pathological complete response following neoadjuvant treatment
INTerpath-014	NCT07513376	Completely resected high-risk Stage I NSCLC
Important: Trial phase, registration, and planned enrollment do not establish clinical efficacy or regulatory approval. Trial status is time-sensitive and should be checked against the live registry before reuse.
3. Combination therapies
27 of 39 (69.23%) personalized neoantigen trial protocols evaluated combinations involving immunotherapy or other anticancer modalities. These included checkpoint inhibitors, radiotherapy, chemotherapy, and targeted therapies. The remaining 12 (30.77%) examined vaccine monotherapy, with or without adjuvants.
4. Registry coverage and data quality
The 39 unique personalized neoantigen trial protocols were distributed across the two searches as follows:
19 found only in ClinicalTrials.gov;
16 found in both ClinicalTrials.gov and WHO ICTRP;
4 found only via WHO ICTRP.
The manuscript documents differences in recruitment-status synchronization, phase terminology, enrollment targets, and endpoint detail. The trial FRAME-001 (NCT04998474 / EUCTR2021-003166-12-NL) illustrates why cross-registry linkage is needed to avoid double-counting.
5. Translation and equity
The review identifies outstanding challenges in demonstrating durable clinical benefit, standardizing personalized vaccine production, harmonizing registry reporting, and broadening geographic representation. The presence of neoantigen-specific immune responses alone should not be interpreted as proof of improved patient outcomes.
Repository structure
```text
.
├── Datasets/                   # Trial-level datasets and supporting extracts
├── Figures/                    # Manuscript figures and visual summaries
├── Scripts/                    # Data analysis and figure-generation scripts
├── NSCLC_Neoantigen_Codebook_Manual.pdf
├── The Global Landscape and Clinical Translation of
│   Personalized Neoantigen Vaccines in NSCLC_Protocol v1.0.pdf
└── README.md
```
Directory contents may evolve. The protocol specifies the review methods; the codebook explains extracted fields and coding conventions. Consult those documents before attempting secondary analysis.
Reproducing or exploring the analysis
Clone the repository:
```bash
git clone https://github.com/AkurutEva/The-Global-Evolution-and-Clinical-Translation-of-Therapeutic-Neoantigen-NSCLC-Vaccines-.git
cd The-Global-Evolution-and-Clinical-Translation-of-Therapeutic-Neoantigen-NSCLC-Vaccines-
```
Then review the protocol, inspect the codebook and available files in `Datasets/`, and examine the scripts in `Scripts/` before running them. The manuscript reports R 4.5.2, tidyverse, and ggplot2; exact script-specific dependencies, input paths, and execution order should be taken from the scripts themselves. No unverified one-command reproduction procedure is claimed here.
When reproducing counts, keep distinct the 184-trial overall cohort, the 39-trial personalized subset, registry records versus unique protocols, and trial-level versus vaccine-product-level analyses. Trial statuses may differ depending on registry export or update date.
Data sources and reporting guidelines
ClinicalTrials.gov
WHO International Clinical Trials Registry Platform
PRISMA-ScR reporting guidance
Joanna Briggs Institute
Please consult original trial records and applicable registry terms when redistributing or reusing third-party data.
Citation and Zenodo archival DOI
Zenodo DOI: forthcoming. A permanent DOI and version-specific archival citation will be added after the repository is deposited or connected to Zenodo. Please do not treat this placeholder as an issued DOI.
Until then, cite the GitHub repository with its URL and an access date or specific commit/release:
> Akurut, E., et al. *The Global Evolution and Clinical Translation of Therapeutic Neoantigen Non-Small Cell Lung Cancer Vaccines – A Scoping Review.* Research repository. GitHub: https://github.com/AkurutEva/The-Global-Evolution-and-Clinical-Translation-of-Therapeutic-Neoantigen-NSCLC-Vaccines-
The manuscript should be cited separately once a journal citation or preprint identifier is available.
Corrections and contributions
Corrections to trial identifiers, registry linkage, classifications, extraction fields, or analyses are welcome via GitHub Issues. Please provide the original registry identifier, supporting source, and date checked.
License and reuse
Consult the repository for an explicit license before reusing the code or redistributing the datasets. Public visibility on GitHub alone does not grant unrestricted reuse rights. Third-party registry records and figures may have separate terms.
Disclaimer
For research and evidence synthesis only. This repository is not intended for medical advice, therapeutic selection, or the demonstration of clinical efficacy or regulatory approval of any NSCLC vaccine.
