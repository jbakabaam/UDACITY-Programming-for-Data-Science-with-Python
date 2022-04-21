-- Q1. Top 5 Customer’s Monthly Spending

WITH top_five
AS (
	SELECT p.customer_id, (c.first_name||' '||c.last_name) AS fullname, SUM(p.amount) AS pay_amount
	FROM payment p
	JOIN customer c
	ON p.customer_id = c.customer_id
	GROUP BY 1, 2
	ORDER BY 3 DESC
	LIMIT 5
	)
  
SELECT DATE_TRUNC('month', p.payment_date) pay_mon, t5.fullname AS name, COUNT(p.payment_date) AS pay_count_per_mon, SUM(p.amount) AS pay_amount
FROM payment p
JOIN top_five t5
ON p.customer_id = t5.customer_id
GROUP BY 1,2
ORDER BY 2,1
;


-- Q2. Distribution Of Film Actors By Country

SELECT co.country, COUNT(fa.actor_id) film_actor
FROM film_actor fa
JOIN film
ON fa.film_id = film.film_id
JOIN inventory inv
ON film.film_id = inv.film_id
JOIN rental rt
ON inv.inventory_id = rt.inventory_id
JOIN customer cust
ON rt.customer_id = cust.customer_id
JOIN address addr
ON cust.address_id = addr.address_id
JOIN city ct
ON addr.city_id = ct.city_id
JOIN country co
ON ct.country_id = co.country_id
GROUP BY 1
ORDER BY 2 DESC
;


-- Q3. The Proportion Of Film Category That Indian Actors Appearing

WITH a
AS (
	SELECT co.country, ca.name
	FROM category ca
	JOIN film_category fc
	ON ca.category_id = fc.film_id
	JOIN film
	ON fc.film_id = film.film_id
	JOIN inventory inv
	ON film.film_id = inv.film_id
	JOIN rental rt
	ON inv.inventory_id = rt.inventory_id
	JOIN customer cust
	ON rt.customer_id = cust.customer_id
	JOIN address addr
	ON cust.address_id = addr.address_id
	JOIN city ct
	ON addr.city_id = ct.city_id
	JOIN country co
	ON ct.country_id = co.country_id
	GROUP BY 1,2
	HAVING country='India'
	)
,
	b
AS (
	SELECT count(name) total_category
	FROM category
	)
,
	c
AS (
	SELECT a.country, count(a.name) cnt, total_category
	FROM a,b
	GROUP BY 1,3
	)
,
	d
AS (
	SELECT *, CAST(cnt AS FLOAT)/CAST(total_category AS FLOAT) ratio
	FROM c
	)

SELECT * FROM d;


-- Q4. Teen Boys Friendly Movies Rental Duration
-- We want to understand more about the movies that teen boys are watching.
-- The following categories are considered teen boys friendly movies: Action, Comedy, Games, Horror, Sci-Fi, Sports

SELECT t.name, t.standard_quartile, COUNT(*)
FROM
	(
	SELECT ca.name, film.rental_duration, NTILE(4) OVER(ORDER BY film.rental_duration) AS standard_quartile
          FROM category AS ca
               JOIN film_category AS fc
                ON ca.category_id = fc.category_id 
                AND ca.name IN ('Action', 'Comedy', 'Games', 'Horror', 'Sci-Fi', 'Sports')
               JOIN film
                ON film.film_id = fc.film_id) AS t
 GROUP BY 1, 2
 ORDER BY 1, 2
 ;
 