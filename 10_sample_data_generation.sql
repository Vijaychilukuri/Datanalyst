-- 10_sample_data_generation.sql
-- NOTE: This script fabricates ~10k+ rows with intentional data issues for practice.
-- In production you would ingest from files (SSIS/ADF).

USE PizzaDW;
GO

-- Seed raw tables with synthetic data
-- Tally for 10000
WITH N AS (
  SELECT TOP (10000) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
  FROM sys.objects a CROSS JOIN sys.objects b
)
INSERT INTO raw.Customers_Raw (CustomerID, FirstName, LastName, Email, Phone, City, Country, CreatedDate)
SELECT 
  n, 
  CONCAT('First', (n%300)), 
  CONCAT('Last', (n%500)),
  CASE WHEN n%37=0 THEN NULL ELSE CONCAT('user', n%9000, '@mail.com') END,
  CASE WHEN n%41=0 THEN NULL ELSE CONCAT('+91-9', RIGHT('000000000'+CAST(n AS VARCHAR(9)),9)) END,
  CASE WHEN n%29=0 THEN NULL ELSE CONCAT('City', n%100) END,
  CASE WHEN n%31=0 THEN NULL ELSE CASE WHEN n%2=0 THEN 'India' ELSE 'USA' END END,
  DATEADD(DAY, - (n%1000), SYSDATETIME())
FROM N;

WITH N AS (
  SELECT TOP (2000) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
  FROM sys.objects
)
INSERT INTO raw.Products_Raw (ProductID, ProductName, Category, Price)
SELECT 
  n,
  CONCAT('Product', n%400),
  CASE WHEN n%3=0 THEN 'Pizza' WHEN n%3=1 THEN 'Drink' ELSE 'Side' END,
  CASE WHEN n%97=0 THEN -ABS(n%50) ELSE CAST((n%50)+5 AS DECIMAL(10,2)) END
FROM N;

WITH N AS (
  SELECT TOP (20) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
  FROM sys.objects
)
INSERT INTO raw.PizzaTypes_Raw (PizzaTypeID, TypeName, Description)
SELECT 
  n,
  CONCAT('Type', n%10),
  CASE WHEN n%5=0 THEN NULL ELSE CONCAT('Description for type ', n%10) END
FROM N;

WITH N AS (
  SELECT TOP (12000) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
  FROM sys.objects a CROSS JOIN sys.objects b
)
INSERT INTO raw.Orders_Raw (OrderID, CustomerID, OrderDate, Status, TotalAmount)
SELECT 
  n,
  CASE WHEN n%53=0 THEN NULL ELSE (n%10000)+1 END,
  DATEADD(DAY, - (n%365), CAST(GETDATE() AS DATE)),
  CASE WHEN n%17=0 THEN NULL ELSE CASE WHEN n%2=0 THEN 'Completed' ELSE 'Pending' END END,
  CASE WHEN n%89=0 THEN -1* (n%500) ELSE (n%500)+50 END
FROM N;

WITH N AS (
  SELECT TOP (25000) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
  FROM sys.objects a CROSS JOIN sys.objects b
)
INSERT INTO raw.OrderDetails_Raw (OrderDetailID, OrderID, ProductID, Quantity, UnitPrice)
SELECT 
  n,
  CASE WHEN n%97=0 THEN NULL ELSE (n%12000)+1 END,
  CASE WHEN n%101=0 THEN NULL ELSE (n%2000)+1 END,
  CASE WHEN n%113=0 THEN 0 ELSE ABS(n%8)+1 END,
  CASE WHEN n%109=0 THEN -1* (n%30) ELSE CAST((n%30)+3 AS DECIMAL(10,2)) END
FROM N;

-- Intentional duplicates
INSERT INTO raw.Customers_Raw SELECT TOP 50 * FROM raw.Customers_Raw;
INSERT INTO raw.Products_Raw  SELECT TOP 100 * FROM raw.Products_Raw;
INSERT INTO raw.Orders_Raw    SELECT TOP 200 * FROM raw.Orders_Raw;
INSERT INTO raw.OrderDetails_Raw SELECT TOP 500 * FROM raw.OrderDetails_Raw;
GO
