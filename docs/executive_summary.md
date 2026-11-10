# Marketplace Fulfillment Intelligence
## Executive Summary

### Business Problem

Marketplace fulfillment performance depends on reliable merchant operations, efficient order processing, and timely customer deliveries.

This project investigates historical fulfillment inefficiencies to identify where operational improvements should be prioritized and evaluates hypothetical merchant intervention strategies.

### Analytical Approach

Using **SQL (DuckDB) and Microsoft Excel**, the analysis examines 99,441 historical orders from the public Brazilian Olist e-commerce dataset.

The project includes:

- Order-level fulfillment KPIs and delivery reliability analysis.
- Merchant performance scorecards and late-delivery concentration analysis.
- Geographic, product-category, and processing-time diagnostics.
- Scenario modeling and cost-effectiveness comparisons.
- An Excel-based operational decision model and implementation scorecard.

### Key Findings

| Metric | Result |
|---|---:|
| Total marketplace orders | 99,441 |
| Delivered orders | 96,478 |
| Cancellation rate | 0.63% |
| Late deliveries | 6,534 |
| Late-delivery rate | 6.77% |
| Average processing time | 68.48 hours |
| Qualifying merchants | 615 |
| Top 10 merchants' share of qualifying-cohort late orders | 18.75% |

Merchant performance analysis identifies concentrated late-delivery exposure among higher-priority merchants.

Longer processing-time segments are also associated with higher late-delivery rates, indicating opportunities for further operational investigation.

These relationships are descriptive and do not establish causation.

### Operational Scenario Analysis

Three hypothetical merchant intervention strategies were evaluated.

| Scenario | Merchants | Modeled Late Orders Avoided | Assumed Implementation Cost |
|---|---:|---:|---:|
| Focused Outreach | 10 | 102 | $7,000 |
| Targeted Improvement | 25 | 358 | $14,500 |
| Expanded Improvement | 50 | 744 | $27,000 |

Under the modeled assumptions, Expanded Improvement produces the greatest reduction in late orders and the lowest cost per modeled avoided late order at $36.29.

However, its projected performance depends on unvalidated effectiveness assumptions and broader execution.

### Recommended Strategy

**Begin with a controlled 10-merchant pilot before scaling interventions.**

The pilot should focus on high-priority merchants and evaluate whether targeted operational support improves fulfillment reliability.

Success should be assessed through late-delivery rates, processing times, merchant participation, intervention costs, and cancellation-rate guardrails.

If a controlled pilot demonstrates measurable improvements, management can evaluate expansion to 25 or 50 merchants.

### Limitations and Assumptions

- The analysis uses historical public Olist data, not proprietary DoorDash operational data.
- Merchant rankings identify associations with late deliveries, not proven merchant-caused delays.
- Multi-seller orders are excluded from primary merchant-level attribution.
- Intervention effectiveness and implementation costs are hypothetical assumptions.
- Processing hours represent elapsed time, not direct labor-hour savings.
- Scenario benefits are alternatives and should not be added together.
- Observed improvements would require a controlled pilot or comparable evaluation.

### Business Value

The project demonstrates how SQL-based operational analysis and Excel-based decision modeling can support marketplace fulfillment monitoring, merchant prioritization, intervention planning, and evidence-based operational decisions.