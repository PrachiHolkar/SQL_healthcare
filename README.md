# 🏥 Healthcare Data Analysis Using SQL

This project focuses on **cleaning**, **standardizing**, and **analyzing healthcare data** using SQL. It simulates a typical healthcare data analyst’s workflow — from raw data ingestion to actionable clinical insights.

---

## 📂 Project Overview

The dataset includes anonymized patient records with the following attributes:

- Demographics (Name, Age, Gender)
- Medical details (Condition, Medication, Test Results)
- Admission info (Admission Type, Hospital, Doctor, Dates)
- Financial data (Billing Amount, Insurance Provider)

This analysis aims to uncover **clinical patterns** in emergency care, medication use, outcome distributions, and more — mimicking common tasks of a healthcare data analyst.

---

## 🧰 Tech Stack

- **MySQL** (Data Cleaning + Analysis)
- No external libraries or tools used — all logic handled within SQL.

---

## 📊 Key Analysis Performed

### 🔹 Part 1: Data Cleaning & Preparation
- Removed duplicate records using `ROW_NUMBER()` + `PARTITION BY`
- Standardized patient names (lowercase)
- Converted admission and discharge dates to `DATE` format
- Renamed columns for consistency
- Dropped unnecessary helper columns

### 🔹 Part 2: Clinical Data Analysis
- **Top conditions in emergency cases**
- **Test outcome distributions by condition** (Normal, Abnormal, Inconclusive)
- **Most common medications used by emergency condition**
- **Emergency conditions with lowest % of normal results**

---

## 🧠 Key Insights

- Obesity, Arthritis, and Diabetes are among the **most common emergency conditions**
- Emergency admissions for **Hypertension and Cancer** show the **lowest % of normal test results**

---

## 🔚 Final Notes

- The dataset contains no unique identifier, so assumptions were made based on stable combinations.
- Age and Blood Type were found **unreliable for patient tracking** across admissions.
- Location-based analysis was skipped due to inconsistent hospital naming.

---

## 📫 Contact

If you found this project insightful or want to collaborate, feel free to connect with me on [LinkedIn](https://www.linkedin.com/in/prachi-holkar/) or reach out via email (holkarprachi@hotmail.com)
