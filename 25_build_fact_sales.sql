-- 25_build_fact_sales.sql
USE PizzaDW;
GO

TRUNCATE TABLE dwh.Fact_Sales;

INSERT INTO dwh.Fact_Sales (DateKey, CustomerKey, ProductKey, OrderID, OrderDetailID, Quantity, UnitPrice)
SELECT 
  CONVERT(INT, FORMAT(o.OrderDate,'yyyyMMdd')) AS DateKey,
  dc.CustomerKey,
  dp.ProductKey,
  od.OrderID,
  od.OrderDetailID,
  ISNULL(od.Quantity,0),
  ISNULL(od.UnitPrice,0)
FROM ods.OrderDetails od
JOIN ods.Orders o ON od.OrderID = o.OrderID
LEFT JOIN dwh.DimCustomer dc ON dc.CustomerID = o.CustomerID
LEFT JOIN dwh.DimProduct dp  ON dp.ProductID  = od.ProductID;

-- 🔴 Analyst Task: Post-load QA
-- 1) Any null keys?
SELECT * FROM dwh.Fact_Sales WHERE CustomerKey IS NULL OR ProductKey IS NULL;

-- 2) Reconciliation: totals
SELECT SUM(ExtendedAmount) AS FactTotal FROM dwh.Fact_Sales;

GO
