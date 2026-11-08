# Phase 1: Data Ingestion & Quality Audit

## Dataset
Olist Brazilian E-Commerce Public Dataset.

## Ingestion
- 9 source tables imported into DuckDB
- 99,441 orders
- 112,650 order-item records
- 3,095 sellers
- 32,951 products

## Data Quality Findings
- No duplicate primary IDs in orders, customers,
  sellers, or products.
- Four tested foreign-key relationships passed.
- 96,478 orders have delivered status.
- 625 canceled orders and 609 unavailable orders.
- 8 delivered orders lack delivery timestamps.
- 1,350 delivered orders have carrier timestamps
  preceding approval timestamps.
- 23 delivered orders have delivery timestamps
  preceding carrier timestamps.
- 6,534 delivered orders arrived after their
  estimated delivery dates.

## KPI Eligibility
- Delivered orders: 96,478
- Valid processing-time records: 95,112
- Valid transit-time records: 96,446
- Valid delivery-reliability records: 96,470

## Order and Seller Relationships
- Orders with item records: 98,666
- Multi-item orders: 9,803
- Multi-seller orders: 1,278
- Maximum items per order: 21
- Maximum sellers per order: 5

## Orders Without Items
- Total: 775
- Unavailable: 603
- Canceled: 164
- Created: 5
- Invoiced: 2
- Shipped: 1
- Delivered: 0

## Analytical Rules
1. Preserve all original records in the raw schema.
2. Use order-level grain for marketplace KPIs.
3. Use single-seller orders for primary seller-level
   delivery performance comparisons.
4. Flag multi-seller orders separately.
5. Exclude invalid timestamps only from affected
   duration metrics.
6. Calculate KPI denominators using eligible records.
7. Preserve orders without items in status analysis.
8. Do not attribute order-level delivery delays
   causally to individual merchants.
9. Treat simulated interventions separately from
   observed historical performance.

## Limitations
Olist represents traditional e-commerce rather than
DoorDash's on-demand grocery fulfillment operation.
It does not directly measure picker productivity,
stockouts, substitutions, or item-level accuracy.
