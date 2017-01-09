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
/     This package contains necessary types, constants, and functions for the parameterized adder
/  design.
/
 **************************************************************************************************/

library ieee;
   use ieee.std_logic_1164.all;
   use ieee.math_real.all;
   use ieee.numeric_std.all;

library work;
   use work.common_data_types_pkg.all;
   use work.common_pkg.all;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

package adder_pkg is


/* function used to check the consistency and correctness of generics                           1 */
/**************************************************************************************************/

   function adder_CHECKS (
      max_possible_bit_opt : integer_exc;
      truncate_to_bit_opt  : integer_exc;
      s                    : positive;
      p                    : positive;
      data_high            : integer;
      data_low             : integer)
   return integer;


/* functions for corrected generics and internal/external port signals                          2 */
/**************************************************************************************************/

   function adder_OH(
      max_possible_bit_opt : integer_exc;
      s                    : positive;
      p                    : positive;
      data_high            : integer)
   return integer;

   function adder_OL(
      truncate_to_bit_opt : integer_exc;
      data_low            : integer)
   return integer;

/* structures and functions to store and read pipeline positions                                3 */
/**************************************************************************************************/
   -- PIPELINE_POSITIONS stores the desired position for the pipelines in the adder tree,
   --    accumulator and output_buffer.
   -- It depends on:
   --    1. total number of possible pipeline positions = ADD_LEVELS + 1(output buffer)
   --    2. the number of desired pipelines
   --    3. '1' or '0' to indicate the presence of a pipeline on that level

/*
   type T_pipeline is record
      P1 : sulv_v(0 to 1)(1 to 1);
      P2 : sulv_v(0 to 2)(1 to 2);
      P3 : sulv_v(0 to 3)(1 to 3);
      P4 : sulv_v(0 to 4)(1 to 4);
      P5 : sulv_v(0 to 5)(1 to 5);
      P6 : sulv_v(0 to 6)(1 to 6);
      P7 : sulv_v(0 to 7)(1 to 7);
      P8 : sulv_v(0 to 8)(1 to 8);
      P9 : sulv_v(0 to 9)(1 to 9);
      P10: sulv_v(0 to 10)(1 to 10);
      P11: sulv_v(0 to 11)(1 to 11);
      P12: sulv_v(0 to 12)(1 to 12);   -- P12 limit => implies a maximum of 1024 parallel inputs.
                                       --    For PX, limit is 2**(X-2)
   end record;

   constant PIPELINE_POSITIONS: T_pipeline:=
      (P1  => (0  => "0",
               1  => "1"),
       P2  => (0  => "00",
               1  => "01",
               2  => "11"),
       P3  => (0  => "000",
               1  => "001",
               2  => "101",
               3  => "111"),
       P4  => (0  => "0000",
               1  => "0001",
               2  => "0101",------->4 (P4) possible positions: 2 pipelines wanted=> 2nd and 4th
               3  => "1011",
               4  => "1111"),
       P5  => (0  => "00000",
               1  => "00001",
               2  => "00101",
               3  => "10101",
               4  => "10111",
               5  => "11111"),
       P6  => (0  => "000000",
               1  => "000001",
               2  => "001001",
               3  => "010101",----->6 (P6) possible positions: 3 pipelines wanted=> 2nd, 4th and 6th
               4  => "101011",
               5  => "101111",
               6  => "111111"),
       P7  => (0  => "0000000",
               1  => "0000001",
               2  => "0001001",
               3  => "0010101",
               4  => "1010101",
               5  => "1010111",
               6  => "1011111",
               7  => "1111111"),
       P8  => (0  => "00000000",
               1  => "00000001",
               2  => "00010001",
               3  => "00100101",
               4  => "01010101",
               5  => "10101011",
               6  => "10101111",
               7  => "10111111",
               8  => "11111111"),
       P9  => (0  => "000000000",
               1  => "000000001",
               2  => "000010001",
               3  => "001001001",
               4  => "001010101",
               5  => "101010101",
               6  => "101010111",
               7  => "101011111",
               8  => "101111111",
               9  => "111111111"),
       P10 => (0  => "0000000000",
               1  => "0000000001",
               2  => "0000100001",
               3  => "0001001001",
               4  => "0010010101",
               5  => "0101010101",
               6  => "1010101011",
               7  => "1010101111",
               8  => "1010111111",
               9  => "1011111111",
               10 => "1111111111"),
       P11 => (0  => "00000000000",
               1  => "00000000001",
               2  => "00000100001",
               3  => "00010001001",
               4  => "00100100101",
               5  => "00101010101",
               6  => "10101010101",
               7  => "10101010111",
               8  => "10101011111",
               9  => "10101111111",
               10 => "10111111111",
               11 => "11111111111"),
       P12 => (0  => "000000000000",
               1  => "000000000001",
               2  => "000001000001",
               3  => "000100010001",
               4  => "001001001001",
               5  => "000101010101",
               6  => "010101010101",
               7  => "101010101011",
               8  => "101010101111",
               9  => "101010111111",
               10 => "101011111111",
               11 => "101111111111",
               12 => "111111111111")
      );

   --function used to read PIPELINE_POSITIONS
   function pipeline_is_present(
      possible_positions : positive;
      pipelines          : natural;
      level              : natural)
   return boolean;

   --used to get a numerical reference to T_pipeline members, for example pipeline_positions_ref(1)
   --   returns PIPELINE_POSITIONS.P1
   function pipeline_positions_ref(
      number : positive)
   return sulv_v;
*/

/* Other functions                                                                              4 */
/**************************************************************************************************/

   --returns the number of signals in a specific level of the tree adder
   function signals_per_level(
      P, level : natural)
   return natural;


