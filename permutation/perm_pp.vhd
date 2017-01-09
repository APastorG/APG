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
/
/
 **************************************************************************************************/

library ieee;
   use ieee.std_logic_1164.all;
   use ieee.math_real.all;
   use ieee.numeric_std.all;

library work;
   use work.common_pkg.all;
   use work.common_data_types_pkg.all;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

entity perm_pp is

   generic(
      indexes : integer_v(1 to 2)
   );

   port(
      input  : in  sulv_v;
      start  : in  std_ulogic;
      output : out sulv_v;
      finish : out std_ulogic
   );

end entity;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

architecture perm_pp_1 of perm_pp is

   --parallel dimensions
   constant P : natural  := integer(log2(real(input'length)));

   constant INDEX1 : integer := indexes(1);

   constant INDEX2 : integer := indexes(2);

/*================================================================================================*/
/*================================================================================================*/

begin

   --control part
   finish <= start;

   --data part
   for_every_index:
   for i in input'range generate
         constant aux : std_ulogic_vector(P-1 downto 0) := std_logic_vector(to_unsigned(i, P));
         signal result : std_ulogic_vector(P-1 downto 0);
      begin
         generate_signals_permutation:
         for j in result'range generate
            result(j) <= aux(INDEX2) when j = INDEX1 else
                         aux(INDEX1) when j = INDEX2 else
                         aux(j);
         end generate;
         output(i) <= input(to_integer(unsigned(result)));
      end;
   end generate;


end architecture;