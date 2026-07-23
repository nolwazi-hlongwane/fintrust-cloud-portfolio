"""
parse_aws_billing.py
Demo: Read an AWS Cost Explorer CSV export and summarise costs by service.
"""

import csv
from collections import defaultdict
from pathlib import Path

BILLING_CSV = Path("data/aws_billing_export.csv")

def summarise_by_service(filepath):
    """Return dict of {service_name: total_cost} from AWS billing CSV."""
    service_costs = defaultdict(float)

    with open(filepath, "r", newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            service = row.get("Service", "Unknown")
            try:
                cost = float(row.get("Cost", 0))
                service_costs[service] += cost
            except ValueError:
                pass   # Skip rows with non-numeric cost

    # Sort by cost descending
    return dict(sorted(service_costs.items(), key=lambda x: x[1], reverse=True))

def print_cost_report(service_costs, currency="USD"):
    """Print a formatted cost breakdown."""
    total = sum(service_costs.values())
    print(f"\nAWS Cost Breakdown — Total: {currency} {total:,.2f}")
    print("-" * 50)
    for service, cost in service_costs.items():
        pct = (cost / total * 100) if total > 0 else 0
        bar = "█" * int(pct / 2)
        print(f"  {service:<35} {currency} {cost:>8.2f}  {pct:4.1f}% {bar}")

if __name__ == "__main__":
    if not BILLING_CSV.exists():
        print("No billing CSV found — create a sample file first")
    else:
        costs = summarise_by_service(BILLING_CSV)
        print_cost_report(costs)