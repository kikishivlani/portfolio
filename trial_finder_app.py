import streamlit as st

st.title("Clinical Trial Finder")

age = st.number_input("Enter your age", min_value=0)
condition = st.text_input("Enter condition (e.g. diabetes)")
sex = st.selectbox("Sex", ["All", "Male", "Female"])

if st.button("Search"):
    st.write("Searching for trials...")
