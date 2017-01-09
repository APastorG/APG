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
/  Description:
/  ¯¯¯¯¯¯¯¯¯¯¯
/     This package contains general types, constants and functions oftenly used in other vhdl files
/
 **************************************************************************************************/

library std;
   use std.textio.all;

library ieee;
   use ieee.numeric_std.all;
   use ieee.std_logic_1164.all;
   use ieee.math_real.all;

library work;
   use work.common_data_types_pkg.all;
   use work.fixed_generic_pkg.all;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

package common_pkg is


/* constants                                                                                    0 */
/**************************************************************************************************/
   --bit used as the first integer bit when representing a fixed point in a std_ulogic_vector. This
   --   value should belong to the interval [0, 2**30]. It is also the value of the maximum number
   --   of fractional values that will be representable
   constant SULV_NEW_ZERO : integer := 2**30;

   --maximum number of fractional bits that will be used when calculating a number like 1/3 in binary
   constant FRACTIONAL_LIMIT : natural := 15;

   --used paths:
   --directory where the vhdl sources are
   constant SOURCES_DIRECTORY : string := "C:\Users\Antonio\Desktop\Vivado_workspace\PFdC_vivado_project\PFdC_vivado\PFdC_vivado.srcs";
   --directory where the solution .txt files are going to be stored
   constant DATA_FILE_DIRECTORY : string := "C:\Users\Antonio\Desktop\Vivado_workspace\PFdC_vivado_project\PFdC_vivado\PFdC_vivado.srcs\data_files";
   --same as the later but with double backslash \\
   constant DATA_FILE_DIRECTORY_M : string := "C:\\Users\\Antonio\\Desktop\\Vivado_workspace\\PFdC_vivado_project\\PFdC_vivado\\PFdC_vivado.srcs\\data_files"; --double backslash for Matlab
   --Active-HDL project directory
   constant ACTIVE_HDL_PROJECT_PATH : string := "C:\Users\Antonio\Active_HDL\Active_HDL_workspace\PFdC_activeHDL";

   --the length of the names used to name the real_const_mult solution files
   constant FILE_NAME_LENGTH : positive := 16;

   --to control when to show debugging messages
   constant DEBUGGING : boolean := false;

   constant SEPARATOR_STR : string := "*************************";


/* if then else functions                                                                       1 */
/**************************************************************************************************/

   function ite(cond : boolean; if_true, if_false : integer) return integer;
   function ite(cond : boolean; if_true, if_false : boolean) return boolean;
   function ite(cond : boolean; if_true, if_false : real) return real;
   function ite(cond : boolean; if_true, if_false : character) return character;
   function ite(cond : boolean; if_true, if_false : string) return string;
   function ite(cond : boolean; if_true, if_false : std_ulogic) return std_ulogic;
   function ite(cond : boolean; if_true, if_false : std_ulogic_vector) return std_ulogic_vector;
   function ite(cond : boolean; if_true, if_false : bit) return bit;
   function ite(cond : boolean; if_true, if_false : bit_vector) return bit_vector;
   function ite(cond : boolean; if_true, if_false : unsigned) return unsigned;
   function ite(cond : boolean; if_true, if_false : signed) return signed;
   function ite(cond : boolean; if_true, if_false : positive_exc) return positive_exc;
   function ite(cond : boolean; if_true, if_false : natural_exc) return natural_exc;
   function ite(cond : boolean; if_true, if_false : boolean_exc) return boolean_exc;
   function ite(cond : boolean; if_true, if_false : T_round_style) return T_round_style;
   function ite(cond : boolean; if_true, if_false : T_overflow_style) return T_overflow_style;
   function ite(cond : boolean; if_true, if_false : u_ufixed) return u_ufixed;
   function ite(cond : boolean; if_true, if_false : u_sfixed) return u_sfixed;
   function ite(cond : boolean; if_true, if_false : boolean_v) return boolean_v;

/* math                                                                                         2 */
/**************************************************************************************************/
   --returns the ceiling of the log2
   function log2ceil(
      number : positive)
   return integer;

   --returns the floor of the log2
   function log2floor(
      number : positive)
   return integer;

   --returns the maximum of the two integers
   function maximum(
      a, b: integer)
   return integer;

   --returns the minimum of the two integers
   function minimum(
      a, b: integer)
   return integer;

   --reduces the numbe to an odd one via dividing by two until odd
   function reduce_to_odd(
      arg : positive)
   return positive;


/* debugging                                                                                    3 */
/**************************************************************************************************/
   --shows a message, for debugging purposes
   procedure msg_debug(arg: in positive_v; separator: string);

   procedure msg_debug(arg: in string);

