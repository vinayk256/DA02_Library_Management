/*Cost & Revenue Calculations
12.	What is the total revenue generated from book rentals per category?
(Use books.rental_price and count of issued_status per category.)
13.	Which branch contributes the most in terms of book rentals?
(Join employees → branch and issued_status.)
*/

--12. What is the total revenue generated from book rentals per category?
/*SELECT
	b.category,
	ROUND(SUM(rental_price), 2) AS total_rental_price
FROM books b
INNER JOIN issued_status i ON b.isbn = i.issued_book_isbn
GROUP BY b.category*/

--13. Which branch contributes the most in terms of book rentals?
SELECT
	b.branch_id,
	SUM(k.rental_price) AS branch_revenue
FROM branch b
INNER JOIN employees e ON b.branch_id = e.branch_id
INNER JOIN issued_status i ON e.emp_id = i.issued_emp_id
INNER JOIN books k ON i.issued_book_isbn = k.isbn
GROUP BY b.branch_id
ORDER BY branch_revenue DESC