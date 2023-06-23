use retail_assignment
select * from Customer
select * from prod_cat_info
select * from Transactions


SELECT * FROM INFORMATION_SCHEMA.TABLES 

--SQL Basic Case Study

--DATA PREPARATION AND UNDERSTANDING

--Q1--BEGIN 1
select * from (
select 'Customer' as table_name, count (*) as No_of_rows from customer UNION ALL
select 'prod_cat_info' as table_name, count (*) as No_of_rows from prod_cat_info UNION ALL
select 'Transactions' as table_name, count (*) as No_of_rows from Transactions ) retail_assignment
--Q1--END

--Q2--BEGIN
select transaction_id, Qty,Rate, Tax, Store_type
from Transactions
WHERE Qty <0
--Q2--END

--Q3--BEGIN 
--IT HAS BEEN CONVERTED DURING IMPORT STAGE ITSELF
--Q3--END


--Q4--BEGIN
SELECT DATEDIFF( YEAR,MIN(tran_date), MAX(tran_date)) AS Year_range, 
DATEDIFF( MONTH,MIN(tran_date) , MAX(tran_date)) AS Month_range, 
DATEDIFF( DAY,MIN(tran_date),  MAX(tran_date)) AS Day_range FROM Transactions
--Q4--END

--Q5--BEGIN
select * from prod_cat_info
where prod_subcat = 'DIY' 
--Q5--END

--DATA ANALYSIS

--Q1--BEGIN 
select TOP 1 Store_type, COUNT (Store_type) AS CHANNELS 
from Transactions  
GROUP BY Store_type
ORDER BY COUNT (Store_type) DESC
--Q1--END

--Q2--BEGIN
select Gender, COUNT (Gender) AS Gen_count 
from Customer
GROUP BY Gender
ORDER BY COUNT (Gender) DESC
--Q2--END

--Q3--BEGIN      
select TOP 1 city_code, COUNT(customer_Id) AS customer_count
from Customer
GROUP BY city_code
ORDER BY COUNT (customer_Id) DESC
--Q3--END

--Q4--BEGIN
SELECT prod_cat,  COUNT ( prod_subcat ) AS prod_subcount FROM prod_cat_info
GROUP BY prod_cat
HAVING prod_cat= 'Books'
--Q4--END

--Q5--BEGIN
--IN TERMS OF PRODUCT CATEGORY ONLY
SELECT TOP 1 prod_cat_code, COUNT(Qty) AS order_Qty from Transactions
GROUP BY  prod_cat_code
HAVING COUNT(Qty) >0
ORDER BY COUNT(Qty) DESC
--IN TERMS OF PRODUCT CATEGORY AND SUB CATEGORY
SELECT TOP 1 prod_cat_code, prod_subcat_code, COUNT(Qty) AS order_Qty from Transactions
GROUP BY  prod_cat_code, prod_subcat_code
HAVING COUNT(Qty) >0
ORDER BY COUNT(Qty) DESC
--Q5--END

--Q6--BEGIN
SELECT prod_cat_code, SUM (total_amt) AS net_total_revenue from Transactions
GROUP BY prod_cat_code
HAVING prod_cat_code IN ('3','5')
--Q6--END
	
--Q7--BEGIN 
SELECT cust_id, COUNT (transaction_id) AS cust_trans_count from Transactions
WHERE Qty >0
GROUP BY cust_id
HAVING COUNT (transaction_id) >10
ORDER BY COUNT (transaction_id) DESC
--Q7--END

--Q8--BEGIN
SELECT prod_cat, SUM( total_amt) AS total_amount,  Store_type FROM prod_cat_info
INNER JOIN Transactions ON prod_cat_info.prod_cat_code = Transactions.prod_cat_code
WHERE (prod_cat IN ( 'Electronics', 'Clothing')) AND Store_type ='Flagship store'
GROUP BY prod_cat,Store_type 
--Q8--END

