 /***************************************************************************************************
 /
 /  Author:     Antonio Pastor González
 /  ¯¯¯¯¯¯
 /
 /  Date:       
 /  ¯¯¯¯
 /
 /  Version:    
 /  ¯¯¯¯¯¯¯
 /
 /  Notes:
 /  ¯¯¯¯¯
 /     This design makes use of some features from VHDL-2008, all of which have been implemented by
 /  Altera and Xilinx in their software.
 /     A 3 space tab is used throughout the document
 /
 /
 /  Description:
 /  ¯¯¯¯¯¯¯¯¯¯¯
 /
 /
  **************************************************************************************************/
 
 library ieee;
    use ieee.numeric_std.all;
    use ieee.std_logic_1164.all;
    use ieee.math_real.all;

library work;
   use work.fixed_generic_pkg.all;
   use work.fixed_float_types.all;
   use work.common_data_types_pkg.all;
   use work.common_pkg.all;
   use work.complex_const_mult_pkg.all;
   use work.real_const_mult_pkg.all;
 
 /*================================================================================================*/
 /*================================================================================================*/
 /*================================================================================================*/
 
 entity complex_const_mult_s is
 
   generic(
      SPEED_opt          : T_speed       := t_exc;
      ROUND_STYLE_opt    : T_round_style := fixed_truncate;
      ROUND_TO_BIT_opt   : integer_exc   := integer'low;
      MAX_ERROR_PCT_opt  : real_exc      := real'low;
      MIN_OUTPUT_BIT     : integer       := integer'low;
      MULTIPLICAND_REAL  : real;
      MULTIPLICAND_IMAG  : real
   );
   port(
      clk          : in  std_ulogic;
      input_real   : in  u_sfixed;
      input_imag   : in  u_sfixed;
      valid_input  : in  std_ulogic;
      output_real  : out u_sfixed;
      output_imag  : out u_sfixed;
      valid_output : out std_ulogic
   );

 end entity;

 /*================================================================================================*/
 /*================================================================================================*/
 /*================================================================================================*/
 
 architecture complex_const_mult_s_1 of complex_const_mult_s is


 /*================================================================================================*/
    /*================================================================================================*/
    
    begin
    
    complex_const_mult_core_s_1:
    entity work.complex_const_mult_core_s
      generic map(
         SPEED_opt          => SPEED_opt,
         ROUND_STYLE_opt    => ROUND_STYLE_opt,
         ROUND_TO_BIT_opt   => ROUND_TO_BIT_opt,
         MAX_ERROR_PCT_opt  => MAX_ERROR_PCT_opt,
         MULTIPLICAND_REAL  => MULTIPLICAND_REAL,
         MULTIPLICAND_IMAG  => MULTIPLICAND_IMAG,
         INPUT_HIGH         => input_real'high,
         INPUT_LOW          => input_real'low
      )
      port map(
         clk          => clk,
         input_real   => input_real,
         input_imag   => input_imag,
         valid_input  => valid_input,
         output_real  => output_real,
         output_imag  => output_imag,
         valid_output => valid_output
      );
 
 end architecture;