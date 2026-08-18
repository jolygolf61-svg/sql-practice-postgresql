-- =====================================================================
-- БЛОК 3 — JOIN (INNER, LEFT, FULL, self-join)
-- База: Olist Brazilian E-Commerce (PostgreSQL)
-- =====================================================================

-- 1. Заказы с городом и штатом клиента
SELECT o.order_id, o.order_status, c.customer_city, c.customer_state
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id;

-- 2. Позиции заказов с категорией товара
SELECT oi.order_id, oi.product_id, p.product_category_name, oi.price
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id;

-- 3. Позиции заказов с городом/штатом продавца
SELECT oi.order_id, oi.product_id, oi.price, s.seller_city, s.seller_state
FROM order_items oi
JOIN sellers s ON s.seller_id = oi.seller_id;

-- 4. Заказы, на которые не оставлен отзыв
SELECT o.order_id
FROM orders o
LEFT JOIN order_reviews t ON o.order_id = t.order_id
WHERE t.order_id IS NULL;

-- 5. Заказы без единой записи об оплате
SELECT o.order_id, o.order_status
FROM orders o
LEFT JOIN order_payments op ON op.order_id = o.order_id
WHERE op.order_id IS NULL;

-- 6. Товары, которые ни разу не заказывали
SELECT p.product_id
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
WHERE oi.order_id IS NULL;

-- 7. Продавцы без единой продажи
SELECT s.seller_id
FROM sellers s
LEFT JOIN order_items oi ON oi.seller_id = s.seller_id
WHERE oi.seller_id IS NULL;

-- 8. FULL JOIN orders + order_payments: строки-"сироты" с любой стороны
SELECT *
FROM orders o
FULL JOIN order_payments op ON op.order_id = o.order_id
WHERE o.order_id IS NULL OR op.order_id IS NULL;

-- 9. Self-join orders через customers: пары заказов одного клиента
SELECT
    c1.customer_unique_id,
    o1.order_id AS order_1, o1.order_purchase_timestamp AS date_1,
    o2.order_id AS order_2, o2.order_purchase_timestamp AS date_2
FROM customers c1
JOIN orders o1 ON o1.customer_id = c1.customer_id
JOIN customers c2 ON c2.customer_unique_id = c1.customer_unique_id
JOIN orders o2 ON o2.customer_id = c2.customer_id
WHERE o1.order_id < o2.order_id   
ORDER BY c1.customer_unique_id;

-- 10. Клиент + заказ + товар + цена (4-табличный JOIN)
SELECT
    c.customer_state,
    o.order_purchase_timestamp,
    p.product_category_name,
    oi.price
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id;

-- 11. Рейтинг отзыва по штату клиента
SELECT t.review_score, c.customer_state
FROM order_reviews t
JOIN orders o ON o.order_id = t.order_id
JOIN customers c ON c.customer_id = o.customer_id
ORDER BY t.review_score ASC;

-- 12. Товары, которые заказывали, но ни разу не получили отзыв
SELECT DISTINCT p.product_id
FROM products p
JOIN order_items oi ON oi.product_id = p.product_id
LEFT JOIN order_reviews r ON r.order_id = oi.order_id
WHERE r.review_pk IS NULL;

-- 13. Средний рейтинг по каждому продавцу (с NULL у продавцов без отзывов)
SELECT s.seller_id, ROUND(AVG(t.review_score), 2) AS avg_score
FROM sellers s
LEFT JOIN order_items oi ON oi.seller_id = s.seller_id
LEFT JOIN order_reviews t ON t.order_id = oi.order_id
GROUP BY s.seller_id;

-- 14. Топ-5 продавцов по суммарной выручке
SELECT s.seller_id, SUM(oi.price) AS total_revenue
FROM order_items oi
JOIN sellers s ON s.seller_id = oi.seller_id
GROUP BY s.seller_id
ORDER BY total_revenue DESC
LIMIT 5;

-- 15. Топ-5 штатов по количеству клиентов с более чем 1 заказом
WITH repeat_customers AS (
    SELECT c.customer_state, c.customer_unique_id
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    GROUP BY c.customer_state, c.customer_unique_id
    HAVING COUNT(o.order_id) > 1
)
SELECT customer_state, COUNT(*) AS repeat_customers_count
FROM repeat_customers
GROUP BY customer_state
ORDER BY repeat_customers_count DESC
LIMIT 5;
