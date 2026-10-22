# Metric dictionary

Definitions are fixed before any analysis so numbers stay comparable across modules.

| Metric | Definition | Source tables | Pitfalls |
|--------|------------|---------------|----------|
| Sessions | Count of distinct `website_session_id` | website_sessions | A session is a visit, not a person. Do not call it users. |
| Orders | Count of distinct `order_id` | orders | One order can contain several items. |
| Session-to-order CVR | Orders / sessions | orders, website_sessions | Compare like with like (same period, same segment). |
| Gross revenue | Sum of `orders.price_usd` | orders | Includes revenue later refunded. |
| Net revenue | Gross revenue minus refunded amount | orders, order_item_refunds | Refunds can land in a later month than the order. State which date is used. |
| AOV | Gross revenue / orders | orders | Moves with product mix and cross-sell. |
| Revenue per session (RPS) | Gross revenue / sessions | orders, website_sessions | Primary growth-efficiency metric because it combines conversion and order value. |
| Gross margin | (price_usd minus cogs_usd) / price_usd | orders | Use net of refunds when judging quality. |
| Items per order | `items_purchased` average | orders | Cross-sell indicator. |
| Refund rate | Refunded items / items sold | order_items, order_item_refunds | Measure by order-month cohort to avoid timing distortion. |
| Bounce rate | Sessions with exactly one pageview / sessions | website_pageviews | Landing page quality indicator. |
| Repeat session rate | Sessions with `is_repeat_session = 1` / sessions | website_sessions | Not the same as customer retention. |

North Star metric: **net revenue per session**. Guardrails: refund rate, gross margin.
