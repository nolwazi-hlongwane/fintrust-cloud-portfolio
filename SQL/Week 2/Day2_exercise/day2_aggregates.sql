-- Week 2 Day 2: Aggregate Functions — COUNT, SUM, AVG, GROUP BY, HAVING
USE fintrust_db;

-- Exercise 1: Transaction count and total amount per customer (customers with >=1 transaction)
-- Business question: which customers are most active/valuable by transaction volume?
-- INNER JOIN naturally excludes customers with zero transactions.
SELECT
    c.first_name,
    c.last_name,
    c.province,
    COUNT(t.transaction_id) AS total_transactions,
    SUM(t.amount)           AS total_amount
FROM customers c
INNER JOIN accounts a ON c.customer_id = a.customer_id
INNER JOIN transactions t ON a.account_id = t.account_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name,
    c.province
ORDER BY total_amount DESC;

-- Exercise 2: Average balance by account type
-- Business question: which account type holds the most value on average?
SELECT
    account_type,
    COUNT(*)      AS num_accounts,
    AVG(balance)  AS avg_balance
FROM accounts
GROUP BY account_type
ORDER BY avg_balance DESC;

-- Exercise 3: Provinces where total CREDIT (deposit) amount exceeds R100,000
-- Business question: which regions are driving the highest deposit volume?
-- HAVING used (not WHERE) because the filter is on an aggregate (SUM), not a raw row value.
SELECT
    c.province,
    SUM(t.amount)            AS total_deposits,
    COUNT(t.transaction_id)  AS credit_count
FROM customers c
INNER JOIN accounts a ON c.customer_id = a.customer_id
INNER JOIN transactions t ON a.account_id = t.account_id
WHERE t.transaction_type = 'CREDIT'
GROUP BY c.province
HAVING SUM(t.amount) > 100000;
-- Note: returns 0 rows against current sample data — only one CREDIT
-- transaction exists (R5,000), well under the R100,000 threshold.
-- Query logic is correct; the result depends on data volume.

-- Exercise 4: Total transaction amount and count per month
-- Business question: what does monthly transaction volume look like over time?
SELECT
    YEAR(transaction_date)  AS txn_year,
    MONTH(transaction_date) AS txn_month,
    COUNT(*)                AS transaction_count,
    SUM(amount)             AS monthly_total
FROM transactions
GROUP BY txn_year, txn_month
ORDER BY txn_year DESC, txn_month DESC;

-- Exercise 5 (Challenge): Customers with more than 3 DEBIT transactions in a single day
-- Business question: fraud detection signal — unusually frequent same-day debits
SELECT
    c.first_name,
    c.last_name,
    DATE(t.transaction_date) AS txn_day,
    COUNT(*)                 AS debit_count
FROM customers c
INNER JOIN accounts a ON c.customer_id = a.customer_id
INNER JOIN transactions t ON a.account_id = t.account_id
WHERE t.transaction_type = 'DEBIT'
GROUP BY c.customer_id, txn_day
HAVING COUNT(*) > 3;
-- Note: returns 0 rows against current sample data — no customer has more
-- than 2 debit transactions on any single day yet. Query logic is correct;
-- as more transaction data accumulates, this would start surfacing hits.