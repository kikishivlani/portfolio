# Alzheimer's Risk Factor Analysis

A self-directed data analytics case study exploring which demographic, lifestyle, and clinical factors predict Alzheimer's diagnosis — and building a predictive model to test how well they could support early-detection screening.

**[View the interactive Tableau Story →](https://public.tableau.com/app/profile/kiki.shivlani/viz/CaseStudyAlzheimersRiskAnalysis/Story1)**

---

## Business Task

Analyze demographic, lifestyle, and clinical risk factors associated with Alzheimer's diagnosis to identify the strongest predictors of cognitive decline, and build a predictive model to explore how these factors could inform early-detection screening and preventive outreach.

## Data Source

- **Dataset:** [Alzheimer's Disease Dataset](https://www.kaggle.com/datasets/rabieelkharoua/alzheimers-disease-dataset) by Rabie El Kharoua (2024), via Kaggle
- **License:** CC BY 4.0
- **Size:** 2,149 patients, 34 features (demographics, lifestyle, medical history, clinical measurements, cognitive/functional assessments, diagnosis)
- **Note:** This is a synthetic, educational dataset — not real patient records. Findings describe patterns in this dataset and should not be generalized to real-world Alzheimer's epidemiology.

## Tools

- **Python** (pandas, scikit-learn, matplotlib, seaborn) — data cleaning, EDA, modeling
- **Jupyter Notebook** — analysis environment
- **Kaggle API** — programmatic dataset download
- **Tableau Public** — visualization and interactive story

## Process

Full workflow followed the Ask → Prepare → Process → Analyze → Share → Act framework.

**Cleaning:** Removed a constant placeholder column (`DoctorInCharge`). No missing values or duplicate records found.

**Key finding:** Rather than analyzing all 32 features as a single undifferentiated group, features were split into two categories before modeling:
- **Risk factors** (22 features) — demographics, lifestyle, medical history, clinical measurements
- **Cognitive/functional variables** (10 features) — assessment scores and symptoms collected as part of diagnosis itself

This split revealed that the two groups behave very differently:

| Model | Features | AUC |
|---|---|---|
| Model A | 22 risk factors only | 0.518 (≈ random) |
| Model B | 5 cognitive/functional signal variables | 0.890 |

Risk factors (age, family history, cardiovascular disease, smoking, cholesterol, etc.) showed near-zero correlation with diagnosis (all \|r\| < 0.06). Cognitive/functional variables — FunctionalAssessment, ADL, MMSE, MemoryComplaints, and BehavioralProblems — showed moderate-to-strong correlations (0.22–0.36) and produced a genuinely predictive model.

**Threshold tuning:** At the default classification threshold, Model B achieved 73.7% recall on the Alzheimer's-positive class. Lowering the threshold to 0.346 raised recall to 85.5% (precision dropped from 0.74 to 0.70) — a tradeoff worth making in a screening context, where missing an at-risk patient is costlier than an unnecessary follow-up.

## Key Insights

- Commonly assumed Alzheimer's risk factors (age, family history, lifestyle, cardiovascular health) showed no predictive power in this dataset.
- Cognitive/functional assessment scores were strong, reliable predictors of diagnosis.
- A screening tool built purely on demographic or lifestyle intake data would perform no better than chance here — effective early detection would need to incorporate brief cognitive/functional assessments instead.

## Repository Structure

```
├── data/
│   ├── raw/                  # Original Kaggle dataset
│   └── processed/            # Tableau-ready exports, correlation & threshold data
├── notebooks/
│   └── 01_eda_and_cleaning.ipynb
└── README.md
```

## Limitations & Further Exploration

- Synthetic dataset — not a substitute for real clinical data
- Additional model types (Random Forest, XGBoost) could be tested for comparison
- Interaction effects between cognitive variables weren't explored
- Validating this approach against real, de-identified clinical data would be a natural next step

---

**Author:** Kiki Shivlani
[Tableau Public](https://public.tableau.com/app/profile/kiki.shivlani) 
