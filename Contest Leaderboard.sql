SELECT max_scores.hacker_id, Hackers.name, SUM(max_scores.max_score) AS total_score
FROM (
    SELECT hacker_id, challenge_id, MAX(score) AS max_score
    FROM Submissions
    GROUP BY hacker_id, challenge_id
) AS max_scores
JOIN Hackers
    ON max_scores.hacker_id = Hackers.hacker_id
GROUP BY max_scores.hacker_id, Hackers.name
HAVING SUM(max_scores.max_score) > 0
ORDER BY total_score DESC, max_scores.hacker_id ASC;
