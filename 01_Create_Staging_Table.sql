-- Creating the staging table
CREATE TABLE mortgage_staging
LIKE mortgage_loan;

INSERT INTO mortgage_staging
SELECT *
FROM mortgage_loan;

SELECT * 
FROM mortgage_staging;

-- Renaming the columns for easier usage in query
ALTER TABLE mortgage_staging
RENAME COLUMN Gender TO gender,
RENAME COLUMN Age TO age,
RENAME COLUMN Married TO marital_status,
RENAME COLUMN Education TO education,
RENAME COLUMN Job TO job,
RENAME COLUMN `Employment Years` TO emp_years,
RENAME COLUMN `Annual Income (USD)` TO annual_income,
RENAME COLUMN `Interest Rate` TO interest_rate,
RENAME COLUMN `Down Payment (USD)` TO down_payment,
RENAME COLUMN `Credit Score` TO credit_score,
RENAME COLUMN `Existing Monthly Debt (USD)` TO monthly_debt,
RENAME COLUMN `Area` TO location,
RENAME COLUMN `Loans Repaid` TO loans_repaid,
RENAME COLUMN `Max Loan Amount (USD)`TO max_loan_amount;