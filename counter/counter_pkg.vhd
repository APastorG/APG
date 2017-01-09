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
/  Description:
/  ¯¯¯¯¯¯¯¯¯¯¯
/     This package contains necessary types, constants, and functions for the parameterized counter
/  design.
/
 **************************************************************************************************/

library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;

library work;
   use work.common_pkg.all;
   use work.common_data_types_pkg.all;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

package counter_pkg is


/* types and related functions                                                                  1 */
/**************************************************************************************************/

   type T_count_mode is (t_up, t_down, t_input_signal);

   type T_overflow_behavior is (t_saturate, t_wrap);

   type T_target_count_behavior is (t_blocking, t_non_blocking);

   type T_set_reset_priority is (t_set, t_reset);


   function ite(
      cond              : boolean;
      if_true, if_false : T_count_mode)
   return T_count_mode;

   function ite(
      cond              : boolean;
      if_true, if_false : T_overflow_behavior)
   return T_overflow_behavior;

   function ite(
      cond              : boolean;
      if_true, if_false : T_target_count_behavior)
   return T_target_count_behavior;

   function ite(
      cond              : boolean;
      if_true, if_false : T_set_reset_priority)
   return T_set_reset_priority;


/* function to check the consistency and correctness of generics                                2 */
/**************************************************************************************************/

   function counter_CHECKS (
      unsigned_2comp_opt, target_mode, use_set, use_reset, use_load: boolean;
      target_blocking_opt : boolean_exc;
      target_dep, set_to_dep: integer_exc;
      counter_width_dep: positive_exc)
   return natural;


/* functions for corrected generics and internal/external port signals                          3 */
/**************************************************************************************************/

   function counter_MWCG(
      unsigned_2comp_opt : boolean;
      target_dep         : integer_exc;
      use_set            : boolean;
      set_to_dep         : integer_exc)
   return positive;

   function counter_CIW(
      unsigned_2comp_opt : boolean;
      counter_width_dep  : positive_exc;
      target_mode        : boolean;
      target_dep         : integer_exc;
      use_set            : boolean;
      set_to_dep         : integer_exc)
   return positive;

   function counter_CW(
      unsigned_2comp_opt : boolean;
      counter_width_dep  : positive_exc;
      target_mode        : boolean;
      target_dep         : integer_exc;
      target_with_count  : boolean;
      use_set            : boolean;
      set_to_dep         : integer_exc)
   return natural;


end package;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

package body counter_pkg is


/********************************************************************************************** 1 */

   function ite(
      cond              : boolean;
      if_true, if_false : T_count_mode)
   return T_count_mode is
   begin
      if cond then
         return(if_true);
      else
         return(if_false);
      end if;
   end function ite;

   function ite(
      cond              : boolean;
      if_true, if_false : T_overflow_behavior)
   return T_overflow_behavior is
   begin
      if cond then
         return(if_true);
      else
         return(if_false);
      end if;
   end function ite;

   function ite(
      cond              : boolean;
      if_true, if_false : T_target_count_behavior)
   return T_target_count_behavior is
   begin
      if cond then
         return(if_true);
      else
         return(if_false);
      end if;
   end function ite;

   function ite(
      cond              : boolean;
      if_true, if_false : T_set_reset_priority)
   return T_set_reset_priority is
   begin
      if cond then
         return(if_true);
      else
         return(if_false);
      end if;
   end function ite;


