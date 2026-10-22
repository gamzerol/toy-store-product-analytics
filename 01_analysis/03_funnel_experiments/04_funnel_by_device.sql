-- =====================================================================
-- Module 03 | Funnel analysis by device
-- Question: At which step do mobile visitors drop out, compared with desktop?
-- Funnel:   landing -> /products -> product page -> /cart -> /shipping
--           -> billing (/billing or /billing-2) -> order
-- Window:   full months only (2012-04-01 to 2015-02-28).
-- Note:     a step means "the session viewed that page at any time". Strict
--           ordering is not enforced; the validation query below checks that the
--           funnel's last step matches the orders table.
-- =====================================================================

SET search_path TO toystore;

-- STEP 1: one row per session with a 0/1 flag per funnel step -------------
CREATE OR REPLACE VIEW v_session_funnel AS
SELECT
    s.website_session_id,
    s.created_at,
    s.device_type,
    s.channel_group,
    MAX((p.pageview_url = '/products')::int)                              AS to_products,
    MAX((p.pageview_url IN ('/the-original-mr-fuzzy', '/the-forever-love-bear',
                            '/the-birthday-sugar-panda',
                            '/the-hudson-river-mini-bear'))::int)         AS to_product_page,
    MAX((p.pageview_url = '/cart')::int)                                  AS to_cart,
    MAX((p.pageview_url = '/shipping')::int)                              AS to_shipping,
    MAX((p.pageview_url IN ('/billing', '/billing-2'))::int)              AS to_billing,
    MAX((p.pageview_url = '/thank-you-for-your-order')::int)              AS to_order
FROM v_sessions_channel s
JOIN website_pageviews p ON p.website_session_id = s.website_session_id
GROUP BY s.website_session_id, s.created_at, s.device_type, s.channel_group;
-- EXPLANATION:
-- * Boolean expression cast to int gives 1 if that page appears in the row, else 0.
--   MAX over the session's rows turns it into "did the session ever reach this page".
-- * This is a standard way to build a funnel in SQL without self-joins: one pass over
--   the pageviews, one row per session.
-- * Every later query is simple sums over these flags.

-- VALIDATION: funnel end must match the orders table ------------------
SELECT SUM(to_order) AS funnel_orders, (SELECT COUNT(*) FROM orders) AS orders_table
FROM v_session_funnel;
-- EXPLANATION: Both numbers should be 32,313. If they differ, the funnel logic, not
-- the business, is wrong, so we check before interpreting anything.

-- QUERY 1: overall funnel with step conversion ----------------------------
WITH f AS (
    SELECT
        COUNT(*)                AS sessions,
        SUM(to_products)        AS products,
        SUM(to_product_page)    AS product_page,
        SUM(to_cart)            AS cart,
        SUM(to_shipping)        AS shipping,
        SUM(to_billing)         AS billing,
        SUM(to_order)           AS orders
    FROM v_session_funnel
    WHERE created_at >= '2012-04-01' AND created_at < '2015-03-01'
)
SELECT 1 AS step_no, 'landing -> products'      AS step, sessions     AS from_n, products     AS to_n, ROUND(products::numeric     / sessions,     4) AS step_rate FROM f
UNION ALL
SELECT 2, 'products -> product page', products,     product_page, ROUND(product_page::numeric / products,     4) FROM f
UNION ALL
SELECT 3, 'product page -> cart',      product_page, cart,         ROUND(cart::numeric         / product_page, 4) FROM f
UNION ALL
SELECT 4, 'cart -> shipping',          cart,         shipping,     ROUND(shipping::numeric     / cart,         4) FROM f
UNION ALL
SELECT 5, 'shipping -> billing',       shipping,     billing,      ROUND(billing::numeric      / shipping,     4) FROM f
UNION ALL
SELECT 6, 'billing -> order',          billing,      orders,       ROUND(orders::numeric       / billing,      4) FROM f
ORDER BY step_no;
-- EXPLANATION:
-- * One CTE holds the counts; each UNION ALL branch turns them into a "from, to, rate" row.
-- * Step rate = sessions reaching the step / sessions at the previous step.
--   The biggest absolute loss (not only the lowest rate) shows where to look first.

-- QUERY 2: funnel by device, side by side --------------------------------
SELECT
    device_type,
    COUNT(*)                                                                        AS sessions,
    ROUND(SUM(to_products)::numeric     / COUNT(*), 4)                              AS landing_to_products,
    ROUND(SUM(to_product_page)::numeric / NULLIF(SUM(to_products), 0), 4)           AS products_to_product_page,
    ROUND(SUM(to_cart)::numeric         / NULLIF(SUM(to_product_page), 0), 4)       AS product_page_to_cart,
    ROUND(SUM(to_shipping)::numeric     / NULLIF(SUM(to_cart), 0), 4)               AS cart_to_shipping,
    ROUND(SUM(to_billing)::numeric      / NULLIF(SUM(to_shipping), 0), 4)           AS shipping_to_billing,
    ROUND(SUM(to_order)::numeric        / NULLIF(SUM(to_billing), 0), 4)            AS billing_to_order,
    ROUND(SUM(to_order)::numeric        / COUNT(*), 4)                              AS session_to_order
FROM v_session_funnel
WHERE created_at >= '2012-04-01' AND created_at < '2015-03-01'
GROUP BY device_type
ORDER BY device_type;
-- EXPLANATION:
-- * Same step rates as Query 1, computed per device with GROUP BY.
-- * Read across the two rows: the step where mobile is lowest relative to desktop is
--   where the mobile experience loses people. A gap that appears at the very first
--   step points to the landing experience; later gaps point to cart or checkout.
-- * NULLIF avoids division by zero if a step has no sessions.

-- QUERY 3: same, paid non-brand only (control for channel mix) ------------
SELECT
    device_type,
    COUNT(*)                                                                        AS sessions,
    ROUND(SUM(to_products)::numeric     / COUNT(*), 4)                              AS landing_to_products,
    ROUND(SUM(to_product_page)::numeric / NULLIF(SUM(to_products), 0), 4)           AS products_to_product_page,
    ROUND(SUM(to_cart)::numeric         / NULLIF(SUM(to_product_page), 0), 4)       AS product_page_to_cart,
    ROUND(SUM(to_shipping)::numeric     / NULLIF(SUM(to_cart), 0), 4)               AS cart_to_shipping,
    ROUND(SUM(to_billing)::numeric      / NULLIF(SUM(to_shipping), 0), 4)           AS shipping_to_billing,
    ROUND(SUM(to_order)::numeric        / NULLIF(SUM(to_billing), 0), 4)            AS billing_to_order,
    ROUND(SUM(to_order)::numeric        / COUNT(*), 4)                              AS session_to_order
FROM v_session_funnel
WHERE created_at >= '2012-04-01' AND created_at < '2015-03-01'
  AND channel_group = 'paid_nonbrand'
GROUP BY device_type
ORDER BY device_type;
-- EXPLANATION:
-- * Desktop and mobile users arrive through different channel mixes. Restricting to one
--   channel checks that the device gap is not just a channel mix effect.
-- * If the gap pattern is the same as in Query 2, the device finding is robust to channel.