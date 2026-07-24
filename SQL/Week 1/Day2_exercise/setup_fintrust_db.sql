-- Create and select the FinTrust database
CREATE DATABASE IF NOT EXISTS fintrust;
USE fintrust;

-- Customers table
CREATE TABLE IF NOT EXISTS customers (
  customer_id  INT           PRIMARY KEY AUTO_INCREMENT,
  first_name   VARCHAR(100) NOT NULL,
  last_name    VARCHAR(100) NOT NULL,
  id_number    VARCHAR(13)  UNIQUE,
  email        VARCHAR(200) UNIQUE NOT NULL,
  phone        VARCHAR(20),
  province     VARCHAR(50),
  created_at   DATETIME     DEFAULT CURRENT_TIMESTAMP
);

-- Accounts table
CREATE TABLE IF NOT EXISTS accounts (
  account_id     INT             PRIMARY KEY AUTO_INCREMENT,
  customer_id    INT             NOT NULL,
  account_type   ENUM('CHEQUE','SAVINGS','CREDIT','BUSINESS') NOT NULL,
  account_number VARCHAR(20)    UNIQUE NOT NULL,
  balance        DECIMAL(15,2) DEFAULT 0.00,
  status         ENUM('ACTIVE','SUSPENDED','CLOSED') DEFAULT 'ACTIVE',
  opened_date    DATE            NOT NULL,
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Transactions table
CREATE TABLE IF NOT EXISTS transactions (
  transaction_id   INT             PRIMARY KEY AUTO_INCREMENT,
  account_id       INT             NOT NULL,
  transaction_type ENUM('DEBIT','CREDIT','TRANSFER','PAYMENT') NOT NULL,
  amount           DECIMAL(15,2) NOT NULL,
  description      VARCHAR(500),
  merchant_category VARCHAR(100),
  transaction_date DATETIME        DEFAULT CURRENT_TIMESTAMP,
  reference_no     VARCHAR(50),
  FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

-- Sample data
INSERT INTO customers
  (first_name, last_name, id_number, email, phone, province)
VALUES
  ('Thabo',    'Nkosi',    '9001015800080', 'thabo.nkosi@fintrust.co.za',    '0821234567', 'Gauteng'),
  ('Amahle',   'Dlamini',  '9503225012086', 'amahle.dlamini@gmail.com',       '0839876543', 'KwaZulu-Natal'),
  ('Sipho',    'Mokoena',  '8812181500089', 'sipho.mokoena@outlook.com',      '0765551234', 'Gauteng'),
  ('Lerato',   'Sithole',  '9207130660084', 'lerato.sithole@fintrust.co.za',  '0611112222', 'Western Cape'),
  ('Nomsa',    'Zulu',     '9508284800087', 'nomsa.zulu@gmail.com',           '0723334444', 'Eastern Cape'),
  ('Pieter',   'van Wyk',  '8406125100082', 'pieter.vw@gmail.com',            '0825556666', 'Western Cape'),
  ('Zanele',   'Khumalo',  '9911295600083', 'zanele.khumalo@yahoo.com',       '0787778888', 'Gauteng'),
  ('Fatima',   'Moosa',    '0002041200085', 'fatima.moosa@gmail.com',         '0849990000', 'KwaZulu-Natal'),
  ('Lungelo',  'Ndlovu',   '9704281800081', 'lungelo.ndlovu@outlook.com',     '0611223344', 'Mpumalanga'),
  ('Cleo',     'Petersen', '0105150400086', 'cleo.petersen@gmail.com',        '0824455667', 'Western Cape');

INSERT INTO accounts
  (customer_id, account_type, account_number, balance, status, opened_date)
VALUES
  (1, 'CHEQUE',  'FT-CHQ-0000001', 12540.50,  'ACTIVE', '2020-03-15'),
  (1, 'SAVINGS', 'FT-SAV-0000001', 45000.00,  'ACTIVE', '2020-03-15'),
  (2, 'CHEQUE',  'FT-CHQ-0000002', 3200.75,   'ACTIVE', '2021-07-01'),
  (3, 'CHEQUE',  'FT-CHQ-0000003', 8750.00,   'ACTIVE', '2019-11-20'),
  (3, 'CREDIT',  'FT-CRD-0000001', -2100.00,  'ACTIVE', '2022-01-10'),
  (4, 'SAVINGS', 'FT-SAV-0000002', 120000.00, 'ACTIVE', '2018-05-30'),
  (5, 'CHEQUE',  'FT-CHQ-0000004', 550.25,    'SUSPENDED', '2023-02-14'),
  (6, 'BUSINESS','FT-BIZ-0000001', 340000.00, 'ACTIVE', '2017-08-01'),
  (7, 'CHEQUE',  'FT-CHQ-0000005', 4320.00,   'ACTIVE', '2022-09-22'),
  (8, 'SAVINGS', 'FT-SAV-0000003', 22100.00,  'ACTIVE', '2021-04-05');

INSERT INTO transactions
  (account_id, transaction_type, amount, description, merchant_category, transaction_date, reference_no)
VALUES
  (1, 'DEBIT',  450.00,   'Woolworths Food JHB',           'Groceries',     '2024-06-01 09:15:00', 'TXN-001'),
  (1, 'DEBIT',  1200.00,  'Cape Union Mart Online',        'Retail',        '2024-06-02 14:30:00', 'TXN-002'),
  (1, 'CREDIT', 25000.00, 'Salary - Praesignis',           'Income',        '2024-06-25 00:01:00', 'TXN-003'),
  (2, 'CREDIT', 5000.00,  'Transfer from Savings',         'Transfer',      '2024-06-03 10:00:00', 'TXN-004'),
  (3, 'DEBIT',  800.00,   'Takealot.com',                  'Online Shopping','2024-06-04 16:45:00', 'TXN-005'),
  (3, 'DEBIT',  320.50,   'Engen Petrol JHB South',        'Fuel',          '2024-06-05 07:20:00', 'TXN-006'),
  (4, 'DEBIT',  2500.00,  'Monthly Debit Order - Insurance','Insurance',     '2024-06-01 00:05:00', 'TXN-007'),
  (6, 'CREDIT', 85000.00, 'Client Invoice Payment',         'Business Income','2024-06-10 11:30:00', 'TXN-008'),
  (8, 'DEBIT',  150.00,   'Netflix Subscription',          'Streaming',     '2024-06-15 00:00:00', 'TXN-009'),
  (9, 'DEBIT',  600.00,   'Dischem Pharmacy',              'Healthcare',    '2024-06-18 14:00:00', 'TXN-010');