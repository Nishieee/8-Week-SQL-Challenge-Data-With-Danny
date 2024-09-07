-- Q1
SELECT s.customer_id, sum(m.price) from sales s 
left join menu m 
on s.product_id = m.product_id 
group by s.customer_id

-- Q2 
SELECT customer_id, count(distinct order_date) from sales 
group by customer_id

-- Q3
with cte as (
select s.customer_id, row_number() over(partition by s.customer_id order by s.order_date) as sliding_window, m.product_name 
from sales s 
left join menu m 
on s.product_id = m.product_id)

select customer_id, product_name
from cte 
where sliding_window = 1

-- Q4 
select s.product_id, m.product_name, count(s.product_id) as most_purchased_item 
from sales s 
left join menu m 
on s.product_id = m.product_id
group by s.product_id, m.product_name
order by most_purchased_item desc
limit 1;


-- Q5 

with customer_count as(
select s.customer_id, s.product_id, m.product_name, count(s.product_id) as purchased_item 
from sales s 
left join menu m 
on s.product_id = m.product_id
group by s.customer_id, s.product_id, m.product_name), 
ranked_items as(
select customer_id, product_id, product_name, purchased_item, row_number() over (partition by customer_id order by purchased_item desc) as rank 
from customer_count)

select customer_id, product_name
from ranked_items
where rank = 1



-- Q6 

with cte as (
SELECT s.customer_id, s.product_id, s.order_date, m.join_date, row_number() over (partition by s.customer_id order by s.order_date) as ranked_columns
from sales s 
join members m 
on s.customer_id = m.customer_id
WHERE s.order_date > m.join_date)

select me.product_name, c.customer_id
from cte c 
join menu me 
on c.product_id = me.product_id
WHERE c.ranked_columns = 1;



-- Q7

with cte as (
SELECT s.customer_id, s.product_id, s.order_date, m.join_date, rank() over (partition by s.customer_id order by s.order_date desc) as ranked_columns
from sales s 
join members m 
on s.customer_id = m.customer_id
WHERE s.order_date < m.join_date)

select me.product_name, c.customer_id
from cte c 
join menu me 
on c.product_id = me.product_id
WHERE c.ranked_columns = 1;


-- Q8 

WITH cte AS (
  SELECT s.customer_id, 
         s.product_id, 
         COUNT(s.product_id) AS product_count, 
         s.order_date
  FROM sales s 
  JOIN members m 
  ON s.customer_id = m.customer_id
  WHERE s.order_date < m.join_date 
  GROUP BY s.customer_id, s.product_id, s.order_date
)

SELECT c.customer_id, 
       SUM(c.product_count) AS total_items,  
       SUM(me.price * c.product_count) AS total_spent 
FROM cte c 
JOIN menu me 
ON c.product_id = me.product_id
GROUP BY c.customer_id;




 -- Q9 

WITH cte AS(
SELECT s.customer_id, case when s.product_id = '1' then me.price * 20 else me.price * 10 end as total_points_per_dish 
from sales s 
join menu me 
on s.product_id = me.product_id)

SELECT customer_id, sum(total_points_per_dish) as total_points 
from cte 
group by customer_id



-- Q10 








