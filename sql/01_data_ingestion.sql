CREATE SCHEMA IF NOT EXISTS raw;

-- 1. Orders
CREATE OR REPLACE TABLE raw.orders AS
SELECT *
FROM read_csv_auto(
    'data/raw/olist_orders_dataset.csv'
);

-- 2. Order Items
CREATE OR REPLACE TABLE raw.order_items AS
SELECT *
FROM read_csv_auto(
    'data/raw/olist_order_items_dataset.csv'
);

-- 3. Customers
CREATE OR REPLACE TABLE raw.customers AS
SELECT *
FROM read_csv_auto(
    'data/raw/olist_customers_dataset.csv'
);

-- 4. Sellers
CREATE OR REPLACE TABLE raw.sellers AS
SELECT *
FROM read_csv_auto(
    'data/raw/olist_sellers_dataset.csv'
);

-- 5. Products
CREATE OR REPLACE TABLE raw.products AS
SELECT *
FROM read_csv_auto(
    'data/raw/olist_products_dataset.csv'
);

-- 6. Order Reviews
CREATE OR REPLACE TABLE raw.order_reviews AS
SELECT *
FROM read_csv_auto(
    'data/raw/olist_order_reviews_dataset.csv'
);

-- 7. Order Payments
CREATE OR REPLACE TABLE raw.order_payments AS
SELECT *
FROM read_csv_auto(
    'data/raw/olist_order_payments_dataset.csv'
);

-- 8. Geolocation
CREATE OR REPLACE TABLE raw.geolocation AS
SELECT *
FROM read_csv_auto(
    'data/raw/olist_geolocation_dataset.csv'
);

-- 9. Product Category Translation
CREATE OR REPLACE TABLE raw.category_translation AS
SELECT *
FROM read_csv_auto(
    'data/raw/product_category_name_translation.csv'
);
