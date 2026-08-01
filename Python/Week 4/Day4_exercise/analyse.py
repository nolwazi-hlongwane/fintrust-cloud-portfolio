"""
analyse.py
Week 4 Day 4 PM — pandas analysis of the FinTrust transaction database.
"""

import sqlite3
import pandas as pd
from pathlib import Path

DB_FILE = Path("fintrust_analytics.db")

conn = sqlite3.connect(DB_FILE)
df = pd.read_sql_query("SELECT * FROM transactions", conn)
conn.close()

print("=== DataFrame Shape ===")
print(f"Rows: {len(df)}  Columns: {len(df.columns)}")
print()
print("=== Column Types ===")
print(df.dtypes)
print()
print("=== First 3 Rows ===")
print(df.head(3))

completed_transfers = df[
    (df["status"] == "COMPLETED") & (df["type"] == "TRANSFER")
]
print(f"\nCompleted transfers: {len(completed_transfers)}")
print(f"Total volume: ZAR {completed_transfers['amount'].sum():,.2f}")

avg = df["amount"].mean()
large = df[df["amount"] > avg]
print(f"\nAbove-average transactions (>{avg:,.2f}):")
print(large[["transaction_id", "amount", "type", "status"]])

by_status = df.groupby("status").agg(
    count=("transaction_id", "count"),
    total_volume=("amount", "sum"),
    avg_amount=("amount", "mean")
).round(2)
print("\n=== By Status ===")
print(by_status)

by_type = df.groupby("type")["amount"].sum().sort_values(ascending=False)
print("\n=== Volume by Type ===")
print(by_type)

by_type_status = df.groupby(["type", "status"]).agg(
    count=("transaction_id", "count"),
    total_volume=("amount", "sum")
).round(2)
print("\n=== Cross-tab: Type x Status ===")
print(by_type_status)

df["high_value"] = df["amount"] > 2000
df["txn_date"] = pd.to_datetime(df["timestamp"]).dt.date

print("\n=== DataFrame with New Columns ===")
print(df[["transaction_id", "amount", "high_value", "txn_date"]].to_string())

df.to_csv("transactions_enriched.csv", index=False)
print("\nExported to transactions_enriched.csv")