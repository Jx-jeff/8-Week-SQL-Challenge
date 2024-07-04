## Pizza Metrics

### 1. How many pizzas were ordered?

```SQL
SELECT 
  COUNT(co.new_id)
FROM customer_orders2 co;
```
![Screenshot 2024-07-04 141122](https://github.com/Jx-jeff/8-Week-SQL-Challenge/assets/131775252/16bdd700-a593-42b9-90f5-32010b82315d)


### 2. How many unique customer orders were made?
```sql
SELECT
  COUNT(distinct(co.order_id)) AS unique_orders
FROM customer_orders2 co;
```
![Screenshot 2024-07-04 141340](https://github.com/Jx-jeff/8-Week-SQL-Challenge/assets/131775252/45e82524-dbbc-4e04-b279-54517b502d59)

### 3. How many successful orders were delivered by each runner?
``` SQL
SELECT
  ro.runner_id,
  COUNT(ro.order_id) as successful_del
FROM runner_orders2 ro
WHERE cancellation IS NUll
GROUP BY 1;
```
![Screenshot 2024-07-04 141457](https://github.com/Jx-jeff/8-Week-SQL-Challenge/assets/131775252/59f12d17-8534-46a9-8997-c8fb0b230d95)

### 4. How many of each type of pizza was delivered?
```SQL
SELECT
  pn.pizza_name,
  COUNT(co.pizza_id) as Number_delivered
FROM runner_orders2 ro
JOIN customer_orders2 co
  ON ro.order_id = co.order_id
JOIN pizza_names pn
  ON co.pizza_id = pn.pizza_id
WHERE cancellation IS NULL
GROUP BY 1;
```
![Screenshot 2024-07-04 142618](https://github.com/Jx-jeff/8-Week-SQL-Challenge/assets/131775252/9d19573b-95f6-4d05-961b-21b21ad23c98)

### 5. How many Vegetarian and Meatlovers were ordered by each customer?
```SQL
SELECT
  co.customer_id ,
  pn.pizza_name,
  COUNT(co.pizza_id) AS Number_ordered
FROM customer_orders2 co
JOIN pizza_names pn
  ON co.pizza_id = pn.pizza_id
GROUP BY 1,2
ORDER BY 1;
```
![Screenshot 2024-07-04 143246](https://github.com/Jx-jeff/8-Week-SQL-Challenge/assets/131775252/dc9bd961-74b3-47f4-a9c3-14db6926a464)


### 6. What was the maximum number of pizzas delivered in a single order?
``` SQL
WITH pizza_count AS (
	SELECT
		co.order_id, 
		COUNT(co.pizza_id) as pizza_count
	FROM customer_orders2 co
	JOIN runner_orders2 ro 
	  ON co.order_id = ro.order_id
	WHERE cancellation IS NULL
	GROUP BY 1
                        )
SELECT 
    MAX(pc.pizza_count) as Largerst_order
FROM pizza_count pc
```
![Screenshot 2024-07-04 143939](https://github.com/Jx-jeff/8-Week-SQL-Challenge/assets/131775252/f5cbdb2f-540d-44ee-8856-61cfa61c025f)

### 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
``` SQL
with change_table as (
  SELECT
    co.order_id,
    co.customer_id,
    co.pizza_id,
    CASE
      WHEN extras IS NULL AND exclusions IS NULL
        THEN 'no' END AS no_changes,
    CASE
      WHEN extras IS NOT NULL or exclusions IS NOT NULL
        THEN 'yes' END AS changes
  FROM customer_orders2 co
  JOIN runner_orders2 ro
    ON ro.order_id = co.order_id
  WHERE cancellation IS NULL
	                	      )
SELECT
  customer_id,
  COUNT(changes) AS changes,
  COUNT(no_changes) AS no_changes
FROM change_table
GROUP BY 1;
```
![Screenshot 2024-07-04 144644](https://github.com/Jx-jeff/8-Week-SQL-Challenge/assets/131775252/130ac70e-9d35-4ab1-b4d3-712551aa7d67)

### 8. How many pizzas were delivered that had both exclusions and extras?
``` SQL
SELECT 
  co.order_id, 
  co.pizza_id, 
  COUNT(co.pizza_id) AS 'exc_&_extra'
FROM customer_orders2 co
JOIN runner_orders2 ro 
	ON ro.order_id = co.order_id
WHERE cancellation IS NULL 
	AND  extras IS NOT NULL 
  AND exclusions IS NOT NULL 
GROUP BY 1,2;
```
![image](https://github.com/Jx-jeff/8-Week-SQL-Challenge/assets/131775252/4498e431-89f6-462f-8c6d-4a67d386345f)


### 9. What was the total volume of pizzas ordered for each hour of the day?
``` SQL
SELECT  
	CONCAT(
          DATE_FORMAT(co.order_time, '%h'),
          '-', 
          DATE_FORMAT(DATE_ADD(co.order_time, INTERVAL 1 HOUR), '%h %p')
				 ) AS day_hours,
  COUNT(co.pizza_id) AS volumes
FROM customer_orders2 co
GROUP BY 1
;
```
![image](https://github.com/Jx-jeff/8-Week-SQL-Challenge/assets/131775252/e76f06b2-4398-4213-a15c-e8fa0a8d6fd5)

### 10. What was the volume of orders for each day of the week?
``` SQL
SELECT 
	DAYNAME(co.order_time) AS days, 
  COUNT(co.pizza_id) AS volumes
FROM customer_orders2 co
GROUP BY 1;
```
![image](https://github.com/Jx-jeff/8-Week-SQL-Challenge/assets/131775252/9100613b-5559-4b5a-bec4-b2c7ce91e2a5)

## Runner and Customer Experience

### 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
```SQL
WITH RECURSIVE WeekDates AS (
  SELECT
    CAST('2021-01-01' AS DATE) AS week_start,
    CAST('2021-01-07' AS DATE) AS week_end
UNION ALL
  SELECT
    DATE_ADD(week_start, INTERVAL 1 WEEK),
    DATE_ADD(week_end, INTERVAL 1 WEEK)
  FROM WeekDates
  WHERE week_start < '2021-06-31'
                )
SELECT
  CONCAT(
    DATE_FORMAT(week_start, '%d'),
    '-',
    DATE_FORMAT(week_end, '%d %Y')) AS Week,
    COUNT(runner_id) AS Sign_ups
FROM WeekDates wd
JOIN runners r
  ON r.registration_date BETWEEN wd.week_start AND wd.week_end
GROUP BY 1;
```
![image](https://github.com/Jx-jeff/8-Week-SQL-Challenge/assets/131775252/6a818892-985a-48ce-a39a-b5bb2c0ed974)

### 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
```SQL
SELECT distinct
  ro.runner_id,
  round(avg(
          TIMESTAMPDIFF(MINUTE,co.order_time,ro.pickup_time)
            )) AS avg_arriv_time
FROM runner_orders2 ro
JOIN customer_orders2 co
  ON ro.order_id = co.order_id
group by 1;

-- Assuming the rider is called as soon as the order is placed
```
![image](https://github.com/Jx-jeff/8-Week-SQL-Challenge/assets/131775252/d64951d1-c68b-430a-a249-dfdec7c9071b)


### 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
```SQL
with ab as (
  SELECT
    co.order_id,
    COUNT(co.pizza_id) AS pizza_number,
    TIMESTAMPDIFF(MINUTE, co.order_time, ro.pickup_time) AS time_dif
  FROM customer_orders2 co
  JOIN runner_orders2 ro
    ON ro.order_id = co.order_id
  WHERE cancellation is null
  GROUP BY 1,3
              )
SELECT
  pizza_number,
  round(avg(time_dif)) as avg_diff
FROM ab
GROUP BY 1;
-- Assuming the pick_up time is the same as the time the order is ready
```
![image](https://github.com/Jx-jeff/8-Week-SQL-Challenge/assets/131775252/626a56b0-a24d-4f4c-95d7-a9ad9b00cfe3)

Yes there seems to be a positive correlation between the number of pizza per order and the production time


### 4. What was the average distance travelled for each customer?
```SQL
WITH x AS (
  SELECT DISTINCT
    co.customer_id,
    co.order_id, 
		ro.distance
  FROM customer_orders2 co
  JOIN runner_orders2 ro
    ON co.order_id = ro.order_id
	WHERE ro.distance IS NOT NULL
          )
SELECT
  x.customer_id,
  ROUND(
    AVG(x.distance),
    2)
FROM x
GROUP BY 1;
```
![image](https://github.com/Jx-jeff/8-Week-SQL-Challenge/assets/131775252/b564dbd4-2c07-4bfc-a287-eb676d2eae19)


### 5. What was the difference between the longest and shortest delivery times for all orders?
```sql
SELECT
  MAX(ro.duration) - MIN(ro.duration) AS dev_time_diff
FROM runner_orders2 ro;
```
![image](https://github.com/Jx-jeff/8-Week-SQL-Challenge/assets/131775252/22463a5a-78ee-4d97-a19e-d69532a4a5c2)

### 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
```SQL
WITH x as (
  SELECT DISTINCT
    runner_id,
    order_id,
    (ro.duration/60) as duration_hr,
    (ro.distance) as distance,
    ROW_NUMBER() OVER (PARTITION BY x.runner_id, x.order_id) AS rn
  FROM runner_orders2 ro
  WHERE cancellation is null
            )
SELECT
  x.runner_id,
  x.order_id,
  ROUND(
    AVG(x.distance/x.duration_hr),
    2) AS avg_speed_Kph
FROM x
GROUP BY 1,2;
```
![image](https://github.com/Jx-jeff/8-Week-SQL-Challenge/assets/131775252/67a8602d-7fb6-46f4-85d2-39c92c5b21f8)

Yes as runners get more experienced, the tend to increase in avg speed. And runner 2's 2nd run should be investigated 


### 7. What is the successful delivery percentage for each runner?
```SQL
SELECT
  ro.runner_id,
  ROUND(
    (COUNT(CASE
            WHEN ro.cancellation IS NULL THEN 1 END)
     / count(*))
    * 100) AS percentage_dev_success
FROM runner_orders2 ro
GROUP BY 1;
```

## C. Ingredient Optimisation

### 1. What are the standard ingredients for each pizza?
```SQL
WITH RECURSIVE AB AS(
  SELECT
    pr.pizza_id,
    pr.toppings AS topping,
    REGEXP_SUBSTR(pr.toppings,'[0-9]+', 1, 1) AS ingredient,
    1 AS pos
  FROM pizza_runner.pizza_recipes pr 
UNION ALL
  SELECT
    AB.pizza_id,
    AB.topping,
    REGEXP_SUBSTR(AB.topping,'[0-9]+', 1, AB.pos + 1),
    AB.pos +1
  FROM AB
  WHERE REGEXP_SUBSTR(AB.topping,'[0-9]+', 1, AB.pos + 1) is not null
	)
-- This table extracts and liststhe individual topping ids from the the toppings column in the pizza_recipes table
SELECT
  pn.pizza_name,
  group_concat(' ', pt.topping_name) AS ingredients
FROM AB
LEFT JOIN pizza_toppings pt
  ON pt.topping_id = ingredient
JOIN pizza_names pn
  ON pn.pizza_id = ab.pizza_id
GROUP BY 1
-- Macthes the listed topping values to the topping name in tha pizza_topping table then aggregates it into one row for each pizza type;
```
 ![image](https://github.com/Jx-jeff/8-Week-SQL-Challenge/assets/131775252/c086508c-614c-4b36-83fd-6b421fe8af60)

### 2. What was the most commonly added extra?
```SQL
SELECT
  ex.extra_name,
  COUNT(ex.extra) as number_ordered
FROM extras ex
WHERE ex.extra_name IS NOT NULL
GROUP BY 1
```
![image](https://github.com/Jx-jeff/8-Week-SQL-Challenge/assets/131775252/e751fb9c-efa7-46d5-9d86-5dcf0f789906)

Bacon is the most common extra

### 3. What was the most common exclusion?
```SQL
SELECT
  exc.exclusion_name,
  COUNT(exc.excluded) as number_excluded
FROM exclusions exc
WHERE exc.exclusion_name IS NOT NULL
GROUP BY 1;
```
![image](https://github.com/Jx-jeff/8-Week-SQL-Challenge/assets/131775252/17b3315a-a29a-47d1-a9d9-dc1052ed037d)

Cheese is the most common exclusion


### 4. Generate an order item for each record in the customers_orders table in the format of one of the following:
Meat Lovers
Meat Lovers - Exclude Beef
Meat Lovers - Extra Bacon
Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
```sql
WITH orders_inc_names AS (
  SELECT
    co.order_id,
    co.new_id,
    pn.pizza_name,
    CASE
      WHEN GROUP_CONCAT( DISTINCT ex.extra_name) IS NOT NULL
        THEN CONCAT_WS(': ','Extra', GROUP_CONCAT( distinct ex.extra_name))
        ELSE null END AS extra,
    CASE
      WHEN GROUP_CONCAT( DISTINCT ec.exclusion_name) IS NOT NULL
        THEN CONCAT_WS(': ','Exclude', GROUP_CONCAT( DISTINCT ec.exclusion_name))
        ELSE null END AS exclude
  FROM customer_orders2 co
  JOIN extras ex
    ON co.new_id = ex.new_id
  JOIN exclusions ec
    ON co.new_id = ec.new_id
  JOIN pizza_names pn
    ON pn.pizza_id = co.pizza_id
  GROUP BY 1,2,3
                      )
SELECT
  CONCAT_WS(' - ', oic.pizza_name, extra, exclude) AS Order_details
FROM orders_inc_names oic;
```
![image](https://github.com/Jx-jeff/8-Week-SQL-Challenge/assets/131775252/4bfe9892-b2be-4a58-868b-924bacf9838b)

### 5.Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"

COMING SOON!

## Pricing and Ratings

### 1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
```SQL
SELECT
  SUM(CASE
        WHEN co.pizza_id = 1
        THEN 12 ELSE 10 END
        ) as revenue
FROM customer_orders2 co
LEFT JOIN runner_orders2 ro
  ON ro.order_id = co.order_id
WHERE ro.cancellation IS NULL;
```
![image](https://github.com/Jx-jeff/8-Week-SQL-Challenge/assets/131775252/e7d81e83-e85e-44f3-8ff0-7f4f6bf6a4ab)

### 2. What if there was an additional $1 charge for any pizza extras?
Add cheese is $1 extra
```SQL
WITH rev_sum AS( 
	SELECT 
		1 as total,
        SUM(CASE 
				WHEN co.pizza_id = 1 THEN 12 
                ELSE 10 END
			) as revenue
	FROM customer_orders2 co
	LEFT JOIN runner_orders2 ro 
		ON ro.order_id = co.order_id
	WHERE ro.cancellation IS NULL
    GROUP BY 1
		)
-- Calculates Total Revenue,
rev_extra AS(
	SELECT
			1 AS total,    
			SUM( CASE
					WHEN ex.extra IS NOT NULL THEN 1
					END) AS extra_revenue
	FROM customer_orders2 co
	LEFT JOIN extras ex
		ON ex.new_id = co.new_id
	LEFT JOIN runner_orders2 ro 
		ON ro.order_id = co.order_id
	WHERE ro.cancellation IS NULL
	GROUP BY 1
)
-- Calculates Revenue from extras
    
SELECT revenue + rv.extra_revenue as total_rev
FROM rev_extra rv 
JOIN rev_sum rs
	ON rs.total = rv.total
-- Sums all revenues
;
```
![image](https://github.com/Jx-jeff/8-Week-SQL-Challenge/assets/131775252/afe9dcbd-5347-423c-9842-e67c9b421aed)

