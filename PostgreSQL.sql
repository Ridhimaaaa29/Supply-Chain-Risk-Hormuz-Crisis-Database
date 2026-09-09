-- Task 1 : Database Design & Core SQL

-- CREATE SCHEMA supply_chain;

-- CREATE TABLE supply_chain.shipment_raw (
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
-- revenue_impact_usd NUMERIC(15,2),
-- disruption_event INTEGER
-- );

-- COPY supply_chain.shipment_raw
-- FROM '"C:\Users\USER\Downloads\supply_chain_hormuz_crisis_700.csv"'
-- WITH (
-- FORMAT CSV,
-- HEADER TRUE,
-- DELIMITER ','
-- );

-- SELECT COUNT(*) AS total_records
-- FROM supply_chain.shipment_raw;

-- SELECT COUNT(*) AS total_columns
-- FROM information_schema.columns
-- WHERE table_schema = 'supply_chain'
-- AND table_name = 'shipment_raw';

-- SELECT
-- shipment_id,
-- COUNT(*) AS occurrence_count
-- FROM supply_chain.shipment_raw
-- GROUP BY shipment_id
-- HAVING COUNT(*) > 1;

-- SELECT
-- supplier_id,
-- COUNT(*) AS shipment_count
-- FROM supply_chain.shipment_raw
-- GROUP BY supplier_id
-- HAVING COUNT(*) > 1
-- ORDER BY shipment_count DESC;

-- SELECT COUNT(DISTINCT supplier_id) AS unique_suppliers
-- FROM supply_chain.shipment_raw;

-- SELECT *
-- FROM supply_chain.shipment_raw
-- WHERE delay_probability NOT BETWEEN 0 AND 1;

-- SELECT *
-- FROM supply_chain.shipment_raw
-- WHERE supplier_reliability NOT BETWEEN 0 AND 1;

-- SELECT *
-- FROM supply_chain.shipment_raw
-- WHERE monthly_demand_tons < 0
-- OR shipment_volume_tons < 0
-- OR historical_delay_days < 0
-- OR fuel_price_usd < 0
-- OR inventory_days < 0
-- OR alternative_supplier_count < 0
-- OR transit_time_days < 0
-- OR current_delay_days < 0
-- OR freight_cost_usd < 0
-- OR revenue_impact_usd < 0;

-- Task 2 : Normalization, Keys & Constraints 

-- CREATE TABLE supply_chain.suppliers (
--     supplier_id VARCHAR(20) PRIMARY KEY,
--     country VARCHAR(100) NOT NULL
-- );

-- INSERT INTO supply_chain.suppliers (
--     supplier_id,
--     country
-- )
-- SELECT DISTINCT
--     supplier_id,
--     country
-- FROM supply_chain.shipment_raw;

-- SELECT
--     supplier_id,
--     COUNT(DISTINCT country) AS country_count,
--     STRING_AGG(DISTINCT country, ', ') AS countries
-- FROM supply_chain.shipment_raw
-- GROUP BY supplier_id
-- HAVING COUNT(DISTINCT country) > 1
-- ORDER BY supplier_id;

-- SELECT DISTINCT
--     supplier_id,
--     country
-- FROM supply_chain.shipment_raw
-- WHERE supplier_id = 'SUP019';

-- SELECT COUNT(*)
-- FROM supply_chain.suppliers;

-- DROP TABLE supply_chain.suppliers;

-- CREATE TABLE supply_chain.suppliers (
--     supplier_id VARCHAR(20) PRIMARY KEY
-- );

-- CREATE TABLE supply_chain.products (
--     product_id SERIAL PRIMARY KEY,
--     product_type VARCHAR(100) NOT NULL UNIQUE
-- );

-- INSERT INTO supply_chain.products (product_type)
-- SELECT DISTINCT product_type
-- FROM supply_chain.shipment_raw;

-- SELECT *
-- FROM supply_chain.products
-- ORDER BY product_id;

-- SELECT COUNT(*)
-- FROM supply_chain.products;

-- INSERT INTO supply_chain.suppliers (supplier_id)
-- SELECT DISTINCT supplier_id
-- FROM supply_chain.shipment_raw;

-- SELECT COUNT(*)
-- FROM supply_chain.suppliers;

