-- =====================================================================
-- Module 01 | Growth trends
-- Question: Is the business growing in a healthy way?
-- North Star: revenue per session (RPS). Definitions: docs/metric_dictionary.md
-- Window: full months only. The data starts 2012-03-19 and ends 2015-03-19,
-- so March 2012 and March 2015 are partial months and are excluded.
-- =====================================================================

SET search_path TO toystore;

-- QUERY 1: monthly funnel-to-revenue summary ---------------------------
SELECT
    DATE_TRUNC('month', s.created_at)::date                         AS month,
    COUNT(DISTINCT s.website_session_id)                            AS sessions,
    COUNT(DISTINCT o.order_id)                                      AS orders,
    ROUND(COUNT(DISTINCT o.order_id)::numeric
          / COUNT(DISTINCT s.website_session_id), 4)                AS session_to_order_cvr,
    SUM(o.price_usd)                                                AS gross_revenue,
    ROUND(SUM(o.price_usd) / COUNT(DISTINCT s.website_session_id), 2) AS revenue_per_session,
    ROUND(SUM(o.price_usd) / NULLIF(COUNT(DISTINCT o.order_id), 0), 2) AS aov
FROM website_sessions s
LEFT JOIN orders o ON o.website_session_id = s.website_session_id
WHERE s.created_at >= '2012-04-01' AND s.created_at < '2015-03-01'
GROUP BY 1
ORDER BY 1;

-- QUERY 2: month-over-month growth with window functions ---------------
WITH monthly AS (
    SELECT
        DATE_TRUNC('month', s.created_at)::date AS month,
        COUNT(DISTINCT s.website_session_id)    AS sessions,
        COUNT(DISTINCT o.order_id)              AS orders,
        SUM(o.price_usd)                        AS gross_revenue
    FROM website_sessions s
    LEFT JOIN orders o ON o.website_session_id = s.website_session_id
    WHERE s.created_at >= '2012-04-01' AND s.created_at < '2015-03-01'
    GROUP BY 1
)
SELECT
    month,
    sessions,
    orders,
    gross_revenue,
    ROUND(100.0 * (sessions - LAG(sessions) OVER w)::numeric
          / NULLIF(LAG(sessions) OVER w, 0), 1)        AS sessions_mom_pct,
    ROUND(100.0 * (gross_revenue - LAG(gross_revenue) OVER w)
          / NULLIF(LAG(gross_revenue) OVER w, 0), 1)   AS revenue_mom_pct
FROM monthly
WINDOW w AS (ORDER BY month)
ORDER BY month;

-- QUERY 3: seasonality-aware view, year over year ----------------------
WITH monthly AS (
    SELECT
        DATE_TRUNC('month', s.created_at)::date AS month,
        COUNT(DISTINCT s.website_session_id)    AS sessions,
        SUM(o.price_usd)                        AS gross_revenue
    FROM website_sessions s
    LEFT JOIN orders o ON o.website_session_id = s.website_session_id
    WHERE s.created_at >= '2012-04-01' AND s.created_at < '2015-03-01'
    GROUP BY 1
)
SELECT
    month,
    gross_revenue,
    LAG(gross_revenue, 12) OVER (ORDER BY month) AS revenue_same_month_last_year,
    ROUND(100.0 * (gross_revenue - LAG(gross_revenue, 12) OVER (ORDER BY month))
          / NULLIF(LAG(gross_revenue, 12) OVER (ORDER BY month), 0), 1) AS revenue_yoy_pct
FROM monthly
ORDER BY month;
