-- Exploratory Data Analysis
-- Data Preparation
-- 1. What is the highest average loan amount for each job category?
SELECT job, avg(max_loan_amount) AS avg_loan_amount
FROM mortgage_staging
GROUP BY job
ORDER BY avg_loan_amount DESC;
/*Insights: Doctors receive the highest average loan amount, 
suggesting that higher-income professions are eligible for larger loans.*/

-- 2. Which location receives the highest average loan amount?
SELECT location, avg(max_loan_amount) AS avg_loan_amount
FROM mortgage_staging
GROUP BY location;
/* Urban areas receive the highest average loan amount, 
likely due to higher property values and borrowing requirements.*/

-- 3. Which education level has the highest average loan amount?
SELECT education, avg(max_loan_amount) AS avg_loan_amount
FROM mortgage_staging
GROUP BY education
ORDER BY avg_loan_amount DESC;
/*PhD holders receive the highest average loan amount,
indicating that advanced education may be associated with higher loan eligibility.*/

-- 4. Does risk category affect loan amount?
SELECT risk_category, AVG(max_loan_amount) AS avg_loan_amount
FROM mortgage_staging
GROUP BY risk_category
ORDER BY avg_loan_amount DESC;
/*Low-risk borrowers receive the highest average loan amount, 
reflecting stronger financial profiles and lower lending risk.*/

-- 5. Which location category has highest average income?
SELECT location, AVG(annual_income) AS avg_income
FROM mortgage_staging
GROUP BY location
ORDER BY avg_income DESC;
/*Urban applicants have the highest average annual income. 
although income alone does not determine loan eligibility*/

-- 6. Which Risk category has the highest approval potential?
SELECT risk_category, 
COUNT(*) AS Applicants, 
AVG(max_loan_amount) AS avg_loan, 
MIN(max_loan_amount) AS min_loan, 
MAX(max_loan_amount) AS max_loan
FROM mortgage_staging
GROUP BY risk_category
ORDER BY avg_loan DESC;
/*Low-risk applicants have the highest approval potential, 
with the largest applicant count and the highest average loan amount (766,299.06).*/

 -- exploring why low risk borrowers stood out
SELECT risk_category, 
AVG(down_payment) AS avg_down_payment,
AVG(annual_income) AS avg_annual_income, 
AVG(max_loan_amount) AS avg_loan, 
MIN(max_loan_amount) AS min_loan, 
MAX(max_loan_amount) AS max_loan
FROM mortgage_staging
GROUP BY risk_category
ORDER BY avg_loan DESC;


-- 7. Low Risk borrower analysis [Income, downpayment,experience]
SELECT risk_category,
ROUND(AVG(emp_years),2) AS avg_experience,
ROUND(AVG(annual_income),2) AS avg_income,
ROUND(AVG(max_loan_amount),2) AS avg_loan,
ROUND(AVG(down_payment),2) AS avg_down_payment
FROM mortgage_staging
GROUP BY risk_category
ORDER BY avg_loan DESC;
/*Low-risk borrowers show higher income, larger down payments, 
and longer work experience, making them strong candidates for larger loan amounts.
*/

SELECT * FROM mortgage_staging;

-- 8. What is the highest average credit score for each job category?
SELECT job, AVG(credit_score) AS avg_score
FROM mortgage_staging
GROUP BY job
ORDER BY avg_score DESC;
/*Doctor applicants have the highest average credit score.*/

-- 9. How applicants are distributes across the risk categories by job?
SELECT job, risk_category,
COUNT(*) AS Applicants
FROM mortgage_staging
GROUP BY job,risk_category
ORDER BY job, Applicants DESC;
/*The majority of applicants belong to the Low Risk category, 
High Risk applicants represent the smallest group.*/

-- 10. What percentage of applicants belong to each risk category?
SELECT risk_category,
COUNT(*) AS Applicants,
ROUND((COUNT(*) * 100 /(SELECT COUNT(*) FROM mortgage_staging)),2) AS Total_percent
FROM mortgage_staging
GROUP BY risk_category;
/*Low-risk applicants account for 58.31% which is the largest*/

-- Using a CTE to calculate the percentage of low-risk applicants by location.
-- 11. Which area has the most low risk applicants and whats the percentage?
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
/*Urban areas have the highest number of low-risk applicants (27,466), 
and 57.94% of applicants whereas Rursl has highest low risk 58.89% with only 7550 applicants*/
