/* Pizza ETL — Full end-to-end (Option B) — Generated: 2025-08-31T09:24:25 */

USE PizzaETL;
GO
-- Staging tables (cleaned & typed)
IF OBJECT_ID('stg.orders') IS NULL
CREATE TABLE stg.orders (
    order_id INT NOT NULL,
    order_datetime DATETIME2 NULL,
    order_date DATE NULL,
    order_time TIME(0) NULL,
    src_order_id NVARCHAR(100) NULL,
    src_date_raw NVARCHAR(100) NULL,
    src_time_raw NVARCHAR(100) NULL,
    load_id INT NULL
);
GO
IF OBJECT_ID('stg.order_details') IS NULL
CREATE TABLE stg.order_details (
    order_details_id INT NOT NULL,
    order_id INT NOT NULL,
    pizza_id NVARCHAR(100) NOT NULL,
    quantity INT NOT NULL,
    load_id INT NULL
);
GO
IF OBJECT_ID('stg.pizzas') IS NULL
CREATE TABLE stg.pizzas (
    pizza_id NVARCHAR(100) NOT NULL,
    pizza_type_id NVARCHAR(100) NOT NULL,
    size NVARCHAR(50) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    load_id INT NULL
);
GO
IF OBJECT_ID('stg.pizza_types') IS NULL
CREATE TABLE stg.pizza_types (
    pizza_type_id NVARCHAR(100) NOT NULL,
    name NVARCHAR(500) NOT NULL,
    category NVARCHAR(200) NOT NULL,
    ingredients NVARCHAR(MAX) NULL,
    load_id INT NULL
);
GO
