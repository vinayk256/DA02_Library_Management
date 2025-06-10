# DA02_Library_Management

## Project Overview

**Project Title**: Library Management System  
**Database**: `db_library`

This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying to answer advanced analytical business questions.

## Objectives

1. **Understand Book and Category Usage Trends** Analyze which books, authors, and categories are most or least popular to guide inventory, acquisitions, and space planning.
2. **Track Member Behavior and Borrowing Patterns** Identify active readers, late returners, and high-value users to improve engagement, loyalty, and enforce policies when needed.
3. **Evaluate Staff and Branch Performance** Measure how employee roles and branch locations influence book circulation to optimize staffing and branch operations.
4. **Monitor Financial and Operational Efficiency** Calculate revenue from rentals, and evaluate overdue or unreturned books to ensure financial health and operational integrity.
5. **Gain Insights from Behavioral Correlations and Trends** Use data-driven insights (like issue-delay correlation, Pareto analysis) to predict patterns and support strategic decisions.

- **Database Creation**: Created a database named 'db_library'.
- **Table Creation**: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.

## Project Structure

### 1. Database Setup
```sql
CREATE DATABASE library_db;

DROP TABLE IF EXISTS branch;
CREATE TABLE branch
(
            branch_id VARCHAR(10) PRIMARY KEY,
            manager_id VARCHAR(10),
            branch_address VARCHAR(30),
            contact_no VARCHAR(15)
);

-- Create table "Employee"
DROP TABLE IF EXISTS employees;
CREATE TABLE employees
(
            emp_id VARCHAR(10) PRIMARY KEY,
            emp_name VARCHAR(30),
            position VARCHAR(30),
            salary DECIMAL(10,2),
            branch_id VARCHAR(10),
            FOREIGN KEY (branch_id) REFERENCES  branch(branch_id)
);

-- Create table "Members"
DROP TABLE IF EXISTS members;
CREATE TABLE members
(
            member_id VARCHAR(10) PRIMARY KEY,
            member_name VARCHAR(30),
            member_address VARCHAR(30),
            reg_date DATE
);

-- Create table "Books"
DROP TABLE IF EXISTS books;
CREATE TABLE books
(
            isbn VARCHAR(50) PRIMARY KEY,
            book_title VARCHAR(80),
            category VARCHAR(30),
            rental_price DECIMAL(10,2),
            status VARCHAR(10),
            author VARCHAR(30),
            publisher VARCHAR(30)
);

-- Create table "IssueStatus"
DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status
(
            issued_id VARCHAR(10) PRIMARY KEY,
            issued_member_id VARCHAR(30),
            issued_book_name VARCHAR(80),
            issued_date DATE,
            issued_book_isbn VARCHAR(50),
            issued_emp_id VARCHAR(10),
            FOREIGN KEY (issued_member_id) REFERENCES members(member_id),
            FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id),
            FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn) 
);

-- Create table "ReturnStatus"
DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status
(
            return_id VARCHAR(10) PRIMARY KEY,
            issued_id VARCHAR(30),
            return_book_name VARCHAR(80),
            return_date DATE,
            return_book_isbn VARCHAR(50),
            FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
```

### 2. Data Analysis & Findings
**Usage & Operations Analysis**

1.	Which book has been issued the most number of times?
<br> (Use issued_status and group by issued_book_name or issued_book_isbn.)

2.	Which members have not returned all the books they issued?
<br>(Compare issued_status and return_status using issued_id or isbn.)

3.	Which employee has issued the highest number of books?
<br> (Aggregate on issued_emp_id from issued_status.)

4.	What is the average rental price of books by category?
<br> (Use the books table and aggregate on category.)

5.	What is the average duration of book returns by category or author?
<br> (Join issued_status and return_status, calculate date difference.)

Data Analysis
<br>--1. Which book has been issued the most number of times?
```sql
SELECT
	issued_book_name,
	issued_book_isbn,
	COUNT(issued_book_isbn) AS count_issued
FROM issued_status
GROUP BY issued_book_name, issued_book_isbn
ORDER BY count_issued DESC
LIMIT 5
```

--2. Which members have not returned all the books they issued?
```sql
select
	m.member_id,
	m.member_name,
	COUNT(i.issued_id) AS issued,
	COUNT(r.return_id) AS returned,
	(COUNT(i.issued_id) - COUNT(r.return_id)) AS not_ruturned
FROM members m
INNER JOIN issued_status i ON m.member_id = i.issued_member_id
LEFT JOIN return_status r ON i.issued_id = r.return_id
GROUP BY m.member_id, m.member_name
```

--3. Which employee has issued the highest number of books?
```sql
SELECT
	i.issued_emp_id,
	e.emp_name,
	COUNT(i.issued_emp_id) AS issued_count
FROM issued_status i
INNER JOIN employees e
ON i.issued_emp_id = e.emp_id
GROUP BY i.issued_emp_id, e.emp_name
ORDER BY issued_count DESC
LIMIT 5
```

