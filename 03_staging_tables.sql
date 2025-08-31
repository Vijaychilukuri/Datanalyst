-- 03_staging_tables.sql
USE PizzaDW;
GO

IF OBJECT_ID('stg.Customers_Staging') IS NOT NULL DROP TABLE stg.Customers_Staging;
CREATE TABLE stg.Customers_Staging (
    CustomerID INT NOT NULL,
    FirstName NVARCHAR(50) NULL,
    LastName NVARCHAR(50) NULL,
    Email NVARCHAR(120) NULL,
    Phone NVARCHAR(30) NULL,
    City NVARCHAR(50) NULL,
    Country NVARCHAR(50) NULL,
    CreatedDate DATETIME2 NULL,
    Is_Unlinked BIT NOT NULL DEFAULT 0,
    DataQualityIssue NVARCHAR(200) NULL
);

IF OBJECT_ID('stg.Products_Staging') IS NOT NULL DROP TABLE stg.Products_Staging;
CREATE TABLE stg.Products_Staging (
    ProductID INT NOT NULL,
    ProductName NVARCHAR(100) NULL,
    Category NVARCHAR(50) NULL,
    Price DECIMAL(10,2) NULL,
    Is_Unlinked BIT NOT NULL DEFAULT 0,
    DataQualityIssue NVARCHAR(200) NULL
);

IF OBJECT_ID('stg.PizzaTypes_Staging') IS NOT NULL DROP TABLE stg.PizzaTypes_Staging;
CREATE TABLE stg.PizzaTypes_Staging (
    PizzaTypeID INT NOT NULL,
    TypeName NVARCHAR(100) NULL,
    Description NVARCHAR(400) NULL,
    Is_Unlinked BIT NOT NULL DEFAULT 0,
    DataQualityIssue NVARCHAR(200) NULL
);

IF OBJECT_ID('stg.Orders_Staging') IS NOT NULL DROP TABLE stg.Orders_Staging;
CREATE TABLE stg.Orders_Staging (
    OrderID INT NOT NULL,
    CustomerID INT NULL,
    OrderDate DATE NULL,
    Status NVARCHAR(50) NULL,
    TotalAmount DECIMAL(12,2) NULL,
    Is_Unlinked BIT NOT NULL DEFAULT 0,
    DataQualityIssue NVARCHAR(200) NULL
);

IF OBJECT_ID('stg.OrderDetails_Staging') IS NOT NULL DROP TABLE stg.OrderDetails_Staging;
CREATE TABLE stg.OrderDetails_Staging (
    OrderDetailID INT NOT NULL,
    OrderID INT NULL,
    ProductID INT NULL,
    Quantity INT NULL,
    UnitPrice DECIMAL(10,2) NULL,
    Is_Unlinked BIT NOT NULL DEFAULT 0,
    DataQualityIssue NVARCHAR(200) NULL
);
GO
