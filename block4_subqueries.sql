-- =====================================================================
-- БЛОК 4 — Подзапросы: скалярные, коррелированные, IN/NOT IN, EXISTS
-- База: Olist Brazilian E-Commerce (PostgreSQL)
-- =====================================================================

-- 1. Позиции заказов дороже средней цены по всем order_items
SELECT oi.product_id, oi.price
FROM order_items oi
WHERE oi.price > (SELECT AVG(price) FROM order_items);

-- 2. Продавцы без единой продажи (через NOT IN)
SELECT s.seller_id
FROM sellers s
WHERE s.seller_id NOT IN (SELECT seller_id FROM order_items);

-- 3. Товар(ы) с максимальной ценой продажи (без ORDER BY + LIMIT)
SELECT oi.product_id, oi.order_id, oi.price
FROM order_items oi
WHERE oi.price = (SELECT MAX(price) FROM order_items);

-- 4. Заказы, суммарная стоимость которых выше средней суммы по заказам
SELECT order_id
FROM (
    SELECT order_id, SUM(price) AS order_total
    FROM order_items
    GROUP BY order_id
) totals
WHERE order_total > (
    SELECT AVG(order_total)
    FROM (SELECT order_id, SUM(price) AS order_total FROM order_items GROUP BY order_id) t2
);

-- 5. Клиенты, суммарная сумма заказов которых больше 5 000
SELECT customer_unique_id
FROM (
    SELECT c.customer_unique_id, SUM(oi.price) AS total
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON oi.order_id = o.order_id
    GROUP BY c.customer_unique_id
) customer_totals
WHERE total > 5000;

-- 6. Товары, которые ни разу не заказывали (через NOT IN)
SELECT p.product_id
FROM products p
WHERE p.product_id NOT IN (SELECT product_id FROM order_items);

-- 7. Товар с максимальной ценой в каждой категории (коррелированный подзапрос)
SELECT p.product_id, p.product_category_name, oi.price
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
WHERE oi.price = (
    SELECT MAX(oi2.price)
    FROM order_items oi2
    JOIN products p2 ON p2.product_id = oi2.product_id
    WHERE p2.product_category_name = p.product_category_name
);

-- 8. Клиенты, чей средний review_score выше общего среднего по всем отзывам
SELECT customer_unique_id
FROM (
    SELECT c.customer_unique_id, AVG(review_score) AS avg_score
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    JOIN order_reviews orw ON orw.order_id = o.order_id
    GROUP BY c.customer_unique_id
) customer_avg
WHERE avg_score > (SELECT AVG(review_score) FROM order_reviews);

-- 9. Позиции заказов дороже средней цены в СВОЕЙ категории (коррелированный подзапрос)
SELECT oi.product_id
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
WHERE oi.price > (
    SELECT AVG(oi2.price)
    FROM order_items oi2
    JOIN products p2 ON p2.product_id = oi2.product_id
    WHERE p2.product_category_name = p.product_category_name   -- условие корреляции
);

-- 10. Второй по величине заказ по суммарной стоимости (без оконных функций)
SELECT order_id, order_total
FROM (
    SELECT order_id, SUM(price) AS order_total
    FROM order_items
    GROUP BY order_id
) AS order_totals
WHERE order_total = (
    SELECT MAX(order_total)
    FROM (SELECT order_id, SUM(price) AS order_total FROM order_items GROUP BY order_id) AS t2
    WHERE order_total < (
        SELECT MAX(order_total)
        FROM (SELECT order_id, SUM(price) AS order_total FROM order_items GROUP BY order_id) AS t3
    )
);

-- 11. Клиенты с хотя бы одним отменённым заказом (EXISTS)
SELECT c.customer_unique_id
FROM customers c
WHERE EXISTS (
    SELECT 1 FROM orders o
    WHERE o.customer_id = c.customer_id AND o.order_status = 'canceled'
);

-- 12. Товары, которые не входят ни в один заказ (NOT EXISTS)
SELECT p.product_id
FROM products p
WHERE NOT EXISTS (
    SELECT 1 FROM order_items oi WHERE oi.product_id = p.product_id
);
