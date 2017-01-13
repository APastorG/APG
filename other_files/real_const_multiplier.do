vsim work.real_const_mult_tb
view wave
quietly set unsigned [examine sim:/real_const_mult_tb/UNSIGNED_2COMP_opt]

if {$unsigned==TRUE} {
	quietly set path sim:/real_const_mult_tb/real_const_mult_1/generate_real_const_mult/real_const_mult_s_1/
} else {
	quietly set path sim:/real_const_mult_tb/real_const_mult_1/generate_real_const_mult/real_const_mult_u_1/	
}
add wave -position end -label CONSTANTS sim:/real_const_mult_tb/MULTIPLICANDS
add wave -position end -label system_input sim:/real_const_mult_tb/input
add wave -position end -label clock sim:/real_const_mult_tb/clk
add wave -position end -label valid_input sim:/real_const_mult_tb/valid_input
add wave -position end -label block_input $path/input
add wave -position end -label valid_output sim:/real_const_mult_tb/valid_output
add wave -position end -label block_output -expand $path/output

run 150 ps