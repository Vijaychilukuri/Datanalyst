-- 02_raw_tables.sql
USE PizzaDW;
GO

IF OBJECT_ID('raw.Customers_Raw') IS NOT NULL DROP TABLE raw.Customers_Raw;
CREATE TABLE raw.Customers_Raw (
    CustomerID INT NULL,
    FirstName NVARCHAR(50) NULL,
    LastName NVARCHAR(50) NULL,
    Email NVARCHAR(120) NULL,
    Phone NVARCHAR(30) NULL,
    City NVARCHAR(50) NULL,
    Country NVARCHAR(50) NULL,
    CreatedDate DATETIME2 NULL
);

IF OBJECT_ID('raw.Products_Raw') IS NOT NULL DROP TABLE raw.Products_Raw;
CREATE TABLE raw.Products_Raw (
    ProductID INT NULL,
    ProductName NVARCHAR(100) NULL,
    Category NVARCHAR(50) NULL,
    Price DECIMAL(10,2) NULL
);

IF OBJECT_ID('raw.PizzaTypes_Raw') IS NOT NULL DROP TABLE raw.PizzaTypes_Raw;
CREATE TABLE raw.PizzaTypes_Raw (
    PizzaTypeID INT NULL,
    TypeName NVARCHAR(100) NULL,
    Description NVARCHAR(400) NULL
);

IF OBJECT_ID('raw.Orders_Raw') IS NOT NULL DROP TABLE raw.Orders_Raw;
CREATE TABLE raw.Orders_Raw (
    OrderID INT NULL,
    CustomerID INT NULL,
    OrderDate DATE NULL,
    Status NVARCHAR(50) NULL,
    TotalAmount DECIMAL(12,2) NULL
);

IF OBJECT_ID('raw.OrderDetails_Raw') IS NOT NULL DROP TABLE raw.OrderDetails_Raw;
CREATE TABLE raw.OrderDetails_Raw (
    OrderDetailID INT NULL,
    OrderID INT NULL,
    ProductID INT NULL,
    Quantity INT NULL,
    UnitPrice DECIMAL(10,2) NULL
);
GO
