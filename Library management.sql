-- View All Tables
SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM return_status;
SELECT * FROM members;

-- Task 1: Insert a New Book
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

-- Task 2: Update Member Address
UPDATE members SET member_address = '125 Main St' WHERE member_id = 'C101';

-- Task 3: Delete Issued Record
DELETE FROM issued_status WHERE issued_id = 'IS121';

-- Task 4: Books Issued by Specific Employee
SELECT * FROM issued_status WHERE issued_emp_id = 'E101';

-- Task 5: Members Issued More Than One Book
SELECT ist.issued_emp_id, e.emp_name
FROM issued_status ist
JOIN employees e ON e.emp_id = ist.issued_emp_id
GROUP BY 1, 2
HAVING COUNT(ist.issued_id) > 1;

-- Task 6: Create Book Count Summary Table
CREATE TABLE book_cnts AS
SELECT b.isbn, b.book_title, COUNT(ist.issued_id) AS no_issued
FROM books b
JOIN issued_status ist ON ist.issued_book_isbn = b.isbn
GROUP BY 1, 2;

-- Task 7: Books by Category
SELECT * FROM books WHERE category = 'Classic';

-- Task 8: Total Rental Income by Category
SELECT b.category, SUM(b.rental_price), COUNT(*)
FROM books b
JOIN issued_status ist ON ist.issued_book_isbn = b.isbn
GROUP BY 1;

-- Task 9: Members Registered in Last 180 Days
SELECT * FROM members WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';

-- Insert New Members
INSERT INTO members(member_id, member_name, member_address, reg_date)
VALUES 
('C118', 'sam', '145 Main St', '2024-06-01'),
('C119', 'john', '133 Main St', '2024-05-01');

-- Task 10: Employees with Manager and Branch Details
SELECT e1.*, b.manager_id, e2.emp_name AS manager
FROM employees e1
JOIN branch b ON b.branch_id = e1.branch_id
JOIN employees e2 ON b.manager_id = e2.emp_id;

-- Task 11: Books Priced > 7
CREATE TABLE books_price_greater_than_seven AS
SELECT * FROM books WHERE rental_price > 7;

-- Task 12: Books Not Yet Returned
SELECT DISTINCT ist.issued_book_name
FROM issued_status ist
LEFT JOIN return_status rs ON ist.issued_id = rs.issued_id
WHERE rs.return_id IS NULL;

-- Task 13: Overdue Books (30+ Days)
SELECT ist.issued_member_id, m.member_name, bk.book_title, ist.issued_date, 
       CURRENT_DATE - ist.issued_date AS over_dues_days
FROM issued_status ist
JOIN members m ON m.member_id = ist.issued_member_id
JOIN books bk ON bk.isbn = ist.issued_book_isbn
LEFT JOIN return_status rs ON rs.issued_id = ist.issued_id
WHERE rs.return_date IS NULL AND (CURRENT_DATE - ist.issued_date) > 30
ORDER BY 1;

-- Task 14: Update Book Status on Return
UPDATE books
SET status = 'yes'
WHERE isbn IN (
    SELECT ist.issued_book_isbn
    FROM return_status rs
    JOIN issued_status ist ON rs.issued_id = ist.issued_id
);

-- Task 15: Stored Procedure – Add Return Records
CREATE OR REPLACE PROCEDURE add_return_records(p_return_id VARCHAR(10), p_issued_id VARCHAR(10), p_book_quality VARCHAR(10))
LANGUAGE plpgsql
AS $$
DECLARE
    v_isbn VARCHAR(50);
    v_book_name VARCHAR(80);
BEGIN
    INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
    VALUES (p_return_id, p_issued_id, CURRENT_DATE, p_book_quality);

    SELECT issued_book_isbn, issued_book_name INTO v_isbn, v_book_name
    FROM issued_status WHERE issued_id = p_issued_id;

    UPDATE books SET status = 'yes' WHERE isbn = v_isbn;

    RAISE NOTICE 'Thank you for returning the book: %', v_book_name;
END;
$$;

-- Call Add Return Procedure
CALL add_return_records('RS138', 'IS135', 'Good');
CALL add_return_records('RS148', 'IS140', 'Good');

-- Task 16: Branch Performance Report
CREATE TABLE branch_reports AS
SELECT b.branch_id, b.manager_id, COUNT(ist.issued_id) AS number_book_issued,
       COUNT(rs.return_id) AS number_of_book_return,
       SUM(bk.rental_price) AS total_revenue
FROM issued_status ist
JOIN employees e ON e.emp_id = ist.issued_emp_id
JOIN branch b ON e.branch_id = b.branch_id
LEFT JOIN return_status rs ON rs.issued_id = ist.issued_id
JOIN books bk ON ist.issued_book_isbn = bk.isbn
GROUP BY 1, 2;

-- Task 17: Active Members (Issued Book in Last 2 Months)
CREATE TABLE active_members AS
SELECT * FROM members
WHERE member_id IN (
    SELECT DISTINCT issued_member_id
    FROM issued_status
    WHERE issued_date >= CURRENT_DATE - INTERVAL '2 month'
);

-- Task 18: Top 3 Employees by Books Issued
SELECT e.emp_name, b.*, COUNT(ist.issued_id) AS no_book_issued
FROM issued_status ist
JOIN employees e ON e.emp_id = ist.issued_emp_id
JOIN branch b ON e.branch_id = b.branch_id
GROUP BY 1, 2
ORDER BY no_book_issued DESC
LIMIT 3;

-- Task 19: Stored Procedure – Issue Book
CREATE OR REPLACE PROCEDURE issue_book(p_issued_id VARCHAR(10), p_issued_member_id VARCHAR(30), p_issued_book_isbn VARCHAR(30), p_issued_emp_id VARCHAR(10))
LANGUAGE plpgsql
AS $$
DECLARE v_status VARCHAR(10);
BEGIN
    SELECT status INTO v_status FROM books WHERE isbn = p_issued_book_isbn;

    IF v_status = 'yes' THEN
        INSERT INTO issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
        VALUES (p_issued_id, p_issued_member_id, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);
        
        UPDATE books SET status = 'no' WHERE isbn = p_issued_book_isbn;

        RAISE NOTICE 'Book issued: %', p_issued_book_isbn;
    ELSE
        RAISE NOTICE 'Book unavailable: %', p_issued_book_isbn;
    END IF;
END;
$$;

-- Call Issue Book Procedure
CALL issue_book('IS155', 'C108', '978-0-553-29698-2', 'E104');
CALL issue_book('IS156', 'C108', '978-0-375-41398-8', 'E104');
