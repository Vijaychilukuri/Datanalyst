/* Pizza ETL — Full end-to-end (Option B) — Generated: 2025-08-31T09:24:25 */

USE PizzaETL;
GO
-- ODS (clean, business-level tables)
IF OBJECT_ID('ods.orders') IS NULL
CREATE TABLE ods.orders (
    order_id INT PRIMARY KEY,
    order_datetime DATETIME2 NOT NULL,
    order_date DATE NOT NULL,
    order_time TIME(0) NOT NULL,
    load_id INT NULL
);
GO
IF OBJECT_ID('ods.order_details') IS NULL
CREATE TABLE ods.order_details (
    order_details_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    pizza_id NVARCHAR(100) NOT NULL,
    quantity INT NOT NULL,
    load_id INT NULL
);
GO
IF OBJECT_ID('ods.pizzas') IS NULL
CREATE TABLE ods.pizzas (
    pizza_id NVARCHAR(100) PRIMARY KEY,
    pizza_type_id NVARCHAR(100) NOT NULL,
    size NVARCHAR(50) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    load_id INT NULL
);
GO
IF OBJECT_ID('ods.pizza_types') IS NULL
CREATE TABLE ods.pizza_types (
    pizza_type_id NVARCHAR(100) PRIMARY KEY,
    name NVARCHAR(500) NOT NULL,
    category NVARCHAR(200) NOT NULL,
    ingredients NVARCHAR(MAX) NULL,
    load_id INT NULL
);
GO
