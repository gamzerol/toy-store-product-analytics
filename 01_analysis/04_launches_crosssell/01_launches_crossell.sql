-- =====================================================================
-- Module 04 | Product launches and cross-sell
-- Questions: Did new products and cross-sell grow revenue and margin?
--            Which products are bought together?
-- Window:    full months only (2012-04-01 to 2015-02-28) for monthly views.
-- Caution:   launches and cross-sell were not randomized. Pre/post comparisons are
--            descriptive: seasonality and other site changes overlap with them.
-- =====================================================================

SET search_path TO toystore;

-- QUERY 1: when did cross-sell start? -----------------------------------
SELECT
    MIN(created_at) FILTER (WHERE is_primary_item = 0) AS first_cross_sell_item,
    COUNT(*)        FILTER (WHERE is_primary_item = 0) AS cross_sell_items,
    COUNT(*)                                           AS all_items
FROM order_items;
-- EXPLANATION:
-- * is_primary_item = 0 marks an add-on item bought together with the main one.
-- * The first such timestamp dates the cross-sell launch from the data itself.

-- QUERY 2: monthly basket metrics ---------------------------------------
SELECT
    DATE_TRUNC('month', created_at)::date                           AS month,
    COUNT(*)                                                        AS orders,
    ROUND(AVG(items_purchased), 3)                                  AS items_per_order,
    ROUND(100.0 * COUNT(*) FILTER (WHERE items_purchased > 1) / COUNT(*), 1) AS pct_orders_with_cross_sell,
    ROUND(AVG(price_usd), 2)                                        AS aov,
    ROUND(100.0 * SUM(price_usd - cogs_usd) / SUM(price_usd), 1)    AS gross_margin_pct
FROM orders
WHERE created_at >= '2012-04-01' AND created_at < '2015-03-01'
GROUP BY 1
ORDER BY 1;
-- EXPLANATION:
-- * Items per order and the share of multi-item orders measure cross-sell adoption.
-- * Gross margin % shows whether the extra items are profitable, not only bigger baskets.
-- * Line this up with the AOV steps seen in module 01.

-- QUERY 3: which products are bought together? ---------------------------
SELECT
    p1.product_name AS primary_product,
    p2.product_name AS cross_sell_product,
    COUNT(*)        AS orders
FROM order_items oi
JOIN orders o    ON o.order_id    = oi.order_id
JOIN products p1 ON p1.product_id = o.primary_product_id
JOIN products p2 ON p2.product_id = oi.product_id
WHERE oi.is_primary_item = 0
GROUP BY 1, 2
ORDER BY orders DESC;
-- EXPLANATION:
-- * Joins the products table twice under two aliases: once for the main product of the
--   order, once for the add-on item.
-- * The top pairs show which bundles customers choose and where a recommendation or
--   bundle offer could be tested.

-- QUERY 4: revenue and margin by product, per quarter ---------------------
SELECT
    DATE_TRUNC('quarter', oi.created_at)::date                       AS quarter,
    p.product_name,
    COUNT(*)                                                         AS items_sold,
    ROUND(SUM(oi.price_usd), 0)                                      AS revenue,
    ROUND(100.0 * SUM(oi.price_usd - oi.cogs_usd) / SUM(oi.price_usd), 1) AS margin_pct
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
WHERE oi.created_at >= '2012-04-01' AND oi.created_at < '2015-01-01'
GROUP BY 1, 2
ORDER BY 1, 3 DESC;
-- EXPLANATION:
-- * Quarterly to keep the table readable; ends at 2014-12-31 so the last quarter is full.
-- * Shows each product's contribution and whether newer products carry better or worse margin.

-- QUERY 5: 30 days before vs 30 days after each launch --------------------
WITH launches AS (
    SELECT product_id, product_name, created_at AS launch_ts
    FROM products
    WHERE product_id > 1                      -- product 1 is the original product
)
SELECT
    l.product_name,
    CASE WHEN s.created_at < l.launch_ts THEN '1_pre_30d' ELSE '2_post_30d' END AS period,
    COUNT(DISTINCT s.website_session_id)                                       AS sessions,
    COUNT(o.order_id)                                                          AS orders,
    ROUND(COUNT(o.order_id)::numeric / COUNT(DISTINCT s.website_session_id), 4) AS session_to_order_cvr,
    ROUND(SUM(o.price_usd) / COUNT(DISTINCT s.website_session_id), 2)          AS revenue_per_session,
    ROUND(AVG(o.price_usd), 2)                                                 AS aov,
    ROUND(100.0 * SUM(o.price_usd - o.cogs_usd) / NULLIF(SUM(o.price_usd), 0), 1) AS gross_margin_pct
FROM launches l
JOIN website_sessions s
  ON s.created_at >= l.launch_ts - INTERVAL '30 days'
 AND s.created_at <  l.launch_ts + INTERVAL '30 days'
LEFT JOIN orders o ON o.website_session_id = s.website_session_id
GROUP BY l.product_name, l.launch_ts, period
ORDER BY l.launch_ts, period;
-- EXPLANATION:
-- * Each launch becomes a pair of 30-day windows around its date. A range join (ON with
--   date conditions) attaches every session to the launches whose window contains it.
-- * The CASE splits each window into pre and post. Compare revenue per session, AOV and
--   margin: a launch can lift basket size without changing conversion.
-- * Descriptive only: the December 2013 launch sits inside the holiday season, so a
--   rise there is partly seasonality. Say this explicitly when presenting the result.