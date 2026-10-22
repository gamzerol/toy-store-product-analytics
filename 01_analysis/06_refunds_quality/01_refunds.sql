-- =====================================================================
-- Module 06 | Refunds and quality
-- Question: Which products are refunded most, and did refunds spike at any point?
-- Window: the monthly view uses full months (2012-04 to 2015-02), grouped by month of sale.
-- Assumption: a refunded item's cost is not recovered (conservative view of margin).
-- =====================================================================

SET search_path TO toystore;

-- CHECK: at most one refund per item? (if not, the joins below would double count)
SELECT COUNT(*) AS refund_rows, COUNT(DISTINCT order_item_id) AS distinct_items
FROM order_item_refunds;

-- QUERY 1: refund rate and margin by product
SELECT
    p.product_name,
    COUNT(*)                                                         AS items_sold,
    COUNT(r.order_item_refund_id)                                    AS items_refunded,
    ROUND(100.0 * COUNT(r.order_item_refund_id) / COUNT(*), 1)       AS refund_rate_pct,
    ROUND(SUM(oi.price_usd), 0)                                      AS gross_revenue,
    ROUND(COALESCE(SUM(r.refund_amount_usd), 0), 0)                  AS refunded_usd,
    ROUND(100.0 * SUM(oi.price_usd - oi.cogs_usd) / SUM(oi.price_usd), 1) AS margin_pct_before_refunds,
    ROUND(100.0 * (SUM(oi.price_usd - oi.cogs_usd) - COALESCE(SUM(r.refund_amount_usd), 0))
          / SUM(oi.price_usd), 1)                                    AS margin_pct_after_refunds
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
LEFT JOIN order_item_refunds r ON r.order_item_id = oi.order_item_id
GROUP BY p.product_name
ORDER BY refund_rate_pct DESC;

-- QUERY 2: monthly refund rate by product (month of sale)
SELECT
    DATE_TRUNC('month', oi.created_at)::date AS month,
    COUNT(*)                                 AS items_sold,
    ROUND(100.0 * COUNT(r.order_item_refund_id) FILTER (WHERE oi.product_id = 1)
          / NULLIF(COUNT(*) FILTER (WHERE oi.product_id = 1), 0), 1) AS original_mr_fuzzy,
    ROUND(100.0 * COUNT(r.order_item_refund_id) FILTER (WHERE oi.product_id = 2)
          / NULLIF(COUNT(*) FILTER (WHERE oi.product_id = 2), 0), 1) AS love_bear,
    ROUND(100.0 * COUNT(r.order_item_refund_id) FILTER (WHERE oi.product_id = 3)
          / NULLIF(COUNT(*) FILTER (WHERE oi.product_id = 3), 0), 1) AS sugar_panda,
    ROUND(100.0 * COUNT(r.order_item_refund_id) FILTER (WHERE oi.product_id = 4)
          / NULLIF(COUNT(*) FILTER (WHERE oi.product_id = 4), 0), 1) AS mini_bear
FROM order_items oi
LEFT JOIN order_item_refunds r ON r.order_item_id = oi.order_item_id
WHERE oi.created_at >= '2012-04-01' AND oi.created_at < '2015-03-01'
GROUP BY 1
ORDER BY 1;
