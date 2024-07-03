### Solutions
-- 1. What is the total amount each customer spent at the restaurant?
```sql
SELECT
	s.customer_id, 
	sum(m.price) AS Total_spend
FROM sales s
JOIN menu m 
	ON m.product_id = s.product_id
GROUP BY 1;
```
![Screenshot 2024-07-03 021351](https://github.com/Jx-jeff/8-Week-SQL-Challenge/assets/131775252/5e9b4d44-950b-4466-aac5-957515e57f10)


<br/>

-- 2. How many days has each customer visited the restaurant?
```sql
SELECT 
	s.customer_id, 
	COUNT(
	 DISTINCT(s.order_date)
		) as Distinct_Days
FROM sales s
GROUP BY 1
ORDER BY Distinct_Days desc;
```
![Screenshot 2024-07-03 021408](https://github.com/Jx-jeff/8-Week-SQL-Challenge/assets/131775252/55cd6862-29bf-476a-987d-598caa860338)

<br/>

-- 3. What was the first item from the menu purchased by each customer?

```sql
WITH x AS (
	SELECT
		s.customer_id,
		m.product_name,
		min(s.order_date) as Fd,
		RANK() OVER(
			  PARTITION BY (s.customer_id)
			  ORDER BY min(s.order_date)) as rn
	FROM sales s
	JOIN menu m
		ON s.product_id = m.product_id
	GROUP BY 1,2
		)
SELECT *
FROM x
WHERE X.rn = 1;
```
![Screenshot 2024-07-03 021427](https://github.com/Jx-jeff/8-Week-SQL-Challenge/assets/131775252/74de6437-42f0-4a1c-bbbf-c41e780bc2e4)

<br/>

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
```SQL
SELECT
	m.product_name,
	count(s.product_id) as purchase_count
FROM sales s
JOIN menu m
	ON s.product_id = m.product_id
GROUP BY 1
ORDER BY 2 desc;
```
![Screenshot 2024-07-03 031510](https://github.com/Jx-jeff/8-Week-SQL-Challenge/assets/131775252/9bd3d8b4-b92b-4d06-823a-849fc781e073)

<br/>

-- 5. Which item was the most popular for each customer?
```SQL
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
```
![Screenshot 2024-07-03 031732](https://github.com/Jx-jeff/8-Week-SQL-Challenge/assets/131775252/6394362c-3943-4e02-a8a4-e520582fa970)

<br/>

-- 6. Which item was purchased first by the customer after they became a member?
```SQL
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
```
![Screenshot 2024-07-03 033554](https://github.com/Jx-jeff/8-Week-SQL-Challenge/assets/131775252/0f7b2b23-b9d2-458b-8bfc-b548452494af)

<br/>

-- 7 Which item was purchased just before the customer became a member?
```SQL
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
FROM x
JOIN sales s
	ON x.fpd = s.order_date
	  AND x.customer_id = s.customer_id
JOIN menu m
	ON s.product_id = m.product_id; 
```
![Screenshot 2024-07-03 033855](https://github.com/Jx-jeff/8-Week-SQL-Challenge/assets/131775252/bfe741c1-e64f-4aa4-a32f-ff65907cc91b)

<br/>

-- 8. What is the total items and amount spent for each member before they became a member?
```SQL
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
```
![Screenshot 2024-07-03 034616](https://github.com/Jx-jeff/8-Week-SQL-Challenge/assets/131775252/d9011f77-76a8-4c4f-a54e-bed284e6be35)

<br/>

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
```SQL
SELECT 
	s.customer_id, 
	SUM(
	 if( m.product_name = 'sushi', 2 * 10 * m.price, 10 * m.price)
		) as points 
FROM sales s 
JOIN menu m 
	ON m.product_id = s.product_id
GROUP BY s.customer_id;
```
![Screenshot 2024-07-03 034722](https://github.com/Jx-jeff/8-Week-SQL-Challenge/assets/131775252/4909ca16-9202-451c-b354-266d9f29c76d)

<br/>

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
```SQL
SELECT
	s.customer_id, 
	SUM(case
		when (s.order_date between mb.join_date and date_add(mb.join_date, interval 7 day)) 
        	  or m.product_name = 'sushi' 
		then 20 * m.price
        	ELSE 10 * m.price END) as points
FROM sales s
LEFT JOIN members mb 
	ON s.customer_id = mb.customer_id
JOIN menu m 
	ON m.product_id = s.product_id 
GROUP BY s.customer_id;
```
![Screenshot 2024-07-03 035329](https://github.com/Jx-jeff/8-Week-SQL-Challenge/assets/131775252/6c6a2a80-8840-4273-81cb-5f41f9d78d75)


