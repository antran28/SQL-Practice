SELECT c.company_code,
             founder, 
             count(distinct l_m.lead_manager_code) as lead_manager_count,
             count(distinct s_m.senior_manager_code) as senior_manager_count,
             count(distinct m.manager_code) as manager_count,
             count(distinct e.employee_code) as employee_count
FROM Company c
INNER JOIN Lead_Manager l_m ON c.company_code = l_m.company_code
INNER JOIN Senior_Manager s_m ON l_m.company_code = s_m.company_code
INNER JOIN Manager m ON s_m.company_code = m.company_code
INNER JOIN Employee e ON m.company_code = e.company_code
GROUP BY c.company_code,c.founder
ORDER BY c.company_code;
