/*  INTRODUCTION TO THE PROJECT:

THE SITUATION:
You and your Uncle Jimmy just purchased Maven Movies, a brick and mortar DVD Rental business. 
Uncle Jimmy put up the money, and you’re in charge of the day-to-day operations.

THE BRIEF: 
As a new owner, you’ll need to learn everything you can about your business: your product inventory,
your staff, your customer purchase behaviors, etc. You have access to the entire Maven Movies SQL database.

THE OBJECTIVE:
Use MySQL to:
• Access and explore the Maven Movies database
• Develop a firm grasp of the 16 database tables and how they relate to each other
• Analyze all aspects of the company’s data, including transactions, customers, staff, etc.
*/


/* Q1.	We will need a list of all staff members, including their first and last names, 
email addresses, and the store identification number where they work. */
 
-- SOLUTION
SELECT 
    first_name, last_name, email, store_id
FROM
    staff;


/* Q2.	We will need separate counts of inventory items held at each of your two stores. */ 

-- SOLUTION
SELECT 
    store_id, 
    COUNT(inventory_id) AS num_of_items
FROM
    inventory
GROUP BY store_id;


-- Q3.	We will need a count of active customers for each of your stores. Separately, please. 

-- SOLUTION
SELECT 
	store_id,
    COUNT(customer_id) AS num_of_active_customers
FROM customer 
WHERE active = 1 
GROUP BY store_id;


/* Q4.	In order to assess the liability of a data breach, we will need you to provide a count 
of all customer email addresses stored in the database. */

SELECT 
	COUNT(email) AS num_of_emails
FROM customer;



/* Q5.	We are interested in how diverse your film offering is as a means of understanding how likely 
you are to keep customers engaged in the future. Please provide a count of unique film titles 
you have in inventory at each store and then provide a count of the unique categories of films you provide. */

SELECT 
    store_id, COUNT(DISTINCT film_id) AS num_of_unique_films
FROM
    inventory
GROUP BY store_id;

SELECT 
    COUNT(DISTINCT rating) AS num_of_unique_categories_or_ratings
FROM
    film;

SELECT 
    rating, COUNT(film_id) AS num_of_films
FROM
    film
GROUP BY rating
ORDER BY 2 DESC;


/*
Q6.	We would like to understand the replacement cost of your films. 
Please provide the replacement cost for the film that is least expensive to replace, 
the most expensive to replace, and the average of all films you carry. ``	
*/
SELECT 
    MIN(replacement_cost) AS least_replacement_cost,
    MAX(replacement_cost) AS highest_replacement_cost,
    AVG(replacement_cost) AS average_replacement_cost
FROM
    film;
    

/*
Q7.	We are interested in having you put payment monitoring systems and maximum payment 
processing restrictions in place in order to minimize the future risk of fraud by your staff. 
Please provide the average payment you process, as well as the maximum payment you have processed.
*/
SELECT 
    AVG(amount) AS average_payment_processed,
    MAX(amount) AS max_payment_processed
FROM
    payment;
    

/*
Q8.	We would like to better understand what your customer base looks like. 
Please provide a list of all customer identification values, with a count of rentals 
they have made all-time, with your highest volume customers at the top of the list.
*/
SELECT * FROM payment;

SELECT 
    payment.customer_id,
    COUNT(payment.payment_id) AS num_of_rentals,
    customer.first_name,
    customer.last_name,
    customer.email
FROM
    payment
        INNER JOIN
    customer ON payment.customer_id = customer.customer_id
GROUP BY payment.customer_id
ORDER BY 2 DESC;


/* 
Q9. My partner and I want to come by each of the stores in person and meet the managers. 
Please send over the managers’ names at each store, with the full address 
of each property (street address, district, city, and country please).  
*/ 
-- Exploring the relevant tables below:

select * from store;
select * from staff;
select * from address;
select * from city;
select * from country;

-- Solution

SELECT 
    store.store_id,
    staff.first_name AS first_name_of_manager,
    staff.last_name AS last_name_of_manager,
    address.address,
    address.district,
    city.city,
    country.country
FROM
    store
        INNER JOIN staff
			ON store.manager_staff_id = staff.staff_id
        INNER JOIN address
			ON store.address_id = address.address_id
        INNER JOIN city
			ON address.city_id = city.city_id
        INNER JOIN country
			ON city.country_id = country.country_id;

	
/*
Q10.	I would like to get a better understanding of all of the inventory that would come along with the business. 
Please pull together a list of each inventory item you have stocked, including the store_id number, 
the inventory_id, the name of the film, the film’s rating, its rental rate and replacement cost. 
*/
-- Exploring the relevant tables below:

select * from inventory;
select * from film;

-- Solution

SELECT 
	film.title,
    film.rating,
    inventory.inventory_id,
    inventory.store_id,
    film.rental_rate,
    film.replacement_cost
FROM inventory
	LEFT JOIN film
		ON inventory.film_id = film.film_id
ORDER BY film.title;


