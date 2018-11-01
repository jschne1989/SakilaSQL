use sakila;

# 1a. Display the first and last names of all actors from the table actor.
select first_name, last_name 
from actor a;

# 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.;
select UPPER(CONCAT(first_name,' ', last_name)) as actor_name from actor;

select actor_id, first_name, last_name
from actor 
where first_name = "Joe";

#2b. Find all actors whose last name contain the letters GEN:
select first_name, last_name
from actor
where last_name like "%gen%";

#2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
select first_name, last_name
from actor
where last_name like "%li%"
order by last_name DESC, first_name DESC;

#Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
Select country_id, country
from country
where country in ('Afghanistan', 'Bangladesh', 'China');

#3a. You want to keep a description of each actor. You don't think you
# will be performing queries on a description, so create a column in the 
#table actor named description and use the data type BLOB (Make sure to 
#research the type BLOB, as the difference between it and VARCHAR are significant).
Alter Table actor
Add Description VARCHAR(255);

#3b. Very quickly you realize that entering descriptions for each 
#actor is too much effort. Delete the description column.
Alter Table actor
Drop Description;

#4a. List the last names of actors, as well as how 
#many actors have that last name.
Select last_name, count(*) As 'Number of Actors'
from actor
Group By last_name;

#4b. List last names of actors and the number of actors who 
#have that last name, but only for names that are 
#shared by at least two actors
Select last_name, Count(*) As 'Number of Actors'
from actor group by last_name Having count(*) >=2;

#4c. The actor HARPO WILLIAMS was accidentally entered in 
#the actor table as GROUCHO WILLIAMS. Write a query 
#to fix the record.
Update actor
Set last_name = 'Williams', first_name = 'Harpo'
where last_name = 'Williams' and first_name = 'Groucho';


#4d. Perhaps we were too hasty in changing GROUCHO to HARPO. 
#It turns out that GROUCHO was the correct name after all! 
#In a single query, if the first name of the actor is currently 
#HARPO, change it to GROUCHO.
Update actor
set first_name = 'Groucho'
where actor_id = 172;

#5a. You cannot locate the schema of the address table. 
#Which query would you use to re-create it?
Show create table address;

#6a. Use JOIN to display the first and last names, as well 
#as the address, of each staff member. Use the tables staff and address:
select first_name, last_name, address
from staff s
join address a on s.address_id = a.address_id;

#6b. Use JOIN to display the total amount rung 
#up by each staff member in August of 2005. 
#Use tables staff and payment.
SELECT payment.staff_id, staff.first_name, staff.last_name, sum(payment.amount), payment.payment_date
FROM staff INNER JOIN payment ON
staff.staff_id = payment.staff_id AND payment_date LIKE '2005-08%'
group by staff_id;

#6c. List each film and the number of actors who are listed for that film.
#Use tables film_actor and film. Use inner join.
Select f.title, count(fa.actor_id) as 'Number of Actors'
from film_actor fa Inner Join film f On
fa.film_id = f.film_id
group by f.title;

#6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT title, (
SELECT COUNT(*) FROM inventory
WHERE film.film_id = inventory.film_id
) AS 'Number of Copies'
FROM film
WHERE title = "Hunchback Impossible";

#6e. Using the tables payment and customer and the JOIN command, list the total 
#paid by each customer. List the customers alphabetically by last name:
Select first_name, last_name, sum(amount) as 'Total Amount Paid'
from customer c join
payment p on c.customer_id = p.customer_id
group by last_name, first_name
order by last_name;

#7a. The music of Queen and Kris Kristofferson 
#have seen an unlikely resurgence. As an unintended 
#consequence, films starting with the letters K and 
#Q have also soared in popularity. Use subqueries to 
#display the titles of movies starting with the letters 
#K and Q whose language is English.

#language_id, language
Select f.title 
from film f
Join language l on f.language_id = l.language_id
where l.name = "English";

#7b. Use subqueries to display all actors who appear in the film Alone Trip.
#film on film_id to film_actor to actor on actor_id
select a.first_name, a.last_name
from actor a
Join film_actor fa on fa.actor_id = a.actor_id
join film f on f.film_id = fa.film_id
where f.title = "Alone Trip";

#7c. You want to run an email marketing campaign in Canada, for
#which you will need the names and email addresses of all Canadian
#customers. Use joins to retrieve this information.
Select first_name, last_name, email
from customer c
join address a on c.address_id = a.address_id
join city ci on a.city_id = ci.city_id
join country co on ci.country_id = co.country_id
where country = "Canada";

#7d.
SELECT title, description FROM film 
WHERE film_id IN
(
SELECT film_id FROM film_category
WHERE category_id IN
(
SELECT category_id FROM category
WHERE name = "Family"
));

#7e
SELECT f.title, COUNT(rental_id) AS 'Times Rented'
FROM rental r
JOIN inventory i
ON (r.inventory_id = i.inventory_id)
JOIN film f
ON (i.film_id = f.film_id)
GROUP BY f.title
ORDER BY `Times Rented` DESC;


#7f
SELECT s.store_id, SUM(amount) AS 'Revenue'
FROM payment p
JOIN rental r
ON (p.rental_id = r.rental_id)
JOIN inventory i
ON (i.inventory_id = r.inventory_id)
JOIN store s
ON (s.store_id = i.store_id)
GROUP BY s.store_id; 

#7g
SELECT s.store_id, cty.city, country.country 
FROM store s
JOIN address a 
ON (s.address_id = a.address_id)
JOIN city cty
ON (cty.city_id = a.city_id)
JOIN country
ON (country.country_id = cty.country_id);

#7h
SELECT c.name AS 'Genre', SUM(p.amount) AS 'Gross' 
FROM category c
JOIN film_category fc 
ON (c.category_id=fc.category_id)
JOIN inventory i 
ON (fc.film_id=i.film_id)
JOIN rental r 
ON (i.inventory_id=r.inventory_id)
JOIN payment p 
ON (r.rental_id=p.rental_id)
GROUP BY c.name ORDER BY Gross  LIMIT 5;

#8a.
CREATE VIEW genre_revenue AS
SELECT c.name AS 'Genre', SUM(p.amount) AS 'Gross' 
FROM category c
JOIN film_category fc 
ON (c.category_id=fc.category_id)
JOIN inventory i 
ON (fc.film_id=i.film_id)
JOIN rental r 
ON (i.inventory_id=r.inventory_id)
JOIN payment p 
ON (r.rental_id=p.rental_id)
GROUP BY c.name ORDER BY Gross  LIMIT 5;

#8b

Select * from genre_revenue;

#8c

Drop View genre_revenue;