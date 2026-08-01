"""
FinTrust Bank — Nightly Transaction Pipeline (packaged version)
Week 4 Day 4 PM — refactored from Day 3's single-file pipeline.py into a
proper Python package (fintrust_pipeline/) with separated concerns:
loader.py (read + validate), database.py (SQLite persistence),
reporter.py (query + formatted report).
"""

from pathlib import Path
from fintrust_pipeline.loader import load_csv
from fintrust_pipeline.database import setup_database, insert_transactions
from fintrust_pipeline.reporter import generate_report

CSV_FILE    = Path("transactions.csv")
DB_FILE     = Path("fintrust_analytics.db")
REPORT_FILE = Path("daily_report.txt")

if __name__ == "__main__":
    valid_rows, invalid_rows = load_csv(CSV_FILE)
    print(f"Valid: {len(valid_rows)}  Invalid: {len(invalid_rows)}")
    for entry in invalid_rows:
        print(f"  {entry['row']['transaction_id']}: {entry['reason']}")

    conn = setup_database(DB_FILE)
    inserted, skipped = insert_transactions(conn, valid_rows)
    print(f"Inserted: {inserted}  Skipped: {skipped}")

    report = generate_report(conn, REPORT_FILE)
    print(report)
    conn.close()