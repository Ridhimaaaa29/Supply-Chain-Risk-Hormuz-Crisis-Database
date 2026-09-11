-- Task 10: COPY, Export, Import, Backup, Restore & DCL
-- Database: SupplyChainRiskDB
-- PostgreSQL 17
--
-- NOTE:
-- \copy and pg_dump/pg_restore are client-side commands.
-- Run \copy in psql.
-- Run pg_dump/pg_restore in PowerShell.
-- SQL verification/GRANT statements can be run in pgAdmin Query Tool.

-- A. EXPORT USING COPY

-- Run in psql:
-- \copy (SELECT * FROM supply_chain.vw_critical_shipments) TO 'C:\Users\USER\Downloads\critical_shipments.csv' WITH CSV HEADER

-- Run in psql:
-- \copy (SELECT * FROM supply_chain.vw_supplier_performance) TO 'C:\Users\USER\Downloads\supplier_summary.csv' WITH CSV HEADER

-- Actual results:
-- critical_shipments.csv: 5 rows
-- supplier_summary.csv: 382 rows

-- B. IMPORT USING COPY

-- CREATE TABLE IF NOT EXISTS supply_chain.critical_shipments_staging(
-- shipment_id VARCHAR(20),
-- supplier VARCHAR(20),
-- country VARCHAR(100),
-- product VARCHAR(100),
-- route_risk NUMERIC(5,2),
-- political_risk NUMERIC(5,2),
-- port_congestion NUMERIC(5,2),
-- delay_probability NUMERIC(5,2),
-- current_delay INTEGER,
-- inventory_days INTEGER
-- );

-- Run in psql:
-- \copy supply_chain.critical_shipments_staging FROM 'C:\Users\USER\Downloads\critical_shipments.csv' WITH CSV HEADER

SELECT COUNT(*) AS row_count
FROM supply_chain.critical_shipments_staging;
-- Expected: 5

SELECT COUNT(*) AS column_count
FROM information_schema.columns
WHERE table_schema='supply_chain'
AND table_name='critical_shipments_staging';
-- Expected: 10

SELECT *
FROM supply_chain.critical_shipments_staging
EXCEPT
SELECT *
FROM supply_chain.vw_critical_shipments;
-- Expected: 0 rows

-- C. DATABASE BACKUP

-- Run these in PowerShell.

-- Full database backup:
-- & "C:\Program Files\PostgreSQL\17\bin\pg_dump.exe" -U postgres -d SupplyChainRiskDB -F c -f "C:\Users\USER\Downloads\SupplyChainRiskDB_full.backup"

-- Schema-only backup:
-- & "C:\Program Files\PostgreSQL\17\bin\pg_dump.exe" -U postgres -d SupplyChainRiskDB --schema-only -f "C:\Users\USER\Downloads\SupplyChainRiskDB_schema.sql"

-- Data-only backup:
-- & "C:\Program Files\PostgreSQL\17\bin\pg_dump.exe" -U postgres -d SupplyChainRiskDB --data-only -f "C:\Users\USER\Downloads\SupplyChainRiskDB_data.sql"

-- D. RESTORE

-- Create the restore database while connected to postgres:
-- CREATE DATABASE "SupplyChainRiskDB_Restore";

-- Run in PowerShell:
-- & "C:\Program Files\PostgreSQL\17\bin\pg_restore.exe" -U postgres -d SupplyChainRiskDB_Restore "C:\Users\USER\Downloads\SupplyChainRiskDB_full.backup"

-- After connecting to SupplyChainRiskDB_Restore:

SELECT table_name
FROM information_schema.tables
WHERE table_schema='supply_chain'
ORDER BY table_name;

SELECT COUNT(*) AS shipment_count
FROM supply_chain.shipments;
-- Expected: 697

SELECT table_name
FROM information_schema.views
WHERE table_schema='supply_chain'
ORDER BY table_name;

SELECT routine_name,routine_type
FROM information_schema.routines
WHERE routine_schema='supply_chain'
ORDER BY routine_name;

SELECT trigger_name
FROM information_schema.triggers
WHERE trigger_schema='supply_chain'
ORDER BY trigger_name;

SELECT indexname
FROM pg_indexes
WHERE schemaname='supply_chain'
ORDER BY indexname;

SELECT table_name,constraint_name,constraint_type
FROM information_schema.table_constraints
WHERE table_schema='supply_chain'
ORDER BY table_name,constraint_name;

-- E. DCL & ROLE MANAGEMENT

-- Run role creation while connected to the postgres database.

CREATE ROLE supply_chain_admin LOGIN PASSWORD 'Admin@123';
CREATE ROLE supply_chain_analyst LOGIN PASSWORD 'Analyst@123';
CREATE ROLE supply_chain_viewer LOGIN PASSWORD 'Viewer@123';

-- Admin: full database access.
-- Run from the postgres database:
-- GRANT ALL PRIVILEGES ON DATABASE "SupplyChainRiskDB" TO supply_chain_admin;

-- Run while connected to SupplyChainRiskDB:
GRANT ALL PRIVILEGES ON SCHEMA supply_chain TO supply_chain_admin;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA supply_chain TO supply_chain_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA supply_chain TO supply_chain_admin;

-- Analyst: SELECT, INSERT, UPDATE.
GRANT CONNECT ON DATABASE "SupplyChainRiskDB" TO supply_chain_analyst;
GRANT USAGE ON SCHEMA supply_chain TO supply_chain_analyst;
GRANT SELECT,INSERT,UPDATE ON ALL TABLES IN SCHEMA supply_chain TO supply_chain_analyst;
GRANT USAGE,SELECT ON ALL SEQUENCES IN SCHEMA supply_chain TO supply_chain_analyst;

-- Viewer: SELECT only.
GRANT CONNECT ON DATABASE "SupplyChainRiskDB" TO supply_chain_viewer;
GRANT USAGE ON SCHEMA supply_chain TO supply_chain_viewer;
GRANT SELECT ON ALL TABLES IN SCHEMA supply_chain TO supply_chain_viewer;

-- Demonstrate GRANT and REVOKE:
GRANT DELETE ON ALL TABLES IN SCHEMA supply_chain TO supply_chain_analyst;
REVOKE DELETE ON ALL TABLES IN SCHEMA supply_chain FROM supply_chain_analyst;

-- Verify table privileges:
SELECT grantee,table_name,privilege_type
FROM information_schema.role_table_grants
WHERE grantee IN('supply_chain_admin','supply_chain_analyst','supply_chain_viewer')
ORDER BY grantee,table_name,privilege_type;

-- Verify roles:
SELECT rolname,rolcanlogin
FROM pg_roles
WHERE rolname IN('supply_chain_admin','supply_chain_analyst','supply_chain_viewer')
ORDER BY rolname;
