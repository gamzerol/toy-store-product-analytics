-- =====================================================================
-- Module 03 | Experiments 2+: landing page tests (/home, /lander-1 ... /lander-5)
-- Questions: Which landing page keeps visitors and converts them best?
--            Are the comparisons fair (same traffic, same period)?
-- Metrics:   primary   = session -> order conversion
--            diagnostic = bounce rate (session with exactly one pageview)
-- Caution:   several pages overlap in time. Overlap does not prove random
--            assignment, so we check traffic composition before comparing.
-- =====================================================================

SET search_path TO toystore;

-- STEP 1: one row per session with its landing page --------------------
CREATE OR REPLACE VIEW v_sessions_landing AS
WITH first_pv AS (
    SELECT
        website_session_id,
        MIN(website_pageview_id) AS first_pv_id,
        COUNT(*)                 AS pageviews
    FROM website_pageviews
    GROUP BY website_session_id
)
SELECT
    s.website_session_id,
    s.created_at,
    s.device_type,
    s.channel_group,
    p.pageview_url      AS landing_page,
    (f.pageviews = 1)   AS is_bounce,
    o.order_id,
    o.price_usd
FROM first_pv f
JOIN website_pageviews p   ON p.website_pageview_id = f.first_pv_id
JOIN v_sessions_channel s  ON s.website_session_id  = f.website_session_id
LEFT JOIN orders o         ON o.website_session_id  = f.website_session_id;

-- QUERY 1: who sees which landing page? (composition check) ------------
SELECT
    landing_page,
    COUNT(*)                                                                       AS sessions,
    ROUND(100.0 * COUNT(*) FILTER (WHERE channel_group = 'paid_nonbrand') / COUNT(*), 1) AS pct_paid_nonbrand,
    ROUND(100.0 * COUNT(*) FILTER (WHERE channel_group = 'paid_brand')    / COUNT(*), 1) AS pct_paid_brand,
    ROUND(100.0 * COUNT(*) FILTER (WHERE channel_group = 'organic_search')/ COUNT(*), 1) AS pct_organic,
    ROUND(100.0 * COUNT(*) FILTER (WHERE channel_group = 'direct')        / COUNT(*), 1) AS pct_direct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE channel_group = 'paid_social')   / COUNT(*), 1) AS pct_social,
    ROUND(100.0 * COUNT(*) FILTER (WHERE device_type = 'mobile')          / COUNT(*), 1) AS pct_mobile
FROM v_sessions_landing
WHERE created_at >= '2012-04-01' AND created_at < '2015-03-01'
GROUP BY landing_page
ORDER BY landing_page;

-- QUERY 2: monthly sessions by landing page (overlap map) ---------------
SELECT
    DATE_TRUNC('month', created_at)::date                         AS month,
    COUNT(*) FILTER (WHERE landing_page = '/home')                AS home,
    COUNT(*) FILTER (WHERE landing_page = '/lander-1')            AS lander_1,
    COUNT(*) FILTER (WHERE landing_page = '/lander-2')            AS lander_2,
    COUNT(*) FILTER (WHERE landing_page = '/lander-3')            AS lander_3,
    COUNT(*) FILTER (WHERE landing_page = '/lander-4')            AS lander_4,
    COUNT(*) FILTER (WHERE landing_page = '/lander-5')            AS lander_5
FROM v_sessions_landing
WHERE created_at >= '2012-04-01' AND created_at < '2015-03-01'
GROUP BY 1
ORDER BY 1;

-- QUERY 3A: when did /home and /lander-1 actually compete for paid non-brand traffic?
SELECT
    DATE_TRUNC('week', created_at)::date                       AS week,
    COUNT(*) FILTER (WHERE landing_page = '/home')             AS home_sessions,
    COUNT(*) FILTER (WHERE landing_page = '/lander-1')         AS lander_1_sessions
FROM v_sessions_landing
WHERE channel_group = 'paid_nonbrand'
  AND created_at >= '2012-06-01' AND created_at < '2012-10-01'
GROUP BY 1
ORDER BY 1;

-- QUERY 3B: home vs lander-1 on paid non-brand, concurrent window only -----------
-- Start = first /lander-1 session. End = date when /home stops receiving paid non-brand
-- traffic, read from Query 3A. It is set to 2012-07-29 below; change it if 3A shows a
-- different last overlapping week.
WITH w AS (
    SELECT
        (SELECT MIN(created_at) FROM v_sessions_landing WHERE landing_page = '/lander-1') AS start_ts,
        TIMESTAMP '2012-07-29 00:00:00'                                                    AS end_ts
)
SELECT
    l.landing_page,
    COUNT(*)                                                          AS sessions,
    COUNT(*) FILTER (WHERE l.is_bounce)                               AS bounces,
    ROUND(COUNT(*) FILTER (WHERE l.is_bounce)::numeric / COUNT(*), 4) AS bounce_rate,
    COUNT(l.order_id)                                                 AS orders,
    ROUND(COUNT(l.order_id)::numeric / COUNT(*), 4)                   AS session_to_order_cvr,
    ROUND(SUM(l.price_usd) / COUNT(*), 2)                             AS revenue_per_session
FROM v_sessions_landing l
CROSS JOIN w
WHERE l.landing_page IN ('/home', '/lander-1')
  AND l.channel_group = 'paid_nonbrand'
  AND l.created_at >= w.start_ts AND l.created_at < w.end_ts
GROUP BY l.landing_page
ORDER BY l.landing_page;
