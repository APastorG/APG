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
 **************************************************************************************************/

library ieee;
   use ieee.numeric_std.all;
   use ieee.std_logic_1164.all;
   use ieee.math_real.all;

library work;
   use work.fixed_float_types.all;
   use work.fixed_generic_pkg.all;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

entity pipelines_s is

   generic( 
      LENGTH : natural
   );

   port(
      clk    : in  std_ulogic;
      input  : in  u_sfixed;
      output : out u_sfixed
   );

end entity;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

architecture pipelines_s_1 of pipelines_s is

   signal input_aux  : std_ulogic_vector(input'length-1 downto 0);
   signal output_aux : std_ulogic_vector(input'length-1 downto 0);
   
begin

   pipelines_core_1:
   entity work.pipelines_core
      generic map(
         LENGTH     => LENGTH,
         INPUT_HIGH => input'high,
         INPUT_LOW  => input'low
      )
      port map(
         clk    => clk,
         input  => input_aux,
         output => output_aux
      );

   output    <= to_sfixed(output_aux, input'high, input'low);
   input_aux <= std_ulogic_vector(input);

end architecture;