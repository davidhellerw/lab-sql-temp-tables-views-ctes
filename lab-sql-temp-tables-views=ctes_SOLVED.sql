USE sakila;

-- Create a View
-- First, create a view that summarizes rental information for each customer. The view should include 
-- the customer's ID, name, email address, and total number of rentals (rental_count).

DROP VIEW IF EXISTS rental_info;

CREATE VIEW rental_info AS
SELECT c.customer_id, CONCAT(c.first_name, " ", c.last_name) AS name, c.email, COUNT(r.rental_id) AS rental_count
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
GROUP BY c.customer_id;

-- Create a Temporary Table
-- Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). 
-- The Temporary Table should use the rental summary view created in Step 1 to join with the payment table 
-- and calculate the total amount paid by each customer.

DROP TEMPORARY TABLE IF EXISTS total_paid;

CREATE TEMPORARY TABLE total_paid AS
SELECT ri.customer_id, ri.name, ri.rental_count, SUM(p.amount) AS total_amount
FROM rental_info ri
JOIN payment p ON ri.customer_id = p.customer_id
GROUP BY ri.customer_id;

-- Create a CTE and the Customer Summary Report
-- Create a CTE that joins the rental summary View with the customer payment summary Temporary Table 
-- created in Step 2. The CTE should include the customer's name, email address, rental count, and
-- total amount paid.

WITH customer_payment_info AS (
						SELECT ri.name, ri.email, ri.rental_count, tp.total_amount
                        FROM rental_info ri
                        JOIN total_paid tp ON ri.customer_id = tp.customer_id)

-- Next, using the CTE, create the query to generate the final customer summary report, which should 
-- include: customer name, email, rental_count, total_paid and average_payment_per_rental, this 
-- last column is a derived column from total_paid and rental_count.

SELECT cpi.name, cpi.email, cpi.rental_count, cpi.total_amount AS total_paid, 
		ROUND(cpi.total_amount/cpi.rental_count, 2) AS average_payment_per_rental
FROM customer_payment_info cpi
ORDER BY total_paid DESC;
