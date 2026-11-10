# KPI Dictionary

Definitions below follow [SQL 03](../sql/03_fulfillment_kpis.sql), [SQL 04](../sql/04_merchant_performance.sql), [SQL 05](../sql/05_root_cause_pareto.sql), and [SQL 06](../sql/06_scenario_analysis.sql). Percent fields use a 0–100 scale; duration fields use hours. Displayed summary values are generally rounded to two decimal places.

## Marketplace fulfillment

| Field / measure | Definition and denominator | Historical reference |
|---|---|---:|
| `total_orders` | Count of all order rows, including orders without item records | 99,441 |
| `delivered_orders` | Orders with status `delivered` | 96,478 |
| `canceled_orders` | Orders with status `canceled` | 625 |
| `unavailable_orders` | Orders with status `unavailable`; separate from canceled | 609 |
| `cancellation_rate_pct` | 100 × canceled orders / all orders | 0.63% |
| `processing_hours` | (Carrier timestamp − approval timestamp), in seconds / 3,600; delivered orders only, both timestamps present, carrier ≥ approval | — |
| `processing_eligible_orders` | Count of non-null `processing_hours` | 95,112 |
| `avg_processing_hours` | Mean over processing-eligible orders | 68.48 |
| `p90_processing_hours` | DuckDB approximate 90th percentile of eligible processing hours | 144.50 |
| `transit_hours` | (Delivery timestamp − carrier timestamp), in seconds / 3,600; delivered orders only, both timestamps present, delivery ≥ carrier | — |
| `transit_eligible_orders` | Count of non-null `transit_hours` | 96,446 |
| `avg_transit_hours` | Mean over transit-eligible orders | 224.00 |
| `late_delivery` | 1 if actual delivery date exceeds estimated delivery date; otherwise 0; null unless delivered with both dates present | — |
| `delivery_eligible_orders` | Count of non-null `late_delivery` | 96,470 |
| `late_orders` / `late_deliveries` | Sum of eligible late-delivery indicators | 6,534 marketplace-wide |
| `late_delivery_rate_pct` | 100 × late deliveries / delivery-eligible orders | 6.77% |
| Delivered-order share | 100 × delivered orders / all orders; distinct from on-time delivery | 97.02% |

Null metric values mean ineligible or missing, not zero duration or on-time delivery. Delivery reliability eligibility does not require valid processing or transit duration. The eight delivered orders without delivery timestamps explain the difference between delivered and delivery-eligible counts.

Monthly reports group by purchase month (`order_month`) and omit null purchase timestamps. Each month's metrics retain their own eligibility rules.

## Merchant and diagnostic measures

| Field / measure | Definition |
|---|---|
| `total_linked_orders` | Orders linked to exactly one distinct seller, counted within that seller's group |
| `priority_rank` | Rank among merchants with ≥30 delivery-eligible orders; late deliveries descending, rate descending, seller ID ascending |
| Qualifying merchants | Number of merchants meeting the threshold: 615 |
| `cohort_late_orders` | Sum of late deliveries across the qualifying merchant cohort |
| `cumulative_late_orders` | Running sum of late deliveries in priority-rank order |
| `cumulative_late_share_pct` | 100 × cumulative late orders / qualifying-cohort late orders |
| `cumulative_merchant_share_pct` | 100 × priority rank / qualifying merchant count |
| Top-10 late share | Cumulative late share at rank 10: 18.75%, representing 1,019 late orders |
| Regional metrics | Order-level measures grouped by customer state, not seller state |
| Category metrics | One category group per order; multi-category orders use `multiple_categories`, orders without items use `no_item_records` |
| Processing bands | Delivered orders grouped into [0,24), [24,72), [72,168), [168,∞) hours, plus `invalid_or_missing` |

A group's late-delivery rate uses delivery-eligible orders within that group. Processing averages use its processing-eligible subset. Diagnostic differences are descriptive associations.

## Modeled scenario measures

| Field / measure | Definition |
|---|---|
| `target_merchants` | Requested top-ranked merchant scope: 10, 25, or 50 |
| `merchants_in_scope` | Actual number of qualifying merchants selected |
| `baseline_eligible_deliveries` | Delivery-eligible single-seller orders in the selected cohort |
| `baseline_late_orders` | Late deliveries in that same cohort |
| `baseline_late_rate_pct` | 100 × baseline late orders / baseline eligible deliveries |
| `modeled_late_orders_avoided` | Round(baseline late orders × assumed late reduction / 100) to whole orders |
| `modeled_remaining_late_orders` | Baseline late orders − modeled avoided late orders |
| `modeled_late_rate_pct` | 100 × modeled remaining late orders / unchanged baseline eligible deliveries |
| `baseline_processing_orders` | Processing-eligible orders in the selected cohort |
| `baseline_processing_hours` | Sum of eligible processing hours in that cohort |
| `modeled_processing_hours_saved` | Baseline processing hours × assumed processing reduction / 100, rounded to two decimals; elapsed hours, not labor savings |
| Cost per modeled avoided late order | Excel assumed implementation cost / modeled avoided orders; undefined if avoided orders are zero |

Scenario outputs are hypotheses, not realized results. See [assumptions](assumptions.md).
