
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
/     This design makes use of some features from VHDL-2008, all of which have been implemented in
/  Xilinx's Vivado
/     A 3 space tab is used throughout the document
/
/
/  Description:
/  ¯¯¯¯¯¯¯¯¯¯¯
/
 **************************************************************************************************/

library ieee;
   use ieee.numeric_std.all;
   use ieee.std_logic_1164.all;
   use ieee.math_real.all;

library work;
   use work.common_pkg.all;
   use work.common_data_types_pkg.all;
   use work.fixed_generic_pkg.all;
   use work.fixed_float_types.all;
   use work.complex_const_mult_pkg.all;
   use work.real_const_mult_pkg.all;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

entity rotator_tb is

   port(
      input_real   : in  u_sfixed(5 downto -2);
      input_imag   : in  u_sfixed(5 downto -2);
      clk          : in  std_ulogic;
      valid_input  : in  std_ulogic;

      output_real  : out u_sfixed(complex_const_mult_OH(round_style_opt   => fixed_truncate,
                                                        round_to_bit_opt  => integer'low,
                                                        max_error_pct_opt => 0.05,
                                                        max_output_bit    => integer'low,
                                                        constants         => (cos(80.0*MATH_PI/180.0),
                                                                              sin(80.0*MATH_PI/180.0)),
                                                        input_high        => 5,
                                                        input_low         => -2,
                                                        is_signed         => true)
                                  downto 
                                  complex_const_mult_OL(round_style_opt   => fixed_truncate,
                                                        round_to_bit_opt  => integer'low,
                                                        max_error_pct_opt => 0.05,
                                                        min_output_bit    => -12,
                                                        constants         => (cos(80.0*MATH_PI/180.0),
                                                                              sin(80.0*MATH_PI/180.0)),
                                                        input_low         => -2,
                                                        is_signed         => true)
                                  );
      output_imag  : out u_sfixed(complex_const_mult_OH(round_style_opt   => fixed_truncate,
                                                        round_to_bit_opt  => integer'low,
                                                        max_error_pct_opt => 0.05,
                                                        max_output_bit    => integer'low,
                                                        constants         => (cos(80.0*MATH_PI/180.0),
                                                                              sin(80.0*MATH_PI/180.0)),
                                                        input_high        => 5,
                                                        input_low         => -2,
                                                        is_signed         => true)
                                  downto 
                                  complex_const_mult_OL(round_style_opt   => fixed_truncate,
                                                        round_to_bit_opt  => integer'low,
                                                        max_error_pct_opt => 0.05,
                                                        min_output_bit    => -12,
                                                        constants         => (cos(80.0*MATH_PI/180.0),
                                                                              sin(80.0*MATH_PI/180.0)),
                                                        input_low         => -2,
                                                        is_signed         => true)
                                  );
      valid_output : out std_ulogic
   );

end entity;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

architecture rotator_tb_1 of rotator_tb is


/*================================================================================================*/
/*================================================================================================*/

begin


   rotator_s_1:
   entity work.rotator_s
      generic map(
         SPEED_opt         => t_min,
         ROUND_STYLE_opt   => fixed_truncate,
         --ROUND_TO_BIT_opt  => ROUND_TO_BIT_opt,
         MAX_ERROR_PCT_opt => 0.05,
         MIN_OUTPUT_BIT    => -12,
         MAX_OUTPUT_BIT    => 5,
         ANGLE_DEGREES     => 80.0
      )
      port map(
         input_real   => input_real,
         input_imag   => input_imag,
         clk          => clk,
         valid_input  => valid_input,
         output_real  => output_real,
         output_imag  => output_imag,
         valid_output => valid_output
      );

end architecture;