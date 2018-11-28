-- [Problem 1a]
-- Calculate a perfect score in the class
SELECT SUM(perfectscore) AS class_perfect_score 
FROM assignment;

-- [Problem 1b]
-- All the section names and # students in each section
WITH per_section AS (SELECT sec_id, COUNT(username) 
AS num_students FROM student GROUP BY sec_id)
SELECT sec_name, num_students FROM section 
NATURAL LEFT JOIN per_section;


-- [Problem 1c]
-- Create a view totalscore that has the student's usernames
-- and total scores for the whole course, taking into account 
-- the graded flag on the submission.
DROP VIEW IF EXISTS totalscores;
CREATE VIEW totalscores (username, total_class_score) 
AS SELECT username, SUM(score) AS total_class_score 
FROM submission WHERE graded = 1 
GROUP BY username;

-- [Problem 1d]
-- Create a view passing that has the students usernames
-- and scores if they have a score >= 40
DROP VIEW IF EXISTS passing;
CREATE VIEW passing (username, passing_class_score) 
AS SELECT username, total_class_score 
FROM totalscores WHERE total_class_score >= 40;


-- [Problem 1e]
-- Create a view failing that has the students usernames
-- and scores if they have a score < 40
DROP VIEW IF EXISTS failing;
CREATE VIEW failing (username, failing_class_score) 
AS SELECT username, total_class_score 
FROM totalscores WHERE total_class_score < 40;

-- [Problem 1f]
-- List the usernames of all the students who skipped at 
-- least one lab but still passed the class.
SELECT DISTINCT username FROM submission 
NATURAL LEFT JOIN fileset WHERE asn_id IN 
(SELECT asn_id FROM assignment 
WHERE shortname LIKE 'lab%') && username IN 
(SELECT username FROM passing)  
&& fset_id IS NULL;

-- Result of running:
-- 'harris'
-- 'ross'
-- 'miller'
-- 'turner'
-- 'edwards'
-- 'murphy'
-- 'simmons'
-- 'tucker'
-- 'coleman'
-- 'flores'
-- 'gibson'

-- [Problem 1g]
-- List the usernames of all the students who skipped a 
-- midterm/final but still passed the class.
SELECT DISTINCT username FROM submission 
NATURAL LEFT JOIN fileset WHERE asn_id IN 
(SELECT asn_id FROM assignment 
WHERE shortname LIKE '%midterm%' 
OR shortname LIKE '%final%') && fset_id IS NULL 
&& username IN (SELECT username FROM passing);

-- Result of running (what a baller):
-- 'collins'

-- [Problem 2a]
-- List of usernames who submitted after midterm due
SELECT DISTINCT username FROM 
assignment NATURAL JOIN submission NATURAL JOIN
fileset WHERE shortname LIKE '%midterm%' AND 
sub_date > due;


-- [Problem 2b]
-- Results in an hour of the day and the number of labs
-- submitted in that hour (range of 0 to 23). 
SELECT EXTRACT(HOUR FROM sub_date) AS hour, 
COUNT(sub_id) as num_submits FROM fileset NATURAL 
JOIN submission NATURAL JOIN assignment WHERE 
shortname LIKE 'lab%' GROUP BY hour;

-- [Problem 2c]
-- Returns total number of finals turned in within 30 minutes 
-- before the due date
 SELECT COUNT(sub_id) AS last_minute_finals FROM 
 fileset NATURAL JOIN submission NATURAL JOIN 
 assignment WHERE shortname LIKE 'final' && 
 sub_date BETWEEN due - INTERVAL 30 MINUTE AND due; 
 
-- [Problem 3a]
-- Adds a column email to the student table and populate it
-- with username@school.edu
ALTER TABLE student ADD email VARCHAR(200);
UPDATE student 
SET email  = CONCAT(username, '@school.edu');
ALTER TABLE student MODIFY email VARCHAR(200) NOT NULL;

-- [Problem 3b]
-- Add a column submit_files to assignment, and make it default 
-- true but false for daily quizzes
ALTER TABLE assignment ADD submit_files 
BOOLEAN DEFAULT TRUE NOT NULL;
UPDATE assignment
SET submit_files = FALSE WHERE shortname LIKE 'dq%';

