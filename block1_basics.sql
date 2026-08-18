-- =====================================================================
-- БЛОК 1 — Базовые запросы: SELECT, WHERE, ORDER BY, LIMIT, LIKE, BETWEEN
-- База: Olist Brazilian E-Commerce (PostgreSQL)
-- =====================================================================

-- 1. Список клиентов с городом и штатом
SELECT customer_id, customer_city, customer_state
FROM customers;

-- 2. Позиции заказов, отсортированные по цене по убыванию
SELECT order_id, product_id, price
FROM order_items
ORDER BY price DESC;

-- 3. Позиции заказов дешевле 50
SELECT order_id, product_id, price
FROM order_items
WHERE price < 50
ORDER BY price DESC;

-- 4. Клиенты из штата SP (São Paulo)
SELECT customer_id, customer_city, customer_state
FROM customers
WHERE customer_state = 'SP';

-- 5. Топ-5 самых дорогих позиций заказов
SELECT order_id, product_id, price
FROM order_items
ORDER BY price DESC
LIMIT 5;

-- 6. Товары весом меньше 500 г
SELECT product_id, product_category_name, product_weight_g
FROM products
WHERE product_weight_g < 500;

-- 7. Заказы, оформленные после 1 января 2018 года
SELECT order_id, order_purchase_timestamp
FROM orders
WHERE order_purchase_timestamp > '2018-01-01';

-- 8. Отменённые заказы
-- ВАЖНО: в данных статус хранится как 'canceled' (одна L, амер. написание)
SELECT *
FROM orders
WHERE order_status = 'canceled';

-- 9. Уникальные штаты клиентов
SELECT DISTINCT customer_state
FROM customers;

-- 10. Товары категории "мебель" (moveis, португальский)
SELECT product_id, product_category_name
FROM products
WHERE product_category_name LIKE '%moveis%';

-- 11. Клиенты из городов, начинающихся на "s"
SELECT customer_id, customer_city
FROM customers
WHERE customer_city LIKE 's%';

-- 12. Позиции заказов с ценой от 100 до 300
SELECT order_id, product_id, price
FROM order_items
WHERE price BETWEEN 100 AND 300;
