vsim -gui work.b

add wave sim:/b/*

force -freeze sim:/b/A 00000011 0
force -freeze sim:/b/B 11001100 0
force -freeze sim:/b/S 0100 0

run