-- [Problem 3c]
-- Create a table gradescheme(scheme_id, scheme_desc) where
-- scheme_id is the primary key and is an integer and 
-- scheme_desc is a 100 non-null varchar. Rename gradescheme 
-- to scheme_id in assignment and make this table a foreign key.
DROP TABLE IF EXISTS gradescheme;
CREATE TABLE gradescheme (
    scheme_id INT PRIMARY KEY,
    scheme_desc VARCHAR (100) NOT NULL
);

INSERT INTO gradescheme 
VALUES (0, 'Lab assignment with min-grading.');
INSERT INTO gradescheme 
VALUES (1, 'Daily quiz.');
INSERT INTO gradescheme 
VALUES (2, 'Midterm or final exam.');

ALTER TABLE assignment CHANGE gradescheme scheme_id 
INT NOT NULL;
ALTER TABLE assignment ADD FOREIGN KEY (scheme_id)
REFERENCES gradescheme(scheme_id);

-- [Problem 4a]
-- Set the "end of statement" character to ! so that
-- semicolons in the function body won't confuse MySQL.
DELIMITER !
-- Given a date value, returns TRUE if it is a weekend,
-- or FALSE if it is a weekday.
CREATE FUNCTION is_weekend(d DATE) 
RETURNS BOOLEAN
BEGIN
-- Use weekday function to find the weekday index of the date
-- 0 = Monday... 6 = SUNDAY and return true if 5 or 6
IF WEEKDAY(d) = 5
THEN RETURN TRUE;
ELSEIF WEEKDAY(d) = 6
THEN RETURN TRUE;
ELSE 
RETURN FALSE;
END IF;

END !
-- Back to the standard SQL delimiter
DELIMITER ;

-- [Problem 4b]
-- Set the "end of statement" character to ! so that
-- semicolons in the function body won't confuse MySQL.
DELIMITER !
-- Given a date value, returns a 20 character VARCHAR
CREATE FUNCTION is_holiday(d DATE) 
RETURNS VARCHAR(20)
BEGIN
-- Set a local variable to hold the result
DECLARE holiday VARCHAR(20);
-- Set up a few helper local variables, including:
-- a month (range 1 to 12)
DECLARE month INT
DEFAULT EXTRACT(MONTH FROM d);
-- the day of month (range 1 to 31)
DECLARE day INT DEFAULT
EXTRACT(DAY FROM d);
-- the index of day of week (range 0 (Mon) to 6 (Sun))
DECLARE weekday INT DEFAULT WEEKDAY(d);
-- Use a series of if/else statements to determine 
-- if the returned date is one of the specified holidays
IF (month = 1 AND day = 1)
THEN SET holiday = 'New Year\'s Day';
ELSEIF (month = 5 AND weekday = 0 AND 
day BETWEEN 25 AND 31)
THEN SET holiday = 'Memorial Day';
ELSEIF (month = 7 AND day = 4)
THEN SET holiday = 'Independence Day';
ELSEIF (month = 9 AND weekday = 0 AND 
day BETWEEN 1 AND 7)
THEN SET holiday = 'Labor Day';
ELSEIF (month = 11 AND weekday = 3 AND 
day BETWEEN 22 AND 28)
THEN SET holiday = 'Thanksgiving';
END IF;

-- If none of the statements apply, return default NULL
RETURN holiday;

END !
-- Back to the standard SQL delimiter
DELIMITER ;

-- [Problem 5a]
-- Determine how many filesets were submitted over
-- the holidays cateogorized by holiday
SELECT is_holiday(DATE(sub_date)) AS holiday_name, 
COUNT(fset_id) AS num_submissions FROM fileset 
GROUP BY holiday_name;

-- [Problem 5b]
-- Determine how many filesets were submitted over 
-- the weekends versus over the weekdays
SELECT CASE is_weekend(DATE(sub_date)) WHEN 
TRUE THEN 'weekend' WHEN FALSE 
THEN 'weekday' END AS part_of_week, 
COUNT(fset_id) AS num_submissions FROM fileset 
GROUP BY part_of_week;

