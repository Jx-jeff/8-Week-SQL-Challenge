## Cleaning Runner Orders Table

1. Create a new Runner orders table for cleaning 
``` SQL
DROP TABLE IF EXISTS runner_orders2;
CREATE TABLE runner_orders2 (
      order_id int,
      runner_id int,
      pickup_time varchar(19),
      distance varchar(7),
      duration varchar(10),
      cancellation varchar(23));

INSERT INTO runner_orders2
SELECT *
FROM runner_orders;
```

<br/>

2. Trimming Non numerical characters from Distance and Duration columns
```SQL
UPDATE runner_orders2
      SET distance = REGEXP_SUBSTR( distance,'[0-9]+(\.[0-9]+)?'),
          duration = REGEXP_SUBSTR( duration,'[0-9]+(\.[0-9]+)?');
```


3. Handling null values and blanks

``` SQL                
UPDATE runner_orders2
      SET duration = CASE
                        WHEN duration = 'null' or duration =' '
                         THEN NULL ELSE duration END,
          distance = CASE
                        WHEN distance = 'null' or distance =' '
                         THEN NULL ELSE distance END,
	      pickup_time = CASE
                        WHEN pickup_time = 'null' or pickup_time =' '
                         THEN NULL ELSE pickup_time END,
	      cancellation = CASE
                        WHEN cancellation = 'null' or cancellation =' ' or cancellation = ''
                          THEN NULL else cancellation end;
```

4. Correcting columnn types
```SQL
ALTER table runner_orders2
      MODIFY COLUMN order_id int,
      MODIFY COLUMN runner_id int,
      MODIFY COLUMN distance Float(2),
      MODIFY COLUMN duration Int ,
      MODIFY COLUMN pickup_time Timestamp,
      MODIFY COLUMN  cancellation Varchar(500) ;             
```
***Result***

