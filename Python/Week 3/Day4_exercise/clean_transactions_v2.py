"""
clean_transactions_v2.py
Transaction pipeline with error handling and logging.
Week 3 - Day 4 exercise: FinTrust Cloud Portfolio
"""

import csv
import json
import logging
from datetime import datetime
from pathlib import Path

# ── Logging setup ──────────────────────────────────────────────────
LOG_DIR  = Path("logs")
DATA_DIR = Path("data")
LOG_DIR.mkdir(exist_ok=True)
DATA_DIR.mkdir(exist_ok=True)

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s  %(levelname)-8s  %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
    handlers=[
        logging.FileHandler(LOG_DIR / "pipeline.log"),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger("fintrust.pipeline")

# ── Config ─────────────────────────────────────────────────────────
RAW_INPUT    = DATA_DIR / "raw_transactions.csv"
CLEAN_CSV    = DATA_DIR / "clean_transactions.csv"
SUMMARY_JSON = DATA_DIR / "daily_summary.json"


def normalise_date(date_str):
    for fmt in ("%Y-%m-%d", "%d/%m/%y", "%d/%m/%Y", "%Y/%m/%d"):
        try:
            return datetime.strptime(date_str.strip(), fmt).strftime("%Y-%m-%d")
        except ValueError:
            continue
    logger.warning("Unrecognised date format: '%s' — returning as-is", date_str)
    return date_str.strip()


def clean_transaction(row, row_num):
    """Return cleaned transaction dict; raises ValueError on bad data."""
    try:
        return {
            "transaction_id": int(row["TxID"].strip()),
            "account_id":     int(row["AcctID"].strip()),
            "type":           row["TYPE"].strip().lower(),
            "amount":         float(row["Amount"].strip()),
            "date":           normalise_date(row["Date"]),
            "description":    row["Desc"].strip() or "No description",
        }
    except (KeyError, ValueError) as e:
        raise ValueError(f"Row {row_num}: {e}") from e


def main():
    logger.info("=== FinTrust Transaction Pipeline starting ===")
    logger.info("Input:  %s", RAW_INPUT)

    try:
        if not RAW_INPUT.exists():
            logger.critical("Input file not found: %s — aborting", RAW_INPUT)
            return
    except PermissionError:
        logger.critical("Permission denied checking input file: %s — aborting", RAW_INPUT)
        return

    transactions = []
    skipped = 0

    try:
        with open(RAW_INPUT, "r", newline="", encoding="utf-8") as fin:
            reader = csv.DictReader(fin)
            for row_num, row in enumerate(reader, start=2):  # 2 = first data row
                try:
                    tx = clean_transaction(row, row_num)
                    transactions.append(tx)
                    logger.debug("Processed row %d: tx_id=%s", row_num, tx["transaction_id"])
                except ValueError as e:
                    logger.warning("Skipped: %s", e)
                    skipped += 1
    except PermissionError:
        logger.error("Permission denied reading %s", RAW_INPUT)
        return
    except UnicodeDecodeError as e:
        logger.error("Encoding error in %s: %s", RAW_INPUT, e)
        return

    logger.info("Processed: %d rows, skipped: %d", len(transactions), skipped)

    # Write clean CSV
    try:
        fieldnames = ["transaction_id", "account_id", "type", "amount", "date", "description"]
        with open(CLEAN_CSV, "w", newline="", encoding="utf-8") as fout:
            writer = csv.DictWriter(fout, fieldnames=fieldnames)
            writer.writeheader()
            writer.writerows(transactions)
        logger.info("Clean CSV written: %s", CLEAN_CSV)
    except OSError as e:
        logger.error("Failed to write CSV: %s", e)

    # Write summary JSON
    try:
        deposits    = [t for t in transactions if t["type"] == "deposit"]
        withdrawals = [t for t in transactions if t["type"] == "withdrawal"]
        summary = {
            "run_timestamp":    datetime.now().isoformat(),
            "total":            len(transactions),
            "deposits":         len(deposits),
            "withdrawals":      len(withdrawals),
            "sum_deposits":     round(sum(t["amount"] for t in deposits), 2),
            "sum_withdrawals":  round(sum(t["amount"] for t in withdrawals), 2),
            "skipped_rows":     skipped,
        }
        with open(SUMMARY_JSON, "w", encoding="utf-8") as f:
            json.dump(summary, f, indent=2)
        logger.info("Summary JSON written: %s", SUMMARY_JSON)
        logger.info("=== Pipeline complete ===")
    except OSError as e:
        logger.error("Failed to write summary: %s", e)


if __name__ == "__main__":
    main()