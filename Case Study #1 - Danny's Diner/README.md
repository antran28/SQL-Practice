# 🍜 Case Study #1: Danny's Diner 
<img src="https://user-images.githubusercontent.com/81607668/127727503-9d9e7a25-93cb-4f95-8bd0-20b87cb4b459.png" alt="Image" width="500" height="520">

## 📚 Table of Contents
- [Business Task](#business-task)
- [Entity Relationship Diagram](#entity-relationship-diagram)
- [Question and Solution](#question-and-solution)

Please note that all the information regarding the case study has been sourced from the following link: [here](https://8weeksqlchallenge.com/case-study-1/). 

***

## Business Task
Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. 

***

## Entity Relationship Diagram

![image](https://user-images.githubusercontent.com/81607668/127271130-dca9aedd-4ca9-4ed8-b6ec-1e1920dca4a8.png)

***

**Schema (PostgreSQL v13)**
````sql
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
````
---

**Query #1: What is the total amount each customer spent at the restaurant?**
````sql
    SELECT
      	dannys_diner.sales.customer_id,
        SUM(dannys_diner.menu.price) as total_spent
    FROM dannys_diner.sales 
    INNER JOIN dannys_diner.menu 
        ON dannys_diner.sales.product_id = dannys_diner.menu.product_id
    GROUP BY dannys_diner.sales.customer_id
    ORDER BY dannys_diner.sales.customer_id ASC;
````
#### Answer:
| customer_id | total_spent |
| ----------- | ----------- |
| A           | 76          |
| B           | 74          |
| C           | 36          |

---

**Query #2: How many days has each customer visited the restaurant?**

````sql
SELECT
  	dannys_diner.sales.customer_id, 
	COUNT( DISTINCT dannys_diner.sales.order_date) AS days_visited
FROM dannys_diner.sales
GROUP BY dannys_diner.sales.customer_id
ORDER BY dannys_diner.sales.customer_id ASC; 
````
#### Answer:
| customer_id | visit_count |
| ----------- | ----------- |
| A           | 4          |
| B           | 6          |
| C           | 2          |

---

**Query #3: What was the first item from the menu purchased by each customer?**

````sql
WITH RankedPurchases AS (
	SELECT
  		dannys_diner.sales.customer_id, 
		dannys_diner.menu.product_name,
		dannys_diner.sales.order_date,
    	DENSE_RANK() OVER (PARTITION BY dannys_diner.sales.customer_id ORDER BY dannys_diner.sales.order_date) AS purchase_rank
	FROM dannys_diner.sales
	INNER JOIN dannys_diner.menu
	ON dannys_diner.sales.product_id = dannys_diner.menu.product_id
)
SELECT
  customer_id,
  product_name AS first_purchase
FROM RankedPurchases
WHERE purchase_rank = 1
GROUP BY customer_id, first_purchase;
````
#### Answer:
| customer_id | product_name | 
| ----------- | ----------- |
| A           | curry        | 
| A           | sushi        | 
| B           | curry        | 
| C           | ramen        |

---

**Query #4: What is the most purchased item on the menu and how many times was it purchased by all customers?**

````sql
SELECT 
  menu.product_name,
  COUNT(sales.product_id) AS most_purchased_item
FROM dannys_diner.sales
INNER JOIN dannys_diner.menu
  ON sales.product_id = menu.product_id
GROUP BY menu.product_name
ORDER BY most_purchased_item DESC
LIMIT 1;
````
#### Answer:
| most_purchased | product_name | 
| ----------- | ----------- |
| 8       | ramen |

---

**Query #5: What is the most purchased item on the menu and how many times was it purchased by all customers?**
````sql
WITH RepeatPurchases AS (
	SELECT
  		dannys_diner.sales.customer_id, 
		dannys_diner.menu.product_name,
		COUNT (dannys_diner.sales.product_id) AS times_purchased,
  		RANK() OVER(
				PARTITION BY dannys_diner.sales.customer_id 
				ORDER BY COUNT (dannys_diner.sales.product_id) DESC)
		AS ranking
	FROM dannys_diner.sales
	INNER JOIN dannys_diner.menu
	ON dannys_diner.sales.product_id = dannys_diner.menu.product_id
  	GROUP BY dannys_diner.sales.customer_id, dannys_diner.menu.product_name
)
SELECT customer_id, product_name AS most_fav_dish
FROM RepeatPurchases
WHERE ranking =1;
````
#### Answer:
| customer_id | most_fav_dish |
| ----------- | ------------- |
| A           | ramen         |
| B           | ramen         |
| B           | curry         |
| B           | sushi         |
| C           | ramen         |

---
**Query #6: Which item was purchased first by the customer after they became a member?**
````sql
WITH SaleHistory AS (
	SELECT
  		dannys_diner.sales.customer_id, 
		dannys_diner.sales.order_date,
		dannys_diner.menu.product_name,
		dannys_diner.members.join_date
	FROM dannys_diner.sales
		INNER JOIN dannys_diner.members
		ON dannys_diner.sales.customer_id = dannys_diner.members.customer_id
  		INNER JOIN dannys_diner.menu 
        ON dannys_diner.sales.product_id = dannys_diner.menu.product_id
	WHERE dannys_diner.sales.order_date > dannys_diner.members.join_date
)
SELECT DISTINCT ON (customer_id) customer_id, product_name
FROM SaleHistory
ORDER BY customer_id ASC;
````
#### In this query:
- We create a CTE (SaleHistory) that joins the members, sales, and menu tables based on the customer_id and product_id. We also filter for purchases that occurred after the customer's membership start date.
- Within the CTE, we use the ORDER BY clause to order the results by customer_id and purchase_date. This helps us identify the first purchase after becoming a member for each customer.
- In the main query, we use DISTINCT ON (customer_id) to select only the first row for each customer, ensuring that we get only the first purchase after becoming a member.
This query will give you the first item purchased by each customer after they became a member.
#### Answer:
| customer_id | product_name |
| ----------- | ------------ |
| A           | ramen        |
| B           | sushi        |

---
**Query #7: Which item was purchased just before the customer became a member?**
````sql
WITH SaleHistory AS (
	SELECT
  		dannys_diner.sales.customer_id, 
		dannys_diner.sales.order_date,
		dannys_diner.menu.product_name,
		dannys_diner.members.join_date
	FROM dannys_diner.sales
		INNER JOIN dannys_diner.members
		ON dannys_diner.sales.customer_id = dannys_diner.members.customer_id
  		INNER JOIN dannys_diner.menu 
        ON dannys_diner.sales.product_id = dannys_diner.menu.product_id
	WHERE dannys_diner.sales.order_date < dannys_diner.members.join_date
)
SELECT DISTINCT ON (customer_id) customer_id, product_name
FROM SaleHistory
ORDER BY customer_id ASC;
````

#### Answer:
| customer_id | product_name |
| ----------- | ------------ |
| A           | sushi        |
| B           | sushi        |

---
**Query #8: What is the total items and amount spent for each member before they became a member?**
````sql
SELECT
  	dannys_diner.sales.customer_id, 
	COUNT(dannys_diner.sales.product_id) AS total_items,
	SUM(dannys_diner.menu.price) AS total_spent
FROM dannys_diner.sales
	INNER JOIN dannys_diner.members
	ON dannys_diner.sales.customer_id = dannys_diner.members.customer_id
  	INNER JOIN dannys_diner.menu 
        ON dannys_diner.sales.product_id = dannys_diner.menu.product_id
WHERE dannys_diner.sales.order_date < dannys_diner.members.join_date
GROUP BY dannys_diner.sales.customer_id
ORDER BY dannys_diner.sales.customer_id ASC;
````

#### Answer:
| customer_id | total_items | total_sales |
| ----------- | ---------- |----------  |
| A           | 2 |  25       |
| B           | 3 |  40       |

---
**Query #9: If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?**
````sql
SELECT
  	dannys_diner.sales.customer_id, 
	SUM(
		CASE 
			WHEN dannys_diner.menu.product_name = 'sushi'
			THEN 20 * dannys_diner.menu.price
			ELSE 10 * dannys_diner.menu.price
		END
		) AS total_points
FROM dannys_diner.sales
  	INNER JOIN dannys_diner.menu 
       ON dannys_diner.sales.product_id = dannys_diner.menu.product_id
GROUP BY dannys_diner.sales.customer_id
ORDER BY dannys_diner.sales.customer_id ASC;
````

#### Answer:
| customer_id | total_points | 
| ----------- | ---------- |
| A           | 860 |
| B           | 940 |
| C           | 360 |

---
**Query #10: In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?**
````sql

````

#### Answer:


---

[View on DB Fiddle](https://www.db-fiddle.com/f/2rM8RAnq7h5LLDTzZiRWcd/138)
