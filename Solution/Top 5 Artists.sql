WITH top_10 AS (
  SELECT songs.artist_id,
  COUNT(global_song_rank.song_id) AS times
  FROM global_song_rank
  JOIN songs ON songs.song_id = global_song_rank.song_id
  WHERE rank <= 10
  GROUP BY songs.artist_id),
  
ranking_table AS (
  SELECT *, DENSE_RANK() OVER(ORDER BY times DESC) AS artist_rank
  FROM top_10)
  
SELECT artists.artist_name, ranking_table.artist_rank
FROM ranking_table
JOIN artists ON artists.artist_id = ranking_table.artist_id
WHERE artist_rank <= 5
ORDER BY artist_rank ASC, artist_name ASC
;
