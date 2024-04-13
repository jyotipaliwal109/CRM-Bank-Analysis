CREATE DATABASE Customer;
USE Customer;

select * from activecustomer; 
select * from bank_churn; 
select * from creditcard; 
select * from customerinfo; 
select * from exitcustomer; 
select * from gender; 
select * from geography; 

-- 1. What is the distribution of account balances across different regions? //
SELECT g.GeographyLocation AS Region,
    COUNT(*) AS NumCustomers,
    MIN(b.Balance) AS MinBalance,
    MAX(b.Balance) AS MaxBalance,
    AVG(b.Balance) AS AvgBalance
FROM bank_churn b
JOIN customerinfo ci ON b.CustomerId = ci.CustomerId
JOIN geography g ON ci.GeographyID = g.GeographyID
GROUP BY g.GeographyLocation;

/*
ALTER TABLE customerinfo
MODIFY BankDOJ DATE;

select BankDOJ from customerinfo;

select extract(quarter from BankDOJ) from customerinfo;

UPDATE customerinfo
SET BankDOJ = STR_TO_DATE(BankDOJ, '%d/%m/%Y');

SET SQL_SAFE_UPDATES = 0;
*/

-- 2. Identify the top 5 customers with the highest Estimated Salary in the last quarter of the year. (SQL)    //
SELECT Surname, EstimatedSalary
FROM customerinfo
WHERE EXTRACT(MONTH FROM BankDOJ) IN (10, 11, 12) 
ORDER BY EstimatedSalary DESC
LIMIT 5;


-- 3. Calculate the average number of products used by customers who have a credit card. (SQL) //
SELECT AVG(NumOfProducts) AS AvgNoProducts
FROM bank_churn
WHERE HasCrCard = 1;

-- 4. Compare the average credit score of customers who have exited and those who remain. (SQL)    //
-- Here 1 = "exited", 2 = "remain"
SELECT Exited, AVG(CreditScore) AS AvgCreditScore
FROM bank_churn
GROUP BY Exited;

-- 5. Which gender has a higher average estimated salary, and how does it relate to the number of active accounts? (SQL)  
SELECT g.GenderCategory, AVG(c.estimatedsalary) AS Average_Estimated_salary
from customerinfo c 
JOIN gender g on c.genderid = g.genderid 
JOIN bank_churn b on c.customerid = b.customerid
WHERE b.isactivemember = 1
GROUP BY g.GenderCategory;


-- 6. Segment the customers based on their credit score and identify the segment with the highest exit rate. (SQL)  //
SELECT 
    CASE 
        WHEN CreditScore >= 800 THEN 'Excellent'
        WHEN CreditScore >= 740 AND CreditScore < 800 THEN 'Very Good'
        WHEN CreditScore >= 670 AND CreditScore < 740 THEN 'Good'
        WHEN CreditScore >= 580 AND CreditScore < 670 THEN 'Fair'
        WHEN CreditScore < 580 THEN 'Poor'
        ELSE 'Unknown'
    END AS CreditScoreSegment,
    SUM(Exited) as TotalExited
FROM bank_churn
GROUP BY CreditScoreSegment
ORDER BY TotalExited DESC
LIMIT 1;


-- 7. Find out which geographic region has the highest number of active customers with a tenure greater than 5 years. (SQL)    //
SELECT g.GeographyLocation,
    COUNT(ci.CustomerId) AS Num_Active_Customers
FROM customerinfo ci
JOIN geography g ON ci.GeographyID = g.GeographyID
JOIN bank_churn bc ON ci.CustomerId = bc.CustomerId
WHERE bc.Tenure > 5
GROUP BY g.GeographyLocation
ORDER BY Num_Active_Customers DESC;


-- 8. What is the impact of having a credit card on customer churn, based on the available data?    //
SELECT HasCrCard, AVG(Exited) AS Churn_Rate
FROM bank_churn
GROUP BY HasCrCard;


-- 9. For customers who have exited, what is the most common number of products they have used?
SELECT NumOfProducts AS MostCommonNumOfProducts, COUNT(*) AS Frequency
FROM bank_churn
WHERE Exited = 1
GROUP BY NumOfProducts
ORDER BY Frequency DESC;