-- SELECT *
-- FROM supply_chain.suppliers
-- ORDER BY supplier_id;
-- CREATE TABLE supply_chain.shipments (
--     shipment_id VARCHAR(20) PRIMARY KEY,
--     supplier_id VARCHAR(20) NOT NULL,
--     product_id INTEGER NOT NULL,
--     country VARCHAR(100) NOT NULL,
--     monthly_demand_tons INTEGER NOT NULL,
--     shipment_volume_tons INTEGER NOT NULL,
--     transit_time_days INTEGER NOT NULL,
--     freight_cost_usd NUMERIC(15,2) NOT NULL,
--     revenue_impact_usd NUMERIC(15,2) NOT NULL,
--     disruption_event INTEGER NOT NULL,
--     CONSTRAINT fk_shipment_supplier
--         FOREIGN KEY (supplier_id)
--         REFERENCES supply_chain.suppliers(supplier_id),
--     CONSTRAINT fk_shipment_product
--         FOREIGN KEY (product_id)
--         REFERENCES supply_chain.products(product_id),
--     CONSTRAINT chk_monthly_demand
--         CHECK (monthly_demand_tons >= 0),
--     CONSTRAINT chk_shipment_volume
--         CHECK (shipment_volume_tons > 0),
--     CONSTRAINT chk_transit_time
--         CHECK (transit_time_days >= 0),
--     CONSTRAINT chk_freight_cost
--         CHECK (freight_cost_usd >= 0),
--     CONSTRAINT chk_revenue_impact
--         CHECK (revenue_impact_usd >= 0),
--     CONSTRAINT chk_disruption_event
--         CHECK (disruption_event IN (0, 1))
-- );

-- INSERT INTO supply_chain.shipments (
--     shipment_id,
--     supplier_id,
--     product_id,
--     country,
--     monthly_demand_tons,
--     shipment_volume_tons,
--     transit_time_days,
--     freight_cost_usd,
--     revenue_impact_usd,
--     disruption_event
-- )
-- SELECT
--     r.shipment_id,
--     r.supplier_id,
--     p.product_id,
--     r.country,
--     r.monthly_demand_tons,
--     r.shipment_volume_tons,
--     r.transit_time_days,
--     r.freight_cost_usd,
--     r.revenue_impact_usd,
--     r.disruption_event
-- FROM supply_chain.shipment_raw r
-- JOIN supply_chain.products p
--     ON r.product_type = p.product_type
-- WHERE r.revenue_impact_usd >= 0;

-- SELECT COUNT(*) AS shipment_count
-- FROM supply_chain.shipments;

-- SELECT
--     s.shipment_id,
--     s.supplier_id,
--     s.country,
--     p.product_type,
--     s.shipment_volume_tons
-- FROM supply_chain.shipments s
-- JOIN supply_chain.products p
--     ON s.product_id = p.product_id
-- LIMIT 10;


-- CREATE TABLE supply_chain.shipment_risk (
--     shipment_id VARCHAR(20) PRIMARY KEY,
--     route_risk_score NUMERIC(5,2) NOT NULL,
--     historical_delay_days INTEGER NOT NULL,
--     fuel_price_usd NUMERIC(10,2) NOT NULL,
--     political_risk_index NUMERIC(5,2) NOT NULL,
--     port_congestion_index NUMERIC(5,2) NOT NULL,
--     delay_probability NUMERIC(5,2) NOT NULL,
--     current_delay_days INTEGER NOT NULL,

--     CONSTRAINT fk_risk_shipment
--         FOREIGN KEY (shipment_id)
--         REFERENCES supply_chain.shipments(shipment_id),
--     CONSTRAINT chk_route_risk
--         CHECK (route_risk_score >= 0),
--     CONSTRAINT chk_historical_delay
--         CHECK (historical_delay_days >= 0),
--     CONSTRAINT chk_fuel_price
--         CHECK (fuel_price_usd >= 0),
--     CONSTRAINT chk_political_risk
--         CHECK (political_risk_index >= 0),
--     CONSTRAINT chk_port_congestion
--         CHECK (port_congestion_index >= 0),
--     CONSTRAINT chk_delay_probability
--         CHECK (delay_probability BETWEEN 0 AND 1),
--     CONSTRAINT chk_current_delay
--         CHECK (current_delay_days >= 0)
-- );

