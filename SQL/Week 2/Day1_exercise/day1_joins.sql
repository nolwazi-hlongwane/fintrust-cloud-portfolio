-- Week 2 Day 1: SQL JOINs — FinTrust customers, accounts, transactions
USE fintrust_db;

-- ═══════════════════════════════════════════════════════
-- LAB EXERCISES
-- ═══════════════════════════════════════════════════════

-- Exercise 1: All customers with their account type and balance (INNER JOIN)
-- Business question: full customer-account list for reporting
SELECT
    c.first_name,
    c.last_name,
    a.account_type,
    a.balance
FROM customers c
INNER JOIN accounts a ON c.customer_id = a.customer_id
ORDER BY a.balance DESC;

-- Exercise 2: Gauteng customers with balance > R25,000
-- Business question: high-value Gauteng customers for a premium offer
SELECT
    c.first_name,
    c.last_name,
    c.province,
    a.account_type,
    a.balance
FROM customers c
INNER JOIN accounts a ON c.customer_id = a.customer_id
WHERE c.province = 'Gauteng'
  AND a.balance > 25000;

-- Exercise 3: 3-table JOIN — DEBIT transactions only, most recent first
-- Business question: recent debit activity across all customers
SELECT
    c.first_name,
    c.last_name,
    a.account_type,
    t.amount,
    t.transaction_date
FROM customers c
INNER JOIN accounts a ON c.customer_id = a.customer_id
INNER JOIN transactions t ON a.account_id = t.account_id
WHERE t.transaction_type = 'DEBIT'
ORDER BY t.transaction_date DESC;

-- Exercise 4: Customers who have never made a transaction (LEFT JOIN anti-pattern)
-- Business question: fraud/data-quality signal — customers with no transaction history
-- Chose LEFT JOIN (not INNER) because we need customers to appear even when
-- accounts/transactions don't match, so the IS NULL filter can catch the gap.
SELECT
    c.customer_id,
    c.first_name,
    c.last_name
FROM customers c
LEFT JOIN accounts a ON c.customer_id = a.customer_id
LEFT JOIN transactions t ON a.account_id = t.account_id
WHERE t.transaction_id IS NULL;

-- Exercise 5: Transactions > R10,000 for Western Cape or KwaZulu-Natal customers
-- Business question: large transactions in two specific provinces for regional review
SELECT
    c.first_name,
    c.last_name,
    c.province,
    t.amount
FROM customers c
INNER JOIN accounts a ON c.customer_id = a.customer_id
INNER JOIN transactions t ON a.account_id = t.account_id
WHERE t.amount > 10000
  AND c.province IN ('Western Cape', 'KwaZulu-Natal')
ORDER BY t.amount DESC;
-- Note: returns 0 rows against current sample data — no transaction in this
-- dataset both exceeds R10,000 AND belongs to a WC/KZN customer. Query logic
-- is correct; the result depends on the data available.

-- ═══════════════════════════════════════════════════════
-- PRACTICAL GUIDE CHALLENGES
-- ═══════════════════════════════════════════════════════

-- Challenge 1: Customers with a CHEQUE account balance below R1,000
-- Business question: which cheque accounts are at risk of going overdrawn?
SELECT
    c.first_name,
    c.last_name,
    c.province,
    a.balance
FROM customers c
INNER JOIN accounts a ON c.customer_id = a.customer_id
WHERE a.account_type = 'CHEQUE'
  AND a.balance < 1000
ORDER BY a.balance ASC;
-- Note: returns 0 rows — both cheque accounts in the sample data have
-- balances well above R1,000. Correct query, no matching data yet.

-- Challenge 2: All transactions made by Western Cape customers (3-table JOIN)
-- Business question: regional transaction activity for Western Cape
SELECT
    c.first_name,
    c.last_name,
    t.amount,
    t.transaction_type
FROM customers c
INNER JOIN accounts a ON c.customer_id = a.customer_id
INNER JOIN transactions t ON a.account_id = t.account_id
WHERE c.province = 'Western Cape';
-- Note: returns 0 rows — Zanele Khumalo (Western Cape) has an account but
-- no recorded transactions yet, confirmed independently by Exercise 4 above.

-- Challenge 3: Accounts with NO transactions recorded (LEFT JOIN from accounts)
-- Business question: which accounts are completely inactive?
SELECT
    a.account_id,
    a.account_type,
    a.balance,
    c.first_name,
    c.last_name
FROM accounts a
LEFT JOIN transactions t ON a.account_id = t.account_id
INNER JOIN customers c ON a.customer_id = c.customer_id
WHERE t.transaction_id IS NULL;