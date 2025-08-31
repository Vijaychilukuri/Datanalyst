/* Pizza ETL — Full end-to-end (Option B) — Generated: 2025-08-31T09:24:25 */

USE PizzaETL;
GO
-- Sales summary view
IF OBJECT_ID('dwh.v_sales_summary') IS NOT NULL DROP VIEW dwh.v_sales_summary;
CREATE VIEW dwh.v_sales_summary AS
SELECT dd.year, dd.month, dp.category, dp.pizza_name, dp.size, SUM(fs.quantity) AS total_qty, SUM(fs.line_amount) AS total_sales
FROM dwh.fact_sales fs
JOIN dwh.dim_date dd ON dd.date_key = fs.date_key
JOIN dwh.dim_pizza dp ON dp.pizza_key = fs.pizza_key
GROUP BY dd.year, dd.month, dp.category, dp.pizza_name, dp.size;
GO
-- Data quality checks (staging)
SELECT 'stg.orders' AS table_name,
       SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS Null_OrderID,
       SUM(CASE WHEN order_datetime IS NULL THEN 1 ELSE 0 END) AS Null_OrderDateTime
FROM stg.orders;
GO
SELECT 'stg.order_details' AS table_name,
       SUM(CASE WHEN order_details_id IS NULL THEN 1 ELSE 0 END) AS Null_OrderDetailsID,
       SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS Null_OD_OrderID,
       SUM(CASE WHEN pizza_id IS NULL THEN 1 ELSE 0 END) AS Null_PizzaID,
       SUM(CASE WHEN quantity IS NULL THEN 1 ELSE 0 END) AS Null_Quantity
FROM stg.order_details;
GO
