WITH impression_table AS(
  SELECT app_id AS id1, COUNT(event_type) AS no_impression
  FROM events
  WHERE event_type = 'impression' AND EXTRACT(YEAR FROM timestamp) = 2022
  GROUP BY id1),
  
click_table AS(
  SELECT app_id as id2, COUNT(event_type) AS no_click
  FROM events
  WHERE event_type = 'click' AND EXTRACT(YEAR FROM timestamp) = 2022
  GROUP BY id2)
  
SELECT id1 as app_id, ROUND(100.0*no_click/no_impression,2) AS ctr
FROM impression_table
JOIN click_table
ON id1 = id2;
