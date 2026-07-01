-- Data Cleaning: Row count verification and verify duplicate
SELECT COUNT(*)
FROM mortgage_staging;

SELECT 
gender,age,marital_status,education,job,emp_years,
annual_income,interest_rate,down_payment,credit_score,
monthly_debt,location,loans_repaid,max_loan_amount,
dti,risk_category,income_category,monthly_income,
COUNT(*) AS duplicate_count
FROM mortgage_staging
GROUP BY 
gender,age,marital_status,education,job,emp_years,
annual_income,interest_rate,down_payment,credit_score,
monthly_debt,location,loans_repaid,max_loan_amount,
dti,risk_category,income_category,monthly_income
HAVING COUNT(*) > 1;

SELECT * FROM mortgage_staging
WHERE gender = 'Female' AND age = '46' AND emp_years = '21' AND job = 'Doctor';
-- Duplicate records are found

-- Data cleaning for the duplicate records
CREATE TABLE mortgage_staging_backup AS
SELECT * FROM mortgage_staging;

CREATE TABLE mortgage_clean AS
WITH duplicate_check AS
(
SELECT *, 
ROW_NUMBER() OVER(PARTITION BY gender,age,marital_status,education,job,emp_years,
annual_income,interest_rate,down_payment,credit_score,
monthly_debt,location,loans_repaid,max_loan_amount,dti,risk_category,income_category,monthly_income
ORDER BY gender) AS row_num
FROM mortgage_staging)
SELECT * 
FROM duplicate_check
WHERE row_num = 1;

SELECT *
FROM mortgage_clean;

ALTER TABLE mortgage_clean
DROP COLUMN row_num;
-- To check the new table for duplicates
WITH duplicate_check AS
(
SELECT *, 
ROW_NUMBER() OVER(PARTITION BY gender,age,marital_status,education,job,emp_years,
annual_income,interest_rate,down_payment,credit_score,
monthly_debt,location,loans_repaid,max_loan_amount
ORDER BY gender) AS row_num
FROM mortgage_clean)
SELECT * 
FROM duplicate_check
WHERE row_num > 1;

-- Renaming the cleaned table
DESCRIBE mortgage_clean;

RENAME TABLE mortgage_staging TO mortgage_staging_backup_1;

RENAME TABLE mortgage_clean TO mortgage_staging;

SELECT COUNT(*) FROM mortgage_staging;

-- Data quality check: Verify NULL values
SELECT
SUM(CASE WHEN annual_income IS NULL THEN 1 ELSE 0 END) AS annual_income_null,
SUM(CASE WHEN credit_score IS NULL THEN 1 ELSE 0 END) AS credit_score_null
FROM mortgage_staging;

-- Data validation check: Verify credit score, income and loan amount ranges using MIN/MAX
SELECT MIN(credit_score),
MAX(credit_score)
FROM mortgage_staging;

SELECT
MIN(annual_income),
MAX(annual_income)
FROM mortgage_staging;

SELECT
MIN(max_loan_amount),
MAX(max_loan_amount)
FROM mortgage_staging;
