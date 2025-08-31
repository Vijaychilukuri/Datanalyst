/* Pizza ETL — Full end-to-end (Option B) — Generated: 2025-08-31T09:24:25 */

-- run_all.sql
:r 00_create_database.sql
:r 01_config_and_logging.sql
:r 02_raw_tables.sql
:r 03_staging_tables.sql
:r 04_quarantine_tables.sql
:r 05_ods_tables.sql
:r 06_dwh_tables.sql
:r 11_load_raw_data.sql
:r 12_load_staging.sql
:r 13_load_quarantine.sql
:r 23_load_to_ods.sql
:r 24_build_dimensions.sql
:r 25_build_fact_sales.sql
:r 26_views_and_quality_scorecards.sql
:r 27_monitoring_queries.sql
-- Optionally run unit tests
:r 30_unit_tests.sql
GO
PRINT 'Full ETL run_all executed (check meta.load_audit for status).';
