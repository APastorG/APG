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
   use work.counter_pkg.all;
   use work.permutation_pkg.all;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

entity perm_sp is

   generic(
      dimensions       : positive;
      p_dimensions     : positive;
      serial_dim       : natural;
      parallel_dim     : natural;
      left_ps_latency  : natural;
      right_ps_latency : natural
   );

   port(
      clk    : in  std_ulogic;
      start  : in  std_ulogic;
      input  : in  sulv_v;
      finish : out std_ulogic;
      output : out sulv_v
   );

end entity;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

architecture perm_sp_1 of perm_sp is

/*================================================================================================*/
/*================================================================================================*/

begin

   perm_sp_core:
   entity work.perm_sp_core
   generic map(
      dimensions       => dimensions,
      p_dimensions     => p_dimensions,
      serial_dim       => serial_dim,
      parallel_dim     => parallel_dim,
      left_ps_latency  => left_ps_latency,
      right_ps_latency => right_ps_latency,
      input_high       => input'high,
      input_low        => input'low
   )
   port map(
      clk    => clk,
      start  => start,
      input  => input,
      finish => finish,
      output => output
   );

end architecture;