-- Business Analysis
-- 1. Loan amount by education
SELECT education, 
COUNT(*) AS Applicants,
ROUND(AVG(max_loan_amount),2) AS avg_loan
FROM mortgage_staging
GROUP BY education
ORDER BY avg_loan DESC;
/*PhD holders receive the highest average loan amount.*/

-- 2. Loan amount by employment years
SELECT 
COUNT(*) AS Applicants,
ROUND(AVG(max_loan_amount),2) AS avg_loan,
CASE 
WHEN emp_years BETWEEN 0 AND 10 THEN '0-10 YEARS'
WHEN emp_years BETWEEN 11 AND 20 THEN '11-20 YEARS'
WHEN emp_years BETWEEN 21 AND 30 THEN '21-30 YEARS'
	ELSE '31+ YEARS' 
    END AS Experience
FROM mortgage_staging
GROUP BY Experience
ORDER BY Experience;
/*Applicants with 31+ years of experience receive the highest average loan amount.*/

-- 3. Does marital status affect the loan amount
SELECT marital_status,
ROUND(AVG(max_loan_Amount),2) AS avg_loan,
COUNT(*) AS Applicants,
ROUND(AVG(annual_income),2) AS avg_income
FROM mortgage_staging
GROUP BY marital_status;
/*Unmarried applicants receive higher average loan amounts than Married applicants.*/

-- 4. Does monthly debt affect the loan amount?
SELECT 
COUNT(*) AS Applicants,
ROUND(AVG(annual_income),2) AS avg_income,
ROUND(AVG(max_loan_amount),2) AS avg_loan,
CASE 
WHEN monthly_debt BETWEEN 0 AND 500 THEN '1. 0-500'
WHEN monthly_debt BETWEEN 501 AND 1000 THEN '2. 501-1000'
WHEN monthly_debt BETWEEN 1001 AND 2000 THEN '3. 1001-2000'
	ELSE '4. 2000+' 
    END AS debt_category
FROM mortgage_staging
GROUP BY debt_category
ORDER BY debt_category DESC;
/*Applicants with higher monthly debt (2000+) also receive higher average loan amounts.*/

-- 5. Does interest rate affect the loan amount?
SELECT 
COUNT(*) AS Applicants,
ROUND(AVG(annual_income),2) AS avg_income,
ROUND(AVG(max_loan_amount),2) AS avg_loan,
CASE 
WHEN interest_rate <= 0.03 THEN '0-3%'
WHEN interest_rate >0.03 AND interest_rate<=0.05 THEN '3%-5%'
WHEN interest_rate >0.05 AND interest_rate<=0.07 THEN '5%-7%'
	ELSE '7% & above' 
    END AS interest_percentage
FROM mortgage_staging
GROUP BY interest_percentage
ORDER BY interest_percentage ASC;
/*Borrowers in the lower interest-rate categories receive the highest average loan amounts.*/

-- To verify the interest bucket
SELECT interest_rate
FROM mortgage_staging
GROUP BY interest_rate
ORDER BY interest_rate;

-- 6. Does credit score influence loan amount
SELECT MIN(credit_score), MAX(credit_score)
FROM mortgage_staging;

SELECT 
COUNT(*) AS Applicants,
ROUND(AVG(annual_income),2) AS avg_income,
ROUND(AVG(max_loan_amount),2) AS avg_loan,
CASE 
WHEN credit_score IS NULL THEN 'UNKOWN'
WHEN credit_score BETWEEN 500 AND 649 THEN '500-649'
WHEN credit_score BETWEEN 650 AND 749 THEN '650-749'
	ELSE '750+' 
    END AS score_category
FROM mortgage_staging
GROUP BY score_category
ORDER BY score_category DESC;
/*Borrowers with credit scores of 750+ receive the highest average loan amounts.*/

-- 7. Which job receives the highest average loan amount?
SELECT job,
COUNT(*) AS Applicants,
ROUND(AVG(annual_income),2) AS avg_income,
ROUND(AVG(max_loan_amount),2) AS avg_loan,
ROUND(AVG(credit_score),2) AS avg_credit_score
FROM mortgage_staging
GROUP BY job;
/*Doctors receive the highest average loan amount among all occupations*/

-- 8. Which location has the strongest borrowing profile?
WITH risk_percentage AS (
SELECT location,
COUNT(*) AS Applicants,
ROUND(AVG(annual_income),2) AS avg_income,
ROUND(AVG(max_loan_amount),2) AS avg_loan,
ROUND(AVG(credit_score),2) AS avg_credit_score,
COUNT(
CASE 
WHEN risk_category ='Low Risk' THEN 1 
END) AS low_risk_applicants
FROM mortgage_staging
GROUP BY location
ORDER BY Applicants DESC)
SELECT location, Applicants,avg_income,avg_loan,avg_credit_score,low_risk_applicants,
ROUND(low_risk_applicants/Applicants * 100,2) AS Low_risk_percentage
FROM risk_percentage;
/*Urban applicants receive the highest average loan amount.*/

