-- 26_views_and_quality_scorecards.sql
USE PizzaDW;
GO

-- Data Quality Scorecard View (Null rates per staging table)
IF OBJECT_ID('dbo.v_DQ_NullRates') IS NOT NULL DROP VIEW dbo.v_DQ_NullRates;
GO
CREATE VIEW dbo.v_DQ_NullRates AS
SELECT 'Customers_Staging' AS TableName,
       SUM(CASE WHEN Email IS NULL THEN 1 ELSE 0 END)*1.0/COUNT(*) AS NullRate_Email,
       SUM(CASE WHEN City  IS NULL THEN 1 ELSE 0 END)*1.0/COUNT(*) AS NullRate_City
FROM stg.Customers_Staging
UNION ALL
SELECT 'Products_Staging',
       SUM(CASE WHEN Price IS NULL THEN 1 ELSE 0 END)*1.0/COUNT(*),
       SUM(CASE WHEN Category IS NULL THEN 1 ELSE 0 END)*1.0/COUNT(*)
FROM stg.Products_Staging
UNION ALL
SELECT 'Orders_Staging',
       SUM(CASE WHEN Status IS NULL THEN 1 ELSE 0 END)*1.0/COUNT(*),
       SUM(CASE WHEN CustomerID IS NULL THEN 1 ELSE 0 END)*1.0/COUNT(*)
FROM stg.Orders_Staging;
GO

-- Log monitoring
IF OBJECT_ID('dbo.v_LastRuns') IS NOT NULL DROP VIEW dbo.v_LastRuns;
GO
CREATE VIEW dbo.v_LastRuns AS
SELECT TOP 50 LogID, ProcessName, StartTime, EndTime, Status, RowsRead, RowsInserted, RowsUpdated, RowsRejected
FROM log.ETL_Log
ORDER BY LogID DESC;
GO
