create database Projectnumber2;

use Projectnumber2;


select * from retail_transactions;



SHOW COLUMNS FROM Retail_Transactions;


ALTER TABLE Retail_Transactions
RENAME COLUMN `ï»¿Invoice` TO InvoiceNo;

DESCRIBE Retail_Transactions;

ALTER TABLE Retail_Transactions
ADD COLUMN InvoiceDate_New DATETIME;

SELECT
    COUNT(*) AS Total,
    COUNT(InvoiceDate_New) AS Converted
FROM Retail_Transactions;

UPDATE Retail_Transactions
SET InvoiceDate_New =
CASE
    WHEN InvoiceDate LIKE '%-%'
        THEN STR_TO_DATE(InvoiceDate,'%d-%m-%Y %H:%i:%s')
    ELSE
        STR_TO_DATE(InvoiceDate,'%m/%d/%Y %H:%i')
END;


SET SQL_SAFE_UPDATES = 0;


SELECT InvoiceDate, InvoiceDate_New
FROM Retail_Transactions
LIMIT 20;


SELECT COUNT(*) AS Not_Converted
FROM Retail_Transactions
WHERE InvoiceDate_New IS NULL;









ALTER TABLE Retail_Transactions
DROP COLUMN InvoiceDate;



ALTER TABLE Retail_Transactions
RENAME COLUMN InvoiceDate_New TO InvoiceDate;


DESCRIBE Retail_Transactions;

DROP TABLE IF EXISTS RFM_Analysis;

CREATE TABLE RFM_Analysis AS
SELECT
    `Customer ID`,
    DATEDIFF(
        (SELECT MAX(InvoiceDate) FROM Retail_Transactions),
        MAX(InvoiceDate)
    ) AS Recency,
    COUNT(DISTINCT InvoiceNo) AS Frequency,
    ROUND(SUM(Sales),2) AS Monetary
FROM Retail_Transactions
GROUP BY `Customer ID`;



CREATE TABLE RFM_Scores AS
SELECT
    `Customer ID`,
    Recency,
    Frequency,
    Monetary,

    NTILE(5) OVER (ORDER BY Recency DESC) AS R_Score,

    NTILE(5) OVER (ORDER BY Frequency ASC) AS F_Score,

    NTILE(5) OVER (ORDER BY Monetary ASC) AS M_Score

FROM RFM_Analysis;


SELECT *
FROM RFM_Scores
LIMIT 10;


DESCRIBE Retail_Transactions;


SELECT COUNT(*) AS Total_Customers
FROM RFM_Scores;



SELECT
    MIN(R_Score), MAX(R_Score),
    MIN(F_Score), MAX(F_Score),
    MIN(M_Score), MAX(M_Score)
FROM RFM_Scores;



CREATE TABLE Customer_RFM AS
SELECT
    `Customer ID`,
    Recency,
    Frequency,
    Monetary,
    R_Score,
    F_Score,
    M_Score,
    CONCAT(R_Score, F_Score, M_Score) AS RFM_Score,

    CASE
        WHEN R_Score = 5 AND F_Score >= 4 AND M_Score >= 4
            THEN 'Champions'

        WHEN R_Score >= 4 AND F_Score >= 3
            THEN 'Loyal Customers'

        WHEN R_Score >= 4 AND F_Score <= 2
            THEN 'Potential Loyalists'

        WHEN R_Score <= 2 AND F_Score >= 3
            THEN 'At Risk'

        ELSE 'Others'
    END AS Customer_Segment

FROM RFM_Scores;

SELECT Customer_Segment, COUNT(*) AS Customers
FROM Customer_RFM
GROUP BY Customer_Segment
ORDER BY Customers DESC;


SELECT COUNT(*) AS Total_Customers
FROM Customer_RFM;




SELECT * FROM Customer_RFM;
SELECT COUNT(*) FROM Customer_RFM;




















SHOW VARIABLES LIKE 'secure_file_priv';

SELECT *
FROM Customer_RFM
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Customer_RFM.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';