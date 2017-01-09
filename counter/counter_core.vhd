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
/     This is a design of a counter that implements different features like reset, enable, load,
/  set, and the direction of counting (up, down, or indicated by an input signal). Additionaly it
/  allows to select the overflow behavior (saturate or wrap), and offers a mode called TARGET_count.
/  This mode outputs only a bit, which indicates when the count reaches a desired value, with the
/  possibility to block it when reaching said value.
/
 **************************************************************************************************/

library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;

library work;
   use work.common_data_types_pkg.all;
   use work.common_pkg.all;
   use work.counter_pkg.all;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

entity counter_core is

   generic(
      UNSIGNED_2COMP_opt     : boolean;
      OVERFLOW_BEHAVIOR_opt  : T_overflow_behavior;
      COUNT_MODE_opt         : T_count_mode;
      COUNTER_WIDTH_dep      : positive_exc;
      TARGET_MODE            : boolean;
      TARGET_dep             : integer_exc;
      TARGET_WITH_COUNT_opt  : boolean_exc;
      TARGET_BLOCKING_opt    : boolean_exc;
      USE_SET                : boolean;
      SET_TO_dep             : integer_exc;
      USE_RESET              : boolean;
      SET_RESET_PRIORITY_opt : T_set_reset_priority;
      USE_LOAD               : boolean
   );

   port(
      clk               : in  std_ulogic;
      enable            : in  std_ulogic;
      count_mode_signal : in  std_ulogic;
      set               : in  std_ulogic;
      reset             : in  std_ulogic;
      load              : in  std_ulogic;
      value_to_load     : in  std_ulogic_vector(counter_CIW(UNSIGNED_2COMP_opt,
                                                            COUNTER_WIDTH_dep,
                                                            TARGET_MODE,
                                                            TARGET_dep,
                                                            USE_SET,
                                                            SET_TO_dep)
                                                downto 1);

      count             : out std_ulogic_vector(counter_CW(UNSIGNED_2COMP_opt,
                                                           COUNTER_WIDTH_dep,
                                                           TARGET_MODE,
                                                           TARGET_dep,
                                                           TARGET_WITH_COUNT_opt = t_true,
                                                           USE_SET,
                                                           SET_TO_dep)
                                                downto 1);
      count_is_TARGET   : out std_ulogic_vector(ite(TARGET_MODE, 1, 0) downto 1)
   );

end entity;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

architecture counter_core1 of counter_core is


/*   constants                                                                                    */
/**************************************************************************************************/

   constant TARGET_WITH_COUNT    : boolean  := TARGET_WITH_COUNT_opt = t_true; --default : false
   constant TARGET_BLOCKING      : boolean  := TARGET_BLOCKING_opt = t_true;   --default : false

   constant MIN_WIDTH_COUNTER_GM : positive := counter_MWCG(UNSIGNED_2COMP_opt,
                                                            TARGET_dep,
                                                            USE_SET,
                                                            SET_TO_dep);
   --counter width 
   constant COUNT_INTER_WIDTH    : natural  := counter_CIW(UNSIGNED_2COMP_opt,
                                                          COUNTER_WIDTH_dep,
                                                          TARGET_MODE,
                                                          TARGET_dep,
                                                          USE_SET,
                                                          SET_TO_dep);
   --used counter width, that is 0 when in target mode and TARGET_WITH_COUNT is false, 
   --COUNT_INTER_WIDTH otherwise
   constant COUNT_WIDTH          : natural  :=counter_CW(UNSIGNED_2COMP_opt,
                                                         COUNTER_WIDTH_dep,
                                                         TARGET_MODE,
                                                         TARGET_dep,
                                                         TARGET_WITH_COUNT,
                                                         USE_SET,
                                                         SET_TO_dep);
   constant COUNTER_WIDTH        : integer  := integer(COUNTER_WIDTH_dep);
   constant TARGET               : integer  := integer(TARGET_dep);



