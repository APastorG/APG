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
/  Vivado by Xilinx 
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

entity real_const_mult_u is

   generic(
      SPEED_opt         : T_speed       := t_exc;          --exception: value not set
      ROUND_STYLE_opt   : T_round_style := fixed_truncate; --default
      ROUND_TO_BIT_opt  : integer_exc   := integer'low;    --exception: value not set
      MAX_ERROR_PCT_opt : real_exc      := real'low;       --exception: value not set
      MULTIPLICANDS     : real_v                           --compulsory
   );

   port(
      input        : in  u_ufixed;
      clk          : in  std_ulogic;
      valid_input  : in  std_ulogic;

      output       : out u_ufixed_v;
      valid_output : out std_ulogic
   );

end entity;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

architecture real_const_mult_u_1 of real_const_mult_u is

   constant CHECKS : integer := real_const_mult_CHECKS(input'high,
                                                       input'low,
                                                       true, --UNSIGNED_2COMP_opt,
                                                       ROUND_TO_BIT_opt,
                                                       MAX_ERROR_PCT_opt,
                                                       MULTIPLICANDS);

   constant MULTIPLICANDS_adjusted : real_v(1 to MULTIPLICANDS'length) := MULTIPLICANDS;

/*================================================================================================*/
/*================================================================================================*/

begin


   real_const_mult_core_u_1:
   entity work.real_const_mult_core_u
      generic map(
         SPEED_opt         => SPEED_opt,
         ROUND_STYLE_opt   => ROUND_STYLE_opt,
         ROUND_TO_BIT_opt  => ROUND_TO_BIT_opt,
         MAX_ERROR_PCT_opt => MAX_ERROR_PCT_opt,
         CONSTANTS         => MULTIPLICANDS_adjusted,
         input_high        => input'high,
         input_low         => input'low
      )
      port map(
         input        => input,
         clk          => clk,
         valid_input  => valid_input,
         output       => output,
         valid_output => valid_output
      );


end architecture;