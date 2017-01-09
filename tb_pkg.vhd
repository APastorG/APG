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
/     This package contains functions and utilities that are used in testbenches
/
 **************************************************************************************************/

library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;
   use ieee.math_real.all;

library work;
   use work.common_pkg.all;
   use work.fixed_generic_pkg.all;
   use work.common_data_types_pkg.all;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

package tb_pkg is

   function exception_value(
      arg : positive_exc)
   return integer;

   function exception_value(
      arg : positive_exc)
   return positive_exc;

   function exception_value(
      arg : natural_exc)
   return integer;

   function exception_value(
      arg : natural_exc)
   return natural_exc;

   function exception_value(
      arg : integer_exc)
   return integer_exc;

   function exception_value(
      arg : real_exc)
   return real_exc;

   function exception_value(
      arg : boolean_exc)
   return boolean_exc;

----------------------------------------------------------------------------------------------------

   function value_used(
      arg : positive_exc_tb)
   return positive_exc;

   function value_used(
      arg : natural_exc_tb)
   return natural_exc;

   function value_used(
      arg : integer_exc_tb)
   return integer_exc;

   function value_used(
      arg : real_exc_tb)
   return real_exc;

   function value_used(
      arg : boolean_exc_tb)
   return boolean_exc;

   function value_used(
      arg : T_speed_tb)
   return T_speed;

----------------------------------------------------------------------------------------------------

   function value_used(
      arg           : boolean_tb;
      default_value : boolean)
   return boolean;

   function value_used(
      arg           : integer_tb;
      default_value : integer)
   return integer;
   
   function value_used(
      arg           : real_tb;
      default_value : real)
   return real;
   
   function value_used(
      arg           : T_round_style_tb;
      default_value : T_round_style)
   return T_round_style;

end package;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

Package body tb_pkg is

   function exception_value(
      arg : positive_exc)
   return integer is
   begin
      return integer(arg'subtype'low);
   end function;

   function exception_value(
      arg : positive_exc)
   return positive_exc is
   begin
      return arg'subtype'low;
   end function;

   function exception_value(
      arg : natural_exc)
   return integer is
   begin
      return integer(arg'subtype'low);
   end function;

   function exception_value(
      arg : natural_exc)
   return natural_exc is
   begin
      return arg'subtype'low;
   end function;

   function exception_value(
      arg : integer_exc)
   return integer_exc is
   begin
      return arg'subtype'low;
   end function;

   function exception_value(
      arg : real_exc)
   return real_exc is
   begin
      return arg'subtype'low;
   end function;

   function exception_value(
      arg : boolean_exc)
   return boolean_exc is
   begin
      return arg'subtype'low;
   end function;

----------------------------------------------------------------------------------------------------

   function value_used(
      arg : positive_exc_tb)
   return positive_exc is
   begin
      if arg.is_defined then
         return arg.value;
      else
         return exception_value(arg.value);
      end if;
   end function;

   function value_used(
      arg : natural_exc_tb)
   return natural_exc is
   begin
      if arg.is_defined then
         return arg.value;
      else
         return exception_value(arg.value);
      end if;
   end function;

   function value_used(
      arg : integer_exc_tb)
   return integer_exc is
   begin
      if arg.is_defined then
         return arg.value;
      else
         return exception_value(arg.value);
      end if;
   end function;

   function value_used(
      arg : real_exc_tb)
   return real_exc is
   begin
      if arg.is_defined then
         return arg.value;
      else
         return exception_value(arg.value);
      end if;
   end function;

   function value_used(
      arg : boolean_exc_tb)
   return boolean_exc is
   begin
      if arg.is_defined then
         return arg.value;
      else
         return exception_value(arg.value);
      end if;
   end function;

   function value_used(
      arg : T_speed_tb)
   return T_speed is
   begin
      if arg.is_defined then
         return arg.value;
      else
         return t_exc;
      end if;
   end function;

----------------------------------------------------------------------------------------------------

   function value_used(
      arg           : boolean_tb;
      default_value : boolean)
   return boolean is
   begin
      if arg.is_defined then
         return arg.value;
      else
         return default_value;
      end if;
   end function;

   function value_used(
      arg : integer_tb;
      default_value : integer)
   return integer is
   begin
      if arg.is_defined then
         return arg.value;
      else
         return default_value;
      end if;
   end function;
   
   function value_used(
      arg : real_tb;
      default_value : real)
   return real is
   begin
      if arg.is_defined then
         return arg.value;
      else
         return default_value;
      end if;
   end function;
   
   function value_used(
      arg : T_round_style_tb;
      default_value : T_round_style)
   return T_round_style is
   begin
      if arg.is_defined then
         return arg.value;
      else
         return default_value;
      end if;
   end function;

end package body;