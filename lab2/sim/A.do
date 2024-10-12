
vsim work.A

add wave -position insertpoint  \
sim:/A/A \
sim:/A/B \
sim:/A/S \
sim:/A/Cin \
sim:/A/F \
sim:/A/Cout

radix signal sim:/A/A hexadecimal
radix signal sim:/A/B hexadecimal
radix signal sim:/A/F hexadecimal
radix signal sim:/A/S binary

# Case 1: F = A (S = "0000", Cin = 0)
force -freeze sim:/A/A 16#F0 0
force -freeze sim:/A/B 16#0A 0
force -freeze sim:/A/S 4'b0000 0
force -freeze sim:/A/Cin 0 0
run 10 ns

# Case 2: F = A + 1 (S = "0000", Cin = 1)
force -freeze sim:/A/Cin 1 0
run 10 ns

# Case 3: F = A + B (S = "0001", Cin = 0)
force -freeze sim:/A/S 4'b0001 0
force -freeze sim:/A/Cin 0 0
run 10 ns

# Case 4: F = A + B + 1 (S = "0001", Cin = 1)
force -freeze sim:/A/Cin 1 0
run 10 ns

# Case 5: F = A - B - 1 (S = "0010", Cin = 0)
force -freeze sim:/A/S 4'b0010 0
force -freeze sim:/A/Cin 0 0
run 10 ns

# Case 6: F = A - B (S = "0010", Cin = 1)
force -freeze sim:/A/Cin 1 0
run 10 ns

# Case 7: F = A - 1 (S = "0011", Cin = 0)
force -freeze sim:/A/S 4'b0011 0
force -freeze sim:/A/Cin 0 0
run 10 ns

# Case 8: F = B (S = "0011", Cin = 1)
force -freeze sim:/A/Cin 1 0
run 10 ns

# Zoom full
wave zoom full
