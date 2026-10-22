-- =====================================================================
-- 01_schema.sql  |  Toy Store (Maven Fuzzy Factory) - PostgreSQL schema
-- NOTE: Column names below follow the dataset as I know it. After you
-- download the CSVs, compare each CSV header with the CREATE TABLE and
-- fix any difference before loading.
-- =====================================================================

DROP TABLE IF EXISTS order_item_refunds, order_items, orders,
                     website_pageviews, website_sessions, products CASCADE;

CREATE TABLE products (
    product_id    INT PRIMARY KEY,
    created_at    TIMESTAMP NOT NULL,
    product_name  TEXT NOT NULL
);

CREATE TABLE website_sessions (
    website_session_id  BIGINT PRIMARY KEY,
    created_at          TIMESTAMP NOT NULL,
    user_id             BIGINT NOT NULL,
    is_repeat_session   SMALLINT NOT NULL,
    utm_source          TEXT,        -- NULL = direct / organic traffic
    utm_campaign        TEXT,
    utm_content         TEXT,
    device_type         TEXT,
    http_referer        TEXT
);

CREATE TABLE website_pageviews (
    website_pageview_id BIGINT PRIMARY KEY,
    created_at          TIMESTAMP NOT NULL,
    website_session_id  BIGINT NOT NULL REFERENCES website_sessions,
    pageview_url        TEXT NOT NULL
);

CREATE TABLE orders (
    order_id            BIGINT PRIMARY KEY,
    created_at          TIMESTAMP NOT NULL,
    website_session_id  BIGINT NOT NULL REFERENCES website_sessions,
    user_id             BIGINT NOT NULL,
    primary_product_id  INT NOT NULL REFERENCES products,
    items_purchased     SMALLINT NOT NULL,
    price_usd           NUMERIC(10,2) NOT NULL,
    cogs_usd            NUMERIC(10,2) NOT NULL
);

CREATE TABLE order_items (
    order_item_id  BIGINT PRIMARY KEY,
    created_at     TIMESTAMP NOT NULL,
    order_id       BIGINT NOT NULL REFERENCES orders,
    product_id     INT NOT NULL REFERENCES products,
    is_primary_item SMALLINT NOT NULL,
    price_usd      NUMERIC(10,2) NOT NULL,
    cogs_usd       NUMERIC(10,2) NOT NULL
);

CREATE TABLE order_item_refunds (
    order_item_refund_id BIGINT PRIMARY KEY,
    created_at           TIMESTAMP NOT NULL,
    order_item_id        BIGINT NOT NULL REFERENCES order_items,
    order_id             BIGINT NOT NULL REFERENCES orders,
    refund_amount_usd    NUMERIC(10,2) NOT NULL
);

-- Indexes for the joins and date filters used in every module
CREATE INDEX ON website_sessions (created_at);
CREATE INDEX ON website_pageviews (website_session_id);
CREATE INDEX ON orders (website_session_id);
CREATE INDEX ON order_items (order_id);

-- ---------------------------------------------------------------------
-- Load (psql). Order matters because of foreign keys.
-- \copy products            FROM 'data/raw/products.csv'            CSV HEADER
-- \copy website_sessions    FROM 'data/raw/website_sessions.csv'    CSV HEADER
-- \copy website_pageviews   FROM 'data/raw/website_pageviews.csv'   CSV HEADER
-- \copy orders              FROM 'data/raw/orders.csv'              CSV HEADER
-- \copy order_items         FROM 'data/raw/order_items.csv'         CSV HEADER
-- \copy order_item_refunds  FROM 'data/raw/order_item_refunds.csv'  CSV HEADER
-- DBeaver alternative: right click table > Import Data > CSV.
-- ---------------------------------------------------------------------
