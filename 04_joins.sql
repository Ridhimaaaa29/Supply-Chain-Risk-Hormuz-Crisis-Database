-- Task 4: Joins & Relational Analysis

-- INNER JOIN

-- SELECT s.shipment_id,s.supplier_id,s.country
-- FROM supply_chain.shipments s INNER JOIN supply_chain.suppliers sup ON s.supplier_id=sup.supplier_id;

-- LEFT JOIN

-- SELECT s.shipment_id,s.supplier_id,sup.supplier_id AS supplier_record
-- FROM supply_chain.shipments s LEFT JOIN supply_chain.suppliers sup ON s.supplier_id=sup.supplier_id LIMIT 10;

-- RIGHT JOIN

-- SELECT s.shipment_id,s.supplier_id,sup.supplier_id AS supplier_record
-- FROM supply_chain.shipments s RIGHT JOIN supply_chain.suppliers sup ON s.supplier_id=sup.supplier_id ORDER BY sup.supplier_id;

-- FULL OUTER JOIN

-- SELECT s.shipment_id,s.supplier_id AS shipment_supplier,sup.supplier_id AS supplier_record
-- FROM supply_chain.shipments s FULL OUTER JOIN supply_chain.suppliers sup ON s.supplier_id=sup.supplier_id LIMIT 20;

-- CROSS JOIN

-- SELECT sup.supplier_id,p.product_type
-- FROM supply_chain.suppliers sup CROSS JOIN supply_chain.products p LIMIT 20;

-- Supplier Shipment Report

-- SELECT s.supplier_id,s.country,COUNT(s.shipment_id) AS shipment_count,SUM(s.shipment_volume_tons) 
-- AS shipment_volume,ROUND(AVG(r.current_delay_days),2) AS average_delay,ROUND(AVG(sr.supplier_reliability),2) 
-- AS supplier_reliability,ROUND(SUM(s.freight_cost_usd),2) AS total_freight_cost,ROUND(SUM(s.revenue_impact_usd),2) AS revenue_impact
-- FROM supply_chain.shipments s JOIN supply_chain.shipment_risk r ON s.shipment_id=r.shipment_id 
-- JOIN supply_chain.shipment_raw sr ON s.shipment_id=sr.shipment_id
-- GROUP BY s.supplier_id,s.country ORDER BY shipment_volume DESC;

-- Product Performance Report

-- SELECT p.product_type AS product,COUNT(s.shipment_id) AS shipment_count,SUM(s.monthly_demand_tons) 
-- AS total_demand,SUM(s.shipment_volume_tons) AS total_shipment_volume,ROUND(AVG(s.freight_cost_usd),2) 
-- AS average_freight_cost,ROUND(AVG(r.current_delay_days),2) AS average_delay,SUM(CASE WHEN s.disruption_event=1 THEN 1 ELSE 0 END) 
-- AS disruption_count FROM supply_chain.products p JOIN supply_chain.shipments s 
-- ON p.product_id=s.product_id JOIN supply_chain.shipment_risk r ON s.shipment_id=r.shipment_id
-- GROUP BY p.product_id,p.product_type ORDER BY total_shipment_volume DESC;

-- Critical Shipment Report

-- SELECT s.shipment_id,s.supplier_id AS supplier,s.country,p.product_type AS product,s.shipment_volume_tons,
-- r.route_risk_score,r.political_risk_index,r.port_congestion_index,r.delay_probability,r.current_delay_days,
-- i.inventory_days,s.freight_cost_usd,s.revenue_impact_usd
-- FROM supply_chain.shipments s JOIN supply_chain.suppliers sup ON s.supplier_id=sup.supplier_id 
-- JOIN supply_chain.products p ON s.product_id=p.product_id JOIN supply_chain.shipment_risk r 
-- ON s.shipment_id=r.shipment_id JOIN supply_chain.inventory i ON s.shipment_id=i.shipment_id
-- ORDER BY r.route_risk_score DESC;