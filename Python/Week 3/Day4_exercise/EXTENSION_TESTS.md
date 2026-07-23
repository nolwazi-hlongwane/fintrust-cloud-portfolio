# Extension: Testing Error Handling

Three tests run against `clean_transactions_v2.py` to confirm the logging/error
handling behaves correctly.

## Test 1 — Delete `raw_transactions.csv`
2026-07-23 10:21:28  INFO      === FinTrust Transaction Pipeline starting ===
2026-07-23 10:21:28  INFO      Input:  data/raw_transactions.csv
2026-07-23 10:21:28  CRITICAL  Input file not found: data/raw_transactions.csv — aborting

**Result:** Caught before any file operation is attempted, logged at `CRITICAL`, clean exit.


## Test 2 — Corrupt a row (bad amount, e.g. `'abc'`)
2026-07-23 10:19:25 WARNING Skipped: Row 5: could not convert string to float: 'abc'
2026-07-23 10:19:25 WARNING Skipped: Row 7: invalid literal for int() with base 10: ''
2026-07-23 10:19:25 INFO Processed: 8 rows, skipped: 2

**Result:** Bad rows raise `ValueError`, caught in the per-row loop, logged at `WARNING`
and skipped. The other valid rows still process — the script doesn't crash.

## Test 3 — Make `data/` read-only (`chmod 444 data`)

**First attempt** exposed a bug: the `RAW_INPUT.exists()` check wasn't wrapped in a
`try/except`, so a `PermissionError` on `.exists()` itself crashed the script with an
unhandled traceback.

**Fix:** wrapped the exists-check in `try/except PermissionError`, logging at `CRITICAL`
instead of crashing:

```python
try:
    if not RAW_INPUT.exists():
        logger.critical("Input file not found: %s — aborting", RAW_INPUT)
        return
except PermissionError:
    logger.critical("Permission denied checking input file: %s — aborting", RAW_INPUT)
    return
```

**After the fix:**
2026-07-23 10:26:37 INFO === FinTrust Transaction Pipeline starting ===
2026-07-23 10:26:37 INFO Input: data/raw_transactions.csv
2026-07-23 10:26:37 CRITICAL Permission denied checking input file: data/raw_transactions.csv — aborting

**Result:** Clean `CRITICAL` log, no crash.

## Checklist
- [x] Script runs successfully and produces `logs/pipeline.log`
- [x] Log contains timestamps, levels, and meaningful messages
- [x] Corrupted rows are skipped with a warning, script does not crash
- [x] Testing surfaced an unhandled `PermissionError` edge case, which was fixed
- [x] Committed as `Python/Week 3/Day4_exercise/clean_transactions_v2.py`