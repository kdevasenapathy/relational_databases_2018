-- [Problem 1]
-- Set the "end of statement" character to ! so that
-- semicolons in the function body won't confuse MySQL.
DROP FUNCTION IF EXISTS min_submit_interval;
DELIMITER !
-- Given a sub_id value, returns an INTEGER 
-- representing the miniumum submission interval
CREATE FUNCTION min_submit_interval(input_id INTEGER) 
RETURNS INTEGER
BEGIN
-- Set a local variable to hold the result (initialize to NULL)
DECLARE min_sub INTEGER;
DECLARE interval_calc INTEGER;
DECLARE first_date TIMESTAMP;
DECLARE second_date TIMESTAMP;
-- Flag for completed iteration
DECLARE done INTEGER DEFAULT 0;
-- Cursor for iterating through list of submissions
DECLARE cur CURSOR FOR SELECT sub_date 
FROM fileset WHERE input_id = sub_id;
-- When there are no rows left to fetch, set flag
DECLARE CONTINUE HANDLER FOR SQLSTATE '02000'
SET done = 1;

OPEN cur;
FETCH cur INTO first_date;
WHILE NOT done DO
     FETCH cur INTO second_date;
     -- If there are at least two submissions, the flag will not be set
     IF NOT done THEN
        SET interval_calc =  UNIX_TIMESTAMP(second_date)
            - UNIX_TIMESTAMP(first_date);
        -- If the min interval is null or greater than interval, replace
        IF min_sub IS NULL OR min_sub > interval_calc THEN
            SET min_sub = interval_calc;
        END IF;
     END IF;
     SET first_date = second_date;
END WHILE;
CLOSE cur;

RETURN min_sub;

END !
-- Back to the standard SQL delimiter
DELIMITER ;

-- [Problem 2]
-- Set the "end of statement" character to ! so that
-- semicolons in the function body won't confuse MySQL.
DROP FUNCTION IF EXISTS max_submit_interval;
DELIMITER !
-- Given a sub_id value, returns an INTEGER 
-- representing the maximum submission interval
CREATE FUNCTION max_submit_interval(input_id INTEGER) 
RETURNS INTEGER
BEGIN
-- Set a local variable to hold the result (initialize to NULL)
DECLARE max_sub INTEGER;
DECLARE interval_calc INTEGER;
DECLARE first_date TIMESTAMP;
DECLARE second_date TIMESTAMP;
-- Flag for completed iteration
DECLARE done INTEGER DEFAULT 0;
-- Cursor for iterating through list of submissions
DECLARE cur CURSOR FOR SELECT sub_date 
FROM fileset WHERE input_id = sub_id;
-- When there are no rows left to fetch, set flag
DECLARE CONTINUE HANDLER FOR SQLSTATE '02000'
SET done = 1;

OPEN cur;
FETCH cur INTO first_date;
WHILE NOT done DO
     FETCH cur INTO second_date;
     -- If there are at least two submissions, the flag will not be set
     IF NOT done THEN
        SET interval_calc =  UNIX_TIMESTAMP(second_date)
            - UNIX_TIMESTAMP(first_date);
        -- If the max interval so far is null or less than interval, replace
        IF max_sub IS NULL OR max_sub < interval_calc THEN
            SET max_sub = interval_calc;
        END IF;
     END IF;
     SET first_date = second_date;
END WHILE;
CLOSE cur;

RETURN max_sub;

END !
-- Back to the standard SQL delimiter
DELIMITER ;


-- [Problem 3]
-- Set the "end of statement" character to ! so that
-- semicolons in the function body won't confuse MySQL.
DROP FUNCTION IF EXISTS avg_submit_interval;
DELIMITER !
-- Given a sub_id value, returns an INTEGER 
-- representing the maximum submission interval
CREATE FUNCTION avg_submit_interval(input_id INTEGER) 
RETURNS DOUBLE
BEGIN
-- Set local variable to hold the total interval length and 
-- number of intervals (initialize to NULL), and return value
DECLARE avg_interval DOUBLE;
DECLARE total_interval INTEGER;
DECLARE min_sub INTEGER;
DECLARE max_sub INTEGER;
DECLARE num_interval INTEGER;
SELECT COUNT(*)-1 INTO num_interval FROM fileset 
WHERE input_id = sub_id;

-- If the num intervals is less than 1, return NULL
IF num_interval < 1 THEN
    RETURN avg_interval;
END IF;

-- Otherwise, we know total interval length is diff between first 
-- and last submission
SELECT UNIX_TIMESTAMP(MIN(sub_date)) INTO min_sub 
FROM fileset WHERE input_id = sub_id;
SELECT UNIX_TIMESTAMP(MAX(sub_date)) INTO max_sub 
FROM fileset WHERE input_id = sub_id;
SET total_interval = max_sub - min_sub;

-- Average is total/num intervals
SET avg_interval = total_interval/num_interval;
RETURN avg_interval;

END !
-- Back to the standard SQL delimiter
DELIMITER ;

-- [Problem 4]
-- For speeding up the avg_submit_interval function, we
-- can speed up min/max utilized within the function 
-- using an index on sub_id
CREATE INDEX idx_sub_id ON fileset(sub_id);

