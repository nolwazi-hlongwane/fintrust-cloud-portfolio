"""
day3_exercises.py
Week 2 Day 3: Python fundamentals — variables, data types, string methods,
type conversion. FinTrust Cloud Portfolio.
"""

from decimal import Decimal


# ═══════════════════════════════════════════════════════
# Exercise 1: Account Formatter
# ═══════════════════════════════════════════════════════

def format_account_summary(customer_name, account_type, balance):
    """Return a formatted multi-line account summary string."""
    d_balance = Decimal(str(balance))
    return (
        f"Customer: {customer_name.title()}\n"
        f"Account:  {account_type.upper()}\n"
        f"Balance:  R {d_balance:,.2f}\n"
        f"Status:   ACTIVE"
    )


# ═══════════════════════════════════════════════════════
# Exercise 2: Compound Interest
# ═══════════════════════════════════════════════════════

def calculate_compound_interest(principal, annual_rate, years, n=12):
    """
    Calculate compound interest. A = P(1 + r/n)^(nt)

    principal: initial amount (Decimal or numeric)
    annual_rate: e.g. 0.085 for 8.5%
    years: number of years
    n: compounding periods per year (default 12 = monthly)

    Returns (final_amount, interest_earned) as Decimal.
    """
    p = float(principal)
    amount = p * (1 + annual_rate / n) ** (n * years)
    interest_earned = amount - p
    return Decimal(str(round(amount, 2))), Decimal(str(round(interest_earned, 2)))


# ═══════════════════════════════════════════════════════
# Exercise 3: List Operations
# ═══════════════════════════════════════════════════════

transactions = [
    Decimal("250.00"), Decimal("12500.00"), Decimal("750.50"),
    Decimal("88000.00"), Decimal("1200.00"), Decimal("3450.00"),
    Decimal("55000.00"), Decimal("125.00"), Decimal("9800.00")
]

total = sum(transactions)
average = total / len(transactions)
largest = max(transactions)
smallest = min(transactions)
count_above_5000 = sum(1 for t in transactions if t > Decimal("5000.00"))


# ═══════════════════════════════════════════════════════
# Run all exercises and print results
# ═══════════════════════════════════════════════════════

if __name__ == "__main__":
    print("=== Exercise 1: Account Formatter ===")
    print(format_account_summary("thabo nkosi", "savings", 52750.00))
    print()

    print("=== Exercise 2: Compound Interest ===")
    principal = Decimal("50000.00")
    amount, interest = calculate_compound_interest(principal, 0.085, 3)
    print(f"After 3 years: R {amount:,.2f} (interest earned: R {interest:,.2f})")
    print()

    print("=== Exercise 3: List Operations ===")
    print(f"Total:              R {total:,.2f}")
    print(f"Average:            R {average:,.2f}")
    print(f"Largest:            R {largest:,.2f}")
    print(f"Smallest:           R {smallest:,.2f}")
    print(f"Count above R5,000: {count_above_5000}")