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
/     This is a testbench generated for the real_const_multiplier module.
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
   use work.average_calculator_pkg.all;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

entity average_calculator_tb is

end entity;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

architecture average_calculator_tb1 of average_calculator_tb is


/* generics' constants                                                                          1 */
/**************************************************************************************************/
   constant UNSIGNED_2COMP_opt        : boolean_tb       := (true, true);         --default
   constant DATA_IMM_AFTER_START_opt  : boolean_tb       := (false, false);       --default
   constant SPEED_opt                 : T_speed_tb       := (t_max, false);       --exception: value not set
   constant ROUND_STYLE_opt           : T_round_style_tb := (fixed_round, false); --default
   constant ROUND_TO_BIT_opt          : integer_exc_tb   := (-2, false);          --exception: value not set
   constant MAX_ERROR_PCT_opt         : real_exc_tb      := (0.01, false);        --exception: value not set
   constant S                         : positive         := 2;                    --compulsory

   constant used_UNSIGNED_2COMP_opt        : boolean       := value_used(UNSIGNED_2COMP_opt, false);
   constant used_DATA_IMM_AFTER_START_opt  : boolean       := value_used(DATA_IMM_AFTER_START_opt, true);
   constant used_SPEED_opt                 : T_speed       := value_used(SPEED_opt);
   constant used_ROUND_STYLE_opt           : T_round_style := value_used(ROUND_STYLE_opt, fixed_truncate);
   constant used_ROUND_TO_BIT_opt          : integer_exc   := value_used(ROUND_TO_BIT_opt);
   constant used_MAX_ERROR_PCT_opt         : real_exc      := value_used(MAX_ERROR_PCT_opt);
   constant used_S                         : positive      := S;


/* constants                                                                                    2 */
/**************************************************************************************************/
   constant P             : positive := 1;
   constant NORM_IN_HIGH  : integer  := 3;
   constant NORM_IN_LOW   : integer  := -3;

   constant IN_HIGH       : integer  := NORM_IN_HIGH + SULV_NEW_ZERO;
   constant IN_LOW        : integer  := NORM_IN_LOW + SULV_NEW_ZERO;


   constant NORM_OUT_HIGH : integer   := average_calculator_OH(used_UNSIGNED_2COMP_opt,
                                                               used_ROUND_STYLE_opt,
                                                               used_ROUND_TO_BIT_opt,
                                                               used_MAX_ERROR_PCT_opt,
                                                               used_S,
                                                               P,
                                                               NORM_IN_HIGH,
                                                               NORM_IN_LOW);

   constant NORM_OUT_LOW  : integer   := average_calculator_OL(used_UNSIGNED_2COMP_opt,
                                                               used_ROUND_STYLE_opt,
                                                               used_ROUND_TO_BIT_opt,
                                                               used_MAX_ERROR_PCT_opt,
                                                               used_S,
                                                               P,
                                                               NORM_IN_HIGH,
                                                               NORM_IN_LOW);

   constant OUT_HIGH      : integer  := SULV_NEW_ZERO + NORM_OUT_HIGH;
   constant OUT_LOW       : integer  := SULV_NEW_ZERO + NORM_OUT_LOW;


/* signals                                                                                      3 */
/**************************************************************************************************/
   --IN
   signal input        : sulv_v(1 to P)(IN_HIGH DOWNTO IN_LOW);
   signal clk          : std_ulogic;
   signal start        : std_ulogic;
   signal valid_input  : std_ulogic;

   --OUT
   signal output       : std_ulogic_vector(OUT_HIGH downto OUT_LOW);
   signal valid_output : std_ulogic;


/*================================================================================================*/
/*================================================================================================*/

begin

   average_calculator_1:
   entity work.average_calculator
      generic map(
         UNSIGNED_2COMP_opt       => used_UNSIGNED_2COMP_opt,
         DATA_IMM_AFTER_START_opt => used_DATA_IMM_AFTER_START_opt,
         SPEED_opt            => used_SPEED_opt,
         ROUND_STYLE_opt          => used_ROUND_STYLE_opt,
         ROUND_TO_BIT_opt         => used_ROUND_TO_BIT_opt,
         MAX_ERROR_PCT_opt        => used_MAX_ERROR_PCT_opt,
         S                        => used_S)
      port map(
         input        => input,
         clk          => clk,
         start        => start,
         valid_input  => valid_input,
         output       => output,
         valid_output => valid_output
      );

end architecture;