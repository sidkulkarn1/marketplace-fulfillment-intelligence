# Assumptions & Limitations

## Historical measurement rules

- Preserve source records in the `raw` schema; exclude invalid observations only from the affected metric.
- Use one row per order for marketplace KPIs. Orders without items remain in marketplace status counts.
- Calculate durations only for delivered orders with both required timestamps and a nonnegative interval.
- Define lateness by calendar date: actual delivery date strictly after estimated delivery date. Same-day delivery is not late.
- Use single-seller orders for primary merchant attribution. Require at least 30 delivery-eligible orders for the priority cohort.
- Rank merchants by late-delivery volume, then late-delivery rate, then seller ID. Rankings identify exposure, not causal responsibility.
- Use the qualifying merchant cohort as the denominator for merchant Pareto shares.
- Treat processing and transit measures as elapsed time, not labor hours.

## SQL scenario inputs

The inputs below are explicitly hypothetical and defined in [SQL 06](../sql/06_scenario_analysis.sql).

| Scenario | Top-ranked merchants | Assumed late-order reduction | Assumed processing-time reduction |
|---|---:|---:|---:|
| Focused Merchant Outreach | 10 | 10% | 5% |
| Targeted Performance Improvement | 25 | 20% | 10% |
| Expanded Merchant Improvement | 50 | 30% | 15% |

Reductions apply to each selected cohort's historical baseline. The model holds eligible delivery volume constant; it does not forecast demand or simulate changes in merchant behavior, capacity, or carrier performance. Modeled avoided late orders are rounded to whole orders before the remaining late orders and modeled rate are calculated. Processing reductions are modeled separately and do not establish that faster processing causes fewer late deliveries.

These scenarios overlap and are alternatives: their benefits must not be added together. The full historical baseline is not an annualized savings forecast.

## Excel cost assumptions

The implementation scorecard and [executive summary](executive_summary.md) use assumed costs of $7,000, $14,500, and $27,000 for the three scenarios. These costs are Excel model inputs, not costs observed in Olist or calculated by SQL 06. Cost per modeled avoided late order divides assumed total cost by modeled avoided orders; it is not verified ROI, profit, or financial savings. The dollar notation represents the model's assumed budget units, not a currency conversion from source transactions.

## Interpretation and validation

Historical data describes associations. Unobserved factors, regional mix, carrier performance, and selection into merchant cohorts may affect comparisons. The minimum cohort threshold does not establish statistical significance.

All intervention benefits and costs remain unvalidated. A proposed controlled pilot should measure outcomes, actual costs, participation, and cancellation guardrails before any scaling decision. The feedback loop in the README is proposed future work, not an implemented production process.

See [KPI definitions](kpi_dictionary.md) for denominators and [audit findings](phase1_audit_summary.md) for data-quality limitations.
