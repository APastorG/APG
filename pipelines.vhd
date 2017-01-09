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

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

entity pipelines is

   generic( 
      LENGTH : natural
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

architecture pipelines_1 of pipelines is

begin

   pipelines_core_1:
   entity work.pipelines_core
      generic map(
         LENGTH => LENGTH,
         INPUT_HIGH => input'high,
         INPUT_LOW  => input'low
      )
      port map(
         clk    => clk,
         input  => input,
         output => output
      );

end architecture;