/* image extraction                                                                             4 */
/**************************************************************************************************/

   procedure separator;

   --returns the 'image attribute of integer type
   function image(
      sca: integer)
   return string;

   function real_rightest_dec_bit(
      number: real)
   return integer;

   function real_image_length(
      number : real)
   return integer;

   --returns the 'image attribute of positive_exc type
   function image(
      number : positive_exc)
   return string;

   --returns the 'image attribute of natural_exc type
   function image(
      number : natural_exc)
   return string;

   --returns the 'image attribute of boolean_exc type
   function image(
      bool : boolean_exc)
   return string;

   --returns the 'image attribute of T_round_style type
   function image(
      bool : T_round_style)
   return string;

   --returns the 'image attribute of real type
   function image(
      number: real)
   return string;

   --returns the 'image attribute of boolean type
   function image(
      sca: boolean)
   return string;

   --returns the 'image attribute of std_ulogic type
   function image(
      sca: std_ulogic)
   return string;

   --returns the 'image attribute of bit type
   function image(
      sca: bit)
   return string;

   --returns the 'image attribute of bit_vector type
   function image(
      vec : bit_vector)
   return string;

   --returns the 'image attribute of std_ulogic_vector type
   function image(
      vec : std_ulogic_vector)
   return string;

   --returns the 'image attribute of a T_csd type in the 0,1,-1 form
   function image(
      csd: T_csd)
   return string;

   --returns the 'image attribute of a u_ufixed type
   function image(
      u_u: u_ufixed)
   return string;

   --returns the 'image attribute of a u_sfixed type
   function image(
      u_s: u_sfixed)
   return string;


/* vector manipulation                                                                          5 */
/**************************************************************************************************/
   --calculates the absolute value of each real of the vector
   function "abs"(
      arg : real_v)
   return real_v;

   --returns the maximum positive in the vector
   function maximum(
      arg : positive_v)
   return positive;

   --returns the maximum integer in the vector
   function maximum(
      arg : integer_v)
   return integer;

   --returns the minimum integer in the vector
   function minimum(
      arg : integer_v)
   return integer;

   --returns the maximum real in the vector
   function maximum(
      arg : real_v)
   return real;

   --uses bubble sort in a vector of reals to order it from low to high
   function order(
      arg : real_v)
   return real_v;

/* integer/binary conversion                                                                    6 */
/**************************************************************************************************/
   --returns the minimum number of bits necessary to represent the number in signed/unsigned
   function min_bits(
      number    : integer;
      is_signed : boolean)
   return natural;

   --returns the minimum number of bits necessary to represent the number assuming the use of
   --   unsigned for natural numbers and signed for negative
   function min_bits(
      number : integer)
   return natural;

----------------------------------------------------------------------------------------------------

   function error_pct(
      A : real;
      B : real)
   return real;

   --returns the smallest representation of a real number in u_ufixed form. The fractional bits are
   --   limited by the constant FRACTIONAL_LIMIT.
   function to_ufixed(
      number        : real;
      max_error_pct : real := 0.0;
      round_style   : T_round_style := fixed_truncate)
   return u_ufixed;

   --returns the smallest representation of a real number in u_sfixed form. The fractional bits are
   --   limited by the constant FRACTIONAL_LIMIT.
   function to_sfixed(
      number        : real;
      max_error_pct : real := 0.0;
      round_style   : T_round_style := fixed_truncate)
   return u_sfixed;

----------------------------------------------------------------------------------------------------

   --returns the std_ulogic_vector of the desired length that represents the number in signed/
   --   unsigned. It asserts the desired length is enough, and that it is signed if number negative
   function sulv_from_int(
      number    : integer;
      is_signed : boolean;
      length    : positive)
   return std_ulogic_vector;

   --returns the std_ulogic_vector of minimum length that represents the number in signed/unsigned
   function sulv_from_int(
      number    : integer;
      is_signed : boolean)
   return std_ulogic_vector;

   --returns the the std_ulogic_vector of minimum length that represents the number, assuming
   --   signed for negative numbers and unsigned for the rest
   function sulv_from_int(
      number : integer)
   return std_ulogic_vector;

   --returns the canonical signed digit of the input vector. It returns a type T_csd which is an
   --   array of length 2-slv. It encodes three values 0, 1, and -1 as "00","01",and "11"
   --   respectively. If the parameter is_signed is ignored it is assumed the vector represents a 
   --   positive value.
   function to_csd(
      vector    : u_ufixed)
   return T_csd;

   function to_csd(
      vector    : u_sfixed)
   return T_csd;

----------------------------------------------------------------------------------------------------

   --returns the maximum signed that can be represented
   function max_vec(
      vector : signed)
   return signed;

   --returns the minimum signed that can be represented
   function min_vec(
      vector : signed)
   return signed;

   --returns the maximum unsigned that can be represented
   function max_vec(
      vector : unsigned)
   return unsigned;

   --returns the minimum unsigned that can be represented
   function min_vec(
      vector : unsigned)
   return unsigned;

   --returns the maximum signed(as slv) that can be represented
   function max_vec(
      vector : signed)
   return std_ulogic_vector;

   --returns the minimum signed(as slv) that can be represented
   function min_vec(
      vector : signed)
   return std_ulogic_vector;

   --returns the maximum unsigned(as slv) that can be represented
   function max_vec(
      vector : unsigned)
   return std_ulogic_vector;

   --returns the minimum unsigned(as slv) that can be represented
   function min_vec(
      vector : unsigned)
   return std_ulogic_vector;

   --returns the maximum std_ulogic_vector that can be represented
   function max_vec(
      vector      : std_ulogic_vector;
      signed_data : boolean)
   return std_ulogic_vector;

   --returns the minimum std_ulogic_vector that can be represented
   function min_vec(
      vector      : std_ulogic_vector;
      signed_data : boolean)
   return std_ulogic_vector;


