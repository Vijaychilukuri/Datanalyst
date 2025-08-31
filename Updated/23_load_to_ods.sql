/* Pizza ETL — Full end-to-end (Option B) — Generated: 2025-08-31T09:24:25 */

USE PizzaETL;
GO
DECLARE @load_id INT = (SELECT MAX(load_id) FROM meta.load_audit);

-- Upsert Orders
MERGE ods.orders AS tgt
USING (
    SELECT order_id, order_datetime, order_date, order_time, load_id FROM stg.orders WHERE order_id IS NOT NULL
) AS src
ON tgt.order_id = src.order_id
WHEN MATCHED THEN UPDATE SET order_datetime = src.order_datetime, order_date = src.order_date, order_time = src.order_time, load_id = @load_id
WHEN NOT MATCHED THEN INSERT (order_id, order_datetime, order_date, order_time, load_id) VALUES (src.order_id, src.order_datetime, src.order_date, src.order_time, @load_id);

-- Upsert Order Details
MERGE ods.order_details AS tgt
USING (
    SELECT order_details_id, order_id, pizza_id, quantity, load_id FROM stg.order_details WHERE order_details_id IS NOT NULL
) AS src
ON tgt.order_details_id = src.order_details_id
WHEN MATCHED THEN UPDATE SET order_id = src.order_id, pizza_id = src.pizza_id, quantity = src.quantity, load_id = @load_id
WHEN NOT MATCHED THEN INSERT (order_details_id, order_id, pizza_id, quantity, load_id) VALUES (src.order_details_id, src.order_id, src.pizza_id, src.quantity, @load_id);

-- Upsert Pizzas
MERGE ods.pizzas AS tgt
USING (
    SELECT pizza_id, pizza_type_id, size, price, load_id FROM stg.pizzas WHERE pizza_id IS NOT NULL
) AS src
ON tgt.pizza_id = src.pizza_id
WHEN MATCHED THEN UPDATE SET pizza_type_id = src.pizza_type_id, size = src.size, price = src.price, load_id = @load_id
WHEN NOT MATCHED THEN INSERT (pizza_id, pizza_type_id, size, price, load_id) VALUES (src.pizza_id, src.pizza_type_id, src.size, src.price, @load_id);

-- Upsert Pizza Types
MERGE ods.pizza_types AS tgt
USING (SELECT pizza_type_id, name, category, ingredients, load_id FROM stg.pizza_types WHERE pizza_type_id IS NOT NULL) AS src
ON tgt.pizza_type_id = src.pizza_type_id
WHEN MATCHED THEN UPDATE SET name = src.name, category = src.category, ingredients = src.ingredients, load_id = @load_id
WHEN NOT MATCHED THEN INSERT (pizza_type_id, name, category, ingredients, load_id) VALUES (src.pizza_type_id, src.name, src.category, src.ingredients, @load_id);

-- Update audit status
UPDATE meta.load_audit SET status = 'ODS_LOADED', end_time = SYSUTCDATETIME() WHERE load_id = @load_id;
GO