end package;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

Package body adder_pkg is


/********************************************************************************************** 1 */

   function adder_CHECKS(
      max_possible_bit_opt : integer_exc;
      truncate_to_bit_opt  : integer_exc;
      s                    : positive;
      p                    : positive;
      data_high            : integer;
      data_low             : integer)
   return integer is
      constant output_h  : integer := adder_OH(max_possible_bit_opt,
                                               s,
                                               p,
                                               data_high);
   begin

   --Errors-----------------------------------------------------------------------------------------

      --trying to limit to a bit which is below the data range
      assert not(max_possible_bit_opt /= integer'low and max_possible_bit_opt<data_low)
         report "(3) " &
            "ILLEGAL PARAMETERS in entity adder: MAX_POSSIBLE_BIT_opt set to " &
            image(max_possible_bit_opt) & " but the result range is: (" & image(output_h) &
            " downto " & image(data_low) & ")."
         severity error;

      --trying to truncate to a value higher than norm_out_high
      assert not(truncate_to_bit_opt /= integer'low and truncate_to_bit_opt>output_h)
         report "(4) " &
            "ILLEGAL PARAMETERS in entity adder: TRUNCATE_TO_BIT_opt set to " &
            image(truncate_to_bit_opt) & " but the result range is: (" & image(output_h) &
            " downto " & image(data_low) & ")."
         severity error;

      --trying to truncate to a value higher than the bit limitation (duplicated with 4)
      assert not(max_possible_bit_opt /= integer'low and truncate_to_bit_opt /= integer'low and 
            truncate_to_bit_opt>max_possible_bit_opt)
         report "(5) " &
            "ILLEGAL PARAMETERS in entity adder: TRUNCATE_TO_BIT_opt cannot have a value higher " &
            "than MAX_POSSIBLE_BIT_opt"
         severity error;

   --Notes------------------------------------------------------------------------------------------
   --defined as warning so they appear in the report after synthesis

      --note when truncating
      assert not(truncate_to_bit_opt /= integer'low and truncate_to_bit_opt>data_low)
         report "(1) " &
            "NOTE in entity adder: truncating to bit " & image(truncate_to_bit_opt) & ". " &
            "The bottom " & image(truncate_to_bit_opt-data_low) &
            ite(truncate_to_bit_opt-data_low>1," bits are"," bit is") & " being ignored."
         severity warning;

      --note when truncation adds bits to the right
      assert not(truncate_to_bit_opt /= integer'low and truncate_to_bit_opt<data_low)
         report "(2) " &
            "NOTE in entity adder: truncating to bit " & image(truncate_to_bit_opt) & ". " &
            image(data_low-truncate_to_bit_opt) &
            ite(data_low-truncate_to_bit_opt>1," bits are"," bit is") & " being added to the right."
         severity warning;

      --note when limiting the number of bits
      assert not(max_possible_bit_opt /= integer'low and output_h<(data_high+log2ceil(s*p)))
         report "(3) " &
            "NOTE in entity adder: limiting the result of the addition to bit " &
            image(max_possible_bit_opt) & ". The top " & image((data_high+log2ceil(s*p))-output_h) &
            ite((data_high+log2ceil(s*p))-output_h>1," bits are"," bit is") & " not generated."
         severity warning;

      return 0;
   end function;


/********************************************************************************************** 2 */

   function adder_OH(
      max_possible_bit_opt : integer_exc;
      s                    : positive;
      p                    : positive;
      data_high            : integer)
   return integer is
   begin
      if max_possible_bit_opt = integer'low then
         return data_high+log2ceil(s*p);
      else
         return minimum(max_possible_bit_opt, data_high+log2ceil(s*p));
      end if ;
   end function;


   function adder_OL(
      truncate_to_bit_opt : integer_exc;
      data_low            : integer)
   return integer is
   begin
      if truncate_to_bit_opt = integer'low then
         return data_low;
      else
         return truncate_to_bit_opt;
      end if ;
   end function;


/********************************************************************************************** 3 */
/*
   function pipeline_is_present(
      possible_positions : positive;
      pipelines          : natural;
      level              : natural)
   return boolean is
   begin
      return ite(pipeline_positions_ref(possible_positions)(pipelines)(level)='1', true, false);
   end function;

   function pipeline_positions_ref(
      number: positive)
   return sulv_v is
   begin
      case number is
         when 1      => return PIPELINE_POSITIONS.P1;
         when 2      => return PIPELINE_POSITIONS.P2;
         when 3      => return PIPELINE_POSITIONS.P3;
         when 4      => return PIPELINE_POSITIONS.P4;
         when 5      => return PIPELINE_POSITIONS.P5;
         when 6      => return PIPELINE_POSITIONS.P6;
         when 7      => return PIPELINE_POSITIONS.P7;
         when 8      => return PIPELINE_POSITIONS.P8;
         when 9      => return PIPELINE_POSITIONS.P9;
         when 10     => return PIPELINE_POSITIONS.P10;
         when 11     => return PIPELINE_POSITIONS.P11;
         when 12     => return PIPELINE_POSITIONS.P12;
         when others => assert false
                           report "tried to access nonexistent member of PIPELINE_POSITIONS"
                           severity failure;
                        return PIPELINE_POSITIONS.P12;
      end case;
   end function;
*/

/********************************************************************************************** 4 */

   function signals_per_level(
      P, level : natural)
   return natural is
   begin
      if level=0 then
         return P;
      else
         return signals_per_level(natural(ceil(real(P)/2.0)), level-1);
      end if;
   end function signals_per_level;


end package body;