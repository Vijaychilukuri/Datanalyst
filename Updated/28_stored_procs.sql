/* Pizza ETL — Full end-to-end (Option B) — Generated: 2025-08-31T09:24:25 */

USE PizzaETL;
GO
-- Stored procedure to run full pipeline (documentation & wrapper)
IF OBJECT_ID('meta.sp_run_full_etl') IS NOT NULL DROP PROCEDURE meta.sp_run_full_etl;
GO
CREATE PROCEDURE meta.sp_run_full_etl @DataRoot NVARCHAR(400)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @load_id INT;
    INSERT INTO meta.load_audit (source_name, data_root, status) VALUES ('pizza_csv_bundle', @DataRoot, 'STARTED');
    SET @load_id = SCOPE_IDENTITY();
    BEGIN TRY
        -- Caller should execute individual scripts or use sqlcmd to run run_all.sql.
        UPDATE meta.load_audit SET status='SP_REGISTERED' WHERE load_id = @load_id;
    END TRY
    BEGIN CATCH
        UPDATE meta.load_audit SET status='FAILED', comments = ERROR_MESSAGE() WHERE load_id = @load_id;
        THROW;
    END CATCH
END;
GO
