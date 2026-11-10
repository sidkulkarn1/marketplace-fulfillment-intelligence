# Methodology & Reproduction Guide

## Analytical design

The unit of analysis is the order. The workflow preserves raw data, defines eligibility separately for each KPI, uses single-seller orders for merchant attribution, and separates historical observations from hypothetical interventions.

## Prerequisites

Use DuckDB and an Excel version capable of importing CSV files. Place the nine Olist CSV files named in [SQL 01](../sql/01_data_ingestion.sql) under `data/raw/`. Raw data and local DuckDB databases are intentionally excluded from Git. Create `outputs/tables/` if it is absent and run SQL from the repository root so relative paths resolve.

## Execution order

Run these scripts in numerical order against the same DuckDB database. For a local DuckDB CLI session, the pattern is `.read sql/01_data_ingestion.sql`, followed by each subsequent script.

| Step | Script | Work performed |
|---|---|---|
| 01 | [Ingestion](../sql/01_data_ingestion.sql) | Create `raw` schema and load nine source tables with automatic CSV type inference |
| 02 | [Quality audit](../sql/02_data_quality_audit.sql) | Inspect ID uniqueness, status counts, missing timestamps, four foreign-key relationships, timestamp ordering, metric eligibility, item/seller grain, and orders without items |
| 03 | [Fulfillment KPIs](../sql/03_fulfillment_kpis.sql) | Aggregate items per order before joining to orders; create order-level, marketplace, and purchase-month views |
| 04 | [Merchant performance](../sql/04_merchant_performance.sql) | Isolate single-seller orders; calculate merchant metrics; prioritize merchants with ≥30 eligible deliveries |
| 05 | [Diagnostics](../sql/05_root_cause_pareto.sql) | Build merchant Pareto, customer-state, category, and processing-band views |
| 06 | [Scenarios](../sql/06_scenario_analysis.sql) | Apply hypothetical effectiveness assumptions to the top 10, 25, and 50 merchants |
| 07 | [Reporting](../sql/07_excel_reporting_views.sql) | Create eight reporting views and export their CSVs to `outputs/tables/` |

The audit script returns diagnostic result sets; it does not automatically stop the pipeline on failures. Review results before continuing. Ingestion replaces raw tables, and reporting exports write to fixed filenames; retain any outputs needed for comparison before rerunning.

## Quality and attribution choices

Raw records are preserved. Invalid durations become null only in the affected measure. Delivered status alone is insufficient for delivery-reliability eligibility when dates are missing. See the [audit summary](phase1_audit_summary.md) and [KPI dictionary](kpi_dictionary.md) for observed counts and exact rules.

Single-seller attribution avoids arbitrarily assigning multi-seller order delays. The qualifying merchant cohort is a subset of marketplace sellers, so its Pareto percentages use a cohort denominator. Orders without items remain in marketplace KPIs.

Regional analysis uses customer state. Category analysis assigns exactly one category group per order: English category if available, original category as fallback, then `unknown`; multi-category orders and orders without items receive separate groups. Processing diagnostics include delivered orders with invalid or missing processing time in a separate band.

## Excel reporting and checks

Import or refresh the eight CSVs in [the workbook](../excel/Marketplace_Fulfillment_Intelligence.xlsx) using Power Query / CSV import as appropriate for the configured workbook connections. If file paths have changed, update the import source paths. The repository does not provide a fully automated Excel refresh pipeline.

The five dashboards cover executive KPIs, merchant performance, descriptive diagnostics, scenario analysis, and an implementation scorecard. SQL supplies baselines and modeled operational outcomes; Excel adds editable decision assumptions and implementation costs.

Before publishing a refreshed workbook:

1. Reconcile marketplace totals and eligible denominators with `executive_kpis.csv`.
2. Confirm merchant counts, rankings, and cohort shares against the scorecard and Pareto exports.
3. Reconcile scenario baselines and default outcomes with `scenario_comparison.csv`.
4. Recalculate Excel and check formulas, chart ranges, and errors.
5. Change effectiveness and cost inputs to verify sensitivity, then restore intended defaults.
6. Save the workbook and refresh dashboard screenshots if displayed values changed.

## Interpretation and future validation

Diagnostics identify associations and investigation priorities, not causal effects. Scenario effectiveness and costs are explicit assumptions. A controlled 10-merchant pilot is recommended but has not been executed. Predefine comparison groups, evaluation periods, success thresholds, and guardrails; use measured results to update assumptions before scaling.

See [business problem](business_problem.md), [assumptions](assumptions.md), and [data dictionary](data_dictionary.md).
