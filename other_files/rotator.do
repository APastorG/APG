
vsim -novopt work.rotator_tb
view wave


add wave -position end -label R_in sim:/rotator_tb/input_real
add wave -position end -label I_in sim:/rotator_tb/input_imag
add wave -position end -label clk sim:/rotator_tb/clk
add wave -position end -label valid_input sim:/rotator_tb/valid_input
add wave -position end -label R_out sim:/rotator_tb/output_real
add wave -position end -label I_out sim:/rotator_tb/output_imag
add wave -position end -label valid_output sim:/rotator_tb/valid_output

force -freeze sim:/rotator_tb/clk 1 0, 0 {1 ps} -r 2
force -freeze sim:/rotator_tb/input_real 00000100 0
force -freeze sim:/rotator_tb/input_imag 00000000 0
force -freeze sim:/rotator_tb/valid_input 0 0
run 52ps

force -freeze sim:/rotator_tb/valid_input 1 0
run 4ps

force -freeze sim:/rotator_tb/valid_input 0 0
run 120ps