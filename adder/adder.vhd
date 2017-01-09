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

entity adder is

   generic(
      UNSIGNED_2COMP_opt       : boolean     := false;       --default
      DATA_IMM_AFTER_START_opt : boolean     := false;       --default
      SPEED_opt                : T_speed     := t_min;       --exception: value not set
      MAX_POSSIBLE_BIT_opt     : integer_exc := integer'low; --exception: value not set
      TRUNCATE_TO_BIT_opt      : integer_exc := integer'low; --exception: value not set
      S                        : positive                    --compulsory
   );

   port(
      input        : in  sulv_v; --unconstrained array
      clk          : in  std_ulogic;
      start        : in  std_ulogic;
      valid_input  : in  std_ulogic;

      output       : out std_ulogic_vector; --unconstrained array
      valid_output : out std_ulogic
   );

end entity;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

architecture adder_1 of adder is

   constant P             : positive := input'length(1);
   constant CHECKS        : integer  := adder_CHECKS(MAX_POSSIBLE_BIT_opt,
                                                     TRUNCATE_TO_BIT_opt,
                                                     S,
                                                     P,
                                                     input(1)'high-SULV_NEW_ZERO,
                                                     input(1)'low-SULV_NEW_ZERO);

   constant NORM_IN_HIGH  : integer  := input(1)'high-SULV_NEW_ZERO;
   constant NORM_IN_LOW   : integer  := input(1)'low-SULV_NEW_ZERO;
   constant NORM_OUT_HIGH : integer  := adder_OH(MAX_POSSIBLE_BIT_opt,
                                                 S,
                                                 P,
                                                 NORM_IN_HIGH);
   constant NORM_OUT_LOW  : integer  := adder_OL(TRUNCATE_TO_BIT_opt,
                                                 NORM_IN_LOW);
   constant OUT_HIGH      : natural  := NORM_OUT_HIGH + SULV_NEW_ZERO;
   constant OUT_LOW       : natural  := NORM_OUT_LOW + SULV_NEW_ZERO;

   signal aux_input_s  : u_sfixed_v(1 to P)(NORM_IN_HIGH downto NORM_IN_LOW);
   signal aux_output_s : u_sfixed(NORM_OUT_HIGH downto NORM_OUT_LOW);

   signal aux_input_u  : u_ufixed_v(1 to P)(NORM_IN_HIGH downto NORM_IN_LOW);
   signal aux_output_u : u_ufixed(NORM_OUT_HIGH downto NORM_OUT_LOW);

/*================================================================================================*/
/*================================================================================================*/

begin

   msg_debug("adder_NORM_IN_HIGH: " & image(NORM_IN_HIGH));
   msg_debug("adder_NORM_IN_LOW: " & image(NORM_IN_LOW));
   msg_debug("adder_NORM_OUT_HIGH: " & image(NORM_OUT_HIGH));
   msg_debug("adder_NORM_OUT_LOW: " & image(NORM_OUT_LOW));
   msg_debug("adder_OUT_HIGH: " & image(OUT_HIGH));
   msg_debug("adder_OUT_LOW: " & image(OUT_LOW));
   msg_debug("adder_UNSIGNED_2COMP_opt: " & image(UNSIGNED_2COMP_opt));

   adder_selection:
   if UNSIGNED_2COMP_opt generate
      begin

         generate_input:
         for i in 1 to P generate
            begin
               aux_input_u(i) <= to_ufixed(unsigned(input(i)), aux_input_u(i));
            end;
         end generate;

         output(OUT_HIGH downto OUT_LOW)
            <= to_sulv(aux_output_u);

         adder_u_1:
         entity work.adder_u
            generic map(
               DATA_IMM_AFTER_START_opt => DATA_IMM_AFTER_START_opt,
               SPEED_opt                => SPEED_opt,
               MAX_POSSIBLE_BIT_opt     => MAX_POSSIBLE_BIT_opt,
               TRUNCATE_TO_BIT_opt      => TRUNCATE_TO_BIT_opt,
               S                        => S
            )
            port map(
               clk          => clk,
               input        => aux_input_u,
               valid_input  => valid_input,
               start        => start,
               output       => aux_output_u,
               valid_output => valid_output
            );

      end;
   else generate
      begin

         generate_input:
         for i in 1 to P generate
            begin
               aux_input_s(i) <= to_sfixed(signed(input(i)), aux_input_s(i));
            end;
         end generate;

         output(OUT_HIGH downto OUT_LOW)
            <= to_sulv(aux_output_s);

         adder_s_1:
         entity work.adder_s
            generic map(
               DATA_IMM_AFTER_START_opt => DATA_IMM_AFTER_START_opt,
               SPEED_opt                => SPEED_opt,
               MAX_POSSIBLE_BIT_opt     => MAX_POSSIBLE_BIT_opt,
               TRUNCATE_TO_BIT_opt      => TRUNCATE_TO_BIT_opt,
               S                        => S
            )
            port map(
               clk          => clk,
               input        => aux_input_s,
               valid_input  => valid_input,
               start        => start,
               output       => aux_output_s,
               valid_output => valid_output
            );

      end;
   end generate;


end architecture;
