WITH time_table AS ( 
SELECT user_id,
  SUM(time_spent) FILTER (WHERE activity_type = 'open') AS opening_time,
  SUM(time_spent) FILTER (WHERE activity_type = 'send') AS sending_time
FROM activities
GROUP BY user_id)

SELECT age_bucket,
  ROUND(sending_time/(sending_time+opening_time)*100.0,2) AS send_perc,
  ROUND(opening_time/(sending_time+opening_time)*100.0,2) AS open_perc
FROM age_breakdown 
JOIN time_table
ON time_table.user_id = age_breakdown.user_id
ORDER BY age_bucket;
