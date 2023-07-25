SELECT N,
    CASE
        WHEN N IN (SELECT P FROM BST)  AND P IN (SELECT N FROM BST) THEN 'Inner'
        WHEN P IS NULL THEN 'Root'
        ELSE 'Leaf'
    END AS node_type
FROM BST
    ORDER BY N ASC;
