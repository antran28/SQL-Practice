# 🥑 Case Study #3: Foodie-Fi

<img src="https://user-images.githubusercontent.com/81607668/129742132-8e13c136-adf2-49c4-9866-dec6be0d30f0.png" width="500" height="520" alt="image">

## 📚 Table of Contents
- [Business Task](#business-task)
- [Entity Relationship Diagram](#entity-relationship-diagram)
- [Question and Solution](#question-and-solution)

Please note that all the information regarding the case study has been sourced from the following link: [here](https://8weeksqlchallenge.com/case-study-3/). 

***

## Business Task
Danny and his friends launched a new startup Foodie-Fi and started selling monthly and annual subscriptions, giving their customers unlimited on-demand access to exclusive food videos from around the world.

This case study focuses on using subscription style digital data to answer important business questions on customer journey, payments, and business performances.

## Entity Relationship Diagram

![image](https://user-images.githubusercontent.com/81607668/129744449-37b3229b-80b2-4cce-b8e0-707d7f48dcec.png)

**Table 1: `plans`**

<img width="207" alt="image" src="https://user-images.githubusercontent.com/81607668/135704535-a82fdd2f-036a-443b-b1da-984178166f95.png">

There are 5 customer plans.

- Trial — Customer sign up to an initial 7 day free trial and will automatically continue with the pro monthly subscription plan unless they cancel, downgrade to basic or upgrade to an annual pro plan at any point during the trial.
- Basic plan — Customers have limited access and can only stream their videos and is only available monthly at $9.90.
- Pro plan — Customers have no watch time limits and are able to download videos for offline viewing. Pro plans start at $19.90 a month or $199 for an annual subscription.

When customers cancel their Foodie-Fi service — they will have a Churn plan record with a null price, but their plan will continue until the end of the billing period.

**Table 2: `subscriptions`**

<img width="245" alt="image" src="https://user-images.githubusercontent.com/81607668/135704564-30250dd9-6381-490a-82cf-d15e6290cf3a.png">

Customer subscriptions show the **exact date** where their specific `plan_id` starts.

If customers downgrade from a pro plan or cancel their subscription — the higher plan will remain in place until the period is over — the `start_date` in the subscriptions table will reflect the date that the actual plan changes.

When customers upgrade their account from a basic plan to a pro or annual pro plan — the higher plan will take effect straightaway.

When customers churn, they will keep their access until the end of their current billing period, but the start_date will be technically the day they decided to cancel their service.

***
## Question and Solution

**1. How many customers has Foodie-Fi ever had?**
```sql
    SELECT COUNT(DISTINCT customer_id)
    	AS unique_customers
    FROM foodie_fi.subscriptions;
```
| unique_customers |
| ---------------- |
| 1000             |

---
**2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value**
```sql
    SELECT 
    	COUNT(foodie_fi.subscriptions.customer_id) AS total_sub,
    	DATE_PART('month', foodie_fi.subscriptions.start_date) AS start_of_month
    FROM foodie_fi.plans
    JOIN foodie_fi.subscriptions
    	ON foodie_fi.plans.plan_id = foodie_fi.subscriptions.plan_id
    WHERE foodie_fi.plans.plan_name = 'trial'
    GROUP BY start_of_month, foodie_fi.plans.plan_name
    ORDER BY start_of_month ASC;
```
| total_sub | start_of_month |
| --------- | -------------- |
| 88        | 1              |
| 68        | 2              |
| 94        | 3              |
| 81        | 4              |
| 88        | 5              |
| 79        | 6              |
| 89        | 7              |
| 88        | 8              |
| 87        | 9              |
| 79        | 10             |
| 75        | 11             |
| 84        | 12             |

---
**3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name**
```sql
    SELECT
    	foodie_fi.plans.plan_name,
    	COUNT(foodie_fi.subscriptions.customer_id) AS total_sub,
    	EXTRACT(YEAR FROM foodie_fi.subscriptions.start_date) AS year
    FROM foodie_fi.plans
    JOIN foodie_fi.subscriptions
    	ON foodie_fi.plans.plan_id = foodie_fi.subscriptions.plan_id
    GROUP BY foodie_fi.plans.plan_name, year
    HAVING EXTRACT(YEAR FROM foodie_fi.subscriptions.start_date) >2020
    ORDER BY total_sub;
```
| plan_name     | total_sub | year |
| ------------- | --------- | ---- |
| basic monthly | 8         | 2021 |
| pro monthly   | 60        | 2021 |
| pro annual    | 63        | 2021 |
| churn         | 71        | 2021 |

---
**4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?**
```sql
    SELECT
        COUNT(DISTINCT CASE WHEN p.plan_name = 'churn' THEN s.customer_id END) AS total_churn,
        ROUND(
            (COUNT(DISTINCT CASE WHEN p.plan_name = 'churn' THEN s.customer_id END) * 100.0) /
            COUNT(DISTINCT s.customer_id),
            1
        ) AS churn_percentage
    FROM foodie_fi.plans AS p
    JOIN foodie_fi.subscriptions AS s ON p.plan_id = s.plan_id;
```
| total_churn | churn_percentage |
| ----------- | ---------------- |
| 307         | 30.7             |

---
**5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?**
```sql
    WITH end_trial AS(
    	SELECT
    		p.plan_name,
      		s.customer_id,
    		CASE
            	WHEN p.plan_name = 'trial' THEN s.start_date + INTERVAL '7 days'
            	ELSE s.start_date
        	END AS end_trial_date
        FROM foodie_fi.plans AS p
    	JOIN foodie_fi.subscriptions AS s ON p.plan_id = s.plan_id
    	WHERE p.plan_name = 'trial'),
    	
    start_churn AS(
    	SELECT
    		p.plan_name,
    		s.customer_id,
        	s.start_date AS start_churn_date
        FROM foodie_fi.plans AS p
    	JOIN foodie_fi.subscriptions AS s ON p.plan_id = s.plan_id
    	WHERE p.plan_name = 'churn')
    
    SELECT
    	COUNT(DISTINCT c.customer_id) AS total_churn,
    	ROUND(100.0*
    		COUNT(DISTINCT c.customer_id)/(SELECT COUNT(DISTINCT foodie_fi.subscriptions.customer_id) FROM foodie_fi.subscriptions),1) AS churn_percent
    FROM end_trial AS e
    JOIN start_churn AS c
    ON c.customer_id = e.customer_id
    WHERE e.end_trial_date=c.start_churn_date;
```
| total_churn | churn_percent |
| ----------- | ------------- |
| 92          | 9.2           |

---
**6. What is the number and percentage of customer plans after their initial free trial?**
```sql
    SELECT 
    	p.plan_name,
    	COUNT(DISTINCT s.customer_id) AS total_customer,
    	ROUND(100.0*
    		COUNT(DISTINCT s.customer_id)/(SELECT COUNT(DISTINCT foodie_fi.subscriptions.customer_id) FROM foodie_fi.subscriptions),1) AS customer_percent
    FROM foodie_fi.plans AS p
    JOIN foodie_fi.subscriptions AS s ON p.plan_id = s.plan_id
    WHERE NOT p.plan_name='trial'
    GROUP BY p.plan_name;
```
| plan_name     | total_customer | customer_percent |
| ------------- | -------------- | ---------------- |
| basic monthly | 546            | 54.6             |
| churn         | 307            | 30.7             |
| pro annual    | 258            | 25.8             |
| pro monthly   | 539            | 53.9             |

---
**7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?**
```sql
    WITH date_table AS(
    SELECT
        customer_id,
        plan_id,
        start_date,
        LEAD(start_date) OVER (
          PARTITION BY customer_id
          ORDER BY start_date
        ) AS next_date
    FROM foodie_fi.subscriptions
    WHERE start_date <= '2020-12-31')
    
    SELECT
    	p.plan_name,
    	COUNT(DISTINCT c.customer_id) AS total_customer,
    	ROUND(100.0*
    		COUNT(DISTINCT c.customer_id)/(SELECT COUNT(DISTINCT foodie_fi.subscriptions.customer_id) FROM foodie_fi.subscriptions),1) AS customer_percent
    FROM date_table AS c
    JOIN foodie_fi.plans AS p
    	ON c.plan_id = p.plan_id
    WHERE next_date IS NULL 
    GROUP BY p.plan_name;
```
| plan_name     | total_customer | customer_percent |
| ------------- | -------------- | ---------------- |
| basic monthly | 224            | 22.4             |
| churn         | 236            | 23.6             |
| pro annual    | 195            | 19.5             |
| pro monthly   | 326            | 32.6             |
| trial         | 19             | 1.9              |

---
**8. How many customers have upgraded to an annual plan in 2020?**
```sql
    SELECT
    	COUNT(DISTINCT s.customer_id) AS total_customer
    FROM foodie_fi.plans AS p
    JOIN foodie_fi.subscriptions AS s 
    	ON p.plan_id = s.plan_id
    WHERE EXTRACT(YEAR FROM s.start_date)=2020 AND p.plan_name='pro annual';
```
| total_customer |
| -------------- |
| 195            |

---
**9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?**
```sql
    WITH annual_date AS(
    	SELECT
    		s.customer_id,
    		s.plan_id,
    		s.start_date AS annual_start_date
    	FROM foodie_fi.subscriptions AS s
    	WHERE s.plan_id=3)
    
    SELECT ROUND(AVG(a.annual_start_date - s.start_date),1) AS date_diff
    FROM annual_date AS a
    JOIN foodie_fi.subscriptions AS s
    ON a.customer_id=s.customer_id
    WHERE s.plan_id=0;
```
| date_diff |
| --------- |
| 104.6     |

---
**10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)**
```sql
    WITH customer_upgrades AS (
        SELECT (annual_start_date - s_basic.start_date) AS date_diff
        FROM (
            SELECT
                s.customer_id,
                s.start_date AS annual_start_date
            FROM foodie_fi.subscriptions AS s
            WHERE s.plan_id = 3
        ) AS s
        JOIN foodie_fi.subscriptions AS s_basic ON s.customer_id = s_basic.customer_id
        WHERE s_basic.plan_id = 0
    )
    SELECT
        CONCAT(
            CASE
                WHEN date_diff >= 0 THEN (date_diff / 30)::int * 30
                ELSE (date_diff / 30 - 1)::int * 30
            END,
            '-',
            CASE
                WHEN date_diff >= 0 THEN (date_diff / 30 + 1)::int * 30
                ELSE (date_diff / 30)::int * 30
            END
        ) AS period,
        ROUND(AVG(date_diff),1) AS average_days
    FROM customer_upgrades
    GROUP BY period
    ORDER BY period;
```
| period  | average_days |
| ------- | ------------ |
| 0-30    | 9.5          |
| 120-150 | 133.0        |
| 150-180 | 161.5        |
| 180-210 | 190.3        |
| 210-240 | 224.3        |
| 240-270 | 257.2        |
| 270-300 | 285.0        |
| 30-60   | 41.8         |
| 300-330 | 327.0        |
| 330-360 | 346.0        |
| 60-90   | 70.9         |
| 90-120  | 99.8         |

---
**11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?**
```sql
    WITH downgrade_customer AS(
    SELECT
    	s.plan_id,
    	s.customer_id,
    	LEAD(s.plan_id) OVER (
          PARTITION BY customer_id
          ORDER BY start_date
        ) AS next_plan
    FROM foodie_fi.subscriptions AS s
    WHERE DATE_PART('year', s.start_date) = 2020)
    
    SELECT COUNT(DISTINCT d.customer_id) AS total
    FROM downgrade_customer AS d
    WHERE d.plan_id=2 AND d.next_plan=1;
```
| total |
| ----- |
| 0     |

---

[View on DB Fiddle](https://www.db-fiddle.com/f/rHJhRrXy5hbVBNJ6F6b9gJ/16)
