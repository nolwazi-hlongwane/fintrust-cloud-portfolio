# Week 1 — Cloud Foundations & SQL Basics

## What I Built
- Installed and configured MySQL Server + MySQL Workbench on macOS (Apple Silicon)
- Created and populated the FinTrust sample database (`fintrust`) with customers, accounts, and transactions
- Built a second, more rigorous FinTrust schema (`fintrust_db`) with full constraints — PRIMARY KEY, FOREIGN KEY, ENUM, DECIMAL(15,2) for money
- Added a bonus `branches` table via `ALTER TABLE`, linking accounts to physical branches
- Wrote WHERE-clause queries covering every major operator: `=`, `>`, `LIKE`, `IN`, `BETWEEN`, `IS NULL`, `AND`/`OR`
- Wrote a 5-query analytics lab simulating real FinTrust business requests (marketing, risk, fraud, product teams)
- Wrote 5 challenge queries applying WHERE logic to realistic banking questions

## Key Concepts Demonstrated
- Relational database fundamentals: tables, primary keys, foreign keys, one-to-many relationships
- Why `DECIMAL(15,2)` is used for money instead of `FLOAT` (binary rounding errors)
- Why `ENUM` is used for fixed-value columns like `account_type`
- The WHERE clause: comparison operators, pattern matching with `LIKE`, `IN`/`NOT IN`, `BETWEEN`, `IS NULL`/`IS NOT NULL`
- Combining conditions with `AND`/`OR`/`NOT`, and why parentheses matter for operator precedence
- Verifying schema and data with `SHOW TABLES`, `DESCRIBE`, and `SELECT COUNT(*)`

## Files
| File | Description |
|------|-------------|
| `SQL/Week 1/Day2_exercise/setup_fintrust_db.sql` | Initial FinTrust schema + sample data (`fintrust` database) |
| `SQL/Week 1/Day2_exercise/day2_basic_select.sql` | First SELECT queries — aliases, calculated columns, LIMIT, DISTINCT |
| `SQL/Week 1/Day3_exercise/day3_fintrust_schema.sql` | Full constrained schema with FOREIGN KEYs (`fintrust_db` database) |
| `SQL/Week 1/Day3_exercise/day3_challenge_branches.sql` | Bonus: branches table + ALTER TABLE to link accounts to branches |
| `SQL/Week 1/Day4_exercise/day4_where_exercises.sql` | Self-paced WHERE clause practice (6 exercises) |
| `SQL/Week 1/Day4_exercise/day4_where_queries.sql` | 5-query analytics lab for the FinTrust business teams |
| `SQL/Week 1/Day4_exercise/day4_where_challenges.sql` | 5 challenge queries from the Day 4 Practical Guide |

## Reflection
The MySQL install and Workbench setup took longer than I expected — between picking the right ARM build for my device, setting the root password, and getting past the version compatibility warning, there was more troubleshooting than actual SQL. Once I was in, though, writing the schema and seeing the FOREIGN KEY constraints actually reject bad data made the "why" behind referential integrity click in a way that just reading about it never did. The WHERE clause work felt the most natural of the week — going from a single condition to combining AND/OR with parentheses made sense quickly. What I want to revisit is HAVING vs WHERE; I understand the rule (WHERE filters rows, HAVING filters groups) but I want more reps recognising which one a business question actually calls for before I'm fully confident.