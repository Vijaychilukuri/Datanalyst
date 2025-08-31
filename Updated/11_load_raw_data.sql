/* Pizza ETL — Full end-to-end (Option B) — Generated: 2025-08-31T09:24:25 */

\
USE PizzaETL;
GO
-- Loads CSV files into raw.* tables. Update @DataRoot to your CSV folder.
DECLARE @DataRoot NVARCHAR(400) = 'C:\ETL\Input'; -- <--- change this to your folder containing CSVs
DECLARE @load_id INT;

INSERT INTO meta.load_audit (source_name, data_root, status, rows_raw, comments)
VALUES ('pizza_csv_bundle', @DataRoot, 'STARTED', 0, 'Starting raw CSV load');
SET @load_id = SCOPE_IDENTITY();

BEGIN TRY
    TRUNCATE TABLE raw.orders_raw;
    TRUNCATE TABLE raw.order_details_raw;
    TRUNCATE TABLE raw.pizzas_raw;
    TRUNCATE TABLE raw.pizza_types_raw;

    BULK INSERT raw.orders_raw
    FROM (@DataRoot + '\orders.csv')
    WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', CODEPAGE = '65001', TABLOCK);

    BULK INSERT raw.order_details_raw
    FROM (@DataRoot + '\order_details.csv')
    WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', CODEPAGE = '65001', TABLOCK);

    BULK INSERT raw.pizzas_raw
    FROM (@DataRoot + '\pizzas.csv')
    WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', CODEPAGE = '65001', TABLOCK);

    BULK INSERT raw.pizza_types_raw
    FROM (@DataRoot + '\pizza_types.csv')
    WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', CODEPAGE = '65001', TABLOCK);

    UPDATE meta.load_audit
    SET status = 'RAW_LOADED',
        rows_raw = (
            (SELECT COUNT(*) FROM raw.orders_raw) +
            (SELECT COUNT(*) FROM raw.order_details_raw) +
            (SELECT COUNT(*) FROM raw.pizzas_raw) +
            (SELECT COUNT(*) FROM raw.pizza_types_raw)
        )
    WHERE load_id = @load_id;
END TRY
BEGIN CATCH
    UPDATE meta.load_audit
    SET status = 'FAILED', comments = ERROR_MESSAGE(), end_time = SYSUTCDATETIME()
    WHERE load_id = @load_id;
    THROW;
END CATCH;
GO
