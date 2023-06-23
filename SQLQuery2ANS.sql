use  Advance_casestudy

select * from DIM_MANUFACTURER
select * from DIM_MODEL
select * from DIM_CUSTOMER
select * from DIM_LOCATION
select * from DIM_DATE
select * from FACT_TRANSACTIONS

--Q1--BEGIN 
SELECT T1.IDCustomer, T1.[Date], DATEPART (YEAR, T1.[Date]) AS YEAR_NUMBER, T2.[State], T2.Country FROM FACT_TRANSACTIONS AS T1 
LEFT JOIN DIM_LOCATION AS T2 ON 
T1.IDLocation = T2.IDLocation 
WHERE DATEPART (YEAR, T1.[Date]) >= 2005
--Q1--END



--Q2--BEGIN 
SELECT TOP 1 T1.IDManufacturer, T1.Manufacturer_Name,T4.Country, T4.[State], 
COUNT(T1.Manufacturer_Name) AS Manufacturer_count FROM DIM_MANUFACTURER AS T1
LEFT JOIN DIM_MODEL AS T2 ON 
T1.IDManufacturer=T2.IDManufacturer
LEFT JOIN FACT_TRANSACTIONS AS T3 ON
T2.IDModel=T3.IDModel
LEFT JOIN DIM_LOCATION AS T4 ON
T3.IDLocation=T4.IDLocation
WHERE T4.Country = 'US' AND T1.Manufacturer_Name = 'Samsung'
GROUP BY T1.IDManufacturer, T1.Manufacturer_Name,T4.Country, T4.[State]
ORDER BY COUNT(T1.Manufacturer_Name) DESC
--Q2--END


--Q3--BEGIN
SELECT T1.IDModel, ZipCode, [State], COUNT (T1.IDModel) AS NO_OF_TRANSACTION FROM FACT_TRANSACTIONS AS T1 
LEFT JOIN DIM_LOCATION AS T2 ON 
T1.IDLocation = T2.IDLocation 
GROUP BY  T1.IDModel, ZipCode, [State]
ORDER BY COUNT (T1.IDModel) DESC
--Q3--END


--Q4--BEGIN 
SELECT TOP 1 T1.IDModel, T1.Model_Name, T2.Manufacturer_Name, MIN(T1.Unit_price) AS cellphone_price FROM DIM_MODEL AS T1
LEFT JOIN DIM_MANUFACTURER AS T2 ON T1.IDManufacturer= T2.IDManufacturer
GROUP BY T1.IDModel, T1.Model_Name, T2.Manufacturer_Name
ORDER BY MIN(Unit_price) ASC
--Q4--END


--Q5--BEGIN 
SELECT T2.IDModel,T1.IDManufacturer, AVG(T2.Unit_price) AS AveragePrice  FROM DIM_MANUFACTURER AS T1
LEFT JOIN DIM_MODEL AS T2 ON 
T1.IDManufacturer=T2.IDManufacturer
LEFT JOIN FACT_TRANSACTIONS AS T3 ON
T2.IDModel=T3.IDModel
WHERE  T1.IDManufacturer IN (SELECT TOP 5 T1.IDManufacturer FROM DIM_MANUFACTURER AS T1
LEFT JOIN DIM_MODEL AS T2 ON 
T1.IDManufacturer=T2.IDManufacturer
LEFT JOIN FACT_TRANSACTIONS AS T3 ON
T2.IDModel=T3.IDModel 
GROUP BY T1.IDManufacturer
ORDER BY AVG(T3.TotalPrice), COUNT(T3.Quantity)
)
GROUP BY  T2.IDModel, T1.IDManufacturer 
--Q5--END


--Q6--BEGIN 
SELECT  T1.Customer_Name, AVG(T2.TotalPrice) AS Average_amount, DATEPART (YEAR, T2.[Date])  AS YEAR_NUMBER FROM DIM_CUSTOMER AS T1
LEFT JOIN FACT_TRANSACTIONS AS T2 ON 
T1.IDCustomer = T2.IDCustomer
WHERE DATEPART (YEAR, T2.[Date]) = '2009'
GROUP BY  T1.Customer_Name, DATEPART (YEAR, T2.[Date]) 
HAVING AVG(T2.TotalPrice) > 500
--Q6--END


--Q7--BEGIN 
    SELECT IdModel FROM (
    SELECT IdModel,
           ROW_NUMBER() OVER (PARTITION BY YEAR([Date]) ORDER BY Quantity DESC) rn
    FROM FACT_TRANSACTIONS
    WHERE YEAR([Date]) IN (2008, 2009, 2010)
) AS FT
WHERE rn <= 5
GROUP BY IdModel
HAVING COUNT(*) = 3
--Q7--END


--Q8--BEGIN 
SELECT *FROM(
      SELECT T1.IDManufacturer, T1.Manufacturer_Name, SUM(T3.TotalPrice) AS Sales, ROW_NUMBER() OVER (ORDER BY SUM(T3.TotalPrice) DESC) AS rn
      FROM DIM_MANUFACTURER AS T1
      LEFT JOIN DIM_MODEL AS T2 ON 
      T1.IDManufacturer=T2.IDManufacturer
      LEFT JOIN FACT_TRANSACTIONS AS T3 ON
      T2.IDModel=T3.IDModel
      WHERE DATEPART (YEAR, T3.[Date]) = '2009'
      GROUP BY T1.IDManufacturer, T1.Manufacturer_Name) temp
WHERE rn =2
union
SELECT *FROM(
      SELECT T1.IDManufacturer, T1.Manufacturer_Name, SUM(T3.TotalPrice) AS Sales, ROW_NUMBER() OVER (ORDER BY SUM(T3.TotalPrice) DESC) AS rn
      FROM DIM_MANUFACTURER AS T1
      LEFT JOIN DIM_MODEL AS T2 ON 
      T1.IDManufacturer=T2.IDManufacturer
      LEFT JOIN FACT_TRANSACTIONS AS T3 ON
      T2.IDModel=T3.IDModel
      WHERE DATEPART (YEAR, T3.[Date]) = '2010'
      GROUP BY T1.IDManufacturer, T1.Manufacturer_Name) temp
WHERE rn =2
--Q8--END


--Q9--BEGIN 
SELECT DISTINCT T1.IDManufacturer, T1.Manufacturer_Name, DATEPART (YEAR, T3.[Date]) FROM DIM_MANUFACTURER AS T1
LEFT JOIN DIM_MODEL AS T2 ON 
T1.IDManufacturer=T2.IDManufacturer
LEFT JOIN FACT_TRANSACTIONS AS T3 ON
T2.IDModel=T3.IDModel
WHERE DATEPART (YEAR, T3.[Date]) = '2010' AND NOT DATEPART (YEAR, T3.[Date]) = '2009'
--Q9--END


--Q10--BEGIN 
SELECT TOP 100 IDCustomer, YEAR([Date]) as [YEAR], AVG(TotalPrice) AS Average_TotalPrice, AVG(Quantity) AS Average_Quantity,
  ((TotalPrice - LAG(TotalPrice) OVER (ORDER BY YEAR(Date))) / LAG(TotalPrice) OVER (ORDER BY YEAR(Date))) * 100 AS percentage_change FROM FACT_TRANSACTIONS
GROUP BY IDCustomer, YEAR(Date), TotalPrice 
ORDER BY YEAR(Date) DESC, AVG(TotalPrice) DESC, AVG(Quantity) DESC
--Q10--END


