-- Task 8: Functions, Stored Procedures & Triggers

-- A. Function — Risk Classification

-- CREATE OR REPLACE FUNCTION supply_chain.get_risk_classification(
-- p_route_risk NUMERIC, p_delay_probability NUMERIC,
-- p_current_delay INTEGER, p_inventory_days INTEGER)
-- RETURNS VARCHAR 
-- LANGUAGE plpgsql 
-- AS $$ BEGIN
-- IF p_route_risk>=80 AND p_delay_probability>=0.70 AND p_current_delay>=10 AND p_inventory_days<=15 THEN
-- RETURN 'CRITICAL';
-- ELSIF p_route_risk>=60 AND p_delay_probability>=0.50 AND p_current_delay>=5 THEN
-- RETURN 'HIGH';
-- ELSIF p_route_risk>=40 OR p_delay_probability>=0.30 THEN
-- RETURN 'MEDIUM';
-- ELSE
-- RETURN 'LOW';
-- END IF;
-- END;
-- $$;

-- SELECT r.shipment_id,
-- supply_chain.get_risk_classification(r.route_risk_score,r.delay_probability,r.current_delay_days,i.inventory_days) AS risk_classification
-- FROM supply_chain.shipment_risk r
-- JOIN supply_chain.inventory i ON r.shipment_id=i.shipment_id;

-- B. Function — Freight Risk Score

-- CREATE OR REPLACE FUNCTION supply_chain.calculate_freight_risk(
-- p_shipment_volume NUMERIC, p_fuel_price NUMERIC, p_route_risk NUMERIC)
-- RETURNS NUMERIC
-- LANGUAGE plpgsql AS $$
-- BEGIN
-- RETURN ROUND((p_shipment_volume*p_fuel_price*p_route_risk)/100,2);
-- END;
-- $$;

-- SELECT s.shipment_id, s.shipment_volume_tons, r.fuel_price_usd, r.route_risk_score,
-- supply_chain.calculate_freight_risk(s.shipment_volume_tons,r.fuel_price_usd,r.route_risk_score) AS freight_risk_score
-- FROM supply_chain.shipments s JOIN supply_chain.shipment_risk r ON s.shipment_id=r.shipment_id
-- ORDER BY freight_risk_score DESC;

-- C. Stored Procedure

-- CREATE OR REPLACE PROCEDURE supply_chain.update_risk_classification(p_shipment_id VARCHAR)
-- LANGUAGE plpgsql
-- AS $$
-- DECLARE
-- v_risk VARCHAR;
-- BEGIN
-- SELECT supply_chain.get_risk_classification(r.route_risk_score,r.delay_probability,r.current_delay_days,i.inventory_days)
-- INTO v_risk
-- FROM supply_chain.shipment_risk r
-- JOIN supply_chain.inventory i ON r.shipment_id=i.shipment_id
-- WHERE r.shipment_id=p_shipment_id;

-- UPDATE supply_chain.shipments
-- SET risk_classification=v_risk
-- WHERE shipment_id=p_shipment_id;
-- END;
-- $$;

-- CALL supply_chain.update_risk_classification('SHP0001');

-- SELECT shipment_id,risk_classification
-- FROM supply_chain.shipments
-- WHERE shipment_id='SHP0001';

-- D. Audit Trigger

-- CREATE TABLE supply_chain.shipment_audit(
-- audit_id SERIAL PRIMARY KEY,
-- shipment_id VARCHAR(20),
-- old_value TEXT,
-- new_value TEXT,
-- operation VARCHAR(20),
-- changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
-- );

-- CREATE OR REPLACE FUNCTION supply_chain.audit_shipment_update()
-- RETURNS TRIGGER
-- LANGUAGE plpgsql
-- AS $$
-- BEGIN
-- INSERT INTO supply_chain.shipment_audit(shipment_id,old_value,new_value,operation)
-- VALUES(OLD.shipment_id,OLD.shipment_volume_tons::TEXT,NEW.shipment_volume_tons::TEXT,TG_OP);
-- RETURN NEW;
-- END;
-- $$;
-- CREATE TRIGGER trg_audit_shipment_update
-- AFTER UPDATE OF shipment_volume_tons
-- ON supply_chain.shipments
-- FOR EACH ROW
-- EXECUTE FUNCTION supply_chain.audit_shipment_update();

-- UPDATE supply_chain.shipments
-- SET shipment_volume_tons=shipment_volume_tons+10
-- WHERE shipment_id='SHP0001';

-- SELECT *
-- FROM supply_chain.shipment_audit
-- ORDER BY changed_at DESC;

-- E. Validation Trigger

-- CREATE OR REPLACE FUNCTION supply_chain.validate_shipment()
-- RETURNS TRIGGER
-- LANGUAGE plpgsql
-- AS $$
-- BEGIN
-- IF NEW.shipment_volume_tons<0 THEN
-- RAISE EXCEPTION 'Shipment volume cannot be negative';
-- END IF;

-- IF NEW.freight_cost_usd<0 THEN
-- RAISE EXCEPTION 'Freight cost cannot be negative';
-- END IF;

-- RETURN NEW;
-- END;
-- $$;

-- CREATE OR REPLACE FUNCTION supply_chain.validate_shipment_risk()
-- RETURNS TRIGGER
-- LANGUAGE plpgsql
-- AS $$
-- BEGIN
-- IF NEW.delay_probability NOT BETWEEN 0 AND 1 THEN
-- RAISE EXCEPTION 'Delay probability must be between 0 and 1';
-- END IF;

-- RETURN NEW;
-- END;
-- $$;

-- CREATE TRIGGER trg_validate_shipment
-- BEFORE INSERT OR UPDATE ON supply_chain.shipments
-- FOR EACH ROW
-- EXECUTE FUNCTION supply_chain.validate_shipment();

-- CREATE TRIGGER trg_validate_shipment_risk
-- BEFORE INSERT OR UPDATE ON supply_chain.shipment_risk
-- FOR EACH ROW
-- EXECUTE FUNCTION supply_chain.validate_shipment_risk();

-- UPDATE supply_chain.shipments
-- SET shipment_volume_tons=-100
-- WHERE shipment_id='SHP0001';

-- UPDATE supply_chain.shipment_risk
-- SET delay_probability=1.5
-- WHERE shipment_id='SHP0001';