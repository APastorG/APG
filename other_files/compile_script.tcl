
quietly set directory C:/Users/Antonio/Desktop/Vivado_workspace/PFdC_vivado_project/PFdC_vivado/PFdC_vivado.srcs

quietly set file_name_list {fixed_float_types.vhdl
                            fixed_generic_pkg.vhd
                            common_data_types_pkg.vhd
                            common_pkg.vhd
                            tb_pkg.vhd
                            counter_pkg.vhd
                            counter_core.vhd
                            counter.vhd
                            counter_tb.vhd
                            adder_pkg.vhd
                            adder_core_s.vhd
                            adder_core_u.vhd
                            adder_s.vhd
                            adder_u.vhd
                            adder.vhd
                            adder_tb.vhd
                            real_const_mult_pkg.vhd
                            mmcm_pkg.vhd
                            real_const_mult_core_s.vhd
                            real_const_mult_core_u.vhd
                            real_const_mult_s.vhd
                            real_const_mult_u.vhd
                            real_const_mult.vhd
                            real_const_mult_tb.vhd
                            int_const_div_s.vhd
                            int_const_div_u.vhd
                            int_const_div.vhd
                            int_const_div_tb.vhd
                            int_const_mult_s.vhd
                            int_const_mult_u.vhd
                            int_const_mult.vhd
                            int_const_mult_tb.vhd
                            average_calculator_pkg.vhd
                            average_calculator_core_s.vhd
                            average_calculator_core_u.vhd
                            average_calculator_s.vhd
                            average_calculator_u.vhd
                            average_calculator.vhd
                            average_calculator_tb.vhd
                            permutation_pkg.vhd
                            perm_pp.vhd
                            perm_ss.vhd
                            perm_sp_core.vhd
                            perm_sp.vhd
                            permutation_core.vhd
                            permutation.vhd
                            permutation_s.vhd
                            permutation_tb.vhd
                            pipelines_core.vhd
                            pipelines_s.vhd
                            pipelines_u.vhd
                            pipelines.vhd
                            complex_const_mult_pkg.vhd
                            complex_const_mult_core_s.vhd
                            complex_const_mult_s.vhd
                            complex_const_mult.vhd
                            rotator_s.vhd
                            rotator.vhd
                            rotator_tb.vhd
                            butterfly_core_s.vhd
                            butterfly_s.vhd
                            butterfly.vhd
                            CM_FFT_core.vhd
                            CM_FFT.vhd
                            CM_FFT_tb.vhd
                         }

quietly set file_list {}

foreach file_name $file_name_list {
   lappend file_list [file join $directory $file_name]
}

quietly set library_file_list {work}
quietly lappend library_file_list $file_list


proc r  {} {
   set directory C:/Users/Antonio/Desktop/Vivado_workspace/PFdC_vivado_project/PFdC_vivado/PFdC_vivado.srcs
   set compile_path [file join $directory compile_script.tcl]
   uplevel #0 source $compile_path
}
proc rr {} {
   global last_compile_time
   set last_compile_time 0
   r
}


quietly set time_now [clock seconds]
if [catch {set last_compile_time}] {
  set last_compile_time 0
}
foreach {library file_list} $library_file_list {
   foreach file $file_list {
   if { $last_compile_time < [file mtime $file] } {
      vcom -2008 -quiet $file
      set last_compile_time 0
   }
}
}
quietly set last_compile_time $time_now

puts "Compilation finished"
