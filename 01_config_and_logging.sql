-- 01_config_and_logging.sql
USE PizzaDW;
GO

-- Config table (dynamic parameters)
IF OBJECT_ID('cfg.ETL_Config') IS NOT NULL DROP TABLE cfg.ETL_Config;
CREATE TABLE cfg.ETL_Config (
    ConfigID INT IDENTITY(1,1) PRIMARY KEY,
    ConfigName NVARCHAR(100) UNIQUE NOT NULL,
    ConfigValue NVARCHAR(500) NOT NULL,
    DataType NVARCHAR(20) NOT NULL, -- STRING, INT, DATE, BOOL
    Description NVARCHAR(200) NULL
);

INSERT INTO cfg.ETL_Config (ConfigName, ConfigValue, DataType, Description) VALUES
('DefaultOrderStatus', 'Pending', 'STRING', 'Fallback status for Orders'),
('EnableQuarantine', '1', 'BOOL', 'Toggle quarantining (1=on,0=off)'),
('UnknownCustomerID', '-1', 'INT', 'Surrogate key for Unknown Customer'),
('UnknownProductID',  '-1', 'INT', 'Surrogate key for Unknown Product'),
('DQ_MaxNegativeTolerance', '0', 'INT', 'Allowed negatives in price/qty (0 means none)'),
('DQ_DuplicateResolution', 'LATEST', 'STRING', 'Which duplicate to keep (LATEST|EARLIEST|HIGHESTVALUE)'),
('RunOwner', SYSTEM_USER, 'STRING', 'Owner of ETL run');


-- Log tables
IF OBJECT_ID('log.ETL_Log') IS NOT NULL DROP TABLE log.ETL_Log;
CREATE TABLE log.ETL_Log (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    ProcessName NVARCHAR(200) NOT NULL,
    StartTime DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    EndTime DATETIME2 NULL,
    SourceTable NVARCHAR(128) NULL,
    TargetTable NVARCHAR(128) NULL,
    RowsRead INT NULL,
    RowsInserted INT NULL,
    RowsUpdated INT NULL,
    RowsRejected INT NULL,
    Status NVARCHAR(30) NOT NULL DEFAULT 'Started',
    ErrorMessage NVARCHAR(MAX) NULL,
    RunOwner NVARCHAR(128) NULL
);

IF OBJECT_ID('log.ETL_RunStep') IS NOT NULL DROP TABLE log.ETL_RunStep;
CREATE TABLE log.ETL_RunStep (
    StepID INT IDENTITY(1,1) PRIMARY KEY,
    LogID INT NOT NULL,
    StepName NVARCHAR(200) NOT NULL,
    StepStart DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    StepEnd DATETIME2 NULL,
    StepRows INT NULL,
    StepStatus NVARCHAR(30) NOT NULL DEFAULT 'Started',
    StepError NVARCHAR(MAX) NULL,
    CONSTRAINT FK_RunStep_Log FOREIGN KEY (LogID) REFERENCES log.ETL_Log(LogID)
);
GO
