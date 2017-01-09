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
/     This is the interface between the instantiation of a counter an its content. It exists to
/  circumvent the impossibility of reading the attributes of an unconstrained port signal inside the
/  port declaration of an entity. (e.g. to declare an output's size, which depends on an input's
/  size).
/     Additionally, the generics' consistency and correctness is checked in here.
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

entity counter is

   generic(
      UNSIGNED_2COMP_opt     : boolean              := true;         --default
      OVERFLOW_BEHAVIOR_opt  : T_overflow_behavior  := t_wrap;       --default
      COUNT_MODE_opt         : T_count_mode         := t_up;         --default
      COUNTER_WIDTH_dep      : positive_exc         := 0;            --exception : value not set
      TARGET_MODE            : boolean;                              --compulsory
      TARGET_dep             : integer_exc          := integer'low;  --exception : value not set
      TARGET_WITH_COUNT_opt  : boolean_exc          := t_exc;        --default
      TARGET_BLOCKING_opt    : boolean_exc          := t_exc;        --default
      USE_SET                : boolean;                              --compulsory
      SET_TO_dep             : integer_exc          := integer'low;  --exception : value not set
      USE_RESET              : boolean;                              --compulsory
      SET_RESET_PRIORITY_opt : T_set_reset_priority := t_reset;      --default
      USE_LOAD               : boolean                               --compulsory
   );

   port(
      clk               : in  std_ulogic;
      enable            : in  std_ulogic;
      set               : in  std_ulogic := 'U';
      reset             : in  std_ulogic := 'U';
      load              : in  std_ulogic := 'U';
      count_mode_signal : in  std_ulogic := 'U';
      value_to_load     : in  std_ulogic_vector:= (counter_CIW(UNSIGNED_2COMP_opt,
                                                              COUNTER_WIDTH_dep,
                                                              TARGET_MODE,
                                                              TARGET_dep,
                                                              USE_SET,
                                                              SET_TO_dep) downto 1
                                                => 'U');

      count             : out std_ulogic_vector;
      count_is_target   : out std_ulogic_vector
   );

end entity;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

architecture counter1 of counter is

   constant CHECKS : integer := counter_CHECKS(UNSIGNED_2COMP_opt,
                                               TARGET_MODE,
                                               USE_SET,
                                               USE_RESET,
                                               USE_LOAD,
                                               TARGET_BLOCKING_opt,
                                               TARGET_dep,
                                               SET_TO_dep,
                                               COUNTER_WIDTH_dep);

begin


   counter_core1:
   entity work.counter_core
      generic map(
         UNSIGNED_2COMP_opt     => UNSIGNED_2COMP_opt,
         OVERFLOW_BEHAVIOR_opt  => OVERFLOW_BEHAVIOR_opt,
         COUNT_MODE_opt         => COUNT_MODE_opt,
         COUNTER_WIDTH_dep      => COUNTER_WIDTH_dep,
         TARGET_MODE            => TARGET_MODE,
         TARGET_dep             => TARGET_dep,
         TARGET_WITH_COUNT_opt  => TARGET_WITH_COUNT_opt,
         TARGET_BLOCKING_opt    => TARGET_BLOCKING_opt,
         USE_SET                => USE_SET,
         SET_TO_dep             => SET_TO_dep,
         USE_RESET              => USE_RESET,
         SET_RESET_PRIORITY_opt => SET_RESET_PRIORITY_opt,
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


end architecture;