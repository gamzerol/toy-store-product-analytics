# Toy Store Product Analytics: Funnel, Experiments and Growth Decisions

**Gamze Erol** | Product Analyst portfolio project
Tools: PostgreSQL, Python (pandas, statsmodels), BI dashboard (tool TBD), Excel/PowerPoint

> **Status: work in progress.** Findings below are placeholders (`TBD`) and will be filled in as each analysis module is finished. No number in this README is real until its module links to the SQL and output that produced it.

---

## 1. Scenario

Maven Fuzzy Factory is an online retailer that sells teddy bears. I act as the company's **first product analyst** and answer the questions a product lead and a CEO would ask:

1. Is the business growing in a healthy way, and where does growth come from?
2. Where do visitors drop out of the purchase funnel, and which fixes are worth building first?
3. Did the website experiments (landing page, billing page) actually work?
4. Did new product launches and cross-sell grow revenue and margin?
5. Are customers coming back?
6. Is product quality (refunds) putting growth at risk?

Each module ends with a **recommendation, an expected impact (labelled as a scenario) and a metric to track after launch.**

## 2. Executive summary

| # | Finding | Decision recommended | Evidence |
|---|---------|----------------------|----------|
| 1 | TBD | TBD | [module 01](01_analysis/01_growth_trends) |
| 2 | TBD | TBD | module 02 |
| 3 | TBD | TBD | module 03 |
| 4 | TBD | TBD | module 04 |

## 3. Data and transparency

- Source: [Maven Analytics, Toy Store E-Commerce Database](https://mavenanalytics.io/data-playground/toy-store-e-commerce-database) (public domain, case-study data).
- Tables: website sessions, pageviews, products, orders, order items, order item refunds. Schema and load steps: [`data/`](data) and [`01_analysis/00_setup`](01_analysis/00_setup).
- This is a case-study dataset about a fictional business. Results show analytical method and product judgment, not real company performance.
- Observational analysis generates hypotheses. Only experiments support causal claims. Scenario models are labelled as scenarios.

## 4. Repository structure

```
01_analysis/            SQL and notebooks, one folder per module
02_decision_center/     metric tree, insight register, RICE prioritization, experiment backlog
03_operating_model/     PRD, user stories, tracking plan, RACI for the top recommendations
dashboard/              BI file and screenshots
docs/                   metric dictionary, data notes
data/                   schema notes (raw data is not committed)
```

## 5. Analysis modules

| Module | Question | Methods | Status |
|--------|----------|---------|--------|
| 00 Setup and data quality | Can the data be trusted? | schema, integrity checks | in progress |
| 01 Growth trends | How do sessions, orders, conversion and revenue per session evolve? | monthly aggregates, window functions | in progress |
| 02 Channel and device | Which channels and devices create profitable conversion? | segmentation, conversion by source | todo |
| 03 Funnel and experiments | Where is the funnel leaking? Did the tests win? | funnel CTEs, two-proportion test, confidence intervals, power | todo |
| 04 Product launches and cross-sell | Did launches and cross-sell lift revenue and margin? | pre/post comparison, AOV, margin | todo |
| 05 Repeat visitors | Do customers return and buy again? | cohorts, retention | todo |
| 06 Refunds and quality | Which products drive refunds and how much margin do they cost? | refund rate by product and month | todo |

## 6. Decision center (in `02_decision_center/`)

Metric tree, insight register, RICE-ranked recommendations and an experiment backlog. Every recommendation lists a primary metric and guardrails.

## 7. Operating model (in `03_operating_model/`)

For the top two recommendations: a short PRD, user stories with acceptance criteria, a tracking plan (events and definitions), a RACI and key risks.

## 8. Metric definitions

See [`docs/metric_dictionary.md`](docs/metric_dictionary.md).

## 9. Limitations

Filled in per module. General limits: observational data, no user demographics, no marketing spend data, so CAC and LTV:CAC are not computed.

## 10. How to reproduce

1. Download the CSV files from Maven Analytics (free account) into `data/raw/` (git-ignored).
2. Create a PostgreSQL database and run `01_analysis/00_setup/01_schema.sql`.
3. Load the CSVs (commands in `01_schema.sql`), then run `02_data_quality_checks.sql`.
4. Run the module SQL files in numeric order.
