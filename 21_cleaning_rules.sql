-- 21_cleaning_rules.sql
USE PizzaDW;
GO

DECLARE @UnknownCustomerID INT = (SELECT CAST(ConfigValue AS INT) FROM cfg.ETL_Config WHERE ConfigName='UnknownCustomerID');
DECLARE @UnknownProductID  INT = (SELECT CAST(ConfigValue AS INT) FROM cfg.ETL_Config WHERE ConfigName='UnknownProductID');
DECLARE @EnableQuarantine  BIT = (SELECT CASE WHEN ConfigValue='1' THEN 1 ELSE 0 END FROM cfg.ETL_Config WHERE ConfigName='EnableQuarantine');
DECLARE @DefaultOrderStatus NVARCHAR(50) = (SELECT ConfigValue FROM cfg.ETL_Config WHERE ConfigName='DefaultOrderStatus');

-- Load raw -> staging (simple copy with light fixes)
TRUNCATE TABLE stg.Customers_Staging;
INSERT INTO stg.Customers_Staging (CustomerID, FirstName, LastName, Email, Phone, City, Country, CreatedDate)
SELECT ISNULL(CustomerID, ABS(CHECKSUM(NEWID()))%1000000 + 1), FirstName, LastName, Email, Phone, City, Country, CreatedDate
FROM raw.Customers_Raw;

TRUNCATE TABLE stg.Products_Staging;
INSERT INTO stg.Products_Staging (ProductID, ProductName, Category, Price)
SELECT ISNULL(ProductID, ABS(CHECKSUM(NEWID()))%1000000 + 1), ProductName, Category, Price
FROM raw.Products_Raw;

TRUNCATE TABLE stg.PizzaTypes_Staging;
INSERT INTO stg.PizzaTypes_Staging (PizzaTypeID, TypeName, Description)
SELECT ISNULL(PizzaTypeID, ABS(CHECKSUM(NEWID()))%1000000 + 1), TypeName, Description
FROM raw.PizzaTypes_Raw;

TRUNCATE TABLE stg.Orders_Staging;
INSERT INTO stg.Orders_Staging (OrderID, CustomerID, OrderDate, Status, TotalAmount)
SELECT ISNULL(OrderID, ABS(CHECKSUM(NEWID()))%1000000 + 1), CustomerID, OrderDate, ISNULL(Status, @DefaultOrderStatus), TotalAmount
FROM raw.Orders_Raw;

TRUNCATE TABLE stg.OrderDetails_Staging;
INSERT INTO stg.OrderDetails_Staging (OrderDetailID, OrderID, ProductID, Quantity, UnitPrice)
SELECT ISNULL(OrderDetailID, ABS(CHECKSUM(NEWID()))%1000000 + 1), OrderID, ProductID, Quantity, UnitPrice
FROM raw.OrderDetails_Raw;

-- Null handling & quarantine patterns --------------------------------------------------

-- Customers: quarantine rows with critically missing identity (should be rare after ISNULL)
IF @EnableQuarantine = 1
BEGIN
    INSERT INTO qrt.Customers_Issues (IssueType, CustomerID, Payload)
    SELECT 'NULLS', CustomerID, CONCAT('Missing criticals: ', 
           CASE WHEN Email IS NULL THEN 'Email;' ELSE '' END)
    FROM stg.Customers_Staging
    WHERE Email IS NULL; -- Example: business critical

    -- Fill safe placeholders
    UPDATE stg.Customers_Staging SET Email = CONCAT('unknown_', CustomerID, '@example.com') WHERE Email IS NULL;
END

-- Products: negative price -> set NULL, quarantine
IF @EnableQuarantine = 1
BEGIN
    INSERT INTO qrt.Products_Issues (IssueType, ProductID, Payload)
    SELECT 'IMPOSSIBLE', ProductID, CONCAT('Price=', Price) FROM stg.Products_Staging WHERE Price < 0;

    UPDATE stg.Products_Staging SET Price = NULL WHERE Price < 0;
