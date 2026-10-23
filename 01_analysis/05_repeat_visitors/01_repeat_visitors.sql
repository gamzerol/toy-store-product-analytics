-- =====================================================================
-- Module 05 | Repeat visitors
-- Question: Do visitors come back, and do they buy when they do?
-- Window: April 2012 to February 2015 (full months).
-- =====================================================================

SET search_path TO toystore;

-- Speeds up the user-level queries below
CREATE INDEX IF NOT EXISTS idx_sessions_user ON website_sessions (user_id);

-- QUERY 1: new vs repeat sessions
SELECT
    CASE WHEN s.is_repeat_session = 1 THEN 'repeat' ELSE 'new' END AS visitor_type,
    COUNT(*)                                           AS sessions,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_of_sessions,
    COUNT(o.order_id)                                  AS orders,
    ROUND(COUNT(o.order_id)::numeric / COUNT(*), 4)    AS session_to_order_cvr,
    ROUND(SUM(o.price_usd) / COUNT(*), 2)              AS revenue_per_session
FROM website_sessions s
LEFT JOIN orders o ON o.website_session_id = s.website_session_id
WHERE s.created_at >= '2012-04-01' AND s.created_at < '2015-03-01'
GROUP BY 1
ORDER BY 1;

-- QUERY 2: channel mix of new vs repeat sessions
SELECT
    v.channel_group,
    ROUND(100.0 * COUNT(*) FILTER (WHERE v.is_repeat_session = 0)
          / SUM(COUNT(*) FILTER (WHERE v.is_repeat_session = 0)) OVER (), 1) AS pct_of_new_sessions,
    ROUND(100.0 * COUNT(*) FILTER (WHERE v.is_repeat_session = 1)
          / SUM(COUNT(*) FILTER (WHERE v.is_repeat_session = 1)) OVER (), 1) AS pct_of_repeat_sessions
FROM v_sessions_channel v
WHERE v.created_at >= '2012-04-01' AND v.created_at < '2015-03-01'
GROUP BY v.channel_group
ORDER BY pct_of_repeat_sessions DESC;

-- QUERY 3: how many orders does each customer place?
WITH per_customer AS (
    SELECT user_id, COUNT(*) AS orders_placed
    FROM orders
    GROUP BY user_id
)
SELECT
    orders_placed,
    COUNT(*)                                           AS customers,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_of_customers
FROM per_customer
GROUP BY orders_placed
ORDER BY orders_placed;

-- QUERY 4: share of new visitors who come back within 30 days, by quarter
WITH first_visit AS (
    SELECT user_id, MIN(created_at) AS first_ts
    FROM website_sessions
    GROUP BY user_id
),
flagged AS (
    SELECT
        f.user_id,
        f.first_ts,
        EXISTS (
            SELECT 1
            FROM website_sessions s
            WHERE s.user_id = f.user_id
              AND s.created_at > f.first_ts
              AND s.created_at <= f.first_ts + INTERVAL '30 days'
        ) AS came_back
    FROM first_visit f
    WHERE f.first_ts >= '2012-04-01' AND f.first_ts < '2015-01-01'
)
SELECT
    DATE_TRUNC('quarter', first_ts)::date                         AS cohort_quarter,
    COUNT(*)                                                      AS new_visitors,
    COUNT(*) FILTER (WHERE came_back)                             AS came_back_30d,
    ROUND(100.0 * COUNT(*) FILTER (WHERE came_back) / COUNT(*), 1) AS return_rate_pct
FROM flagged
GROUP BY 1
ORDER BY 1;

-- QUERY 5: conversion by channel, new vs repeat visitors (like-for-like comparison)
SELECT
    v.channel_group,
    CASE WHEN v.is_repeat_session = 1 THEN 'repeat' ELSE 'new' END AS visitor_type,
    COUNT(*)                                        AS sessions,
    COUNT(o.order_id)                               AS orders,
    ROUND(COUNT(o.order_id)::numeric / COUNT(*), 4) AS session_to_order_cvr,
    ROUND(SUM(o.price_usd) / COUNT(*), 2)           AS revenue_per_session
FROM v_sessions_channel v
LEFT JOIN orders o ON o.website_session_id = v.website_session_id
WHERE v.created_at >= '2012-04-01' AND v.created_at < '2015-03-01'
GROUP BY 1, 2
ORDER BY 1, 2;
