/*Usage & Operations Analysis
1.	Which book has been issued the most number of times?
(Use issued_status and group by issued_book_name or issued_book_isbn.)
2.	Which members have not returned all the books they issued?
(Compare issued_status and return_status using issued_id or isbn.)
3.	Which employee has issued the highest number of books?
(Aggregate on issued_emp_id from issued_status.)
4.	What is the average rental price of books by category?
(Use the books table and aggregate on category.)
5.	What is the average duration of book returns by category or author?
(Join issued_status and return_status, calculate date difference.)
*/

--1. Which book has been issued the most number of times?
/*SELECT
	issued_book_name,
	issued_book_isbn,
	COUNT(issued_book_isbn) AS count_issued
FROM issued_status
GROUP BY issued_book_name, issued_book_isbn
ORDER BY count_issued DESC
LIMIT 5
*/

--2. Which members have not returned all the books they issued?
/*select
	m.member_id,
	m.member_name,
	COUNT(i.issued_id) AS issued,
	COUNT(r.return_id) AS returned,
	(COUNT(i.issued_id) - COUNT(r.return_id)) AS not_ruturned
FROM members m
INNER JOIN issued_status i ON m.member_id = i.issued_member_id
LEFT JOIN return_status r ON i.issued_id = r.return_id
GROUP BY m.member_id, m.member_name
*/

--3. Which employee has issued the highest number of books?
/*SELECT
	i.issued_emp_id,
	e.emp_name,
	COUNT(i.issued_emp_id) AS issued_count
FROM issued_status i
INNER JOIN employees e
ON i.issued_emp_id = e.emp_id
GROUP BY i.issued_emp_id, e.emp_name
ORDER BY issued_count DESC
LIMIT 5
*/

--4. What is the average rental price of books by category?
/*SELECT
	category,
	ROUND(AVG(rental_price), 2) AS avg_rental_price
FROM books
GROUP BY category
*/

--5. What is the average duration of book returns by category or author?
/*SELECT
	b.category,
	ROUND(AVG(r.return_date - i.issued_date), 2) as avg_issued_date
FROM return_status r
INNER JOIN issued_status i ON i.issued_id = r.issued_id
INNER JOIN books b ON i.issued_book_isbn = b.isbn
GROUP BY b.category

SELECT
	b.author,
	ROUND(AVG(r.return_date - i.issued_date), 2) as avg_issued_date
FROM return_status r
INNER JOIN issued_status i ON i.issued_id = r.issued_id
INNER JOIN books b ON i.issued_book_isbn = b.isbn
GROUP BY b.author
*/