END

-- Orders: NULL CustomerID -> map to Unknown & flag
IF NOT EXISTS (SELECT 1 FROM stg.Customers_Staging WHERE CustomerID = @UnknownCustomerID)
BEGIN
    INSERT INTO stg.Customers_Staging (CustomerID, FirstName, LastName, Email, Phone, City, Country, CreatedDate, Is_Unlinked, DataQualityIssue)
    VALUES (@UnknownCustomerID, 'Unknown', 'Customer', 'unknown@example.com', 'UNKNOWN', 'NA', 'NA', SYSDATETIME(), 1, 'Surrogate Unknown');
END

UPDATE stg.Orders_Staging
SET CustomerID = @UnknownCustomerID, Is_Unlinked = 1, DataQualityIssue = 'Missing CustomerID mapped to Unknown'
WHERE CustomerID IS NULL;

-- OrderDetails: NULL ProductID -> map to Unknown product & flag
IF NOT EXISTS (SELECT 1 FROM stg.Products_Staging WHERE ProductID = @UnknownProductID)
BEGIN
    INSERT INTO stg.Products_Staging (ProductID, ProductName, Category, Price, Is_Unlinked, DataQualityIssue)
    VALUES (@UnknownProductID, 'Unknown Product', 'Unknown', 0, 1, 'Surrogate Unknown');
END

UPDATE stg.OrderDetails_Staging
SET ProductID = @UnknownProductID, Is_Unlinked = 1, DataQualityIssue = 'Missing ProductID mapped to Unknown'
WHERE ProductID IS NULL;

-- OrderDetails: NULL OrderID -> quarantine and flag; exclude from ODS
IF @EnableQuarantine = 1
BEGIN
    INSERT INTO qrt.OrderDetails_Issues (IssueType, OrderDetailID, OrderID, ProductID, Payload)
    SELECT 'FK', OrderDetailID, OrderID, ProductID, 'Missing OrderID' 
    FROM stg.OrderDetails_Staging WHERE OrderID IS NULL;

    UPDATE stg.OrderDetails_Staging
    SET Is_Unlinked = 1, DataQualityIssue = 'Missing OrderID - excluded from ODS'
    WHERE OrderID IS NULL;
END

-- Duplicate handling with quarantine ---------------------------------------------------

-- Customers duplicates by (FirstName, LastName, Email) keep latest CreatedDate
WITH d AS (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY FirstName, LastName, Email ORDER BY CreatedDate DESC) rn
  FROM stg.Customers_Staging
)
INSERT INTO qrt.Customers_Issues (IssueType, CustomerID, Payload)
SELECT 'DUPLICATE', CustomerID, 'Customers duplicate by Name+Email'
FROM d WHERE rn > 1;

DELETE FROM d WHERE rn > 1;

-- Orders duplicates by OrderID keep latest OrderDate
WITH d AS (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY OrderID ORDER BY OrderDate DESC) rn
  FROM stg.Orders_Staging
)
INSERT INTO qrt.Orders_Issues (IssueType, OrderID, CustomerID, Payload)
SELECT 'DUPLICATE', OrderID, CustomerID, 'Orders duplicate by OrderID'
FROM d WHERE rn > 1;
DELETE FROM d WHERE rn > 1;

-- OrderDetails duplicates by (OrderID, ProductID) keep highest Quantity*UnitPrice
WITH d AS (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY OrderID, ProductID ORDER BY (ISNULL(Quantity,0)*ISNULL(UnitPrice,0)) DESC) rn
  FROM stg.OrderDetails_Staging
)
INSERT INTO qrt.OrderDetails_Issues (IssueType, OrderDetailID, OrderID, ProductID, Payload)
SELECT 'DUPLICATE', OrderDetailID, OrderID, ProductID, 'OrderDetails duplicate by OrderID+ProductID'
FROM d WHERE rn > 1;
DELETE FROM d WHERE rn > 1;

GO
