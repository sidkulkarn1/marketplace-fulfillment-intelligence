CREATE SCHEMA IF NOT EXISTS analytics;

CREATE OR REPLACE VIEW analytics.order_fulfillment AS

WITH item_summary AS (
    SELECT
        order_id,
        COUNT(*) AS item_count,
        COUNT(DISTINCT seller_id) AS seller_count
    FROM raw.order_items
    GROUP BY order_id
)

SELECT
    o.order_id,
    o.customer_id,
    o.order_status,
    o.order_purchase_timestamp AS purchase_at,
    o.order_approved_at AS approved_at,
    o.order_delivered_carrier_date AS carrier_at,
    o.order_delivered_customer_date AS delivered_at,
    o.order_estimated_delivery_date AS estimated_at,

    COALESCE(i.item_count, 0) AS item_count,
    COALESCE(i.seller_count, 0) AS seller_count,

    -- Approval to carrier handoff
    CASE
        WHEN o.order_status = 'delivered'
         AND o.order_approved_at IS NOT NULL
         AND o.order_delivered_carrier_date IS NOT NULL
         AND o.order_delivered_carrier_date >= o.order_approved_at
        THEN DATE_DIFF(
            'second',
            o.order_approved_at,
            o.order_delivered_carrier_date
        ) / 3600.0
    END AS processing_hours,

    -- Carrier handoff to customer delivery
    CASE
        WHEN o.order_status = 'delivered'
         AND o.order_delivered_carrier_date IS NOT NULL
         AND o.order_delivered_customer_date IS NOT NULL
         AND o.order_delivered_customer_date >= o.order_delivered_carrier_date
        THEN DATE_DIFF(
            'second',
            o.order_delivered_carrier_date,
            o.order_delivered_customer_date
        ) / 3600.0
    END AS transit_hours,

    -- Calendar-date delivery reliability
    CASE
        WHEN o.order_status = 'delivered'
         AND o.order_delivered_customer_date IS NOT NULL
         AND o.order_estimated_delivery_date IS NOT NULL
        THEN CASE
            WHEN CAST(o.order_delivered_customer_date AS DATE)
               > CAST(o.order_estimated_delivery_date AS DATE)
            THEN 1
            ELSE 0
        END
    END AS late_delivery

FROM raw.orders o
LEFT JOIN item_summary i
    ON o.order_id = i.order_id;


-- =====================================================
-- VIEW 2: MARKETPLACE KPI SUMMARY
-- =====================================================

CREATE OR REPLACE VIEW analytics.fulfillment_kpi_summary AS

SELECT
    COUNT(*) AS total_orders,

    COUNT(*) FILTER (
        WHERE order_status = 'delivered'
    ) AS delivered_orders,

    COUNT(*) FILTER (
        WHERE order_status = 'canceled'
    ) AS canceled_orders,

    COUNT(*) FILTER (
        WHERE order_status = 'unavailable'
    ) AS unavailable_orders,

    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE order_status = 'canceled'
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS cancellation_rate_pct,

    COUNT(processing_hours) AS processing_eligible_orders,

    ROUND(AVG(processing_hours), 2)
        AS avg_processing_hours,

    ROUND(
        APPROX_QUANTILE(processing_hours, 0.90),
        2
    ) AS p90_processing_hours,

    COUNT(transit_hours) AS transit_eligible_orders,

    ROUND(AVG(transit_hours), 2)
        AS avg_transit_hours,

    COUNT(late_delivery) AS delivery_eligible_orders,

    SUM(late_delivery) AS late_orders,

    ROUND(
        100.0 * AVG(late_delivery),
        2
    ) AS late_delivery_rate_pct

FROM analytics.order_fulfillment;


-- =====================================================
-- VIEW 3: MONTHLY FULFILLMENT TRENDS
-- =====================================================

CREATE OR REPLACE VIEW analytics.fulfillment_monthly AS

SELECT
    DATE_TRUNC('month', purchase_at)::DATE
        AS order_month,

    COUNT(*) AS total_orders,

    COUNT(*) FILTER (
        WHERE order_status = 'delivered'
    ) AS delivered_orders,

    COUNT(*) FILTER (
        WHERE order_status = 'canceled'
    ) AS canceled_orders,

    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE order_status = 'canceled'
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS cancellation_rate_pct,

    ROUND(AVG(processing_hours), 2)
        AS avg_processing_hours,

    ROUND(AVG(transit_hours), 2)
        AS avg_transit_hours,

    COUNT(late_delivery) AS delivery_eligible_orders,

    ROUND(
        100.0 * AVG(late_delivery),
        2
    ) AS late_delivery_rate_pct

FROM analytics.order_fulfillment
WHERE purchase_at IS NOT NULL
GROUP BY 1
ORDER BY 1;
