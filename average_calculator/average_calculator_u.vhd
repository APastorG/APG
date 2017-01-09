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
/     This design makes use of some features from VHDL-2008, all of which have been implemented in
/  Vivado by Xilinx 
/     A 3 space tab is used throughout the document
/
/
/  Description:
/  ¯¯¯¯¯¯¯¯¯¯¯
/     This is the interface between the instantiation of an adder an its core. It exists to make it
/  possible to use external std_ulogic_vector which contain the numeric values while having modules
/  which are able to manipulate this data as fixed point types (either u_ufixed or u_sfixed).
/     As std_ulogic_vector have a natural range and the u_ufixed and u_sfixed types have an integer
/  range ('high downto 0 is the integer part and -1 downto 'low is the fractional part) it is needed
/  a solution so as to represent the negative indexes in the std_ulogic_vector. A solution is
/  adopted where the integer indexes of the fixed point types are moved to the natural space with a
/  transformation. This consists in limiting the indexes of the fixed point data to +-2**30 and 
/  adding 2**30 to obtain the std_ulogic_vector's indexes. [-2**30, 2**30]->[0, 2**31]. For example,
/  fixed point indexes (3 donwto -2) would become (1073741827, 1073741822) in a std_ulogic_vector
/     Additionally, the generics' consistency and correctness are checked in here.
/
 **************************************************************************************************/

library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;
   use ieee.math_real.all;

library work;
   use work.common_data_types_pkg.all;
   use work.common_pkg.all;
   use work.adder_pkg.all;
   use work.fixed_generic_pkg.all;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

entity average_calculator_u is

   generic(
      DATA_IMM_AFTER_START_opt : boolean       := false;          --default
      SPEED_opt                : T_speed       := t_min;             --exception: value not set
      ROUND_STYLE_opt          : T_round_style := fixed_truncate; --default
      ROUND_TO_BIT_opt         : integer_exc   := integer'low;    --exception: value not set
      MAX_ERROR_PCT_opt        : real_exc      := real'low;       --exception: value not set
      S                        : positive                         --compulsory
   );

   port(
      input        : in  u_ufixed_v; --unconstrained array
      clk          : in  std_ulogic;
      start        : in  std_ulogic;
      valid_input  : in  std_ulogic;

      output       : out u_ufixed; --unconstrained array
      valid_output : out std_ulogic
   );

end entity;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

architecture average_calculator_u1 of average_calculator_u is

   constant P             : positive := input'length;
/*   constant CHECKS        : integer := average_calculator_CHECKS();*/

/*================================================================================================*/
/*================================================================================================*/

begin

   average_calculator_core_u1:
   entity work.average_calculator_core_u
      generic map(
         DATA_IMM_AFTER_START_opt => DATA_IMM_AFTER_START_opt,
         SPEED_opt                => SPEED_opt,
         ROUND_STYLE_opt          => ROUND_STYLE_opt,
         ROUND_TO_BIT_opt         => ROUND_TO_BIT_opt,
         MAX_ERROR_PCT_opt        => MAX_ERROR_PCT_opt,
         S                        => S,
         P                        => P,
         input_high               => input(1)'high,
         input_low                => input(1)'low
      )
      port map(
         clk          => clk,
         input        => input,
         valid_input  => valid_input,
         start        => start,
         output       => output,
         valid_output => valid_output
      );


end architecture;