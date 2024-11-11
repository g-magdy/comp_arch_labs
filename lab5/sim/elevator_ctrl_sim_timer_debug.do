vcom -work work ./src/rtl/elevator_ctrl.vhd
vsim -t 1ns work.elevator_ctrl

add wave -position insertpoint \
sim:/elevator_ctrl/clk \
sim:/elevator_ctrl/rst \
sim:/elevator_ctrl/floor_request \
sim:/elevator_ctrl/current_floor \
sim:/elevator_ctrl/moving_up \
sim:/elevator_ctrl/moving_down \
sim:/elevator_ctrl/door_open \

# debugging signals
add wave -position insertpoint \
sim:/elevator_ctrl/current_state \
sim:/elevator_ctrl/enable \
sim:/elevator_ctrl/door_timer
# sim:/elevator_ctrl/request_valid \
# sim:/elevator_ctrl/request_done \

# radix
radix signal sim:/elevator_ctrl/current_floor unsigned

# intialize signals
# force -freeze sim:/elevator_ctrl/clk 1 0, 0 {50 ps} -r 100
force -freeze sim:/elevator_ctrl/clk 1 0, 0 {10000 ps} -r {20 ns}
force -freeze sim:/elevator_ctrl/rst 1 0
force -freeze sim:/elevator_ctrl/floor_request 0000000000 0

run 2000 ns

force -freeze sim:/elevator_ctrl/rst 0 0

run 2000 ns

force -freeze sim:/elevator_ctrl/floor_request 0000000010 0
run 500 ns
force -freeze sim:/elevator_ctrl/floor_request 0000000000 0

run 4500 ns

run 2000 ns

force -freeze sim:/elevator_ctrl/floor_request 1000000000 0
run 500 ns
force -freeze sim:/elevator_ctrl/floor_request 0000000000 0

run 22500 ns

force -freeze sim:/elevator_ctrl/floor_request 0000001000 0
run 500 ns
force -freeze sim:/elevator_ctrl/floor_request 0000000000 0

run 30000 ns

force -freeze sim:/elevator_ctrl/floor_request 0101000000 0
run 500 ns
force -freeze sim:/elevator_ctrl/floor_request 0000000000 0

run 30000 ns

wave zoom full
