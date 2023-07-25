WITH count_challenges AS (
    SELECT Challenges.hacker_id, COUNT(Challenges.challenge_id) AS total_challenges
    FROM Challenges
    GROUP BY Challenges.hacker_id
    ),
    
meet_requirement AS(
    SELECT total_challenges, COUNT(total_challenges)
    FROM count_challenges
    GROUP BY count_challenges.total_challenges
    HAVING COUNT(total_challenges) = 1
    OR (total_challenges) = (SELECT MAX(total_challenges) FROM count_challenges)
    )

SELECT count_challenges.hacker_id, Hackers.name, meet_requirement.total_challenges
FROM count_challenges
JOIN meet_requirement
    ON count_challenges.total_challenges = meet_requirement.total_challenges
JOIN Hackers
    ON Hackers.hacker_id = count_challenges.hacker_id
    ORDER BY meet_requirement.total_challenges DESC,
             count_challenges.hacker_id ASC;
