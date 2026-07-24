-- ════════════════════════════════════════════════════════════
-- Challenge: Branches Table (Week 1 Day 3 bonus)
-- Design decisions:
--   - branch_id as PRIMARY KEY AUTO_INCREMENT: standard surrogate key,
--     consistent with the rest of the schema.
--   - branch_name, province, city all VARCHAR: text identifiers, never
--     compared mathematically, so no numeric type is appropriate.
--   - created_at DATETIME DEFAULT CURRENT_TIMESTAMP: automatic audit
--     trail matching the pattern used in customers/transactions.
--   - accounts.branch_id is NULLABLE: some accounts are opened online
--     with no physical branch, so NOT NULL would incorrectly force a
--     branch on every account.
--   - branches must be created BEFORE the ALTER TABLE, since a FOREIGN
--     KEY cannot reference a table that doesn't exist yet.
-- ════════════════════════════════════════════════════════════

USE fintrust_db;

CREATE TABLE branches (
    branch_id    INT           PRIMARY KEY AUTO_INCREMENT,
    branch_name  VARCHAR(150)  NOT NULL,
    province     VARCHAR(50)   NOT NULL,
    city         VARCHAR(100)  NOT NULL,
    created_at   DATETIME      DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE accounts
    ADD COLUMN branch_id INT NULL,
    ADD FOREIGN KEY (branch_id) REFERENCES branches(branch_id);

-- Insert 3 sample branches
INSERT INTO branches (branch_name, province, city) VALUES
    ('Sandton City Branch',   'Gauteng',       'Johannesburg'),
    ('Cape Town CBD Branch',  'Western Cape',  'Cape Town'),
    ('Durban Point Branch',   'KwaZulu-Natal', 'Durban');

-- Update 2 existing accounts to reference a branch
UPDATE accounts SET branch_id = 1 WHERE account_id = 1;  -- Thabo's cheque account -> Sandton
UPDATE accounts SET branch_id = 2 WHERE account_id = 4;  -- Sipho's business account -> Cape Town CBD

-- Verify
SELECT * FROM branches;
SELECT account_id, account_number, branch_id FROM accounts;