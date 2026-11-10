# Data Dictionary

This is a project-focused dictionary of source tables, join keys, analytical fields, and reporting outputs. It is not an exhaustive description of every unused Olist column. Sources are loaded by [SQL 01](../sql/01_data_ingestion.sql) using DuckDB CSV type inference; types should be checked when replacing source files.

## Nine source tables

All source files reside in `data/raw/` and are excluded from Git.

| Raw table | CSV filename | Grain / relationship | Role in this project |
|---|---|---|---|
| `raw.orders` | `olist_orders_dataset.csv` | One order; `order_id`, linked to customers by `customer_id` | Status, purchase/approval/carrier/delivery/estimated timestamps; KPI backbone |
| `raw.order_items` | `olist_order_items_dataset.csv` | Item within order; `order_id` + `order_item_id`; links to seller and product | Item counts, distinct sellers, merchant attribution, category grouping |
| `raw.customers` | `olist_customers_dataset.csv` | Customer record keyed by `customer_id`; `customer_unique_id` identifies repeat customers across records | Customer state for regional analysis; do not substitute unique-customer ID for the order join key |
| `raw.sellers` | `olist_sellers_dataset.csv` | Seller keyed by `seller_id` | Seller city/state in merchant scorecards |
| `raw.products` | `olist_products_dataset.csv` | Product keyed by `product_id` | Product category lookup |
| `raw.order_reviews` | `olist_order_reviews_dataset.csv` | Review records linked by `order_id`; do not assume one row per order | Ingested; not used in current reporting KPIs |
| `raw.order_payments` | `olist_order_payments_dataset.csv` | Payment records per order; `payment_sequential` distinguishes payment records; `payment_installments` records installment count | Ingested; not used in current reporting KPIs |
| `raw.geolocation` | `olist_geolocation_dataset.csv` | Geographic observations; ZIP prefix is not necessarily unique | Ingested; not used in current state-level reporting |
| `raw.category_translation` | `product_category_name_translation.csv` | Original category name mapped to English category name | English category labels with fallback handling |

The completed audit tested primary-ID uniqueness for orders, customers, sellers, and products, and four foreign-key relationships. Do not interpret that as verification of every possible key in all nine tables.

## Key analytical fields

| Field | Meaning |
|---|---|
| `order_id` | Order identifier and base reporting grain |
| `customer_id` | Order-to-customer lookup key |
| `seller_id` | Merchant identifier; primary attribution requires exactly one distinct seller per order |
| `product_id` | Item-to-product lookup key |
| `order_status` | Source order status; canceled and unavailable remain distinct |
| `purchase_at`, `approved_at`, `carrier_at`, `delivered_at`, `estimated_at` | Aliases of the five source order timestamps in `analytics.order_fulfillment` |
| `item_count`, `seller_count` | Item-row count and distinct seller count per order; zero when no items exist |
| `processing_hours`, `transit_hours` | Eligible elapsed durations; null when ineligible |
| `late_delivery` | Eligible calendar-date lateness indicator: 1 late, 0 not late, null ineligible |
| `customer_state` | Delivery-customer state used in regional grouping |
| `seller_city`, `seller_state` | Merchant location attributes, not customer destination |
| `category_group` | Single category, `multiple_categories`, `no_item_records`, or fallback `unknown` |
| `processing_band` | Delivered-order processing interval or `invalid_or_missing` |
| `priority_rank` | Merchant exposure ranking within the qualifying cohort |
| `scenario_id`, `initiative` | Stable scenario identifier and display label |

See [KPI dictionary](kpi_dictionary.md) for metric formulas, units, denominators, and scenario fields.

## Reporting export contract

[SQL 07](../sql/07_excel_reporting_views.sql) exports the following files. Column lists below reflect the saved CSV headers.

### `executive_kpis.csv`

