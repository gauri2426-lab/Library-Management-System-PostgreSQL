# 📚 Library Management System

**Level:** Intermediate  
**Database:** `library_db`  

This project demonstrates the development of a **Library Management System** using SQL. It covers database design, data population, CRUD operations, CTAS queries, stored procedures, and advanced SQL queries for reporting and analysis.

---

## 🔍 Project Overview

The system is built to manage library operations such as handling books, members, employees, branches, issuing and returning books, and generating insights from the data. The project is intended to showcase your expertise in SQL and relational database design.

---

## 🎯 Objectives

- **Database Setup:** Design and create tables for branches, employees, members, books, issue and return status.
- **CRUD Operations:** Implement insert, update, delete, and read functionalities.
- **CTAS Usage:** Create summary and report tables from query results.
- **Advanced SQL:** Execute complex queries, stored procedures, and data analysis tasks.

---

## 📂 Project Structure

### 1. Database Setup

- **Database:** `library_db`
- **Tables Created:**  
  - `branch`, `employees`, `members`, `books`, `issued_status`, `return_status`

```sql
CREATE DATABASE library_db;

-- Sample: Creating `branch` table
CREATE TABLE branch (
  branch_id VARCHAR(10) PRIMARY KEY,
  manager_id VARCHAR(10),
  branch_address VARCHAR(30),
  contact_no VARCHAR(15)
);
```

*Refer to `database_setup.png` for complete table structures.*

---

### 2. CRUD Operations

Basic operations performed on tables:

- **Insert a Book:**
```sql
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
```

- **Update Member Address:**
```sql
UPDATE members SET member_address = '125 Oak St' WHERE member_id = 'C103';
```

- **Delete Issued Record:**
```sql
DELETE FROM issued_status WHERE issued_id = 'IS121';
```

- **Read Data (Books issued by Employee `E101`):**
```sql
SELECT * FROM issued_status WHERE issued_emp_id = 'E101';
```

---

### 3. CTAS (Create Table As Select)

- **Books Issue Summary:**
```sql
CREATE TABLE book_issued_cnt AS
SELECT b.isbn, b.book_title, COUNT(ist.issued_id) AS issue_count
FROM issued_status ist
JOIN books b ON ist.issued_book_isbn = b.isbn
GROUP BY b.isbn, b.book_title;
```

---

### 4. 🔍 Data Analysis & Reporting

- **Books in a Category:**
```sql
SELECT * FROM books WHERE category = 'Classic';
```

- **Rental Income by Category:**
```sql
SELECT b.category, SUM(b.rental_price), COUNT(*)
FROM issued_status ist
JOIN books b ON b.isbn = ist.issued_book_isbn
GROUP BY 1;
```

- **Recent Members (180 days):**
```sql
SELECT * FROM members WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';
```

- **Employees with Branch Details & Managers:**
```sql
SELECT e1.emp_id, e1.emp_name, e1.position, e1.salary, b.*, e2.emp_name as manager
FROM employees e1
JOIN branch b ON e1.branch_id = b.branch_id
JOIN employees e2 ON e2.emp_id = b.manager_id;
```

- **Expensive Books:**
```sql
CREATE TABLE expensive_books AS
SELECT * FROM books WHERE rental_price > 7.00;
```

- **Books Not Yet Returned:**
```sql
SELECT * FROM issued_status ist
LEFT JOIN return_status rs ON rs.issued_id = ist.issued_id
WHERE rs.return_id IS NULL;
```

---

### 5. 🧠 Advanced Operations

- **Overdue Books:**
```sql
SELECT ist.issued_member_id, m.member_name, bk.book_title, ist.issued_date,
CURRENT_DATE - ist.issued_date as over_dues_days
FROM issued_status ist
JOIN members m ON m.member_id = ist.issued_member_id
JOIN books bk ON bk.isbn = ist.issued_book_isbn
LEFT JOIN return_status rs ON rs.issued_id = ist.issued_id
WHERE rs.return_date IS NULL AND (CURRENT_DATE - ist.issued_date) > 30;
```

- **Procedure to Return Book & Update Status:**
```sql
CALL add_return_records('RS138', 'IS135', 'Good');
```

- **Branch Performance Report:**
```sql
CREATE TABLE branch_reports AS
SELECT b.branch_id, b.manager_id,
COUNT(ist.issued_id) AS number_book_issued,
COUNT(rs.return_id) AS number_of_book_return,
SUM(bk.rental_price) AS total_revenue
FROM issued_status ist
JOIN employees e ON e.emp_id = ist.issued_emp_id
JOIN branch b ON e.branch_id = b.branch_id
LEFT JOIN return_status rs ON rs.issued_id = ist.issued_id
JOIN books bk ON ist.issued_book_isbn = bk.isbn
GROUP BY 1, 2;
```

- **Active Members in Last 2 Months:**
```sql
CREATE TABLE active_members AS
SELECT * FROM members
WHERE member_id IN (
  SELECT DISTINCT issued_member_id FROM issued_status
  WHERE issued_date >= CURRENT_DATE - INTERVAL '2 month'
);
```

- **Top 3 Employees with Most Issues:**
```sql
SELECT e.emp_name, b.*, COUNT(ist.issued_id) as no_book_issued
FROM issued_status ist
JOIN employees e ON e.emp_id = ist.issued_emp_id
JOIN branch b ON e.branch_id = b.branch_id
GROUP BY 1, 2
ORDER BY 3 DESC
LIMIT 3;
```

---

### 6. 📦 Stored Procedures

- **`issue_book`**: Issues a book if available (`status = 'yes'`), else shows a message.
- **`add_return_records`**: Adds return data and sets book status to "yes".

---

## 📈 Reports & Insights

- Book categories and rental insights.
- Overdue tracking and fine calculations.
- Branch and employee performance analytics.
- CTAS usage for reporting active users and popular books.

---

## 📌 Conclusion

This SQL-based project provides a comprehensive understanding of relational database design and manipulation. From schema creation to stored procedures and reporting, it’s a strong showcase of hands-on database development skills.

---

Let me know if you also want this README exported as a file or styled for a GitHub page!
