-- [Problem 1]
-- Since the min/max functions are operating on 
-- balance in the view, we use it as the index column
CREATE INDEX idx_balance ON account(balance);

-- [Problem 2]
-- Create table for the materialized view 
-- referencing types from branch/account tables
CREATE TABLE mv_branch_account_stats (
    branch_name VARCHAR(15) NOT NULL,
    num_accounts INTEGER NOT NULL,
    total_deposits NUMERIC (14, 2) NOT NULL,
    min_balance NUMERIC (12, 2) NOT NULL,
    max_balance NUMERIC(12, 2) NOT NULL,
    PRIMARY KEY (branch_name),
    FOREIGN KEY (branch_name) 
    REFERENCES  branch (branch_name)
);

-- [Problem 3]
-- Use insert into -select syntax to add the computed
-- initial values into the materialized view
INSERT INTO mv_branch_account_stats 
SELECT branch_name, COUNT(*) AS num_accounts, 
SUM(balance) AS total_deposits,
MIN(balance) AS min_balance,
MAX(balance) AS max_balance
FROM account GROUP BY branch_name;


-- [Problem 4]
-- Create the corresponding view to the table
CREATE VIEW branch_account_stats AS
 SELECT branch_name, num_accounts, 
 total_deposits, total_deposits/num_accounts 
 AS avg_balance, min_balance, max_balance 
 FROM mv_branch_account_stats;

-- [Problem 5]
DELIMITER !
CREATE TRIGGER trg_insert AFTER INSERT 
ON account FOR EACH ROW
BEGIN
    -- If the branch_name doesn't already exists, add 
    -- new summary info; if exists, the duplicate key 
    -- update on branch will update values
    INSERT INTO mv_branch_account_stats 
    VALUES (NEW.branch_name, 1, NEW.balance, 
    NEW.balance, NEW.balance) 
    ON DUPLICATE KEY UPDATE num_accounts = 
    num_accounts + 1, total_deposits = 
    total_deposits + NEW.balance, 
    min_balance = LEAST(min_balance, NEW.balance),
    max_balance = 
    GREATEST(max_balance, NEW.balance);
END;
DELIMITER ;

-- [Problem 6]
DELIMITER !
CREATE TRIGGER trg_delete AFTER DELETE 
ON account FOR EACH ROW
BEGIN
CALL delete_from_branch(OLD.branch_name);
END;

-- Helper procedure to delete banks with no 
-- more accounts and update min/max 
CREATE PROCEDURE delete_from_branch(
IN old_name VARCHAR(15)
)
BEGIN
    DECLARE num_accts INTEGER;
-- Calculate number of accounts left post-deletion
    INSERT COUNT(account_number) INTO num_accts
    FROM account WHERE account.branch_name = 
    old_name.branch_name;
    -- If this was the last account from this branch, 
    -- remove summary. Else, update the stats.
    IF num_accts = 0 THEN 
        DELETE FROM mv_branch_account_stats 
        WHERE branch_name = old_name.branch_name;
    ELSE 
        -- Calculate the min and max balance after removal
        INSERT MIN(balance) INTO min_bal FROM account
        WHERE account.branch_name = old_name.branch_name;
        INSERT MAX(balance) INTO max_bal FROM account
        WHERE account.branch_name = old_name.branch_name;
        UPDATE mv_branch_account_stats 
            SET num_accounts = num_accts,
            total_balance = total_balance - old_name.balance,
            min_balance = min_bal,
            max_balance = max_bal
        WHERE branch_name = old_name.branch_name;
    END IF;
END
DELIMITER ;


-- [Problem 7]
DELIMITER !
CREATE TRIGGER trg_update AFTER UPDATE
ON account FOR EACH ROW
BEGIN
    -- If the branch_name has been updated to 
    -- reflect a different branch, then use stored
    -- procedure helper function to update. Else, 
    -- update summary statistics. 
    IF (OLD.branch_name = NEW.branch_name) THEN
        UPDATE mv_branch_account_stats 
            SET total_balance = 
            total_balance - OLD.balance + NEW.balance,
            min_balance = LEAST(min_balance, NEW.balance),
            max_balance = GREATEST(max_balance, NEW.balance)
        WHERE branch_name = NEW.branch_name;
    ELSE
        -- 'Delete' the account from the old branch:
        CALL delete_from_branch(OLD.branch_name);
        -- Add the account to the new branch
        INSERT INTO mv_branch_account_stats 
        VALUES (NEW.branch_name, 1, NEW.balance, 
        NEW.balance, NEW.balance) 
        ON DUPLICATE KEY UPDATE num_accounts = 
        num_accounts + 1, total_deposits = 
        total_deposits + NEW.balance, 
        min_balance = LEAST(min_balance, NEW.balance),
        max_balance = 
        GREATEST(max_balance, NEW.balance);
    END IF;
END;
DELIMITER ;