-- 1. What is the total amount each customer spent at the restaurant?

SELECT 
  s.customer_id, 
  sum(m.price) AS Total_spend
FROM sales s
JOIN menu m 
  ON m.product_id = s.product_id
GROUP BY s.customer_id;


-- 2. How many days has each customer visited the restaurant?

SELECT 
  s.customer_id, 
  COUNT(
    DISTINCT(s.order_date)
         ) as Distinct_Days
FROM sales s
GROUP BY s.customer_id
ORDER BY Distinct_Days desc;


-- 3. What was the first item from the menu purchased by each customer?

-- 5. Which item was the most popular for each customer?

WITH X AS (
  SELECT 
   s.customer_id, 
   m.product_name, 
   COUNT(s.product_id) AS purchase_number,
   RANK() OVER(
     PARTITION BY(s.customer_id) 
     ORDER BY COUNT(s.product_id) DESC
               ) AS rn
	FROM sales s
	JOIN menu m 
   ON s.product_id = m.product_id
	GROUP BY 1,2
              )
SELECT 
  x.customer_id, 
  x.product_name, 
  x.purchase_number
FROM x
WHERE x.rn = 1;
