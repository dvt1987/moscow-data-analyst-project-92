--------------------------------------------------------------------------------------------------------------------------------------------
-- Задание 4: Подсчет количества клиентов
--------------------------------------------------------------------------------------------------------------------------------------------
SELECT 
	COUNT (customer_id) as customers_count --считаем клиентов по id, можно с DISTINCT, но подразумевается, что это справочник и все клиенты уникальные, результат одинаковый

FROM 
	public.customers;


--------------------------------------------------------------------------------------------------------------------------------------------
-- Задание 5.1: Топ-10 продавцов по выручке, по убыванию выручки
--------------------------------------------------------------------------------------------------------------------------------------------
SELECT 
    CONCAT(e.first_name, ' ', e.last_name) 	AS seller,
    COUNT(s.sales_id) 						AS operations,
    FLOOR(SUM(s.quantity * p.price)) 		AS income
FROM 
	employees e
JOIN 
	sales s 
	ON e.employee_id = s.sales_person_id
JOIN 
	products p 
	ON s.product_id = p.product_id
GROUP BY 
	e.employee_id, 
	e.first_name, 
	e.last_name
ORDER BY 
	income DESC
LIMIT 10
;

--------------------------------------------------------------------------------------------------------------------------------------------
-- Задание 5.2: Продавцы, чья средняя выручка за сделку меньше средней по всем продавцам. Отсортировано по выручке по возрастанию
--------------------------------------------------------------------------------------------------------------------------------------------
SELECT 
    CONCAT(e.first_name, ' ', e.last_name)	AS seller,
    FLOOR(AVG(s.quantity * p.price)) 		AS average_income
FROM 
	employees e
LEFT JOIN 
	sales s 
	ON e.employee_id = s.sales_person_id
LEFT JOIN 
	products p 
	ON s.product_id = p.product_id
GROUP BY 
	e.employee_id, 
	e.first_name, 
	e.last_name
HAVING 
	AVG(s.quantity * p.price) < 
		(
    		SELECT 
    			AVG(s2.quantity * p2.price)
    		FROM 
    			sales s2
    		LEFT JOIN 
    			products p2 
    			ON s2.product_id = p2.product_id
			)
ORDER BY 
	average_income asc
	;

--------------------------------------------------------------------------------------------------------------------------------------------
-- Задание 5.3: Выручка по дням недели
--------------------------------------------------------------------------------------------------------------------------------------------
--Задаем CTE, чтобы получить таблицу со всеми возможными комбинациями дня недели и продавца. Нужно для получения строк для продавцов, у которых в определенные дни недели могло вообще не быть продаж. Все равно хотим их видеть, но с продажами = 0.
WITH dim_tab AS (
	SELECT DISTINCT
		TO_CHAR(s.sale_date, 'day') 			AS day_of_week,
		TO_CHAR(s.sale_date, 'ID')				AS day_of_week_int,
		CONCAT(e.first_name, ' ', e.last_name) 	AS seller
	FROM
		sales s
	CROSS JOIN employees e
			)
SELECT
	a.day_of_week as day_of_week, 
	a.seller as seller,
	COALESCE(b.income,0.0) as income
FROM 
	dim_tab as a
LEFT JOIN (SELECT 
		    CONCAT(e.first_name, ' ', e.last_name) 	AS seller,
		    TO_CHAR(s.sale_date, 'day') 			AS day_of_week,
		    FLOOR(SUM(s.quantity * p.price)) 		AS income
		FROM 
			employees e
		LEFT JOIN 
			sales s 
			ON e.employee_id = s.sales_person_id
		LEFT JOIN 
			products p 
			ON s.product_id = p.product_id
		GROUP BY 
			e.employee_id,  
			day_of_week
		) AS b
	on a.seller = b.seller and a.day_of_week = b.day_of_week
ORDER BY 
	a.day_of_week_int,
	a.seller
