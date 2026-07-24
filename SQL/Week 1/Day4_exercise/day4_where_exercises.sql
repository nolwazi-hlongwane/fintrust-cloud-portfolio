-- Day 4 Self-Paced Exercises: WHERE Clause Practice
USE fintrust_db;

-- Exercise 1: All customers from Gauteng
SELECT * FROM customers WHERE province = 'Gauteng';

-- Exercise 2: All accounts with a balance greater than R5,000
SELECT * FROM accounts WHERE balance > 5000;

-- Exercise 3: Customers whose email ends in '.co.za'
SELECT * FROM customers WHERE email LIKE '%.co.za';

-- Exercise 4: Transactions of type DEBIT or PAYMENT (using IN)
SELECT * FROM transactions WHERE transaction_type IN ('DEBIT', 'PAYMENT');

-- Exercise 5: SAVINGS accounts with balance between R1,000 and R50,000
SELECT * FROM accounts
WHERE account_type = 'SAVINGS' AND balance BETWEEN 1000 AND 50000;

-- Exercise 6: Transactions that DO have a merchant_category recorded
SELECT * FROM transactions WHERE merchant_category IS NOT NULL;