![image](https://github.com/Jx-jeff/8-Week-SQL-Challenge/assets/131775252/5a5aaf67-3510-4418-b4d7-fc99756064dc)



## Cleaning Customer Orders table

1.. Creating a new customer orders table for cleaning 
``` SQL
DROP TABLE IF EXISTS customer_orders2;
CREATE TABLE customer_orders2 (
      order_id INT ,
      new_id INT,
      customer_id INT,
      pizza_id INT ,
      exclusions VARCHAR(50) ,
      extras VARCHAR(50) ,
      order_time TIMESTAMP
) ;

INSERT INTO customer_orders2
SELECT
      order_id,
      row_number() OVER(),
      customer_id,
      pizza_id,
      exclusions,
      extras,
      order_time
FROM customer_orders;
```

Please note: A new id has been assigned to every transaction since, there is no unique key to differentiate them.
It could ba argued that some of these transactions are duplicates but i believe otherwise since its possible to buy the same pizza twice.
The new key will help reduce duplicates from joins i will be doing subsequently especially in for Section C

2. Handling null values and blanks
```SQL                
UPDATE customer_orders2
      SET exclusions = CASE
                        WHEN exclusions = 'null' OR exclusions =''
                          THEN NULL ELSE exclusions END,
          extras = CASE
                      WHEN extras = 'null' or extras =''
                          THEN NULL ELSE extras END;
```

3. Correcting Column types
``` SQL
ALTER TABLE customer_orders2
      MODIFY COLUMN order_id INT,
      MODIFY COLUMN customer_id INT,
      MODIFY COLUMN pizza_id INT,
      MODIFY COLUMN exclusions VARCHAR (50),
      MODIFY COLUMN extras VARCHAR (50),
      MODIFY COLUMN order_time TIMESTAMP;
```
***Result***

![image](https://github.com/Jx-jeff/8-Week-SQL-Challenge/assets/131775252/4e27bb50-ef3e-489b-b845-f985048cb235)


## Creating Temporary Tables for extracting and listing extras, Exclusions and ingredients

1. Pizza ingredients 

Create Temporay table 
```SQL
/* create and populate a temporary table for seperated toppings in each pizza ordered*/
DROP TEMPORARY TABLE topping;
CREATE TEMPORARY TABLE topping(
	pizza_id int,
	topping varchar (50),
	toppings int,
	topping_name varchar (50)
);

INSERT INTO topping
WITH RECURSIVE CD AS (
      SELECT
              pr.pizza_id,
              pr.toppings as topping,
              REGEXP_SUBSTR(pr.toppings,'[0-9]+',1,1) as toppings,
              1 as pos
      FROM pizza_runner.pizza_recipes pr 
UNION ALL
      SELECT
              CD.pizza_id,
              CD.topping,
              REGEXP_SUBSTR(CD.topping,'[0-9]+', 1, CD.pos + 1),
              CD.pos +1
      FROM CD
      WHERE  REGEXP_SUBSTR(CD.topping,'[0-9]+', 1, CD.pos + 1) is not null
)

-- The above Recursive CTE extracts the numbers in the pizza toppings column from the pizza recipes table

SELECT 
	CD.pizza_id,
	CD.topping,
	CD.toppings,
	pt.topping_name 
FROM CD
JOIN pizza_toppings pt
	ON CD.Toppings = pt.topping_id;
-- This joins the results from the CTE with the pizza_toppings table to get the names of each ingrediets
-- And then inserts it into the temporary table topping.
```
***Result***

![image](https://github.com/Jx-jeff/8-Week-SQL-Challenge/assets/131775252/41a72f4d-e9fc-4dea-ae3b-431be6d37ee1)


2. Extras

   Create a Temporary Table for extras
```SQL
CREATE TEMPORARY TABLE extras(
      pizza_id int,
      order_id int,
      new_id INT,
      extras varchar (50),
      extra int,
      extra_name varchar (50)
);

INSERT INTO extras
WITH RECURSIVE BC AS(
      SELECT
              co.pizza_id,
              co.extras,
              co.new_id,
              co.order_id,
              REGEXP_SUBSTR(co.extras,'[0-9]+',1,1) as extra,
              1 as pos
      FROM pizza_runner.customer_orders2 co 
UNION ALL
      SELECT
              BC.pizza_id,
              BC.extras,
              BC.new_id,
              BC.order_id,
              REGEXP_SUBSTR(BC.extras,'[0-9]+', 1, BC.pos + 1),
              BC.pos +1
      FROM BC
      WHERE  REGEXP_SUBSTR(BC.extras,'[0-9]+', 1,BC.pos + 1) IS NOT NULL
)

-- The above Recursive CTE extracts the numbers in the extras column from the customer orders table

SELECT
      BC.pizza_id,
      BC.order_id,
      BC.new_id,
      BC.extras,
      BC.extra,
      pt.topping_name as extra_name 
FROM BC
JOIN pizza_toppings pt
      ON extra = pt.topping_id
;

-- This joins the results from the CTE with the pizza_toppings table to get the names of each ingrediets
-- And then inserts it into the temporary table extras.

```
***Result***

![image](https://github.com/Jx-jeff/8-Week-SQL-Challenge/assets/131775252/cbba4a8c-7b43-4d34-a75d-a420d1349c5c)

3. Exclusions
Create a Temporary Table for extras
``` SQL
CREATE TEMPORARY TABLE exclusions(
      pizza_id int,
      order_id int,
      new_id INT,
      exclusions varchar (20),
      excluded int,
      exclusion_name varchar (50)
    );

INSERT INTO  exclusions
WITH RECURSIVE ab AS (
      SELECT
              co.pizza_id,
              co.new_id,
              co.exclusions AS exclusions,
              co.order_id,
              REGEXP_SUBSTR(co.exclusions,'[0-9]+',1,1) AS excluded,
              1 AS pos
      FROM pizza_runner.customer_orders2 co
UNION ALL
      SELECT
              ab.pizza_id,
              ab.new_id,
              ab.exclusions,
              ab.order_id,
              REGEXP_SUBSTR(ab.exclusions,'[0-9]+', 1, ab.pos + 1),
              ab.pos +1
      FROM ab
      WHERE  REGEXP_SUBSTR(exclusions,'[0-9]+',1,pos + 1) IS NOT NULL
)

---- The above Recursive CTE extracts the numbers in the pizza Exclusion column from the customer orders table

SELECT
      ab.pizza_id,
      ab.order_id,
      ab.new_id,
      ab.exclusions,
      ab.excluded,
      pt.topping_name
FROM ab
JOIN pizza_toppings pt
      ON excluded = pt.topping_id;

-- This joins the results from the CTE with the pizza_toppings table to get the names of each ingrediets
-- And then inserts it into the temporary table exclusions.
```
***Result***

![image](https://github.com/Jx-jeff/8-Week-SQL-Challenge/assets/131775252/ccb5ef42-3686-479a-b3fa-923e4ac553a4)





