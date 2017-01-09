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
 
 entity rotator_s is
 
   generic(
      SPEED_opt          : T_speed       := t_exc;
      ROUND_STYLE_opt    : T_round_style := fixed_truncate;
      ROUND_TO_BIT_opt   : integer_exc   := integer'low;
      MAX_ERROR_PCT_opt  : real_exc      := real'low;
      MIN_OUTPUT_BIT     : integer_exc   := integer'low;
      MAX_OUTPUT_BIT     : integer_exc   := integer'low;
      ANGLE_DEGREES      : real
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
 
 architecture rotator_s_1 of rotator_s is

   signal inter_real : u_sfixed(complex_const_mult_OH(round_style_opt   => ROUND_STYLE_OPT,
                                                      round_to_bit_opt  => ROUND_TO_BIT_OPT,
                                                      max_error_pct_opt => MAX_ERROR_PCT_OPT,
                                                      max_output_bit    => MAX_OUTPUT_BIT,
                                                      constants         => (cos(ANGLE_DEGREES*MATH_PI/180.0),
                                                                            sin(ANGLE_DEGREES*MATH_PI/180.0)),
                                                      input_high        => input_real'high,
                                                      input_low         => input_real'low,
                                                      is_signed         => true)
                                downto 
                                complex_const_mult_OL(round_style_opt   => ROUND_STYLE_OPT,
                                                      round_to_bit_opt  => ROUND_TO_BIT_OPT,
                                                      max_error_pct_opt => MAX_ERROR_PCT_OPT,
                                                      min_output_bit    => MIN_OUTPUT_BIT,
                                                      constants         => (cos(ANGLE_DEGREES*MATH_PI/180.0),
                                                                            sin(ANGLE_DEGREES*MATH_PI/180.0)),
                                                      input_low         => input_real'low,
                                                      is_signed         => true)
                               );
   signal inter_imag : u_sfixed(inter_real'range);

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
         MIN_OUTPUT_BIT     => MIN_OUTPUT_BIT,
         MAX_OUTPUT_BIT     => MAX_OUTPUT_BIT,
         MULTIPLICAND_REAL  => cos(ANGLE_DEGREES*MATH_PI/180.0),
         MULTIPLICAND_IMAG  => sin(ANGLE_DEGREES*MATH_PI/180.0),
         INPUT_HIGH         => input_real'high,
         INPUT_LOW          => input_real'low
      )
      port map(
         clk          => clk,
         input_real   => input_real,
         input_imag   => input_imag,
         valid_input  => valid_input,
         output_real  => inter_real,
         output_imag  => inter_imag,
         valid_output => valid_output
      );

   truncate_min_exists:
   if MIN_OUTPUT_BIT /= integer'low generate
      truncate_max_exists:
      if MAX_OUTPUT_BIT /= integer'low generate
         max_needed:
         if MAX_OUTPUT_BIT < inter_real'high generate
            min_needed:
            if MIN_OUTPUT_BIT > inter_real'low generate
               output_real(MAX_OUTPUT_BIT downto MIN_OUTPUT_BIT) <= inter_real(MAX_OUTPUT_BIT downto MIN_OUTPUT_BIT);
               output_imag(MAX_OUTPUT_BIT downto MIN_OUTPUT_BIT) <= inter_imag(MAX_OUTPUT_BIT downto MIN_OUTPUT_BIT);
            else generate
               output_real(MAX_OUTPUT_BIT downto inter_real'low) <= inter_real(MAX_OUTPUT_BIT downto inter_real'low);
               output_imag(MAX_OUTPUT_BIT downto inter_real'low) <= inter_imag(MAX_OUTPUT_BIT downto inter_real'low);
            end generate;
         else generate
            min_needed:
            if MIN_OUTPUT_BIT > inter_real'low generate
               output_real(inter_real'high downto MIN_OUTPUT_BIT) <= inter_real(inter_real'high downto MIN_OUTPUT_BIT);
               output_imag(inter_real'high downto MIN_OUTPUT_BIT) <= inter_imag(inter_real'high downto MIN_OUTPUT_BIT);
            else generate
               output_real <= inter_real(output_real'high downto output_real'low);
               output_imag <= inter_imag(output_imag'high downto output_imag'low);
            end generate;
         end generate;
      else generate
         truncate_max_exists:
         if MIN_OUTPUT_BIT /= integer'low generate
            min_needed:
            if MIN_OUTPUT_BIT > inter_real'low generate
               output_real <= inter_real(output_real'high downto MIN_OUTPUT_BIT);
               output_imag <= inter_imag(output_imag'high downto MIN_OUTPUT_BIT);
            else generate
               output_real <= inter_real;
               output_imag <= inter_imag;
            end generate;
         else generate
            output_real <= inter_real;
            output_imag <= inter_imag;
         end generate;
      end generate;
   else generate
      truncate_max_exists:
      if MAX_OUTPUT_BIT /= integer'low generate
         max_needed:
         if MAX_OUTPUT_BIT < inter_real'high generate
               output_real(MAX_OUTPUT_BIT downto inter_real'low) <= inter_real(MAX_OUTPUT_BIT downto inter_real'low);
               output_imag(MAX_OUTPUT_BIT downto inter_real'low) <= inter_imag(MAX_OUTPUT_BIT downto inter_real'low);
         else generate
            output_real <= inter_real;
            output_imag <= inter_imag;
         end generate;
      else generate
         output_real <= inter_real;
         output_imag <= inter_imag;
      end generate;
   end generate;
 
 end architecture;