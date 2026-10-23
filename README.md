# Toy Store Product Analytics: Funnel, Experiments and Growth Decisions

Tools: PostgreSQL, Python (statsmodels), Tableau Public, Excel

> **[Live dashboard on Tableau Public](https://public.tableau.com/app/profile/gamze.erol/viz/ToyStoreProductAnalytics/Dashboard)**

---

## 1. Scenario

Maven Fuzzy Factory is an online store that sells teddy bears. I act as its first product analyst and answer the questions a product lead and a CEO would ask:

1. Is growth healthy, and where does it come from?
2. Where do visitors drop out of the funnel, and what is worth fixing first?
3. Did the website experiments work?
4. Did new products and cross-sell grow revenue and margin?
5. Do customers come back?
6. Are refunds a quality risk?

## 2. Summary

Window: April 2012 to February 2015 (35 full months). Revenue is gross unless stated.

| #   | What I found                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          | What I would do                                                                                                                                                                                                                    | Details                                                                                 |
| --- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------- |
| 1   | Revenue per session grew about 4x ($1.33 to $5.43). Most of it came from conversion (2.7% to 8.7%), the rest from bigger baskets.                                                                                                                                                                                                                                                                                                                                                                     | Keep working on conversion and basket size, not only traffic.                                                                                                                                                                      | [module 01](01_analysis/01_growth_trends)                                               |
| 2   | Mobile is 31% of sessions but converts 3.1% vs 8.5% on desktop. It loses visitors at every funnel step, also within paid non-brand traffic.                                                                                                                                                                                                                                                                                                                                                           | Test mobile fixes. Closing a quarter of the gap in browsing or in checkout is worth about 2% of revenue each (scenario).                                                                                                           | [module 03](01_analysis/03_funnel_experiments)                                          |
| 3   | The new billing page beat the old one in a concurrent test: 45.1% to 62.1% (+17 points, 95% CI +13.7 to +20.3).                                                                                                                                                                                                                                                                                                                                                                                       | Rolled out in Jan 2013. Keep monitoring.                                                                                                                                                                                           | [billing test](01_analysis/03_funnel_experiments/01_billing_test.sql)                   |
| 4   | /lander-1 lowered bounce rate (58.6% to 53.1%). The conversion lift was positive but not significant: the test was too small (about 2,300 sessions per page, about 9,000 needed).                                                                                                                                                                                                                                                                                                                     | Size landing page tests before running them.                                                                                                                                                                                       | [landing tests](01_analysis/03_funnel_experiments/03_landing_page_tests.sql)            |
| 5   | Cross-sell started in Sep 2013 and is now in about one in three orders. Add-ons are about 15% of all-time revenue (estimate) and lifted gross margin from 61% to 63%. Mini Bear is 57% of add-ons.                                                                                                                                                                                                                                                                                                    | Test showing the top bundle first.                                                                                                                                                                                                 | [module 04](01_analysis/04_launches_crosssell)                                          |
| 6   | Paid non-brand brings 71.5% of sessions. Among new visitors it converts about as well as the free channels (6.7% vs 6.6-7.2%). Free channels look better per session ($4.36-4.71 vs $3.97) mostly because about 63% of their sessions are return visitors, who convert better (see 7). Paid social converts at half the rate (3.2%).                                                                                                                                                                  | Do not scale paid social without spend data. Whether paid non-brand is worth its cost also needs spend data.                                                                                                                       | [module 02](01_analysis/02_channel_device), [module 05](01_analysis/05_repeat_visitors) |
| 7   | About 1 in 6 sessions is a return visit. Return visits convert better (7.8% vs 6.6%), bring about 19% of orders, and come only through free channels (organic, brand search and direct, about a third each), never through paid ads. Only 1.9% of customers buy twice, so most orders in return visits are first purchases: at least 1 in 6 customers needed a second visit to buy. The 30-day return rate doubled from 3.4% to 6.9% across cohorts, which explains part of the rise of free traffic. | Judge channels on new visitors and on what they bring back, not on session revenue alone. Do not start with a retention programme: low repeat purchase fits a gift-type product. Find out why first purchases need a second visit. | [module 05](01_analysis/05_repeat_visitors)                                             |
| 8   | Refunds are 4.3% of items (4.4% of revenue) and differ by product: Sugar Panda 6.0%, Original Mr. Fuzzy 5.1%, Love Bear 2.2%, Mini Bear 1.3%. Original Mr. Fuzzy items sold in Aug and Sep 2014 were refunded at 13.8% and 13.3% (2.3-5.7% in every other month since Sep 2013; it ran higher in 2012, up to 9.1%), back to 2.5% in Oct 2014. Refunds cut Original's margin from 61.0% to 55.9%.                                                                                                      | Track refund rate by product and month as a guardrail, with an alert at about 8%. Lead cross-sell with Mini Bear (lowest refund rate, 67.1% margin after refunds), not Sugar Panda.                                                | [module 06](01_analysis/06_refunds_quality)                                             |

## 3. Data

- Source: [Maven Analytics, Toy Store E-Commerce Database](https://mavenanalytics.io/data-playground/toy-store-e-commerce-database) (public domain case-study data about a fictional business). Results show method and judgement, not real company performance.
- Six tables: sessions, pageviews, products, orders, order items, refunds. Setup and quality checks: [`01_analysis/00_setup`](01_analysis/00_setup). Metric definitions: [`docs/metric_dictionary.md`](docs/metric_dictionary.md).
- Observational analysis gives hypotheses. Only experiments support cause and effect. Scenarios are labelled as scenarios.

## 4. Repository

```
01_analysis/          SQL and Python, one folder per module
02_decision_center/   metric tree, insights and priorities, experiment backlog
dashboard/            Tableau Public dashboard and the aggregated CSVs behind it
03_operating_model/   product brief and Excel scenario model for the top recommendation
docs/                 metric dictionary
data/                 schema notes (raw data is not committed)
```

## 5. Modules

| Module                     | Question                                                    | Status |
| -------------------------- | ----------------------------------------------------------- | ------ |
| 00 Data quality            | Can the data be trusted?                                    | done   |
| 01 Growth                  | How do sessions, conversion and revenue per session change? | done   |
| 02 Channel and device      | Which channels and devices create valuable conversion?      | done   |
| 03 Funnel and experiments  | Where is the funnel leaking? Did the tests win?             | done   |
| 04 Launches and cross-sell | Did new products and add-ons lift revenue and margin?       | done   |
| 05 Repeat visitors         | Do visitors come back and buy again?                        | done   |
| 06 Refunds                 | Which products are refunded and what does it cost?          | done   |

## 6. Decision center

[Metric tree](02_decision_center/metric_tree.md), [insights and priorities](02_decision_center/insights_and_priorities.md) (RICE), [experiment backlog](02_decision_center/experiment_backlog.md).

## 7. Dashboard

[Tableau Public dashboard](https://public.tableau.com/app/profile/gamze.erol/viz/ToyStoreProductAnalytics/Dashboard) with four views: revenue per session and conversion by month, funnel by device, cross-sell share, and refund rate by product. It reads the aggregated CSVs in [`dashboard/data`](dashboard/data), exported from the SQL in modules 01, 03, 04 and 06.

![Dashboard preview](dashboard/dashboard.png)

## 8. Product brief

[Product brief for the cross-sell experiment](03_operating_model/product_brief_cross_sell.md): problem, metrics, user stories, tracking events and risks. The impact and sample size can be changed in [`cross_sell_scenario.xlsx`](03_operating_model/cross_sell_scenario.xlsx).

## 9. Limitations

- Observational data: device and channel gaps are hypotheses, not causes.
- No spend data, so CAC and LTV:CAC are not computed. Margin per session is used as a break-even ceiling for cost per session (first order only).
- The first and last months of the data are partial and excluded.
- How visitors were assigned in the experiments is not documented. The billing test ran concurrently with balanced groups, but randomization cannot be proven.
- Landing pages are routed by device and channel, so only concurrent comparisons within one segment are used.
- Product launch comparisons are before/after, not tests. Other changes overlap (billing rollout in Jan 2013, holiday season in Dec 2013), so I read basket effects there, not conversion.
- Funnel steps mean "the session reached the page"; strict order is not enforced.
- Channel is taken per session, so the channel of a first visit gets no credit for orders placed on later visits.
- Refunds are assigned to the month of sale; the data ends about a month after the last sale, so the latest months may be slightly incomplete.

## 10. How to reproduce

1. Download the CSVs from Maven Analytics (free account) into `data/raw/` (git-ignored).
2. Create a PostgreSQL schema `toystore`, run `01_analysis/00_setup/01_schema.sql`, load the CSVs, then run `02_data_quality_checks.sql`.
3. Run the module SQL files in numeric order.
4. For the statistical tests: `pip install statsmodels` in a virtual environment, then run `01_analysis/03_funnel_experiments/02_billing_test_stats.py` with the counts from the SQL output (usage in the script header).
