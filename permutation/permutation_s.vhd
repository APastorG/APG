
library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;
   use ieee.math_real.all;
   use std.textio.all;

library work;
   use work.fixed_float_types.all;
   use work.fixed_generic_pkg.all;
   use work.common_pkg.all;
   use work.common_data_types_pkg.all;
   use work.permutation_pkg.all;

/*================================================================================================*/
/*================================================================================================*/

entity permutation_s is

   generic (
      INPUT_INDEXES  : integer_v := (0 => 0);   --default
      OUTPUT_INDEXES : integer_v                --compulsory
   );
   port(
      Clk          : in  std_ulogic;
      input        : in  u_sfixed_v;
      start        : in  std_ulogic;

      output       : out u_sfixed_v;
      finish       : out std_ulogic
   );

end entity;

/*================================================================================================*/
/*================================================================================================*/

architecture permutation_s_1 of permutation_s is

   function  corrected_input_indexes
   return integer_v is
      variable result : integer_v(0 to OUTPUT_INDEXES'length-1);
   begin
      if INPUT_INDEXES'length = 1 and INPUT_INDEXES(0) = 0 then
         for i in 0 to INPUT_INDEXES'length-1 loop
            result(i) := OUTPUT_INDEXES'length - 1 - i;
         end loop;
         return result;
      else
         return INPUT_INDEXES;
      end if;
   end function;

   constant INPUT_INDEXES_corrected : integer_v := corrected_input_indexes;

   --normal order for the second dimension is descending
   signal corrected_input_d : sulv_v(input'range)(input'element'length-1 downto 0);
   signal corrected_output_d : sulv_v(input'range)(input'element'length-1 downto 0);
   signal corrected_input_a : sulv_v(input'range)(0 to input'element'length-1);
   signal corrected_output_a : sulv_v(input'range)(0 to input'element'length-1);

   constant asc : boolean := input'ascending;

/*================================================================================================*/
/*================================================================================================*/

begin

   ascending_or_descending:
   if asc generate
         signal i : integer;
      begin
         generate_corrected_signals_a:
         for i in input'range generate
            begin
               corrected_input_a(i) <= to_sulv(input(input'high-i+input'low));
               output(input'high-i+input'low) <= to_sfixed(corrected_output_a(i), input(i));
            end;
         end generate;
      end;
   else generate
         signal i : integer;
      begin
         generate_corrected_signals_d:
         for i in input'range generate
            begin
               corrected_input_d(i) <= to_sulv(input(i));
               output(i) <= to_sfixed(corrected_output_d(i), input(i));
            end;
         end generate;
      end;
   end generate;


   ascending_or_descending_core:
   if asc generate
      permutation_core_a:
      entity work.permutation_core
         generic map(
            INPUT_INDEXES  => INPUT_INDEXES_corrected,
            OUTPUT_INDEXES => OUTPUT_INDEXES,
            INPUT_HIGH     => input'high,
            INPUT_LOW      => input'low
         )
         port map(
            clk          => clk,
            input        => corrected_input_a,
            start        => start,
            output       => corrected_output_a,
            finish       => finish
         );
   else generate
      permutation_core_d:
      entity work.permutation_core
         generic map(
            INPUT_INDEXES  => INPUT_INDEXES_corrected,
            OUTPUT_INDEXES => OUTPUT_INDEXES,
            INPUT_HIGH     => input'high,
            INPUT_LOW      => input'low
         )
         port map(
            clk          => clk,
            input        => corrected_input_d,
            start        => start,
            output       => corrected_output_d,
            finish       => finish
         );
   end generate;

end architecture;

