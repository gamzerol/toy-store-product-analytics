-- =====================================================================
-- 02_data_quality_checks.sql  |  Can the data be trusted?
-- Run each block and record the result in docs/data_notes.md.
-- =====================================================================

-- CHECK 1: row counts and date range per table ------------------------
SELECT 'website_sessions' AS tbl, COUNT(*) AS n, MIN(created_at) AS first_ts, MAX(created_at) AS last_ts FROM website_sessions
UNION ALL SELECT 'website_pageviews', COUNT(*), MIN(created_at), MAX(created_at) FROM website_pageviews
UNION ALL SELECT 'orders',            COUNT(*), MIN(created_at), MAX(created_at) FROM orders
UNION ALL SELECT 'order_items',       COUNT(*), MIN(created_at), MAX(created_at) FROM order_items
UNION ALL SELECT 'order_item_refunds',COUNT(*), MIN(created_at), MAX(created_at) FROM order_item_refunds;

-- CHECK 2: orders whose session is missing --------------------------
SELECT COUNT(*) AS orphan_orders
FROM orders o
LEFT JOIN website_sessions s ON s.website_session_id = o.website_session_id
WHERE s.website_session_id IS NULL;

-- CHECK 3: order total equals the sum of its items ------------------
SELECT COUNT(*) AS mismatched_orders
FROM orders o
JOIN (
    SELECT order_id, SUM(price_usd) AS item_total, COUNT(*) AS item_cnt
    FROM order_items
    GROUP BY order_id
) i ON i.order_id = o.order_id
WHERE ROUND(o.price_usd, 2) <> ROUND(i.item_total, 2)
   OR o.items_purchased <> i.item_cnt;

-- CHECK 4: refunds that exceed the item price -----------------------
SELECT COUNT(*) AS over_refunded
FROM order_item_refunds r
JOIN order_items oi ON oi.order_item_id = r.order_item_id
WHERE r.refund_amount_usd > oi.price_usd;

-- CHECK 5: sessions with no pageviews ------------------------------
SELECT COUNT(*) AS sessions_without_pageviews
FROM website_sessions s
LEFT JOIN website_pageviews p ON p.website_session_id = s.website_session_id
WHERE p.website_pageview_id IS NULL;

-- CHECK 6: share of sessions with missing source (direct/organic) ----
SELECT
    COUNT(*) FILTER (WHERE utm_source IS NULL)                         AS null_source_sessions,
    ROUND(100.0 * COUNT(*) FILTER (WHERE utm_source IS NULL) / COUNT(*), 1) AS pct_null_source
FROM website_sessions;
