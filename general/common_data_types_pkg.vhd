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
/     This package contains common data types
/
 **************************************************************************************************/

library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;
   use ieee.math_real.all;

library work;
   use work.fixed_generic_pkg.all;
   use work.fixed_float_types.all;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

package common_data_types_pkg is

   subtype T_sulv_index is integer range -2**30 to 2**30-1;

   type T_speed is (t_exc, t_min, t_low, t_medium, t_high, t_max);

   --std_ulogic_vector vector
   type sulv_v is array (natural range <>) of std_ulogic_vector;

   --std_ulogic_vector vector of vectors
   type sulv_vv is array (natural range <>) of sulv_v;

   type natural_v is array (natural range <>) of natural;

   type positive_v is array (natural range <>) of positive;

   type integer_v is array (natural range <>) of integer;

   type integer_vv is array (natural range <>) of integer_v;

   type real_v is array (natural range <>) of real;

   type boolean_v is array (natural range <>) of boolean;

   --u_sfixed vector
   type u_sfixed_v is array (integer range <>) of u_sfixed;

   --vector u_sfixed vectors
   type u_sfixed_vv is array (integer range <>) of u_sfixed_v;

   --vector of vector of u_sfixed vectors
   type u_sfixed_vvv is array (integer range <>) of u_sfixed_vv;

   --u_ufixed vector
   type u_ufixed_v is array (integer range <>) of u_ufixed;

   --vector of u_ufixed vectors
   type u_ufixed_vv is array (integer range <>) of u_ufixed_v;

   --sfixed vector
   type sfixed_v is array (integer range <>) of sfixed;

   --ufixed vector
   type ufixed_v is array (integer range <>) of ufixed;

   --vector in canonical signed digit representation. Each bit has the possible values of 0, 1, or
   --   -1, which are represented by 2 bits: 00, 01, or 11 respectively
   type T_csd is array (integer range<>) of bit_vector(2 downto 1);

   --types for describing the behavior of fixed and floating point data
   alias T_round_style is fixed_round_style_type;
   alias T_overflow_style is fixed_overflow_style_type;

   --type used for exceptions of generics of type positive (possible values: positive + '0').
   --   Exception will portrayed by value 0
   type positive_exc is range 0 to integer'high;


   --type used for exceptions of generics of type natural (possible values: natural + '-1').
   --   Exception will portrayed by value -1
   type natural_exc is range -1 to integer'high;

   --subtype used for exceptions of generics of type integer.
   --   Exception will portrayed by value integer'low
   subtype integer_exc is integer;

   --subtype used for exceptions of generics of type real
   subtype real_exc is real;

   --type used for exceptions of generics of type boolean (possible values: t_false, t_true, and 
   --   t_exc)
   type boolean_exc is (t_exc, t_true, t_false);

   --types to use in testbenches to ease the testing of defined/undefined generics. They allow
   --   setting a value for a generic and whether the assignment has been done inside the instantiation
   type T_round_style_tb is record
      value      : T_round_style;
      is_defined : boolean;
   end record;

   type T_overflow_style_tb is record
      value      : T_overflow_style;
      is_defined : boolean;
   end record;

   type T_speed_tb is record
      value      : T_speed;
      is_defined : boolean;
   end record;

   type boolean_tb is record
      value      : boolean;
      is_defined : boolean;
   end record;

   type boolean_exc_tb is record
      value      : boolean_exc;
      is_defined : boolean;
   end record;

   type natural_tb is record
      value      : natural;
      is_defined : boolean;
   end record;

   type natural_exc_tb is record
      value      : natural_exc;
      is_defined : boolean;
   end record;

   type positive_tb is record
      value      : positive;
      is_defined : boolean;
   end record;

   type positive_exc_tb is record
      value      : positive_exc;
      is_defined : boolean;
   end record;

   type integer_tb is record
      value      : integer;
      is_defined : boolean;
   end record;

   type integer_exc_tb is record
      value      : integer_exc;
      is_defined : boolean;
   end record;

   type real_tb is record
      value      : real;
      is_defined : boolean;
   end record;

   type real_exc_tb is record
      value      : real_exc;
      is_defined : boolean;
   end record;


/* functions                                                                                    1 */
/**************************************************************************************************/
   --function to convert boolean_exc to boolean to prevent errors in the elaboration phase
   function to_boolean(
      arg : boolean_exc)
   return boolean;

end package;


package body common_data_types_pkg is

   function to_boolean(
      arg : boolean_exc)
   return boolean is
   begin
      if arg = t_true then
         return true;
      else
         return false;
      end if;
   end function;

end package body;