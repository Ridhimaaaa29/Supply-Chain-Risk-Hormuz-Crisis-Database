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

-- Task 2: Normalization, Keys & Constraints

-- CREATE TABLE supply_chain.suppliers(supplier_id VARCHAR(20) PRIMARY KEY);

-- CREATE TABLE supply_chain.products(product_id SERIAL PRIMARY KEY,product_type VARCHAR(100) NOT NULL UNIQUE);

-- CREATE TABLE supply_chain.shipments(
-- shipment_id VARCHAR(20) PRIMARY KEY,supplier_id VARCHAR(20) NOT NULL,product_id INTEGER NOT NULL,country VARCHAR(100) NOT NULL,
-- monthly_demand_tons INTEGER NOT NULL,shipment_volume_tons INTEGER NOT NULL,transit_time_days INTEGER NOT NULL,freight_cost_usd 
-- NUMERIC(15,2) NOT NULL,revenue_impact_usd NUMERIC(15,2) NOT NULL,disruption_event INTEGER NOT NULL,
-- FOREIGN KEY(supplier_id) REFERENCES supply_chain.suppliers(supplier_id),FOREIGN KEY(product_id) 
-- REFERENCES supply_chain.products(product_id), CHECK(monthly_demand_tons>=0),CHECK(shipment_volume_tons>0),CHECK(transit_time_days>=0),
-- CHECK(freight_cost_usd>=0),CHECK(revenue_impact_usd>=0),CHECK(disruption_event IN(0,1)));

-- CREATE TABLE supply_chain.shipment_risk(
-- shipment_id VARCHAR(20) PRIMARY KEY,route_risk_score NUMERIC(5,2) NOT NULL,historical_delay_days INTEGER NOT NULL,
-- fuel_price_usd NUMERIC(10,2) NOT NULL,political_risk_index NUMERIC(5,2) NOT NULL,
-- port_congestion_index NUMERIC(5,2) NOT NULL,delay_probability NUMERIC(5,2) NOT NULL,current_delay_days INTEGER NOT NULL,
-- FOREIGN KEY(shipment_id) REFERENCES supply_chain.shipments(shipment_id),
-- CHECK(route_risk_score>=0),CHECK(historical_delay_days>=0),CHECK(fuel_price_usd>=0),
-- CHECK(political_risk_index>=0),CHECK(port_congestion_index>=0),CHECK(delay_probability BETWEEN 0 AND 1),CHECK(current_delay_days>=0));

-- CREATE TABLE supply_chain.inventory(
-- shipment_id VARCHAR(20) PRIMARY KEY,inventory_days INTEGER NOT NULL,alternative_supplier_count INTEGER NOT NULL,
-- FOREIGN KEY(shipment_id) REFERENCES supply_chain.shipments(shipment_id),CHECK(inventory_days>=0),CHECK(alternative_supplier_count>=0));

-- INSERT INTO supply_chain.products(product_type) SELECT DISTINCT product_type FROM supply_chain.shipment_raw;
-- INSERT INTO supply_chain.suppliers(supplier_id) SELECT DISTINCT supplier_id FROM supply_chain.shipment_raw;

-- INSERT INTO supply_chain.shipments(shipment_id,supplier_id,product_id,country,monthly_demand_tons,shipment_volume_tons,
-- transit_time_days,freight_cost_usd,revenue_impact_usd,disruption_event)
-- SELECT r.shipment_id,r.supplier_id,p.product_id,r.country,r.monthly_demand_tons,r.shipment_volume_tons,
-- r.transit_time_days,r.freight_cost_usd,r.revenue_impact_usd,r.disruption_event
-- FROM supply_chain.shipment_raw r JOIN supply_chain.products p ON r.product_type=p.product_type 
-- WHERE r.revenue_impact_usd>=0;

-- INSERT INTO supply_chain.shipment_risk(shipment_id,route_risk_score,historical_delay_days,
-- fuel_price_usd,political_risk_index, port_congestion_index,delay_probability,current_delay_days)
-- SELECT r.shipment_id,r.route_risk_score,r.historical_delay_days,r.fuel_price_usd,
-- r.political_risk_index,r.port_congestion_index,r.delay_probability,r.current_delay_days
-- FROM supply_chain.shipment_raw r JOIN supply_chain.shipments s ON r.shipment_id=s.shipment_id;

-- INSERT INTO supply_chain.inventory(shipment_id,inventory_days,alternative_supplier_count)
-- SELECT r.shipment_id,r.inventory_days,r.alternative_supplier_count
-- FROM supply_chain.shipment_raw r JOIN supply_chain.shipments s ON r.shipment_id=s.shipment_id;

