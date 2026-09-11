-- Task 7: Views & Reusable Reporting

-- View 1: Supplier Performance

-- CREATE OR REPLACE VIEW supply_chain.vw_supplier_performance AS
-- SELECT s.supplier_id AS supplier,s.country, COUNT(s.shipment_id) AS shipment_count,
-- SUM(s.shipment_volume_tons) AS total_shipment_volume, ROUND(AVG(r.current_delay_days),2)
-- AS average_delay, ROUND(AVG(sr.supplier_reliability),2) AS average_reliability,
-- ROUND(SUM(s.freight_cost_usd),2) AS total_freight_cost, ROUND(SUM(s.revenue_impact_usd),2) 
-- AS total_revenue_impact FROM supply_chain.shipments s JOIN supply_chain.shipment_risk r 
-- ON s.shipment_id=r.shipment_id JOIN supply_chain.shipment_raw sr 
-- ON s.shipment_id=sr.shipment_id GROUP BY s.supplier_id,s.country;

-- View 2: Shipment Risk

-- CREATE OR REPLACE VIEW supply_chain.vw_shipment_risk AS
-- SELECT s.shipment_id, s.supplier_id AS supplier, s.country, p.product_type 
-- AS product, r.route_risk_score AS route_risk, r.political_risk_index 
-- AS political_risk, r.port_congestion_index AS port_congestion, r.delay_probability, r.current_delay_days 
-- AS current_delay, i.inventory_days
-- FROM supply_chain.shipments s
-- JOIN supply_chain.products p ON s.product_id=p.product_id
-- JOIN supply_chain.shipment_risk r ON s.shipment_id=r.shipment_id
-- JOIN supply_chain.inventory i ON s.shipment_id=i.shipment_id;

-- View 3: Critical Shipments

-- CREATE OR REPLACE VIEW supply_chain.vw_critical_shipments AS
-- SELECT shipment_id,supplier,country,product,route_risk,political_risk,
-- port_congestion,delay_probability,current_delay,inventory_days
-- FROM supply_chain.vw_shipment_risk
-- WHERE route_risk>=8
-- AND delay_probability>=0.70
-- AND current_delay>=10
-- AND inventory_days<=15;


-- Query 1: Suppliers with low reliability

-- SELECT supplier,country,average_reliability,shipment_count
-- FROM supply_chain.vw_supplier_performance
-- WHERE average_reliability<0.70
-- ORDER BY average_reliability;

-- Query 2: Supplier-country combinations with high revenue impact

-- SELECT *
-- FROM supply_chain.vw_supplier_performance
-- WHERE total_revenue_impact>200000
-- ORDER BY total_revenue_impact DESC;

-- Query 3: Countries with more than 10 high-risk shipments

-- SELECT country,COUNT(*) AS high_risk_shipments
-- FROM supply_chain.vw_shipment_risk
-- WHERE route_risk>=6
-- AND delay_probability>=0.50
-- GROUP BY country
-- HAVING COUNT(*)>10
-- ORDER BY high_risk_shipments DESC;

-- Query 4: Shipments with low inventory and significant delay

-- SELECT shipment_id,supplier,country,product,current_delay,inventory_days
-- FROM supply_chain.vw_shipment_risk
-- WHERE current_delay>=5
-- AND inventory_days<=20
-- ORDER BY current_delay DESC,inventory_days;

-- Query 5: Critical shipments grouped by product

-- SELECT shipment_id,supplier,country,product,route_risk,
-- delay_probability,current_delay,inventory_days
-- FROM supply_chain.vw_critical_shipments
-- ORDER BY route_risk DESC,current_delay DESC;



-- SELECT s.shipment_id,s.supplier_id,s.country,p.product_type,
-- r.route_risk_score,r.delay_probability,r.current_delay_days,i.inventory_days
-- FROM supply_chain.shipments s
-- JOIN supply_chain.products p ON s.product_id=p.product_id
-- JOIN supply_chain.shipment_risk r ON s.shipment_id=r.shipment_id
-- JOIN supply_chain.inventory i ON s.shipment_id=i.shipment_id
-- WHERE r.route_risk_score>=8
-- AND r.delay_probability>=0.70
-- AND r.current_delay_days>=10
-- AND i.inventory_days<=15
-- ORDER BY r.route_risk_score DESC;