
vsim work.adder_subtractor

add wave -position insertpoint \
sim:/adder_subtractor/a \
sim:/adder_subtractor/b \
sim:/adder_subtractor/sub \
sim:/adder_subtractor/cin \
sim:/adder_subtractor/result \
sim:/adder_subtractor/cout

radix signal sim:/adder_subtractor/a hexadecimal
radix signal sim:/adder_subtractor/b hexadecimal
radix signal sim:/adder_subtractor/result hexadecimal

# Addition: A + B
force -freeze sim:/adder_subtractor/a 16#F0 0
force -freeze sim:/adder_subtractor/b 16#0A 0
force -freeze sim:/adder_subtractor/sub 0 0
force -freeze sim:/adder_subtractor/cin 0 0
run 10 ns

# Addition with carry: A + B + 1
force -freeze sim:/adder_subtractor/cin 1 0
run 10 ns

# Subtraction: A - B
force -freeze sim:/adder_subtractor/a 16#F0 0
force -freeze sim:/adder_subtractor/b 16#0A 0
force -freeze sim:/adder_subtractor/sub 1 0
force -freeze sim:/adder_subtractor/cin 0 0
run 10 ns


# Subtraction with borrow: A - B - 1
force -freeze sim:/adder_subtractor/cin 1 0
run 10 ns

# A + 1
force -freeze sim:/adder_subtractor/b 16#00 0
force -freeze sim:/adder_subtractor/sub 0 0
force -freeze sim:/adder_subtractor/cin 1 0
run 10 ns

# A - 1
force -freeze sim:/adder_subtractor/sub 1 0
force -freeze sim:/adder_subtractor/cin 0 0
run 10 ns

wave zoom full
