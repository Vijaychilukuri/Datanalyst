/* Pizza ETL — Full end-to-end (Option B) — Generated: 2025-08-31T09:24:25 */

USE PizzaETL;
GO
-- Quarantine tables for bad rows and reasons
IF OBJECT_ID('quarantine.orders_bad') IS NULL
CREATE TABLE quarantine.orders_bad (
    src_order_id NVARCHAR(100),
    src_date NVARCHAR(100),
    src_time NVARCHAR(100),
    reason NVARCHAR(500),
    load_id INT,
    _quarantined_at DATETIME2 DEFAULT SYSUTCDATETIME()
);
GO
IF OBJECT_ID('quarantine.order_details_bad') IS NULL
CREATE TABLE quarantine.order_details_bad (
    src_order_details_id NVARCHAR(100),
    src_order_id NVARCHAR(100),
    src_pizza_id NVARCHAR(100),
    src_quantity NVARCHAR(100),
    reason NVARCHAR(500),
    load_id INT,
    _quarantined_at DATETIME2 DEFAULT SYSUTCDATETIME()
);
GO
IF OBJECT_ID('quarantine.pizzas_bad') IS NULL
CREATE TABLE quarantine.pizzas_bad (
    src_pizza_id NVARCHAR(100),
    src_pizza_type_id NVARCHAR(100),
    src_size NVARCHAR(50),
    src_price NVARCHAR(100),
    reason NVARCHAR(500),
    load_id INT,
    _quarantined_at DATETIME2 DEFAULT SYSUTCDATETIME()
);
GO
IF OBJECT_ID('quarantine.pizza_types_bad') IS NULL
CREATE TABLE quarantine.pizza_types_bad (
    src_pizza_type_id NVARCHAR(100),
    src_name NVARCHAR(500),
    src_category NVARCHAR(200),
    src_ingredients NVARCHAR(MAX),
    reason NVARCHAR(500),
    load_id INT,
    _quarantined_at DATETIME2 DEFAULT SYSUTCDATETIME()
);
GO
