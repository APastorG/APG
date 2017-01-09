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
/     The input must have ranges of type (x to x+(2^n)-1)(high downto low)
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
   use work.common_pkg.all;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

entity butterfly_s is

   generic(
      SPEED_opt  : T_speed := t_exc;  --exception: value not set
      EXTEND_opt : boolean := true    --default value
   );
   port(
      clk    : in  std_ulogic;
      input  : in  u_sfixed_v;
      output : out u_sfixed_v
   );

end entity;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

architecture butterfly_s_1 of butterfly_s is

   --signal inter : u_sfixed_v(input'range)(input'element'left+1 downto input'element'right);
   constant LENGTH : positive := input'length;

/*================================================================================================*/
/*================================================================================================*/

begin

   butterfly_core_s_1:
   entity work.butterfly_core_s
      generic map(
         SPEED_opt    => SPEED_opt,
         EXTEND_opt   => EXTEND_opt,
         RANGE1_LEFT  => input'left,
         RANGE1_RIGHT => input'right,
         RANGE2_LEFT  => input'element'left,
         RANGE2_RIGHT => input'element'right
      )
      port map(
         clk    => clk,
         input  => input,
         output => output
      );

end architecture;