-- Task 3: DDL, DML & Transactions

-- DDL Demonstration
-- CREATE TABLE supply_chain.ddl_demo(id SERIAL PRIMARY KEY,name VARCHAR(50));
-- ALTER TABLE supply_chain.ddl_demo ADD COLUMN description VARCHAR(100);
-- TRUNCATE TABLE supply_chain.ddl_demo;
-- DROP TABLE supply_chain.ddl_demo;

-- ALTER
-- ALTER TABLE supply_chain.shipments ADD COLUMN IF NOT EXISTS shipment_status VARCHAR(20);
-- ALTER TABLE supply_chain.shipments ADD COLUMN IF NOT EXISTS risk_classification VARCHAR(20);

-- Update delayed shipments
-- UPDATE supply_chain.shipments s SET shipment_status=CASE WHEN r.current_delay_days=0 
-- THEN 'ON_TIME' WHEN r.current_delay_days<=5 THEN 'DELAYED' ELSE 'SEVERELY_DELAYED' END
-- FROM supply_chain.shipment_risk r WHERE s.shipment_id=r.shipment_id;

-- Update risk classification
-- UPDATE supply_chain.shipments s SET risk_classification=CASE WHEN r.route_risk_score>=80 
-- AND r.delay_probability>=0.70 AND r.current_delay_days>=10 AND i.inventory_days<=15 
-- THEN 'CRITICAL' WHEN r.route_risk_score>=60 AND r.delay_probability>=0.50 
-- AND r.current_delay_days>=5 THEN 'HIGH' WHEN r.route_risk_score>=40 
-- OR r.delay_probability>=0.30 THEN 'MEDIUM' ELSE 'LOW' END
-- FROM supply_chain.shipment_risk r JOIN supply_chain.inventory i 
-- ON r.shipment_id=i.shipment_id WHERE s.shipment_id=r.shipment_id;

-- Insert supplier
-- INSERT INTO supply_chain.suppliers(supplier_id) VALUES('SUP_TEST');

-- Insert shipment
-- INSERT INTO supply_chain.shipments(shipment_id,supplier_id,product_id,country,monthly_demand_tons,
-- shipment_volume_tons,transit_time_days,freight_cost_usd,revenue_impact_usd,disruption_event,shipment_status,risk_classification)
-- VALUES('SHP_TEST','SUP_TEST',1,'India',1000,500,10,5000.00,10000.00,0,'ON_TIME','LOW');

-- Update freight cost
-- UPDATE supply_chain.shipments SET freight_cost_usd=ROUND(freight_cost_usd*1.05,2) WHERE risk_classification='CRITICAL';

-- UPSERT
-- INSERT INTO supply_chain.suppliers(supplier_id) VALUES('SUP_TEST') 
-- ON CONFLICT(supplier_id) DO UPDATE SET supplier_id=EXCLUDED.supplier_id;

-- Delete test records
-- DELETE FROM supply_chain.shipments WHERE shipment_id='SHP_TEST';
-- DELETE FROM supply_chain.suppliers WHERE supplier_id='SUP_TEST';

-- Successful Transaction
-- BEGIN;
-- UPDATE supply_chain.shipments SET shipment_status='DELAYED' WHERE shipment_id='SHP0001';
-- UPDATE supply_chain.shipment_risk SET current_delay_days=current_delay_days+1 WHERE shipment_id='SHP0001';
-- SELECT s.shipment_id,s.shipment_status,r.current_delay_days FROM supply_chain.shipments s 
-- JOIN supply_chain.shipment_risk r ON s.shipment_id=r.shipment_id WHERE s.shipment_id='SHP0001';
-- COMMIT;

-- Failed Transaction
-- BEGIN;
-- UPDATE supply_chain.shipments SET shipment_volume_tons=-100 WHERE shipment_id='SHP0001';
-- ROLLBACK;

-- Verify rollback
-- SELECT shipment_id,shipment_volume_tons FROM supply_chain.shipments WHERE shipment_id='SHP0001';

-- ACID
-- Atomicity: All transaction operations succeed together or are rolled back.
-- Consistency: Constraints keep the database in a valid state.
-- Isolation: Transactions do not expose uncommitted changes to other transactions.
-- Durability: Committed changes remain stored after completion.

-- -- Task 4: Joins & Relational Analysis

-- -- INNER JOIN

