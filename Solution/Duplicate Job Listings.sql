WITH  duplicate AS(
  SELECT company_id, title, description, COUNT(*) FROM job_listings
  GROUP BY company_id, title, description
  HAVING COUNT(*)>1
)

SELECT COUNT(company_id) AS duplicate_companies FROM duplicate;
