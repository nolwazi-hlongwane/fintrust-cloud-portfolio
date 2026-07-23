"""
clean_transactions.py
Reads raw FinTrust transaction CSV, cleans it, outputs clean CSV + JSON summary.
"""

import csv
import json
from pathlib import Path
from datetime import datetime

RAW_INPUT  = Path("data/raw_transactions.csv")
CLEAN_CSV  = Path("data/clean_transactions.csv")
SUMMARY_JSON = Path("data/daily_summary.json")


def normalise_date(date_str):
    """Try multiple date formats and return ISO 8601 YYYY-MM-DD string."""
    for fmt in ("%Y-%m-%d", "%Y-%-m-%d", "%d/%m/%y", "%d/%m/%Y"):
        try:
            return datetime.strptime(date_str.strip(), fmt).strftime("%Y-%m-%d")
        except ValueError:
            continue
    return date_str.strip()   # Return as-is if no format matched


def clean_transaction(row):
    """Return a cleaned, normalised transaction dict from a raw CSV row."""
    return {
        "transaction_id": int(row["TxID"].strip()),
        "account_id":     int(row["AcctID"].strip()),
        "type":           row["TYPE"].strip().lower(),
        "amount":         float(row["Amount"].strip()),
        "date":           normalise_date(row["Date"]),
        "description":    row["Desc"].strip() or "No description",
    }


def build_summary(transactions):
    """Return a summary dict of totals and counts."""
    deposits     = [t for t in transactions if t["type"] == "deposit"]
    withdrawals  = [t for t in transactions if t["type"] == "withdrawal"]
    return {
        "total_transactions": len(transactions),
        "total_deposits":     len(deposits),
        "total_withdrawals":  len(withdrawals),
        "sum_deposits":       round(sum(t["amount"] for t in deposits), 2),
        "sum_withdrawals":    round(sum(t["amount"] for t in withdrawals), 2),
    }


def main():
    transactions = []

    with open(RAW_INPUT, "r", newline="", encoding="utf-8") as fin:
        reader = csv.DictReader(fin)
        for row in reader:
            try:
                transactions.append(clean_transaction(row))
            except (ValueError, KeyError) as e:
                print(f"  Skipped row {row}: {e}")

    # Write clean CSV
    CLEAN_CSV.parent.mkdir(parents=True, exist_ok=True)
    fieldnames = ["transaction_id", "account_id", "type", "amount", "date", "description"]
    with open(CLEAN_CSV, "w", newline="", encoding="utf-8") as fout:
        writer = csv.DictWriter(fout, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(transactions)
    print(f"Clean CSV: {CLEAN_CSV} ({len(transactions)} rows)")

    # Write JSON summary
    summary = build_summary(transactions)
    with open(SUMMARY_JSON, "w", encoding="utf-8") as f:
        json.dump(summary, f, indent=2)
    print(f"Summary JSON: {SUMMARY_JSON}")
    print(json.dumps(summary, indent=2))


if __name__ == "__main__":
    main()