/********************************************************************************************** 2 */

   function counter_CHECKS (
      unsigned_2comp_opt, target_mode, use_set, use_reset, use_load: boolean;
      target_blocking_opt : boolean_exc;
      target_dep, set_to_dep: integer_exc;
      counter_width_dep: positive_exc)
   return natural is
      constant target          : integer := integer(target_dep);
      constant set_to          : integer := integer(set_to_dep);
      constant counter_width   : integer := integer(counter_width_dep);
      variable target_min_bits : positive;
      variable set_to_min_bits : positive;
      variable counter_w       : natural;
   begin

      --error: target mode but target not set
      assert not(target_mode and target=integer'low)
         report "(1) " &
            "ILLEGAL PARAMETERS in entity counter: in target mode (target_MODE=true) the parameter " &
            "target_dep must be assigned a value."
         severity error;

      --error: negative target in an unsigned counter
      assert not (target_mode and unsigned_2comp_opt and target<0)
         report "(2) " &
            "ILLEGAL PARAMETERS in entity counter: cannot have a negative number as the target " &
            "in an unsigned counter. Generic UNSIGNED_2COMP should be false."
         severity error;

      --error: negative set_to in an unsigned counter
      assert not (unsigned_2comp_opt and use_set and set_to<0)
         report "(3) " &
            "ILLEGAL PARAMETERS in entity counter: cannot have a negative number as the value" &
            " to set the counter to when set='1'. Generic UNSIGNED_2COMP should be false."
         severity error;

      counter_w := counter_CIW(unsigned_2comp_opt,
                              counter_width_dep,
                              target_mode,
                              target_dep,
                              use_set,
                              set_to_dep);

      --error: COUNTER_WIDTH is not set when in normal mode
      assert not(not target_mode and counter_width=0)
         report "(4) " &
            "MISSING PARAMETERS in entity counter: when in normal mode (target_MODE = false) " &
            "the value of the generic COUNTER_WIDTH must be set."
         severity error;

      --error: SET_TO_dep is not set when USE_SET is true
      assert not(use_set and set_to=integer'low)
         report "(5) " &
            "MISSING PARAMETERS in entity counter: when using set (USE_SET = true) " &
            "the value of the generic SET_TO_dep must be set."
         severity error;

      if target_mode then
         target_min_bits:= min_bits(target, not unsigned_2comp_opt);
      else
         target_min_bits := 1;
      end if;

      --error: the width of the counter is not enough for target
      assert not(target_mode and counter_w<target_min_bits)
         report "(6) " &
            "ILLEGAL PARAMETERS in entity counter: the specified counter width (" &
             image(counter_w) & ") is not enough for the stated target (" &
             image(target_dep) & "). At least " & image(target_min_bits) &
             " bits are necessary."
         severity error;

      if use_set then
         set_to_min_bits := min_bits(set_to, not unsigned_2comp_opt);
      else
         set_to_min_bits := 1;
      end if;

      --error: the width of the counter is not enough for set_to
      assert not(use_set and counter_w<set_to_min_bits)
         report "(7) " &
            "ILLEGAL PARAMETERS in entity counter: the specified counter width (" &
             image(counter_w) & ") is not enough for the stated set_to (" &
             image(set_to) & "). At least " & image(set_to_min_bits) &
             " bits are necessary."
         severity error;

      --warning: target blocking but neither set, reset, nor load (permanent block)
      assert not(target_mode and target_blocking_opt=t_true and
            not(use_set or use_reset or use_load))
         report "(11) " &
            "With the specified parameters, the counter module will reach a permanent block "&
            "once it reaches the target"
         severity warning;


      return 0;
   end function;


/********************************************************************************************** 3 */

   function counter_MWCG(
      unsigned_2comp_opt : boolean;
      target_dep         : integer_exc;
      use_set            : boolean;
      set_to_dep         : integer_exc)
   return positive is
   begin
      if use_set then
         return maximum(min_bits(target_dep, not unsigned_2comp_opt),
                        min_bits(set_to_dep, not unsigned_2comp_opt));
      else
         return min_bits(target_dep, not unsigned_2comp_opt);
      end if;
   end function;


   function counter_CIW(
      unsigned_2comp_opt : boolean;
      counter_width_dep  : positive_exc;
      target_mode        : boolean;
      target_dep         : integer_exc;
      use_set            : boolean;
      set_to_dep         : integer_exc)
   return positive is
   begin
      if target_mode then
         if counter_width_dep = 0 then
            return counter_MWCG(unsigned_2comp_opt,
                                target_dep,
                                use_set,
                                set_to_dep);
         else 
            return positive(counter_width_dep);
         end if;
      else
         return positive(counter_width_dep);
      end if;
   end function;


   function counter_CW(
      unsigned_2comp_opt : boolean;
      counter_width_dep  : positive_exc;
      target_mode        : boolean;
      target_dep         : integer_exc;
      target_with_count  : boolean;
      use_set            : boolean;
      set_to_dep         : integer_exc)
   return natural is
   begin
      if target_mode then
         if target_with_count then
            if counter_width_dep = 0 then
               return counter_MWCG(unsigned_2comp_opt,
                                   target_dep,
                                   use_set,
                                   set_to_dep);
            else 
               return natural(counter_width_dep);
            end if;
         else
            return 0;
         end if;
      else
         return natural(counter_width_dep);
      end if;
   end function;


end package body;
