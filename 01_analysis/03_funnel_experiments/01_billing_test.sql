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
-- EXPLANATION:
-- * The test window is defined by the data, not guessed: it starts when the new
--   page first appears and ends when the old page last appears.
-- * FILTER (WHERE ...) lets one scan compute two different aggregates.

SELECT COUNT(*) AS sessions_seeing_both_pages
FROM (
    SELECT website_session_id
    FROM website_pageviews
    WHERE pageview_url IN ('/billing', '/billing-2')
    GROUP BY website_session_id
    HAVING COUNT(DISTINCT pageview_url) > 1
) t;
-- EXPLANATION: HAVING filters after grouping. A session that saw both versions
-- would contaminate the comparison, so we expect 0 here.

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
-- EXPLANATION:
-- * One row per billing-page session, tagged with the version it saw and whether it
--   ended in an order. LEFT JOIN keeps sessions that did not order.
-- * CROSS JOIN with the one-row CTE w makes the window dates available to the WHERE.
-- * Putting this in a view means every check below uses the same, auditable definition.

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
-- EXPLANATION:
-- * COUNT(order_id) ignores NULLs, so it counts sessions that converted.
-- * Send these four numbers (sessions and orders per version) to the stats script:
--   python 02_billing_test_stats.py <ctrl_sessions> <ctrl_orders> <var_sessions> <var_orders>
-- * Revenue per billing session is the guardrail: a page can lift conversion but
--   attract smaller baskets, so we check value, not only counts.

-- QUERY 2: balance check, were the groups comparable? -------------------
SELECT
    billing_version,
    ROUND(100.0 * COUNT(*) FILTER (WHERE device_type = 'mobile') / COUNT(*), 1) AS pct_mobile,
    ROUND(100.0 * COUNT(*) FILTER (WHERE channel_group = 'paid_nonbrand') / COUNT(*), 1) AS pct_paid_nonbrand,
    ROUND(100.0 * COUNT(*) FILTER (WHERE channel_group = 'direct') / COUNT(*), 1)        AS pct_direct
FROM v_billing_test
GROUP BY billing_version
ORDER BY billing_version;
-- EXPLANATION:
-- * A valid A/B comparison needs similar groups. If one version got far more mobile
--   or far more paid traffic, a difference in conversion could come from the audience,
--   not from the page.
-- * This is a sample-balance sanity check, the first thing to verify after a result.

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
-- EXPLANATION:
-- * If both versions appear every day in similar numbers, assignment was concurrent
--   (time cannot explain the difference). If one version only appears in certain weeks,
--   the comparison is confounded by time and seasonality.