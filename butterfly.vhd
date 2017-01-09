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
/     The input must have ranges of type for example (0 to 7)(high downto low)
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

entity butterfly is
   
   generic(
      SPEED_opt  : T_speed;
      EXTEND_opt : boolean
   );
   port(
      clk    : in  std_ulogic;
      input  : in  sulv_v;
      output : out sulv_v
   );

end entity;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

architecture butterfly_1 of butterfly is

   signal aux_in  : u_sfixed_v(input'range)
                              (input'element'high downto input'element'low);
   signal aux_out : u_sfixed_v(input'range)
                              (input'element'high+1 downto input'element'low);

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
         input  => aux_in,
         output => aux_out
      );

   generate_ports:
   for i in input'range generate
      begin
         aux_in(i) <= to_sfixed(input(i), aux_in(i));
         output(i) <= to_sulv(aux_out(i));
      end;
   end generate;

end architecture;