/* arithmetic operators                                                                         7 */
/**************************************************************************************************/
   --several functions to complete the functionality of the numeric_std package's
   --   operators "+" and "-" so they return std_ulogic_vectors as well
   function "+"(
      vector : unsigned;
      number : integer)
   return std_ulogic_vector;

   function "+"(
      vector : signed;
      number : integer)
   return std_ulogic_vector;

   function "+"(
      vector1 : unsigned;
      vector2 : unsigned)
   return std_ulogic_vector;

   function "+"(
      vector1 : signed;
      vector2 : signed)
   return std_ulogic_vector;

   function "-"(
      vector : unsigned;
      number : integer)
   return std_ulogic_vector;

   function "-"(
      vector : signed;
      number : integer)
   return std_ulogic_vector;

   function "-"(
      vector1 : unsigned;
      vector2 : unsigned)
   return std_ulogic_vector;

   function "-"(
      vector1 : signed;
      vector2 : signed)
   return std_ulogic_vector;


/* other operators                                                                             10 */
/**************************************************************************************************/
   --several functions to complete the functionality of operators +, -, *, /, ** so they accept an
   --   integer and a real as parameters. It converts the integer to real
   function "+"(
      i : integer;
      r : real)
   return real;

   function "+"(
      r : real;
      i : integer)
   return real;

   function "-"(
      i : integer;
      r : real)
   return real;

   function "-"(
      r : real;
      i : integer)
   return real;

   function "*"(
      i : integer;
      r : real)
   return real;

   function "*"(
      r : real;
      i : integer)
   return real;

   function "/"(
      i : integer;
      r : real)
   return real;

   function "/"(
      r : real;
      i : integer)
   return real;

   function "**"(
      i : integer;
      r : real)
   return real;

   function "**"(
      r : real;
      i : integer)
   return real;

/* pipeline functions                                                                          11 */
/**************************************************************************************************/
   --generates a vector of booleans which indicates in which position to place the pipelines out of
   --all the possible ones depending on the parameter SPEED
   function generate_pipelines(
      positions : natural;
      speed     : T_speed)
   return boolean_v;

   function is_pipelined(
      positions : natural;
      speed     : T_speed;
      position  : natural)
   return boolean;

   function number_of_pipelines(
      positions : natural;
      speed     : T_speed)
   return natural;

end package;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

package body common_pkg is

/********************************************************************************************** 1 */

   function ite(cond: boolean; if_true, if_false: integer) return integer is
   begin
      if cond then
         return(if_true);
      else
         return(if_false);
      end if;
   end function ite;

   function ite(cond: boolean; if_true, if_false: boolean) return boolean is
   begin
      if cond then
         return(if_true);
      else
         return(if_false);
      end if;
   end function ite;

   function ite(cond: boolean; if_true, if_false: real) return real is
   begin
      if cond then
         return(if_true);
      else
         return(if_false);
      end if;
   end function ite;

   function ite(cond: boolean; if_true, if_false: character) return character is
   begin
      if cond then
         return(if_true);
      else
         return(if_false);
      end if;
   end function ite;

   function ite(cond: boolean; if_true, if_false: string) return string is
   begin
      if cond then
         return(if_true);
      else
         return(if_false);
      end if;
   end function ite;
   function ite(cond: boolean; if_true, if_false: std_ulogic) return std_ulogic is
   begin
      if cond then
         return(if_true);
      else
         return(if_false);
      end if;
   end function ite;

   function ite(cond: boolean; if_true, if_false: std_ulogic_vector) return std_ulogic_vector is
   begin
      if cond then
         return(if_true);
      else
         return(if_false);
      end if;
   end function ite;

   function ite(cond: boolean; if_true, if_false: bit) return bit is
   begin
      if cond then
         return(if_true);
      else
         return(if_false);
      end if;
   end function ite;

   function ite(cond: boolean; if_true, if_false: bit_vector) return bit_vector is
   begin
      if cond then
         return(if_true);
      else
         return(if_false);
      end if;
   end function ite;

   function ite(cond: boolean; if_true, if_false: unsigned) return unsigned is
   begin
      if cond then
         return(if_true);
      else
         return(if_false);
      end if;
   end function ite;

   function ite(cond: boolean; if_true, if_false: signed) return signed is
   begin
      if cond then
         return(if_true);
      else
         return(if_false);
      end if;
   end function ite;

   function ite(cond: boolean; if_true, if_false: positive_exc) return positive_exc is
   begin
      if cond then
         return(if_true);
      else
         return(if_false);
      end if;
   end function ite;

   function ite(cond: boolean; if_true, if_false: natural_exc) return natural_exc is
   begin
      if cond then
         return(if_true);
      else
         return(if_false);
      end if;
   end function ite;

   function ite(cond: boolean; if_true, if_false: boolean_exc) return boolean_exc is
   begin
      if cond then
         return(if_true);
      else
         return(if_false);
      end if;
   end function ite;

   function ite(cond: boolean; if_true, if_false: T_round_style) return T_round_style is
   begin
      if cond then
         return(if_true);
      else
         return(if_false);
      end if;
   end function ite;

   function ite(cond: boolean; if_true, if_false: T_overflow_style) return T_overflow_style is
   begin
      if cond then
         return(if_true);
      else
         return(if_false);
      end if;
   end function ite;

   function ite(cond: boolean; if_true, if_false: u_ufixed) return u_ufixed is
   begin
      if cond then
         return(if_true);
      else
         return(if_false);
      end if;
   end function ite;

   function ite(cond: boolean; if_true, if_false: u_sfixed) return u_sfixed is
   begin
      if cond then
         return(if_true);
      else
         return(if_false);
      end if;
   end function ite;

   function ite(cond: boolean; if_true, if_false: boolean_v) return boolean_v is
   begin
      if cond then
         return(if_true);
      else
         return(if_false);
      end if;
   end function ite;


