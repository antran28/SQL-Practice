WITH max_card AS(
  SELECT card_name, MAX(issued_amount) AS max_amt, MIN(issued_amount) AS min_amt
  FROM monthly_cards_issued
  GROUP BY card_name)

SELECT card_name, max_amt-min_amt AS difference FROM max_card
ORDER BY difference DESC;