--Q9--BEGIN 
SELECT prod_subcat, SUM (total_amt) AS total_revenue FROM prod_cat_info
INNER JOIN Transactions ON prod_cat_info.prod_cat_code = Transactions.prod_cat_code
INNER JOIN Customer ON Transactions.cust_id = Customer.customer_Id
WHERE Gender = 'M' AND prod_cat = 'Electronics'
GROUP BY prod_subcat
ORDER BY prod_subcat
--Q9--END

--Q10--BEGIN
SELECT T1.prod_subcat_code,
(CASE WHEN total_amt>0 THEN total_amt/ (SELECT SUM (total_amt) FROM Transactions)*100 ELSE 0 END) AS sales_percentage,
(CASE WHEN total_amt<0 THEN ABS(total_amt)/ (SELECT SUM (total_amt) FROM Transactions)*100 ELSE 0 END) AS return_percentage FROM Transactions as T1
INNER JOIN prod_cat_info as T2
ON T1.prod_cat_code = T2.prod_cat_code AND T1.prod_subcat_code = 
T2.prod_sub_cat_code
WHERE T1.prod_subcat_code IN (
select top 5 T2.prod_sub_cat_code
from prod_cat_info as T2
inner join Transactions as T1
ON T2.prod_cat_code = T1.prod_cat_code AND T2.prod_sub_cat_code = 
T1.prod_subcat_code
group by T2.prod_sub_cat_code
order by SUM(total_amt) desc
)
group by T1.prod_subcat_code,total_amt 
--Q10--END

--Q11--BEGIN 
SELECT SUM(T1.total_amt) as net_total_revenue
FROM (SELECT T1.*,
             MAX(T1.tran_date) OVER () as max_tran_date
      FROM Transactions T1
     ) T1 JOIN
     Customer T2
     ON T1.cust_id = T2.customer_Id
WHERE T1.tran_date >= DATEADD(day, -30, T1.max_tran_date) AND 
      T1.tran_date >= DATEADD(YEAR, 25, T2.DOB) AND
      T1.tran_date < DATEADD(YEAR, 31, T2.DOB)
--Q11--END

--Q12--BEGIN
Select TOP 1 T2.prod_cat, sum(T1.total_amt) as total_return_amount
From Transactions as T1
inner join prod_cat_info as T2 
on T1.prod_subcat_code=T2.prod_sub_cat_code and T1.prod_cat_code = T2.prod_cat_code
WHERE  T1.total_amt < 0 AND T1.tran_date >= (SELECT dateadd(month, -3 , (max(tran_date))) FROM Transactions)
GROUP BY T2.prod_cat
ORDER BY sum(T1.total_amt) ASC
--Q12--END

--Q13--BEGIN      
SELECT TOP 1 Store_type, SUM(total_amt) AS SALES_AMT, COUNT(Qty) AS QTY_SOLD
FROM Transactions
GROUP BY Store_type
ORDER BY SUM(total_amt) DESC, COUNT(Qty) DESC
--Q13--END

--Q14--BEGIN
SELECT T1.prod_cat_code, T1.prod_cat, AVG (total_amt) as total_amount_average FROM prod_cat_info as T1
INNER JOIN Transactions as T2
ON T1.prod_cat_code = T2.prod_cat_code
GROUP BY T1.prod_cat_code, T1.prod_cat
HAVING AVG (total_amt) > (SELECT AVG(total_amt) FROM Transactions)
--Q14--END

--Q15--BEGIN
SELECT T2.prod_cat_code , T1.prod_subcat_code, SUM (total_amt) AS total_revenue, AVG (total_amt) as average_revenue FROM Transactions as T1
INNER JOIN prod_cat_info as T2
ON T1.prod_cat_code = T2.prod_cat_code AND T1.prod_subcat_code = 
T2.prod_sub_cat_code
WHERE T2.prod_cat_code IN (
select top 5 T2.prod_cat_code
from prod_cat_info as T2
inner join Transactions as T1
ON T2.prod_cat_code = T1.prod_cat_code AND T2.prod_sub_cat_code = 
T1.prod_subcat_code
group by T2.prod_cat_code
order by COUNT(Qty) desc
)
group by T1.prod_subcat_code, T2.prod_cat_code 
--Q15--END






