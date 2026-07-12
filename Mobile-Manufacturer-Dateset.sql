--SQL Advance Case Study


--Q1--BEGIN 
	
SELECT DISTINCT l.state
FROM FACT_TRANSACTIONS t
JOIN DIM_LOCATION l ON t.IDLocation = l.IDLocation
WHERE YEAR(t.date) >= 2005;


--Q1--END

--Q2--BEGIN

SELECT TOP 1 l.state
FROM FACT_TRANSACTIONS t
JOIN DIM_LOCATION l ON t.IDLocation = l.IDLocation
JOIN DIM_MODEL m ON t.IDModel = m.IDModel
JOIN DIM_MANUFACTURER man ON m.IDManufacturer = man.IDManufacturer
WHERE man.manufacturer_name = 'Samsung' AND l.Country = 'US'
group by l.State
order by sum(t.quantity) DESC;

--Q2--END

--Q3--BEGIN      
 
 SELECT m.Model_Name, l.zipcode,l.state, COUNT(t.IDModel) AS Number_of_Transactions
 FROM FACT_TRANSACTIONS t
 JOIN DIM_LOCATION l ON t.IDLocation = l.IDLocation
 JOIN DIM_MODEL m ON t.IDModel = m.IDModel
 GROUP BY m.Model_Name,l.ZipCode,l.State;


--Q3--END

--Q4--BEGIN

SELECT TOP 1 Model_name,Unit_price
from DIM_MODEL
order by Unit_price ASC;


--Q4--END

--Q5--BEGIN

SELECT M.MODEL_NAME,AVG(M.UNIT_PRICE) AS AVERAGE_PRICE
FROM DIM_MODEL M
WHERE M.IDManufacturer IN(
	SELECT TOP 5 m2.IDManufacturer
	from FACT_TRANSACTIONS t
	JOIN DIM_MODEL m2 ON t.IDModel = m2.IDModel
	group by m2.IDManufacturer
	order by sum(t.quantity) DESC 
)
GROUP BY M.Model_Name
ORDER BY AVERAGE_PRICE;


--Q5--END

--Q6--BEGIN

SELECT C.CUSTOMER_NAME, AVG(T.TOTALPRICE) AS AVERAGE_SPENT
FROM FACT_TRANSACTIONS t
JOIN DIM_CUSTOMER C ON t.IDCustomer = c.IDCustomer
WHERE YEAR(t.date) = 2009 
group by c.Customer_Name
Having AVG(t.totalprice) > 500;


--Q6--END
	
--Q7--BEGIN  
	
select m.model_name
from DIM_MODEL m
JOIN(
	select top 5 idmodel
	from FACT_TRANSACTIONS
	where YEAR(date) = 2008
	group by IDModel
	order by sum(quantity) desc
	) AS y2008 ON m.IDModel = y2008.IDModel
	join(
	select top 5 idmodel
	from FACT_TRANSACTIONS
	where year(date) = 2009
	group by IDModel
	order by sum(Quantity) desc
	) AS y2009 ON m.IDModel = y2009.IDModel
	join(
	select top 5 idmodel
	from FACT_TRANSACTIONS
	where YEAR(date) = 2010
	group by IDModel
	order by sum(Quantity)DESC
	)AS y2010 ON m.IDModel = y2010.IDModel;


--Q7--END	
--Q8--BEGIN

with rankedsales AS(
	select 
	man.manufacturer_name,
	YEAR(t.date) AS sales_year,
	sum(t.totalprice) AS total_sales,
	RANK() over (partition by year (t.date)
	order by sum(t.totalprice) desc) AS rank
	from FACT_TRANSACTIONS t
	join DIM_MODEL m ON t.IDModel = m.IDModel
	join DIM_MANUFACTURER man ON m.IDManufacturer = man.IDManufacturer
	where YEAR(t.date)IN (2009,2010)
	group by man.Manufacturer_Name,YEAR(t.date)
	)
	select manufacturer_name,sales_year
	from rankedsales
	where rank = 2;

--Q8--END
--Q9--BEGIN
	
select man.manufacturer_name
from FACT_TRANSACTIONS t
JOIN DIM_MODEL m ON t.IDModel = m.IDModel
JOIN DIM_MANUFACTURER man ON m.IDManufacturer = man.IDManufacturer
where year(t.Date) = 2010

EXCEPT

select man.manufacturer_name
from FACT_TRANSACTIONS t
JOIN DIM_MODEL m ON t.IDModel = m.IDModel
JOIN DIM_MANUFACTURER man ON m.IDManufacturer = man.IDManufacturer
where YEAR(t.Date) = 2009;

--Q9--END

--Q10--BEGIN
	
WITH TOP100CUSTOMERS AS (
	SELECT TOP 100 IDCUSTOMER
	FROM FACT_TRANSACTIONS
	GROUP BY IDCustomer
	ORDER BY SUM(TOTALPRICE)DESC
),
YEARLYDATA AS (
	SELECT
		C.CUSTOMER_NAME,
		T.IDCUSTOMER,
		YEAR(T.DATE) AS YEAR,
		AVG(T.TOTALPRICE) AS AVG_SPEND,
		AVG(CAST(T.QUANTITY AS FLOAT)) AS AVG_QUANTITY,
		SUM(T.TOTALPRICE) AS TOTAL_SPEND_PER_YEAR
	FROM FACT_TRANSACTIONS T
	JOIN DIM_CUSTOMER C ON T.IDCustomer = C. IDCustomer
	WHERE T.IDCustomer IN (SELECT IDCustomer FROM TOP100CUSTOMERS)
	GROUP BY C.Customer_Name ,T.IDCustomer ,YEAR(T.DATE)
)
	SELECT
		CUSTOMER_NAME,
		YEAR,
		AVG_SPEND,
		AVG_QUANTITY,
		CASE 
			WHEN LAG(TOTAL_SPEND_PER_YEAR) OVER (PARTITION BY IDCUSTOMER ORDER BY YEAR)IS NULL THEN 0
			ELSE((TOTAL_SPEND_PER_YEAR - LAG(TOTAL_SPEND_PER_YEAR)OVER(PARTITION BY IDCUSTOMER ORDER BY YEAR))/
				LAG(TOTAL_SPEND_PER_YEAR) OVER (PARTITION BY IDCUSTOMER ORDER BY YEAR)) * 100
			END AS PERCENTAGE_CHANGE
		FROM YEARLYDATA
		ORDER BY CUSTOMER_NAME, YEAR;


















--Q10--END
	