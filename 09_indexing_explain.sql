-- Task 9 — Indexing & Query Optimisation
-- Requirement 1: Identify at least 5 queries that could benefit from indexes.

-- Query 1 — Supplier filtering

-- SELECT *
-- FROM supply_chain.shipments
-- WHERE supplier_id='SUP019';

-- Query 2 — Country filtering

-- SELECT *
-- FROM supply_chain.shipments
-- WHERE country='India';

-- Query 3 — High route risk

-- SELECT shipment_id,route_risk_score
-- FROM supply_chain.shipment_risk
-- WHERE route_risk_score>=8
-- ORDER BY route_risk_score DESC;

-- Query 4 — High delay probability

-- SELECT shipment_id,delay_probability
-- FROM supply_chain.shipment_risk
-- WHERE delay_probability>=0.70
-- ORDER BY delay_probability DESC;

-- Query 5 — Disrupted shipments

-- SELECT *
-- FROM supply_chain.shipments
-- WHERE disruption_event=1;

-- Requirement 2: Run each query using: EXPLAIN

-- EXPLAIN
-- SELECT *
-- FROM supply_chain.shipments
-- WHERE supplier_id='SUP019';

-- EXPLAIN
-- SELECT *
-- FROM supply_chain.shipments
-- WHERE country='India';

-- EXPLAIN
-- SELECT shipment_id,route_risk_score
-- FROM supply_chain.shipment_risk
-- WHERE route_risk_score>=80
-- ORDER BY route_risk_score DESC;

-- EXPLAIN
-- SELECT shipment_id,delay_probability
-- FROM supply_chain.shipment_risk
-- WHERE delay_probability>=0.70
-- ORDER BY delay_probability DESC;

-- EXPLAIN
-- SELECT *
-- FROM supply_chain.shipments
-- WHERE disruption_event=1;

-- Requirement 3: Run again using: EXPLAIN ANALYZE

-- EXPLAIN ANALYZE
-- SELECT *
-- FROM supply_chain.shipments
-- WHERE supplier_id='SUP019';

-- EXPLAIN ANALYZE
-- SELECT *
-- FROM supply_chain.shipments
-- WHERE country='India';

-- EXPLAIN ANALYZE
-- SELECT shipment_id,route_risk_score
-- FROM supply_chain.shipment_risk
-- WHERE route_risk_score>=80
-- ORDER BY route_risk_score DESC;

-- EXPLAIN ANALYZE
-- SELECT shipment_id,delay_probability
-- FROM supply_chain.shipment_risk
-- WHERE delay_probability>=0.70
-- ORDER BY delay_probability DESC;

-- EXPLAIN ANALYZE
-- SELECT *
-- FROM supply_chain.shipments
-- WHERE disruption_event=1;

-- Requirement 4: Create appropriate indexes.

-- CREATE INDEX idx_shipments_supplier
-- ON supply_chain.shipments(supplier_id);

-- CREATE INDEX idx_shipments_country
-- ON supply_chain.shipments(country);

-- CREATE INDEX idx_risk_route
-- ON supply_chain.shipment_risk(route_risk_score);

-- CREATE INDEX idx_risk_delay_probability
-- ON supply_chain.shipment_risk(delay_probability);

-- CREATE INDEX idx_shipments_disruption
-- ON supply_chain.shipments(disruption_event);

-- CREATE TABLE supply_chain.index_comparison(
-- query_name VARCHAR(50),
-- indexed_column VARCHAR(50),
-- before_plan VARCHAR(100),
-- after_plan VARCHAR(100),
-- before_time NUMERIC(10,3),
-- after_time NUMERIC(10,3),
-- improved VARCHAR(10),
-- remarks TEXT
-- );

-- SELECT *
-- FROM supply_chain.index_comparison;

-- INSERT INTO supply_chain.index_comparison
-- (query_name,indexed_column,before_plan,after_plan,before_time,after_time,improved,remarks)
-- VALUES
-- ('Q1 Supplier Filtering','supplier_id','Seq Scan','Bitmap Heap Scan + Bitmap Index Scan',0.192,0.104,'YES','Execution time decreased with index'),
-- ('Q2 Country Filtering','country','Seq Scan','Bitmap Heap Scan + Bitmap Index Scan',0.215,0.169,'YES','Execution time decreased with index'),
-- ('Q3 High Route Risk','route_risk_score','Seq Scan + Sort','Index Scan Backward',0.562,0.021,'YES','Major improvement; index also supports descending order'),
-- ('Q4 High Delay Probability','delay_probability','Seq Scan + Sort','Bitmap Heap Scan + Bitmap Index Scan + Sort',0.165,0.233,'NO','Index used but execution time increased'),
-- ('Q5 Disruption Filtering','disruption_event','Seq Scan','Bitmap Heap Scan + Bitmap Index Scan',0.145,0.191,'NO','Low selectivity and small table reduced index benefit');

SELECT *
FROM supply_chain.index_comparison
ORDER BY query_name;
