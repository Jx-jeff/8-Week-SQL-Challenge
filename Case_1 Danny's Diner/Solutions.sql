-- 1. What is the total amount each customer spent at the restaurant?

SELECT
	s.customer_id, 
	sum(m.price) AS Total_spend
FROM sales s
JOIN menu m 
	ON m.product_id = s.product_id
GROUP BY 1;



-- 2. How many days has each customer visited the restaurant?

SELECT 
	s.customer_id, 
	COUNT(
	 DISTINCT(s.order_date)
		) as Distinct_Days
FROM sales s
GROUP BY 1
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
	     		ORDER BY COUNT(s.product_id) DESC) AS rn
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



-- 6. Which item was purchased first by the customer after they became a member?

WITH x AS (
	SELECT 
		s.customer_id,
		mb.join_date, 
		min(s.order_date) as fpd
	FROM sales s 
	JOIN members mb on mb.customer_id = s.customer_id
	WHERE (s.order_date) >= mb.join_date
	GROUP BY 1,2
		)
SELECT
	x.customer_id, 
	m.product_name, 
	x.fpd
FROM  x
JOIN sales s
	ON x.fpd = s.order_date
		AND x.customer_id = s.customer_id
JOIN menu m 
	ON s.product_id = m.product_id;



-- 7 Which item was purchased just before the customer became a member?

WITH x AS (
	SELECT 
		s.customer_id, 
		mb.join_date, 
		max(s.order_date) as fpd
	FROM sales s 
	JOIN members mb 
		ON mb.customer_id = s.customer_id
	WHERE (s.order_date) < mb.join_date
	GROUP BY 1,2
		)	
SELECT
	x.customer_id,
	m.product_name, 
	x.fpd
FROM
() x
join sales s on x.fpd = s.order_date and x.customer_id = s.customer_id
join menu m on s.product_id = m.product_id; 



-- 8. What is the total items and amount spent for each member before they became a member?

SELECT 
	s.customer_id, 
	COUNT(s.product_id), 
	SUM(m.price)
FROM sales s
JOIN members mb
	ON mb.customer_id = s.customer_id
JOIN menu m 
	ON m.product_id = s.product_id
WHERE mb.join_date > s.order_date
GROUP BY s.customer_id;



-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT 
	s.customer_id, 
	SUM(
	 if( m.product_name = 'sushi', 2 * 10 * m.price, 10 * m.price)
		) as points 
FROM sales s 
JOIN menu m 
	ON m.product_id = s.product_id
GROUP BY s.customer_id;



-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

SELECT
	s.customer_id,
	COUNT(*), 
	SUM(case
		when (s.order_date between mb.join_date and date_add(mb.join_date, interval 7 day)) 
        	  or m.product_name = 'sushi' 
		then 20 * m.price
        	ELSE 10 * m.price END) as points
FROM sales s
JOIN members mb 
	ON s.customer_id = mb.customer_id
JOIN menu m 
	ON m.product_id = s.product_id 
GROUP BY s.customer_id;






