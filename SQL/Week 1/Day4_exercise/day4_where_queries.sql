-- Day 4 Lab: Business Intelligence Queries for the FinTrust Analytics Team
USE fintrust_db;

-- QUERY 1: Gauteng customers — marketing regional campaign
SELECT customer_id, first_name, last_name, email
FROM customers
WHERE province = 'Gauteng'
ORDER BY last_name;

-- QUERY 2: High-balance accounts — risk management monitoring (> R10,000)
SELECT account_id, account_number, account_type, balance
FROM accounts
WHERE balance > 10000
ORDER BY balance DESC;

-- QUERY 3: SAVINGS accounts — savings product feature rollout
SELECT account_id, customer_id, account_number, balance
FROM accounts
WHERE account_type = 'SAVINGS'
ORDER BY balance DESC;

-- QUERY 4: Large grocery transactions — fraud team review (> R500 in Groceries)
SELECT transaction_id, account_id, amount, transaction_type, transaction_date
FROM transactions
WHERE merchant_category = 'Groceries'
  AND amount > 500
ORDER BY amount DESC;
-- Note: returns 0 rows against the current 5-row sample data (the one
-- Groceries transaction is R250, under the R500 threshold). Query logic
-- is correct — the result depends on the data, not the query.

-- QUERY 5: Gmail customers — digital team campaign
SELECT first_name, last_name, email
FROM customers
WHERE email LIKE '%gmail%'
ORDER BY last_name;

-- STRETCH — 6th query: total transaction volume per account, useful for
-- the analytics team to identify most-active accounts
SELECT account_id, COUNT(*) AS transaction_count, SUM(amount) AS total_amount
FROM transactions
GROUP BY account_id
ORDER BY total_amount DESC;