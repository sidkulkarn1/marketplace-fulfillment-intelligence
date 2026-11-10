CREATE SCHEMA IF NOT EXISTS reporting;

-- 1. Executive KPI Dashboard
CREATE OR REPLACE VIEW reporting.executive_kpis AS
SELECT
    total_orders,
    delivered_orders,
    canceled_orders,
    unavailable_orders,
    cancellation_rate_pct,
    processing_eligible_orders,
    avg_processing_hours,
    p90_processing_hours,
    transit_eligible_orders,
    avg_transit_hours,
    delivery_eligible_orders,
    late_orders,
    late_delivery_rate_pct
FROM analytics.fulfillment_kpi_summary;

-- 2. Monthly Fulfillment Trends
CREATE OR REPLACE VIEW reporting.monthly_fulfillment AS
SELECT
    order_month,
    total_orders,
    delivered_orders,
    canceled_orders,
    cancellation_rate_pct,
    avg_processing_hours,
    avg_transit_hours,
    delivery_eligible_orders,
    late_delivery_rate_pct
FROM analytics.fulfillment_monthly;

-- 3. Merchant Performance Scorecard
CREATE OR REPLACE VIEW reporting.merchant_scorecard AS
SELECT
    priority_rank,
    seller_id,
    seller_city,
    seller_state,
    total_linked_orders,
    delivered_orders,
    processing_eligible_orders,
    avg_processing_hours,
    p90_processing_hours,
    transit_eligible_orders,
    avg_transit_hours,
    delivery_eligible_orders,
    late_deliveries,
    late_delivery_rate_pct
FROM analytics.merchant_priority;

-- 4. Merchant Pareto Analysis
CREATE OR REPLACE VIEW reporting.merchant_pareto AS
SELECT
    priority_rank,
    seller_id,
    seller_city,
    seller_state,
    delivered_orders,
    late_deliveries,
    late_delivery_rate_pct,
    cohort_late_orders,
    cumulative_late_orders,
    cumulative_late_share_pct,
    cumulative_merchant_share_pct
FROM analytics.merchant_late_pareto;

-- 5. Regional Fulfillment Performance
CREATE OR REPLACE VIEW reporting.regional_performance AS
SELECT *
FROM analytics.customer_region_performance;

-- 6. Product Category Performance
CREATE OR REPLACE VIEW reporting.category_performance AS
SELECT *
FROM analytics.category_fulfillment;

-- 7. Processing-Time Segments
CREATE OR REPLACE VIEW reporting.processing_bands AS
SELECT *
FROM analytics.processing_band_performance;

-- 8. Operational Scenario Comparison
CREATE OR REPLACE VIEW reporting.scenario_comparison AS
SELECT *
FROM analytics.scenario_comparison;


-- =====================================================
-- EXPORT REPORTING TABLES TO CSV
-- =====================================================

COPY (
    SELECT * FROM reporting.executive_kpis
) TO 'outputs/tables/executive_kpis.csv'
(HEADER, DELIMITER ',');

COPY (
    SELECT * FROM reporting.monthly_fulfillment
    ORDER BY order_month
) TO 'outputs/tables/monthly_fulfillment.csv'
(HEADER, DELIMITER ',');

COPY (
    SELECT * FROM reporting.merchant_scorecard
    ORDER BY priority_rank
) TO 'outputs/tables/merchant_scorecard.csv'
(HEADER, DELIMITER ',');

COPY (
    SELECT * FROM reporting.merchant_pareto
    ORDER BY priority_rank
) TO 'outputs/tables/merchant_pareto.csv'
(HEADER, DELIMITER ',');

COPY (
    SELECT * FROM reporting.regional_performance
    ORDER BY late_deliveries DESC
) TO 'outputs/tables/regional_performance.csv'
(HEADER, DELIMITER ',');

COPY (
    SELECT * FROM reporting.category_performance
    ORDER BY late_deliveries DESC
) TO 'outputs/tables/category_performance.csv'
(HEADER, DELIMITER ',');

COPY (
    SELECT * FROM reporting.processing_bands
    ORDER BY processing_band
) TO 'outputs/tables/processing_bands.csv'
(HEADER, DELIMITER ',');

COPY (
    SELECT * FROM reporting.scenario_comparison
    ORDER BY target_merchants
) TO 'outputs/tables/scenario_comparison.csv'
(HEADER, DELIMITER ',');
