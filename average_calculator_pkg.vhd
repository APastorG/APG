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
/     This package contains necessary types, constants, and functions for the parameterized average
/  calculator design.
/
 **************************************************************************************************/

library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;
   use ieee.math_real.all;

library work;
   use work.common_data_types_pkg.all;
   use work.adder_pkg.all;
   use work.real_const_mult_pkg.all;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

package average_calculator_pkg is


/* function                                                                                     1 */
/**************************************************************************************************/

--   function average_calculator_CHECKS()
--  return integer;

   function average_calculator_IH(
      s                  : positive;
      p                  : positive;
      input_high         : integer)
   return integer;

   function average_calculator_IL(
      round_to_bit_opt : integer_exc;
      input_low        : integer)
   return integer;

   function average_calculator_OH(
      unsigned_2comp_opt : boolean;
      round_style_opt    : T_round_style;
      round_to_bit_opt   : integer_exc;
      max_error_pct_opt  : real_exc;
      s                  : positive;
      p                  : positive;
      input_high         : integer;
      input_low          : integer)
   return integer;

   function average_calculator_OL(
      unsigned_2comp_opt : boolean;
      round_style_opt    : T_round_style;
      round_to_bit_opt   : integer_exc;
      max_error_pct_opt  : real_exc;
      s                  : positive;
      p                  : positive;
      input_high         : integer;
      input_low          : integer)
   return integer;

end package;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

Package body average_calculator_pkg is


/********************************************************************************************** 1 */

   function average_calculator_IH(
      s                  : positive;
      p                  : positive;
      input_high         : integer)
   return integer is
   begin
      return adder_OH(integer'low,
                      s,
                      p,
                      input_high);
   end function;

   function average_calculator_IL(
      round_to_bit_opt : integer_exc;
      input_low        : integer)
   return integer is
   begin
      return adder_OL(round_to_bit_opt,
                      input_low);
   end function;

   function average_calculator_OH(
      unsigned_2comp_opt : boolean;
      round_style_opt    : T_round_style;
      round_to_bit_opt   : integer_exc;
      max_error_pct_opt  : real_exc;
      s                  : positive;
      p                  : positive;
      input_high         : integer;
      input_low          : integer)
   return integer is
      constant inter_high : integer := average_calculator_IH(s,
                                                             p,
                                                             input_high);
      constant inter_low  : integer := average_calculator_IL(round_to_bit_opt,
                                                             input_low);
      constant constants  : real_v(1 to 1) := (1 => 1.0/real(p*s));
   begin
      return real_const_mult_OH(round_style_opt,
                                round_to_bit_opt,
                                max_error_pct_opt,
                                constants,
                                inter_high,
                                inter_low,
                                not unsigned_2comp_opt);
   end function;

   function average_calculator_OL(
      unsigned_2comp_opt : boolean;
      round_style_opt    : T_round_style;
      round_to_bit_opt   : integer_exc;
      max_error_pct_opt  : real_exc;
      s                  : positive;
      p                  : positive;
      input_high         : integer;
      input_low          : integer)
   return integer is
      constant inter_high : integer := average_calculator_IH(s,
                                                             p,
                                                             input_high);
      constant inter_low  : integer := average_calculator_IL(round_to_bit_opt,
                                                             input_low);
      constant constants  : real_v(1 to 1) := (1 => 1.0/real(p*s));
   begin
      return real_const_mult_OL(round_style_opt,
                                round_to_bit_opt,
                                max_error_pct_opt,
                                constants,
                                inter_low,
                                not unsigned_2comp_opt);
   end function;


end package body;