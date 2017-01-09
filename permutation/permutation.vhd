
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

entity permutation is

   generic (
      INPUT_INDEXES  : integer_v := (0 => 0);   --default
      OUTPUT_INDEXES : integer_v                --compulsory
   );
   port(
      Clk          : in  std_ulogic;
      input        : in  sulv_v;
      start        : in  std_ulogic;

      output       : out sulv_v;
      finish       : out std_ulogic
   );

end entity;

/*================================================================================================*/
/*================================================================================================*/

architecture permutation_1 of permutation is

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

/*================================================================================================*/
/*================================================================================================*/

begin

   permutation_core:
   entity work.permutation_core
      generic map(
         INPUT_INDEXES  => INPUT_INDEXES_corrected,
         OUTPUT_INDEXES => OUTPUT_INDEXES,
         INPUT_HIGH     => input'high,
         INPUT_LOW      => input'low
      )
      port map(
         clk          => clk,
         input        => input,
         start        => start,
         output       => output,
         finish       => finish
      );

end architecture;

