-- ════════════════════════════════════════════════════════════
-- FinTrust Bank — Core Database Schema (Week 1 Day 3)
-- Database: fintrust_db
-- ════════════════════════════════════════════════════════════

CREATE DATABASE IF NOT EXISTS fintrust_db;
USE fintrust_db;

-- ═══════════════════════════════════════════════════════
-- TABLE 1: customers
-- Stores personal details of FinTrust Bank account holders.
-- customer_id is the primary key — referenced by accounts table.
-- email is UNIQUE — one account per email address (POPIA requirement).
-- ═══════════════════════════════════════════════════════
CREATE TABLE customers (
    customer_id  INT           PRIMARY KEY AUTO_INCREMENT,
    first_name   VARCHAR(100)  NOT NULL,
    last_name    VARCHAR(100)  NOT NULL,
    email        VARCHAR(200)  UNIQUE NOT NULL,
    province     VARCHAR(50),
    created_at   DATETIME      DEFAULT CURRENT_TIMESTAMP
);

-- ═══════════════════════════════════════════════════════
-- TABLE 2: accounts
-- Each customer can have multiple accounts (one-to-many).
-- customer_id is a FOREIGN KEY — enforces referential integrity.
-- ENUM restricts account_type to known valid values only.
-- DECIMAL(15,2) stores money exactly — never use FLOAT for currency.
-- ═══════════════════════════════════════════════════════
CREATE TABLE accounts (
    account_id      INT           PRIMARY KEY AUTO_INCREMENT,
    customer_id     INT           NOT NULL,
    account_type    ENUM('CHEQUE','SAVINGS','CREDIT','BUSINESS') NOT NULL,
    account_number  VARCHAR(20)   UNIQUE NOT NULL,
    balance         DECIMAL(15,2) DEFAULT 0.00,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- ═══════════════════════════════════════════════════════
-- TABLE 3: transactions
-- Each transaction belongs to one account (via account_id FK).
-- merchant_category enables spending analysis (fraud detection).
-- transaction_date defaults to NOW() — audit trail for POPIA.
-- ═══════════════════════════════════════════════════════
CREATE TABLE transactions (
    transaction_id    INT           PRIMARY KEY AUTO_INCREMENT,
    account_id        INT           NOT NULL,
    transaction_type  ENUM('DEBIT','CREDIT','PAYMENT') NOT NULL,
    amount            DECIMAL(15,2) NOT NULL,
    merchant_category VARCHAR(100),
    transaction_date  DATETIME      DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

-- ═══════════════════════════════════════════════════════
-- INSERT DATA — order matters: customers → accounts → transactions
-- ═══════════════════════════════════════════════════════

-- CUSTOMERS: 5 rows across different provinces
INSERT INTO customers (first_name, last_name, email, province) VALUES
    ('Thabo',    'Nkosi',    'thabo.nkosi@gmail.com',      'Gauteng'),
    ('Amahle',   'Dlamini',  'amahle.dlamini@outlook.com', 'KwaZulu-Natal'),
    ('Sipho',    'Mokoena',  'sipho.m@fintrust.co.za',    'Gauteng'),
    ('Zanele',   'Khumalo',  'zanele.k@gmail.com',        'Western Cape'),
    ('Bongani',  'Zulu',     'b.zulu@webmail.co.za',      'Eastern Cape');

-- ACCOUNTS: 5 rows (some customers have multiple accounts)
INSERT INTO accounts (customer_id, account_type, account_number, balance) VALUES
    (1, 'CHEQUE',   'FT-CHQ-000001', 15250.00),
    (1, 'SAVINGS',  'FT-SAV-000001', 42000.75),
    (2, 'CHEQUE',   'FT-CHQ-000002',  8900.50),
    (3, 'BUSINESS', 'FT-BUS-000001', 120000.00),
    (4, 'SAVINGS',  'FT-SAV-000002',  3250.25);

-- TRANSACTIONS: 5 rows referencing the accounts above
INSERT INTO transactions (account_id, transaction_type, amount, merchant_category) VALUES
    (1, 'DEBIT',   250.00,  'Groceries'),
    (1, 'DEBIT',   1500.00, 'Electronics'),
    (2, 'CREDIT',  5000.00, 'Salary'),
    (3, 'DEBIT',   89.99,   'Fuel'),
    (4, 'PAYMENT', 350.00,  'Utilities');

-- ═══════════════════════════════════════════════════════
-- VERIFICATION
-- ═══════════════════════════════════════════════════════

SELECT * FROM customers;
SELECT * FROM accounts;
SELECT * FROM transactions;

SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL
SELECT 'accounts',   COUNT(*) FROM accounts
UNION ALL
SELECT 'transactions', COUNT(*) FROM transactions;