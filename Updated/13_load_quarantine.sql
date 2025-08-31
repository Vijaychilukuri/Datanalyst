/* Pizza ETL — Full end-to-end (Option B) — Generated: 2025-08-31T09:24:25 */

USE PizzaETL;
GO
DECLARE @load_id INT = (SELECT MAX(load_id) FROM meta.load_audit);

-- Orders bad: missing order_id or invalid date/time
INSERT INTO quarantine.orders_bad (src_order_id, src_date, src_time, reason, load_id)
SELECT src_order_id, src_date_raw, src_time_raw,
       CASE
         WHEN TRY_CAST(src_order_id AS INT) IS NULL THEN 'Invalid order_id'
         WHEN TRY_CAST(src_date_raw AS DATE) IS NULL AND TRY_CONVERT(DATETIME2, CONCAT(src_date_raw,' ',src_time_raw)) IS NULL THEN 'Invalid date/time'
         ELSE 'Other'
       END, @load_id
FROM stg.orders
WHERE TRY_CAST(src_order_id AS INT) IS NULL
   OR (TRY_CAST(src_date_raw AS DATE) IS NULL AND TRY_CONVERT(DATETIME2, CONCAT(src_date_raw,' ',src_time_raw)) IS NULL);

-- Order details bad: missing keys or missing pizza
INSERT INTO quarantine.order_details_bad (src_order_details_id, src_order_id, src_pizza_id, src_quantity, reason, load_id)
SELECT CAST(order_details_id AS NVARCHAR(100)), CAST(order_id AS NVARCHAR(100)), pizza_id, CAST(quantity AS NVARCHAR(100)),
       CASE
         WHEN order_details_id IS NULL THEN 'Missing order_details_id'
         WHEN order_id IS NULL THEN 'Missing order_id'
         WHEN pizza_id IS NULL OR LTRIM(RTRIM(pizza_id)) = '' THEN 'Missing pizza_id'
         WHEN quantity IS NULL THEN 'Missing quantity'
         ELSE 'Other'
       END, @load_id
FROM stg.order_details
WHERE order_details_id IS NULL OR order_id IS NULL OR pizza_id IS NULL OR LTRIM(RTRIM(pizza_id)) = '';

-- Pizzas bad
INSERT INTO quarantine.pizzas_bad (src_pizza_id, src_pizza_type_id, src_size, src_price, reason, load_id)
SELECT pizza_id, pizza_type_id, size, CAST(price AS NVARCHAR(100)),
       CASE WHEN price IS NULL THEN 'Missing/Invalid price' WHEN pizza_id IS NULL THEN 'Missing pizza_id' ELSE 'Other' END, @load_id
FROM stg.pizzas
WHERE price IS NULL OR pizza_id IS NULL;

-- Pizza types bad
INSERT INTO quarantine.pizza_types_bad (src_pizza_type_id, src_name, src_category, src_ingredients, reason, load_id)
SELECT pizza_type_id, name, category, ingredients,
       CASE WHEN pizza_type_id IS NULL THEN 'Missing pizza_type_id' WHEN name IS NULL THEN 'Missing name' ELSE 'Other' END, @load_id
FROM stg.pizza_types
WHERE pizza_type_id IS NULL OR name IS NULL;
GO
