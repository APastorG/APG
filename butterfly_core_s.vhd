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
   use work.common_data_types_pkg.all;
   use work.common_pkg.all;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

entity butterfly_core_s is
	
	generic(
      SPEED_opt    : T_speed;
      EXTEND_opt   : boolean;
      RANGE1_LEFT  : positive;
      RANGE1_RIGHT : positive;
      RANGE2_LEFT  : integer;
      RANGE2_RIGHT : integer
	);

   port(
      clk    : in  std_ulogic;
      input  : in  u_sfixed_v;
      output : out u_sfixed_v(RANGE1_LEFT to RANGE1_RIGHT)(ite(EXTEND_opt,
                                                               RANGE2_LEFT+1,
                                                               RANGE2_LEFT)
                                                           downto
                                                           RANGE2_RIGHT)
   );

end entity;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

architecture butterfly_core_s_1 of butterfly_core_s is

/*================================================================================================*/
/*================================================================================================*/

begin

   assert integer(2.0**log2(real(input'length))) = 2**integer(log2(real(input'length)))
      report "ERROR in module butterfly: the size of the input signal is not a power of 2"
      severity error;

   generate_butterfly:
   for i in output'low  to output'low+input'length/2-1 generate
      begin
         generate_pipeline:
         if is_pipelined(positions => 1,
                         speed => SPEED_opt,
                         position => 1) generate
            begin
               process (clk) is
               begin
                  if rising_edge(clk) then
                     output(i) <= resize(input(i) + input(i+input'length/2), output(i));
                     output(i+input'length/2) <= resize(input(i) - input(i+input'length/2), output(i));
                  end if;
               end process;
            end;
         else generate
            begin
               output(i) <= resize(input(i) + input(i+input'length/2), output(i));
               output(i+input'length/2) <= resize(input(i) - input(i+input'length/2), output(i));
            end;
         end generate;
      end;
   end generate;


end architecture;