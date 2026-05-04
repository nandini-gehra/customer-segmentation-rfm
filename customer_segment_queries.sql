-- Project: Customer Segmentation
-- Description: SQL queries for data cleaning, segmentation, and analysis
-- Author: Nandini


SELECT COUNT(*) FROM customer_segment.test;

SELECT * 
FROM customer_segment.test
LIMIT 10;


DROP TABLE IF EXISTS customer_segment.cleaned_customers;

CREATE TABLE customer_segment.cleaned_customers AS
SELECT 
    ID,
    Gender,
    Ever_Married,
    Age,
    Graduated,

    COALESCE(Profession, 'Unknown') AS Profession,

    COALESCE(Work_Experience, 
        (SELECT ROUND(AVG(Work_Experience),0) FROM customer_segment.test)
    ) AS Work_Experience,

    Spending_Score,

    COALESCE(Family_Size, 
        (SELECT ROUND(AVG(Family_Size),0) FROM customer_segment.test)
    ) AS Family_Size

FROM customer_segment.test;


DROP TABLE IF EXISTS customer_segment.segmented_customers;

CREATE TABLE customer_segment.segmented_customers AS
SELECT 
    *,
    CASE 
        WHEN Age < 30 AND Spending_Score = 'Low' THEN 'Young Low Spenders'
        WHEN Age BETWEEN 30 AND 50 AND Spending_Score = 'High' THEN 'Affluent Professionals'
        WHEN Family_Size >= 4 THEN 'Family Customers'
        WHEN Age > 50 AND Spending_Score = 'Low' THEN 'Low Engagement Seniors'
        ELSE 'Average Customers'
    END AS Customer_Segment
FROM customer_segment.cleaned_customers;

-- segment distribution %
SELECT 
    Customer_Segment, 
    COUNT(*) AS Total_Customers,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM customer_segment.segmented_customers), 0) AS Percentage
FROM customer_segment.segmented_customers
GROUP BY Customer_Segment
ORDER BY Total_Customers DESC;

-- average behavior 

SELECT 
    Customer_Segment,
    ROUND(AVG(Age), 0) AS Avg_Age,
    ROUND(AVG(Work_Experience), 0) AS Avg_Experience,
    ROUND(AVG(Family_Size), 0) AS Avg_Family_Size
FROM customer_segment.segmented_customers
GROUP BY Customer_Segment
ORDER BY Avg_Experience DESC;

-- gender distribution %

SELECT 
    Customer_Segment,
    Gender,
    COUNT(*) AS Total,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY Customer_Segment), 2) AS Percentage
FROM customer_segment.segmented_customers
GROUP BY Customer_Segment, Gender;


-- profession distribution 
SELECT 
    Customer_Segment,
    Profession,
    COUNT(*) AS Count
FROM customer_segment.segmented_customers
GROUP BY Customer_Segment, Profession
ORDER BY Customer_Segment, Count DESC;

-- high value customer 
SELECT 
    ID,
    Age,
    Profession,
    Work_Experience,
    Spending_Score
FROM customer_segment.segmented_customers
WHERE Customer_Segment = 'Affluent Professionals'
ORDER BY Work_Experience DESC
LIMIT 20;

SELECT * 
FROM customer_segment.segmented_customers;