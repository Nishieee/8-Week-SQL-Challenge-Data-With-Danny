
-- Q1
select count(pizza_id) from customer_orders

-- Q2
select count(distinct order_id) from customer_orders

--Q3
select count(order_id) 
from runner_orders
where duration not like '%null%'

--Q4
select count(r.order_id), c.pizza_id
from customer_orders c 
join runner_orders r 
on c.order_id = r.order_id 
where r.duration != 'null'
group by c.pizza_id


-- Q5 
SELECT 
    c.customer_id,
    SUM(CASE WHEN p.pizza_name = 'Vegetarian' THEN 1 ELSE 0 END) AS vegetarian_count,
    SUM(CASE WHEN p.pizza_name = 'Meatlovers' THEN 1 ELSE 0 END) AS meatlovers_count
FROM 
    pizza_runner.customer_orders c
JOIN 
    pizza_runner.pizza_names p 
ON 
    c.pizza_id = p.pizza_id
GROUP BY 
    c.customer_id;