-- Which factors are common among the low risk borrowers?
SELECT risk_category,
ROUND(AVG(annual_income),2) AS avg_income,
ROUND(AVG(max_loan_amount),2) AS avg_loan,
ROUND(AVG(down_payment),2) AS avg_down_payment,
ROUND(AVG(emp_years),2) AS avg_experience
FROM mortgage_staging
WHERE risk_category = 'Low Risk';
/*Low-risk borrowers receive the highest average loan amount.*/

-- 10.a. Borrower profile with highest average[USING CTE function, cross join and window function]
WITH risk_percentage AS (
SELECT
COUNT(*) AS Applicants,
ROUND(AVG(annual_income),2) AS avg_income,
ROUND(AVG(max_loan_amount),2) AS avg_loan,
ROUND(AVG(credit_score),2) AS avg_credit_score,
COUNT(
CASE 
WHEN risk_category ='Low Risk' THEN 1 
END) AS low_risk_applicants
FROM mortgage_staging),

 loan_category AS (
SELECT job, location,
ROUND(AVG(max_loan_amount),2) AS category_avg_loan,
CASE 
WHEN emp_years BETWEEN 0 AND 10 THEN '0-10 YEARS'
wHEN emp_years BETWEEN 11 AND 20 THEN '11-20 YEARS'
WHEN emp_years BETWEEN 21 AND 30 THEN '21-30 YEARS'
	ELSE '31+ YEARS' 
    END AS Experience,
CASE 
WHEN credit_score BETWEEN 500 AND 649 THEN '500-649'
WHEN credit_score BETWEEN 650 AND 749 THEN '650-749'
	ELSE '750+' 
    END AS score_category
FROM mortgage_staging
GROUP BY Experience,job,location,score_category),

FinalKPI AS(
SELECT 
ROW_NUMBER() OVER (ORDER BY category_avg_loan DESC) AS RowNum ,
r1.Applicants AS total_applicants,
r1.avg_income AS global_avg_income,
r1.avg_credit_score AS global_avg_credit_score,
r1.low_risk_applicants,
r1.avg_loan AS global_avg_loan,
ROUND(r1.low_risk_applicants/r1.Applicants * 100,2) AS Low_risk_percentage,
l1.score_category,
l1.category_avg_loan
FROM loan_category l1
CROSS JOIN risk_percentage r1 )
SELECT
total_applicants,
    global_avg_income,
    global_avg_credit_score,
    low_risk_applicants,
    global_avg_loan,
    Low_risk_percentage,
    score_category,
    category_avg_loan
    FROM FinalKPI
WHERE RowNum = 1;
/*The strongest borrowers tend to be from low risk applicants and this provides 
an overall combination for loan amount and score category for loan approval potential*/


WITH loan_category AS
(
SELECT job, location,
ROUND(AVG(max_loan_amount),2) AS category_avg_loan,
CASE 
WHEN emp_years BETWEEN 0 AND 10 THEN '0-10 YEARS'
wHEN emp_years BETWEEN 11 AND 20 THEN '11-20 YEARS'
WHEN emp_years BETWEEN 21 AND 30 THEN '21-30 YEARS'
	ELSE '31+ YEARS' 
    END AS Experience,
CASE 
WHEN credit_score BETWEEN 500 AND 649 THEN '500-649'
WHEN credit_score BETWEEN 650 AND 749 THEN '650-749'
	ELSE '750+' 
    END AS score_category
FROM mortgage_staging
GROUP BY Experience,job,location,score_category)
SELECT
    job,
    location,
    Experience,
    score_category,
    category_avg_loan
FROM loan_category
ORDER BY category_avg_loan DESC;

/*The highest average loan amount is observed among 
Rural Bankers with 11–20 years of experience and a credit score of 650–749, 
while low-risk applicants make up 59.96% of the dataset.*/

-- 10.b. Highest loan category KPI
SELECT
COUNT(*) AS Applicants,
ROUND(AVG(annual_income),2) AS avg_income,
ROUND(AVG(max_loan_amount),2) AS avg_loan,
ROUND(AVG(credit_score),2) AS avg_credit_score,
ROUND(COUNT(CASE WHEN risk_category ='Low Risk' THEN 1 END)/COUNT(*) * 100,2) AS Low_risk_percentage
FROM mortgage_staging;
/*Overall numbers for KPI*/
