-- Task 1: Database Creation, Data Loading & Data Quality

-- CREATE SCHEMA supply_chain;

-- CREATE TABLE supply_chain.shipment_raw(
-- shipment_id VARCHAR(20),
-- supplier_id VARCHAR(20),
-- country VARCHAR(100),
-- product_type VARCHAR(100),
-- monthly_demand_tons INTEGER,
-- shipment_volume_tons INTEGER,
-- route_risk_score NUMERIC(5,2),
-- historical_delay_days INTEGER,
-- fuel_price_usd NUMERIC(10,2),
-- political_risk_index NUMERIC(5,2),
-- port_congestion_index NUMERIC(5,2),
-- inventory_days INTEGER,
-- supplier_reliability NUMERIC(5,2),
-- alternative_supplier_count INTEGER,
-- transit_time_days INTEGER,
-- delay_probability NUMERIC(5,2),
-- current_delay_days INTEGER,
-- freight_cost_usd NUMERIC(15,2),
-- revenue_impact_usd NUMERIC(15,2),disruption_event INTEGER);

-- COPY supply_chain.shipment_raw FROM 'C:\Users\USER\Downloads\supply_chain_hormuz_crisis_700.csv' WITH(FORMAT CSV,HEADER TRUE,DELIMITER ',');

-- Record count
-- SELECT COUNT(*) AS total_records FROM supply_chain.shipment_raw;

-- Column count
-- SELECT COUNT(*) AS total_columns FROM information_schema.columns WHERE table_schema='supply_chain' AND table_name='shipment_raw';

-- Duplicate Shipment IDs
-- SELECT shipment_id,COUNT(*) AS occurrence_count FROM supply_chain.shipment_raw GROUP BY shipment_id HAVING COUNT(*)>1;

-- Duplicate Supplier IDs
-- SELECT supplier_id,COUNT(*) AS shipment_count FROM supply_chain.shipment_raw GROUP BY supplier_id HAVING COUNT(*)>1 ORDER BY shipment_count DESC;

-- NULL check
-- SELECT COUNT(*) AS null_count FROM supply_chain.shipment_raw WHERE shipment_id IS NULL OR supplier_id IS NULL OR country IS NULL OR product_type IS NULL;

-- Invalid numeric values
-- SELECT * FROM supply_chain.shipment_raw WHERE delay_probability NOT BETWEEN 0 AND 1 OR supplier_reliability NOT BETWEEN 0 AND 1;

-- Negative values
-- SELECT * FROM supply_chain.shipment_raw WHERE monthly_demand_tons<0 
-- OR shipment_volume_tons<0 OR historical_delay_days<0
-- OR fuel_price_usd<0 OR inventory_days<0 OR alternative_supplier_count<0 
-- OR transit_time_days<0 OR current_delay_days<0 OR freight_cost_usd<0 OR revenue_impact_usd<0;

-- Basic Data Quality Report
-- SELECT CASE WHEN COUNT(*)=700 THEN 'PASS' ELSE 'CHECK' END AS record_check,COUNT(*) 
-- AS total_records FROM supply_chain.shipment_raw;
