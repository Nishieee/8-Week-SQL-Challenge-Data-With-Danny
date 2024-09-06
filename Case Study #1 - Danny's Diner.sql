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



