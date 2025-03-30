-- Add you solution queries below:
USE sakila;
-- How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT COUNT(*) AS "Hunchback Impossible copies"
FROM inventory
WHERE film_id = (SELECT film_id FROM film WHERE title LIKE '%Hunchback Impossible%');

-- List all films whose length is longer than the average of all the films.--
SELECT title 
FROM film 
WHERE length > (SELECT AVG(length) FROM film);

--  Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name AS "ACTOR NAME" , last_name AS "ACTOR LAST NAME"
FROM actor
WHERE actor_id IN (
    SELECT actor_id
    FROM film_actor
    WHERE film_id = (SELECT film_id FROM film WHERE title LIKE '%Alone Trip%'));
    
-- Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.
SELECT film.title
FROM film
WHERE film_id IN (
    SELECT film_id
    FROM film_category
    WHERE category_id = (SELECT category_id FROM category WHERE name LIKE '%Family%')
);

-- Get name and email from customers from Canada using subqueries. Do the same with joins. 
-- Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, 
-- that will help you get the relevant information.

SELECT first_name, last_name, email
FROM customer
WHERE address_id IN (
    SELECT address_id
    FROM address
    WHERE city_id IN (
        SELECT city_id
        FROM city
        WHERE country_id = (SELECT country_id FROM country WHERE country LIKE '%Canada%')
    ) ) ;

SELECT customer.first_name, customer.last_name, customer.email
FROM customer 
JOIN address ON customer.address_id = address.address_id
JOIN city ON address.city_id = city.city_id
JOIN country ON city.country_id = country.country_id
WHERE country.country LIKE '%Canada%';

-- Which are films starred by the most prolific actor? 
-- Most prolific actor is defined as the actor that has acted in the most number of films. 
-- First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.
SELECT actor_id, COUNT(film_id) AS number_of_films
FROM film_actor
GROUP BY actor_id
ORDER BY number_of_films DESC
LIMIT 1;

SELECT film.title
FROM film 
INNER JOIN film_actor ON film.film_id = film_actor.film_id
WHERE film_actor.actor_id = 107
LIMIT 1;

SELECT film.title
FROM film
INNER JOIN film_actor ON film.film_id = film_actor.film_id
WHERE film_actor.actor_id = (
    SELECT actor_id
    FROM film_actor
    GROUP BY actor_id
    ORDER BY COUNT(film_id) DESC
    LIMIT 1
)LIMIT 1;

-- Films rented by most profitable customer. You can use the customer table 
-- and payment table to find the most profitable customer ie the customer that has made the largest sum of payments

SELECT film.title
FROM film 
INNER JOIN inventory  ON film.film_id = inventory.film_id
INNER JOIN rental ON inventory.inventory_id = rental.inventory_id
WHERE rental.customer_id = (
    SELECT payment.customer_id
    FROM payment 
    GROUP BY payment.customer_id
    ORDER BY SUM(payment.amount) DESC
    LIMIT 1
)LIMIT 1;

-- Get the client_id and the total_amount_spent of those clients 
-- who spent more than the average of the total_amount spent by each client.

-- total amount spent by each customer -- 
CREATE TEMPORARY TABLE customer_totals AS
SELECT customer_id, SUM(amount) AS total_amount
FROM payment
GROUP BY customer_id;

-- average total amount -- 
CREATE TEMPORARY TABLE average_total AS
SELECT AVG(total_amount) AS avg_total
FROM customer_totals;

-- customers IDs that consume more than average -- 
SELECT customer_id, total_amount
FROM customer_totals
WHERE total_amount > (SELECT avg_total FROM average_total)
