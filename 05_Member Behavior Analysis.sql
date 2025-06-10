/*Member Behavior Analysis
14.	Top 5 members who borrow the most expensive books on average.
(Join issued_status → books, then compute average rental_price per member.)
15.	What percentage of books are borrowed by the top 10% of members (Pareto analysis)?
*/

--14. Top 5 members who borrow the most expensive books on average.
/*SELECT
	m.member_id,
	m.member_name,
	COUNT(i.issued_id) AS num_borrowed,
	ROUND(AVG(b.rental_price), 2) AS avg_rental
FROM members m
INNER JOIN issued_status i ON m.member_id = i.issued_member_id
INNER JOIN books b ON i.issued_book_isbn = b.isbn
GROUP BY m.member_id, m.member_name
ORDER BY avg_rental DESC
LIMIT 5
*/

--15. What percentage of books are borrowed by the top 10% of members (Pareto analysis)?
WITH member_borrow_count AS(
		SELECT
			issued_member_id,
			COUNT(issued_id) AS issued_count
		FROM issued_status
		GROUP BY issued_member_id
		ORDER BY issued_count DESC
		),
	top_10per AS(
		SELECT
			*
		FROM member_borrow_count
		LIMIT CEIL((SELECT 
						COUNT(issued_count) * 0.20 
					FROM member_borrow_count))
		),
	total_issued AS(
  		SELECT COUNT(issued_id) AS total_books_issued 
		FROM issued_status
		),
	top_issued AS (
  		SELECT SUM(issued_count) AS top_books_issued 
		FROM top_10per
		)
SELECT
	ROUND((top_books_issued::decimal / total_books_issued) * 100, 2) AS percent_borrowed_by_top_10_percent
FROM top_issued, total_issued;