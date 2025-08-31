/* Pizza ETL — Full end-to-end (Option B) — Generated: 2025-08-31T09:24:25 */

USE PizzaETL;
GO
-- Build fact_sales incrementally for new order_details
INSERT INTO dwh.fact_sales (order_details_id, order_id, date_key, pizza_key, quantity, unit_price, line_amount)
SELECT
    od.order_details_id,
    od.order_id,
    CONVERT(INT, FORMAT(o.order_date, 'yyyyMMdd')) AS date_key,
    dp.pizza_key,
    od.quantity,
    dp.price AS unit_price,
    CAST(od.quantity * dp.price AS DECIMAL(12,2)) AS line_amount
FROM ods.order_details od
JOIN ods.orders o ON o.order_id = od.order_id
LEFT JOIN dwh.dim_pizza dp ON dp.pizza_id = od.pizza_id
WHERE NOT EXISTS (SELECT 1 FROM dwh.fact_sales f WHERE f.order_details_id = od.order_details_id)
  AND dp.pizza_key IS NOT NULL;
GO
