# Week 2 — Compute Services, SQL JOINs & Python Fundamentals

## What I Built
- SQL JOIN queries connecting `customers` → `accounts` → `transactions` using INNER JOIN, LEFT JOIN, and the LEFT JOIN + IS NULL anti-join pattern
- Aggregate analytics queries using `COUNT`, `SUM`, `AVG`, `GROUP BY`, and `HAVING`
- First Python scripts: data types, `Decimal` for currency, string methods, functions, and list operations
- A working FinTrust fraud-style transaction decision engine using `if`/`elif`/`else`, Boolean logic, and the `in` operator

## Key Concepts Demonstrated
- **SQL JOINs:** table aliases, the difference between INNER JOIN (matches only) and LEFT JOIN (all left rows + NULLs), chaining a 3-table JOIN, and using LEFT JOIN + `IS NULL` to find "gaps" (e.g. customers with no transactions)
- **SQL Aggregates:** the GROUP BY rule (every non-aggregated SELECT column must appear in GROUP BY), WHERE vs HAVING (WHERE filters rows before grouping, HAVING filters the aggregated groups after)
- **Python fundamentals:** `Decimal` instead of `float` for money, f-strings for formatting, string methods (`.strip()`, `.title()`, `.upper()`), type conversion pitfalls with `input()`
- **Python conditionals:** `if`/`elif`/`else` order (most specific condition first), chained comparisons (`0 < amount <= 100`), the `in` operator for membership testing, the early-return pattern for hard blocks in a decision engine
- **Compute services (AWS):** when to use EC2 vs Lambda vs ECS Fargate vs Elastic Beanstalk vs AWS Batch, and EBS/EFS/FSx storage selection — conceptual, no code artifact

## How to Run
```bash
# SQL — open in MySQL Workbench and run against fintrust_db
# Python
python3 "Python/Week 2/Day3_exercise/day3_exercises.py"
python3 "Python/Week 2/Day4_exercise/conditionals.py"
python3 "Python/Week 2/Day4_exercise/transaction_flowchart.py"
```

## Files
| File | Description |
|------|-------------|
| `SQL/Week 2/Day1_exercise/day1_joins.sql` | INNER JOIN, LEFT JOIN, 3-table JOIN, anti-join pattern |
| `SQL/Week 2/Day2_exercise/day2_aggregates.sql` | COUNT/SUM/AVG, GROUP BY, HAVING |
| `Python/Week 2/Day3_exercise/day3_exercises.py` | Account formatter, compound interest, list statistics |
| `Python/Week 2/Day4_exercise/conditionals.py` | Transaction classifier, interest rate calculator, ATM logic, transaction tagger |
| `Python/Week 2/Day4_exercise/transaction_flowchart.py` | Full FinTrust transaction decision engine (APPROVED/PENDING/REVIEW/BLOCKED) |

## Reflection
JOINs were the big unlock this week. Once I had the two-spreadsheet mental model — lay them side by side, draw a line where keys match — INNER JOIN and LEFT JOIN stopped feeling like syntax to memorise and started feeling like a question I was asking the data. The LEFT JOIN + IS NULL anti-join pattern especially clicked once I saw it answer a real question: "which customers have never made a transaction?" On the Python side, building the transaction decision engine was satisfying because the early-return pattern made the logic easy to trace — hard blocks first, then softer checks depending on device trust. I also hit a real Git/GitHub setup problem this week (folder typos, an empty repo connection, a .gitignore silently excluding my log file) and working through each error one at a time taught me more about how Git actually works than any tutorial would have. Next thing I want to get more comfortable with is combining JOIN and GROUP BY in the same query without second-guessing the column list in GROUP BY.