-- SELECT s.shipment_id,s.supplier_id,s.country
-- FROM supply_chain.shipments s INNER JOIN supply_chain.suppliers sup ON s.supplier_id=sup.supplier_id;

-- -- LEFT JOIN

-- SELECT s.shipment_id,s.supplier_id,sup.supplier_id AS supplier_record
-- FROM supply_chain.shipments s LEFT JOIN supply_chain.suppliers sup ON s.supplier_id=sup.supplier_id LIMIT 10;

-- -- RIGHT JOIN

-- SELECT s.shipment_id,s.supplier_id,sup.supplier_id AS supplier_record
-- FROM supply_chain.shipments s RIGHT JOIN supply_chain.suppliers sup ON s.supplier_id=sup.supplier_id ORDER BY sup.supplier_id;

-- -- FULL OUTER JOIN

-- SELECT s.shipment_id,s.supplier_id AS shipment_supplier,sup.supplier_id AS supplier_record
-- FROM supply_chain.shipments s FULL OUTER JOIN supply_chain.suppliers sup ON s.supplier_id=sup.supplier_id LIMIT 20;

-- -- CROSS JOIN

-- SELECT sup.supplier_id,p.product_type
-- FROM supply_chain.suppliers sup CROSS JOIN supply_chain.products p LIMIT 20;

-- -- Supplier Shipment Report

-- SELECT s.supplier_id,s.country,COUNT(s.shipment_id) AS shipment_count,SUM(s.shipment_volume_tons) AS shipment_volume,ROUND(AVG(r.current_delay_days),2) AS average_delay,ROUND(AVG(sr.supplier_reliability),2) AS supplier_reliability,ROUND(SUM(s.freight_cost_usd),2) AS total_freight_cost,ROUND(SUM(s.revenue_impact_usd),2) AS revenue_impact
-- FROM supply_chain.shipments s JOIN supply_chain.shipment_risk r ON s.shipment_id=r.shipment_id JOIN supply_chain.shipment_raw sr ON s.shipment_id=sr.shipment_id
-- GROUP BY s.supplier_id,s.country ORDER BY shipment_volume DESC;

-- -- Product Performance Report

-- SELECT p.product_type AS product,COUNT(s.shipment_id) AS shipment_count,SUM(s.monthly_demand_tons) 
-- AS total_demand,SUM(s.shipment_volume_tons) AS total_shipment_volume,ROUND(AVG(s.freight_cost_usd),2) 
-- AS average_freight_cost,ROUND(AVG(r.current_delay_days),2) AS average_delay,SUM(CASE WHEN s.disruption_event=1 THEN 1 ELSE 0 END) 
-- AS disruption_count FROM supply_chain.products p JOIN supply_chain.shipments s 
-- ON p.product_id=s.product_id JOIN supply_chain.shipment_risk r ON s.shipment_id=r.shipment_id
-- GROUP BY p.product_id,p.product_type ORDER BY total_shipment_volume DESC;

-- -- Critical Shipment Report

-- SELECT s.shipment_id,s.supplier_id AS supplier,s.country,p.product_type AS product,s.shipment_volume_tons,
-- r.route_risk_score,r.political_risk_index,r.port_congestion_index,r.delay_probability,r.current_delay_days,
-- i.inventory_days,s.freight_cost_usd,s.revenue_impact_usd
-- FROM supply_chain.shipments s JOIN supply_chain.suppliers sup ON s.supplier_id=sup.supplier_id 
-- JOIN supply_chain.products p ON s.product_id=p.product_id JOIN supply_chain.shipment_risk r 
-- ON s.shipment_id=r.shipment_id JOIN supply_chain.inventory i ON s.shipment_id=i.shipment_id
-- ORDER BY r.route_risk_score DESC;

-- Task 5: Aggregate Functions & Business Analysis

-- Q1. Highest shipment volume supplier

-- SELECT supplier_id,SUM(shipment_volume_tons) AS total_volume
-- FROM supply_chain.shipments GROUP BY supplier_id ORDER BY total_volume DESC LIMIT 1;
-- SELECT MIN(shipment_volume_tons) AS minimum_volume,MAX(shipment_volume_tons) AS maximum_volume
-- FROM supply_chain.shipments;

-- Q2. Highest revenue impact supplier

-- SELECT supplier_id,SUM(revenue_impact_usd) AS total_revenue_impact
-- FROM supply_chain.shipments GROUP BY supplier_id ORDER BY total_revenue_impact DESC LIMIT 1;

-- Q3. Highest average delay supplier

