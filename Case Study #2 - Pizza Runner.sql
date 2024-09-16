
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


-- Q6
SELECT 
    r.order_id, 
    count(c.pizza_id) as total_pizza_count
from 
    runner_orders r 
left join 
    customer_orders c 
on 
    r.order_id = c.order_id
where 
    duration != 'null'
group by 
    r.order_id
order by 
    count(c.pizza_id) desc
limit 1; 



-- Q7 


SELECT 
    c.customer_id,
    COUNT(CASE WHEN (c.exclusions != '' AND c.exclusions != 'null') OR (c.extras != '' AND c.extras != 'null') 
               THEN 1 END) AS pizzas_with_changes,
    COUNT(CASE WHEN (c.exclusions = '' OR c.exclusions = 'null') AND (c.extras = '' OR c.extras = 'null') 
               THEN 1 END) AS pizzas_without_changes
FROM 
    pizza_runner.customer_orders c
JOIN 
    pizza_runner.runner_orders r
ON 
    c.order_id = r.order_id
WHERE 
    r.duration != 'null'  -- Only consider delivered pizzas
GROUP BY 
    c.customer_id;

--Q8

SELECT 
    c.customer_id,
    COUNT(CASE WHEN (c.exclusions != '' AND c.exclusions != 'null') OR (c.extras != '' AND c.extras != 'null') 
               THEN 1 END) AS pizzas_with_changes
FROM 
    pizza_runner.customer_orders c
JOIN 
    pizza_runner.runner_orders r
ON 
    c.order_id = r.order_id
WHERE 
    r.duration != 'null'  -- Only consider delivered pizzas
GROUP BY 
    c.customer_id;


-- Q9
SELECT EXTRACT(HOUR FROM order_time) AS "Hour",
       COUNT(order_id) AS "Number of pizzas ordered",
       ROUND(100.0 * COUNT(order_id) / SUM(COUNT(order_id)) OVER(), 2) AS "Volume of pizzas ordered"
FROM pizza_runner.customer_orders
GROUP BY EXTRACT(HOUR FROM order_time)
ORDER BY "Hour"; 












