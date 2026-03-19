# Superstore Sales Analysis — SQL
## Business Problem
A retail company wants to understand sales performance trends across product categories, identify top and bottom performers, and detect year over year growth and decline patterns to support strategic business decisions.
## Dataset
- Source: Sample Superstore dataset
- 9,994 records covering 2014 to 2017
- Columns: Order Date, Category, Sub-Category, Product Name, Sales, Profit, Discount, Region, Segment
## SQL Approach — 8 Business Queries
Query 1 — Year over year sales growth by category — LAG, CTE, PARTITION BY
Query 2 — Running total of sales by month within each year — SUM OVER, PARTITION BY
Query 3 — Top 3 products by profit in each category — DENSE_RANK, PARTITION BY
Query 4 — Months where sales declined vs previous month — LAG, CTE
Query 5 — Customer segments above average profit each year — CTE, JOIN, Subquery
Query 6 — Product profit margin categorisation — CASE WHEN, Aggregation
Query 7 — Top performers in 2014 that dropped out by 2017 — CTE, LEFT JOIN, RANK
Query 8 — Top 3 and bottom 3 subcategories by profit — UNION ALL
## Key Business Insights
- Year over year category growth trends identified using LAG window function
- Running totals reveal which months drive peak sales momentum
- Top 3 products per category identified for each business unit
- Loss making subcategories flagged for immediate management action
- Products that lost top performer status between 2014 and 2017 identified
- Best and worst performing subcategories combined in single executive view
## Tools Used
- MySQL syntax
- GitHub
## Repository Structure
- superstore_analysis.sql — All 8 SQL queries with business comments
