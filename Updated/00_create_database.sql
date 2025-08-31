/* Pizza ETL — Full end-to-end (Option B) — Generated: 2025-08-31T09:24:25 */

USE master;
GO
IF DB_ID('PizzaETL') IS NULL
BEGIN
    CREATE DATABASE PizzaETL;
END
GO
USE PizzaETL;
GO
-- Create schemas
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name='raw') EXEC('CREATE SCHEMA raw');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name='stg') EXEC('CREATE SCHEMA stg');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name='quarantine') EXEC('CREATE SCHEMA quarantine');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name='ods') EXEC('CREATE SCHEMA ods');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name='dwh') EXEC('CREATE SCHEMA dwh');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name='meta') EXEC('CREATE SCHEMA meta');
GO
