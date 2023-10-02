WITH main_table AS(
  SELECT * FROM emails
  JOIN texts
  ON emails.email_id = texts.email_id
  WHEre signup_action = 'Confirmed')
  
SELECT user_id FROM main_table
WHERE EXTRACT(DAY FROM AGE(action_date, signup_date)) = 1;
