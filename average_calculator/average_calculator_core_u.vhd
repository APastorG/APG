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
   use work.average_calculator_pkg.all;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

entity average_calculator_core_u is

   generic(
      DATA_IMM_AFTER_START_opt : boolean;
      SPEED_opt                : T_speed;
      ROUND_STYLE_opt          : T_round_style;
      ROUND_TO_BIT_opt         : integer_exc;
      MAX_ERROR_PCT_opt        : real_exc;
      S                        : positive;
      P                        : positive;
      input_high               : integer;
      input_low                : integer
   );

   port(
      input        : in  u_ufixed_v(1 to P);
      clk          : in  std_ulogic;
      start        : in  std_ulogic;
      valid_input  : in  std_ulogic;

      output       : out u_ufixed(average_calculator_OH(true, --UNSIGNED_2COMP_opt,
                                                        ROUND_STYLE_opt,
                                                        ROUND_TO_BIT_opt,
                                                        MAX_ERROR_PCT_opt,
                                                        S,
                                                        P,
                                                        input_high,
                                                        input_low)
                                  downto
                                  average_calculator_OL(true, --UNSIGNED_2COMP_opt,
                                                        ROUND_STYLE_opt,
                                                        ROUND_TO_BIT_opt,
                                                        MAX_ERROR_PCT_opt,
                                                        S,
                                                        P,
                                                        input_high,
                                                        input_low)
                                  );
      valid_output : out std_ulogic
   );

end entity;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

architecture average_calculator_core_u1 of average_calculator_core_u is

   constant INTER_HIGH : integer := average_calculator_IH(S,
                                                          P,
                                                          input_high);

   constant INTER_LOW  : integer := average_calculator_IL(ROUND_TO_BIT_opt,
                                                          input_low);

   constant OUT_HIGH   : integer := average_calculator_OH(true, --UNSIGNED_2COMP_opt,
                                                          ROUND_STYLE_opt,
                                                          ROUND_TO_BIT_opt,
                                                          MAX_ERROR_PCT_opt,
                                                          S,
                                                          P,
                                                          input_high,
                                                          input_low);

   constant OUT_LOW    : integer := average_calculator_OL(true, --UNSIGNED_2COMP_opt,
                                                          ROUND_STYLE_opt,
                                                          ROUND_TO_BIT_opt,
                                                          MAX_ERROR_PCT_opt,
                                                          S,
                                                          P,
                                                          input_high,
                                                          input_low);

   signal inter : u_ufixed(INTER_HIGH downto INTER_LOW);

   signal valid_output_inter : std_ulogic;

/*================================================================================================*/
/*================================================================================================*/

begin


   adder_u1:
   entity work.adder_u
      generic map(
         DATA_IMM_AFTER_START_opt => DATA_IMM_AFTER_START_opt,
         SPEED_opt                =>  SPEED_opt,
         --MAX_POSSIBLE_BIT_opt     => ,
         TRUNCATE_TO_BIT_opt      => ROUND_TO_BIT_opt,
         S                        => S
      )
      port map(
         input        => input,
         clk          => clk,
         start        => start,
         valid_input  => valid_input,
         output       => inter,
         valid_output => valid_output_inter
      );

   real_const_mult_u1:
   entity work.real_const_mult_u
      generic map(
         SPEED_opt          => SPEED_opt,
         ROUND_STYLE_opt    => ROUND_STYLE_opt,
         ROUND_TO_BIT_opt   => ROUND_TO_BIT_opt,
         MAX_ERROR_PCT_opt  => MAX_ERROR_PCT_opt,
         MULTIPLICANDS      => (1 => 1.0/(S*P))
      )
      port map(
         input        => inter,
         clk          => clk,
         valid_input  => valid_output_inter,
         output(1)    => output,
         valid_output => valid_output
      );


end architecture;