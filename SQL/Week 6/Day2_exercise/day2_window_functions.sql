-- Week 6 Day 2: SQL Window Functions
-- Ranking, running totals, and period-over-period comparison for FinTrust analytics

-- ═══════════════════════════════════════════════════════
-- Sample data setup (adjust table/column names to match your
-- actual FinTrust schema if you have a live `transactions` table)
-- ═══════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS transactions (
    transaction_id    INT PRIMARY KEY AUTO_INCREMENT,
    branch_code       VARCHAR(10),
    customer_id       INT,
    amount            DECIMAL(15,2),
    is_suspicious     BOOLEAN DEFAULT FALSE,
    transaction_date  DATE
);

-- Sample rows: 5 customers, 2 branches, June 2024 activity plus
-- Jan-Apr 2024 history for two customers (spike detection test data)
INSERT INTO transactions (branch_code, customer_id, amount, is_suspicious, transaction_date) VALUES
('JHB', 101, 15000, FALSE, '2024-06-05'),
('JHB', 101, 12000, FALSE, '2024-06-18'),
('JHB', 102,  3000, FALSE, '2024-06-10'),
('JHB', 103, 45000, TRUE,  '2024-06-02'),
('JHB', 103, 20000, TRUE,  '2024-06-20'),
('CPT', 201,  8000, FALSE, '2024-06-07'),
('CPT', 202, 50000, FALSE, '2024-06-15'),
('CPT', 202,  2000, TRUE,  '2024-06-25'),
('CPT', 203,  1000, FALSE, '2024-06-12'),
('JHB', 104,  5000, FALSE, '2024-01-15'),
('JHB', 104,  5200, FALSE, '2024-02-15'),
('JHB', 104,  4800, FALSE, '2024-03-15'),
('JHB', 104, 25000, FALSE, '2024-04-15'),  -- spike: 5.2x previous month
('CPT', 205,  2000, FALSE, '2024-02-10'),
('CPT', 205,  1800, FALSE, '2024-03-10'),
('CPT', 205,  3000, FALSE, '2024-04-10'); -- 1.67x — not a spike

-- ═══════════════════════════════════════════════════════
-- Challenge 1: Customer spend ranking within spend tier
-- Rank customers by June 2024 total spend, DENSE_RANK() within
-- their own tier (Premium/Standard/Basic), not overall
-- ═══════════════════════════════════════════════════════

WITH june_spend AS (
    SELECT customer_id, SUM(amount) AS total_spend
    FROM transactions
    WHERE transaction_date BETWEEN '2024-06-01' AND '2024-06-30'
    GROUP BY customer_id
),
tiered AS (
    SELECT
        customer_id,
        total_spend,
        CASE
            WHEN total_spend >= 20000 THEN 'Premium'
            WHEN total_spend >= 5000  THEN 'Standard'
            ELSE 'Basic'
        END AS spend_tier
    FROM june_spend
)
SELECT
    customer_id,
    total_spend,
    spend_tier,
    DENSE_RANK() OVER (PARTITION BY spend_tier ORDER BY total_spend DESC) AS rank_in_tier
FROM tiered
ORDER BY spend_tier, rank_in_tier;

-- ═══════════════════════════════════════════════════════
-- Challenge 2: Running fraud exposure per branch
-- Cumulative running total of suspicious transaction amounts,
-- ordered by date, alongside each individual flagged transaction
-- ═══════════════════════════════════════════════════════

SELECT
    branch_code,
    transaction_date,
    transaction_id,
    amount,
    SUM(amount) OVER (
        PARTITION BY branch_code
        ORDER BY transaction_date, transaction_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_fraud_total
FROM transactions
WHERE is_suspicious = TRUE
ORDER BY branch_code, transaction_date;

-- ═══════════════════════════════════════════════════════
-- Challenge 3: Detect spending spikes (H1 2024)
-- Spike = current month spend > 3x previous month spend
-- ═══════════════════════════════════════════════════════

WITH monthly AS (
    SELECT
        customer_id,
        DATE_FORMAT(transaction_date, '%Y-%m') AS month,
        SUM(amount) AS month_total
    FROM transactions
    WHERE transaction_date BETWEEN '2024-01-01' AND '2024-06-30'
    GROUP BY customer_id, DATE_FORMAT(transaction_date, '%Y-%m')
),
with_prev AS (
    SELECT
        customer_id,
        month,
        month_total,
        LAG(month_total) OVER (PARTITION BY customer_id ORDER BY month) AS prev_month_total
    FROM monthly
)
SELECT customer_id, month AS spike_month, month_total, prev_month_total
FROM with_prev
WHERE prev_month_total IS NOT NULL
  AND month_total > 3 * prev_month_total
ORDER BY customer_id, spike_month;

-- ═══════════════════════════════════════════════════════
-- Reflection: When would you use a window function instead of
-- GROUP BY with a self-join?
--
-- When you need the individual row detail AND a summary value
-- in the same result set at the same time -- e.g. showing every
-- flagged transaction next to its branch's running fraud total,
-- rather than collapsing rows down to one summary row per branch
-- the way GROUP BY would.
-- ═══════════════════════════════════════════════════════