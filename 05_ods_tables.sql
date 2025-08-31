-- 05_ods_tables.sql
USE PizzaDW;
GO

IF OBJECT_ID('ods.Customers') IS NOT NULL DROP TABLE ods.Customers;
CREATE TABLE ods.Customers (
    CustomerID INT PRIMARY KEY,
    FirstName NVARCHAR(50) NULL,
    LastName NVARCHAR(50) NULL,
    Email NVARCHAR(120) NULL,
    Phone NVARCHAR(30) NULL,
    City NVARCHAR(50) NULL,
    Country NVARCHAR(50) NULL,
    CreatedDate DATETIME2 NULL,
    LoadDate DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);

IF OBJECT_ID('ods.Products') IS NOT NULL DROP TABLE ods.Products;
CREATE TABLE ods.Products (
    ProductID INT PRIMARY KEY,
    ProductName NVARCHAR(100) NULL,
    Category NVARCHAR(50) NULL,
    Price DECIMAL(10,2) NULL,
    LoadDate DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);

IF OBJECT_ID('ods.PizzaTypes') IS NOT NULL DROP TABLE ods.PizzaTypes;
CREATE TABLE ods.PizzaTypes (
    PizzaTypeID INT PRIMARY KEY,
    TypeName NVARCHAR(100) NULL,
    Description NVARCHAR(400) NULL,
    LoadDate DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);

IF OBJECT_ID('ods.Orders') IS NOT NULL DROP TABLE ods.Orders;
CREATE TABLE ods.Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT NOT NULL,
    OrderDate DATE NULL,
    Status NVARCHAR(50) NULL,
    TotalAmount DECIMAL(12,2) NULL,
    LoadDate DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);

IF OBJECT_ID('ods.OrderDetails') IS NOT NULL DROP TABLE ods.OrderDetails;
CREATE TABLE ods.OrderDetails (
    OrderDetailID INT PRIMARY KEY,
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NULL,
    UnitPrice DECIMAL(10,2) NULL,
    LoadDate DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO
