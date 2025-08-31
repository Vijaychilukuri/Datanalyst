/* Pizza ETL — Full end-to-end (Option B) — Generated: 2025-08-31T09:24:25 */

USE PizzaETL;
GO
DECLARE @load_id INT = (SELECT MAX(load_id) FROM meta.load_audit);

-- Clear staging for idempotency (alternatively, use temp tables or partitioning)
TRUNCATE TABLE stg.orders;
TRUNCATE TABLE stg.order_details;
TRUNCATE TABLE stg.pizzas;
TRUNCATE TABLE stg.pizza_types;

-- Orders: parse and convert
INSERT INTO stg.orders (order_id, order_datetime, order_date, order_time, src_order_id, src_date_raw, src_time_raw, load_id)
SELECT
    TRY_CAST(order_id AS INT) AS order_id,
    TRY_CONVERT(DATETIME2, CONCAT(NULLIF(date,''), ' ', NULLIF(time,''))) AS order_datetime,
    TRY_CAST(NULLIF(date,'') AS DATE) AS order_date,
    TRY_CAST(NULLIF(time,'') AS TIME) AS order_time,
    order_id, date, time, @load_id
FROM raw.orders_raw;

-- Order details: numeric conversion & defaults
INSERT INTO stg.order_details (order_details_id, order_id, pizza_id, quantity, load_id)
SELECT
    TRY_CAST(order_details_id AS INT) AS order_details_id,
    TRY_CAST(order_id AS INT) AS order_id,
    NULLIF(LTRIM(RTRIM(pizza_id)), '') AS pizza_id,
    ISNULL(TRY_CAST(quantity AS INT), 0) AS quantity,
    @load_id
FROM raw.order_details_raw;

-- Pizzas
INSERT INTO stg.pizzas (pizza_id, pizza_type_id, size, price, load_id)
SELECT
    NULLIF(LTRIM(RTRIM(pizza_id)), '') AS pizza_id,
    NULLIF(LTRIM(RTRIM(pizza_type_id)), '') AS pizza_type_id,
    UPPER(NULLIF(LTRIM(RTRIM(size)), '')) AS size,
    TRY_CAST(NULLIF(price, '') AS DECIMAL(10,2)) AS price,
    @load_id
FROM raw.pizzas_raw;

-- Pizza types
INSERT INTO stg.pizza_types (pizza_type_id, name, category, ingredients, load_id)
SELECT
    NULLIF(LTRIM(RTRIM(pizza_type_id)), '') AS pizza_type_id,
    NULLIF(LTRIM(RTRIM(name)), '') AS name,
    NULLIF(LTRIM(RTRIM(category)), '') AS category,
    NULLIF(LTRIM(RTRIM(ingredients)), '') AS ingredients,
    @load_id
FROM raw.pizza_types_raw;

-- Update audit with staged counts
UPDATE meta.load_audit
SET status = 'STAGED',
    rows_staged = (
        (SELECT COUNT(*) FROM stg.orders) +
        (SELECT COUNT(*) FROM stg.order_details) +
        (SELECT COUNT(*) FROM stg.pizzas) +
        (SELECT COUNT(*) FROM stg.pizza_types)
    )
WHERE load_id = @load_id;
GO
