CREATE OR REPLACE VIEW analytics.merchant_single_seller_orders AS
WITH seller_counts AS (
    SELECT
        order_id,
        MIN(seller_id) AS seller_id,
        COUNT(DISTINCT seller_id) AS seller_count
    FROM raw.order_items
    GROUP BY order_id
)
SELECT
    f.*,
    s.seller_id
FROM analytics.order_fulfillment f
JOIN seller_counts s
    ON f.order_id = s.order_id
WHERE s.seller_count = 1;

-- VIEW 2: Merchant performance scorecard
CREATE OR REPLACE VIEW analytics.merchant_performance AS
SELECT
    m.seller_id,
    s.seller_city,
    s.seller_state,

    COUNT(*) AS total_linked_orders,

    COUNT(*) FILTER (
        WHERE m.order_status = 'delivered'
    ) AS delivered_orders,

    COUNT(*) FILTER (
        WHERE m.order_status = 'canceled'
    ) AS canceled_orders_with_items,

    COUNT(m.processing_hours)
        AS processing_eligible_orders,

    ROUND(AVG(m.processing_hours), 2)
        AS avg_processing_hours,

    ROUND(
        APPROX_QUANTILE(m.processing_hours, 0.90), 2
    ) AS p90_processing_hours,

    COUNT(m.transit_hours)
        AS transit_eligible_orders,

    ROUND(AVG(m.transit_hours), 2)
        AS avg_transit_hours,

    COUNT(m.late_delivery)
        AS delivery_eligible_orders,

    COALESCE(SUM(m.late_delivery), 0)
        AS late_deliveries,

    ROUND(
        100.0 * AVG(m.late_delivery), 2
    ) AS late_delivery_rate_pct

FROM analytics.merchant_single_seller_orders m
LEFT JOIN raw.sellers s
    ON m.seller_id = s.seller_id
GROUP BY
    m.seller_id,
    s.seller_city,
    s.seller_state;

-- VIEW 3: Prioritize merchants by late-order volume
-- Require at least 30 eligible deliveries.
CREATE OR REPLACE VIEW analytics.merchant_priority AS
SELECT
    ROW_NUMBER() OVER (
        ORDER BY
            late_deliveries DESC,
            late_delivery_rate_pct DESC,
            seller_id
    ) AS priority_rank,
    *
FROM analytics.merchant_performance
WHERE delivery_eligible_orders >= 30;
