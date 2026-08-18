DROP TABLE IF EXISTS order_reviews CASCADE;
DROP TABLE IF EXISTS order_payments CASCADE;
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS sellers CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS geolocation CASCADE;
DROP TABLE IF EXISTS product_category_name_translation CASCADE;

CREATE TABLE product_category_name_translation (
    product_category_name          VARCHAR(100) PRIMARY KEY,
    product_category_name_english  VARCHAR(100)
);
CREATE TABLE customers (
    customer_id              VARCHAR(32) PRIMARY KEY,
    customer_unique_id       VARCHAR(32) NOT NULL,
    customer_zip_code_prefix VARCHAR(10),
    customer_city             VARCHAR(100),
    customer_state             VARCHAR(2)
);
CREATE TABLE sellers (
    seller_id               VARCHAR(32) PRIMARY KEY,
    seller_zip_code_prefix  VARCHAR(10),
    seller_city              VARCHAR(100),
    seller_state              VARCHAR(2)
);
CREATE TABLE geolocation (
    geo_id                        SERIAL PRIMARY KEY,
    geolocation_zip_code_prefix   VARCHAR(10),
    geolocation_lat                DOUBLE PRECISION,
    geolocation_lng                DOUBLE PRECISION,
    geolocation_city               VARCHAR(100),
    geolocation_state              VARCHAR(2)
);
CREATE TABLE products (
    product_id                    VARCHAR(32) PRIMARY KEY,
    product_category_name         VARCHAR(100),
    product_name_lenght           INTEGER,
    product_description_lenght    INTEGER,
    product_photos_qty            INTEGER,
    product_weight_g              INTEGER,
    product_length_cm             INTEGER,
    product_height_cm             INTEGER,
    product_width_cm              INTEGER
);
CREATE TABLE orders (
    order_id                        VARCHAR(32) PRIMARY KEY,
    customer_id                     VARCHAR(32) NOT NULL REFERENCES customers(customer_id),
    order_status                    VARCHAR(20) NOT NULL,
    order_purchase_timestamp        TIMESTAMP,
    order_approved_at               TIMESTAMP,
    order_delivered_carrier_date    TIMESTAMP,
    order_delivered_customer_date   TIMESTAMP,
    order_estimated_delivery_date   TIMESTAMP
);
CREATE TABLE order_items (
    order_id             VARCHAR(32) NOT NULL REFERENCES orders(order_id),
    order_item_id         INTEGER NOT NULL,
    product_id             VARCHAR(32) NOT NULL REFERENCES products(product_id),
    seller_id               VARCHAR(32) NOT NULL REFERENCES sellers(seller_id),
    shipping_limit_date     TIMESTAMP,
    price                   NUMERIC(10,2) NOT NULL,
    freight_value           NUMERIC(10,2) NOT NULL,
    PRIMARY KEY (order_id, order_item_id)
);
CREATE TABLE order_payments (
    order_id               VARCHAR(32) NOT NULL REFERENCES orders(order_id),
    payment_sequential     INTEGER NOT NULL,
    payment_type            VARCHAR(20) NOT NULL,
    payment_installments     INTEGER,
    payment_value             NUMERIC(10,2) NOT NULL,
    PRIMARY KEY (order_id, payment_sequential)
);
CREATE TABLE order_reviews (
    review_pk                    SERIAL PRIMARY KEY,
    review_id                    VARCHAR(32) NOT NULL,
    order_id                     VARCHAR(32) NOT NULL REFERENCES orders(order_id),
    review_score                 INTEGER NOT NULL CHECK (review_score BETWEEN 1 AND 5),
    review_comment_title         VARCHAR(200),
    review_comment_message       TEXT,
    review_creation_date         TIMESTAMP,
    review_answer_timestamp      TIMESTAMP
);
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_status ON orders(order_status);
CREATE INDEX idx_orders_purchase_ts ON orders(order_purchase_timestamp);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
CREATE INDEX idx_order_items_seller_id ON order_items(seller_id);
CREATE INDEX idx_order_payments_order_id ON order_payments(order_id);
CREATE INDEX idx_order_reviews_order_id ON order_reviews(order_id);
CREATE INDEX idx_products_category ON products(product_category_name);
CREATE INDEX idx_geolocation_zip ON geolocation(geolocation_zip_code_prefix);
