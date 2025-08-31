-- 28_stored_procs.sql
USE PizzaDW;
GO

-- Simple logging helpers
IF OBJECT_ID('dbo.usp_LogStart') IS NOT NULL DROP PROCEDURE dbo.usp_LogStart;
GO
CREATE PROCEDURE dbo.usp_LogStart
  @ProcessName NVARCHAR(200),
  @SourceTable NVARCHAR(128) = NULL,
  @TargetTable NVARCHAR(128) = NULL,
  @LogID INT OUTPUT
AS
BEGIN
  SET NOCOUNT ON;
  INSERT INTO log.ETL_Log (ProcessName, SourceTable, TargetTable, Status, RunOwner)
  VALUES (@ProcessName, @SourceTable, @TargetTable, 'Started', (SELECT ConfigValue FROM cfg.ETL_Config WHERE ConfigName='RunOwner'));
  SET @LogID = SCOPE_IDENTITY();
END
GO

IF OBJECT_ID('dbo.usp_LogEnd') IS NOT NULL DROP PROCEDURE dbo.usp_LogEnd;
GO
CREATE PROCEDURE dbo.usp_LogEnd
  @LogID INT,
  @RowsRead INT = NULL,
  @RowsInserted INT = NULL,
  @RowsUpdated INT = NULL,
  @RowsRejected INT = NULL,
  @Status NVARCHAR(30) = 'Success',
  @ErrorMessage NVARCHAR(MAX) = NULL
AS
BEGIN
  UPDATE log.ETL_Log
  SET EndTime = SYSDATETIME(),
      RowsRead = COALESCE(@RowsRead, RowsRead),
      RowsInserted = COALESCE(@RowsInserted, RowsInserted),
      RowsUpdated = COALESCE(@RowsUpdated, RowsUpdated),
      RowsRejected = COALESCE(@RowsRejected, RowsRejected),
      Status = @Status,
      ErrorMessage = @ErrorMessage
  WHERE LogID = @LogID;
END
GO

-- Orchestrator (Raw->Stg->ODS->DWH demo)
IF OBJECT_ID('dbo.usp_Run_Pipeline_Demo') IS NOT NULL DROP PROCEDURE dbo.usp_Run_Pipeline_Demo;
GO
CREATE PROCEDURE dbo.usp_Run_Pipeline_Demo
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @LogID INT;
  EXEC dbo.usp_LogStart @ProcessName='Full Pipeline Demo', @SourceTable='raw.*', @TargetTable='dwh.*', @LogID=@LogID OUTPUT;

  BEGIN TRY
    -- Load raw->stg cleaning
    :r 21_cleaning_rules.sql
    -- FK validation
    :r 22_fk_validation_and_mapping.sql
    -- Load to ODS
    :r 23_load_to_ods.sql
    -- Build dims
    :r 24_build_dimensions.sql
    -- Build fact
    :r 25_build_fact_sales.sql

    EXEC dbo.usp_LogEnd @LogID=@LogID, @Status='Success';
  END TRY
  BEGIN CATCH
    EXEC dbo.usp_LogEnd @LogID=@LogID, @Status='Failed', @ErrorMessage=ERROR_MESSAGE();
    THROW;
  END CATCH
END
GO
