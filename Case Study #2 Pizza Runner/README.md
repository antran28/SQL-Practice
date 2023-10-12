# 🍕 Case Study #2 Pizza Runner

<img src="https://user-images.githubusercontent.com/81607668/127271856-3c0d5b4a-baab-472c-9e24-3c1e3c3359b2.png" alt="Image" width="500" height="520">

## 📚 Table of Contents
- [Business Task](#business-task)
- [Entity Relationship Diagram](#entity-relationship-diagram)
- Solution
  - [Data Cleaning and Transformation](#-data-cleaning--transformation)
  - [A. Pizza Metrics](#a-pizza-metrics)
  - [B. Runner and Customer Experience](#b-runner-and-customer-experience)
  - [C. Ingredient Optimisation](#c-ingredient-optimisation)
  - [D. Pricing and Ratings](#d-pricing-and-ratings)

## Business Task
Danny is expanding his new Pizza Empire and at the same time, he wants to Uberize it, so Pizza Runner was launched!

Danny started by recruiting “runners” to deliver fresh pizza from Pizza Runner Headquarters (otherwise known as Danny’s house) and also maxed out his credit card to pay freelance developers to build a mobile app to accept orders from customers. 

## Entity Relationship Diagram

![Pizza Runner](https://github.com/katiehuangx/8-Week-SQL-Challenge/assets/81607668/78099a4e-4d0e-421f-a560-b72e4321f530)

## 🧼 Data Cleaning & Transformation

### 🔨 Table: customer_orders
**```customer_orders```**
- Converting ```null``` and ```NaN``` values into blanks ```''``` in ```exclusions``` and ```extras```
  - Blanks indicate that the customer requested no extras/exclusions for the pizza, whereas ```null``` values would be ambiguous.
- Saving the transformations in a temporary table ```customer_orders_temp```
  - We want to avoid permanently changing the raw data via ```UPDATE``` commands if possible.

```sql
      CREATE TEMP TABLE
      	customer_orders_temp AS
      	SELECT
      		order_id,
      		customer_id,
      		pizza_id,
      		CASE
      			WHEN exclusions IS NULL or exclusions LIKE 'null' THEN ''
      			ELSE exclusions
      			END AS exclusions,
      		CASE
      			WHEN extras IS NULL or extras LIKE 'null' THEN ''
      			ELSE extras
      			END AS extras,
      		order_time
      	FROM pizza_runner.customer_orders;
  # Check the new temporary table
      SELECT
      	*
      FROM
      	customer_orders_temp;
```
| order_id | customer_id | pizza_id | exclusions | extras | order_time               |
| -------- | ----------- | -------- | ---------- | ------ | ------------------------ |
| 1        | 101         | 1        |            |        | 2020-01-01T18:05:02.000Z |
| 2        | 101         | 1        |            |        | 2020-01-01T19:00:52.000Z |
| 3        | 102         | 1        |            |        | 2020-01-02T23:51:23.000Z |
| 3        | 102         | 2        |            |        | 2020-01-02T23:51:23.000Z |
| 4        | 103         | 1        | 4          |        | 2020-01-04T13:23:46.000Z |
| 4        | 103         | 1        | 4          |        | 2020-01-04T13:23:46.000Z |
| 4        | 103         | 2        | 4          |        | 2020-01-04T13:23:46.000Z |
| 5        | 104         | 1        |            | 1      | 2020-01-08T21:00:29.000Z |
| 6        | 101         | 2        |            |        | 2020-01-08T21:03:13.000Z |
| 7        | 105         | 2        |            | 1      | 2020-01-08T21:20:29.000Z |
| 8        | 102         | 1        |            |        | 2020-01-09T23:54:33.000Z |
| 9        | 103         | 1        | 4          | 1, 5   | 2020-01-10T11:22:59.000Z |
| 10       | 104         | 1        |            |        | 2020-01-11T18:34:49.000Z |
| 10       | 104         | 1        | 2, 6       | 1, 4   | 2020-01-11T18:34:49.000Z |


### 🔨 Table: runner_orders
**```runner_orders```**

- Converting ```'null'``` text values into null values for ```pickup_time```, ```distance``` and ```duration```
- Extracting only numbers and decimal spaces for the distance and duration columns
  - Use regular expressions and ```NULLIF``` to convert non-numeric entries to null values
- Converting blanks, ```'null'``` and ```NaN``` into null values for cancellation
- Saving the transformations in a temporary table ```runner_orders_temp```
```sql
  CREATE TEMP TABLE
      	runner_orders_temp AS
      SELECT
      	order_id,
          runner_id,
          CASE
          	WHEN pickup_time LIKE 'null' THEN NULL
              ELSE pickup_time
              END::timestamp AS pickup_time,
      	CASE
            WHEN distance = 'null' THEN NULL
            ELSE (
              SELECT NULLIF(regexp_replace(distance, '[^0-9.]','','g'), '')::numeric)
            END AS distance,
      	CASE
          	WHEN duration LIKE 'null' THEN NULL
              ELSE (
                SELECT NULLIF(regexp_replace(duration, '[^0-9.]','','g'), '')::numeric)
              END AS duration,
      	CASE
          	WHEN cancellation LIKE 'null' or cancellation LIKE '' THEN NULL
              ELSE cancellation
              END AS cancellation                  
      FROM pizza_runner.runner_orders;
  # Check the new temporary table  
      SELECT
      	*
      FROM
      	runner_orders_temp;
```
| order_id | runner_id | pickup_time              | distance | duration | cancellation            |
| -------- | --------- | ------------------------ | -------- | -------- | ----------------------- |
| 1        | 1         | 2020-01-01T18:15:34.000Z | 20       | 32       |                         |
| 2        | 1         | 2020-01-01T19:10:54.000Z | 20       | 27       |                         |
| 3        | 1         | 2020-01-03T00:12:37.000Z | 13.4     | 20       |                         |
| 4        | 2         | 2020-01-04T13:53:03.000Z | 23.4     | 40       |                         |
| 5        | 3         | 2020-01-08T21:10:57.000Z | 10       | 15       |                         |
| 6        | 3         |                          |          |          | Restaurant Cancellation |
| 7        | 2         | 2020-01-08T21:30:45.000Z | 25       | 25       |                         |
| 8        | 2         | 2020-01-10T00:15:02.000Z | 23.4     | 15       |                         |
| 9        | 2         |                          |          |          | Customer Cancellation   |
| 10       | 1         | 2020-01-11T18:50:20.000Z | 10       | 10       |                         |

***

## Solution

## A. Pizza Metrics

**How many pizzas were ordered?**
```sql
    SELECT
    	COUNT(*) AS pizza_order_count
    FROM customer_orders_temp;
```
| pizza_order_count |
| ----------------- |
| 14                |

---
**How many unique customer orders were made?**
```sql
    SELECT COUNT(DISTINCT order_id) AS unique_order_count
    FROM customer_orders_temp;
```
| unique_order_count |
| ------------------ |
| 10                 |

---
**How many successful orders were delivered by each runner?**
```sql
    SELECT 
      runner_id, 
      COUNT(order_id) AS successful_orders
    FROM runner_orders_temp
    WHERE pickup_time IS NOT NULL
    GROUP BY runner_id
    ORDER BY runner_id ASC;
```
| runner_id | successful_orders |
| --------- | ----------------- |
| 1         | 4                 |
| 2         | 3                 |
| 3         | 1                 |

---
**How many of each type of pizza was delivered?**
```sql
    SELECT 
    	customer_orders_temp.pizza_id AS pizza_type, 
    	pizza_runner.pizza_names.pizza_name,
    	COUNT(runner_orders_temp.order_id) AS delivered_pizza
    FROM customer_orders_temp
    	INNER JOIN runner_orders_temp
    	ON customer_orders_temp.order_id = runner_orders_temp.order_id
    	INNER JOIN pizza_runner.pizza_names
    	ON customer_orders_temp.pizza_id = pizza_runner.pizza_names.pizza_id
    WHERE pickup_time IS NOT NULL
    GROUP BY pizza_type, pizza_runner.pizza_names.pizza_name
    ORDER BY pizza_type ASC;
```
| pizza_type | pizza_name | delivered_pizza |
| ---------- | ---------- | --------------- |
| 1          | Meatlovers | 9               |
| 2          | Vegetarian | 3               |

---
**How many Vegetarian and Meatlovers were ordered by each customer?**
```sql
    SELECT  
        customer_orders_temp.customer_id,
        pizza_runner.pizza_names.pizza_name,
    	COUNT(customer_orders_temp.pizza_id) AS ordered_pizza
    FROM customer_orders_temp
    	INNER JOIN pizza_runner.pizza_names
    	ON customer_orders_temp.pizza_id = pizza_runner.pizza_names.pizza_id
    GROUP BY pizza_runner.pizza_names.pizza_name, customer_orders_temp.customer_id
    ORDER BY customer_orders_temp.customer_id ASC;
```
| customer_id | pizza_name | ordered_pizza |
| ----------- | ---------- | ------------- |
| 101         | Meatlovers | 2             |
| 101         | Vegetarian | 1             |
| 102         | Meatlovers | 2             |
| 102         | Vegetarian | 1             |
| 103         | Meatlovers | 3             |
| 103         | Vegetarian | 1             |
| 104         | Meatlovers | 3             |
| 105         | Vegetarian | 1             |

---
**What was the maximum number of pizzas delivered in a single order?**
```sql
    WITH pizza_per_order AS(
    	SELECT
    		customer_orders_temp.order_id, 
    		COUNT(customer_orders_temp.pizza_id) AS ordered_pizza
    	FROM customer_orders_temp
    		INNER JOIN runner_orders_temp
    	ON customer_orders_temp.order_id = runner_orders_temp.order_id
    	WHERE runner_orders_temp.pickup_time IS NOT NULL
    	GROUP BY customer_orders_temp.order_id
    	ORDER BY customer_orders_temp.order_id ASC)
    
    SELECT
    	MAX(ordered_pizza) AS max_pizza_per_ordered
    FROM
    	pizza_per_order;
```
| max_pizza_per_ordered |
| --------------------- |
| 3                     |

---
**For each customer, how many delivered pizzas had at least 1 change and how many had no changes?**
```sql
    SELECT
    	customer_orders_temp.customer_id,
    	SUM(
    		CASE WHEN customer_orders_temp.exclusions <> '' OR customer_orders_temp.extras <> '' THEN 1
          	ELSE 0
          	END) AS at_least_1_change,
    	SUM(
    		CASE WHEN customer_orders_temp.exclusions = '' OR customer_orders_temp.extras = '' THEN 1
          	ELSE 0
          	END) AS no_change
    FROM
    	customer_orders_temp
    INNER JOIN
    	runner_orders_temp ON customer_orders_temp.order_id = runner_orders_temp.order_id
    WHERE runner_orders_temp.pickup_time IS NOT NULL
    GROUP BY customer_orders_temp.customer_id
    ORDER BY customer_orders_temp.customer_id;
```
| customer_id | at_least_1_change | no_change |
| ----------- | ----------------- | --------- |
| 101         | 0                 | 2         |
| 102         | 0                 | 3         |
| 103         | 3                 | 3         |
| 104         | 2                 | 2         |
| 105         | 1                 | 1         |

---
**How many pizzas were delivered that had both exclusions and extras?**
```sql
    SELECT
    	COUNT(customer_orders_temp.order_id) AS delivered_special
    FROM
    	customer_orders_temp
    INNER JOIN
    	runner_orders_temp ON customer_orders_temp.order_id = runner_orders_temp.order_id
    WHERE 
    	runner_orders_temp.pickup_time IS NOT NULL
    	AND
    	(customer_orders_temp.exclusions <> '' AND customer_orders_temp.extras <> '');
```
| delivered_special |
| ----------------- |
| 1                 |

---
**What was the total volume of pizzas ordered for each hour of the day?**
```sql
    SELECT
    	EXTRACT(HOUR FROM order_time) AS hour,
        COUNT(order_id) AS total_orders
    FROM customer_orders_temp
    GROUP BY hour
    ORDER BY hour ASC;
```
| hour | total_orders |
| ---- | ------------ |
| 11   | 1            |
| 13   | 3            |
| 18   | 3            |
| 19   | 1            |
| 21   | 3            |
| 23   | 3            |

---
**What was the volume of orders for each day of the week?**
```sql
    SELECT
    	TO_CHAR(order_time, 'Day') AS day_of_week,
    	COUNT(order_id) AS total_orders
    FROM customer_orders_temp
    GROUP BY day_of_week
    ORDER BY day_of_week ASC;
```
| day_of_week | total_orders |
| ----------- | ------------ |
| Friday      | 1            |
| Saturday    | 5            |
| Thursday    | 3            |
| Wednesday   | 5            |

---


[View on DB Fiddle](https://www.db-fiddle.com/f/7VcQKQwsS3CTkGRFG7vu98/65)