- **View:** `reporting.executive_kpis`
- **Grain:** One marketplace summary row.
- **File:** [executive_kpis.csv](../outputs/tables/executive_kpis.csv)
- **Columns:** `total_orders`, `delivered_orders`, `canceled_orders`, `unavailable_orders`, `cancellation_rate_pct`, `processing_eligible_orders`, `avg_processing_hours`, `p90_processing_hours`, `transit_eligible_orders`, `avg_transit_hours`, `delivery_eligible_orders`, `late_orders`, `late_delivery_rate_pct`.

### `monthly_fulfillment.csv`

- **View:** `reporting.monthly_fulfillment`
- **Grain:** One purchase month.
- **File:** [monthly_fulfillment.csv](../outputs/tables/monthly_fulfillment.csv)
- **Columns:** `order_month`, `total_orders`, `delivered_orders`, `canceled_orders`, `cancellation_rate_pct`, `avg_processing_hours`, `avg_transit_hours`, `delivery_eligible_orders`, `late_delivery_rate_pct`.

### `merchant_scorecard.csv`

- **View:** `reporting.merchant_scorecard`
- **Grain:** One qualifying merchant.
- **File:** [merchant_scorecard.csv](../outputs/tables/merchant_scorecard.csv)
- **Columns:** `priority_rank`, `seller_id`, `seller_city`, `seller_state`, `total_linked_orders`, `delivered_orders`, `processing_eligible_orders`, `avg_processing_hours`, `p90_processing_hours`, `transit_eligible_orders`, `avg_transit_hours`, `delivery_eligible_orders`, `late_deliveries`, `late_delivery_rate_pct`.

### `merchant_pareto.csv`

- **View:** `reporting.merchant_pareto`
- **Grain:** One qualifying merchant in priority order.
- **File:** [merchant_pareto.csv](../outputs/tables/merchant_pareto.csv)
- **Columns:** `priority_rank`, `seller_id`, `seller_city`, `seller_state`, `delivered_orders`, `late_deliveries`, `late_delivery_rate_pct`, `cohort_late_orders`, `cumulative_late_orders`, `cumulative_late_share_pct`, `cumulative_merchant_share_pct`.

### `regional_performance.csv`

- **View:** `reporting.regional_performance`
- **Grain:** One customer state.
- **File:** [regional_performance.csv](../outputs/tables/regional_performance.csv)
- **Columns:** `customer_state`, `total_orders`, `delivered_orders`, `delivery_eligible_orders`, `late_deliveries`, `late_delivery_rate_pct`, `avg_processing_hours`, `avg_transit_hours`.

### `category_performance.csv`

- **View:** `reporting.category_performance`
- **Grain:** One category group.
- **File:** [category_performance.csv](../outputs/tables/category_performance.csv)
- **Columns:** `category_group`, `total_orders`, `delivered_orders`, `canceled_orders`, `delivery_eligible_orders`, `late_deliveries`, `late_delivery_rate_pct`, `avg_processing_hours`.

### `processing_bands.csv`

- **View:** `reporting.processing_bands`
- **Grain:** One processing band for delivered orders.
- **File:** [processing_bands.csv](../outputs/tables/processing_bands.csv)
- **Columns:** `processing_band`, `delivered_orders`, `delivery_eligible_orders`, `late_deliveries`, `late_delivery_rate_pct`, `avg_processing_hours`.

### `scenario_comparison.csv`

- **View:** `reporting.scenario_comparison`
- **Grain:** One hypothetical intervention scenario.
- **File:** [scenario_comparison.csv](../outputs/tables/scenario_comparison.csv)
- **Columns:** `scenario_id`, `initiative`, `target_merchants`, `merchants_in_scope`, `late_reduction_pct`, `processing_reduction_pct`, `baseline_eligible_deliveries`, `baseline_late_orders`, `baseline_late_rate_pct`, `modeled_late_orders_avoided`, `modeled_remaining_late_orders`, `modeled_late_rate_pct`, `baseline_processing_orders`, `baseline_processing_hours`, `modeled_processing_hours_saved`.
