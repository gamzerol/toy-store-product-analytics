# Insights and priorities

## Insight register

| # | Insight | Evidence | Confidence |
|---|---------|----------|------------|
| 1 | Mobile is 31% of sessions but converts 3.1% vs 8.5% on desktop, and loses visitors at every funnel step. | Module 03, funnel by device (holds within paid non-brand traffic) | Medium: observational, mobile visitors may have different intent |
| 2 | The new billing page converted 62.1% of billing sessions vs 45.1% for the old one (+17 points). | Module 03, billing test: concurrent, balanced groups, p < 0.001 | High |
| 3 | /lander-1 cut bounce rate from 58.6% to 53.1%. The conversion lift (3.2% to 4.0%) is not statistically significant. | Module 03, landing test: concurrent window, paid non-brand only | Medium for bounce, low for conversion |
| 4 | Cross-sell adds about $0.3M (15% of all-time revenue, estimate) and lifted gross margin from 61% to 63%, because add-ons carry about 67% margin. | Module 04: monthly basket metrics, product mix | Medium: before/after, not a test |
| 5 | Mini Bear is the engine of cross-sell: 57% of add-ons, and the top pair is Original Mr. Fuzzy + Mini Bear (3,126 orders). AOV rose $6.73 in the 30 days after its launch. | Module 04: product pairs and launch windows | Medium-low: launch window is descriptive |
| 6 | Paid non-brand brings 71.5% of sessions at lower revenue per session than free channels. Paid social converts at half its rate. | Module 02 | Medium: no spend data |

## Priorities (RICE)

Reach = sessions or orders per month, averaged over the 35 full months. Impact: 1 = medium. Confidence and effort are my judgement; effort (person-months) should be replaced with engineering estimates.

| Initiative | Reach | Impact | Confidence | Effort | Score |
|------------|-------|--------|------------|--------|-------|
| B. Mobile landing page: show products sooner | 4,014 mobile sessions | 1 (about +2% revenue if a quarter of the gap closes) | 50% (landing test moved bounce, not clearly conversion) | 2 | 1,003 |
| C. Cross-sell: show the top bundle first (Mini Bear with Original) | 886 orders | 1 (about +3% revenue per order if attach rate goes 35% to 40%) | 50% | 0.5 | 886 |
| A. Mobile checkout simplification | 544 mobile cart sessions | 1 (about +2% revenue if a quarter of the gap closes) | 60% (the billing test shows checkout changes can move conversion a lot) | 2 | 163 |

Score = reach x impact x confidence / effort. The ranking is driven mostly by reach and effort, so I treat it as a guide, not a verdict.

## Decisions I would recommend

1. **Run B and C first.** Both can reach a result within about 1 to 3 months (see the experiment backlog).
2. **Start A with a bigger change** (target at least +20% relative lift). Mobile cart traffic is small, so a +10% effect would need about 20 months at average traffic.
3. **Do not scale paid social** until cost per session is known. First-order margin per session ($1.32) is its break-even ceiling.
4. **Size every landing page test before running it.** The /lander-1 test needed about 9,000 sessions per page to detect its conversion lift and had about 2,300.
5. **Keep tracking refunds** as a guardrail on every initiative (module 06).
