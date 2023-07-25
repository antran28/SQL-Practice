SELECT ROUND(LAT_N, 4) AS Median
FROM (
    SELECT @rownum:=@rownum+1 AS rownum, LAT_N
    FROM STATION, (SELECT @rownum:=0) r
    ORDER BY LAT_N
) AS sorted
WHERE rownum = CEIL((SELECT COUNT(*) FROM STATION) / 2);
