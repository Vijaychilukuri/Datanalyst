/* Pizza ETL — Full end-to-end (Option B) — Generated: 2025-08-31T09:24:25 */

USE PizzaETL;
GO
-- Pipeline config and logging
IF OBJECT_ID('meta.pipeline_config') IS NULL
CREATE TABLE meta.pipeline_config (
    config_id INT IDENTITY(1,1) PRIMARY KEY,
    config_name NVARCHAR(200) UNIQUE,
    config_value NVARCHAR(500),
    data_type NVARCHAR(50),
    description NVARCHAR(500),
    last_updated DATETIME2 DEFAULT SYSUTCDATETIME()
);
GO
IF OBJECT_ID('meta.load_audit') IS NULL
CREATE TABLE meta.load_audit (
    load_id INT IDENTITY(1,1) PRIMARY KEY,
    source_name NVARCHAR(200),
    data_root NVARCHAR(400),
    start_time DATETIME2 DEFAULT SYSUTCDATETIME(),
    end_time DATETIME2,
    status NVARCHAR(50), /* STARTED, SUCCESS, PARTIAL, FAILED */
    rows_raw INT,
    rows_staged INT,
    rows_quarantined INT,
    comments NVARCHAR(1000)
);
GO
IF OBJECT_ID('meta.step_log') IS NULL
CREATE TABLE meta.step_log (
    step_log_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    load_id INT,
    step_name NVARCHAR(200),
    start_time DATETIME2 DEFAULT SYSUTCDATETIME(),
    end_time DATETIME2,
    status NVARCHAR(50),
    rows_affected INT,
    message NVARCHAR(1000)
);
GO
-- default configs
MERGE meta.pipeline_config AS tgt
USING (VALUES
 ('csv.field_terminator', ',', 'STRING', 'CSV field delimiter'),
 ('csv.row_terminator', '\n', 'STRING', 'CSV row terminator'),
 ('csv.codepage', '65001', 'INT', 'UTF-8 codepage')
) AS src (config_name, config_value, data_type, description)
ON tgt.config_name = src.config_name
WHEN MATCHED THEN UPDATE SET config_value = src.config_value, data_type = src.data_type, description = src.description, last_updated = SYSUTCDATETIME()
WHEN NOT MATCHED THEN INSERT (config_name, config_value, data_type, description) VALUES (src.config_name, src.config_value, src.data_type, src.description);
GO
