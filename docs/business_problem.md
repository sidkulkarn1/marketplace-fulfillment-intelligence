# Business Problem & Recommended Action

## Decision to support

How should a marketplace operations team prioritize investigation and merchant support to improve delivery reliability with limited resources?

This project uses historical public Olist e-commerce data to build a decision-support workflow. It is not an analysis of proprietary DoorDash operations.

## Business questions

1. What are the baseline fulfillment, cancellation, processing, and delivery-reliability metrics?
2. Which merchants account for the greatest late-delivery exposure, and how do their volumes and rates differ?
3. What regional, category, and processing-time patterns merit further investigation?
4. How do alternative intervention scopes compare under explicit effectiveness and cost assumptions?
5. What evidence would justify expanding an initial merchant pilot?

## Delivered solution

Seven DuckDB SQL scripts transform nine source tables into audited order-level metrics, merchant scorecards, descriptive diagnostics, and hypothetical scenarios. Eight CSV exports feed five Excel dashboards, including a scenario model and implementation scorecard.

The historical baseline includes 99,441 orders and 6,534 late deliveries among 96,470 delivery-eligible orders (6.77%). The top 10 prioritized merchants account for 1,019 late deliveries, or 18.75% of late deliveries in the qualifying merchant cohort. That share is not a marketplace-wide percentage.

## Recommendation

Propose a controlled outreach pilot with 10 high-priority merchants. Compare outcomes with comparable control merchants and track late-delivery rates, processing times, participation, actual costs, and cancellation guardrails. Define the evaluation period and success thresholds before launch; use random assignment where feasible.

Expansion to 25 or 50 merchants should depend on measured effectiveness and operational feasibility. The larger modeled scenarios are decision aids, not evidence of realized benefits. No pilot has been completed as part of this project.

## Scope boundaries

Historical associations do not establish merchant responsibility for delays. The data does not directly measure picker productivity, substitutions, stockouts, or item-level accuracy. This project delivers analysis and pilot planning, not a deployed operational intervention.

See [methodology](methodology.md), [KPI definitions](kpi_dictionary.md), and [scenario assumptions](assumptions.md).
