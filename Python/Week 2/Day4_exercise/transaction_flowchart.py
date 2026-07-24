# transaction_flowchart.py
# FinTrust Bank — Automated Transaction Decision Engine
# Week 2 Day 4 — Cloud to Solutions Accelerator

BLOCKED_COUNTRIES = ["KP", "IR", "CU", "SY", "SD"]
DAILY_LIMIT = 50000
ATM_LIMIT = 5000
LARGE_THRESHOLD = 10000
REVIEW_THRESHOLD = 5000


def assess_transaction(tx_id, customer, amount, destination, is_trusted_device):
    """
    Evaluate a FinTrust Bank transaction and return a decision.
    """
    if destination.upper() in BLOCKED_COUNTRIES:
        return {
            "tx_id": tx_id,
            "customer": customer,
            "status": "BLOCKED",
            "reason": f"Transfer to {destination} is not permitted"
        }

    if amount > DAILY_LIMIT:
        return {
            "tx_id": tx_id,
            "customer": customer,
            "status": "BLOCKED",
            "reason": f"Amount exceeds daily limit of R{DAILY_LIMIT:,.0f}"
        }

    if amount <= 0:
        return {
            "tx_id": tx_id,
            "customer": customer,
            "status": "BLOCKED",
            "reason": "Invalid transaction amount"
        }

    if amount > LARGE_THRESHOLD:
        if is_trusted_device:
            return {
                "tx_id": tx_id,
                "customer": customer,
                "status": "PENDING",
                "reason": "Large transfer — OTP verification required"
            }
        else:
            return {
                "tx_id": tx_id,
                "customer": customer,
                "status": "REVIEW",
                "reason": "Large transfer from unrecognised device"
            }

    if amount > REVIEW_THRESHOLD and not is_trusted_device:
        return {
            "tx_id": tx_id,
            "customer": customer,
            "status": "REVIEW",
            "reason": "Moderate amount from unrecognised device"
        }

    return {
        "tx_id": tx_id,
        "customer": customer,
        "status": "APPROVED",
        "reason": "All checks passed"
    }


test_cases = [
    ("TX001", "Thabo Nkosi",    500.00,   "ZA", True),
    ("TX002", "Amahle Dlamini", 15000.00, "ZA", True),
    ("TX003", "Sipho Mokoena",  8000.00,  "ZA", False),
    ("TX004", "Lerato Sithole", 200.00,   "IR", True),
    ("TX005", "Nomvula Dube",   75000.00, "ZA", True),
]

print("=" * 65)
print(f"{'TX ID':<8} {'Customer':<18} {'Status':<10} Reason")
print("=" * 65)

for tc in test_cases:
    result = assess_transaction(*tc)
    print(f"{result['tx_id']:<8} {result['customer']:<18} {result['status']:<10} {result['reason']}")