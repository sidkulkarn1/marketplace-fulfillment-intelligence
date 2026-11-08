
SELECT
    'orders' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS unique_ids,
    COUNT(*) - COUNT(DISTINCT order_id) AS duplicate_count
FROM raw.orders

UNION ALL

SELECT
    'customers',
    COUNT(*),
    COUNT(DISTINCT customer_id),
    COUNT(*) - COUNT(DISTINCT customer_id)
FROM raw.customers

UNION ALL

SELECT
    'sellers',
    COUNT(*),
    COUNT(DISTINCT seller_id),
    COUNT(*) - COUNT(DISTINCT seller_id)
FROM raw.sellers

UNION ALL

SELECT
    'products',
    COUNT(*),
    COUNT(DISTINCT product_id),
    COUNT(*) - COUNT(DISTINCT product_id)
FROM raw.products;


-- Audit 2: Order Status Distribution

SELECT
    order_status,
    COUNT(*) AS total_orders,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM raw.orders
GROUP BY order_status
ORDER BY total_orders DESC;

-- Audit 3: Missing Order Timestamps

SELECT
    order_status,
    COUNT(*) AS total_orders,
    COUNT(*) FILTER (
        WHERE order_purchase_timestamp IS NULL
    ) AS missing_purchase,
    COUNT(*) FILTER (
        WHERE order_approved_at IS NULL
    ) AS missing_approval,
    COUNT(*) FILTER (
        WHERE order_delivered_carrier_date IS NULL
    ) AS missing_carrier,
    COUNT(*) FILTER (
        WHERE order_delivered_customer_date IS NULL
    ) AS missing_delivery,
    COUNT(*) FILTER (
        WHERE order_estimated_delivery_date IS NULL
    ) AS missing_estimate
FROM raw.orders
GROUP BY order_status
ORDER BY total_orders DESC;

-- Audit 4: Relationship Integrity

SELECT
    'order_items_to_orders' AS relationship,
    COUNT(*) AS child_rows,
    COUNT(*) FILTER (
        WHERE c.order_id IS NULL
    ) AS null_keys,
    COUNT(*) FILTER (
        WHERE c.order_id IS NOT NULL
        AND p.order_id IS NULL
    ) AS unmatched_keys
FROM raw.order_items c
LEFT JOIN raw.orders p
    ON c.order_id = p.order_id

UNION ALL

SELECT
    'order_items_to_sellers' AS relationship,
    COUNT(*) AS child_rows,
    COUNT(*) FILTER (
        WHERE c.seller_id IS NULL
    ) AS null_keys,
    COUNT(*) FILTER (
        WHERE c.seller_id IS NOT NULL
        AND p.seller_id IS NULL
    ) AS unmatched_keys
FROM raw.order_items c
LEFT JOIN raw.sellers p
    ON c.seller_id = p.seller_id

UNION ALL

SELECT
    'order_items_to_products' AS relationship,
    COUNT(*) AS child_rows,
    COUNT(*) FILTER (
        WHERE c.product_id IS NULL
    ) AS null_keys,
    COUNT(*) FILTER (
        WHERE c.product_id IS NOT NULL
        AND p.product_id IS NULL
    ) AS unmatched_keys
FROM raw.order_items c
LEFT JOIN raw.products p
    ON c.product_id = p.product_id

UNION ALL

SELECT
    'orders_to_customers' AS relationship,
    COUNT(*) AS child_rows,
    COUNT(*) FILTER (
        WHERE c.customer_id IS NULL
    ) AS null_keys,
    COUNT(*) FILTER (
        WHERE c.customer_id IS NOT NULL
        AND p.customer_id IS NULL
    ) AS unmatched_keys
FROM raw.orders c
LEFT JOIN raw.customers p
    ON c.customer_id = p.customer_id
;

-- Audit 5: Timestamp Consistency

SELECT
    order_status,
    COUNT(*) AS total_orders,

    COUNT(*) FILTER (
        WHERE order_approved_at < order_purchase_timestamp
    ) AS approval_before_purchase,

    COUNT(*) FILTER (
        WHERE order_delivered_carrier_date < order_approved_at
    ) AS carrier_before_approval,

    COUNT(*) FILTER (
        WHERE order_delivered_customer_date < order_delivered_carrier_date
    ) AS delivery_before_carrier,

    COUNT(*) FILTER (
        WHERE order_status = 'delivered'
        AND CAST(order_delivered_customer_date AS DATE)
          > CAST(order_estimated_delivery_date AS DATE)
    ) AS late_deliveries,

    MIN(order_purchase_timestamp) AS earliest_purchase,
    MAX(order_purchase_timestamp) AS latest_purchase

FROM raw.orders
GROUP BY order_status
ORDER BY total_orders DESC;

-- Audit 6: KPI Eligibility

SELECT
    COUNT(*) AS delivered_orders,

    COUNT(*) FILTER (
        WHERE order_approved_at IS NOT NULL
          AND order_delivered_carrier_date IS NOT NULL
          AND order_delivered_carrier_date >= order_approved_at
    ) AS valid_processing_time,

    COUNT(*) FILTER (
        WHERE order_delivered_carrier_date IS NOT NULL
          AND order_delivered_customer_date IS NOT NULL
          AND order_delivered_customer_date >= order_delivered_carrier_date
    ) AS valid_transit_time,

    COUNT(*) FILTER (
        WHERE order_delivered_customer_date IS NOT NULL
          AND order_estimated_delivery_date IS NOT NULL
    ) AS valid_delivery_reliability

FROM raw.orders
WHERE order_status = 'delivered';

-- Audit 7: Order and Seller Grain

WITH order_summary AS (
    SELECT
        order_id,
        COUNT(*) AS item_count,
        COUNT(DISTINCT seller_id) AS seller_count
    FROM raw.order_items
    GROUP BY order_id
)
SELECT
    COUNT(*) AS orders_with_items,
    COUNT(*) FILTER (
        WHERE item_count > 1
    ) AS multi_item_orders,
    COUNT(*) FILTER (
        WHERE seller_count > 1
    ) AS multi_seller_orders,
    MAX(item_count) AS max_items_per_order,
    MAX(seller_count) AS max_sellers_per_order
FROM order_summary;

-- Audit 8: Orders Without Item Records

SELECT
    o.order_status,
    COUNT(*) AS orders_without_items
FROM raw.orders o
LEFT JOIN (
    SELECT DISTINCT order_id
    FROM raw.order_items
) i
    ON o.order_id = i.order_id
WHERE i.order_id IS NULL
GROUP BY o.order_status
ORDER BY orders_without_items DESC;
