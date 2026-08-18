-- =====================================================================
-- БЛОК 2 — Агрегатные функции, GROUP BY, HAVING
-- База: Olist Brazilian E-Commerce (PostgreSQL)
-- =====================================================================

-- 1. Общее количество клиентов
SELECT COUNT(customer_id) AS customers_count
FROM customers;

-- 2. Средняя цена позиции заказа
SELECT ROUND(AVG(price), 2) AS avg_item_price
FROM order_items;

-- 3. Минимальная и максимальная цена позиции заказа
SELECT MIN(price) AS min_price, MAX(price) AS max_price
FROM order_items;

-- 4. Количество товаров по категориям (с англ. названием)
-- ВАЖНО: группировка по "сырому" product_category_name, а не по переводу —
-- иначе 2 категории без перевода схлопываются в одну NULL-группу
-- вместе с 610 товарами без категории вовсе.
SELECT
    p.product_category_name,
    pcnt.product_category_name_english,
    COUNT(p.product_id) AS products_count
FROM products p
LEFT JOIN product_category_name_translation pcnt
    ON p.product_category_name = pcnt.product_category_name
GROUP BY p.product_category_name, pcnt.product_category_name_english;

-- 5. Количество заказов по статусам
SELECT order_status, COUNT(*) AS orders_count
FROM orders
GROUP BY order_status;

-- 6. Средняя цена товара по категориям
SELECT
    product_category_name,
    ROUND(AVG(price), 2) AS avg_price
FROM products p
LEFT JOIN order_items oi ON oi.product_id = p.product_id
GROUP BY product_category_name;

-- 7. Суммарная стоимость каждого заказа
SELECT order_id, SUM(price) AS order_total
FROM order_items
GROUP BY order_id;

-- 8. Категории товаров с более чем 500 товарами
SELECT product_category_name, COUNT(product_id) AS products_count
FROM products
WHERE product_category_name IS NOT NULL
GROUP BY product_category_name
HAVING COUNT(product_id) > 500;

-- 9. Количество заказов у каждого реального клиента
-- ВАЖНО: customer_id уникален НА ЗАКАЗ, реальный человек — customer_unique_id
SELECT customer_unique_id, COUNT(order_id) AS orders_count
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
GROUP BY customer_unique_id
ORDER BY orders_count DESC;

-- 10. Клиенты с более чем 1 заказом (повторные покупатели)
SELECT customer_unique_id, COUNT(order_id) AS orders_count
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
GROUP BY customer_unique_id
HAVING COUNT(order_id) > 1
ORDER BY orders_count DESC;

-- 11. Средний рейтинг по каждому товару
-- Примечание: отзыв в Olist пишется на ЗАКАЗ целиком, а не на конкретный товар,
-- поэтому при многотоварных заказах один отзыв влияет на несколько товаров сразу.
SELECT
    oi.product_id,
    ROUND(AVG(t.review_score), 2) AS avg_score
FROM order_reviews t
LEFT JOIN order_items oi ON oi.order_id = t.order_id
GROUP BY oi.product_id;

-- 12. Товары со средним рейтингом ниже 3
SELECT
    oi.product_id,
    ROUND(AVG(t.review_score), 2) AS avg_score
FROM order_reviews t
LEFT JOIN order_items oi ON oi.order_id = t.order_id
GROUP BY oi.product_id
HAVING ROUND(AVG(t.review_score), 2) < 3
ORDER BY avg_score DESC;

-- 13. Количество заказов по каждому способу оплаты
-- ВАЖНО: COUNT(DISTINCT order_id), а не COUNT(order_id) — один заказ может
-- иметь несколько строк оплаты (например, ваучер + карта), иначе переучёт.
SELECT
    payment_type,
    COUNT(DISTINCT order_id) AS orders_count
FROM order_payments
GROUP BY payment_type
ORDER BY orders_count DESC;

-- 14. Штаты с суммарной выручкой клиентов выше 500 000
-- ВАЖНО: выручка = SUM(price), а не SUM(freight_value) (это стоимость доставки, не продажи)
SELECT
    customer_state,
    SUM(oi.price) AS total_revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY customer_state
HAVING SUM(oi.price) > 500000
ORDER BY total_revenue DESC;
