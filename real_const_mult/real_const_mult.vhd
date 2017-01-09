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
/     This is the interface between the instantiation of a real_const_mult an its content. It exists
/  to circumvent the impossibility of reading the attributes of an unconstrained port signal inside
/  the port declaration of an entity. (so as to declare the output's size, which depends on the
/  input's size).
/     Additionally, the generics' consistency and correctness is checked in here.
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
   use work.real_const_mult_pkg.all;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

entity real_const_mult is

   generic(
      UNSIGNED_2COMP_opt : boolean       := false;          --default
      SPEED_opt          : T_speed       := t_exc;          --exception: value not set
      ROUND_STYLE_opt    : T_round_style := fixed_truncate; --default
      ROUND_TO_BIT_opt   : integer_exc   := integer'low;    --exception: value not set
      MAX_ERROR_PCT_opt  : real_exc      := real'low;       --exception: value not set
      MULTIPLICANDS      : real_v                           --compulsory
   );

   port(
      input        : in  std_ulogic_vector;
      clk          : in  std_ulogic;
      valid_input  : in  std_ulogic;

      output       : out sulv_v;
      valid_output : out std_ulogic
   );

end entity;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

architecture real_const_mult_1 of real_const_mult is

   constant NORM_IN_HIGH  : integer := input'high-SULV_NEW_ZERO;
   constant NORM_IN_LOW   : integer := input'low-SULV_NEW_ZERO;

   constant CHECKS : integer := real_const_mult_CHECKS(input'high,
                                                       input'low,
                                                       UNSIGNED_2COMP_opt,
                                                       ROUND_TO_BIT_opt,
                                                       MAX_ERROR_PCT_opt,
                                                       MULTIPLICANDS);

   constant NORM_OUT_HIGH : integer := real_const_mult_OH(ROUND_STYLE_opt,
                                                          ROUND_TO_BIT_opt,
                                                          MAX_ERROR_PCT_opt,
                                                          MULTIPLICANDS,
                                                          NORM_IN_HIGH,
                                                          NORM_IN_LOW,
                                                          not UNSIGNED_2COMP_opt);
   constant NORM_OUT_LOW  : integer := real_const_mult_OL(ROUND_STYLE_opt,
                                                          ROUND_TO_BIT_opt,
                                                          MAX_ERROR_PCT_opt,
                                                          MULTIPLICANDS,
                                                          NORM_IN_LOW,
                                                          not UNSIGNED_2COMP_opt);
   constant OUT_HIGH      : natural := NORM_OUT_HIGH + SULV_NEW_ZERO;
   constant OUT_LOW       : natural := NORM_OUT_LOW + SULV_NEW_ZERO;

   signal   aux_input_s   : u_sfixed(NORM_IN_HIGH downto NORM_IN_LOW);
   signal   aux_output_s  : u_sfixed_v(1 to MULTIPLICANDS'length)(NORM_OUT_HIGH downto NORM_OUT_LOW);

   signal   aux_input_u   : u_ufixed(NORM_IN_HIGH downto NORM_IN_LOW);
   signal   aux_output_u  : u_ufixed_v(1 to MULTIPLICANDS'length)(NORM_OUT_HIGH downto NORM_OUT_LOW);

/*================================================================================================*/
/*================================================================================================*/

begin

   generate_debugging:
   if DEBUGGING generate
      msg_debug("real_const_mult : NORM_IN_HIGH: " & image(NORM_IN_HIGH));
      msg_debug("real_const_mult : NORM_IN_LOW: " & image(NORM_IN_LOW));
      msg_debug("real_const_mult : NORM_OUT_HIGH: " & image(NORM_OUT_HIGH));
      msg_debug("real_const_mult : NORM_OUT_LOW: " & image(NORM_OUT_LOW));
      end;
   end generate;


   generate_real_const_mult:
   if UNSIGNED_2COMP_opt generate
      constant MULTIPLICANDS_adjusted : real_v(1 to MULTIPLICANDS'length) := MULTIPLICANDS;
   begin
      aux_input_u <= to_ufixed(input, aux_input_u);
      generate_output_members:
      for i in 1 to MULTIPLICANDS'length generate
      begin
         output(i)(OUT_HIGH doWnto OUT_LOW) <= to_sulv(aux_output_u(i));
      end generate;

      real_const_mult_u_1:
      entity work.real_const_mult_u
         generic map(
            SPEED_opt         => SPEED_opt,
            ROUND_STYLE_opt   => ROUND_STYLE_opt,
            ROUND_TO_BIT_opt  => ROUND_TO_BIT_opt,
            MAX_ERROR_PCT_opt => MAX_ERROR_PCT_opt,
            MULTIPLICANDS     => MULTIPLICANDS_adjusted
         )
         port map(
            input        => aux_input_u,
            clk          => clk,
            valid_input  => valid_input,
            output       => aux_output_u,
            valid_output => valid_output
         );

   else generate
      constant MULTIPLICANDS_adjusted : real_v(1 to MULTIPLICANDS'length) := MULTIPLICANDS;
   begin
      aux_input_s <= to_sfixed(input, aux_input_s);
      generate_output_members:
      for i in 1 to MULTIPLICANDS'length generate
      begin
         output(i)(OUT_HIGH doWnto OUT_LOW) <= to_sulv(aux_output_s(i));
      end generate;

      real_const_mult_s_1:
      entity work.real_const_mult_s
         generic map(
            SPEED_opt         => SPEED_opt,
            ROUND_STYLE_opt   => ROUND_STYLE_opt,
            ROUND_TO_BIT_opt  => ROUND_TO_BIT_opt,
            MAX_ERROR_PCT_opt => MAX_ERROR_PCT_opt,
            MULTIPLICANDS     => MULTIPLICANDS_adjusted
         )
         port map(
            input        => aux_input_s,
            clk          => clk,
            valid_input  => valid_input,
            output       => aux_output_s,
            valid_output => valid_output
         );

   end generate;

end architecture;