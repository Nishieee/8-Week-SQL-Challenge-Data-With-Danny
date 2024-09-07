-- Create the schema and set the search path
CREATE SCHEMA dannys_diner;
SET search_path = dannys_diner;

-- Create sales table
CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

-- Insert records into sales table
INSERT INTO sales ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', 1),
  ('A', '2021-01-01', 2),
  ('A', '2021-01-07', 2),
  ('A', '2021-01-10', 3),
  ('A', '2021-01-11', 3),
  ('A', '2021-01-11', 3),
  ('B', '2021-01-01', 2),
  ('B', '2021-01-02', 2),
  ('B', '2021-01-04', 1),
  ('B', '2021-01-11', 1),
  ('B', '2021-01-16', 3),
  ('B', '2021-02-01', 3),
  ('C', '2021-01-01', 3),
  ('C', '2021-01-01', 3),
  ('C', '2021-01-07', 3);

-- Create menu table
CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

-- Insert records into menu table
INSERT INTO menu ("product_id", "product_name", "price")
VALUES
  (1, 'sushi', 10),
  (2, 'curry', 15),
  (3, 'ramen', 12);

-- Create members table
CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

-- Insert records into members table
INSERT INTO members ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

-- Select data from all tables for verification
SELECT * FROM members;
SELECT * FROM sales;
SELECT * FROM menu;

-- --------------------
-- Case Study Questions
-- --------------------

-- Q1: What is the total amount each customer spent at the restaurant?
SELECT s.customer_id, SUM(m.price)
FROM sales s 
LEFT JOIN menu m ON s.product_id = m.product_id 
GROUP BY s.customer_id;

-- Q2: How many days has each customer visited the restaurant?
SELECT customer_id, COUNT(DISTINCT order_date)
FROM sales 
GROUP BY customer_id;

-- Q3: What was the first item from the menu purchased by each customer?
WITH cte AS (
  SELECT s.customer_id, ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS row_num, m.product_name
  FROM sales s
  LEFT JOIN menu m ON s.product_id = m.product_id
)
SELECT customer_id, product_name
FROM cte 
WHERE row_num = 1;

-- Q4: What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT s.product_id, m.product_name, COUNT(s.product_id) AS most_purchased_item
FROM sales s
LEFT JOIN menu m ON s.product_id = m.product_id
GROUP BY s.product_id, m.product_name
ORDER BY most_purchased_item DESC
LIMIT 1;

-- Q5: Which item was the most popular for each customer?
WITH customer_count AS (
  SELECT s.customer_id, s.product_id, m.product_name, COUNT(s.product_id) AS purchased_item
  FROM sales s
  LEFT JOIN menu m ON s.product_id = m.product_id
  GROUP BY s.customer_id, s.product_id, m.product_name
), ranked_items AS (
  SELECT customer_id, product_id, product_name, purchased_item, ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY purchased_item DESC) AS rank
  FROM customer_count
)
SELECT customer_id, product_name
FROM ranked_items
WHERE rank = 1;

-- Q6: Which item was purchased first by the customer after they became a member?
WITH cte AS (
  SELECT s.customer_id, s.product_id, s.order_date, m.join_date, ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS rank_num
  FROM sales s
  JOIN members m ON s.customer_id = m.customer_id
  WHERE s.order_date > m.join_date
)
SELECT me.product_name, c.customer_id
FROM cte c 
JOIN menu me ON c.product_id = me.product_id
WHERE c.rank_num = 1;

-- Q7: Which item was purchased just before the customer became a member?
WITH cte AS (
  SELECT s.customer_id, s.product_id, s.order_date, m.join_date, RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS rank_num
  FROM sales s
  JOIN members m ON s.customer_id = m.customer_id
  WHERE s.order_date < m.join_date
)
SELECT me.product_name, c.customer_id
FROM cte c 
JOIN menu me ON c.product_id = me.product_id
WHERE c.rank_num = 1;

-- Q8: What is the total items and amount spent for each member before they became a member?
WITH cte AS (
  SELECT s.customer_id, s.product_id, COUNT(s.product_id) AS product_count, s.order_date
  FROM sales s
  JOIN members m ON s.customer_id = m.customer_id
  WHERE s.order_date < m.join_date 
  GROUP BY s.customer_id, s.product_id, s.order_date
)
SELECT c.customer_id, SUM(c.product_count) AS total_items, SUM(me.price * c.product_count) AS total_spent
FROM cte c 
JOIN menu me ON c.product_id = me.product_id
GROUP BY c.customer_id;

-- Q9: How many points would each customer have?
WITH cte AS (
  SELECT s.customer_id, CASE WHEN s.product_id = 1 THEN me.price * 20 ELSE me.price * 10 END AS total_points_per_dish
  FROM sales s
  JOIN menu me ON s.product_id = me.product_id
)
SELECT customer_id, SUM(total_points_per_dish) AS total_points
FROM cte 
GROUP BY customer_id;

-- Q10: How many points do customer A and B have at the end of January?
WITH cte AS (
  SELECT s.customer_id, s.order_date, s.product_id,
    CASE 
      WHEN s.product_id = 1 THEN me.price * 20
      WHEN s.order_date BETWEEN m.join_date AND m.join_date + INTERVAL '6 days' THEN me.price * 20
      ELSE me.price * 10
    END AS total_points_per_dish
  FROM sales s
  JOIN menu me ON s.product_id = me.product_id
  LEFT JOIN members m ON s.customer_id = m.customer_id
  WHERE s.order_date BETWEEN '2021-01-01' AND '2021-01-31'
)
SELECT customer_id, SUM(total_points_per_dish) AS total_points
FROM cte 
GROUP BY customer_id;
