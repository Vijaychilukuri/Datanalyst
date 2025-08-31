-- 23_load_to_ods.sql
USE PizzaDW;
GO

DECLARE @LogID INT;
DECLARE @ProcessName NVARCHAR(200) = 'Staging->ODS Load';

INSERT INTO log.ETL_Log (ProcessName, SourceTable, TargetTable, Status, RunOwner)
VALUES (@ProcessName, 'stg.*', 'ods.*', 'Started', (SELECT ConfigValue FROM cfg.ETL_Config WHERE ConfigName='RunOwner'));

SET @LogID = SCOPE_IDENTITY();

-- STEP: Customers
INSERT INTO log.ETL_RunStep (LogID, StepName) VALUES (@LogID, 'Load ODS.Customers'); DECLARE @StepID1 INT= SCOPE_IDENTITY();
MERGE ods.Customers AS tgt
USING (SELECT * FROM stg.Customers_Staging) AS src
ON (tgt.CustomerID = src.CustomerID)
WHEN MATCHED THEN UPDATE SET
  FirstName=src.FirstName, LastName=src.LastName, Email=src.Email, Phone=src.Phone, City=src.City, Country=src.Country, CreatedDate=src.CreatedDate
WHEN NOT MATCHED THEN
  INSERT (CustomerID, FirstName, LastName, Email, Phone, City, Country, CreatedDate) 
  VALUES (src.CustomerID, src.FirstName, src.LastName, src.Email, src.Phone, src.City, src.Country, src.CreatedDate);

UPDATE log.ETL_RunStep SET StepEnd=SYSDATETIME(), StepStatus='Success',
    StepRows=(SELECT COUNT(*) FROM ods.Customers) WHERE StepID=@StepID1;

-- STEP: Products
INSERT INTO log.ETL_RunStep (LogID, StepName) VALUES (@LogID, 'Load ODS.Products'); DECLARE @StepID2 INT= SCOPE_IDENTITY();
MERGE ods.Products AS tgt
USING (SELECT * FROM stg.Products_Staging) AS src
ON (tgt.ProductID = src.ProductID)
WHEN MATCHED THEN UPDATE SET
  ProductName=src.ProductName, Category=src.Category, Price=src.Price
WHEN NOT MATCHED THEN
  INSERT (ProductID, ProductName, Category, Price) 
  VALUES (src.ProductID, src.ProductName, src.Category, src.Price);
UPDATE log.ETL_RunStep SET StepEnd=SYSDATETIME(), StepStatus='Success',
    StepRows=(SELECT COUNT(*) FROM ods.Products) WHERE StepID=@StepID2;

-- STEP: PizzaTypes
INSERT INTO log.ETL_RunStep (LogID, StepName) VALUES (@LogID, 'Load ODS.PizzaTypes'); DECLARE @StepID3 INT= SCOPE_IDENTITY();
MERGE ods.PizzaTypes AS tgt
USING (SELECT * FROM stg.PizzaTypes_Staging) AS src
ON (tgt.PizzaTypeID = src.PizzaTypeID)
WHEN MATCHED THEN UPDATE SET
  TypeName=src.TypeName, Description=src.Description
WHEN NOT MATCHED THEN
  INSERT (PizzaTypeID, TypeName, Description) 
  VALUES (src.PizzaTypeID, src.TypeName, src.Description);
UPDATE log.ETL_RunStep SET StepEnd=SYSDATETIME(), StepStatus='Success',
    StepRows=(SELECT COUNT(*) FROM ods.PizzaTypes) WHERE StepID=@StepID3;

-- STEP: Orders (only those with valid CustomerID; invalids were mapped to Unknown earlier)
INSERT INTO log.ETL_RunStep (LogID, StepName) VALUES (@LogID, 'Load ODS.Orders'); DECLARE @StepID4 INT= SCOPE_IDENTITY();
MERGE ods.Orders AS tgt
USING (
  SELECT OrderID, CustomerID, OrderDate, Status, TotalAmount
  FROM stg.Orders_Staging
) AS src
ON (tgt.OrderID = src.OrderID)
WHEN MATCHED THEN UPDATE SET
  CustomerID=src.CustomerID, OrderDate=src.OrderDate, Status=src.Status, TotalAmount=src.TotalAmount
WHEN NOT MATCHED THEN
  INSERT (OrderID, CustomerID, OrderDate, Status, TotalAmount) 
  VALUES (src.OrderID, src.CustomerID, src.OrderDate, src.Status, src.TotalAmount);
UPDATE log.ETL_RunStep SET StepEnd=SYSDATETIME(), StepStatus='Success',
    StepRows=(SELECT COUNT(*) FROM ods.Orders) WHERE StepID=@StepID4;

-- STEP: OrderDetails (exclude rows flagged as Is_Unlinked due to missing OrderID)
INSERT INTO log.ETL_RunStep (LogID, StepName) VALUES (@LogID, 'Load ODS.OrderDetails'); DECLARE @StepID5 INT= SCOPE_IDENTITY();
MERGE ods.OrderDetails AS tgt
USING (
  SELECT OrderDetailID, OrderID, ProductID, Quantity, UnitPrice
  FROM stg.OrderDetails_Staging
  WHERE Is_Unlinked = 0 OR (Is_Unlinked=1 AND DataQualityIssue NOT LIKE '%Missing OrderID%')
) AS src
ON (tgt.OrderDetailID = src.OrderDetailID)
WHEN MATCHED THEN UPDATE SET
  OrderID=src.OrderID, ProductID=src.ProductID, Quantity=src.Quantity, UnitPrice=src.UnitPrice
WHEN NOT MATCHED THEN
  INSERT (OrderDetailID, OrderID, ProductID, Quantity, UnitPrice)
  VALUES (src.OrderDetailID, src.OrderID, src.ProductID, src.Quantity, src.UnitPrice);
UPDATE log.ETL_RunStep SET StepEnd=SYSDATETIME(), StepStatus='Success',
    StepRows=(SELECT COUNT(*) FROM ods.OrderDetails) WHERE StepID=@StepID5;

-- Finalize log
UPDATE log.ETL_Log
SET EndTime=SYSDATETIME(),
    RowsRead = (SELECT SUM(x.cnt) FROM (VALUES ((SELECT COUNT(*) FROM stg.Customers_Staging)),
                                              ((SELECT COUNT(*) FROM stg.Products_Staging)),
                                              ((SELECT COUNT(*) FROM stg.Orders_Staging)),
                                              ((SELECT COUNT(*) FROM stg.OrderDetails_Staging))) x(cnt)),
    RowsInserted = (SELECT SUM(x.cnt) FROM (VALUES ((SELECT COUNT(*) FROM ods.Customers)),
                                                  ((SELECT COUNT(*) FROM ods.Products)),
                                                  ((SELECT COUNT(*) FROM ods.Orders)),
                                                  ((SELECT COUNT(*) FROM ods.OrderDetails))) x(cnt)),
    Status='Success'
WHERE LogID = @LogID;
GO
