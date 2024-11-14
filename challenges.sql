USE sakila;

/*
Step 1: Create a View
First, create a view that summarizes rental information for each customer. 
The view should include the customer's ID, name, email address, and total number of rentals (rental_count).

Step 2: Create a Temporary Table
Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). 
The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount
paid by each customer.

Step 3: Create a CTE and the Customer Summary Report
Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. 
The CTE should include the customer's name, email address, rental count, and total amount paid.

Next, using the CTE, create the query to generate the final customer summary report, which should include: 
customer name, email, rental_count, total_paid and average_payment_per_rental, this last column is a derived column from total_paid 
and rental_count.
*/
DROP VIEW IF EXISTS rental_info;

CREATE VIEW rental_info AS

with rental_per_customer as ( 
	select r.customer_id, count(r.rental_id) as rental_count 
	from sakila.rental as r 
	group by r.customer_id
)
select rpc.customer_id, c.first_name, c.last_name, c.email, rpc.rental_count from rental_per_customer as rpc
join sakila.customer as c 
on c.customer_id = rpc.customer_id
;

select * from rental_info;

DROP TEMPORARY TABLE IF EXISTS total_paid;

CREATE TEMPORARY TABLE total_paid
select p.customer_id, sum(p.amount) as 'total_paid_per_customer' from rental_info as ri
join sakila.payment as p
on p.customer_id = ri.customer_id
group by p.customer_id
;

select * from total_paid;

with customer_summary_report as(
select ri.customer_id, ri.first_name, ri.last_name, ri.email, ri.rental_count, t.total_paid_per_customer from rental_info as ri
join total_paid as t
on t.customer_id = ri.customer_id
)
select *, c.total_paid_per_customer/c.rental_count as 'average_paid_per_rental' from customer_summary_report as c;