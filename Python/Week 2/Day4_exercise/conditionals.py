"""
conditionals.py
Week 2 Day 4: Python if/elif/else, Boolean logic, and the 'in' keyword.
FinTrust Cloud Portfolio.
"""


def classify_transaction(amount):
    """Classify a transaction amount into a size bracket."""
    if 0 < amount <= 100:
        return "MICRO"
    elif 100 < amount <= 1000:
        return "SMALL"
    elif 1000 < amount <= 10000:
        return "STANDARD"
    elif amount > 10000:
        return "LARGE"
    else:
        return "INVALID"


def get_interest_rate(credit_score):
    """Return the interest rate tier based on credit score."""
    if credit_score >= 750:
        return 7.5
    elif 700 <= credit_score < 750:
        return 9.5
    elif 650 <= credit_score < 700:
        return 12.0
    else:
        return 18.5


def atm_withdraw(balance, amount):
    """Return (success: bool, message: str) for an ATM withdrawal request."""
    if amount <= 0:
        return (False, "Invalid amount")
    if amount > 5000:
        return (False, "ATM daily limit is R5 000")
    if amount > balance:
        return (False, "Insufficient funds")
    return (True, f"Dispensing R{amount:.2f}")


def tag_transaction(tx_type, merchant_category, amount):
    """Return a classification tag for a transaction."""
    if tx_type == "REFUND":
        return "REFUND"
    if merchant_category == "GAMBLING":
        return "HIGH_RISK"
    if merchant_category == "GROCERY" and amount < 500:
        return "ROUTINE"
    if amount > 10000:
        return "LARGE_PURCHASE"
    return "STANDARD"


if __name__ == "__main__":
    print("=== Exercise 1: classify_transaction ===")
    print(classify_transaction(50))     # MICRO
    print(classify_transaction(9999))   # STANDARD
    print(classify_transaction(-5))     # INVALID
    print(classify_transaction(100))    # MICRO (boundary)
    print(classify_transaction(15000))  # LARGE
    print()

    print("=== Exercise 2: get_interest_rate ===")
    print(get_interest_rate(720))  # 9.5
    print(get_interest_rate(800))  # 7.5
    print(get_interest_rate(680))  # 12.0
    print(get_interest_rate(600))  # 18.5
    print()

    print("=== Exercise 3: atm_withdraw ===")
    print(atm_withdraw(3000, 1500))  # (True, "Dispensing R1500.00")
    print(atm_withdraw(500, 600))    # (False, "Insufficient funds")
    print(atm_withdraw(3000, 6000))  # (False, "ATM daily limit is R5 000")
    print(atm_withdraw(3000, 0))     # (False, "Invalid amount")
    print()

    print("=== Exercise 4: tag_transaction ===")
    print(tag_transaction("REFUND", "ELECTRONICS", 200))     # REFUND
    print(tag_transaction("DEBIT", "GAMBLING", 100))          # HIGH_RISK
    print(tag_transaction("DEBIT", "GROCERY", 250))           # ROUTINE
    print(tag_transaction("DEBIT", "ELECTRONICS", 15000))     # LARGE_PURCHASE
    print(tag_transaction("DEBIT", "FUEL", 300))              # STANDARD