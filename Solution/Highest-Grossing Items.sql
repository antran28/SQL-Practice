WITH filter_table AS (
  SELECT category, product,
  SUM(spend) as total_spend
  FROM product_spend
  WHERE EXTRACT(YEAR FROM transaction_date) = 2022
  GROUP BY category, product),

rank_table AS (
  SELECT *,
  ROW_NUMBER() OVER (PARTITION BY category ORDER BY total_spend DESC) AS row_num
  FROM filter_table)

SELECT category, product, total_spend
FROM rank_table
WHERE row_num <= 2;
