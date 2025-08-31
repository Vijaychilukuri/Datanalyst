/* Pizza ETL — Full end-to-end (Option B) — Generated: 2025-08-31T09:24:25 */

USE PizzaETL;
GO
-- Basic unit tests / validations
SELECT COUNT(*) AS raw_orders FROM raw.orders_raw;
SELECT COUNT(*) AS stg_orders FROM stg.orders;
SELECT COUNT(*) AS ods_orders FROM ods.orders;
SELECT COUNT(*) AS quarantined_orders FROM quarantine.orders_bad;
GO
-- Referential checks (order_details referencing orders)
SELECT od.order_id FROM ods.order_details od LEFT JOIN ods.orders o ON od.order_id = o.order_id WHERE o.order_id IS NULL;
GO
