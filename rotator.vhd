
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

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

entity rotator is

   generic(
      SPEED_opt          : T_speed       := t_exc;          --exception: value not set
      ROUND_STYLE_opt    : T_round_style := fixed_truncate; --default
      ROUND_TO_BIT_opt   : integer_exc   := integer'low;    --exception: value not set
      MAX_ERROR_PCT_opt  : real_exc      := real'low;       --exception: value not set
      MIN_OUTPUT_BIT     : integer_exc   := integer'low;    --exception: value not set
      MAX_OUTPUT_BIT     : integer_exc   := integer'low;    --exception: value not set
      ANGLE_DEGREES      : real                            --compulsory
   );

   port(
      input_real   : in  std_ulogic_vector;
      input_imag   : in  std_ulogic_vector;
      clk          : in  std_ulogic;
      valid_input  : in  std_ulogic;

      output_real  : out std_ulogic_vector;
      output_imag  : out std_ulogic_vector;
      valid_output : out std_ulogic
   );

end entity;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

architecture rotator_1 of rotator is

   --assumed that both real and imag inputs have the same size
   constant NORM_IN_HIGH : integer := input_real'high - SULV_NEW_ZERO;
   constant NORM_IN_LOW  : integer := input_real'low - SULV_NEW_ZERO;

   --constant CHECKS : integer := real_const_mult_CHECKS(input'high,
   --                                                    input'low,
   --                                                    UNSIGNED_2COMP_opt,
   --                                                    ROUND_TO_BIT_opt,
   --                                                    MAX_ERROR_PCT_opt,
   --                                                    MULTIPLICANDS);

   constant NORM_OUT_HIGH : integer := complex_const_mult_OH(ROUND_STYLE_opt,
                                                             ROUND_TO_BIT_opt,
                                                             MAX_ERROR_PCT_opt,
                                                             MAX_OUTPUT_BIT,
                                                             (1 => cos(ANGLE_DEGREES*MATH_PI/180.0),
                                                              2 => sin(ANGLE_DEGREES*MATH_PI/180.0)),
                                                             NORM_IN_HIGH,
                                                             NORM_IN_LOW,
                                                             is_signed => true);
   constant NORM_OUT_LOW  : integer := complex_const_mult_OL(ROUND_STYLE_opt,
                                                             ROUND_TO_BIT_opt,
                                                             MAX_ERROR_PCT_opt,
                                                             MIN_OUTPUT_BIT,
                                                             (1 => cos(ANGLE_DEGREES*MATH_PI/180.0),
                                                              2 => sin(ANGLE_DEGREES*MATH_PI/180.0)),
                                                             NORM_IN_LOW,
                                                             is_signed => true);
   constant OUT_HIGH      : natural := NORM_OUT_HIGH + SULV_NEW_ZERO;
   constant OUT_LOW       : natural := NORM_OUT_LOW + SULV_NEW_ZERO;

   signal   aux_input_real_S   : u_Sfixed(NORM_IN_HIGH downto NORM_IN_LOW);
   signal   aux_input_imag_S   : u_Sfixed(NORM_IN_HIGH downto NORM_IN_LOW);
   signal   aux_output_real_S  : u_Sfixed(NORM_OUT_HIGH downto NORM_OUT_LOW);
   signal   aux_output_imag_S  : u_Sfixed(NORM_OUT_HIGH downto NORM_OUT_LOW);

/*================================================================================================*/
/*================================================================================================*/

begin

   aux_input_real_s <= to_sfixed(input_real, aux_input_real_s);
   aux_input_imag_s <= to_sfixed(input_imag, aux_input_imag_s);

   rotator_s_1:
   entity work.rotator_s
      generic map(
         SPEED_opt         => SPEED_opt,
         ROUND_STYLE_opt   => ROUND_STYLE_opt,
         ROUND_TO_BIT_opt  => ROUND_TO_BIT_opt,
         MAX_ERROR_PCT_opt => MAX_ERROR_PCT_opt,
         MIN_OUTPUT_BIT    => MIN_OUTPUT_BIT,
         MAX_OUTPUT_BIT    => MAX_OUTPUT_BIT,
         ANGLE_DEGREES     => ANGLE_DEGREES
      )
      port map(
         input_real   => aux_input_real_s,
         input_imag   => aux_input_imag_s,
         clk          => clk,
         valid_input  => valid_input,
         output_real  => aux_output_real_s,
         output_imag  => aux_output_imag_s,
         valid_output => valid_output
      );

   output_real <= to_std_ulogic_vector(aux_output_real_s);
   output_imag <= to_std_ulogic_vector(aux_output_imag_s);

end architecture;