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
   use ieee.numeric_std.all;
   use ieee.std_logic_1164.all;
   use ieee.math_real.all;

library work;
   use work.fixed_float_types.all;
   use work.fixed_generic_pkg.all;
   use work.common_data_types_pkg.all;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

entity pipelines_core is

   generic( 
      LENGTH     : natural;
      INPUT_HIGH : integer;
      INPUT_LOW  : integer
   );

   port(
      clk    : in  std_ulogic;
      input  : in  std_ulogic_vector;
      output : out std_ulogic_vector
   );

end entity;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

architecture pipelines_core_1 of pipelines_core is

/*================================================================================================*/
/*================================================================================================*/

begin

   generate_pipelines:
   if LENGTH = 0 generate
      begin
         output <= input;
      end;
   elsif LENGTH = 1 generate
         signal aux : std_ulogic_vector(input'range);
      begin
         process (clk) is
         begin
            if rising_edge(clk) then
               aux    <= input;
               output <= aux;
            end if;
         end process;   
      end;
   else generate
         signal aux : sulv_v(1 to LENGTH)(input'range);
      begin
         process (clk) is
         begin
            if rising_edge(clk) then
               aux(1)           <= input;
               aux(2 to LENGTH) <= aux(1 to LENGTH-1);
               output           <= aux(LENGTH);
            end if;
         end process;   
      end;
   end generate;

end architecture;