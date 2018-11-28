-- [Problem 1a]
-- Get loan numbers and amounts for loans between 1000 and 2000
SELECT loan_number, amount FROM loan WHERE amount <= 2000 && amount >= 1000;


-- [Problem 1b]
-- Get loan number and amount in order of all Smith loans
SELECT loan_number, amount FROM loan NATURAL JOIN borrower 
    WHERE customer_name = 'Smith' ORDER BY loan_number ASC;


-- [Problem 1c]
-- Get city of branch where A-446 is open
SELECT branch_city FROM  branch NATURAL JOIN account 
    WHERE account_number = 'A-446';

-- [Problem 1d]
-- Get info from account and depositor for customer names start with J  
SELECT * FROM depositor NATURAL JOIN account WHERE customer_name LIKE 'J%' 
    ORDER BY customer_name ASC;


-- [Problem 1e]
-- Retrieve names of all customers with more than 5 bank accounts
SELECT customer_name FROM depositor NATURAL JOIN account 
    GROUP BY customer_name HAVING COUNT(account_number) > 5; 

-- [Problem 2a]
-- Create a view with the account number and customer names at pownal branch
CREATE VIEW pownal_customers AS SELECT account_number, customer_name 
    FROM depositor NATURAL JOIN account WHERE branch_name = 'Pownal';

-- [Problem 2b]
-- Updatable view onlyacct_customers for customers w an account but no loan
CREATE VIEW onlyacct_customers AS SELECT 
    customer_name, customer_street, customer_city FROM customer WHERE 
    customer_name IN (SELECT customer_name FROM depositor) && 
    customer_name NOT IN (SELECT customer_name FROM borrower);


-- [Problem 2c]
-- Creates a view branch_deposits w/ branch, total val, avg balance 
CREATE VIEW branch_deposits AS SELECT branch.branch_name, 
    IFNULL(SUM(account.balance), 0) AS total_balance, 
    AVG(account.balance) AS avg_balance FROM account RIGHT JOIN branch 
    ON branch.branch_name = account.branch_name GROUP BY branch.branch_name;

-- [Problem 3a]
-- List of cities where customers live but no bank branch, alphabetically
SELECT DISTINCT customer_city FROM customer WHERE 
    customer_city NOT IN (SELECT branch_city FROM branch) 
    ORDER BY customer_city ASC;

-- [Problem 3b]
-- List of customer names with no account or loan
SELECT customer_name FROM customer WHERE customer_name NOT IN 
    (SELECT customer_name FROM depositor) && 
    customer_name NOT IN (SELECT customer_name FROM borrower);
            
-- [Problem 3c]
-- Deposit 50 more bucks into each account at Horseneck
UPDATE account SET balance = balance + 50 WHERE account.branch_name IN 
    (SELECT branch_name FROM branch WHERE branch_city = 'Horseneck');

-- [Problem 3d]
-- Deposit 50  bucks into each Horseneck using multi-table update 
UPDATE account, branch SET balance = balance + 50 
    WHERE branch_city = 'Horseneck';

-- [Problem 3e]
-- Get the largest balance, list using a derived relation join in FROM
SELECT * FROM account NATURAL JOIN (SELECT branch_name, MAX(balance) as balance 
    FROM account GROUP BY branch_name) AS max_finder;

-- [Problem 3f]
-- Get the largest balance a multicolumn IN predicate
SELECT * FROM account WHERE (branch_name, balance) IN 
    (SELECT branch_name, MAX(balance) as balance 
    FROM account GROUP BY branch_name);

-- [Problem 4]
-- Rankbank branches by assets 
WITH g_assets AS (SELECT A.branch_name, COUNT(B.assets) AS rank  
    FROM branch AS A, branch AS B WHERE A.assets<B.assets 
    GROUP BY A.branch_name) SELECT branch.branch_name, assets, g_assets.rank 
    FROM branch NATURAL JOIN g_assets ORDER BY rank DESC, branch_name;


