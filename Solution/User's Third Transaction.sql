WITH order_table AS(
  SELECT *,
  ROW_NUMBER() OVER (
  PARTITION BY user_id ORDER BY transaction_date) AS sequence
  FROM transactions)
  
SELECT user_id, spend, transaction_date
FROM order_table
WHERE sequence=3;
