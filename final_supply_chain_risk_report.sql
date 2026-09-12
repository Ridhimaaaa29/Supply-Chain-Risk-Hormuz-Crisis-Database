SELECT
v.shipment_id AS "Shipment ID",
v.supplier AS "Supplier",
v.country AS "Country",
v.product AS "Product",
s.shipment_volume_tons AS "Shipment Volume",
v.route_risk AS "Route Risk",
v.political_risk AS "Political Risk",
v.port_congestion AS "Port Congestion",
sr.supplier_reliability AS "Supplier Reliability",
v.inventory_days AS "Inventory Days",
s.transit_time_days AS "Transit Time",
v.delay_probability AS "Delay Probability",
v.current_delay AS "Current Delay",
s.freight_cost_usd AS "Freight Cost",
s.revenue_impact_usd AS "Revenue Impact",
s.risk_classification AS "Risk Classification",
ROUND((
v.route_risk*0.20+
v.political_risk*0.15+
v.port_congestion*0.15+
v.delay_probability*100*0.20+
LEAST(v.current_delay*5,100)*0.10+
(1-sr.supplier_reliability)*100*0.10+
GREATEST(100-v.inventory_days*5,0)*0.05+
LEAST(supply_chain.calculate_freight_risk(
s.shipment_volume_tons,r.fuel_price_usd,v.route_risk)/100,1)*100*0.05
)::NUMERIC,2) AS "Supply Chain Risk Score",
CASE
WHEN v.route_risk>=80 AND v.delay_probability>=0.70 AND v.current_delay>=10 AND v.inventory_days<=15 THEN 'CRITICAL'
WHEN v.route_risk>=60 AND v.delay_probability>=0.50 AND v.current_delay>=5 THEN 'HIGH'
WHEN v.route_risk>=40 OR v.delay_probability>=0.30 THEN 'MEDIUM'
ELSE 'LOW'
END AS "Final Risk Level"
FROM supply_chain.vw_shipment_risk v
JOIN supply_chain.shipments s ON v.shipment_id=s.shipment_id
JOIN supply_chain.shipment_risk r ON v.shipment_id=r.shipment_id
JOIN supply_chain.shipment_raw sr ON v.shipment_id=sr.shipment_id
WHERE v.shipment_id IN(
SELECT shipment_id
FROM supply_chain.vw_critical_shipments
)
ORDER BY "Supply Chain Risk Score" DESC
LIMIT 20;