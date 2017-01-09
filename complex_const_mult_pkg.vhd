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
 **************************************************************************************************/

library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;
   use ieee.math_real.all;

library work;
   use work.common_data_types_pkg.all;
   use work.common_pkg.all;
   use work.real_const_mult_pkg.all;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

package complex_const_mult_pkg is


/* function                                                                                     1 */
/**************************************************************************************************/

   --returns the output signals' low index, which is the lowest of the low indexes of the partial output signals
   function complex_const_mult_OL(
      round_style_opt   : T_round_style;
      round_to_bit_opt  : integer_exc;
      max_error_pct_opt : real_exc;
      min_output_bit    : integer_exc;
      constants         : real_v;
      input_low         : integer;
      is_signed         : boolean)
   return integer;

   --returns the output signals' high index, which is the highest of the high indexes of the partial output signals
   function complex_const_mult_OH(
      round_style_opt   : T_round_style;
      round_to_bit_opt  : integer_exc;
      max_error_pct_opt : real_exc;
      max_output_bit    : integer_exc;
      constants         : real_v;
      input_high        : integer;
      input_low         : integer;
      is_signed         : boolean)
   return integer;



end package;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

Package body complex_const_mult_pkg is


/********************************************************************************************** 1 */
   --returns the output signals' low index, which is the lowest of the low indexes of the partial output signals
   function complex_const_mult_OL(
      round_style_opt   : T_round_style;
      round_to_bit_opt  : integer_exc;
      max_error_pct_opt : real_exc;
      min_output_bit    : integer_exc;
      constants         : real_v;
      input_low         : integer;
      is_signed         : boolean)
   return integer is
      variable result : integer := real_const_mult_OL(round_style_opt   => round_style_opt,
                                                      round_to_bit_opt  => round_to_bit_opt,
                                                      max_error_pct_opt => max_error_pct_opt,
                                                      constants         => constants,
                                                      input_low         => input_low,
                                                      is_signed         => is_signed);
   begin
      if min_output_bit /= integer'low then
         return maximum(result, min_output_bit);
      else
         return result;
      end if;
   end function;

   --returns the output signals' high index, which is the highest of the high indexes of the partial output signals
   function complex_const_mult_OH(
      round_style_opt   : T_round_style;
      round_to_bit_opt  : integer_exc;
      max_error_pct_opt : real_exc;
      max_output_bit    : integer_exc;
      constants         : real_v;
      input_high        : integer;
      input_low         : integer;
      is_signed         : boolean)
   return integer is
      variable result : integer := real_const_mult_OH(round_style_opt   => round_style_opt,
                                                      round_to_bit_opt  => round_to_bit_opt,
                                                      max_error_pct_opt => max_error_pct_opt,
                                                      constants         => constants,
                                                      input_high        => input_high,
                                                      input_low         => input_low,
                                                      is_signed         => is_signed);
   begin
      --if not (
      --          (constants(0) = 0.0 and constants(1)>-1.0 and constants(1)<=1.0)
      --          or
      --          (constants(1) = 0.0 and constants(0)>-1.0 and constants(0)<=1.0)
      --       )
      --then
      --   result := result + 1;
      --end if;
      if max_output_bit /= integer'low then
         return minimum(result, max_output_bit);
      else
         return result;
      end if;
   end function;




end package body;