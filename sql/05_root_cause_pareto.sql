-- VIEW 1: Merchant Late-Delivery Pareto

CREATE OR REPLACE VIEW analytics.merchant_late_pareto AS
SELECT
    priority_rank,
    seller_id,
    seller_city,
    seller_state,
    delivered_orders,
    delivery_eligible_orders,
    late_deliveries,
    late_delivery_rate_pct,

    SUM(late_deliveries) OVER ()
        AS cohort_late_orders,

    SUM(late_deliveries) OVER (
        ORDER BY priority_rank
        ROWS BETWEEN UNBOUNDED PRECEDING
        AND CURRENT ROW
    ) AS cumulative_late_orders,

    ROUND(
        100.0 * SUM(late_deliveries) OVER (
            ORDER BY priority_rank
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW
        )
        / NULLIF(SUM(late_deliveries) OVER (), 0),
        2
    ) AS cumulative_late_share_pct,

    ROUND(
        100.0 * priority_rank
        / COUNT(*) OVER (),
        2
    ) AS cumulative_merchant_share_pct

FROM analytics.merchant_priority;


-- ================================================
-- VIEW 2: Customer Region Performance
-- ================================================

CREATE OR REPLACE VIEW analytics.customer_region_performance AS
SELECT
    c.customer_state,

    COUNT(*) AS total_orders,

    COUNT(*) FILTER (
        WHERE f.order_status = 'delivered'
    ) AS delivered_orders,

    COUNT(f.late_delivery)
        AS delivery_eligible_orders,

    COALESCE(SUM(f.late_delivery), 0)
        AS late_deliveries,

    ROUND(
        100.0 * AVG(f.late_delivery), 2
    ) AS late_delivery_rate_pct,

    ROUND(AVG(f.processing_hours), 2)
        AS avg_processing_hours,

    ROUND(AVG(f.transit_hours), 2)
        AS avg_transit_hours

FROM analytics.order_fulfillment f
JOIN raw.customers c
    ON f.customer_id = c.customer_id
GROUP BY c.customer_state;


-- ================================================
-- VIEW 3: Product Category Performance
-- One category group per order to avoid duplication.
-- ================================================

CREATE OR REPLACE VIEW analytics.category_fulfillment AS

WITH order_categories AS (
    SELECT
        oi.order_id,

        COUNT(DISTINCT COALESCE(
            t.product_category_name_english,
            p.product_category_name,
            'unknown'
        )) AS category_count,

        MIN(COALESCE(
            t.product_category_name_english,
            p.product_category_name,
            'unknown'
        )) AS single_category

    FROM raw.order_items oi
    LEFT JOIN raw.products p
        ON oi.product_id = p.product_id
    LEFT JOIN raw.category_translation t
        ON p.product_category_name =
           t.product_category_name
    GROUP BY oi.order_id
)

SELECT
    CASE
        WHEN c.order_id IS NULL
            THEN 'no_item_records'
        WHEN c.category_count > 1
            THEN 'multiple_categories'
        ELSE c.single_category
    END AS category_group,

    COUNT(*) AS total_orders,

    COUNT(*) FILTER (
        WHERE f.order_status = 'delivered'
    ) AS delivered_orders,

    COUNT(*) FILTER (
        WHERE f.order_status = 'canceled'
    ) AS canceled_orders,

    COUNT(f.late_delivery)
        AS delivery_eligible_orders,

    COALESCE(SUM(f.late_delivery), 0)
        AS late_deliveries,

    ROUND(
        100.0 * AVG(f.late_delivery), 2
    ) AS late_delivery_rate_pct,

    ROUND(AVG(f.processing_hours), 2)
        AS avg_processing_hours

FROM analytics.order_fulfillment f
LEFT JOIN order_categories c
    ON f.order_id = c.order_id
GROUP BY 1;


-- ================================================
-- VIEW 4: Processing Time Diagnostics
-- ================================================

CREATE OR REPLACE VIEW analytics.processing_band_performance AS

WITH classified AS (
    SELECT
        *,
        CASE
            WHEN processing_hours IS NULL
                THEN 'invalid_or_missing'
            WHEN processing_hours < 24
                THEN 'under_24_hours'
            WHEN processing_hours < 72
                THEN '24_to_72_hours'
            WHEN processing_hours < 168
                THEN '72_to_168_hours'
            ELSE '168_plus_hours'
        END AS processing_band
    FROM analytics.order_fulfillment
    WHERE order_status = 'delivered'
)

SELECT
    processing_band,

    COUNT(*) AS delivered_orders,

    COUNT(late_delivery)
        AS delivery_eligible_orders,

    COALESCE(SUM(late_delivery), 0)
        AS late_deliveries,

    ROUND(
        100.0 * AVG(late_delivery), 2
    ) AS late_delivery_rate_pct,

    ROUND(AVG(processing_hours), 2)
        AS avg_processing_hours

FROM classified
GROUP BY processing_band;
