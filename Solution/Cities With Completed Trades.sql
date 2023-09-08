WITH orders AS(
SELECT user_id, order_id FROM trades
WHERE status = 'Completed'
GROUP BY user_id, order_id
)

SELECT users.city, COUNT(orders.order_id) AS total_orders
FROM users
INNER JOIN orders
ON orders.user_id = users.user_id
GROUP BY city
ORDER BY total_orders DESC
LIMIT 3;
