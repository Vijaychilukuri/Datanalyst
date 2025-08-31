/* Pizza ETL — Full end-to-end (Option B) — Generated: 2025-08-31T09:24:25 */

USE PizzaETL;
GO
-- Recent loads
SELECT TOP 50 * FROM meta.load_audit ORDER BY load_id DESC;
SELECT TOP 50 * FROM meta.step_log ORDER BY step_log_id DESC;
-- Row counts across layers
SELECT 'raw.orders' AS object, COUNT(*) AS rows FROM raw.orders_raw
UNION ALL SELECT 'stg.orders', COUNT(*) FROM stg.orders
UNION ALL SELECT 'ods.orders', COUNT(*) FROM ods.orders
UNION ALL SELECT 'dwh.fact_sales', COUNT(*) FROM dwh.fact_sales;
GO
