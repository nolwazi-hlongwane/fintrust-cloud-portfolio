"""fintrust_pipeline.reporter — query the DB and build the daily report."""
from datetime import datetime


def generate_report(conn, report_path):
    """Query the DB and write a formatted daily report."""
    lines = []
    lines.append("=" * 60)
    lines.append("FINTRUST DAILY TRANSACTION REPORT")
    lines.append(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    lines.append("=" * 60)

    row = conn.execute("""
        SELECT
            COUNT(*)              AS total_count,
            ROUND(SUM(amount), 2) AS total_volume,
            ROUND(AVG(amount), 2) AS avg_amount,
            ROUND(MIN(amount), 2) AS min_amount,
            ROUND(MAX(amount), 2) AS max_amount
        FROM transactions
    """).fetchone()

    lines.append("\n-- SUMMARY --------------------------------------------")
    lines.append(f"  Total transactions : {row['total_count']}")
    lines.append(f"  Total volume       : ZAR {row['total_volume']:,.2f}")
    lines.append(f"  Average amount     : ZAR {row['avg_amount']:,.2f}")
    lines.append(f"  Min / Max          : ZAR {row['min_amount']:,.2f} / ZAR {row['max_amount']:,.2f}")

    lines.append("\n-- BREAKDOWN BY TYPE ------------------------------------")
    rows = conn.execute("""
        SELECT type, COUNT(*) AS cnt, ROUND(SUM(amount), 2) AS volume
        FROM transactions GROUP BY type ORDER BY volume DESC
    """).fetchall()
    for r in rows:
        lines.append(f"  {r['type']:<12}  {r['cnt']:>3} txns   ZAR {r['volume']:>10,.2f}")

    lines.append("\n-- BREAKDOWN BY STATUS ----------------------------------")
    rows = conn.execute("""
        SELECT status, COUNT(*) AS cnt, ROUND(SUM(amount), 2) AS volume
        FROM transactions GROUP BY status ORDER BY cnt DESC
    """).fetchall()
    for r in rows:
        lines.append(f"  {r['status']:<12}  {r['cnt']:>3} txns   ZAR {r['volume']:>10,.2f}")

    lines.append("\n-- TOP 3 LARGEST TRANSACTIONS ---------------------------")
    rows = conn.execute("""
        SELECT transaction_id, account_from, amount, type, status
        FROM transactions ORDER BY amount DESC LIMIT 3
    """).fetchall()
    for i, r in enumerate(rows, 1):
        lines.append(f"  #{i}  {r['transaction_id']}  {r['account_from']}  ZAR {r['amount']:,.2f}  [{r['type']} / {r['status']}]")

    lines.append("\n" + "=" * 60)
    report_text = "\n".join(lines)
    report_path.write_text(report_text, encoding="utf-8")
    return report_text