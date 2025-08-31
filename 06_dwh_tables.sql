-- 06_dwh_tables.sql
USE PizzaDW;
GO

-- DimDate (simplified)
IF OBJECT_ID('dwh.DimDate') IS NOT NULL DROP TABLE dwh.DimDate;
CREATE TABLE dwh.DimDate (
    DateKey INT PRIMARY KEY,           -- yyyymmdd
    DateValue DATE NOT NULL,
    Year INT NOT NULL,
    Month INT NOT NULL,
    Day INT NOT NULL,
    MonthName NVARCHAR(12) NOT NULL
);

-- Customer Dimension (SCD1 simplified)
IF OBJECT_ID('dwh.DimCustomer') IS NOT NULL DROP TABLE dwh.DimCustomer;
CREATE TABLE dwh.DimCustomer (
    CustomerKey INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,           -- business key
    FirstName NVARCHAR(50) NULL,
    LastName NVARCHAR(50) NULL,
    Email NVARCHAR(120) NULL,
    City NVARCHAR(50) NULL,
    Country NVARCHAR(50) NULL,
    IsUnknown BIT NOT NULL DEFAULT 0,
    UniqueHash AS CHECKSUM(CustomerID, ISNULL(Email,'')) PERSISTED
);

-- Product Dimension
IF OBJECT_ID('dwh.DimProduct') IS NOT NULL DROP TABLE dwh.DimProduct;
CREATE TABLE dwh.DimProduct (
    ProductKey INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT NOT NULL,
    ProductName NVARCHAR(100) NULL,
    Category NVARCHAR(50) NULL,
    Price DECIMAL(10,2) NULL,
    IsUnknown BIT NOT NULL DEFAULT 0,
    UniqueHash AS CHECKSUM(ProductID, ISNULL(ProductName,'')) PERSISTED
);

-- PizzaType Dimension
IF OBJECT_ID('dwh.DimPizzaType') IS NOT NULL DROP TABLE dwh.DimPizzaType;
CREATE TABLE dwh.DimPizzaType (
    PizzaTypeKey INT IDENTITY(1,1) PRIMARY KEY,
    PizzaTypeID INT NOT NULL,
    TypeName NVARCHAR(100) NULL,
    Description NVARCHAR(400) NULL,
    IsUnknown BIT NOT NULL DEFAULT 0,
    UniqueHash AS CHECKSUM(PizzaTypeID, ISNULL(TypeName,'')) PERSISTED
);

-- Fact Sales
IF OBJECT_ID('dwh.Fact_Sales') IS NOT NULL DROP TABLE dwh.Fact_Sales;
CREATE TABLE dwh.Fact_Sales (
    SalesKey BIGINT IDENTITY(1,1) PRIMARY KEY,
    DateKey INT NOT NULL,
    CustomerKey INT NOT NULL,
    ProductKey INT NOT NULL,
    OrderID INT NOT NULL,
    OrderDetailID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    ExtendedAmount AS (Quantity * UnitPrice) PERSISTED
);
GO
