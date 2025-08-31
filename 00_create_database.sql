-- 00_create_database.sql
IF DB_ID('PizzaDW') IS NULL
BEGIN
    CREATE DATABASE PizzaDW;
END
GO

USE PizzaDW;
GO

-- Create schemas
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'cfg') EXEC('CREATE SCHEMA cfg');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'log') EXEC('CREATE SCHEMA log');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'raw') EXEC('CREATE SCHEMA raw');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'stg') EXEC('CREATE SCHEMA stg');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'qrt') EXEC('CREATE SCHEMA qrt');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'ods') EXEC('CREATE SCHEMA ods');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'dwh') EXEC('CREATE SCHEMA dwh');
GO
