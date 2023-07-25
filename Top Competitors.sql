SELECT H.hacker_id, H.name
FROM Hackers H
JOIN Submissions S ON H.hacker_id = S.hacker_id
JOIN Challenges C ON S.challenge_id = C.challenge_id
JOIN Difficulty D ON C.difficulty_level = D.difficulty_level
WHERE S.score = D.score
GROUP BY H.hacker_id, H.name
HAVING COUNT(DISTINCT C.challenge_id) > 1
ORDER BY COUNT(DISTINCT C.challenge_id) DESC, H.hacker_id ASC;
