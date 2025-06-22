-- PART 1: DATA CLEANING

SELECT * FROM healthcare;

-- Create staging table with appropriate data types for data cleaning and transformation
CREATE TABLE healthcare_staging
LIKE healthcare;

-- Check the empty staging table structure
SELECT * FROM healthcare_staging;

-- Load data from the raw data into staging table for cleaning
INSERT healthcare_staging
SELECT *
FROM healthcare;

-- Verify data loaded into staging table
SELECT * FROM healthcare_staging;


-- Rename columns for consistency and readability
ALTER TABLE healthcare_staging
CHANGE `Blood Type` Blood_Type VARCHAR(5);

ALTER TABLE healthcare_staging
CHANGE `Medical Condition` Medical_Condition VARCHAR(20);

ALTER TABLE healthcare_staging
CHANGE `Insurance Provider` Insurance_Provider VARCHAR(50);

ALTER TABLE healthcare_staging
CHANGE `Billing Amount` Billing_Amount DOUBLE;

ALTER TABLE healthcare_staging
CHANGE `Room Number` Room_Number INT;

ALTER TABLE healthcare_staging
CHANGE `Admission Type` Admission_Type VARCHAR(25);

ALTER TABLE healthcare_staging
CHANGE `Test Results` Test_Results VARCHAR(25);

ALTER TABLE healthcare_staging
CHANGE `Discharge Date` Discharge_Date TEXT;

ALTER TABLE healthcare_staging
CHANGE `Date of Admission` Date_of_Admission TEXT;

-- Preview data and structure
SELECT * FROM healthcare_staging;
DESCRIBE healthcare_staging;

SELECT COUNT(*) FROM healthcare_staging;

SELECT DISTINCT Blood Type FROM healthcare_staging;

-- 1. REMOVE DUPLICATE
-- Identify potential duplicate records (no unique ID available)
-- Use row_number over combination of stable columns
SELECT * ,
ROW_NUMBER() OVER(
PARTITION BY Name, Medical_Condition, Date_of_Admission, Hospital, Doctor, Admission_Type, Discharge_Date, Medication, Test_Results) AS row_num
FROM healthcare_staging;

WITH duplicate_cte AS
(
SELECT * ,
ROW_NUMBER() OVER(
PARTITION BY Name, Medical_Condition, Date_of_Admission, Hospital, Doctor, Admission_Type, Discharge_Date, Medication, Test_Results) AS row_num
FROM healthcare_staging
)
SELECT * 
FROM duplicate_cte
WHERE row_num > 1;

