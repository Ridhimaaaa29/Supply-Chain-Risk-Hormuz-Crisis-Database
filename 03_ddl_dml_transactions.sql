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
