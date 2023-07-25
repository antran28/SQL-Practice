SELECT 
    IF (Grades.Grade>=8, Students.Name, NULL) AS Names,
    Grades.Grade,
    Students.Marks AS Mark
FROM Students
INNER JOIN Grades
    ON Students.Marks BETWEEN Grades.Min_Mark AND Grades.Max_Mark
    ORDER BY
        Grades.Grade DESC,
        Names ASC,
        Mark ASC;