-- SELECT s.supplier_id,ROUND(AVG(r.current_delay_days),2) AS average_delay
-- FROM supply_chain.shipments s JOIN supply_chain.shipment_risk r 
-- ON s.shipment_id=r.shipment_id GROUP BY s.supplier_id ORDER BY average_delay DESC LIMIT 1;

-- Q4. Suppliers below average reliability

-- SELECT supplier_id,ROUND(AVG(supplier_reliability),2) AS average_reliability
-- FROM supply_chain.shipment_raw GROUP BY supplier_id 
-- HAVING AVG(supplier_reliability)<(SELECT AVG(supplier_reliability) 
-- FROM supply_chain.shipment_raw) ORDER BY average_reliability;

-- Q5. Suppliers with more than 5 shipments

-- SELECT supplier_id,COUNT(*) AS shipment_count
-- FROM supply_chain.shipments GROUP BY supplier_id HAVING COUNT(*)>5 ORDER BY shipment_count DESC;

-- -- Q6. Country with highest average route risk

-- SELECT s.country,ROUND(AVG(r.route_risk_score),2) AS average_route_risk
-- FROM supply_chain.shipments s JOIN supply_chain.shipment_risk r ON s.shipment_id=r.shipment_id GROUP BY s.country ORDER BY average_route_risk DESC LIMIT 1;

-- -- Q7. Country with highest political risk

-- SELECT s.country,ROUND(AVG(r.political_risk_index),2) AS average_political_risk
-- FROM supply_chain.shipments s JOIN supply_chain.shipment_risk r ON s.shipment_id=r.shipment_id GROUP BY s.country ORDER BY average_political_risk DESC LIMIT 1;

-- -- Q8. Country with highest total revenue impact

-- SELECT country,SUM(revenue_impact_usd) AS total_revenue_impact
-- FROM supply_chain.shipments GROUP BY country ORDER BY total_revenue_impact DESC LIMIT 1;

-- -- Q9. Average delay by country

-- SELECT s.country,ROUND(AVG(r.current_delay_days),2) AS average_delay
-- FROM supply_chain.shipments s JOIN supply_chain.shipment_risk r ON s.shipment_id=r.shipment_id GROUP BY s.country ORDER BY average_delay DESC;

-- -- Q10. Product with highest demand

-- SELECT p.product_type,SUM(s.monthly_demand_tons) AS total_demand
-- FROM supply_chain.shipments s JOIN supply_chain.products p ON s.product_id=p.product_id GROUP BY p.product_type ORDER BY total_demand DESC LIMIT 1;

-- -- Q11. Product with highest freight cost

-- SELECT p.product_type,SUM(s.freight_cost_usd) AS total_freight_cost
-- FROM supply_chain.shipments s JOIN supply_chain.products p ON s.product_id=p.product_id GROUP BY p.product_type ORDER BY total_freight_cost DESC LIMIT 1;

-- -- Q12. Product with highest disruptions

-- SELECT p.product_type,COUNT(*) AS disruption_count
-- FROM supply_chain.shipments s JOIN supply_chain.products p ON s.product_id=p.product_id WHERE s.disruption_event=1 GROUP BY p.product_type ORDER BY disruption_count DESC LIMIT 1;

-- -- Q13. Percentage of disrupted shipments

-- SELECT ROUND(SUM(CASE WHEN disruption_event=1 THEN 1 ELSE 0 END)::NUMERIC/COUNT(*)*100,2) AS disruption_percentage
-- FROM supply_chain.shipments;

-- -- Q14. Total revenue impact

-- SELECT ROUND(SUM(revenue_impact_usd),2) AS total_revenue_impact
-- FROM supply_chain.shipments;

-- -- Q15. Average shipment delay

-- SELECT ROUND(AVG(current_delay_days),2) AS average_shipment_delay
-- FROM supply_chain.shipment_risk;

-- Task 6 — Subqueries, Casting & Advanced SQL

-- Q1. Shipments above average freight cost

-- SELECT
--     shipment_id,
--     freight_cost_usd
-- FROM supply_chain.shipments
-- WHERE freight_cost_usd > (
--     SELECT AVG(freight_cost_usd)
--     FROM supply_chain.shipments
-- )
-- ORDER BY freight_cost_usd DESC;

-- Q2. shipments whose current delay is above the overall average.

-- SELECT s.shipment_id,s.supplier_id,r.current_delay_days
-- FROM supply_chain.shipments s JOIN supply_chain.shipment_risk r ON s.shipment_id=r.shipment_id
-- WHERE r.current_delay_days>(SELECT AVG(current_delay_days) FROM supply_chain.shipment_risk)
-- ORDER BY r.current_delay_days DESC;

