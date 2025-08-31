-- 31_rollback_scripts.sql
USE PizzaDW;
GO

TRUNCATE TABLE dwh.Fact_Sales;
TRUNCATE TABLE dwh.DimProduct;
TRUNCATE TABLE dwh.DimCustomer;
TRUNCATE TABLE dwh.DimPizzaType;
TRUNCATE TABLE dwh.DimDate;

TRUNCATE TABLE ods.OrderDetails;
TRUNCATE TABLE ods.Orders;
TRUNCATE TABLE ods.Products;
TRUNCATE TABLE ods.Customers;
TRUNCATE TABLE ods.PizzaTypes;

TRUNCATE TABLE stg.OrderDetails_Staging;
TRUNCATE TABLE stg.Orders_Staging;
TRUNCATE TABLE stg.Products_Staging;
TRUNCATE TABLE stg.Customers_Staging;
TRUNCATE TABLE stg.PizzaTypes_Staging;

TRUNCATE TABLE qrt.Customers_Issues;
TRUNCATE TABLE qrt.Orders_Issues;
TRUNCATE TABLE qrt.OrderDetails_Issues;
TRUNCATE TABLE qrt.Products_Issues;
TRUNCATE TABLE qrt.PizzaTypes_Issues;

TRUNCATE TABLE raw.OrderDetails_Raw;
TRUNCATE TABLE raw.Orders_Raw;
TRUNCATE TABLE raw.Products_Raw;
TRUNCATE TABLE raw.Customers_Raw;
TRUNCATE TABLE raw.PizzaTypes_Raw;

DELETE FROM log.ETL_RunStep;
DELETE FROM log.ETL_Log;
GO
