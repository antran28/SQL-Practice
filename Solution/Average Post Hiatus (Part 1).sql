WITH user_table AS(
  SELECT user_id AS repeat_user FROM posts 
  GROUP BY user_id
  HAVING COUNT(user_id)>1
  ),

main_table AS(
  SELECT user_id, MAX(post_date) as max_date, MIN(post_date) as min_date FROM posts
  INNER JOIN user_table
  ON repeat_user = user_id
  GROUP BY user_id
  )

SELECT main_table.user_id,
  DATE_PART('day', main_table.max_date - main_table.min_date) AS days_between
  FROM main_table
  WHERE EXTRACT(YEAR FROM max_date) = 2021
  ORDER BY main_table.user_id ASC;
