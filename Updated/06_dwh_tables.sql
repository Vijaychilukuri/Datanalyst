/* Pizza ETL — Full end-to-end (Option B) — Generated: 2025-08-31T09:24:25 */

USE PizzaETL;
GO
-- DWH: dimensions and fact table
IF OBJECT_ID('dwh.dim_date') IS NULL
CREATE TABLE dwh.dim_date (
    date_key INT PRIMARY KEY, -- yyyymmdd
    full_date DATE NOT NULL,
    year INT, quarter INT, month INT, day INT,
    day_name NVARCHAR(50), month_name NVARCHAR(50),
    is_weekend BIT
);
GO
IF OBJECT_ID('dwh.dim_pizza') IS NULL
CREATE TABLE dwh.dim_pizza (
    pizza_key INT IDENTITY(1,1) PRIMARY KEY,
    pizza_id NVARCHAR(100) NOT NULL UNIQUE,
    pizza_type_id NVARCHAR(100),
    size NVARCHAR(50),
    price DECIMAL(10,2),
    pizza_name NVARCHAR(500),
    category NVARCHAR(200)
);
GO
IF OBJECT_ID('dwh.fact_sales') IS NULL
CREATE TABLE dwh.fact_sales (
    sales_key BIGINT IDENTITY(1,1) PRIMARY KEY,
    order_details_id INT,
    order_id INT,
    date_key INT,
    pizza_key INT,
    quantity INT,
    unit_price DECIMAL(10,2),
    line_amount DECIMAL(12,2)
);
GO
