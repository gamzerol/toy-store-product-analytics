-- =====================================================================
-- Module 02 | Channel and device performance
-- Question: Which traffic sources and devices create valuable conversion?
-- Window: full months only (2012-04-01 to 2015-02-28), see module 01 notes.
-- Limitation: the dataset has no marketing spend, so CAC and ROI cannot be
-- computed. Margin per session is used as a value proxy instead.
-- =====================================================================

SET search_path TO toystore;

-- STEP 0: channel grouping view ----------------------------------------
-- Check device values first: SELECT DISTINCT device_type FROM website_sessions;
CREATE OR REPLACE VIEW v_sessions_channel AS
SELECT
    s.*,
    CASE
        WHEN s.utm_source IS NULL AND s.http_referer IS NULL THEN 'direct'
        WHEN s.utm_source IS NULL                            THEN 'organic_search'
        WHEN s.utm_source = 'socialbook'                     THEN 'paid_social'
        WHEN s.utm_campaign = 'brand'                        THEN 'paid_brand'
        WHEN s.utm_campaign = 'nonbrand'                     THEN 'paid_nonbrand'
        ELSE 'other'
    END AS channel_group
FROM website_sessions s;
-- EXPLANATION:
-- * Raw utm fields are too granular (source x campaign x referer). A CASE
--   expression maps them to five business-friendly channels.
-- * Order of WHEN branches matters: the first true branch wins.
-- * No utm_source and no referer = typed the URL or bookmark (direct).
--   No utm_source but a search engine referer = free (organic) search.
-- * A VIEW stores the query, not the data, so every later query reuses the
--   same definition and the channel logic lives in one place.

-- QUERY 1: channel scorecard ----------------------------------------------
SELECT
    v.channel_group,
    COUNT(*)                                                          AS sessions,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1)                AS pct_of_sessions,
    COUNT(o.order_id)                                                 AS orders,
    ROUND(COUNT(o.order_id)::numeric / COUNT(*), 4)                   AS session_to_order_cvr,
    ROUND(SUM(o.price_usd), 0)                                        AS gross_revenue,
    ROUND(100.0 * SUM(o.price_usd) / SUM(SUM(o.price_usd)) OVER (), 1) AS pct_of_revenue,
    ROUND(SUM(o.price_usd) / COUNT(*), 2)                             AS revenue_per_session,
    ROUND(SUM(o.price_usd - o.cogs_usd) / COUNT(*), 2)                AS margin_per_session
FROM v_sessions_channel v
LEFT JOIN orders o ON o.website_session_id = v.website_session_id
WHERE v.created_at >= '2012-04-01' AND v.created_at < '2015-03-01'
GROUP BY v.channel_group
ORDER BY sessions DESC;
-- EXPLANATION:
-- * LEFT JOIN keeps sessions without orders, otherwise conversion is overstated.
-- * COUNT(o.order_id) counts only non-NULL order ids, i.e. sessions that ordered
--   (a session has at most one order here).
-- * SUM(COUNT(*)) OVER () is a window function over the aggregated rows. It
--   gives the grand total on every row, so each channel's share is one division.
-- * Compare pct_of_sessions with pct_of_revenue: a channel with a larger revenue
--   share than traffic share converts better than average.
-- * Margin per session = (price - cogs) / sessions. It is a value proxy because
--   we have no cost of acquiring the traffic.

-- QUERY 2: channel x device conversion -------------------------------------
SELECT
    v.channel_group,
    COUNT(*) FILTER (WHERE v.device_type = 'desktop')                 AS desktop_sessions,
    ROUND(COUNT(o.order_id) FILTER (WHERE v.device_type = 'desktop')::numeric
          / NULLIF(COUNT(*) FILTER (WHERE v.device_type = 'desktop'), 0), 4) AS desktop_cvr,
    COUNT(*) FILTER (WHERE v.device_type = 'mobile')                  AS mobile_sessions,
    ROUND(COUNT(o.order_id) FILTER (WHERE v.device_type = 'mobile')::numeric
          / NULLIF(COUNT(*) FILTER (WHERE v.device_type = 'mobile'), 0), 4)  AS mobile_cvr
FROM v_sessions_channel v
LEFT JOIN orders o ON o.website_session_id = v.website_session_id
WHERE v.created_at >= '2012-04-01' AND v.created_at < '2015-03-01'
GROUP BY v.channel_group
ORDER BY desktop_sessions DESC;
-- EXPLANATION:
-- * FILTER (WHERE ...) is conditional aggregation: one scan of the table gives
--   desktop and mobile numbers side by side (a pivot without a PIVOT keyword).
-- * Keep sample sizes in view. A large CVR gap on a tiny channel (for example paid
--   social) is not a reliable finding.
-- * Observational gap only: desktop users may differ from mobile users in intent,
--   so a gap generates a hypothesis, it does not prove the device causes it.

-- QUERY 3: quarterly channel mix -------------------------------------------
-- Ends at 2014-12-31 because Q1 2015 would only contain Jan and Feb.
WITH q AS (
    SELECT
        DATE_TRUNC('quarter', created_at)::date AS quarter,
        channel_group,
        COUNT(*) AS sessions
    FROM v_sessions_channel
    WHERE created_at >= '2012-04-01' AND created_at < '2015-01-01'
    GROUP BY 1, 2
)
SELECT
    quarter,
    channel_group,
    sessions,
    ROUND(100.0 * sessions / SUM(sessions) OVER (PARTITION BY quarter), 1) AS pct_of_quarter
FROM q
ORDER BY quarter, sessions DESC;
-- EXPLANATION:
-- * PARTITION BY quarter makes the window total restart for every quarter, so each
--   row's share is relative to its own quarter.
-- * Look for dependence on one channel and for whether free channels (direct,
--   organic, brand) grow as a share over time. That would indicate brand building
--   rather than buying all traffic.
-- * Quarters that end after the last full month are excluded on purpose.