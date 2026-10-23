# Product brief: lead the cart add-on with Mini Bear

Owner: product analyst · Status: proposal · Evidence: modules 04 and 06, experiment 2 in the [experiment backlog](../02_decision_center/experiment_backlog.md)

## 1. Problem

About 35% of orders include an add-on (31-37% since Feb 2014). Add-ons are about 15% of all-time revenue (estimate) at about 67% margin, against 61% for the first product. The other 65% of orders have none.

- The top pair is Original Mr. Fuzzy + Mini Bear (3,126 orders). Orders with Original as the main item account for 75% of add-on items (5,757 of 7,712).
- Mini Bear has the lowest refund rate (1.3%) and keeps 67.1% margin after refunds. Sugar Panda has the highest refund rate (6.0%).

Open point: the data has no event for the add-on offer (no page view or click). I assume it sits on the cart page, because add-ons arrive inside the same order and there is no separate page. Confirm this with the team before building.

## 2. Goal

Raise the share of orders with an add-on from about 35% to 40% without hurting checkout.

## 3. Change

For carts without an add-on, show Mini Bear first as the suggested add-on (unless Mini Bear is already the main item). Nothing else changes.

## 4. Metrics

| Role | Metric | Baseline |
|------|--------|----------|
| Primary | Share of orders with an add-on | about 35% |
| Decision | Revenue per cart session | measured in the test |
| Guardrails | Cart to order conversion, AOV, gross margin, refund rate of add-on items | 34% (cart to order), $62.48, 63.5%, 1.3% (Mini Bear) |

Ship if the add-on share goes up and revenue per cart session does not go down. The decision metric matters because a version that makes fewer people check out could still show a higher add-on share among those who do. The test is sized for the add-on share only; guardrails catch large drops but are not proven safe.

## 5. User stories and acceptance criteria

**As a shopper with Original Mr. Fuzzy in my cart, I want to see Mini Bear suggested first, so I can add a small extra in one click.**
- Given a cart with Original Mr. Fuzzy and no add-on, when the cart page loads for the new version, then Mini Bear is the first suggestion.
- When I add it, the order total and item count update without leaving the cart page.

**As a shopper who does not want an add-on, I want to reach checkout as before.**
- The path to checkout needs no extra click or field compared with today.

**As the analyst, I want to see which add-on was offered and whether it was added.**
- Every order can be tied to its test version and the offer shown (events in section 6).

## 6. Tracking plan

| Event | When | Key fields |
|-------|------|-----------|
| cart_viewed | Cart page loads | user_id, session_id, cart items, version |
| cross_sell_shown | Add-on offer is displayed | user_id, session_id, main product, suggested product, version |
| cross_sell_added | Visitor adds the add-on | same fields plus price |
| cross_sell_removed | Visitor removes the add-on | same fields |
| order_placed | Thank-you page (already exists) | order_id, items, revenue |

Today there is no offer event, so the share of carts that saw the offer is unknown. These events need to exist before launch.

## 7. Experiment design

- Random 50/50 split by user, both versions at the same time, full weeks.
- 1,470 orders per version (5% significance, 80% power, +5 points). That is about 3.3 months at the 35-month average volume and about 1.4 months at the recent volume of about 2,160 orders per month.
- Check that both versions look alike on device and channel before reading results, as in the billing test.
- Sample size and impact can be changed in [`cross_sell_scenario.xlsx`](cross_sell_scenario.xlsx).

## 8. Expected impact (scenario, not a forecast)

If the add-on share goes from 35% to 40% and the extra add-ons are Mini Bear ($29.99): +$1.50 per order (+2.4% of AOV), about $3,200 per month at recent volume, with about 68% gross margin. This assumes conversion does not change.

## 9. Risks

- The add-on distracts from checkout: watch cart to order conversion and revenue per cart session.
- Extra add-ons are low-quality purchases: watch the refund rate of add-on items.
- Mini Bear replaces higher-priced add-ons (Love Bear $59.99, Original $49.99): watch AOV.
- The offer location is an assumption: confirm it before building.
