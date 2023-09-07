WITH python_skill AS (
  SELECT candidate_id AS python_id
  FROM candidates
  WHERE skill = 'Python'
  ),

tableau_skill AS (
  SELECT candidate_id AS tableau_id
  FROM candidates
  WHERE skill = 'Tableau'
  ),
  
sql_skill AS (
  SELECT candidate_id AS sql_id
  FROM candidates
  WHERE skill = 'PostgreSQL'
  )
  
SELECT sql_id
  FROM sql_skill
  INNER JOIN python_skill ON sql_id = python_id
  INNER JOIN tableau_skill ON sql_id = tableau_id
;
