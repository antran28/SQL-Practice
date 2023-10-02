WITH main AS (SELECT manufacturer, drug, total_sales-cogs AS total_losses 
FROM pharmacy_sales)

SELECT manufacturer, COUNT(manufacturer) AS drug_count, ABS(SUM(total_losses)) AS total_losses FROM main
WHERE total_losses < 0
GROUP BY manufacturer
ORDER BY total_losses DESC;
