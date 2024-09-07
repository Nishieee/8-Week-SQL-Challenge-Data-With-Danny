CREATE SCHEMA dannys_diner;
SET search_path = dannys_diner;

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
select * from members;
select * from sales;
select * from menu;
  
  /* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
-- 2. How many days has each customer visited the restaurant?
-- 3. What was the first item from the menu purchased by each customer?
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
-- 5. Which item was the most popular for each customer?
-- 6. Which item was purchased first by the customer after they became a member?
-- 7. Which item was purchased just before the customer became a member?
-- 8. What is the total items and amount spent for each member before they became a member?
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?





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








