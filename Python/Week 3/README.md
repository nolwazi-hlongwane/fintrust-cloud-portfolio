# Week 3 — Python Deep Dive: Functions, Standard Library, File I/O & Error Handling

## What I Built
- A reusable `fintrust_utils.py` module with formatting, validation, calculation, and reporting functions
- A `setup_data_dirs.py` script using `pathlib`, `os`, and `sys` together to build and report on a directory structure
- A transaction-cleaning pipeline (`clean_transactions.py`) that reads messy CSV data and outputs both a clean CSV and a JSON summary
- An AWS billing CSV parser (`parse_aws_billing.py`) that aggregates costs by service
- A production-grade version of the transaction pipeline (`clean_transactions_v2.py`) with full `try`/`except`/`else`/`finally` error handling and structured `logging`, including a documented bug found and fixed during testing

## Key Concepts Demonstrated
- **Functions & modules:** positional vs keyword arguments, default parameter values, multiple return values (tuples), organising code into an importable module with `import`/`from ... import`
- **Standard library:** `pathlib.Path` for file operations (`.exists()`, `.mkdir(parents=True, exist_ok=True)`, `.glob()`), `os.environ` for configuration, `sys.argv` for CLI arguments, `sys.exit()` for return codes
- **File I/O:** `csv.DictReader`/`DictWriter` for structured CSV data, `newline=""` handling, `json.dump()`/`json.load()` for structured data, `collections.defaultdict` for aggregation
- **Error handling & logging:** `try`/`except`/`else`/`finally`, catching specific exception types instead of bare `except:`, the `logging` module with `FileHandler` + `StreamHandler` and INFO/WARNING/ERROR/CRITICAL levels, and finding a real edge case (a `PermissionError` on `.exists()` that wasn't originally caught) through deliberate testing

## How to Run
```bash
cd "Python/Week 3/Day1_exercise" && python3 test_utils.py
cd "Python/Week 3/Day2_exercise" && python3 setup_data_dirs.py
cd "Python/Week 3/Day3_exercise" && python3 clean_transactions.py && python3 parse_aws_billing.py
cd "Python/Week 3/Day4_exercise" && python3 clean_transactions_v2.py
```

## Files
| File | Description |
|------|-------------|
| `Python/Week 3/Day1_exercise/fintrust_utils.py` | Shared utility module: formatting, validation, calculations, report headers |
| `Python/Week 3/Day1_exercise/test_utils.py` | Test script exercising every function in `fintrust_utils.py` |
| `Python/Week 3/Day2_exercise/setup_data_dirs.py` | Directory setup + reporting script using pathlib/os/sys |
| `Python/Week 3/Day3_exercise/clean_transactions.py` | CSV → clean CSV + JSON summary pipeline |
| `Python/Week 3/Day3_exercise/parse_aws_billing.py` | AWS Cost Explorer-style billing CSV parser |
| `Python/Week 3/Day4_exercise/clean_transactions_v2.py` | Pipeline with full error handling and audit logging |
| `Python/Week 3/Day4_exercise/EXTENSION_TESTS.md` | Write-up of 3 fault-injection tests, including a bug found and fixed |

## Reflection
Finding the PermissionError bug during the extension tests was the highlight of this week — my first script handled the "file doesn't exist" case fine, but when I made the data folder read-only, it crashed instead of failing gracefully. Fixing it myself (wrapping the exists-check in its own try/except) made the difference between error handling as a concept and error handling as something I actually understand well enough to debug. Building fintrust_utils.py also gave me a better sense of why functions and modules matter beyond "keeping code organised" — being able to import the same tested functions into different scripts without rewriting them felt like a real productivity shift. The logging module took a bit to get comfortable with, mainly figuring out when something should be a WARNING versus an ERROR versus CRITICAL. That judgment call is something I want more practice with going into Week 4.