/*   signals                                                                                      */
/**************************************************************************************************/

   signal count_inter : std_ulogic_vector(COUNT_INTER_WIDTH downto 1) := (others => '0');


/*   procedures to update the value of the count                                                  */
/**************************************************************************************************/

   procedure set_routine (
      signal counter : inout std_ulogic_vector) is
   begin
      counter <= sulv_from_int(SET_TO_dep, not UNSIGNED_2COMP_opt, COUNT_INTER_WIDTH);
   end procedure;

   procedure reset_routine (
      signal counter : inout std_ulogic_vector) is
   begin
      counter <= sulv_from_int(0, not UNSIGNED_2COMP_opt, COUNT_INTER_WIDTH);
   end procedure;

   procedure load_routine (
      signal counter       : inout std_ulogic_vector;
      signal value_to_load : in    std_ulogic_vector) is
   begin
      counter <= value_to_load;
   end procedure;

   procedure count_routine (
      signal count             : inout std_ulogic_vector;
      signal count_mode_signal : in    std_ulogic) is
   begin--count upwards
            if COUNT_MODE_opt = t_up
               or
               (COUNT_MODE_opt = t_input_signal and count_mode_signal = '1')
            then
               --count when not on the upper limit or when behavior is to wrap
               if count /= max_vec(count, not UNSIGNED_2COMP_opt) 
                  or
                  OVERFLOW_BEHAVIOR_opt = t_wrap
               then
                  --increase count
                  if UNSIGNED_2COMP_opt then
                     count <= unsigned(count) + 1;
                  else
                     count <= signed(count) + 1;
                  end if;
               end if;
            --count downwards
            else
               --count when not on the lower limit or when behavior is to wrap
               if count /= min_vec(count, not UNSIGNED_2COMP_opt) 
                  or
                  OVERFLOW_BEHAVIOR_opt = t_wrap
               then
                  --decrease count
                  if UNSIGNED_2COMP_opt then
                     count <= unsigned(count) - 1;
                  else
                     count <= signed(count) - 1;
                  end if;
               end if;
            end if;
   end procedure;

/*================================================================================================*/
/*================================================================================================*/

begin


/* generate the count value and count_is_TARGET if in TARGET mode                                 */
/**************************************************************************************************/
   generate_count_value:
   if TARGET_MODE generate
      begin
         count_is_TARGET(1) <= count_inter ?= sulv_from_int(TARGET,
                                                            not UNSIGNED_2COMP_opt,
                                                            count_inter'length);

         generate_count_in_TARGET_mode:
         if TARGET_WITH_COUNT generate
            begin
               count <= count_inter;
            end;
         end generate;

      end;
   else generate
      begin
         count <= count_inter;
      end;
   end generate;


/* update the count value (count_inter)                                                           */
/**************************************************************************************************/
   process (clk)
   begin
      if rising_edge(clk) then
         --1st: set if there's no reset or if set has priority
         if USE_SET and set='1' and
            ((USE_RESET and SET_RESET_PRIORITY_opt=t_set) or not USE_RESET) then
            set_routine(count_inter);
         --2nd: reset
         elsif USE_RESET and reset='1' then
            reset_routine(count_inter);
         --3rd: set if there's reset and it has priority
         elsif USE_SET and set='1' and
            (USE_RESET and SET_RESET_PRIORITY_opt=t_reset) then
            set_routine(count_inter);
         --4th: load
         elsif USE_LOAD and load='1' then
            load_routine(count_inter, value_to_load);
         --5th: increase count (unless we are in TARGET mode, the count is TARGET and the behavior is
         --   blocking)
         elsif (enable='1' and not(TARGET_MODE
                                  and count_inter = sulv_from_int(TARGET,
                                                                  not UNSIGNED_2COMP_opt,
                                                                  count_inter'length)
                                  and TARGET_BLOCKING)) then
            if COUNT_WIDTH = 1 then
               count_inter <= not count_inter;
            else
               count_routine(count_inter, count_mode_signal);
            end if;
         end if;
      end if;
   end process;

end architecture;