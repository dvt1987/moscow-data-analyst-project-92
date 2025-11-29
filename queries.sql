--Задание 4: Подсчет количества клиентов
SELECT COUNT(customer_id) AS customers_count
FROM
    public.customers;

--Задание 5.1: Топ-10 продавцов по выручке, по убыванию выручки
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS seller,
    COUNT(s.sales_id) AS operations,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM
    employees AS e
INNER JOIN
    sales AS s
    ON e.employee_id = s.sales_person_id
INNER JOIN
    products AS p
    ON s.product_id = p.product_id
GROUP BY
    e.employee_id,
    e.first_name,
    e.last_name
ORDER BY
    income DESC
LIMIT 10;

--Задание 5.2: Продавцы, чья средняя выручка за сделку меньше средней 
--по всем продавцам. Отсортировано по выручке по возрастанию
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS seller,
    FLOOR(AVG(s.quantity * p.price)) AS average_income
FROM
    employees AS e
LEFT JOIN
    sales AS s
    ON e.employee_id = s.sales_person_id
LEFT JOIN
    products AS p
    ON s.product_id = p.product_id
GROUP BY
    e.employee_id,
    e.first_name,
    e.last_name
HAVING
    AVG(s.quantity * p.price)
    < (
        SELECT AVG(s2.quantity * p2.price)
        FROM
            sales AS s2
        LEFT JOIN
            products AS p2
            ON s2.product_id = p2.product_id
    )
ORDER BY
    average_income ASC;

--Задание 5.3: Выручка по дням недели
SELECT
    day_of_week,
    income,
    seller
FROM (
    SELECT
        TRIM(TO_CHAR(s.sale_date, 'day')) AS day_of_week,
        CONCAT(e.first_name, ' ', e.last_name) AS seller,
        TO_CHAR(s.sale_date, 'ID') AS sort_d,
        FLOOR(SUM(s.quantity * p.price)) AS income
    FROM
        sales AS s
    LEFT JOIN
        employees AS e
        ON s.sales_person_id = e.employee_id
    LEFT JOIN
        products AS p
        ON s.product_id = p.product_id
    GROUP BY 
        TRIM(TO_CHAR(s.sale_date, 'day')), 
        CONCAT(e.first_name, ' ', e.last_name), 
        TO_CHAR(s.sale_date, 'ID')
) AS a
ORDER BY sort_d, seller;

--Задание 6.1: Количество покупателей в разных 
--возрастных группах: 16-25, 26-40 и 40+
SELECT
    CASE
        WHEN age BETWEEN 16 AND 25
            THEN '16-25'
        WHEN age BETWEEN 26 AND 40
            THEN '26-40'
        WHEN age > 40
            THEN '40+'
        ELSE 'Другие'
    END AS age_category,
    COUNT(*) AS age_count
FROM
    customers
GROUP BY
    age_category
ORDER BY
    age_category;

--Задание 6.2: Данные по количеству уникальных покупателей 
--и выручке, которую они принесли за каждый месяц
SELECT
    TO_CHAR(s.sale_date, 'YYYY-MM') AS selling_month,
    COUNT(DISTINCT s.customer_id) AS total_customers,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM
    sales AS s
INNER JOIN
    products AS p
    ON s.product_id = p.product_id
GROUP BY
    selling_month
ORDER BY
    selling_month;

--Задание 6.3: Отчет о покупателях, первая покупка 
--которых была в ходе проведения акций
SELECT
    s.sale_date,
    CONCAT(c.first_name, ' ', c.last_name) AS customer,
    CONCAT(e.first_name, ' ', e.last_name) AS seller
FROM (
    SELECT DISTINCT ON (s.customer_id)
        s.customer_id,
        s.sale_date,
        s.sales_person_id
    FROM
        sales AS s
    INNER JOIN
        products AS p
        ON s.product_id = p.product_id
    WHERE p.price = 0
    ORDER BY
        s.customer_id,
        s.sale_date
) AS s
LEFT JOIN
    customers AS c
    ON s.customer_id = c.customer_id
LEFT JOIN
    employees AS e
    ON s.sales_person_id = e.employee_id
WHERE 
    s.sale_date
    = (
        SELECT MIN(s2.sale_date)
        FROM
            sales AS s2
        WHERE s2.customer_id = s.customer_id
    )
ORDER BY
    s.customer_id;

