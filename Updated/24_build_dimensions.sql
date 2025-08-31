/* Pizza ETL — Full end-to-end (Option B) — Generated: 2025-08-31T09:24:25 */

USE PizzaETL;
GO
-- Build DimDate
INSERT INTO dwh.dim_date (date_key, full_date, year, quarter, month, day, day_name, month_name, is_weekend)
SELECT DISTINCT
    CONVERT(INT, FORMAT(order_date, 'yyyyMMdd')) AS date_key,
    order_date,
    DATEPART(YEAR, order_date),
    DATEPART(QUARTER, order_date),
    DATEPART(MONTH, order_date),
    DATEPART(DAY, order_date),
    DATENAME(WEEKDAY, order_date),
    DATENAME(MONTH, order_date),
    CASE WHEN DATEPART(WEEKDAY, order_date) IN (1,7) THEN 1 ELSE 0 END
FROM ods.orders o
WHERE order_date IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM dwh.dim_date d WHERE d.date_key = CONVERT(INT, FORMAT(o.order_date,'yyyyMMdd')));
GO

-- Build DimPizza (surrogate keys)
MERGE dwh.dim_pizza AS tgt
USING (
    SELECT p.pizza_id, p.pizza_type_id, p.size, p.price, pt.name AS pizza_name, pt.category
    FROM ods.pizzas p
    LEFT JOIN ods.pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
) AS src
ON tgt.pizza_id = src.pizza_id
WHEN MATCHED THEN UPDATE SET pizza_type_id = src.pizza_type_id, size = src.size, price = src.price, pizza_name = src.pizza_name, category = src.category
WHEN NOT MATCHED THEN INSERT (pizza_id, pizza_type_id, size, price, pizza_name, category) VALUES (src.pizza_id, src.pizza_type_id, src.size, src.price, src.pizza_name, src.category);
GO
