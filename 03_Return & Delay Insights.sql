/*Return & Delay Insights
9.	Which books are most often returned late (based on average delay)?
(Join issued_status and return_status, compute delay.)
10.	How many issued books are still not returned?
(Find issued_ids not present in return_status.)
11.	List of members with frequent late returns (e.g., more than 3 times).
*/

--9. Which books are most often returned late (based on average delay)?
/*SELECT
	b.isbn,
	b.book_title,
	ROUND(AVG(r.return_date - i.issued_date), 2) as avg_loan_duration_days
FROM return_status r
INNER JOIN issued_status i ON i.issued_id = r.issued_id
INNER JOIN books b ON i.issued_book_isbn = b.isbn
GROUP BY b.isbn, b.book_title
ORDER BY avg_loan_duration_days DESC
*/

--10. How many issued books are still not returned?
/*SELECT
	i.issued_id,
	i.issued_book_isbn,
	b.book_title
FROM issued_status i
LEFT JOIN return_status r ON i.issued_id = r.issued_id
INNER JOIN books b ON i.issued_book_isbn = b.isbn
WHERE r.issued_id IS NULL
*/

--11. List of members with frequent late returns (e.g., more than 3 times).
SELECT
	i.issued_member_id,
	m.member_name,
	COUNT(issued_member_id)
FROM issued_status i 
INNER JOIN return_status r ON i.issued_id = r.issued_id
INNER JOIN members m ON i.issued_member_id = m.member_id
WHERE (r.return_date - i.issued_date) > 50
GROUP BY i.issued_member_id, m.member_name
HAVING COUNT(issued_member_id) > 3