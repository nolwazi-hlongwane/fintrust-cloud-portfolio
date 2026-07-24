-- Practical Guide Challenge: WHERE Clause Practice Challenges
USE fintrust_db;

-- Challenge 1 (Easy): Customers NOT from Gauteng or Western Cape
-- Business question: which customers fall outside our two largest markets?
SELECT * FROM customers
WHERE province NOT IN ('Gauteng', 'Western Cape');

-- Challenge 2 (Easy-Medium): CHEQUE or SAVINGS accounts, balance R1,000-R20,000
-- Business question: which everyday-banking accounts fall in a mid-range balance tier?
SELECT * FROM accounts
WHERE balance BETWEEN 1000 AND 20000
  AND account_type IN ('CHEQUE', 'SAVINGS');

-- Challenge 3 (Medium): Food or Groceries transactions over R200
-- Business question: which higher-value food-related spending needs review?
SELECT * FROM transactions
WHERE (merchant_category LIKE '%Food%' OR merchant_category LIKE '%Groceries%')
  AND amount > 200;

-- Challenge 4 (Medium-Hard): DEBIT transactions with no merchant_category, amount > R100
-- Business question: which sizeable debits are missing merchant data quality?
SELECT * FROM transactions
WHERE transaction_type = 'DEBIT'
  AND merchant_category IS NULL
  AND amount > 100;
-- Note: returns 0 rows against current sample data — every DEBIT row
-- has a merchant_category recorded. Correct query, just no matching data yet.

-- Challenge 5 (Hard): Customers with .co.za or .com email, province recorded, ordered by last_name
-- Business question: which customers can we reach via standard email domains,
-- with enough profile data for regional segmentation?
SELECT * FROM customers
WHERE (email LIKE '%.co.za' OR email LIKE '%.com')
  AND province IS NOT NULL
ORDER BY last_name;