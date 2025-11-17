SELECT 
	COUNT (customer_id) as customers_count --считаем клиентов по id, можно с DISTINCT, но подразумевается, что это справочник и все клиенты уникальные, результат одинаковый
FROM public.customers;