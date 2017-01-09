
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

entity complex_const_mult is

   generic(
      UNSIGNED_2COMP_opt : boolean       := false;          --default
      SPEED_opt          : T_speed       := t_exc;          --exception: value not set
      ROUND_STYLE_opt    : T_round_style := fixed_truncate; --default
      ROUND_TO_BIT_opt   : integer_exc   := integer'low;    --exception: value not set
      MAX_ERROR_PCT_opt  : real_exc      := real'low;       --exception: value not set
      MIN_OUTPUT_BIT     : integer       := integer'low;    --exception: value not set
      MAX_OUTPUT_BIT     : integer       := integer'low;    --exception: value not set
      MULTIPLICAND_REAL  : real;                            --compulsory
      MULTIPLICAND_IMAG  : real                             --compulsory
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

architecture complex_const_mult_1 of complex_const_mult is

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
                                                             (1 => MULTIPLICAND_REAL,
                                                              2 => MULTIPLICAND_IMAG),
                                                             NORM_IN_HIGH,
                                                             NORM_IN_LOW,
                                                             not UNSIGNED_2COMP_opt);
   constant NORM_OUT_LOW  : integer := complex_const_mult_OL(ROUND_STYLE_opt,
                                                             ROUND_TO_BIT_opt,
                                                             MAX_ERROR_PCT_opt,
                                                             MIN_OUTPUT_BIT,
                                                             (1 => MULTIPLICAND_REAL,
                                                              2 => MULTIPLICAND_IMAG),
                                                             NORM_IN_LOW,
                                                             not UNSIGNED_2COMP_opt);
   constant OUT_HIGH      : natural := NORM_OUT_HIGH + SULV_NEW_ZERO;
   constant OUT_LOW       : natural := NORM_OUT_LOW + SULV_NEW_ZERO;

   signal   aux_input_real_s   : u_sfixed(NORM_IN_HIGH downto NORM_IN_LOW);
   signal   aux_input_imag_s   : u_sfixed(NORM_IN_HIGH downto NORM_IN_LOW);
   signal   aux_output_real_s  : u_sfixed(NORM_OUT_HIGH downto NORM_OUT_LOW);
   signal   aux_output_imag_s  : u_sfixed(NORM_OUT_HIGH downto NORM_OUT_LOW);

   signal   aux_input_real_u   : u_ufixed(NORM_IN_HIGH downto NORM_IN_LOW);
   signal   aux_input_imag_u   : u_ufixed(NORM_IN_HIGH downto NORM_IN_LOW);
   signal   aux_output_real_u  : u_ufixed(NORM_OUT_HIGH downto NORM_OUT_LOW);
   signal   aux_output_imag_u  : u_ufixed(NORM_OUT_HIGH downto NORM_OUT_LOW);

/*================================================================================================*/
/*================================================================================================*/

begin

   generate_real_const_mult:
   if UNSIGNED_2COMP_opt generate
      begin
         --aux_input_real_u <= to_ufixed(input_real, aux_input_real_u);
         --aux_input_imag_u <= to_ufixed(input_imag, aux_input_imag_u);

         --complex_const_mult_u_1:
         --entity work.complex_const_mult_u
         --   generic map(
         --      SPEED_opt         => SPEED_opt,
         --      ROUND_STYLE_opt   => ROUND_STYLE_opt,
         --      ROUND_TO_BIT_opt  => ROUND_TO_BIT_opt,
         --      MAX_ERROR_PCT_opt => MAX_ERROR_PCT_opt,
         --      MULTIPLICAND_REAL => MULTIPLICAND_REAL,
         --      MULTIPLICAND_IMAG => MULTIPLICAND_IMAG
         --   )
         --   port map(
         --      input_real   => aux_input_real_u,
         --      input_imag   => aux_input_imag_u,
         --      clk          => clk,
         --      valid_input  => valid_input,
         --      output_real  => aux_output_real_u,
         --      output_imag  => aux_output_imag_u,
         --      valid_output => valid_output
         --   );

         --output_real <= to_std_ulogic_vector(aux_output_real_u, output_real);
         --output_imag <= to_std_ulogic_vector(aux_output_imag_u, output_imag);
      end;
   else generate
      begin
         aux_input_real_s <= to_sfixed(input_real, aux_input_real_s);
         aux_input_imag_s <= to_sfixed(input_imag, aux_input_imag_s);

         complex_const_mult_s_1:
         entity work.complex_const_mult_s
            generic map(
               SPEED_opt         => SPEED_opt,
               ROUND_STYLE_opt   => ROUND_STYLE_opt,
               ROUND_TO_BIT_opt  => ROUND_TO_BIT_opt,
               MAX_ERROR_PCT_opt => MAX_ERROR_PCT_opt,
               MIN_OUTPUT_BIT    => MIN_OUTPUT_BIT,
               MULTIPLICAND_REAL => MULTIPLICAND_REAL,
               MULTIPLICAND_IMAG => MULTIPLICAND_IMAG
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
      end;
   end generate;

end architecture;