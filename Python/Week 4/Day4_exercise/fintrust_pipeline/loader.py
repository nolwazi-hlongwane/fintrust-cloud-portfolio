"""fintrust_pipeline.loader — CSV reading and row validation."""
import csv
from pathlib import Path

VALID_TYPES    = {"TRANSFER", "DEPOSIT", "WITHDRAWAL"}
VALID_STATUSES = {"COMPLETED", "FAILED", "PENDING"}


def validate_row(row):
    """Return (True, None) if valid, (False, reason) if invalid."""
    if not row["account_from"].strip():
        return False, "missing account_from"

    try:
        amount = float(row["amount"])
    except (ValueError, TypeError):
        return False, f"invalid amount: {row['amount']!r}"

    if amount <= 0:
        return False, f"amount must be positive, got {amount}"

    if row["type"] not in VALID_TYPES:
        return False, f"unknown type: {row['type']!r}"

    if row["status"] not in VALID_STATUSES:
        return False, f"unknown status: {row['status']!r}"

    return True, None


def load_csv(filepath: Path):
    """Read the CSV and return (valid_rows, invalid_rows)."""
    valid = []
    invalid = []
    with open(filepath, newline="", encoding="utf-8") as f:
        for row in csv.DictReader(f):
            ok, reason = validate_row(row)
            if ok:
                valid.append(row)
            else:
                invalid.append({"row": row, "reason": reason})
    return valid, invalid