-- INSERT INTO supply_chain.shipment_risk (
--     shipment_id,
--     route_risk_score,
--     historical_delay_days,
--     fuel_price_usd,
--     political_risk_index,
--     port_congestion_index,
--     delay_probability,
--     current_delay_days
-- )
-- SELECT
--     r.shipment_id,
--     r.route_risk_score,
--     r.historical_delay_days,
--     r.fuel_price_usd,
--     r.political_risk_index,
--     r.port_congestion_index,
--     r.delay_probability,
--     r.current_delay_days
-- FROM supply_chain.shipment_raw r
-- JOIN supply_chain.shipments s
--     ON r.shipment_id = s.shipment_id;

-- CREATE TABLE supply_chain.inventory (
--     shipment_id VARCHAR(20) PRIMARY KEY,
--     inventory_days INTEGER NOT NULL,
--     alternative_supplier_count INTEGER NOT NULL,

--     CONSTRAINT fk_inventory_shipment
--         FOREIGN KEY (shipment_id)
--         REFERENCES supply_chain.shipments(shipment_id),

--     CONSTRAINT chk_inventory_days
--         CHECK (inventory_days >= 0),

--     CONSTRAINT chk_alternative_suppliers
--         CHECK (alternative_supplier_count >= 0)
-- );

-- INSERT INTO supply_chain.inventory (
--     shipment_id,
--     inventory_days,
--     alternative_supplier_count
-- )
-- SELECT
--     r.shipment_id,
--     r.inventory_days,
--     r.alternative_supplier_count
-- FROM supply_chain.shipment_raw r
-- JOIN supply_chain.shipments s
--     ON r.shipment_id = s.shipment_id;

-- SELECT 'suppliers' AS table_name, COUNT(*) AS records
-- FROM supply_chain.suppliers
-- UNION ALL
-- SELECT 'products', COUNT(*)
-- FROM supply_chain.products
-- UNION ALL
-- SELECT 'shipments', COUNT(*)
-- FROM supply_chain.shipments
-- UNION ALL
-- SELECT 'shipment_risk', COUNT(*)
-- FROM supply_chain.shipment_risk
-- UNION ALL
-- SELECT 'inventory', COUNT(*)
-- FROM supply_chain.inventory;

-- SELECT
--     s.shipment_id,
--     s.supplier_id,
--     s.country,
--     p.product_type,
--     r.route_risk_score,
--     r.delay_probability,
--     i.inventory_days,
--     s.freight_cost_usd
-- FROM supply_chain.shipments s
-- JOIN supply_chain.suppliers sup
--     ON s.supplier_id = sup.supplier_id
-- JOIN supply_chain.products p
--     ON s.product_id = p.product_id
-- JOIN supply_chain.shipment_risk r
--     ON s.shipment_id = r.shipment_id
-- JOIN supply_chain.inventory i
--     ON s.shipment_id = i.shipment_id
-- LIMIT 10;


-- Task 3 : DDL, DML & Transactions

-- ALTER TABLE supply_chain.shipments
-- ADD COLUMN IF NOT EXISTS shipment_status VARCHAR(20);

-- ALTER TABLE supply_chain.shipments
-- ADD COLUMN IF NOT EXISTS risk_classification VARCHAR(20);

-- SELECT column_name, data_type
-- FROM information_schema.columns
-- WHERE table_schema = 'supply_chain'
--   AND table_name = 'shipments'
-- ORDER BY ordinal_position;

-- UPDATE supply_chain.shipments s
-- SET shipment_status =
--     CASE
--         WHEN r.current_delay_days = 0 THEN 'ON_TIME'
--         WHEN r.current_delay_days <= 5 THEN 'DELAYED'
--         ELSE 'SEVERELY_DELAYED'
--     END
-- FROM supply_chain.shipment_risk r
-- WHERE s.shipment_id = r.shipment_id;

-- SELECT
--     shipment_status,
--     COUNT(*) AS shipment_count
-- FROM supply_chain.shipments
-- GROUP BY shipment_status
-- ORDER BY shipment_count DESC;

-- UPDATE supply_chain.shipments s
-- SET risk_classification =
--     CASE
--         WHEN r.route_risk_score >= 80
--              AND r.delay_probability >= 0.70
--              AND r.current_delay_days >= 10
--              AND i.inventory_days <= 15
--             THEN 'CRITICAL'

