/* Pizza ETL — Full end-to-end (Option B) — Generated: 2025-08-31T09:24:25 */

-- 29_scheduler_note.sql
-- Notes: To run this pipeline on schedule:
-- 1) Use SQL Server Agent job with steps calling: sqlcmd -S <server> -i run_all.sql
-- 2) Or use Azure Data Factory / Synapse to orchestrate stored procedures or script steps.
-- Ensure the SQL Agent service account has access to the file share containing CSVs.
