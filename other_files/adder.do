vsim work.adder_tb
view wave
quietly set unsigned [examine sim:/adder_tb/adder1/UNSIGNED_2COMP_opt]

add wave -position 0 -label clk sim:/adder_tb/clk
add wave -position 1 -label start sim:/adder_tb/start
add wave -position 2 -label valid_input sim:/adder_tb/valid_input
add wave -position 4 -label valid_output sim:/adder_tb/valid_output

if {$unsigned==TRUE} {
add wave -position 6 -label selector sim:/adder_tb/adder1/adder_selection/adder_u_1/adder_core_u_1/generate_accumulator/selector
add wave -position 3 -radix unsigned -label input sim:/adder_tb/input
add wave -position 5 -radix unsigned -label output sim:/adder_tb/output
add wave -position 7 -radix unsigned -label inter_resized sim:/adder_tb/adder1/adder_selection/adder_u_1/adder_core_u_1/generate_accumulator/inter_resized
add wave -position 8 -radix unsigned -label previous_output_inter sim:/adder_tb/adder1/adder_selection/adder_u_1/adder_core_u_1/generate_accumulator/previous_output_inter
add wave -position 9 -radix unsigned -label addition sim:/adder_tb/adder1/adder_selection/adder_u_1/adder_core_u_1/generate_accumulator/addition
add wave -position 0 -label PIPELINES sim:/adder_tb/adder1/adder_selection/adder_u_1/adder_core_u_1/PIPELINES
add wave -position 1 -label ADD_PIPELINES sim:/adder_tb/adder1/adder_selection/adder_u_1/adder_core_u_1/ADD_PIPELINES
add wave -position 2 -label IS_PIPELINED  sim:/adder_tb/adder1/adder_selection/adder_u_1/adder_core_u_1/IS_PIPELINED
add wave -position 3 -label ACC_PIPELINES sim:/adder_tb/adder1/adder_selection/adder_u_1/adder_core_u_1/ACC_PIPELINES
add wave -position 4 -label OUTPUT_BUFFER sim:/adder_tb/adder1/adder_selection/adder_u_1/adder_core_u_1/OUTPUT_BUFFER
} else {
add wave -position 6 -label selector sim:/adder_tb/adder1/adder_selection/adder_s_1/adder_core_s_1/generate_accumulator/selector
add wave -position 3 -radix decimal -label input sim:/adder_tb/input
add wave -position 5 -radix decimal -label output sim:/adder_tb/output
add wave -position 7 -radix decimal -label inter_resized sim:/adder_tb/adder1/adder_selection/adder_s_1/adder_core_s_1/generate_accumulator/inter_resized
add wave -position 8 -radix decimal -label previous_output_inter sim:/adder_tb/adder1/adder_selection/adder_s_1/adder_core_s_1/generate_accumulator/previous_output_inter
add wave -position 9 -radix decimal -label addition sim:/adder_tb/adder1/adder_selection/adder_s_1/adder_core_s_1/generate_accumulator/addition
add wave -position 0 -label PIPELINES sim:/adder_tb/adder1/adder_selection/adder_s_1/adder_core_s_1/PIPELINES
add wave -position 1 -label ADD_PIPELINES sim:/adder_tb/adder1/adder_selection/adder_s_1/adder_core_s_1/ADD_PIPELINES
add wave -position 2 -label IS_PIPELINED  sim:/adder_tb/adder1/adder_selection/adder_s_1/adder_core_s_1/IS_PIPELINED
add wave -position 3 -label ACC_PIPELINES sim:/adder_tb/adder1/adder_selection/adder_s_1/adder_core_s_1/ACC_PIPELINES
add wave -position 4 -label OUTPUT_BUFFER sim:/adder_tb/adder1/adder_selection/adder_s_1/adder_core_s_1/OUTPUT_BUFFER
}
