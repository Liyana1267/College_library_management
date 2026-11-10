create database college_db;
use college_db;
CREATE TABLE members (
    member_id INT PRIMARY KEY,
    member_name VARCHAR(100),
    member_type VARCHAR(20),
    joined_date DATE
);
CREATE TABLE books (
    book_id INT PRIMARY KEY,
    title VARCHAR(150),
    author VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2),
    copies_available INT
);
CREATE TABLE issues (
    issue_id INT PRIMARY KEY,
    member_id INT,
    book_id INT,
    issue_date DATE,
    due_date DATE,
    return_date DATE,
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);
SELECT
 (SELECT COUNT(*) FROM members) AS total_members,
 (SELECT COUNT(*) FROM books) AS total_books,
 (SELECT COUNT(*) FROM issues) AS total_issues;
 SELECT category,
       COUNT(*) AS total_titles,
       SUM(copies_available) AS total_copies
FROM books
GROUP BY category;
SELECT b.title, COUNT(*) AS total_borrowed
FROM books b
JOIN issues i ON b.book_id = i.book_id
GROUP BY b.book_id, b.title
ORDER BY total_borrowed DESC
LIMIT 5;
SELECT m.member_id, m.member_name
FROM members m
LEFT JOIN issues i ON m.member_id = i.member_id
WHERE i.issue_id IS NULL;
SELECT m.member_name, b.title, i.due_date
FROM issues i
JOIN members m ON i.member_id = m.member_id
JOIN books b ON i.book_id = b.book_id
WHERE i.return_date IS NULL;
SELECT b.title, m.member_name,
       DATEDIFF(i.return_date, i.due_date) AS days_late,
       DATEDIFF(i.return_date, i.due_date) * 2 AS fine
FROM issues i
JOIN books b ON i.book_id = b.book_id
JOIN members m ON i.member_id = m.member_id
WHERE i.return_date > i.due_date;
SELECT m.member_name,
       SUM(DATEDIFF(i.return_date, i.due_date) * 2) AS total_fine
FROM members m
JOIN issues i ON m.member_id = i.member_id
WHERE i.return_date > i.due_date
GROUP BY m.member_id, m.member_name
HAVING total_fine > 0;
SELECT m.member_type,
       COUNT(i.issue_id) AS total_borrowed
FROM members m
LEFT JOIN issues i ON m.member_id = i.member_id
GROUP BY m.member_type;
SELECT m.member_name,
       COUNT(i.issue_id) AS total_borrowed,
       RANK() OVER (ORDER BY COUNT(i.issue_id) DESC) AS member_rank
FROM members m
LEFT JOIN issues i ON m.member_id = i.member_id
GROUP BY m.member_id, m.member_name;
SELECT b.category,
       COUNT(i.issue_id) AS total_issues
FROM books b
JOIN issues i ON b.book_id = i.book_id
GROUP BY b.category
ORDER BY total_issues DESC;
SELECT *
FROM books
WHERE copies_available = 0
AND book_id IN (
    SELECT book_id
    FROM issues
    WHERE return_date IS NULL
);
DELIMITER //

CREATE PROCEDURE member_history(IN p_member_id INT)
BEGIN
    SELECT m.member_name, b.title,
           i.issue_date, i.due_date, i.return_date
    FROM issues i
    JOIN members m ON i.member_id = m.member_id
    JOIN books b ON i.book_id = b.book_id
    WHERE i.member_id = p_member_id;
END //

DELIMITER ;
CALL member_history(1);
CREATE TABLE books_copy AS
SELECT * FROM books;

CREATE TABLE issues_copy AS
SELECT * FROM issues;
DELIMITER //

CREATE TRIGGER reduce_copies
AFTER INSERT ON issues_copy
FOR EACH ROW
BEGIN
    UPDATE books_copy
    SET copies_available = copies_available - 1
    WHERE book_id = NEW.book_id;
END //

DELIMITER ;
SELECT book_id, title, copies_available
FROM books_copy WHERE book_id = 1;
ALTER TABLE books_copy
ADD PRIMARY KEY (book_id);
SHOW KEYS FROM books_copy;
INSERT INTO issues_copy
(issue_id, member_id, book_id, issue_date, due_date, return_date)
VALUES
(9999, 1, 1, CURDATE(),
DATE_ADD(CURDATE(), INTERVAL 14 DAY), NULL);
SELECT * FROM books_copy;
SELECT book_id, title, copies_available
FROM books_copy WHERE book_id = 1;

SHOW TABLES;

SELECT * FROM members LIMIT 5;
SELECT * FROM books LIMIT 5;
SELECT * FROM issues LIMIT 5;