/********************************************************************************************** 2 */

   function log2ceil(number: positive)
   return integer is
   begin
      return integer(ceil(log2(real(number))));
   end function;

   function log2floor(number: positive)
   return integer is
   begin
      return integer(floor(log2(real(number))));
   end function;

   --returns the maximum of the two integers
   function maximum(
      a, b: integer)
   return integer is
   begin
      return ite(a>b, a, b);
   end function;

   --returns the minimum of the two integers
   function minimum(
      a, b: integer)
   return integer is
   begin
      return ite(a<b, a, b);
   end function;

   --reduction to odd number
   function reduce_to_odd(
      arg : positive)
   return positive is
      variable aux : positive := arg;
   begin
      if arg mod 2 = 1 then
         return arg;
      else 
         return reduce_to_odd(arg/2);
      end if;
   end function;


/********************************************************************************************** 3 */

   procedure msg_debug(arg: in positive_v; separator: string) is
      constant left    : integer := arg'left;
      constant right   : integer := arg'right;
      variable message : line;
   begin
      write(message, image(arg(left)));
      if left /= right then
         for i in arg'range loop
            if i /= left then
               write(message, separator);
               write(message, image(arg(i)));
            end if;
         end loop;
      end if;
      writeline(output, message);
   end procedure;


   procedure msg_debug(
      arg : in string)
   is
      variable message : line;
   begin
      if DEBUGGING then
         write(message, arg);
         writeline(OUTPUT, message);
      end if;
   end procedure;


