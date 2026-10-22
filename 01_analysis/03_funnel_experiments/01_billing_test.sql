-- =====================================================================
-- Module 03 | Experiment 1: billing page test (/billing vs /billing-2)
-- Question: Did the new billing page (/billing-2) convert more billing
--           sessions into orders than the old one?
-- Design:   /billing-2 first appears on 2012-09-10 and /billing stops on
--           2013-01-05. Only inside that window were BOTH pages live, so
--           only that window is a fair comparison. Before it, only /billing
--           existed; after it, only /billing-2 existed.
-- Metric:   primary = billing-page session -> order conversion
--           guardrail = revenue per billing session
-- =====================================================================

SET search_path TO toystore;

-- QUERY 0: test window and overlap check -------------------------------
SELECT
    MIN(created_at) FILTER (WHERE pageview_url = '/billing-2') AS test_start,
    MAX(created_at) FILTER (WHERE pageview_url = '/billing')   AS test_end
FROM website_pageviews;

SELECT COUNT(*) AS sessions_seeing_both_pages
FROM (
    SELECT website_session_id
    FROM website_pageviews
    WHERE pageview_url IN ('/billing', '/billing-2')
    GROUP BY website_session_id
    HAVING COUNT(DISTINCT pageview_url) > 1
) t;

-- STEP 1: analysis view, one row per billing session in the window -------
CREATE OR REPLACE VIEW v_billing_test AS
WITH w AS (
    SELECT
        MIN(created_at) FILTER (WHERE pageview_url = '/billing-2') AS test_start,
        MAX(created_at) FILTER (WHERE pageview_url = '/billing')   AS test_end
    FROM website_pageviews
)
SELECT
    p.website_session_id,
    p.pageview_url   AS billing_version,
    s.device_type,
    s.channel_group,
    o.order_id,
    o.price_usd
FROM website_pageviews p
CROSS JOIN w
JOIN v_sessions_channel s ON s.website_session_id = p.website_session_id
LEFT JOIN orders o        ON o.website_session_id = p.website_session_id
WHERE p.pageview_url IN ('/billing', '/billing-2')
  AND p.created_at BETWEEN w.test_start AND w.test_end;

-- QUERY 1: the result: conversion by billing version ---------------------
SELECT
    billing_version,
    COUNT(*)                                             AS billing_sessions,
    COUNT(order_id)                                      AS orders,
    ROUND(COUNT(order_id)::numeric / COUNT(*), 4)        AS billing_to_order_cvr,
    ROUND(SUM(price_usd) / COUNT(*), 2)                  AS revenue_per_billing_session
FROM v_billing_test
GROUP BY billing_version
ORDER BY billing_version;

-- QUERY 2: balance check, were the groups comparable? -------------------
SELECT
    billing_version,
    ROUND(100.0 * COUNT(*) FILTER (WHERE device_type = 'mobile') / COUNT(*), 1) AS pct_mobile,
    ROUND(100.0 * COUNT(*) FILTER (WHERE channel_group = 'paid_nonbrand') / COUNT(*), 1) AS pct_paid_nonbrand,
    ROUND(100.0 * COUNT(*) FILTER (WHERE channel_group = 'direct') / COUNT(*), 1)        AS pct_direct
FROM v_billing_test
GROUP BY billing_version
ORDER BY billing_version;

-- QUERY 3: daily split, did both versions run side by side? --------------
SELECT
    p.created_at::date                                              AS day,
    COUNT(*) FILTER (WHERE p.pageview_url = '/billing')             AS billing_old,
    COUNT(*) FILTER (WHERE p.pageview_url = '/billing-2')           AS billing_new
FROM website_pageviews p
WHERE p.pageview_url IN ('/billing', '/billing-2')
  AND p.created_at BETWEEN '2012-09-10' AND '2013-01-06'
GROUP BY 1
ORDER BY 1;