-- Q3. Find suppliers whose reliability is below the overall average.

-- SELECT supplier_id,
-- ROUND(AVG(supplier_reliability),2) AS average_reliability
-- FROM supply_chain.shipment_raw GROUP BY supplier_id
-- HAVING AVG(supplier_reliability)<(SELECT AVG(supplier_reliability)
-- FROM supply_chain.shipment_raw) ORDER BY average_reliability;

-- Q4. Countries whose average route risk is above global average

-- SELECT s.country,
-- ROUND(AVG(r.route_risk_score),2) AS average_route_risk
-- FROM supply_chain.shipments s JOIN supply_chain.shipment_risk r
-- ON s.shipment_id=r.shipment_id GROUP BY s.country
-- HAVING AVG(r.route_risk_score)>(SELECT AVG(route_risk_score)
-- FROM supply_chain.shipment_risk) ORDER BY average_route_risk DESC;

-- Q5. Find shipments with the maximum revenue impact.

-- SELECT shipment_id,revenue_impact_usd
-- FROM supply_chain.shipments
-- WHERE revenue_impact_usd=(SELECT MAX(revenue_impact_usd) FROM supply_chain.shipments);

-- Q6. Second-highest freight cost

-- SELECT shipment_id, freight_cost_usd FROM supply_chain.shipments
-- WHERE freight_cost_usd=(SELECT MAX(freight_cost_usd) FROM supply_chain.shipments
-- WHERE freight_cost_usd<(SELECT MAX(freight_cost_usd) FROM supply_chain.shipments));

-- Q7. Revenue impact higher than country's average

-- SELECT s1.shipment_id, s1.country, s1.revenue_impact_usd
-- FROM supply_chain.shipments s1 WHERE s1.revenue_impact_usd>(
-- SELECT AVG(s2.revenue_impact_usd) FROM supply_chain.shipments s2
-- WHERE s2.country=s1.country) ORDER BY s1.revenue_impact_usd DESC;

-- Q8. Freight cost higher than product's average

-- SELECT s1.shipment_id,p.product_type,s1.freight_cost_usd
-- FROM supply_chain.shipments s1 JOIN supply_chain.products p ON s1.product_id=p.product_id
-- WHERE s1.freight_cost_usd>(SELECT AVG(s2.freight_cost_usd) FROM supply_chain.shipments s2 WHERE s2.product_id=s1.product_id)
-- ORDER BY s1.freight_cost_usd DESC;

-- Q9. Highest-risk shipment for each country

-- SELECT s1.shipment_id,s1.country,r1.route_risk_score
-- FROM supply_chain.shipments s1 JOIN supply_chain.shipment_risk r1 ON s1.shipment_id=r1.shipment_id
-- WHERE r1.route_risk_score=(SELECT MAX(r2.route_risk_score) 
-- FROM supply_chain.shipments s2 JOIN supply_chain.shipment_risk r2 ON s2.shipment_id=r2.shipment_id WHERE s2.country=s1.country)
-- ORDER BY s1.country,r1.route_risk_score DESC;

-- Q10. Suppliers whose average delay > overall average delay

-- SELECT s.supplier_id,ROUND(AVG(r.current_delay_days),2) AS average_delay
-- FROM supply_chain.shipments s JOIN supply_chain.shipment_risk r ON s.shipment_id=r.shipment_id
-- GROUP BY s.supplier_id
-- HAVING AVG(r.current_delay_days)>(SELECT AVG(current_delay_days) FROM supply_chain.shipment_risk)
-- ORDER BY average_delay DESC;

-- Casting 1: CAST(value AS datatype)

-- SELECT shipment_id,CAST(freight_cost_usd AS NUMERIC(12,2)) AS freight_cost
-- FROM supply_chain.shipments LIMIT 10;

-- Casting 2: value::datatype

-- SELECT shipment_id,freight_cost_usd::NUMERIC(12,2) AS freight_cost
-- FROM supply_chain.shipments LIMIT 10;

-- Percentage calculation

-- SELECT shipment_id,ROUND(delay_probability::NUMERIC*100,2) AS delay_probability_percentage
-- FROM supply_chain.shipment_risk ORDER BY delay_probability_percentage DESC;

-- Calculated value converted to integer

-- SELECT shipment_id,CAST((shipment_volume_tons::NUMERIC/monthly_demand_tons)*100 AS INTEGER) AS volume_percentage
-- FROM supply_chain.shipments WHERE monthly_demand_tons>0;