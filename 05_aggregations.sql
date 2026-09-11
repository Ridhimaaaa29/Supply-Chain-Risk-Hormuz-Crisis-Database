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
