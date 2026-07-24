-- Day 2 Lab: Simple Queries on FinTrust Dataset
USE fintrust;

-- Exercise 1: First and last name of every customer, plus province, ordered by province
SELECT first_name, last_name, province
FROM customers
ORDER BY province;

-- Exercise 2: Account number, type, and balance for SAVINGS accounts, first 20 results
SELECT account_number, account_type, balance
FROM accounts
WHERE account_type = 'SAVINGS'
LIMIT 20;

-- Exercise 3: All unique provinces with FinTrust customers
SELECT DISTINCT province FROM customers;

-- Exercise 4: Total balance potential (balance + 10% interest for one year)
SELECT
  account_number,
  balance,
  balance * 1.10 AS projected_balance
FROM accounts;

-- Exercise 5 (Stretch): How many accounts are in the accounts table?
SELECT COUNT(*) AS total_accounts FROM accounts;