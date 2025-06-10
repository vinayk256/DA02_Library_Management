/*Trend & Time-Series Analysis
6.	How many books were issued each month over the past year?
(Use issued_date, extract month/year and group.)
7.	Which day of the week sees the highest book issues?
(Use TO_CHAR(issued_date, 'Day') and aggregate.)
8.	Identify members who registered in the last 6 months but have not issued any books.
(Use members and left join with issued_status.)
*/

--6. How many books were issued each month over the past year?
/*SELECT
	TO_CHAR(i.issued_date, 'Month') AS month,
	COUNT(b.isbn)
FROM books b
INNER JOIN issued_status i ON i.issued_book_isbn = b.isbn
--WHERE i.issued_date >= CURRENT_DATE - INTERVAL '12 months'
GROUP BY month
*/

--7. Which day of the week sees the highest book issues?
/*SELECT
	TO_CHAR(issued_date, 'Day') AS weekday,
	COUNT(issued_id) AS count_dow
FROM issued_status
GROUP BY weekday
*/

--8. Identify members who registered in the last 6 months but have not issued any books.
/*SELECT
	m.member_id,
	m.member_name,
	m.reg_date
FROM members m
LEFT JOIN issued_status i ON m.member_id = i.issued_member_id
WHERE m.reg_date < CURRENT_DATE - INTERVAL '6 months' 
	AND i.issued_member_id IS NULL
*/