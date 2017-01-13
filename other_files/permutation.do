
vsim work.permutation_tb
view wave


add wave -position end -label clk sim:/permutation_tb/clk
add wave -position end -label start sim:/permutation_tb/start
add wave -position end -label finish sim:/permutation_tb/finish
add wave -position end -label input -expand -unsigned sim:/permutation_tb/input

#quietly set index 1
#quietly set main_path sim:/permutation_tb/permutation/permutation_core/check_if_permutations_are_needed/generate_elemental_operations($index)/serial_serial/perm_ss
#quietly set groupname ss$index
#add wave -group $groupname
#add wave -position end -group $groupname -label sradixs_finish $main_path/finish
#add wave -position end -unsigned -group $groupname -label ss_output -expand $main_path/output
#add wave -position end -group $groupname -label "ss_perm count" -radix unsigned -format analog-step -max 7 -height 74 $main_path/counter/count
#add wave -position end -group $groupname -label "ss_perm control" $main_path/control
#add wave -position end -group $groupname -label LATENCY $main_path/LATENCY
#add wave -position end -group $groupname -label start_delayed $main_path/start_delayed

#quietly set index 1
#quietly set main_path sim:/permutation_tb/permutation/permutation_core/check_if_permutations_are_needed/generate_elemental_operations($index)/serial_parallel/perm_sp/perm_sp_core
#quietly set groupname sp$index
#add wave -group $groupname
#add wave -position end -group $groupname -label sp_finish $main_path/finish
#add wave -position end -unsigned -group $groupname -label sp_output -expand $main_path/output
#add wave -position end -group $groupname -label "sp_perm count" -radix unsigned -format analog-step -max 7 -height 74 $main_path/counter/count
#add wave -position end -group $groupname -label "sp_perm control" $main_path/control
#add wave -position end -group $groupname -label LATENCY $main_path/LATENCY
#add wave -position end -group $groupname -label start_delayed $main_path/start_delayed


#quietly set index 2
#quietly set main_path sim:/permutation_tb/permutation/permutation_core/check_if_permutations_are_needed/generate_elemental_operations($index)/serial_parallel/perm_sp/perm_sp_core
#quietly set groupname sp$index
#add wave -group $groupname
#add wave -position end -group $groupname -label sp_finish $main_path/finish
#add wave -position end -unsigned -group $groupname -label sp_output -expand $main_path/output
#add wave -position end -group $groupname -label "sp_perm count" -radix unsigned -format analog-step -max 7 -height 74 $main_path/counter/count
#add wave -position end -group $groupname -label "sp_perm control" $main_path/control
#add wave -position end -group $groupname -label LATENCY $main_path/LATENCY
#add wave -position end -group $groupname -label start_delayed $main_path/start_delayed

#quietly set index 3
#quietly set main_path sim:/permutation_tb/permutation/permutation_core/check_if_permutations_are_needed/generate_elemental_operations($index)/parallel_parallel/perm_pp
#quietly set groupname pp$index
#add wave -group $groupname
#add wave -position end -group $groupname -label pp_finish $main_path/finish
#add wave -position end -unsigned -group $groupname -label pp_output -expand $main_path/output


add wave -position end -label output -expand -unsigned sim:/permutation_tb/output

run 152ps

wave zoom full