-- Create a clean version of staging table with deduplication logic
CREATE TABLE `healthcare_staging2` (
  `Name` text,
  `Age` int DEFAULT NULL,
  `Gender` text,
  `Blood_Type` varchar(5) DEFAULT NULL,
  `Medical_Condition` varchar(20) DEFAULT NULL,
  `Date_of_Admission` text,
  `Doctor` text,
  `Hospital` text,
  `Insurance_Provider` varchar(50) DEFAULT NULL,
  `Billing_Amount` double DEFAULT NULL,
  `Room_Number` int DEFAULT NULL,
  `Admission_Type` varchar(25) DEFAULT NULL,
  `Discharge_Date` text,
  `Medication` text,
  `Test_Results` varchar(25) DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * 
FROM healthcare_staging2;

-- Loading data 
INSERT INTO healthcare_staging2
SELECT * ,
ROW_NUMBER() OVER(
PARTITION BY Name, Medical_Condition, Date_of_Admission, Hospital, Doctor, Admission_Type, Discharge_Date, Medication, Test_Results) AS row_num
FROM healthcare_staging;

SELECT * 
FROM healthcare_staging2
WHERE row_num > 1;

-- Remove true duplicates
DELETE 
FROM healthcare_staging2
WHERE row_num > 1;

SELECT * 
FROM healthcare_staging2
WHERE row_num > 1;

SELECT * 
FROM healthcare_staging2;

-- 2. STANDARDIZE THE DATA
-- Standardize patient names to lowercase
UPDATE healthcare_staging2
SET Name = (LOWER(Name));

-- Review data characteristics
SELECT * 
FROM healthcare_staging2;

SELECT MAX(Age), MIN(Age)
FROM healthcare_staging2;

SELECT DISTINCT Gender
FROM healthcare_staging2;

SELECT DISTINCT Blood_Type
FROM healthcare_staging2;

SELECT DISTINCT Medical_Condition
FROM healthcare_staging2;

SELECT DISTINCT Hospital
FROM healthcare_staging2;

SELECT DISTINCT Doctor
FROM healthcare_staging2;

SELECT DISTINCT Insurance_Provider
FROM healthcare_staging2;

SELECT DISTINCT Admission_Type
FROM healthcare_staging2;

SELECT DISTINCT Medication
FROM healthcare_staging2;

SELECT DISTINCT Test_Results
FROM healthcare_staging2;

SELECT * 
FROM healthcare_staging2;

-- Convert Date_of_Admission
SELECT `Date_of_Admission`,
STR_TO_DATE(`Date_of_Admission`, '%Y-%m-%d')
FROM healthcare_staging2;

UPDATE healthcare_staging2
SET `Date_of_Admission` = STR_TO_DATE(`Date_of_Admission`, '%Y-%m-%d');

-- Convert Discharge_Date
SELECT `Date_of_Admission`
FROM healthcare_staging2;

ALTER TABLE healthcare_staging2
MODIFY COLUMN `Date_of_Admission` DATE;

SELECT * 
FROM healthcare_staging2;

SELECT `Discharge_Date`,
STR_TO_DATE(`Discharge_Date`, '%Y-%m-%d')
FROM healthcare_staging2;

UPDATE healthcare_staging2
SET `Discharge_Date` = STR_TO_DATE(`Discharge_Date`, '%Y-%m-%d');

SELECT `Discharge_Date`
FROM healthcare_staging2;

ALTER TABLE healthcare_staging2
MODIFY COLUMN `Discharge_Date` DATE;

SELECT * 
FROM healthcare_staging2;

-- 3. CHECK FOR NULL OR BLANK VALUES
SELECT Billing_Amount
FROM healthcare_staging2
WHERE Billing_Amount IS NULL;

SELECT Date_of_Admission
FROM healthcare_staging2
WHERE Date_of_Admission IS NULL;

SELECT Discharge_Date
FROM healthcare_staging2
WHERE Discharge_Date IS NULL;

-- 4. REMOVE UNNECCESARY/ EXTRA COLUMNS
ALTER TABLE healthcare_staging2
DROP COLUMN row_num;

SELECT *
FROM healthcare_staging2;


-- PART 2: EDA EXPLANATORY DATA ANALYSIS
-- Check if same patient (Name, Age, Gender) has multiple conditions
SELECT Name, Age, Gender, COUNT(Medical_Condition)
FROM healthcare_staging2
GROUP BY Name, Age, Gender
HAVING COUNT(Medical_Condition) > 1 ;

-- Sample edge case checks
SELECT *
FROM healthcare_staging2
WHERE Name = 'brian gonzalez';

SELECT *
FROM healthcare_staging2
WHERE Name = 'john johnson' and Gender = 'Male';

SELECT *
FROM healthcare_staging2
WHERE Name = 'james smith';

-- Note: Blood_Type and Age are unreliable for identity (Name not unique, Blood_Type varies)

-- Get time window of dataset
SELECT MAX(Date_of_Admission), MIN(Date_of_Admission)
FROM healthcare_staging2;

SELECT MAX(Discharge_Date), MIN(Discharge_Date)
FROM healthcare_staging2;
-- Our data is between May 2019 to June 2024

-- Check for invalid discharge logic
SELECT *
FROM healthcare_staging2
WHERE Discharge_Date < Date_of_Admission;
-- no such inaccurate records found

-- Most Common Conditions in Emergency Admissions
SELECT Medical_Condition, COUNT(*) AS Emergency_Count
FROM healthcare_staging2
WHERE Admission_Type = 'Emergency'
GROUP BY Medical_Condition
ORDER BY Emergency_Count DESC;

--  Emergency Conditions and Test Outcomes
SELECT Medical_Condition, Test_Results, COUNT(*) AS Result_Count
FROM healthcare_staging2
WHERE Admission_Type = 'Emergency'
GROUP BY Medical_Condition, Test_Results
ORDER BY Medical_Condition, Result_Count DESC;

-- Medication Usage by Emergency Conditions & Outcomes
SELECT Medical_Condition, Test_Results, Medication, COUNT(*) AS Medication_Count
FROM healthcare_staging2
WHERE Admission_Type = 'Emergency'
GROUP BY Medical_Condition, Test_Results, Medication
ORDER BY Medical_Condition, Medication_Count DESC;

-- Percentage of “Normal” Outcomes by Condition (Emergency Cases)
SELECT 
	Medical_Condition,
	ROUND(SUM(CASE WHEN Test_Results = 'Normal' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),2) AS Normal_Percentage,
    COUNT(*) AS Total_Emergencies
FROM healthcare_staging2
WHERE Admission_Type = 'Emergency'
GROUP BY Medical_Condition
ORDER BY Normal_Percentage ASC;


