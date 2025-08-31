-- 20_dq_profiles.sql
USE PizzaDW;
GO

-- 🔴 Analyst Task: Null profiling per column (SUM(CASE)) for staging

-- Customers_Staging
SELECT
  SUM(CASE WHEN CustomerID IS NULL THEN 1 ELSE 0 END) AS Null_CustomerID,
  SUM(CASE WHEN FirstName  IS NULL THEN 1 ELSE 0 END) AS Null_FirstName,
  SUM(CASE WHEN LastName   IS NULL THEN 1 ELSE 0 END) AS Null_LastName,
  SUM(CASE WHEN Email      IS NULL THEN 1 ELSE 0 END) AS Null_Email,
  SUM(CASE WHEN Phone      IS NULL THEN 1 ELSE 0 END) AS Null_Phone,
  SUM(CASE WHEN City       IS NULL THEN 1 ELSE 0 END) AS Null_City,
  SUM(CASE WHEN Country    IS NULL THEN 1 ELSE 0 END) AS Null_Country
FROM stg.Customers_Staging;

-- Products_Staging
SELECT
  SUM(CASE WHEN ProductID   IS NULL THEN 1 ELSE 0 END) AS Null_ProductID,
  SUM(CASE WHEN ProductName IS NULL THEN 1 ELSE 0 END) AS Null_ProductName,
  SUM(CASE WHEN Category    IS NULL THEN 1 ELSE 0 END) AS Null_Category,
  SUM(CASE WHEN Price       IS NULL THEN 1 ELSE 0 END) AS Null_Price
FROM stg.Products_Staging;

-- PizzaTypes_Staging
SELECT
  SUM(CASE WHEN PizzaTypeID IS NULL THEN 1 ELSE 0 END) AS Null_PizzaTypeID,
  SUM(CASE WHEN TypeName    IS NULL THEN 1 ELSE 0 END) AS Null_TypeName,
  SUM(CASE WHEN Description IS NULL THEN 1 ELSE 0 END) AS Null_Description
FROM stg.PizzaTypes_Staging;

-- Orders_Staging
SELECT
  SUM(CASE WHEN OrderID     IS NULL THEN 1 ELSE 0 END) AS Null_OrderID,
  SUM(CASE WHEN CustomerID  IS NULL THEN 1 ELSE 0 END) AS Null_CustomerID,
  SUM(CASE WHEN OrderDate   IS NULL THEN 1 ELSE 0 END) AS Null_OrderDate,
  SUM(CASE WHEN Status      IS NULL THEN 1 ELSE 0 END) AS Null_Status,
  SUM(CASE WHEN TotalAmount IS NULL THEN 1 ELSE 0 END) AS Null_TotalAmount
FROM stg.Orders_Staging;

-- OrderDetails_Staging
SELECT
  SUM(CASE WHEN OrderDetailID IS NULL THEN 1 ELSE 0 END) AS Null_OrderDetailID,
  SUM(CASE WHEN OrderID       IS NULL THEN 1 ELSE 0 END) AS Null_OrderID,
  SUM(CASE WHEN ProductID     IS NULL THEN 1 ELSE 0 END) AS Null_ProductID,
  SUM(CASE WHEN Quantity      IS NULL THEN 1 ELSE 0 END) AS Null_Quantity,
  SUM(CASE WHEN UnitPrice     IS NULL THEN 1 ELSE 0 END) AS Null_UnitPrice
FROM stg.OrderDetails_Staging;

-- 🔴 Analyst Task: Duplicate checks
-- Example: Customers
SELECT FirstName, LastName, Email, COUNT(*) AS DupCount
FROM stg.Customers_Staging
GROUP BY FirstName, LastName, Email
HAVING COUNT(*) > 1;

-- 🔴 Analyst Task: Impossible values
SELECT ProductID, Price FROM stg.Products_Staging WHERE Price < 0;
SELECT OrderDetailID, Quantity, UnitPrice FROM stg.OrderDetails_Staging WHERE Quantity <= 0 OR UnitPrice < 0;

-- 🔴 Analyst Task: FK validations
SELECT o.OrderID FROM stg.Orders_Staging o LEFT JOIN stg.Customers_Staging c ON o.CustomerID=c.CustomerID WHERE c.CustomerID IS NULL;
SELECT od.OrderDetailID FROM stg.OrderDetails_Staging od LEFT JOIN stg.Orders_Staging o ON od.OrderID=o.OrderID WHERE o.OrderID IS NULL;
SELECT od.OrderDetailID FROM stg.OrderDetails_Staging od LEFT JOIN stg.Products_Staging p ON od.ProductID=p.ProductID WHERE p.ProductID IS NULL;
GO
