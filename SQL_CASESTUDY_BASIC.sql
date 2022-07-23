CREATE DATABASE SQL_CASESTUDY_BASIC

SELECT * FROM Customer
SELECT * FROM prod_cat_info
SELECT * FROM Transactions

--DATA PREPARATION AND UNDERSTANDING

--1. What is the total number of rows in each of the 3 tables in the database?

SELECT * FROM (
SELECT 'Customer' AS TABLE_NAME, COUNT(*) AS NO_OF_RECORDS FROM Customer UNION ALL
SELECT 'prod_cat_info' AS TABLE_NAME, COUNT(*) AS NO_OF_RECORDS FROM prod_cat_info UNION ALL
SELECT 'Transactions' AS TABLE_NAME, COUNT(*) AS NO_OF_RECORDS FROM Transactions
) TBL;

--2. What is the total number of transactions that have a return?

SELECT 
COUNT(Qty) AS [Total Number of Return Transactions]
FROM Transactions
WHERE Qty < 0;

/* 3. As you would have noticed, the dates provided across the datasets are not in a correct format.
As first steps, pls convert the date variables into valid date formats before proceeding ahead. */

ALTER TABLE Customer ALTER COLUMN DOB date null;
ALTER TABLE Transactions ALTER COLUMN tran_date date null;

/* 4. What is the time range of the transaction data available for analysis? 
Show the output in number of days, months and years simultaneously in different columns. */

SELECT
DATEDIFF(DD, MIN(tran_date), MAX(tran_date)) AS [Number of Days],
DATEDIFF(MM, MIN(tran_date), MAX(tran_date)) AS [Number of Months],
DATEDIFF(YY, MIN(tran_date), MAX(tran_date)) AS [Number of Years]
FROM Transactions;

--5. Which product category does the sub-category “DIY” belong to?

SELECT
prod_cat [Product Category]
FROM prod_cat_info
WHERE prod_subcat = 'DIY';

--DATA ANALYSIS

--1. Which channel is most frequently used for transactions?

SELECT TOP 1
Store_type AS [Most Frequent Channel]
FROM Transactions
GROUP BY Store_type
ORDER BY COUNT(Store_type) DESC;

--2. What is the count of Male and Female customers in the database?

SELECT 
Gender, COUNT(Gender) AS [Count of Genders]
FROM Customer
WHERE Gender IN ('M' , 'F')
GROUP BY Gender;

--3. From which city do we have the maximum number of customers and how many?

SELECT TOP 1
city_code, COUNT(customer_Id) AS [Maximum Number of Customers]
FROM Customer
GROUP BY city_code
ORDER BY [Maximum Number of Customers] DESC;

--4. How many sub-categories are there under the Books category?

SELECT
COUNT(prod_subcat) AS [Count of Sub-categories in Books Category]
FROM prod_cat_info
WHERE prod_cat = 'Books';

--5. What is the maximum quantity of products ever ordered?

SELECT TOP 1
prod_cat, COUNT(Qty) AS [Quantity]
FROM prod_cat_info INNER JOIN Transactions ON prod_cat_info.prod_cat_code = Transactions.prod_cat_code AND prod_sub_cat_code = prod_subcat_code
GROUP BY prod_cat
ORDER BY [Quantity] DESC;

--6. What is the net total revenue generated in categories Electronics and Books?

SELECT
prod_cat, SUM(total_amt) AS [Total Revenue]
FROM prod_cat_info INNER JOIN Transactions ON prod_cat_info.prod_cat_code = Transactions.prod_cat_code AND prod_sub_cat_code = prod_subcat_code
WHERE prod_cat IN ('Electronics' , 'Books')
GROUP BY prod_cat;

--7. How many customers have >10 transactions with us, excluding returns?

SELECT 
cust_id AS [Customers >10 Transactions]
FROM Transactions
WHERE Qty > 0
GROUP BY cust_id
HAVING COUNT(transaction_id)> 10;

--8. What is the combined revenue earned from the “Electronics” & “Clothing” categories, from “Flagship stores”?

SELECT
SUM(total_amt) AS [Total Combined Revenue]
FROM prod_cat_info INNER JOIN Transactions ON prod_cat_info.prod_cat_code = Transactions.prod_cat_code AND prod_sub_cat_code = prod_subcat_code
WHERE prod_cat IN ('Electronics' , 'Clothing') AND Store_type = 'Flagship store';

--9. What is the total revenue generated from “Male” customers in “Electronics” category? Output should display total revenue by prod sub-cat.

SELECT 
prod_subcat, SUM(total_amt) AS [Total Revenue]
FROM prod_cat_info INNER JOIN Transactions ON prod_cat_info.prod_cat_code = Transactions.prod_cat_code AND prod_sub_cat_code = prod_subcat_code
                   LEFT JOIN Customer ON cust_id = customer_Id
