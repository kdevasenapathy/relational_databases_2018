-- [Problem 1a]
-- Name of all students who have taken at least one CS class
SELECT DISTINCT student.name FROM ((student NATURAL JOIN takes) 
    INNER JOIN course ON course.course_id = takes.course_id)
    WHERE course.dept_name = 'Comp. Sci.';

-- [Problem 1b]
-- Max salary of instructor per department
SELECT instructor.dept_name, MAX(salary) AS max_salary 
    FROM instructor GROUP BY dept_name;


-- [Problem 1c]
-- Find the lowest maximum salary of the departments
SELECT MIN(max_salary) as min_dept_salary FROM 
    (SELECT instructor.dept_name, MAX(salary) AS max_salary 
    FROM instructor GROUP BY dept_name) AS max_salaries;

-- [Problem 1d]
-- Find the lowest maximum salary of the departments using WITH
WITH max_salaries AS (SELECT MAX(salary) AS max_s FROM instructor 
    GROUP BY dept_name) SELECT MIN(max_s) AS min_dept_salary 
    FROM max_salaries;

-- [Problem 2a]
-- Insert a CS course into the course table
INSERT INTO course VALUES ('CS-001', 'Weekly Seminar', 'Comp. Sci.', 3);

-- [Problem 2b]
-- Make a section for the previously inserted CS course
INSERT INTO section VALUES ('CS-001', '1', 'Fall', 2009, NULL, NULL, NULL);


-- [Problem 2c]
-- Add all the students into the take table for this class and update tot_cred
INSERT INTO takes SELECT student.id, 'CS-001', '1', 'Fall', 2009, NULL 
    FROM student WHERE student.dept_name = 'Comp. Sci.';
UPDATE student SET tot_cred = tot_cred + 3 WHERE dept_name = 'Comp. Sci';

-- [Problem 2d]
-- Delete Chavez's enrollments in section 1(no need to update tot_cred)
DELETE FROM takes WHERE (SELECT DISTINCT student.id 
    FROM student WHERE name = 'Chavez') = takes.id && takes.sec_id = '1';

-- [Problem 2e]
-- Delete CS 001
-- If CS 001 is deleted without deleting the corresponding sections, then any 
-- attempts to correlate section/times with the offered class title, department 
-- name, or credits will fail (return NULL) since no other course will have the 
-- same course id.
DELETE FROM course WHERE course_id = 'CS-001';

-- [Problem 2f]
-- Delete all courses with the word 'database' in the title at any point
DELETE FROM takes WHERE (SELECT course.course_id 
    FROM course WHERE LOWER(title) LIKE '%database%') = takes.course_id;

-- [Problem 3a]
-- Get names of anyone who has borrowed from publisher 'McGraw-Hill'
SELECT DISTINCT name FROM (member NATURAL JOIN book 
    NATURAL JOIN borrowed) WHERE publisher = 'McGraw-Hill';

-- [Problem 3b]
-- Get names of anyone who has borrowed all books published by 'McGraw-Hill'
SELECT DISTINCT name FROM member NATURAL JOIN book NATURAL JOIN borrowed 
    WHERE publisher = 'McGraw-Hill' GROUP BY name HAVING (SELECT COUNT(isbn) 
    AS num_books FROM book WHERE publisher = 'McGraw-Hill'  
    GROUP BY publisher)  = COUNT(isbn);

-- [Problem 3c]
-- Get the names per publisher of members who have read >5 books by them
SELECT publisher, name FROM member NATURAL JOIN book NATURAL JOIN borrowed 
    GROUP BY publisher, name HAVING COUNT(isbn) >= 5;

-- [Problem 3d]
-- Get the average number of books borrowed per member w/o WITH
SELECT SUM(num_books)/COUNT(memb_no) AS avg_per FROM 
    (SELECT memb_no, COUNT (isbn) AS num_books  FROM borrowed GROUP BY memb_no) 
    AS borrowed_books NATURAL RIGHT JOIN member;


-- [Problem 3e]
-- Get the average number of books borrowed per member using WITH
WITH books_per AS (SELECT memb_no, COUNT (isbn) AS num_books  
    FROM borrowed GROUP BY memb_no) SELECT SUM(num_books)/COUNT(memb_no) 
    AS avg_per FROM books_per NATURAL RIGHT JOIN member;