--4. What is the average rental price of books by category?
```sql
SELECT
	category,
	ROUND(AVG(rental_price), 2) AS avg_rental_price
FROM books
GROUP BY category
```

--5. What is the average duration of book returns by category or author?
```sql
SELECT
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
```

**Trend & Time-Series Analysis**

6.	How many books were issued each month over the past year?
<br> (Use issued_date, extract month/year and group.)

7.	Which day of the week sees the highest book issues?
<br>(Use TO_CHAR(issued_date, 'Day') and aggregate.)

8.	Identify members who registered in the last 6 months but have not issued any books.
<br>(Use members and left join with issued_status.)

Data Analysis
<br>--6. How many books were issued each month over the past year?
```sql
SELECT
	TO_CHAR(i.issued_date, 'Month') AS month,
	COUNT(b.isbn)
FROM books b
INNER JOIN issued_status i ON i.issued_book_isbn = b.isbn
--WHERE i.issued_date >= CURRENT_DATE - INTERVAL '12 months'
GROUP BY month
```

--7. Which day of the week sees the highest book issues?
```sql
SELECT
	TO_CHAR(issued_date, 'Day') AS weekday,
	COUNT(issued_id) AS count_dow
FROM issued_status
GROUP BY weekday
```

--8. Identify members who registered in the last 6 months but have not issued any books.
```sql
SELECT
	m.member_id,
	m.member_name,
	m.reg_date
FROM members m
LEFT JOIN issued_status i ON m.member_id = i.issued_member_id
WHERE m.reg_date < CURRENT_DATE - INTERVAL '6 months' 
	AND i.issued_member_id IS NULL
```

**Return & Delay Insights**

9.	Which books are most often returned late (based on average delay)?
<br>(Join issued_status and return_status, compute delay.)

10.	How many issued books are still not returned?
<br>(Find issued_ids not present in return_status.)

11.	List of members with frequent late returns (e.g., more than 3 times).

Data Analysis
<br>--9. Which books are most often returned late (based on average delay)?
```sql
SELECT
	b.isbn,
	b.book_title,
	ROUND(AVG(r.return_date - i.issued_date), 2) as avg_loan_duration_days
FROM return_status r
INNER JOIN issued_status i ON i.issued_id = r.issued_id
INNER JOIN books b ON i.issued_book_isbn = b.isbn
GROUP BY b.isbn, b.book_title
ORDER BY avg_loan_duration_days DESC
```

--10. How many issued books are still not returned?
```sql
SELECT
	i.issued_id,
	i.issued_book_isbn,
	b.book_title
FROM issued_status i
LEFT JOIN return_status r ON i.issued_id = r.issued_id
INNER JOIN books b ON i.issued_book_isbn = b.isbn
WHERE r.issued_id IS NULL
```

--11. List of members with frequent late returns (e.g., more than 3 times).
```sql
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
```

**Cost & Revenue Calculations**

12.	What is the total revenue generated from book rentals per category?
<br>(Use books.rental_price and count of issued_status per category.)

13.	Which branch contributes the most in terms of book rentals?
<br>(Join employees â†’ branch and issued_status.)

Data Analysis
<br>--12. What is the total revenue generated from book rentals per category?
```sql
SELECT
	b.category,
	ROUND(SUM(rental_price), 2) AS total_rental_price
FROM books b
INNER JOIN issued_status i ON b.isbn = i.issued_book_isbn
GROUP BY b.category*/
```

--13. Which branch contributes the most in terms of book rentals?
```sql
SELECT
	b.branch_id,
	SUM(k.rental_price) AS branch_revenue
FROM branch b
INNER JOIN employees e ON b.branch_id = e.branch_id
INNER JOIN issued_status i ON e.emp_id = i.issued_emp_id
INNER JOIN books k ON i.issued_book_isbn = k.isbn
GROUP BY b.branch_id
ORDER BY branch_revenue DESC
```

**Member Behavior Analysis**

14.	Top 5 members who borrow the most expensive books on average.
<br>(Join issued_status â†’ books, then compute average rental_price per member.)

15.	What percentage of books are borrowed by the top 10% of members (Pareto analysis)?

Data Analysis
<br>--14. Top 5 members who borrow the most expensive books on average.
```sql
SELECT
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
```

--15. What percentage of books are borrowed by the top 10% of members (Pareto analysis)?
```sql
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
```

**Advanced & Correlation-Based**

16.	Does the position of the employee (e.g., 'Librarian', 'Clerk') influence the number of books issued?
<br>(Join issued_status â†’ employees, group by position.)

17.	Find the correlation between the number of books a member issues and their return delays.
<br>(Compute for each member: count of books issued, and avg delay in return.)

Data Analysis
<br>--16. Does the position of the employee (e.g., 'Librarian', 'Clerk') influence the number of books issued?
```sql
SELECT
	e.position,
	COUNT(i.issued_id) AS total_books_issued
FROM issued_status i
INNER JOIN employees e ON i.issued_emp_id = e.emp_id
GROUP BY e.position
ORDER BY total_books_issued DESC
```

--17. Find the correlation between the number of books a member issues and their return delays.
```sql
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
```