WHERE Gender = 'M' AND prod_cat = 'Electronics'
GROUP BY prod_subcat;

--10. What is percentage of sales and returns by product sub category; display only top 5 sub categories in terms of sales?

SELECT TOP 5
prod_subcat, SUM(total_amt) / (SELECT SUM(total_amt) FROM TRANSACTIONS) * 100 AS [Percentage of Sales]
FROM prod_cat_info INNER JOIN Transactions ON prod_cat_info.prod_cat_code = Transactions.prod_cat_code AND prod_sub_cat_code = prod_subcat_code
GROUP BY prod_subcat
ORDER BY [Percentage of Sales] DESC;

                                                            --OR--

SELECT 'Percentage of Sales' AS [Sale of Maximum Products], *
FROM(
SELECT TOP 5
prod_subcat, SUM(total_amt) / (SELECT SUM(total_amt) FROM TRANSACTIONS) * 100 AS [Percentage of Sales]
FROM prod_cat_info INNER JOIN Transactions ON prod_cat_info.prod_cat_code = Transactions.prod_cat_code AND prod_sub_cat_code = prod_subcat_code
GROUP BY prod_subcat
ORDER BY [Percentage of Sales] DESC) AS [T1]
UNION ALL
SELECT 'Percentage of Returns' AS [Sale of Maximum Products], *
FROM(
SELECT TOP 5
prod_subcat, SUM(total_amt) / (SELECT SUM(total_amt) FROM TRANSACTIONS WHERE Qty < 0) * 100 AS [Percentage of Returns]
FROM prod_cat_info INNER JOIN Transactions ON prod_cat_info.prod_cat_code = Transactions.prod_cat_code AND prod_sub_cat_code = prod_subcat_code
WHERE Qty < 0
GROUP BY prod_subcat
ORDER BY [Percentage of Returns] DESC) AS [T2];

/*11.	For all customers aged between 25 to 35 years find what is the net total revenue generated by these consumers
in last 30 days of transactions from max transaction date available in the data?*/

SELECT 
SUM(total_amt) AS [Total Revenue]
FROM CUSTOMER INNER JOIN Transactions ON customer_Id = cust_id
WHERE DATEDIFF(YY,DOB,tran_date) BETWEEN 25 AND 35 AND tran_date BETWEEN (SELECT DATEADD(DAY, -30, MAX(tran_date)) FROM Transactions) 
                                                                 AND (SELECT MAX(tran_date) FROM Transactions);

--12. Which product category has seen the max value of returns in the last 3 months of transactions?

SELECT TOP 1
prod_cat
FROM prod_cat_info INNER JOIN Transactions ON prod_cat_info.prod_cat_code = Transactions.prod_cat_code AND prod_sub_cat_code = prod_subcat_code
WHERE Qty < 0 AND tran_date BETWEEN (SELECT DATEADD(MONTH, -3, MAX(tran_date)) FROM Transactions) AND (SELECT MAX(tran_date) FROM Transactions)
GROUP BY prod_cat
ORDER BY SUM(total_amt);

--13. Which store-type sells the maximum products; by value of sales amount and by quantity sold?

SELECT 'By Value of Sales Amount' AS [Sale of Maximum Products], *
FROM(
SELECT TOP 1
Store_type
FROM Transactions
GROUP BY Store_type
ORDER BY SUM(total_amt)DESC) AS [T1]
UNION ALL
SELECT 'By Value of Quantity Sold' AS [Sale of Maximum Products], *
FROM(
SELECT TOP 1
Store_type
FROM Transactions
GROUP BY Store_type
ORDER BY SUM(Qty)DESC) AS [T2];

--14. What are the categories for which average revenue is above the overall average.

SELECT
prod_cat, AVG(total_amt) AS [Average Sales]
FROM prod_cat_info INNER JOIN Transactions ON prod_cat_info.prod_cat_code = Transactions.prod_cat_code AND prod_sub_cat_code = prod_subcat_code
GROUP BY prod_cat
HAVING AVG(total_amt) > (SELECT AVG(total_amt) FROM Transactions);

--15. Find the average and total revenue by each subcategory for the categories which are among top 5 categories in terms of quantity sold.

SELECT
prod_subcat, AVG(total_amt) AS [Average Revenue], SUM(total_amt) AS [Total Revenue]
FROM prod_cat_info INNER JOIN Transactions ON prod_cat_info.prod_cat_code = Transactions.prod_cat_code AND prod_sub_cat_code = prod_subcat_code
WHERE prod_cat IN (SELECT TOP 5
                   prod_cat
                   FROM prod_cat_info INNER JOIN Transactions ON prod_cat_info.prod_cat_code = Transactions.prod_cat_code AND prod_sub_cat_code = prod_subcat_code
                   GROUP BY prod_cat
                   ORDER BY SUM(Qty) DESC)
GROUP BY prod_subcat;








