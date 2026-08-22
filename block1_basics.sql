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

-- 12. Выведите seller_id, seller_city, seller_state всех продавцов. 
select 
	seller_id,
	seller_city,
	seller_state
from sellers;

-- 13. Выведите товары тяжелее 5 кг.
select
	p.product_id,
	p.product_weight_g 
from products p 
where p.product_weight_g > 5000;

-- 14. Выведите платежи из order_payments, где сумма больше 1000.
select
	op.order_id ,
	op.payment_value 
from order_payments op 
where op.payment_value > 1000;

-- 15. Выведите клиентов из штата RJ (Рио-де-Жанейро).
select 
	c.customer_id,
	c.customer_zip_code_prefix 
from customers c 
where c.customer_state = 'RJ';

-- 16. Выведите 10 самых дешёвых позиций заказов, отсортированных по цене по возрастанию.
select
	oi.order_id,
	oi.price
from order_items oi 
order by oi.price   
limit 10;

-- 17. Выведите заказы со статусом delivered, оформленные в январе 2017 года.
select 
	o.order_id,
	o.order_status,
	o.order_purchase_timestamp 
from orders o 
where o.order_status = 'delivered' and order_purchase_timestamp >= '2017-01-01' and order_purchase_timestamp < '2017-02-01'
order by o.order_purchase_timestamp; 

-- 18. Выведите уникальные значения payment_type.
select 
	distinct (op.payment_type)
from order_payments op;

-- 19. Выведите товары, у которых больше 5 фотографий.
select
	p.product_id,
	p.product_photos_qty 
from products p 
where p.product_photos_qty > 5
order by p.product_photos_qty 

-- 20. Выведите продавцов из штатов SP, RJ или MG.
select 
	s.seller_id,
	s.seller_state 
from sellers s 
where s.seller_state in ('SP', 'RJ', 'MG');

-- 21. Выведите product_id товаров, у которых product_category_name пустое.
select
	p.product_id 
from products p 
where p.product_category_name is null;

-- 22. Выведите order_id и order_estimated_delivery_date заказов, которые ещё не доставлены.
select
	o.order_id,
	o.order_estimated_delivery_date 
from orders o 
where o.order_delivered_customer_date is null;

-- 23. Выведите 20 строк геолокациидля штата SP.
select
	g.geolocation_city,
	g.geolocation_state 
from geolocation g 
where g.geolocation_state ='SP'
group by g.geolocation_city, g.geolocation_state
limit 20;

-- 24. Выведите товары и три габарита, у которых длина больше 100 см.
select 
	p.product_id,
	p.product_height_cm,
	p.product_width_cm,
	p.product_length_cm 
from products p 
where p.product_length_cm > 100
order by product_length_cm desc;

--25. Выведите customer_unique_id клиентов, чей город содержит подстроку rio (например, «rio de janeiro»).
select 
	c.customer_unique_id,
	c.customer_city 
from customers c 
where c.customer_city like '%rio%'

-- 26. Выведите платежи с рассрочкой больше 10 платежей, отсортируйте по убыванию количества платежей.
select 
	op.order_id,
	op.payment_installments 
from order_payments op 
where op.payment_installments > 10
order by op.payment_installments desc

-- 27. Выведите 15 отзывов с высокой оценкой (review_score BETWEEN 4 AND 5) — order_id, review_score.
select
	t.order_id,
	t.review_score 
from order_reviews t 
where t.review_score between 4 and 5
limit 15 
-- 28. Выведите 10 продавцов (seller_zip_code_prefix, seller_city), отсортированных по городу в алфавитном порядке.
select
	s.seller_zip_code_prefix,
	s.seller_city 
from sellers s 
order by s.seller_city 
limit 10;

-- 29. Выведите английские названия категорий (product_category_name_english), начинающиеся на букву a, в алфавитном порядке.
select 
	pcnt.product_category_name_english 
from product_category_name_translation pcnt 
where pcnt.product_category_name_english LIKE 'a%'
ORDER BY product_category_name_english asc

-- 30. Выведите самый ранний по дате заказ во всём датасете (order_id, order_purchase_timestamp) — без WHERE, только ORDER BY + LIMIT.
select
	o.order_id 
from orders o 
order by o.order_purchase_timestamp
limit 1

--31. Выведите 20 отзывов с самой низкой оценкой (review_score = 1) — order_id, review_comment_title.
select
	t.order_id,
	t.review_comment_title 
from order_reviews t 
where t.review_score = 1
limit 20;

-- 32. Позиции заказов с ценой от 100 до 300
SELECT order_id, product_id, price
FROM order_items
WHERE price BETWEEN 100 AND 300;
