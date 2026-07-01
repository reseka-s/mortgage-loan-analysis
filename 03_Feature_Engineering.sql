-- Feature Engineering
ALTER TABLE mortgage_staging
ADD COLUMN dti DECIMAL(10,2);

ALTER TABLE mortgage_staging
ADD COLUMN risk_category VARCHAR(20);

ALTER TABLE mortgage_staging
ADD COLUMN monthly_income DECIMAL(12,2);

ALTER TABLE mortgage_staging
ADD COLUMN income_category VARCHAR(20);

UPDATE mortgage_staging
SET monthly_income = annual_income / 12;

SELECT *
FROM mortgage_staging;

UPDATE mortgage_staging
SET dti = monthly_debt / monthly_income;

UPDATE mortgage_staging
SET risk_category = 
CASE
WHEN credit_score IS NULL THEN 'Unknown'

WHEN credit_score >=750
THEN 'Low Risk'

WHEN credit_score BETWEEN 650 AND 749
THEN 'Medium Risk'

ELSE 'High Risk'
END;

UPDATE mortgage_staging
SET income_category = 
CASE
WHEN annual_income < 50000
THEN 'Low Income'

WHEN annual_income BETWEEN 50000 AND 100000
THEN 'Middle Income'

ELSE 'High Income'
END;

SELECT annual_income, monthly_income, income_category
FROM mortgage_staging
LIMIT 10;
