

use pizzahut;
-- QUESTION

/*
Basic:
Retrieve the total number of orders placed.
Calculate the total revenue generated from pizza sales.
Identify the highest-priced pizza.
Identify the most common pizza size ordered.
List the top 5 most ordered pizza types along with their quantities.


Intermediate:
Join the necessary tables to find the total quantity of each pizza category ordered.
Determine the distribution of orders by hour of the day.
Join relevant tables to find the category-wise distribution of pizzas.
Group the orders by date and calculate the average number of pizzas ordered per day.
Determine the top 3 most ordered pizza types based on revenue.

Advanced:
Calculate the percentage contribution of each pizza type to total revenue.
Analyze the cumulative revenue generated over time.
Determine the top 3 most ordered pizza types based on revenue for each pizza category.

*/

-- 1.Retrieve the total number of orders placed.

SELECT 
    COUNT(*) as total_orders
FROM
    orders;
    
    
 -- 2.Calculate the total revenue generated from pizza sales.  
 select * from order_details; -- quantity
 select * from pizzas; -- price
 
SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_revenue
FROM
    order_details
        INNER JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;
 

-- 3. Identify the highest-priced pizza.
Select * from pizza_types;
select * from pizzas;

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        INNER JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;     


-- 4. Identify the most common pizza size ordered.


select * from order_details;
select * from pizzas;

SELECT 
    size, count(order_details.order_details_id) total_times_orders
FROM
    order_details
        INNER JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizzas.size
ORDER BY total_times_orders DESC;


-- 5. List the top 5 most ordered pizza types along with their quantities.


select * from order_details; -- pizza_id ,quantity
SELECT * from pizzas; -- pizza_id,pizza_type_id
select * from pizza_types; -- pizza_type_id


SELECT 
    pizza_types.name,
    SUM(order_details.quantity) AS total_quantities
FROM
    order_details
        INNER JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
        INNER JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY  pizza_types.name
ORDER BY total_quantities DESC
LIMIT 5;


-- 6. Join the necessary tables to find the total quantity of each pizza category ordered.


select * from pizza_types; -- pizza_type_id, category
select * from pizzas; -- pizz_type_id,pizza_id
select * from order_details; -- ,pizza_id,quantity

SELECT 
    pizza_types.category,
    COUNT(order_details.quantity) AS total_quantities
FROM
    pizza_types
        INNER JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        INNER JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category
ORDER BY total_quantities DESC;



-- 7.Determine the distribution of orders by hour of the day.
SELECT 
    EXTRACT(HOUR FROM order_time) AS current_hour,
    COUNT(order_id) AS total_orders
FROM
    orders
GROUP BY current_hour;


-- 8. Join relevant tables to find the category-wise distribution of pizzas.
select * from pizza_types; -- pizza_type_id category

SELECT 
    category, COUNT(name) AS pizza_type
FROM
    pizza_types
GROUP BY category;



-- 9.Group the orders by date and calculate the average number of pizzas ordered per day.


WITH total_pizza_per_day as 
(
select 
	order_date,
   sum(order_details.quantity)  as total_pizza
from orders
JOIN order_details
ON orders.order_id = order_details.order_id
GROUP BY order_date
) 

SELECT ROUND(avg(total_pizza),0)as average_pizza_ordered_per_day FROM total_pizza_per_day;



-- 10. Determine the top 3 most ordered pizza types based on revenue.


select * FROM pizza_types; -- name , pizza_type_id
select * from pizzas; -- pizza_type_id ,pizza_id,price
select * from order_details; -- order_id,pizza_id quantity

SELECT 
    pizza_types.name,
    SUM(pizzas.price * order_details.quantity) AS total_revenue_by_pizza_type
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY total_revenue_by_pizza_type DESC
LIMIT 3; 


-- 11. Calculate the percentage contribution of each pizza type to total revenue.

SELECT * from pizza_types; -- pizza_type_id ,category
SELECT * from pizzas; -- pizza_id,pizza_type_id, price
SELECT * from order_details; -- pizza_id quantity


SELECT 
    pizza_types.category AS category,
    ROUND(SUM(pizzas.price * order_details.quantity) / (SELECT 
            ROUND(SUM(order_details.quantity * pizzas.price),
                        2) AS total_revenue
        FROM
            order_details
                INNER JOIN
            pizzas ON order_details.pizza_id = pizzas.pizza_id) * 100,2) AS revenue_percentage
FROM
    pizza_types
        INNER JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        INNER JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category;



-- 12. Analyze the cumulative revenue generated over time.


-- select * from order_details; -- order_id
-- select * from orders; -- order_id,order_date

SELECT 
    order_date,
    revenue_per_day,
    SUM(revenue_per_day) OVER(order by order_date) as cumulative_sum
FROM    
(SELECT 
    orders.order_date,
    ROUND(SUM(pizzas.price * order_details.quantity),
            0) as revenue_per_day
FROM
    pizzas
        INNER JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
        INNER JOIN
    orders ON order_details.order_id = orders.order_id
GROUP BY orders.order_date
) as sales;



-- 13.Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT * from pizza_types; -- pizza_type_id category
select * from pizzas; -- pizza_id, pizza_type_id , price
select * from order_details; -- order_id,pizza_id , quantity

SELECT 
   name, 
   category,
   total_revenue_by_pizza_name,
   ranka
FROM   
(SELECT  name,
      category,
      total_revenue_by_pizza_name,
      rank() OVER(Partition BY category ORDER BY total_revenue_by_pizza_name desc) as ranka
FROM    
(SELECT 
    pizza_types.name,
    pizza_types.category,
    ROUND(SUM(pizzas.price * order_details.quantity),2) AS total_revenue_by_pizza_name
FROM
    pizza_types
        INNER JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        INNER JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name , pizza_types.category
)
as test1)
as test2
where ranka <= 3;    


