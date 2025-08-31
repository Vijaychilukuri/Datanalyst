-- 04_quarantine_tables.sql
USE PizzaDW;
GO

IF OBJECT_ID('qrt.Customers_Issues') IS NOT NULL DROP TABLE qrt.Customers_Issues;
CREATE TABLE qrt.Customers_Issues (
    IssueID INT IDENTITY(1,1) PRIMARY KEY,
    IssueType NVARCHAR(50) NOT NULL, -- NULLS, DUPLICATE, FK, IMPOSSIBLE
    SnapshotTime DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    SourceLayer NVARCHAR(10) NOT NULL DEFAULT 'STG',
    CustomerID INT NULL,
    Payload NVARCHAR(MAX) NULL
);

IF OBJECT_ID('qrt.Orders_Issues') IS NOT NULL DROP TABLE qrt.Orders_Issues;
CREATE TABLE qrt.Orders_Issues (
    IssueID INT IDENTITY(1,1) PRIMARY KEY,
    IssueType NVARCHAR(50) NOT NULL,
    SnapshotTime DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    SourceLayer NVARCHAR(10) NOT NULL DEFAULT 'STG',
    OrderID INT NULL,
    CustomerID INT NULL,
    Payload NVARCHAR(MAX) NULL
);

IF OBJECT_ID('qrt.OrderDetails_Issues') IS NOT NULL DROP TABLE qrt.OrderDetails_Issues;
CREATE TABLE qrt.OrderDetails_Issues (
    IssueID INT IDENTITY(1,1) PRIMARY KEY,
    IssueType NVARCHAR(50) NOT NULL,
    SnapshotTime DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    SourceLayer NVARCHAR(10) NOT NULL DEFAULT 'STG',
    OrderDetailID INT NULL,
    OrderID INT NULL,
    ProductID INT NULL,
    Payload NVARCHAR(MAX) NULL
);

IF OBJECT_ID('qrt.Products_Issues') IS NOT NULL DROP TABLE qrt.Products_Issues;
CREATE TABLE qrt.Products_Issues (
    IssueID INT IDENTITY(1,1) PRIMARY KEY,
    IssueType NVARCHAR(50) NOT NULL,
    SnapshotTime DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    SourceLayer NVARCHAR(10) NOT NULL DEFAULT 'STG',
    ProductID INT NULL,
    Payload NVARCHAR(MAX) NULL
);

IF OBJECT_ID('qrt.PizzaTypes_Issues') IS NOT NULL DROP TABLE qrt.PizzaTypes_Issues;
CREATE TABLE qrt.PizzaTypes_Issues (
    IssueID INT IDENTITY(1,1) PRIMARY KEY,
    IssueType NVARCHAR(50) NOT NULL,
    SnapshotTime DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    SourceLayer NVARCHAR(10) NOT NULL DEFAULT 'STG',
    PizzaTypeID INT NULL,
    Payload NVARCHAR(MAX) NULL
);
GO
