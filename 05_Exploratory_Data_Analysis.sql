-- Data Preparation
-- 1. Which job category receives the highest average loan amount?
SELECT job, avg(max_loan_amount) AS avg_loan_amount
FROM mortgage_staging
GROUP BY job;

-- 2. Which location receives the highest average loan amount?
SELECT location, avg(max_loan_amount) AS avg_loan_amount
FROM mortgage_staging
GROUP BY location;

-- 3. Which education level has the highest average loan amount?
SELECT education, avg(max_loan_amount) AS avg_loan_amount
FROM mortgage_staging
GROUP BY education;

-- 4. Does credit score affect loan amount?
SELECT risk_category, AVG(max_loan_amount) AS avg_loan_amount
FROM mortgage_staging
GROUP BY risk_category
ORDER BY avg_loan_amount DESC;

-- 5. Which location category has highest average income?
SELECT location, AVG(annual_income) AS avg_income
FROM mortgage_staging
GROUP BY location
ORDER BY avg_income DESC;

-- Which Risk category has the highest approval potential?
SELECT risk_category, 
COUNT(*) AS Applicants, 
AVG(max_loan_amount) AS avg_loan, 
MIN(max_loan_amount) AS min_loan, 
MAX(max_loan_amount) AS max_loan
FROM mortgage_staging
GROUP BY risk_category
ORDER BY avg_loan DESC;

SELECT risk_category, 
AVG(down_payment) AS avg_down_payment,
AVG(annual_income) AS avg_annual_income, 
AVG(max_loan_amount) AS avg_loan, 
MIN(max_loan_amount) AS min_loan, 
MAX(max_loan_amount) AS max_loan
FROM mortgage_staging
GROUP BY risk_category
ORDER BY avg_loan DESC;


-- Income vs Loan Amount
SELECT risk_category,
ROUND(AVG(emp_years),2) AS avg_experience,
ROUND(AVG(annual_income),2) AS avg_income,
ROUND(AVG(max_loan_amount),2) AS avg_loan,
ROUND(AVG(down_payment),2) AS avg_down_payment
FROM mortgage_staging
GROUP BY risk_category
ORDER BY avg_loan DESC;

SELECT * FROM mortgage_staging;

-- What is the highest average loan amount for each job category?
SELECT job, AVG(max_loan_amount) AS avg_loan
FROM mortgage_staging
GROUP BY job
ORDER BY avg_loan DESC;

-- What is the highest average credit score for each job category?
SELECT job, AVG(credit_score) AS avg_score
FROM mortgage_staging
GROUP BY job
ORDER BY avg_score DESC;

-- How applicants are distributes across the risk categories?
SELECT job, risk_category,
COUNT(*) AS Applicants
FROM mortgage_staging
GROUP BY job,risk_category
ORDER BY job, Applicants DESC;

-- What percentage of applicants belong to each risk category?
SELECT risk_category,
COUNT(*) AS Applicants,
ROUND((COUNT(*) * 100 /(SELECT COUNT(*) FROM mortgage_staging)),2) AS Total_percent
FROM mortgage_staging
GROUP BY risk_category;

-- To analyse which area has the most low risk applicants and whats the percentage
WITH risk_percentage AS (
SELECT location,
COUNT(*) AS Applicants,
ROUND(AVG(monthly_income),2) AS avg_income,
ROUND(AVG(max_loan_amount),2) AS avg_loan,
COUNT(
CASE 
WHEN risk_category ='Low Risk' THEN 1 
END) AS low_risk_applicants
FROM mortgage_staging
GROUP BY location
ORDER BY Applicants DESC)
SELECT location, Applicants,avg_income,avg_loan,low_risk_applicants,
ROUND(low_risk_applicants/Applicants * 100,2) AS Low_risk_percentage
FROM risk_percentage;
