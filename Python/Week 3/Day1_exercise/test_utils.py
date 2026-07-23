from fintrust_utils import (
    format_rand, mask_id_number, validate_id_number,
    calculate_monthly_fee, summarise_transactions, generate_report_header
)

# Test formatting
print(format_rand(45230.75))         # R 45,230.75
print(mask_id_number("8501015009084")) # 850101******4

# Test validation
print(validate_id_number("8501015009084"))  # True
print(validate_id_number("123"))             # False

# Test calculations
print(calculate_monthly_fee("savings"))  # 0.0
print(calculate_monthly_fee("credit"))   # 120.0

# Test transaction summary
amounts = [5000, -250, 1200, -800, 3500, -1500]
deposits, withdrawals, net = summarise_transactions(amounts)
print(f"In: {format_rand(deposits)}")        # In: R 9,700.00
print(f"Out: {format_rand(abs(withdrawals))}") # Out: R 2,550.00
print(f"Net: {format_rand(net)}")             # Net: R 7,150.00

# Test report header
print(generate_report_header("Thabo Nkosi", "ACC-10042"))