--         WHEN r.route_risk_score >= 60
--              AND r.delay_probability >= 0.50
--              AND r.current_delay_days >= 5
--             THEN 'HIGH'

--         WHEN r.route_risk_score >= 40
--              OR r.delay_probability >= 0.30
--             THEN 'MEDIUM'

--         ELSE 'LOW'
--     END
-- FROM supply_chain.shipment_risk r
-- JOIN supply_chain.inventory i
--     ON r.shipment_id = i.shipment_id
-- WHERE s.shipment_id = r.shipment_id;

-- SELECT
--     risk_classification,
--     COUNT(*) AS shipment_count
-- FROM supply_chain.shipments
-- GROUP BY risk_classification
-- ORDER BY shipment_count DESC;

-- SELECT
--     s.shipment_id,
--     r.route_risk_score,
--     r.delay_probability,
--     r.current_delay_days,
--     i.inventory_days,
--     s.risk_classification
-- FROM supply_chain.shipments s
-- JOIN supply_chain.shipment_risk r
--     ON s.shipment_id = r.shipment_id
-- JOIN supply_chain.inventory i
--     ON s.shipment_id = i.shipment_id
-- ORDER BY
--     CASE s.risk_classification
--         WHEN 'CRITICAL' THEN 1
--         WHEN 'HIGH' THEN 2
--         WHEN 'MEDIUM' THEN 3
--         ELSE 4
--     END
-- LIMIT 10;

-- INSERT INTO supply_chain.suppliers (supplier_id)
-- VALUES ('SUP_TEST');

-- SELECT *
-- FROM supply_chain.products
-- ORDER BY product_id;

-- INSERT INTO supply_chain.shipments (
--     shipment_id,
--     supplier_id,
--     product_id,
--     country,
--     monthly_demand_tons,
--     shipment_volume_tons,
--     transit_time_days,
--     freight_cost_usd,
--     revenue_impact_usd,
--     disruption_event,
--     shipment_status,
--     risk_classification
-- )
-- VALUES (
--     'SHP_TEST',
--     'SUP_TEST',
--     1,
--     'India',
--     1000,
--     500,
--     10,
--     5000.00,
--     10000.00,
--     0,
--     'ON_TIME',
--     'LOW'
-- );

-- UPDATE supply_chain.shipments
-- SET freight_cost_usd = ROUND(freight_cost_usd * 1.05, 2)
-- WHERE risk_classification = 'CRITICAL';

-- SELECT
--     shipment_id,
--     freight_cost_usd,
--     risk_classification
-- FROM supply_chain.shipments
-- WHERE risk_classification = 'CRITICAL'
-- LIMIT 10;

-- INSERT INTO supply_chain.suppliers (supplier_id)
-- VALUES ('SUP_TEST')
-- ON CONFLICT (supplier_id)
-- DO UPDATE
-- SET supplier_id = EXCLUDED.supplier_id;

-- DELETE FROM supply_chain.shipments
-- WHERE shipment_id = 'SHP_TEST';

-- DELETE FROM supply_chain.suppliers
-- WHERE supplier_id = 'SUP_TEST';

-- SELECT *
-- FROM supply_chain.shipments
-- WHERE shipment_id = 'SHP_TEST';

-- SELECT *
-- FROM supply_chain.suppliers
-- WHERE supplier_id = 'SUP_TEST';

-- SELECT shipment_id, shipment_status
-- FROM supply_chain.shipments
-- LIMIT 1;

-- BEGIN;
-- UPDATE supply_chain.shipments
-- SET shipment_status = 'DELAYED'
-- WHERE shipment_id = 'SHP0001';
-- SELECT shipment_id, shipment_status
-- FROM supply_chain.shipments
-- WHERE shipment_id = 'SHP0001';
-- COMMIT;

-- BEGIN;
-- UPDATE supply_chain.shipments
-- SET shipment_volume_tons = -100
-- WHERE shipment_id = 'SHP0001';

-- ROLLBACK

-- SELECT shipment_id, shipment_volume_tons
-- FROM supply_chain.shipments
-- WHERE shipment_id = 'SHP0001';
