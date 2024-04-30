

-- create the database and enter into it.
CREATE DATABASE pizzahut;
USE pizzahut;

-- importing the csv files directly and also by first creating a table and them importing
CREATE TABLE pizza_types (
pizza_type_id VARCHAR(100) NOT NULL PRIMARY KEY,
pizza_name VARCHAR(100) NOT NULL,
category VARCHAR(100),
ingredients VARCHAR(300)
);

SELECT * FROM pizza_types;
DESCRIBE pizza_types;

-- Problems faced during importing pizza_types csv files.
-- 1. Not detecting the columns properly. Solution = change ; seperator to ,
-- 2. not all the records were getting imported. Solution = Changed the Encoding to Latin1

-- Creating Orders table and then importing the csv file into it.
CREATE TABLE orders (
order_id INT NOT NULL,
order_date DATE NOT NULL,
order_time TIME NOT NULL,
PRIMARY KEY(order_id)
);

-- creating Order_details table
CREATE TABLE order_details (
order_details_id INT NOT NULL,
order_id INT NOT NULL,
pizza_id VARCHAR(200) NOT NULL,
quantity INT NOT NULL,
PRIMARY KEY(order_details_id)
);

-- how to change the data type of order_id?
ALTER TABLE order_details
MODIFY COLUMN order_id INT;

-- checking data in all the tables go get an idea
SELECT * FROM pizzas;
SELECT * FROM pizza_types;
SELECT * FROM orders;
SELECT * FROM order_details;

SELECT DISTINCT(pizza_type_id) FROM pizzas;


-- Retrieve the total numbers of orders placed
SELECT COUNT(order_id) AS total_orders
FROM orders;


-- Calculate total revenue generated from pizza sales
SELECT 
    ROUND(SUM(quantity*price),2) AS sales
FROM order_details INNER JOIN pizzas
	ON order_details.pizza_id = pizzas.pizza_id;
    
    
-- Which pizza has the highest average price
SELECT 
	pizzas.pizza_type_id,
    pizza_types.pizza_name,
    AVG(price) AS avg_price
FROM pizzas INNER JOIN pizza_types
	ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizzas.pizza_type_id
ORDER BY avg_price DESC
LIMIT 1;


-- which pizza has the highest price?
SELECT 
	pizzas.pizza_type_id,
    pizza_types.pizza_name,
    pizzas.price
FROM pizzas INNER JOIN pizza_types
	ON pizzas.pizza_type_id = pizza_types.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- identify the most common pizza size ordered
SELECT 
    SUM(order_details.quantity) AS total_orders_placed,
    pizzas.size
FROM order_details INNER JOIN pizzas
	ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizzas.size
ORDER BY total_orders_placed DESC;


-- list the top 5 most ordered pizzas along with their quantities
SELECT 
	pizza_types.pizza_name,
    SUM(order_details.quantity) AS total_quantity_ordered
FROM order_details INNER JOIN pizzas
	ON order_details.pizza_id = pizzas.pizza_id
    INNER JOIN pizza_types
    ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.pizza_name
ORDER BY total_quantity_ordered DESC
LIMIT 5;



-- INTERMEDIATE LEVEL
-- join the necessary tables to find the total quantity of each pizza category ordered
SELECT 
	pizza_types.category, 
    SUM(order_details.quantity) AS Total_quantity_ordered
FROM order_details INNER JOIN pizzas
	ON order_details.pizza_id = pizzas.pizza_id
    INNER JOIN pizza_types
    ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.category
ORDER BY Total_quantity_ordered DESC;

-- Determine the distribution of orders by hour of the day
SELECT 
    HOUR(order_time) AS Hour_of_the_day,
    SUM(quantity)
FROM order_details INNER JOIN orders
	ON order_details.order_id = orders.order_id
GROUP BY Hour_of_the_day;
    
-- how many pizza types are there in each category?
SELECT
	category,
    COUNT(pizza_type_id) AS Total_pizza_types
FROM pizza_types
GROUP BY category
ORDER BY Total_pizza_types DESC;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
	ROUND(AVG(total_quantity_orderd_per_day),0) AS avg_pizzas_ordered_per_day
FROM
	(SELECT 
		order_date,
		SUM(quantity) AS total_quantity_orderd_per_day
	FROM order_details INNER JOIN orders
		ON order_details.order_id = orders.order_id
	GROUP BY order_date) AS quantity_ordered_per_day_table;
    
-- Find out the top 3 pizzas based on the revenue.
SELECT 
	order_details.pizza_id,
    ROUND(SUM(quantity*price),2) AS revenue
FROM order_details
	INNER JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
GROUP BY order_details.pizza_id
ORDER BY revenue DESC;



-- ADVANCED QUERIES
-- calculate the percentage contribution of each pizza type to total revenue
SELECT 
	SUM(revenue) AS Total_revenue
FROM
	(SELECT 
		pizza_name,
		ROUND(SUM(quantity*price),2) AS revenue
	FROM order_details
		INNER JOIN
		pizzas ON order_details.pizza_id = pizzas.pizza_id
		INNER JOIN
		pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
	GROUP BY pizza_name
	ORDER BY revenue DESC) AS revenue_of_each_pizza_type;
    
-- Final query
    SELECT 
		pizza_name,
		ROUND(SUM(quantity*price),2) AS revenue,
                (ROUND(SUM(quantity*price),2) / (SELECT 
						     SUM(revenue) AS Total_revenue
							FROM
							    (SELECT 
								pizza_name,
								ROUND(SUM(quantity*price),2) AS revenue
								FROM order_details
									INNER JOIN
									pizzas ON order_details.pizza_id = pizzas.pizza_id
									INNER JOIN
									pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
									GROUP BY pizza_name) AS revenue_each_pizza_type)) * 100  AS Percentage_Contributed
	FROM order_details
		INNER JOIN
		pizzas ON order_details.pizza_id = pizzas.pizza_id
		INNER JOIN
		pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
	GROUP BY pizza_name
	ORDER BY revenue DESC;
    
    
-- Analyze the cumulative revenue generated over time
SELECT 
	order_date,
    SUM(revenue_per_day) OVER(ORDER BY order_date) AS cummulative_revenue
FROM
	(SELECT 
		order_date,
		ROUND(SUM(quantity * price),2) AS revenue_per_day
	FROM order_details 
		INNER JOIN
		orders ON order_details.order_id = orders.order_id
		INNER JOIN 
		pizzas ON order_details.pizza_id = pizzas.pizza_id
	GROUP BY order_date) AS sales_per_day;


-- determine the top 3 most ordered pizza types based on revenue of each pizza category
          SELECT *
          FROM
		(SELECT 
			category,
			pizza_name,
			SUM(quantity * price) AS revenue,
			RANK() OVER(PARTITION BY category ORDER BY SUM(quantity * price) DESC) AS top_rank			
		FROM order_details
			INNER JOIN
			pizzas ON order_details.pizza_id = pizzas.pizza_id
			INNER JOIN
			pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
		GROUP BY category, pizza_name) AS top_ranked_pizzas
         WHERE top_rank <=3;

-- https://www.youtube.com/watch?v=zZpMvAedh_E 
