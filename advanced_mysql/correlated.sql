-- [Problem a]
-- Computes the list of all customers ordered by the number of 
-- loans they have at their bank in descending order

SELECT customer_name, COUNT(loan_number) AS num_loans
FROM customer AS c NATURAL LEFT JOIN borrower
GROUP BY c.customer_name ORDER BY num_loans DESC;

-- [Problem b]
-- Computes the list of branches where the value of assets is 
-- less than the total value of all the loans taken from that branch
 
WITH total_loans AS (SELECT branch_name, 
SUM(amount) AS total_amt FROM loan 
GROUP BY branch_name) SELECT b.branch_name 
FROM branch AS b NATURAL LEFT JOIN total_loans 
WHERE assets < total_amt;

-- [Problem c]
-- Correlated list of branches and associated number 
-- of accounts and loans
SELECT b.branch_name, (SELECT COUNT(*) 
FROM account AS a 
WHERE a.branch_name = b.branch_name) AS num_accounts,
(SELECT COUNT(*) FROM loan AS l 
WHERE l.branch_name = b.branch_name) AS num_loans
FROM branch AS b ORDER BY b.branch_name;


-- [Problem d]
-- Decorrelate the query from problem c
SELECT branch_name, 
COUNT(DISTINCT account_number) AS num_accounts, 
COUNT(DISTINCT loan_number) AS num_loans
FROM branch AS b NATURAL LEFT JOIN loan 
NATURAL LEFT JOIN account GROUP BY b.branch_name; 


