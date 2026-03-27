# billiard-salon-warehouse
# Billiard Salon Management System — SQL Server Data Warehouse

A end-to-end database project built in SQL Server, covering normalized OLTP design, dimensional modeling, ETL pipeline, and automated change tracking via triggers.

## Project Structure

| File | Description |
|---|---|
| `normalised.sql` | 3NF OLTP schema (8 tables) with triggers and INSERT pipeline from raw CSV |
| `billdimensional.sql` | Star schema warehouse: 4 dimension tables, 2 fact tables, 1 bridge table |
| `bill_etl_merge.sql` | ETL pipeline: 7 MERGE statements syncing OLTP → warehouse (upsert + delete) |
| `bill_timestamps_triggers.sql` | AFTER INSERT/UPDATE triggers on all 6 source tables for `modified_on` tracking |

## Schema Overview

**OLTP (normalised.sql)**
- `customers`, `staff`, `tabletypes`, `billiardtables`, `services`, `sessions`, `session_services`, `payments`
- Seeded from a flat CSV using `DENSE_RANK()` and `ROW_NUMBER()` to generate surrogate keys

**Warehouse (billdimensional.sql)**
- Dimensions: `dim_customer`, `dim_staff`, `dim_billiardtable`, `dim_service`, `dim_date`
- Facts: `fact_session`, `fact_payment`
- Bridge: `fact_session_service`

**ETL (bill_etl_merge.sql)**
- Full bidirectional sync: inserts new rows, updates changed rows, deletes removed rows
- Covers all 4 dimensions + 2 fact tables + bridge

## Tech Stack

- SQL Server (T-SQL)
- Concepts: 3NF normalization, star schema, ETL, window functions, triggers, MERGE statement

## Context

Coursework project — Database Systems, BSc Data Science in Business, Corvinus University of Budapest (2024).