/* 
Q11.	From the same list of films you just pulled, please roll that data up and provide a summary level overview 
of your inventory. We would like to know how many inventory items you have with each rating at each store. 
*/
-- Solution 1

SELECT 
    film.rating,
    inventory.store_id,
    COUNT(inventory.inventory_id) AS num_of_films
FROM inventory
	LEFT JOIN film
		ON inventory.film_id = film.film_id
GROUP BY film.rating, inventory.store_id;

-- OR / Another WAY (More readable in a PIVOT Table format)
-- Solution 2

SELECT 
    film.rating,
    COUNT(CASE WHEN inventory.store_id = 1 THEN inventory.inventory_id ELSE NULL END) AS num_of_films_in_store1,
    count(CASE WHEN inventory.store_id = 2 THEN inventory.inventory_id ELSE NULL END) AS num_of_films_in_store2
FROM inventory
	LEFT JOIN film
		ON inventory.film_id = film.film_id
GROUP BY film.rating;


/* 
Q12. Similarly, we want to understand how diversified the inventory is in terms of replacement cost. We want to 
see how big of a hit it would be if a certain category of film became unpopular at a certain store.
We would like to see the number of films, as well as the average replacement cost, and total replacement cost, 
sliced by store and film category. 
*/ 
-- Relevant tables are: film, film_category, category, inventory
-- Exploring the tables

select * from film;
select * from film_category;
select * from category;
select * from inventory;

-- Solution

SELECT 
    category.name AS film_genre,
    inventory.store_id,
    COUNT(inventory.inventory_id) AS num_of_films,
    AVG(film.replacement_cost) AS average_replacement_cost,
    SUM(film.replacement_cost) AS total_replacement_cost
FROM
    inventory
        LEFT JOIN
    film ON inventory.film_id = film.film_id
        LEFT JOIN
    film_category ON film.film_id = film_category.film_id
        LEFT JOIN
    category ON film_category.category_id = category.category_id
GROUP BY category.name , inventory.store_id;


/*
Q13.	We want to make sure you folks have a good handle on who your customers are. Please provide a list 
of all customer names, which store they go to, whether or not they are currently active, 
and their full addresses – street address, city, and country. 
*/
-- Exploring the relevant tables are: customer, address, city, country 

select * from customer;
select * from address;
select * from city;
select * from country;

-- Solution

SELECT 
    customer.first_name,
    customer.last_name,
    customer.store_id,
    customer.active,
    address.address,
    address.district,
    city.city,
    country.country
FROM
    customer
        LEFT JOIN
    address ON customer.address_id = address.address_id
        LEFT JOIN
    city ON address.city_id = city.city_id
        LEFT JOIN
    country ON city.country_id = country.country_id;
	

/*
Q14.	We would like to understand how much your customers are spending with you, and also to know 
who your most valuable customers are. Please pull together a list of customer names, their total 
lifetime rentals, and the sum of all payments you have collected from them. It would be great to 
see this ordered on total lifetime value, with the most valuable customers at the top of the list. 
*/
-- Exploring the relevant tables are: customer, rental, payment 
 
select * from customer;
select * from rental;
select * from payment;

-- Solution
 
SELECT 
    customer.first_name,
    customer.last_name,
    COUNT(rental.rental_id) AS num_of_rentals,
    SUM(payment.amount) AS total_payment
FROM
    customer
        LEFT JOIN
    rental ON customer.customer_id = rental.customer_id
        LEFT JOIN
    payment ON rental.rental_id = payment.rental_id
GROUP BY customer.customer_id
ORDER BY SUM(payment.amount) DESC;
	

/*
Q15. My partner and I would like to get to know your board of advisors and any current investors.
Could you please provide a list of advisor and investor names in one table? 
Could you please note whether they are an investor or an advisor, and for the investors, 
it would be good to include which company they work with. 
*/
-- Exploring the relevant tables:

select * from advisor;
select * from investor;

SELECT 
    'investor' AS type, 
     first_name, 
     last_name, 
     company_name
FROM
    investor 
UNION 
SELECT 
    'advisor' AS type,
    first_name,
    last_name,
    'Not Applicable' AS company_name
FROM
    advisor;


/*
Q16. We're interested in how well you have covered the most-awarded actors. 
Of all the actors with three types of awards, for what % of them do we carry a film?
And how about for actors with two types of awards? Same questions. 
Finally, how about actors with just one award? 
*/
-- Exploring the relevant tables

select * from actor_award; -- in this table, wherever the actor_id is NULL, we don't have their films in our stores/inventory

-- Solution 

SELECT 
    CASE
        WHEN awards LIKE '%,%,%' THEN '3 awards'
        WHEN awards LIKE '%,%' THEN '2 awards'
        ELSE '1 award'
    END AS num_of_awards,
    AVG(CASE
        WHEN actor_id IS NULL THEN 0
        ELSE 1
    END) * 100 AS percentage_of_films_we_own
FROM
    actor_award
GROUP BY num_of_awards;
	
