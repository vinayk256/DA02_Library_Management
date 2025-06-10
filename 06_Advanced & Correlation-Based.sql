/*Advanced & Correlation-Based
16.	Does the position of the employee (e.g., 'Librarian', 'Clerk') influence the number of books issued?
(Join issued_status → employees, group by position.)
17.	Find the correlation between the number of books a member issues and their return delays.
(Compute for each member: count of books issued, and avg delay in return.)
*/

--16. Does the position of the employee (e.g., 'Librarian', 'Clerk') influence the number of books issued?
/*SELECT
	e.position,
	COUNT(i.issued_id) AS total_books_issued
FROM issued_status i
INNER JOIN employees e ON i.issued_emp_id = e.emp_id
GROUP BY e.position
ORDER BY total_books_issued DESC
*/

--17. Find the correlation between the number of books a member issues and their return delays.
WITH member_data AS(
		SELECT
			i.issued_member_id,
			COUNT(i.issued_member_id) AS x_issued,
			ROUND(AVG((r.return_date - i.issued_date) - 50), 2) AS y_delay
		FROM issued_status i 
		INNER JOIN return_status r ON i.issued_id = r.issued_id
		INNER JOIN members m ON i.issued_member_id = m.member_id
		GROUP BY i.issued_member_id
		HAVING COUNT(issued_member_id) > 3
		),
	stats AS (
		SELECT
			COUNT(*) AS n,
		    SUM(x_issued) AS sum_x,
		    SUM(y_delay) AS sum_y,
		    SUM(x_issued * y_delay) AS sum_xy,
		    SUM(x_issued * x_issued) AS sum_x2,
		    SUM(y_delay * y_delay) AS sum_y2
		  FROM member_data
		)
SELECT
  ROUND(
    (n * sum_xy - (sum_x * sum_y)) / 
    SQRT(((n * sum_x2) - (sum_x * sum_x)) * ((n * sum_y2) - (sum_y * sum_y))),
  4) AS correlation
FROM stats;