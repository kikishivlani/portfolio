# Clinical Trial Finder

I wanted to create a simple tool that makes clinical trial data more accessible.
This is a very simple web app that is built with Streamlit to help users find clinical trials based on age, condition, and sex.

## Features
- Searches clinicaltrials.gov
- Filters trial eligibility by:
  - Age
  - Sex
  - Condition
- Shows:
  - Title
  - Recruitment status
  - Link to study
  - Age match

## Used
- Python
- Streamlit
- Requests API

## Run locally
```bash
streamlit run trial_finder_app.py
