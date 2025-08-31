-- 24_build_dimensions.sql
USE PizzaDW;
GO

-- DimDate load (from ODS Orders dates)
TRUNCATE TABLE dwh.DimDate;
WITH d AS (
  SELECT DISTINCT OrderDate AS DateValue
  FROM ods.Orders
  WHERE OrderDate IS NOT NULL
)
INSERT INTO dwh.DimDate (DateKey, DateValue, Year, Month, Day, MonthName)
SELECT CONVERT(INT, FORMAT(DateValue,'yyyyMMdd')),
       DateValue,
       YEAR(DateValue), MONTH(DateValue), DAY(DateValue),
       DATENAME(MONTH, DateValue)
FROM d;

-- Ensure Unknown members
IF NOT EXISTS (SELECT 1 FROM dwh.DimCustomer WHERE CustomerID = -1)
INSERT INTO dwh.DimCustomer (CustomerID, FirstName, LastName, Email, City, Country, IsUnknown)
VALUES (-1, 'Unknown', 'Customer', 'unknown@example.com', 'NA', 'NA', 1);

IF NOT EXISTS (SELECT 1 FROM dwh.DimProduct WHERE ProductID = -1)
INSERT INTO dwh.DimProduct (ProductID, ProductName, Category, Price, IsUnknown)
VALUES (-1, 'Unknown Product', 'Unknown', 0, 1);

-- Customer SCD1 upsert
MERGE dwh.DimCustomer AS tgt
USING (SELECT * FROM ods.Customers) AS src
ON (tgt.CustomerID = src.CustomerID)
WHEN MATCHED AND tgt.UniqueHash <> CHECKSUM(src.CustomerID, ISNULL(src.Email,'')) THEN
  UPDATE SET FirstName=src.FirstName, LastName=src.LastName, Email=src.Email, City=src.City, Country=src.Country
WHEN NOT MATCHED THEN
  INSERT (CustomerID, FirstName, LastName, Email, City, Country)
  VALUES (src.CustomerID, src.FirstName, src.LastName, src.Email, src.City, src.Country);

-- Product SCD1 upsert
MERGE dwh.DimProduct AS tgt
USING (SELECT * FROM ods.Products) AS src
ON (tgt.ProductID = src.ProductID)
WHEN MATCHED AND tgt.UniqueHash <> CHECKSUM(src.ProductID, ISNULL(src.ProductName,'')) THEN
  UPDATE SET ProductName=src.ProductName, Category=src.Category, Price=src.Price
WHEN NOT MATCHED THEN
  INSERT (ProductID, ProductName, Category, Price)
  VALUES (src.ProductID, src.ProductName, src.Category, src.Price);

-- PizzaType dimension from ODS
MERGE dwh.DimPizzaType AS tgt
USING (SELECT * FROM ods.PizzaTypes) AS src
ON (tgt.PizzaTypeID = src.PizzaTypeID)
WHEN MATCHED AND tgt.UniqueHash <> CHECKSUM(src.PizzaTypeID, ISNULL(src.TypeName,'')) THEN
  UPDATE SET TypeName=src.TypeName, Description=src.Description
WHEN NOT MATCHED THEN
  INSERT (PizzaTypeID, TypeName, Description)
  VALUES (src.PizzaTypeID, src.TypeName, src.Description);

GO
