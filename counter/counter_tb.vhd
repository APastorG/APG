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
/     This is a testbench generated for the counter module.
/
 **************************************************************************************************/

library ieee;
   use ieee.math_real.all;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;
   use ieee.fixed_pkg.all;

library work;
   use work.common_data_types_pkg.all;
   use work.common_pkg.all;
   use work.counter_pkg.all;
   use work.tb_pkg.all;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

entity counter_tb is

end entity;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

architecture counter_tb1 of counter_tb is


/* types                                                                                          */
/**************************************************************************************************/

   type T_overflow_behavior_tb is record
      value      : T_overflow_behavior;
      is_defined : boolean;
   end record;

   type T_count_mode_tb is record
      value      : T_count_mode;
      is_defined : boolean;
   end record;

   type T_set_reset_priority_tb is record
      value      : T_set_reset_priority;
      is_defined : boolean;
   end record;


/* constants                                                                                      */
/**************************************************************************************************/

   constant UNSIGNED_2COMP_opt     : boolean_tb              := (true, true);
   constant OVERFLOW_BEHAVIOR_opt  : T_overflow_behavior_tb  := (t_wrap, false);
                                                             --t_saturate, t_wrap
   constant COUNT_MODE_opt         : T_count_mode_tb         := (t_up, true);
                                                             --t_up, t_down, t_input_signal
   constant COUNTER_WIDTH_dep      : positive_exc_tb         := (1, false);
   constant TARGET_MODE            : boolean                 := true;
   constant TARGET_dep             : integer_exc_tb          := (1, true);
   constant TARGET_WITH_COUNT_opt  : boolean_exc_tb          := (t_false, true);--t_true, t_false
   constant TARGET_BLOCKING_opt    : boolean_exc_tb          := (t_false, true);--t_true, t_false
   constant USE_SET                : boolean                 := true;
   constant SET_TO_dep             : integer_exc_tb          := (1, true);
   constant USE_RESET              : boolean                 := true;
   constant SET_RESET_PRIORITY_opt : T_set_reset_priority_tb := (t_set, true);--t_set, t_reset
   constant USE_LOAD               : boolean                 := false;

   constant used_UNSIGNED_2COMP_opt     : boolean
                                        := ite(UNSIGNED_2COMP_opt.is_defined,
                                               UNSIGNED_2COMP_opt.value,
                                               false);
   constant used_OVERFLOW_BEHAVIOR_opt  : T_overflow_behavior
                                        := ite(OVERFLOW_BEHAVIOR_opt.is_defined,
                                               OVERFLOW_BEHAVIOR_opt.value,
                                               t_wrap);
   constant used_COUNT_MODE_opt         : T_count_mode
                                        := ite(COUNT_MODE_opt.is_defined,
                                               COUNT_MODE_opt.value,
                                               t_up);
   constant used_COUNTER_WIDTH_dep      : positive_exc
                                        := ite(COUNTER_WIDTH_dep.is_defined,
                                               COUNTER_WIDTH_dep.value,
                                               0);
   constant used_TARGET_dep               : integer_exc
                                        := ite(TARGET_dep.is_defined,
                                               TARGET_dep.value,
                                               integer'low);
   constant used_TARGET_WITH_COUNT_opt    : boolean_exc
                                        := ite(TARGET_WITH_COUNT_opt.is_defined,
                                               TARGET_WITH_COUNT_opt.value,
                                               t_exc);
   constant used_TARGET_BLOCKING_opt      : boolean_exc
                                        := ite(TARGET_BLOCKING_opt.is_defined,
                                               TARGET_BLOCKING_opt.value,
                                               t_exc);
   constant used_SET_TO_dep             : integer_exc
                                        := ite(SET_TO_dep.is_defined,
                                               SET_TO_dep.value,
                                               integer'low);
   constant used_SET_RESET_PRIORITY_opt : T_set_reset_priority
                                        := ite(SET_RESET_PRIORITY_opt.is_defined,
                                               SET_RESET_PRIORITY_opt.value,
                                               t_reset);


/* signals                                                                                        */
/**************************************************************************************************/
   --IN--
   signal clk               : std_ulogic := '1';
   signal enable            : std_ulogic := '0';
   signal count_mode_signal : std_ulogic := '0';
   signal set               : std_ulogic := '0';
   signal reset             : std_ulogic := '0';
   signal load              : std_ulogic := '0';
   signal value_to_load     : std_ulogic_vector(counter_CIW(used_UNSIGNED_2COMP_opt,
                                                            used_COUNTER_WIDTH_dep,
                                                            TARGET_MODE,
                                                            used_TARGET_dep,
                                                            USE_SET,
                                                            used_SET_TO_dep)
                                                downto 1);

   --OUT--
   signal count             : std_ulogic_vector(counter_CW(used_UNSIGNED_2COMP_opt,
                                                           used_COUNTER_WIDTH_dep,
                                                           TARGET_MODE,
                                                           used_TARGET_dep,
                                                           used_TARGET_WITH_COUNT_opt = t_true,
                                                           USE_SET,
                                                           used_SET_TO_dep)
                                                downto 1); 
   signal count_is_target   : std_ulogic_vector(ite(TARGET_MODE, 1, 0) downto 1);

constant test1 : std_ulogic_vector := "101101";
constant test2 : std_ulogic_vector := "010010";
/*================================================================================================*/
/*================================================================================================*/

begin

   counter1:
   entity work.counter
      generic map(
         UNSIGNED_2COMP_opt     => used_UNSIGNED_2COMP_opt,
         OVERFLOW_BEHAVIOR_opt  => used_OVERFLOW_BEHAVIOR_opt,
         COUNT_MODE_opt         => used_COUNT_MODE_opt,
         COUNTER_WIDTH_dep      => used_COUNTER_WIDTH_dep,
         TARGET_MODE            => TARGET_MODE,
         TARGET_dep             => used_TARGET_dep,
         TARGET_WITH_COUNT_opt  => used_TARGET_WITH_COUNT_opt,
         TARGET_BLOCKING_opt    => used_TARGET_BLOCKING_opt,
         USE_SET                => USE_SET,
         SET_TO_dep             => used_SET_TO_dep,
         USE_RESET              => USE_RESET,
         SET_RESET_PRIORITY_opt => used_SET_RESET_PRIORITY_opt,
         USE_LOAD               => USE_LOAD
      )
      port map(
         clk               => clk,
         enable            => enable,
         count_mode_signal => count_mode_signal,
         set               => set,
         reset             => reset,
         load              => load,
         value_to_load     => value_to_load,
         count             => count,
         count_is_target   => count_is_target
      );

-- pragma translate_off

      process (clk)
      begin
         clk <= not clk after 2 ps;
      end process;

      process (enable)
      begin
         enable <= not enable after 5 ps;
      end process;

      process
      begin
            count_mode_signal                  <= '1';
            reset                              <= '1';
            set                                <= '0';
            load                               <= '0';
            value_to_load                      <= (others => '1');
            value_to_load(value_to_load'left)  <= '0';
            value_to_load(value_to_load'right) <= '0';
         wait for 25 ps;
            reset             <= '1';
            set               <= '1';
         wait for 25 ps;
            reset             <= '0';
            set               <= '0';
         wait for 25 ps;
            reset             <= '0';
            set               <= '1';
         wait for 10 ps;
            reset             <= '0';
            set               <= '0';
         wait for 35 ps;
            count_mode_signal <= '0';
         wait for 30 ps;
            load              <= '1';
         wait for 10 ps;
            load              <= '0';
            wait for 200 ps;
         wait;
      end process;

-- pragma translate_on

end architecture;
