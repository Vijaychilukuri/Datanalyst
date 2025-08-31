-- 27_monitoring_queries.sql
USE PizzaDW;
GO

-- 🔴 Analyst Task: Daily checks

-- 1) Check last 10 runs
SELECT * FROM dbo.v_LastRuns;

-- 2) Check DQ scorecard
SELECT * FROM dbo.v_DQ_NullRates;

-- 3) Verify no orphans in ODS
SELECT od.OrderDetailID
FROM ods.OrderDetails od
LEFT JOIN ods.Orders o ON od.OrderID=o.OrderID
WHERE o.OrderID IS NULL;

-- 4) Fact vs ODS reconciliation
SELECT (SELECT COUNT(*) FROM dwh.Fact_Sales) AS FactRows,
       (SELECT COUNT(*) FROM ods.OrderDetails) AS ODSDetailsRows;

GO
