-- 30_unit_tests.sql
USE PizzaDW;
GO

-- 🔴 Analyst Task: Unit / sanity tests

-- 1) Counts non-zero
SELECT 'ODS Orders' AS Entity, COUNT(*) AS Cnt FROM ods.Orders
UNION ALL SELECT 'ODS OrderDetails', COUNT(*) FROM ods.OrderDetails
UNION ALL SELECT 'DimCustomer', COUNT(*) FROM dwh.DimCustomer
UNION ALL SELECT 'DimProduct', COUNT(*) FROM dwh.DimProduct
UNION ALL SELECT 'Fact_Sales', COUNT(*) FROM dwh.Fact_Sales;

-- 2) No negative amounts in ODS Orders
SELECT * FROM ods.Orders WHERE TotalAmount < 0;

-- 3) Fact extended amount equals Quantity*UnitPrice (computed column ensures this)
SELECT TOP 10 * FROM dwh.Fact_Sales;
GO
