WITH total_tweets AS (
  SELECT
  user_id,
  COUNT(tweet_id) AS tweet_bucket
  FROM tweets
  WHERE EXTRACT(YEAR FROM tweet_date)=2022
  GROUP BY user_id
  )

SELECT total_tweets.tweet_bucket,
  COUNT(total_tweets.user_id) AS users_num
  FROM total_tweets
  GROUP BY tweet_bucket;
