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

---

[View on DB Fiddle](https://www.db-fiddle.com/f/7VcQKQwsS3CTkGRFG7vu98/65)
