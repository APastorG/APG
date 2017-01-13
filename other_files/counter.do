vsim work.counter_tb
view wave
quietly set unsigned [examine sim:/counter_tb/counter1/counter_core1/UNSIGNED_2COMP_opt]

add wave -position end -label clk sim:/counter_tb/counter1/clk
add wave -position end -label count_mode_signal sim:/counter_tb/counter1/count_mode_signal
add wave -position end -label enable sim:/counter_tb/counter1/enable
add wave -position end -label load sim:/counter_tb/counter1/load

quietly set signal sim:/counter_tb/counter1/value_to_load
if {$unsigned==TRUE} {
	add wave -radix unsigned -position end -label value_to_load $signal
} else {
	add wave -radix decimal -position end -label value_to_load $signal
}
#add wave -radix unsigned -position end -label value_to_load $signal

add wave -position end -label reset sim:/counter_tb/counter1/reset
add wave -position end -label set sim:/counter_tb/counter1/set

quietly set signal count_inter
quietly set path sim:/counter_tb/counter1/counter_core1/$signal
if {$unsigned==TRUE} {
	add wave -position end -radix unsigned -label $signal $path
} else {
	add wave -position end -radix decimal -label $signal $path
}
#add wave -position end -radix unsigned -label $signal $path
add wave -position end -label count_is_TARGET sim:/counter_tb/counter1/count_is_TARGET

run 300 ps