# PizzaDW ETL Project (Analyst-Focused, Industry-Standard)

This project is a **downloadable, production-style SQL ETL** template designed for a **4-year data analyst** to practice real-world workflows end-to-end.
It includes **config tables, log tables, raw→staging→ODS→DWH layers, quarantine/error handling, data quality profiling, cleaning rules,
FK validation, deduplication, SCD handling, fact/dimension loads, monitoring views**, and **sample data generation** (~10k+ rows).

## Layers & Schemas
- `cfg` — configuration (dynamic parameters, no hardcoding)
- `log` — ETL run logs and step logs (with `SCOPE_IDENTITY()` pattern)
- `raw` — raw landing tables (ingested as-is from source/CSV/files)
- `stg` — staging tables (profiling, cleaning, dedup, FK mapping)
- `qrt` — quarantine/error tables (audit trail; nothing is deleted without copy)
- `ods` — cleaned, conformed operational data store (analysts’ daily source of truth)
- `dwh` — star schema (dimensions + facts) for BI/analytics

## Execution Order (in SSMS)
1. `00_create_database.sql`
2. `01_config_and_logging.sql`
3. `02_raw_tables.sql`
4. `03_staging_tables.sql`
5. `04_quarantine_tables.sql`
6. `05_ods_tables.sql`
7. `06_dwh_tables.sql`
8. `10_sample_data_generation.sql` (optional: generates ~10k+ records with realistic issues)
9. `20_dq_profiles.sql` (🔴 **Analyst Task**: profile nulls, duplicates, FKs, impossible values)
10. `21_cleaning_rules.sql` (apply null fixes, map unknowns, quarantine, dedup)
11. `22_fk_validation_and_mapping.sql` (validate & enforce referential integrity)
12. `23_load_to_ods.sql` (load to ODS with logging; includes `SCOPE_IDENTITY()` usage)
13. `24_build_dimensions.sql` (SCD1 dims incl. unknown members)
14. `25_build_fact_sales.sql` (build Fact_Sales; ensure no broken links)
15. `26_views_and_quality_scorecards.sql` (monitoring/reporting views)
16. `27_monitoring_queries.sql` (🔴 **Analyst Task**: daily checks against log + scorecards)
17. `28_stored_procs.sql` (orchestrate steps; reusable logging procs)
18. `29_scheduler_note.sql` (notes for SQL Agent jobs/scheduling)
19. `30_unit_tests.sql` (sanity tests: counts, constraints)
20. `31_rollback_scripts.sql` (truncate/reset utilities for reruns)

> Comments marked with **🔴 Analyst Task** indicate clear responsibilities for a 4-year analyst.

## Important Notes (Real-World Alignment)
- **No silent deletes**: all removals are preceded by **quarantine** into `qrt.*` tables.
- **Unknown members**: we use **-1** surrogate keys (Kimball best practice).
- **Logging**: Each load writes to `log.ETL_Log`, step details to `log.ETL_RunStep`. We capture the run id using `SCOPE_IDENTITY()`.
- **Config-driven**: Default statuses, thresholds, and feature toggles live in `cfg.ETL_Config`.
- **Performance**: Sample data generation is simple T‑SQL; in production you would use SSIS/Azure Data Factory/Spark — commented where relevant.

— Generated on 2025-08-28 16:54:49
