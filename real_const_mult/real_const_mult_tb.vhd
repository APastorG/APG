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
/     This is a testbench generated for the real_const_mult.
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

entity real_const_mult_tb is

end entity;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

architecture real_const_mult_tb1 of real_const_mult_tb is


/* generics' constants                                                                          1 */
/**************************************************************************************************/
   constant UNSIGNED_2COMP_opt : boolean_tb       := (true, true);       --default
   constant SPEED_opt          : T_speed_tb       := (t_min, true);       --exception: value not set
   constant ROUND_STYLE_opt    : T_round_style_tb := (fixed_round, true);--default
   constant ROUND_TO_BIT_opt   : integer_exc_tb   := (-13, true);         --exception: value not set
   constant MAX_ERROR_PCT_opt  : real_exc_tb      := (0.01, false);        --exception: value not set
   constant MULTIPLICANDS      : real_v           := (44.0, 130.0, 172.0); --compulsory

   constant used_UNSIGNED_2COMP_opt : boolean       := value_used(UNSIGNED_2COMP_opt, false);
   constant used_SPEED_opt          : T_speed       := value_used(SPEED_opt);
   constant used_ROUND_STYLE_opt    : T_round_style := value_used(ROUND_STYLE_opt, fixed_truncate);
   constant used_ROUND_TO_BIT_opt   : integer_exc   := value_used(ROUND_TO_BIT_opt);
   constant used_MAX_ERROR_PCT_opt  : real_exc      := value_used(MAX_ERROR_PCT_opt);
   constant used_MULTIPLICANDS      : real_v        := MULTIPLICANDS;


/* constants                                                                                    2 */
/**************************************************************************************************/
   constant NORM_IN_HIGH  : integer := 0;
   constant NORM_IN_LOW   : integer := -5;

   constant IN_HIGH       : integer := NORM_IN_HIGH + SULV_NEW_ZERO;
   constant IN_LOW        : integer := NORM_IN_LOW + SULV_NEW_ZERO;

   constant NORM_OUT_HIGH : integer := real_const_mult_OH(used_ROUND_STYLE_opt,
                                                          used_ROUND_TO_BIT_opt,
                                                          used_MAX_ERROR_PCT_opt,
                                                          used_MULTIPLICANDS,
                                                          NORM_IN_HIGH,
                                                          NORM_IN_LOW,
                                                          not used_UNSIGNED_2COMP_opt);
   constant NORM_OUT_LOW  : integer := real_const_mult_OL(used_ROUND_STYLE_opt,
                                                          used_ROUND_TO_BIT_opt,
                                                          used_MAX_ERROR_PCT_opt,
                                                          used_MULTIPLICANDS,
                                                          NORM_IN_LOW,
                                                          not used_UNSIGNED_2COMP_opt);

   constant OUT_HIGH      : integer := SULV_NEW_ZERO + NORM_OUT_HIGH;
   constant OUT_LOW       : integer := SULV_NEW_ZERO + NORM_OUT_LOW;


/* signals                                                                                      3 */
/**************************************************************************************************/
   --IN
   signal input        : std_ulogic_vector(IN_HIGH DOWNTO IN_LOW);
   signal clk          : std_ulogic := '1';
   signal valid_input  : std_ulogic := '1';

   --OUT
   signal output           : sulv_v(1 to MULTIPLICANDS'length)(OUT_HIGH downto OUT_LOW);
   signal valid_output     : std_ulogic;


/*================================================================================================*/
/*================================================================================================*/

begin

      real_const_mult_1:
      entity work.real_const_mult
         generic map(
            UNSIGNED_2COMP_opt => used_UNSIGNED_2COMP_opt,
            SPEED_opt          => used_SPEED_opt,
            ROUND_STYLE_opt    => used_ROUND_STYLE_opt,
            ROUND_TO_BIT_opt   => used_ROUND_TO_BIT_opt,
            MAX_ERROR_PCT_opt  => used_MAX_ERROR_PCT_opt,
            MULTIPLICANDS      => used_MULTIPLICANDS)
         port map(
            input        => input,
            clk          => clk,
            valid_input  => valid_input,
            output       => output,
            valid_output => valid_output
         );


   --pragma translate off
   --synthesis translate_off
   process (clk)
   begin
      clk <= not clk after 2 ps;
   end process;

   process
   begin
      valid_input <= '0';
      input <= (others => '0');
      wait for 10 ps;
      valid_input <= '1';
      input <= (SULV_NEW_ZERO => '1', others => '0');
      wait for 4 ps;
      valid_input <= '0';
      input <= (others => '0');
      wait;
   end process;
   
   --pragma translate on
   --synthesis translate_on


end architecture;