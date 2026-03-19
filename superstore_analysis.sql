-- Query 1: Year over Year Sales Growth by Category
-- Business Question: Which categories are growing or declining each year?

WITH yearly_cte
AS
( SELECT 
  Category,
  year(order_date) AS years, 
  SUM(sales) AS total_sales
  FROM superstore
  GROUP BY category, year(order_date)
)

yoy_cte
AS
(
 SELECT 
 category,
 years,
 total_sales,
 LAG(total_sales) over (PARTITION by category 
						order by year) 
						AS prev_year_sales
						
FROM yearly_cte 
)

SELECT category, 
       year,
	   total_sales,
	   prev_year_sales,
	   ROUND((total_sales - prev_year_sales)*100.0/prev_year_sales, 2) AS yoy_growth_pct
FROM yoy_cte 
WHERE prev_year_sales is not null 
order by category,year; 

-- Query 2: Running Total of Sales by Month WITHin Each Year 
-- Business Question: How does sales momentum build through each year?

SELECT 
	YEAR(order_date) AS years,
	MONTH(order_date) AS months,
	ROUND(sum(sales),2) AS monthly_sales,
	ROUND(sum(sum(sales)) over
	(partition by year(order_date) 
	order by MONTH(order_date)),2) AS Running_Total
FROM superstore
GROUP BY YEAR(order_date), MONTH(order_date)
order by year, month;


-- Query 3: Top 3 Products by Profit in Each Category 
-- Business Question: Which Products are the star performers in each category?

WITH profit_cte
AS
(
 SELECT category,product_name,
		ROUND(sum(profit),2) AS total_profit,
		DENSE_RANK() over ( partition by category order by sum(profit) desc)
		AS prfrank
FROM superstore
GROUP BY category,product_name
)

SELECT 
	Category, product_name, total_profit,
	prfrank 
FROM profit_cte 
WHERE prfrank <= 3
order by category, prfrank;

-- Query 4: Months WHERE Sales Declined vs Previous Month
-- Business Question: Which months showed sales decline and by how much?

WITH mon_cte
AS
(
	SELECT 
		YEAR(order_date) AS years,
		MONTH(order_date) AS months,
		round(sum(sales),2) AS monthly_sales
	FROM superstore
	GROUP BY YEAR(order_date),MONTH(order_date)
),
mon_com_cte 
AS
(
	SELECT 
		years,
		months,
		monthly_sales,
		LAG(monthly_sales) over() (order by years, months) 
		AS prev_month_sales
	FROM mon_cte 
)

SELECT 
	years,
	months,
	monthly_sales,
	prev_month_sales,
	ROUND(monthly_sales - prev_month_sales),2) AS month_change,
	ROUND((monthly_sales - prev_month_sales)*100.0/monthly_sales , 2) AS pct_change
	FROM 
	mon_com_cte
	WHERE monthly_sales < prev_month_sales
	order by pct_change;
	
-- Query 5: Customer Segments Genrating Above Average Profit Each Year 
-- Business Question: Which Customer segments consistently outperform the average?

WITH seg_cte
AS
(
	SELECT 
		YEAR(order_date) AS years,
		segment,
		ROUND(sum(profit),2) AS total_profit
	FROM superstore
	GROUP BY YEAR(order_date), segment
),
yearly_cte 
AS
(
	SELECT
		years,
		ROUND(avg(total_profit),2) AS avg_profit
	FROM seg_cte 
	GROUP BY years
)

SELECT
	sp.years,
	sp.segment,
	sp.total_profit,
	ya.avg_profit,
	ROUND(sp.total_profit - ya.avg_profit),2) AS above_avg_by
FROM seg_cte sp 
join yearly_cte ya 
ON sp.years=ya.years
WHERE sp.total_profit > ya.avg_profit
ORDER BY sp.years, sp.total_profit DESC;

-- Query 6: Product Profit Margin Categorisation
-- Business Question: Which products are high, medium, or low margin performers?

SELECT 
    Sub_Category,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit,
    ROUND(SUM(Profit) * 100.0 / SUM(Sales), 2) AS profit_margin_pct,
    CASE 
        WHEN SUM(Profit) * 100.0 / SUM(Sales) >= 20 THEN 'High Margin'
        WHEN SUM(Profit) * 100.0 / SUM(Sales) BETWEEN 10 AND 20 THEN 'Medium Margin'
        WHEN SUM(Profit) * 100.0 / SUM(Sales) > 0 THEN 'Low Margin'
        ELSE 'Loss Making'
    END AS margin_category
FROM superstore
GROUP BY Sub_Category
ORDER BY profit_margin_pct DESC;

-- Query 7: Top Performers in 2014 That Dropped Out by 2017
-- Business Question: Which products lost their star status over four years?

WITH top_2014 AS (
    SELECT 
        Product_Name,
        ROUND(SUM(Sales), 2) AS sales_2014,
        RANK() OVER (ORDER BY SUM(Sales) DESC) AS rank_2014
    FROM superstore
    WHERE YEAR(Order_Date) = 2014
    GROUP BY Product_Name
),
top_2017 AS (
    SELECT 
        Product_Name,
        ROUND(SUM(Sales), 2) AS sales_2017,
        RANK() OVER (ORDER BY SUM(Sales) DESC) AS rank_2017
    FROM superstore
    WHERE YEAR(Order_Date) = 2017
    GROUP BY Product_Name
)
SELECT 
    t1.Product_Name,
    t1.sales_2014,
    t1.rank_2014,
    COALESCE(t2.sales_2017, 0) AS sales_2017,
    COALESCE(t2.rank_2017, 999) AS rank_2017
FROM top_2014 t1
LEFT JOIN top_2017 t2 ON t1.Product_Name = t2.Product_Name
WHERE t1.rank_2014 <= 5
AND (t2.rank_2017 > 5 OR t2.rank_2017 IS NULL)
ORDER BY t1.rank_2014;

-- Query 8: Top 3 and Bottom 3 Subcategories by Profit
-- Business Question: Which subcategories are best and worst profit performers?

SELECT 
    Sub_Category,
    ROUND(SUM(Profit), 2) AS total_profit,
    'Top Performer' AS performance_label
FROM superstore
GROUP BY Sub_Category
ORDER BY SUM(Profit) DESC
LIMIT 3

UNION ALL

SELECT 
    Sub_Category,
    ROUND(SUM(Profit), 2) AS total_profit,
    'Bottom Performer' AS performance_label
FROM superstore
GROUP BY Sub_Category
ORDER BY SUM(Profit) ASC
LIMIT 3;
