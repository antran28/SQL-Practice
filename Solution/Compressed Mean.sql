WITH calculation_table AS(
  SELECT SUM(order_occurrences) AS total_order,
  SUM(order_occurrences*item_count::DECIMAL) AS total_items 
  FROM items_per_order)

SELECT ROUND(total_items/total_order,1) AS mean FROM calculation_table;
