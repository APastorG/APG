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
/     This is a testbench generated for the int_const_multiplier module.
/
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
   use work.tb_pkg.all;
   use work.real_const_mult_pkg.all;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

entity int_const_mult_tb is

end entity;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

architecture int_const_mult_tb1 of int_const_mult_tb is


/* constants                                                                                    1 */
/**************************************************************************************************/
   constant UNSIGNED_2COMP_opt : boolean_tb := (true, true);       --default
   constant SPEED_opt          : T_speed_tb := (t_min, false);          --exception: value not set
   constant MULTIPLICANDS      : integer_v  := (2, 7);              --compulsory

   constant used_UNSIGNED_2COMP_opt : boolean   := value_used(UNSIGNED_2COMP_opt, false);
   constant used_SPEED_opt          : T_speed   := value_used(SPEED_opt);
   constant used_MULTIPLICANDS      : integer_v := MULTIPLICANDS;


/* signals                                                                                      2 */
/**************************************************************************************************/
   constant NORMALIZED_IN_HIGH : integer := 1;
   constant NORMALIZED_IN_LOW  : integer := -2;

   function to_real(
      vector : integer_v)
   return real_v is
      variable result : real_v(vector'range);
   begin
      for i in vector'range loop
         result(i) := real(vector(i));
      end loop;
      return result;
   end function;

   constant used_MULTIPLICANDS_real : real_v(MULTIPLICANDS'range) := to_real(used_MULTIPLICANDS);

   constant IN_HIGH  : integer := NORMALIZED_IN_HIGH + SULV_NEW_ZERO;
   constant IN_LOW   : integer := NORMALIZED_IN_LOW + SULV_NEW_ZERO;
   constant OUT_HIGH : integer := SULV_NEW_ZERO + real_const_mult_OH(fixed_truncate,--used_ROUND_STYLE_opt,
                                                                     integer'low,--used_ROUND_TO_BIT_opt,
                                                                     real'low,--used_MAX_ERROR_PCT_opt,
                                                                     used_MULTIPLICANDS_real,
                                                                     NORMALIZED_IN_HIGH,
                                                                     NORMALIZED_IN_LOW,
                                                                     not used_UNSIGNED_2COMP_opt);
   constant OUT_LOW  : integer := SULV_NEW_ZERO + real_const_mult_OL(fixed_truncate,--used_ROUND_STYLE_opt,
                                                                     integer'low,--used_ROUND_TO_BIT_opt,
                                                                     real'low,--used_MAX_ERROR_PCT_opt,
                                                                     used_MULTIPLICANDS_real,
                                                                     NORMALIZED_IN_LOW,
                                                                     not used_UNSIGNED_2COMP_opt);
   --IN
   signal input        : std_ulogic_vector(IN_HIGH DOWNTO IN_LOW);
   signal clk          : std_ulogic;
   signal valid_input  : std_ulogic;

   --OUT
   signal output       : sulv_v(1 to MULTIPLICANDS'length)(OUT_HIGH downto OUT_LOW);
   signal valid_output : std_ulogic;


/*================================================================================================*/
/*================================================================================================*/

begin

      real_const_mult_2:
      entity work.real_const_mult
         generic map(
            UNSIGNED_2COMP_opt => used_UNSIGNED_2COMP_opt,
            SPEED_opt          => used_SPEED_opt,
            --ROUND_STYLE_opt    => used_ROUND_STYLE_opt,
            --ROUND_TO_BIT_opt   => used_ROUND_TO_BIT_opt,
            --MAX_ERROR_PCT_opt  => used_MAX_ERROR_PCT_opt,
            MULTIPLICANDS      => used_MULTIPLICANDS_real)
         port map(
            input        => input,
            clk          => clk,
            valid_input  => valid_input,
            output       => output,
            valid_output => valid_output
         );

end architecture;