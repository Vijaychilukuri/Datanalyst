-- 22_fk_validation_and_mapping.sql
USE PizzaDW;
GO

DECLARE @UnknownCustomerID INT = (SELECT CAST(ConfigValue AS INT) FROM cfg.ETL_Config WHERE ConfigName='UnknownCustomerID');
DECLARE @UnknownProductID  INT = (SELECT CAST(ConfigValue AS INT) FROM cfg.ETL_Config WHERE ConfigName='UnknownProductID');
DECLARE @EnableQuarantine  BIT = (SELECT CASE WHEN ConfigValue='1' THEN 1 ELSE 0 END FROM cfg.ETL_Config WHERE ConfigName='EnableQuarantine');

-- 🔴 Analyst Task: FK checks within staging

-- Orders -> Customers
IF @EnableQuarantine = 1
BEGIN
    INSERT INTO qrt.Orders_Issues (IssueType, OrderID, CustomerID, Payload)
    SELECT 'FK', o.OrderID, o.CustomerID, 'Customer not found'
    FROM stg.Orders_Staging o
    LEFT JOIN stg.Customers_Staging c ON o.CustomerID = c.CustomerID
    WHERE c.CustomerID IS NULL;
END

-- Map missing to Unknown
UPDATE o
SET o.CustomerID = @UnknownCustomerID, o.Is_Unlinked = 1, o.DataQualityIssue = 'FK->Customer mapped to Unknown'
FROM stg.Orders_Staging o
LEFT JOIN stg.Customers_Staging c ON o.CustomerID = c.CustomerID
WHERE c.CustomerID IS NULL;

-- OrderDetails -> Orders
IF @EnableQuarantine = 1
BEGIN
    INSERT INTO qrt.OrderDetails_Issues (IssueType, OrderDetailID, OrderID, ProductID, Payload)
    SELECT 'FK', od.OrderDetailID, od.OrderID, od.ProductID, 'Order not found'
    FROM stg.OrderDetails_Staging od
    LEFT JOIN stg.Orders_Staging o ON od.OrderID = o.OrderID
    WHERE o.OrderID IS NULL;
END

-- Exclude by flag (do not map to Unknown Order)
UPDATE od
SET od.Is_Unlinked = 1, od.DataQualityIssue = 'FK->Order missing - excluded from ODS'
FROM stg.OrderDetails_Staging od
LEFT JOIN stg.Orders_Staging o ON od.OrderID = o.OrderID
WHERE o.OrderID IS NULL;

-- OrderDetails -> Products
IF @EnableQuarantine = 1
BEGIN
    INSERT INTO qrt.OrderDetails_Issues (IssueType, OrderDetailID, OrderID, ProductID, Payload)
    SELECT 'FK', od.OrderDetailID, od.OrderID, od.ProductID, 'Product not found'
    FROM stg.OrderDetails_Staging od
    LEFT JOIN stg.Products_Staging p ON od.ProductID = p.ProductID
    WHERE p.ProductID IS NULL;
END

-- Map missing to Unknown product
UPDATE od
SET od.ProductID = @UnknownProductID, od.Is_Unlinked = 1, od.DataQualityIssue = 'FK->Product mapped to Unknown'
FROM stg.OrderDetails_Staging od
LEFT JOIN stg.Products_Staging p ON od.ProductID = p.ProductID
WHERE p.ProductID IS NULL;

GO
