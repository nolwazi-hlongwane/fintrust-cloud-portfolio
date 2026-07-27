# Week 4 — Databases & Production-Grade Python Error Handling

## What I Built
- A full custom exception hierarchy for FinTrust's transaction processing: `BankingError` → `TransactionError` → `InsufficientFundsError`, `AccountFrozenError`, `DailyLimitExceededError`, `InvalidAmountError`, `CurrencyMismatchError`
- A `process_withdrawal()` function that validates a transaction against all of these rules in the correct priority order and raises the matching exception
- An audit log that captures every failed transaction with a timestamp, error type, and message — logged automatically via a wrapping `try`/`except`

## Key Concepts Demonstrated
- **RDS (AWS, conceptual):** Multi-AZ (high availability, synchronous, standby not readable) vs Read Replicas (read scaling, asynchronous, readable, manual promotion); automated backups (max 35-day retention, supports point-in-time recovery) vs manual snapshots (indefinite retention, exact-moment restore only)
- **Custom exceptions:** building a hierarchy so callers can catch as narrowly (`InsufficientFundsError`) or broadly (`BankingError`) as they need
- **Exception design:** always calling `super().__init__(message)` so the message propagates correctly into tracebacks and logs; attaching domain-specific attributes (`account_id`, `shortfall`, `remaining`) so calling code can inspect *why* something failed, not just read a string
- **Early return + validation order:** checking invalid amount → account exists → frozen → daily limit → insufficient funds, in that priority order, so the most fundamental problem is always reported first
- **Audit logging pattern:** wrapping the core logic in `try`/`except`, logging the error, then re-raising with a bare `raise` — preserves the original traceback while still recording the failure

## How to Run
```bash
cd "Python/Week 4/Day1_exercise" && python3 transactions.py
```

## Files
| File | Description |
|------|-------------|
| `Python/Week 4/Day1_exercise/transactions.py` | Exception hierarchy, transaction processor, audit log, 5 test cases |
