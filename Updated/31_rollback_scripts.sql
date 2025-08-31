/* Pizza ETL — Full end-to-end (Option B) — Generated: 2025-08-31T09:24:25 */

USE PizzaETL;
GO
-- Rollback / truncate for a failed load (by load_id)
DECLARE @load_id INT = (SELECT MAX(load_id) FROM meta.load_audit);
PRINT 'Rolling back staged and ods rows for load_id=' + CAST(@load_id AS NVARCHAR(20));
DELETE FROM dwh.fact_sales WHERE order_details_id IN (SELECT order_details_id FROM ods.order_details WHERE load_id = @load_id);
DELETE FROM dwh.dim_pizza WHERE pizza_id IN (SELECT pizza_id FROM ods.pizzas WHERE load_id = @load_id);
DELETE FROM ods.order_details WHERE load_id = @load_id;
DELETE FROM ods.orders WHERE load_id = @load_id;
DELETE FROM ods.pizzas WHERE load_id = @load_id;
DELETE FROM ods.pizza_types WHERE load_id = @load_id;
DELETE FROM stg.order_details WHERE load_id = @load_id;
DELETE FROM stg.orders WHERE load_id = @load_id;
DELETE FROM stg.pizzas WHERE load_id = @load_id;
DELETE FROM stg.pizza_types WHERE load_id = @load_id;
DELETE FROM quarantine.orders_bad WHERE load_id = @load_id;
DELETE FROM quarantine.order_details_bad WHERE load_id = @load_id;
DELETE FROM quarantine.pizzas_bad WHERE load_id = @load_id;
DELETE FROM quarantine.pizza_types_bad WHERE load_id = @load_id;
UPDATE meta.load_audit SET status='ROLLED_BACK' WHERE load_id = @load_id;
GO
