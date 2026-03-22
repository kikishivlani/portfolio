import streamlit as st
import requests

st.title("Clinical Trial Finder")

age = st.number_input("Enter your age", min_value=0)
condition = st.text_input("Enter condition (e.g. diabetes)")
sex = st.selectbox("Sex", ["All", "Male", "Female"])

if st.button("Search"):
    if condition == "":
        st.write("Please enter a condition")
    else:
        url = f"https://clinicaltrials.gov/api/v2/studies?query.term={condition}"
        response = requests.get(url)

        if response.status_code == 200:
            data = response.json()
            studies = data.get("studies", [])

            if len(studies) == 0:
                st.write("No trials found")
            else:
                found_match = False

                for study in studies[:20]:
                    title = study.get("protocolSection", {}).get("identificationModule", {}).get("briefTitle", "No title")

                    eligibility = study.get("protocolSection", {}).get("eligibilityModule", {})
                    min_age = eligibility.get("minimumAge", "0 Years")
                    max_age = eligibility.get("maximumAge", "100 Years")

                    try:
                        min_age_num = int(min_age.split()[0])
                    except:
                        min_age_num = 0

                    try:
                        max_age_num = int(max_age.split()[0])
                    except:
                        max_age_num = 100

                    if min_age_num <= age <= max_age_num:
                        st.write("✅", title)
                        found_match = True

                if found_match == False:
                    st.write("No age-matching trials found")
        else:
            st.write("Error fetching data")