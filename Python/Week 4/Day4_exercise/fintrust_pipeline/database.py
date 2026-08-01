"""fintrust_pipeline.database — SQLite setup and inserts."""
import sqlite3
from datetime import datetime
from pathlib import Path


def setup_database(db_path: Path):
    """Create the transactions table if it doesn't exist. Return a connection."""
    conn = sqlite3.connect(db_path)
    conn.row_factory = sqlite3.Row  # allows dict-style access: row["amount"]
    conn.execute("""
        CREATE TABLE IF NOT EXISTS transactions (
            transaction_id TEXT PRIMARY KEY,
            account_from   TEXT NOT NULL,
            account_to     TEXT,
            amount         REAL NOT NULL,
            currency       TEXT NOT NULL,
            type           TEXT NOT NULL,
            status         TEXT NOT NULL,
            timestamp      TEXT,
            loaded_at      TEXT NOT NULL
        )
    """)
    conn.commit()
    return conn


def insert_transactions(conn, valid_rows):
    """Insert valid rows. Skip rows already in the database (duplicate IDs)."""
    loaded_at = datetime.now().isoformat(timespec="seconds")
    inserted = skipped = 0
    for row in valid_rows:
        try:
            conn.execute(
                "INSERT INTO transactions VALUES (?,?,?,?,?,?,?,?,?)",
                (row["transaction_id"], row["account_from"],
                 row["account_to"] or None, float(row["amount"]),
                 row["currency"], row["type"], row["status"],
                 row["timestamp"], loaded_at)
            )
            inserted += 1
        except sqlite3.IntegrityError:
            skipped += 1
    conn.commit()
    return inserted, skipped