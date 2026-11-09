-- Project 3: Operational Scenario Analysis
-- Results are hypothetical, not causal estimates.

-- ================================================
-- VIEW 1: Scenario Assumptions
-- ================================================

CREATE OR REPLACE VIEW analytics.scenario_assumptions AS
SELECT *
FROM (
    VALUES
    (
        'focused_10',
        'Focused Merchant Outreach',
        10, 10.0, 5.0
    ),
    (
        'targeted_25',
        'Targeted Performance Improvement',
        25, 20.0, 10.0
    ),
    (
        'expanded_50',
        'Expanded Merchant Improvement',
        50, 30.0, 15.0
    )
) AS s(
    scenario_id,
    initiative,
    target_merchants,
    late_reduction_pct,
    processing_reduction_pct
);


-- ================================================
-- VIEW 2: Scenario Comparison
-- ================================================

CREATE OR REPLACE VIEW analytics.scenario_comparison AS

WITH merchant_baseline AS (
    SELECT
        p.priority_rank,
        p.seller_id,

        COUNT(o.late_delivery)
            AS eligible_deliveries,

        COALESCE(SUM(o.late_delivery), 0)
            AS late_deliveries,

        COUNT(o.processing_hours)
            AS eligible_processing_orders,

        COALESCE(SUM(o.processing_hours), 0)
            AS total_processing_hours

    FROM analytics.merchant_priority p
    JOIN analytics.merchant_single_seller_orders o
        ON p.seller_id = o.seller_id
    GROUP BY p.priority_rank, p.seller_id
),

targeted AS (
    SELECT
        a.*,
        b.seller_id,
        b.eligible_deliveries,
        b.late_deliveries,
        b.eligible_processing_orders,
        b.total_processing_hours

    FROM analytics.scenario_assumptions a
    JOIN merchant_baseline b
        ON b.priority_rank <= a.target_merchants
),

aggregated AS (
    SELECT
        scenario_id,
        initiative,
        target_merchants,
        late_reduction_pct,
        processing_reduction_pct,

        COUNT(*) AS merchants_in_scope,

        SUM(eligible_deliveries)
            AS baseline_eligible_deliveries,

        SUM(late_deliveries)
            AS baseline_late_orders,

        SUM(eligible_processing_orders)
            AS baseline_processing_orders,

        SUM(total_processing_hours)
            AS baseline_processing_hours

    FROM targeted
    GROUP BY 1, 2, 3, 4, 5
),

modeled AS (
    SELECT
        *,

        CAST(ROUND(
            baseline_late_orders *
            late_reduction_pct / 100.0,
            0
        ) AS BIGINT)
            AS modeled_late_orders_avoided,

        ROUND(
            baseline_processing_hours *
            processing_reduction_pct / 100.0,
            2
        ) AS modeled_processing_hours_saved

    FROM aggregated
)

SELECT
    scenario_id,
    initiative,
    target_merchants,
    merchants_in_scope,

    late_reduction_pct,
    processing_reduction_pct,

    baseline_eligible_deliveries,
    baseline_late_orders,

    ROUND(
        100.0 * baseline_late_orders /
        NULLIF(baseline_eligible_deliveries, 0),
        2
    ) AS baseline_late_rate_pct,

    modeled_late_orders_avoided,

    baseline_late_orders -
        modeled_late_orders_avoided
        AS modeled_remaining_late_orders,

    ROUND(
        100.0 * (
            baseline_late_orders -
            modeled_late_orders_avoided
        ) /
        NULLIF(baseline_eligible_deliveries, 0),
        2
    ) AS modeled_late_rate_pct,

    baseline_processing_orders,

    ROUND(baseline_processing_hours, 2)
        AS baseline_processing_hours,

    modeled_processing_hours_saved

FROM modeled;