/*10.Examine the trend of customers joining over time and identify any seasonal patterns (yearly or monthly).   
Prepare the data through SQL and then visualize it.*/
SELECT YEAR(BankDOJ) AS Years,COUNT(CustomerId) AS CustomersCount
FROM CustomerInfo
GROUP BY Years
ORDER BY CustomersCount DESC;
    
/*11.. Using SQL, write a query to find out the gender-wise average income of male and females in each geography id. Also,                   
rank the gender according to the average value. (SQL)*/                                                                              -- //
SELECT ci.GeographyID, ge.GeographyLocation, gd.GenderCategory,
       AVG(ci.EstimatedSalary) AS AverageIncome,
       RANK() OVER(PARTITION BY ci.GeographyID, gd.GenderCategory 
ORDER BY AVG(ci.EstimatedSalary) DESC) AS GenderRank
FROM customerinfo ci
JOIN geography ge ON ci.GeographyID = ge.GeographyID
JOIN gender gd ON ci.GenderID = gd.GenderID
GROUP BY ci.GeographyID, ge.GeographyLocation, gd.GenderCategory;


-- 12. Using SQL, write a query to find out the average tenure of the people who have exited in each age bracket (18-30, 30-50, 50+).     //
​select CASE 
		WHEN ci.Age BETWEEN 18 AND 30 THEN '18-30'
        WHEN ci.Age BETWEEN 31 AND 50 THEN '31-50'
        ELSE '50+'
    END AS Age_Bracket,
    AVG(bc.Tenure) AS Avg_Tenure
FROM bank_churn bc
JOIN customerinfo ci ON bc.CustomerId = ci.CustomerId
WHERE bc.Exited = 1
GROUP BY Age_Bracket;


-- 14. Rank each bucket of credit score as per the number of customers who have churned the bank.
SELECT CreditScore,
    COUNT(*) AS Churned_Customers,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS Score_Rank
FROM bank_churn
WHERE Exited = 1
GROUP BY CreditScore;


/* 15. As we can see that the “CustomerInfo” table has the CustomerID and Surname, now if we have to join it with a table where the primary key is 
also a combination of CustomerID and Surname, come up with a column where the format is “CustomerID_Surname”.*/
SELECT CONCAT(ci.CustomerId, '_', ci.Surname) AS CustomerID_Surname
FROM customerinfo ci;

select * from customerinfo;

-- 16.Without using “Join”, can we get the “ExitCategory” from ExitCustomers table to Bank_Churn table? If yes do this using SQL.          
SELECT b.*,
    (SELECT ExitCategory 
     FROM exitcustomer ec 
     WHERE ec.ExitID = b.Exited) AS ExitCategory
FROM bank_churn b;

	
# 17. Write the query to get the customer IDs, their last name, and whether they are active or not for the customers whose surname ends with “on”.

select * from activecustomer; 

SELECT ci.CustomerId, ci.Surname AS lastname,
    CASE
        WHEN bc.IsActiveMember = 1 THEN 'Active'
        ELSE 'Inactive'
    END AS ActiveStatus
FROM customerinfo ci
JOIN bank_churn bc ON ci.CustomerId = bc.CustomerId
WHERE ci.Surname LIKE '%on';


-- 18.	Utilize SQL queries to segment customers based on demographics and account details.
SELECT
    CASE
        WHEN age BETWEEN 18 AND 30 THEN '18-30'
        WHEN age BETWEEN 31 AND 40 THEN '31-40'
        	   WHEN age BETWEEN 41 AND 50 THEN '41-50'
       	   ELSE '51+'
   	   END AS age_group, COUNT(*) AS num_customers
	FROM customerinfo
	GROUP BY age_group;
    
-- 19.	In the “Bank_Churn” table how can you modify the name of the “HasCrCard” column to “Has_creditcard”? 
ALTER TABLE bank_churn
CHANGE COLUMN HasCrCard Has_creditcard INT;





