/********************************************************************************************** 4 */

   procedure separator is
   begin
      assert false
         report SEPARATOR_STR
         severity warning;
   end procedure;


   function image(
      sca: integer)
   return string is
   begin
      return integer'image(sca);
   end;


   function real_rightest_dec_bit(
      number: real)
   return integer is
      variable copy : real := "mod"(number, 1.0);
      variable counter : integer := 0;
   begin
      --for i in -FRACTIONAL_LIMIT to 0 loop
      while copy /= 0.0 and counter > -FRACTIONAL_LIMIT loop
            copy := "mod"(10.0*copy, 1.0);
            counter := counter - 1;
      end loop;
      return counter;
   end function;


   function real_image_length(
      number : real)
   return integer is
      constant rightest_frac_bit : integer := real_rightest_dec_bit(number);
      constant fractional_bits   : natural := -rightest_frac_bit;
      constant integer_bits      : integer := 1+integer(floor(log10(realmax(abs(number),1.0))));--at least 1
      variable result : positive;
   begin
      if number = 0.0 then --'0'
         result := 3;
      elsif abs(number)<1.0 then --'0,f..f'
         result := 2+fractional_bits; -- +2 for the leading '0.'
      elsif fractional_bits=0 then --'i..i'
         result := integer_bits;
      else --'i..i,f..f'
         result := integer_bits+1+fractional_bits; -- +1 because of the comma
      end if;
      if number<0.0 then     --add the minus sign
         return result+1;
      else
         return result;
      end if;
   end function;


   function image(
      number: real)
   return string is
      constant rightest_frac_bit : integer := real_rightest_dec_bit(number);
      variable remain            : real    := abs(number);
      constant fractional_bits   : natural := -rightest_frac_bit;
      constant integer_bits      : natural := 1+integer(floor(log10(realmax(remain,1.0))));--at least 1
      constant string_length     : integer := real_image_length(number);
      variable result            : string(1 to string_length);
      variable j                 : integer := 1; --string index
   begin
      if number = real'low then
         return "real'low";
      elsif number = real'high then
         return "real'high";
      end if;
      --minus sign
      if number < 0.0 then 
         result(j) := '-';
         j := j + 1;
      end if;
      --integer bits
      result(j to j+integer_bits-1) := real'image(floor(remain))(1 to integer_bits);
      j := j+integer_bits;
      remain := "mod"(remain, 1.0);
      --fractional bits with the '.'
      if fractional_bits > 0 then
         result(j) := '.';
         j := j + 1;
         for i in 1 to fractional_bits loop
            remain := remain * 10;
            result (j) := image(integer(floor(remain)))(1);
            remain := "mod"(remain, 1.0);
            j := j + 1;
         end loop;
      end if;
      return result;
   end;


   function image(
      number : positive_exc)
   return string is
   begin
      return integer'image(integer(number));
   end function;


   function image(
      number : natural_exc)
   return string is
   begin
      return integer'image(integer(number));
   end function;


   function image(
      bool : boolean_exc)
   return string is
   begin
      return boolean_exc'image(bool);
   end function;


   function image(
      bool : T_round_style)
   return string is
   begin
      return T_round_style'image(bool);
   end function;


   function image(
      sca: boolean)
   return string is
   begin
      return boolean'image(sca);
   end;


   function image(
      sca: std_ulogic)
   return string is
   begin
      return std_ulogic'image(sca);
   end;


   function image(
      sca: bit)
   return string is
   begin
      return bit'image(sca);
   end;


   function image(
      vec: bit_vector)
   return string is
      variable result   : string(1 to vec'length);
      variable iterator : integer;
   begin
      iterator := vec'left;
      for i in result'range loop
         if (vec(iterator) = '1') then
            result(i) := '1';
         else
            result(i) := '0';
         end if;
         iterator := ite(vec'ascending, iterator+1, iterator-1);
      end loop;
      return result;
   end;

   function image(
      vec: std_ulogic_vector)
   return string is
      variable result   : string(1 to vec'length);
      variable iterator : integer;
   begin
      iterator := vec'left;
      for i in result'range loop
         if (vec(iterator) = '1') then
            result(i) := '1';
         else
            result(i) := '0';
         end if;
         iterator := ite(vec'ascending, iterator+1, iterator-1);
      end loop;
      return result;
   end;


   function image(
      csd: T_csd)
   return string is
      variable message : string(1 to 2*csd'length+1);
      variable i, j    : positive := 1;
   begin

      for i in csd'range loop
         if csd(i) = "00" then
            message(j) := '0';
            j := j+1;
         elsif csd(i) = "01" then
            message(j) := '1';
            j := j+1;
         elsif csd(i) = "11" then
            message(j to j+1) := "-1";
            j := j+2;
         else
            assert false
               report
                  "ERRROR on function image(T_csd): received illegal value ""10""."
               severity error;
         end if;
         if i = 0 then
            message(j) := '.';
            j := j + 1;
         end if;
      end loop;

      return message;
   end function;


   function image(
      u_u: u_ufixed)
   return string is
      constant string_length : positive := 2+1+maximum(1+u_u'high, 1)-u_u'low; --+2:quotes, +1:comma
      variable message : string(1 to string_length);
      variable i       : integer;
      variable j       : positive := 1; --string index
   begin
      message(j) := '"';
      j := j + 1;
      if u_u'high < 0 then
         message(j to j+1) := "0.";
         if u_u'high < -1 then
            message (j+2 to j -u_u'high) := (others =>'0');
         end if;
      end if;
      for i in u_u'range loop
         message(j) := image(u_u(i))(2);
         j := j+1;
         if i=0 then
            message(j) := '.';
            j := j + 1;
         end if;
      end loop;
      message(j) := '"';
      return message;
   end function;


   function image(
      u_s: u_sfixed)
   return string is
      constant string_length : positive := 2+1+maximum(1+u_s'high, 1)-u_s'low; --+2:quotes, +1:comma
      variable message : string(1 to string_length);
      variable i       : integer;
      variable j       : positive := 1; --string index
   begin
      message(j) := '"';
      j := j + 1;
      if u_s'high < 0 then
         message(j to j+1) := "0.";
         if u_s'high < -1 then
            message (j+2 to j -u_s'high) := (others =>'0');
         end if;
      end if;
      for i in u_s'range loop
         message(j) := image(u_s(i))(2);
         j := j+1;
         if i=0 then
            message(j) := '.';
            j := j + 1;
         end if;
      end loop;
      message(j) := '"';
      return message;
   end function;


/********************************************************************************************** 5 */

   function "abs"(
      arg : real_v)
   return real_v is
      variable result : real_v(arg'range);
   begin
      for i in arg'range loop
         result(i) := abs(arg(i));
      end loop;
      return result;
   end function;

   function maximum(
      arg : positive_v)
   return positive is
      variable result : positive := positive'low;
   begin
      for i in arg'range loop
         if arg(i) > result then
            result := arg(i);
         end if;
      end loop;
      return result;
   end function;

   function maximum(
      arg : integer_v)
   return integer is
      variable result : integer := integer'low;
   begin
      for i in arg'range loop
         if arg(i) > result then
            result := arg(i);
         end if;
      end loop;
      return result;
   end function;

   function minimum(
      arg : integer_v)
   return integer is
      variable result : integer := integer'high;
   begin
      for i in arg'range loop
         if arg(i) < result then
            result := arg(i);
         end if;
      end loop;
      return result;
   end function;

   function maximum(
      arg : real_v)
   return real is
      variable result : real := real'low;
   begin
      for i in arg'range loop
         if arg(i) > result then
            result := arg(i);
         end if;
      end loop;
      return result;
   end function;

   function order(
      arg : real_v)
   return real_v is
      variable result : real_v(1 to arg'length) := arg;
      variable aux    : real;
   begin
      for i in 1 to result'high-1 loop
         for j in 1 to result'high-i loop
            if result(i) > result(i+1) then
               aux := result(i);
               result(i)   := result(i+1);
               result(i+1) := aux;
            end if;
         end loop;
      end loop;
      return result;
   end function;


/********************************************************************************************** 6 */

   function min_bits(
      number    : integer;
      is_signed : boolean)
   return natural is
   begin

      if number=0 then
         return 1;
      end if;

      if number=-1 then
         return 1;
      end if;

      if is_signed then
         if number<0 then
            if number=integer'low then
               return 32;
            else
               return 1+log2ceil(abs(number));
            end if;
         elsif number=integer'high then
            return 32;
         else
            return 1+log2ceil(number+1);
         end if;
      else
         if number<0 then
            assert false
               report
                  "ERROR in function min_bits: trying to represent negative numbers in unsigned"
               severity error;
            return 0;                     --trying to represent negative numbers in unsigned
         elsif number=integer'high then   --   in unsigned
            return 31;
         else
            return log2ceil(number+1);
         end if;
      end if;                             --added the condition number<0 when is_signed is false
                                          --   because when using ite to control which value of
                                          --   is_signed will be sent to min_bits some errors will
                                          --   appear even though the condition is never reached
   end function;


   function min_bits(
      number : integer)
   return natural is
   begin
      if number>=0 then
         return min_bits(number, false);
      else
         return min_bits(number, true);
      end if;
   end function;

----------------------------------------------------------------------------------------------------

   function error_pct(
      A : real;
      B : real)
   return real is
   begin
      if B = 0.0 then
         return real'high;
      else
         return abs(100*(A-B)/B);
      end if;
   end function;


   function to_ufixed(
      number        : real;
      max_error_pct : real := 0.0;
      round_style   : T_round_style := fixed_truncate) --fixed_truncate, fixed_round
   return u_ufixed is
      constant number_int : natural  := integer(floor(abs(number)));
      constant number_uf  : u_ufixed := to_ufixed(abs(number),
                                                  -1,
                                                  -FRACTIONAL_LIMIT,
                                                  round_style => fixed_truncate,
                                                  overflow_style => fixed_wrap);
      constant int_bits   : integer  := min_bits(number_int);
      constant frac_bits  : integer  := -find_rightmost(number_uf, '1');
      variable result     : u_ufixed(int_bits-1 downto -frac_bits);
      variable new_low : integer := result'low;
   begin

      result := to_ufixed(number,
                          int_bits-1,
                          -frac_bits,
                          round_style => fixed_truncate,
                          overflow_style => fixed_wrap);

      assert number >= 0.0
         report
            "ERROR in function to_ufixed: real number must be natural"
         severity error;

      --check if the number is either real'low, real'high as their real'image is not a number representation, but "#INF"
      --   Also with 0.0, 1.0, and -1.0 as their representation is 0 downto 0 and this generates errors with functions from
      --   the fixed_generic_pkg
      if number = real'high then
         return to_ufixed(number,
                          int_bits-1,
                          -1,
                          round_style => round_style,
                          overflow_style => fixed_wrap);
      elsif number = 0.0 then
         return to_ufixed(0.0, 0, -1);
      elsif number = 1.0 then
         return to_ufixed(1.0, 0, -1);
      end if;

      --in this part the fractional bits that are unnecesary are discarded accordingly with the error_pct 
      if result'low <0 then 
         for i in result'low to minimum(result'high, -1) loop
            if error_pct(to_real(resize(result,
                                        result'high,
                                        i)),
                         number)<= max_error_pct
            then new_low := i;
            end if;
         end loop;
         --number 0 causes an error because (0 downto 0) is not liked by the function cleanvec from the
         --    fixed point package. So the first(-1) fractional bit is only discarded when the number
         --   of integer bits is greater than 1
         if result'high > 0 then
            if error_pct(to_real(resize(result, 
                                        result'high,
                                        0)),
                         number)<= max_error_pct
            then new_low := 0;
            end if;
         end if;
      end if;

      return resize(result, result'high, new_low);
   end function;


   function to_sfixed(
      number        : real;
      max_error_pct : real := 0.0;
      round_style   : T_round_style := fixed_truncate) --fixed_truncate, fixed_round
   return u_sfixed is
      constant number_int : integer  := integer(floor(number));
      constant number_uf  : u_ufixed := to_ufixed(abs(number),
                                                  -1,
                                                  -FRACTIONAL_LIMIT,
                                                  round_style => round_style,
                                                  overflow_style => fixed_wrap);
      constant int_bits   : integer  := min_bits(number_int, is_signed=>true);
      constant frac_bits  : integer  := -find_rightmost(number_uf, '1');
      constant result     : u_sfixed := to_sfixed(number,
                                                  int_bits-1,
                                                  -frac_bits,
                                                  round_style => round_style,
                                                  overflow_style => fixed_wrap);
      variable new_low : integer := result'low;
   begin
      --check if the number is either real'low, real'high as their real'image is not a number representation, but "-1.#INF00" and "1.#INF00"
      --   Also with 0.0, 1.0, and -1.0 as their representation is 0 downto 0 and this generates errors with functions from
      --   the fixed_generic_pkg
      if number = real'low then
         return to_sfixed(number,
                          int_bits-1,
                          -1,
                          round_style => round_style,
                          overflow_style => fixed_wrap);
      elsif number = real'high then
         return to_sfixed(number,
                          int_bits-1,
                          -1,
                          round_style => round_style,
                          overflow_style => fixed_wrap);
      elsif number = 0.0 then
         return to_sfixed(0, 0, -1);
      elsif number = 1.0 then
         return to_sfixed(1.0, 1, 0);
      elsif number = -1.0 then
         return tO_sfixed(-1.0, 0, -1);
      end if;
      --in this part the fractional bits that are unnecesary are discarded accordingly with the error_pct 
      if result'low <0 then 
         for i in result'low to minimum(result'high, -1) loop
            if error_pct(to_real(resize(result,
                                        result'high,
                                        i)),
                         number)<= max_error_pct
            then new_low := i;
            end if;
         end loop;
         --number 0 causes an error because (0 downto 0) is not liked by the function cleanvec from the
         --    fixed point package. So the first(-1) fractional bit is only discarded when the number
         --   of integer bits is greater than 1
         if result'high > 0 then
            if error_pct(to_real(resize(result, 
                                        result'high,
                                        0)),
                         number)<= max_error_pct
            then new_low := 0;
            end if;
         end if;
      end if;
      return resize(result, result'high, new_low);
   end function;

----------------------------------------------------------------------------------------------------

   function sulv_from_int(
      number    : integer;
      is_signed : boolean;
      length    : positive)
   return std_ulogic_vector is
   begin

      if is_signed then
         return std_ulogic_vector(to_signed(number, length));
      else
         return std_ulogic_vector(to_unsigned(abs(number), length));
      end if;

   end function;


   function sulv_from_int(
      number    : integer;
      is_signed : boolean)
   return std_ulogic_vector is
   begin
      return sulv_from_int(number, is_signed, min_bits(number, is_signed));
   end function;


   function sulv_from_int(
      number : integer)
   return std_ulogic_vector is
   begin
      return sulv_from_int(number, number<0);
   end function;

----------------------------------------------------------------------------------------------------

   function to_csd(
      vector    : u_ufixed)
   return T_csd is
      constant aux_vector : u_ufixed := resize(vector, vector'high+1 , vector'low);
      variable flag       : integer := vector'low-1;
      variable result     : T_csd(aux_vector'range) := (others => "00");
   begin

      for i in result'reverse_range loop  --from low to high
         if aux_vector(i)='0' then

            if flag = i-1 then
               flag := i;
            elsif flag = i-2 then
               result(i-1) := "01";  -- 1
               flag := i;
            else
               result(flag+1) := "11";  -- -1
               result(i)      := "01";  -- 1
               flag := i-1;
            end if;

         end if;
      end loop ;
      return result(result'high-1 downto result'low); --discard higher bit as it is the "sign"(in csd the values of a number in its 
                                                      --positive and negative form can be represented in the same amount of bits)

   end function;


   function to_csd(
      vector    : u_sfixed)
   return T_csd is
      constant is_negative : boolean  := to_real(vector) < 0.0;
      constant aux_vector  : u_sfixed := "abs"(vector); --to_csd of the absolute value and then invert the values
      variable result : T_csd(aux_vector'high+ 1 downto aux_vector'low);
   begin
      result := to_csd(to_ufixed(to_real(aux_vector), aux_vector'high, aux_vector'low));
      --invert values: -1 to 1, and 1 to -1
      if is_negative then
         for i in result'range loop
            case result(i) is
               when "11" => result(i) := "01";
               when "01" => result(i) := "11";
               when others => null;
            end case;
         end loop;
      end if;
   return result;
   end function;

----------------------------------------------------------------------------------------------------

   function max_int(
      bits        : positive;
      signed_data : boolean)
   return integer is
   begin
      if signed_data then
         return 2**(bits-1)-1;
      else
         return 2**bits-1;
      end if;
   end function;

   function min_int(
      bits        : positive;
      signed_data : boolean)
   return integer is
   begin
      if signed_data then
         return -2**(bits-1);
      else
         return 0;
      end if;
   end function;

----------------------------------------------------------------------------------------------------

   function max_vec(
      vector : signed)
   return signed is
      variable aux : signed(vector'length downto 1);
   begin
      aux := (others => '1');
      aux(vector'length) := '0';
      return aux;
   end function;

   function min_vec(
      vector : signed)
   return signed is
      variable aux : signed(vector'length downto 1);
   begin
      aux := (others => '0');
      aux(vector'length) := '1';
      return aux;
   end function;

   function max_vec(
      vector : unsigned)
   return unsigned is
      variable aux : unsigned(vector'range);
   begin
      aux := (others => '1');
      return aux;
   end function;

   function min_vec(
      vector : unsigned)
   return unsigned is
      variable aux : unsigned(vector'range);
   begin
      aux := (others => '0');
      return aux;
   end function;

   function max_vec(
      vector : signed)
   return std_ulogic_vector is
      variable aux : signed(vector'range);
   begin
      aux := max_vec(vector);
      return std_ulogic_vector(aux);
   end function;

   function min_vec(
      vector : signed)
   return std_ulogic_vector is
      variable aux : signed(vector'range);
   begin
      aux := min_vec(vector);
      return std_ulogic_vector(aux);
   end function;

   function max_vec(
      vector : unsigned)
   return std_ulogic_vector is
      variable aux : unsigned(vector'range);
   begin
      aux := max_vec(vector);
      return std_ulogic_vector(aux);
   end function;

   function min_vec(
      vector : unsigned)
   return std_ulogic_vector is
      variable aux : unsigned(vector'range);
   begin
      aux := min_vec(vector);
      return std_ulogic_vector(aux);
   end function;

   function max_vec(
      vector      : std_ulogic_vector;
      signed_data : boolean)
   return std_ulogic_vector is
   begin
      if signed_data then
         return max_vec(signed(vector));
      else
         return max_vec(unsigned(vector));
      end if;
   end function;

   function min_vec(
      vector      : std_ulogic_vector;
      signed_data : boolean)
   return std_ulogic_vector is
   begin
      if signed_data then
         return min_vec(signed(vector));
      else
         return min_vec(unsigned(vector));
      end if;
   end function;


/********************************************************************************************** 7 */

   function "+"(
      vector : unsigned;
      number : integer)
   return std_ulogic_vector is
      variable aux : unsigned(vector'range);
   begin
      aux := vector + number;
      return std_ulogic_vector(aux);
   end function;

   function "+"(
      vector : signed;
      number : integer)
   return std_ulogic_vector is
      variable aux : signed(vector'range);
   begin
      aux := vector + number;
      return std_ulogic_vector(aux);
   end function;

   function "+"(
      vector1 : unsigned;
      vector2 : unsigned)
   return std_ulogic_vector is
      variable aux : unsigned(vector1'range);
   begin
      aux := vector1 + vector2;
      return std_ulogic_vector(aux);
   end function;

   function "+"(
      vector1 : signed;
      vector2 : signed)
   return std_ulogic_vector is
      variable aux : signed(vector1'range);
   begin
      aux := vector1 + vector2;
      return std_ulogic_vector(aux);
   end function;

   function "-"(
      vector : unsigned;
      number : integer)
   return std_ulogic_vector is
      variable aux : unsigned(vector'range);
   begin
      aux :=vector - number;
      return std_ulogic_vector(aux);
   end function;

   function "-"(
      vector : signed;
      number : integer)
   return std_ulogic_vector is
      variable aux : signed(vector'range);
   begin
      aux := vector - number;
      return std_ulogic_vector(aux);
   end function;

   function "-"(
      vector1 : unsigned;
      vector2 : unsigned)
   return std_ulogic_vector is
      variable aux : unsigned(vector1'range);
   begin
      aux := vector1 - vector2;
      return std_ulogic_vector(aux);
   end function;

   function "-"(
      vector1 : signed;
      vector2 : signed)
   return std_ulogic_vector is
      variable aux : signed(vector1'range);
   begin
      aux := vector1 - vector2;
      return std_ulogic_vector(aux);
   end function;


/********************************************************************************************* 10 */

   function "+"(
      i : integer;
      r : real)
   return real is
   begin
      return real(i) + r;
   end function;

   function "+"(
      r : real;
      i : integer)
   return real is
   begin
      return real(i) + r;
   end function;

   function "-"(
      i : integer;
      r : real)
   return real is
   begin
      return real(i) - r;
   end function;

   function "-"(
      r : real;
      i : integer)
   return real is
   begin
      return r - real(i);
   end function;

   function "*"(
      i : integer;
      r : real)
   return real is
   begin
      return real(i) * r;
   end function;

   function "*"(
      r : real;
      i : integer)
   return real is
   begin
      return real(i) * r;
   end function;

   function "/"(
      i : integer;
      r : real)
   return real is
   begin
      return real(i) / r;
   end function;

   function "/"(
      r : real;
      i : integer)
   return real is
   begin
      return r / real(i);
   end function;

   function "**"(
      i : integer;
      r : real)
   return real is
   begin
      return real(i) ** r;
   end function;

   function "**"(
      r : real;
      i : integer)
   return real is
   begin
      return r ** real(i);
   end function;


/********************************************************************************************* 11 */

   function generate_pipelines(
      positions : natural;
      speed     : T_speed)
   return boolean_v is
      variable pipelines : natural;
      variable aux       : natural := positions;
      variable result    : boolean_v(1 to positions) := (others => false);
   begin
      case speed is
         when t_min    => return result;
         when t_low    => pipelines := integer(ceil(0.25 * real(aux)));
         when t_medium => pipelines := integer(ceil(0.5 * real(aux)));
         when t_high   => pipelines := integer(ceil(0.75 * real(aux)));
         when t_max    => result := (others => true);
                          return result;
         when t_exc    => return result;  --no value assigned
      end case;
      if pipelines>0 then
         result(aux) := true;
         if pipelines>1 then
            for i in pipelines downto 2 loop
               aux := aux - aux/pipelines;
               result(aux) := true;
            end loop;
         end if;
      end if;
      return result;
   end function;

   function is_pipelined(
      positions : natural;
      speed     : T_speed;
      position  : natural)
   return boolean is
      variable indexes : boolean_v(1 to positions) := generate_pipelines(positions,
                                                                         speed);
   begin
      return indexes(position);
   end function;

   function number_of_pipelines(
      positions : natural;
      speed     : T_speed)
   return natural is
   begin
      case speed is
         when t_min    => return 0;
         when t_low    => return integer(ceil(0.25 * real(positions)));
         when t_medium => return integer(ceil(0.5 * real(positions)));
         when t_high   => return integer(ceil(0.75 * real(positions)));
         when t_max    => return positions;
         when others   => return 0;  --no value assigned
      end case;
   end function;

end package body;