# Experiment backlog

Rules for all three: split visitors randomly by user (so returning visitors keep the same version), run both versions at the same time for full weeks, decide the primary metric and sample size before launch, and do not stop early on a good-looking result. Sample sizes assume 5% significance and 80% power. Traffic in the last 3 months was about twice the 35-month average, so real durations should be shorter than shown.

| # | Experiment | Hypothesis | Primary metric (baseline) | Smallest effect to detect | Sample per version | Duration at average traffic | Guardrails |
|---|------------|------------|---------------------------|---------------------------|--------------------|-----------------------------|------------|
| 1 | Mobile landing page: show products sooner | Mobile visitors leave before they see products, so showing them sooner raises the share that reaches /products | Landing to products, mobile (47.3%) | +10% relative (to 52.0%) | 1,756 sessions | about 1 month (4,000 mobile sessions per month) | Bounce rate, orders per session, AOV |
| 2 | Cross-sell: show the top bundle first | Suggesting the most popular add-on (Mini Bear with Original Mr. Fuzzy) raises the share of orders with an add-on | Orders with an add-on (about 35%) | +5 points (to 40%) | 1,470 orders | about 3.3 months (1.4 months at recent volume) | Revenue per cart session (decision metric), cart to order conversion, AOV, gross margin, refund rate |
| 3 | Mobile checkout simplification | Fewer steps and fields on mobile raise the share of carts that become orders | Cart to order, mobile (22.9%) | +20% relative (to 27.4%) | 1,412 carts | about 5 months (2.6 months at about 2x recent volume) | AOV, refund rate, payment errors (not in the data) |

Why experiment 3 targets +20%: a +10% effect would need 5,481 carts per version, about 20 months at average traffic. If a small improvement is all the team expects, this test is not worth running.

## Before launching any of them

- Check that the groups look alike on device and channel mix (the same check used in the billing test).
- Confirm the events needed to measure the primary metric are tracked (see the product brief in `03_operating_model/`).
