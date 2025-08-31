/* Pizza ETL — Full end-to-end (Option B) — Generated: 2025-08-31T09:24:25 */

USE PizzaETL;
GO
-- Raw landing tables (columns chosen to match CSVs; keep everything nullable)
IF OBJECT_ID('raw.orders_raw') IS NULL
CREATE TABLE raw.orders_raw (
    order_id NVARCHAR(100) NULL,
    date NVARCHAR(100) NULL,
    time NVARCHAR(100) NULL,
    _ingested_at DATETIME2 DEFAULT SYSUTCDATETIME()
);
GO
IF OBJECT_ID('raw.order_details_raw') IS NULL
CREATE TABLE raw.order_details_raw (
    order_details_id NVARCHAR(100) NULL,
    order_id NVARCHAR(100) NULL,
    pizza_id NVARCHAR(100) NULL,
    quantity NVARCHAR(100) NULL,
    _ingested_at DATETIME2 DEFAULT SYSUTCDATETIME()
);
GO
IF OBJECT_ID('raw.pizzas_raw') IS NULL
CREATE TABLE raw.pizzas_raw (
    pizza_id NVARCHAR(100) NULL,
    pizza_type_id NVARCHAR(100) NULL,
    size NVARCHAR(50) NULL,
    price NVARCHAR(100) NULL,
    _ingested_at DATETIME2 DEFAULT SYSUTCDATETIME()
);
GO
IF OBJECT_ID('raw.pizza_types_raw') IS NULL
CREATE TABLE raw.pizza_types_raw (
    pizza_type_id NVARCHAR(100) NULL,
    name NVARCHAR(500) NULL,
    category NVARCHAR(200) NULL,
    ingredients NVARCHAR(MAX) NULL,
    _ingested_at DATETIME2 DEFAULT SYSUTCDATETIME()
);
GO
