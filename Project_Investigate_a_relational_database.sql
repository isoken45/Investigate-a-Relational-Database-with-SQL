/* SET1_Q1 */

/* Create a query that lists each movie, the film category it is classified in
and the number of times it has been rented out */

SELECT film_title, category_name,
       COUNT(*) AS rental_count
FROM
(SELECT f.title film_title,
        c.name category_name,
        r.rental_id rental_id
FROM film f
JOIN film_category fc
ON fc.film_id = f.film_id
JOIN category c
ON fc.category_id = c.category_id
JOIN inventory i
ON i.film_id = f.film_id
JOIN rental r
ON r.inventory_id = i.inventory_id
WHERE c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')) t1
GROUP BY 1,2
ORDER BY category_name


/* SET1_Q2 */

/* We need to know how the length of rental duration of these family-friendly
movies compares to the duration that all movies are rented for. Provide
a table with the movie titles and divide them into 4 levels (first_quarter,
second_quarter, third_quarter, and final_quarter) based on the quartiles (25%,
50%, 75%) of the rental duration for movies across all categories. */

SELECT *
FROM
(SELECT *,
	   NTILE(4) OVER(ORDER BY rental_duration) AS standard_quartile,
	   CASE WHEN NTILE(4) OVER(ORDER BY rental_duration)= 1 THEN 'First_quarter'
            WHEN NTILE(4) OVER(ORDER BY rental_duration)= 2 THEN 'Second_quarter'
            WHEN NTILE(4) OVER(ORDER BY rental_duration)= 3 THEN 'Third_quarter'
            WHEN NTILE(4) OVER(ORDER BY rental_duration)= 4 THEN 'Fourth_quarter'
            END AS levels
FROM
(SELECT f.title film_title,
        c.name category_name,
        f.rental_duration rental_duration
FROM film f
JOIN film_category fc
ON fc.film_id = f.film_id
JOIN category c
ON fc.category_id = c.category_id
) t1) t2


/* SET1_Q3 */

/* Query provides a table with the family-friendly film category, each of the
quartiles, and the corresponding count of movies within each combination of film
category for each corresponding rental duration category. */

SELECT category_name, standard_quartile, COUNT(*)
FROM
(SELECT *,
	   NTILE(4) OVER(ORDER BY rental_duration) AS standard_quartile,
	   CASE WHEN NTILE(4) OVER(ORDER BY rental_duration)= 1 THEN 'First_quarter'
            WHEN NTILE(4) OVER(ORDER BY rental_duration)= 2 THEN 'Second_quarter'
            WHEN NTILE(4) OVER(ORDER BY rental_duration)= 3 THEN 'Third_quarter'
            WHEN NTILE(4) OVER(ORDER BY rental_duration)= 4 THEN 'Fourth_quarter'
            END AS levels
FROM
(SELECT f.title film_title,
        c.name category_name,
        f.rental_duration rental_duration
FROM film f
JOIN film_category fc
ON fc.film_id = f.film_id
JOIN category c
ON fc.category_id = c.category_id
) t1) t2
WHERE category_name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
GROUP BY 1,2
ORDER BY category_name


/* SET2_Q1 */

/* A query that returns the store ID for the store, the year and month and the
number of rental orders each store has fulfilled for that month. Your table
should include a column for each of the following: year, month, store ID and
count of rental orders fulfilled during that month. */

SELECT DATE_PART('month', r.rental_date) rental_month,
       DATE_PART('year', r.rental_date) rental_year,
	     i.store_id,
	     COUNT(*) rentals_count
FROM inventory i
JOIN rental r
ON i.inventory_id = r.inventory_id
GROUP BY 1,2,3
ORDER BY rentals_count DESC


/* SET2_Q2 */

/* Query to capture the customer name, month and year of payment, and total
payment amount for each month by the top 10 paying customers. */

SELECT t1.payment_month,
       t2.customer_name,
       t1.pay_count_per_month,
       t1.pay_amount_per_month
FROM
(SELECT DATE_TRUNC('month', payment_date) payment_month,
       c.first_name || ' ' || c.last_name AS customer_name,
 	   COUNT(*) pay_count_per_month,
       SUM(p.amount) pay_amount_per_month
FROM customer c
JOIN payment p
ON p.customer_id = c.customer_id
GROUP BY 1,2) t1

JOIN

(SELECT c.first_name || ' ' || c.last_name AS customer_name,
       SUM(p.amount)
FROM customer c
JOIN payment p
ON p.customer_id = c.customer_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10) t2

ON t1.customer_name = t2.customer_name
ORDER BY t2.customer_name, t1.payment_month


/* SET2_Q3 */

/* A query to compare the payment amounts in each successive month for each of
the top 10 paying customers in order to find the difference across their monthly
payments during 2007 */

SELECT t1.payment_month,
       t2.customer_name,
	   t1.pay_count_per_month,
	   t1.pay_amount_per_month,
	   LEAD (t1.pay_amount_per_month) OVER(PARTITION BY t2.customer_name ORDER BY t1.payment_month) AS lead,
	   LEAD (t1.pay_amount_per_month) OVER(PARTITION BY t2.customer_name ORDER BY t1.payment_month) - t1.pay_amount_per_month AS lead_difference
FROM
(SELECT DATE_TRUNC('month', payment_date) payment_month,
       c.first_name || ' ' || c.last_name AS customer_name,
 	   COUNT(*) pay_count_per_month,
       SUM(p.amount) pay_amount_per_month
FROM customer c
JOIN payment p
ON p.customer_id = c.customer_id
GROUP BY 1,2) t1

JOIN

(SELECT c.first_name || ' ' || c.last_name AS customer_name,
       SUM(p.amount)
FROM customer c
JOIN payment p
ON p.customer_id = c.customer_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10) t2

ON t1.customer_name = t2.customer_name
ORDER BY t2.customer_name, t1.payment_month
