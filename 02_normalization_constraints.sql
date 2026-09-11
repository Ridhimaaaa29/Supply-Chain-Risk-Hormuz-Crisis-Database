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