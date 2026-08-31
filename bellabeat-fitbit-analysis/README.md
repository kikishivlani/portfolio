# Bellabeat Fitbit Analysis
### Google Data Analytics Capstone Project

**Tools:** SQL (Google BigQuery) · Tableau
**Live Dashboard:** [View on Tableau Public](https://public.tableau.com/app/profile/kiki.shivlani/viz/BellabeatCaseStudy-FitbitAnalysis)
**SQL Queries:** [bellabeat_sql_queries.sql](./bellabeat_sql_queries.sql)

---

## Overview

Bellabeat is a wellness technology company for women. This project analyzes public Fitbit fitness tracker data to uncover trends in activity and sleep behavior, then applies those insights to Bellabeat's **Leaf** tracker to generate data-driven marketing recommendations.

## Business Task

Identify trends in how people use smart fitness devices — specifically around activity and sleep — and translate those trends into actionable marketing strategy recommendations for Bellabeat's Leaf product.

## Data

**FitBit Fitness Tracker Data** (Kaggle, public domain via Mobius) — daily activity, hourly steps, heart rate, and sleep data from 30–35 users, collected across two time periods in 2016.

## Process

Data was cleaned and combined in **Google BigQuery** using SQL:
- Removed duplicate rows (3 exact duplicates in the sleep table)
- Fixed a naming inconsistency across split tables
- Discovered and resolved a **systematic date overlap** (April 12, 2016) duplicated across the activity, heart rate, and hourly steps tables — verified the pattern across all three before excluding it from final combined tables
- Verified data integrity: 0 nulls, confirmed row counts and unique user counts after every join/combine step

Full annotated queries: [`bellabeat_sql_queries.sql`](./bellabeat_sql_queries.sql)

## Key Findings

- Users are sedentary for **~68% of their day** (992 min/day on average) — well above their "very active" time (just 20 min/day)
- Average daily step count: **7,258** — below the commonly cited 10,000-step benchmark
- Activity peaks at **midday (12pm)** and **early evening (6–7pm)**
- **Saturday** is the most active day; **Sunday** the least
- **Sedentary time — not step count — is what's statistically linked to sleep quality:** a moderate negative correlation (r = -0.54, p = 0.028) was found between sedentary minutes and sleep duration, while steps showed almost no relationship with sleep (r = -0.183)

## Recommendations

1. Reframe Leaf's core value proposition around **reducing sedentary time**, not just step-counting
2. Time engagement features (reminders, notifications) around users' natural activity peaks (12pm, 6–7pm)
3. Differentiate weekend messaging — activity challenges on Saturday, recovery/sleep-focused content on Sunday

---

📊 **[View the full interactive Tableau Story →](https://public.tableau.com/app/profile/kiki.shivlani/viz/BellabeatCaseStudy-FitbitAnalysis)**
