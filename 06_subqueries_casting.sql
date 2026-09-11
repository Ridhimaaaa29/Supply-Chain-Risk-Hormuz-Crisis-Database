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