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
/     This is a testbench generated for the adder module.
/
 **************************************************************************************************/

library ieee;
   use ieee.numeric_std.all;
   use ieee.std_logic_1164.all;
   use ieee.math_real.all;

library work;
   use work.common_data_types_pkg.all;
   use work.common_pkg.all;
   use work.fixed_generic_pkg.all;
   use work.adder_pkg.all;
   use work.tb_pkg.all;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

entity adder_tb is

end entity;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

architecture adder_tb1 of adder_tb is

/* constants                                                                                      */
/**************************************************************************************************/

   constant UNSIGNED_2COMP_opt       : boolean_tb      := (true, false);   --default
   constant DATA_IMM_AFTER_START_opt : boolean_tb      := (false, true);   --default
   constant SPEED_opt                : T_speed_tb      := (t_medium, true);  --exception: value not set
   constant MAX_POSSIBLE_BIT_opt     : integer_exc_tb  := (2, false);      --exception: value not set
   constant TRUNCATE_TO_BIT_opt      : integer_exc_tb  := (-2, false);      --exception: value not set
   constant S                        : positive        := 2;               --compulsory

   constant used_UNSIGNED_2COMP_opt       : boolean     := value_used(UNSIGNED_2COMP_opt, false);
   constant used_DATA_IMM_AFTER_START_opt : boolean     := value_used(DATA_IMM_AFTER_START_opt, false);
   constant used_SPEED_opt                : T_speed     := value_used(SPEED_opt);
   constant used_MAX_POSSIBLE_BIT_opt     : integer_exc := value_used(MAX_POSSIBLE_BIT_opt);
   constant used_TRUNCATE_TO_BIT_opt      : integer_exc := value_used(TRUNCATE_TO_BIT_opt);

/* signals                                                                                        */
/**************************************************************************************************/

   constant P               : positive := 4;
   constant NORMALIZED_HIGH : integer  := 1;
   constant NORMALIZED_LOW  : integer  := 0;
   constant IN_HIGH         : natural  := NORMALIZED_HIGH+SULV_NEW_ZERO;
   constant IN_LOW          : natural  := NORMALIZED_LOW+SULV_NEW_ZERO;
   constant OUT_HIGH        : natural  := SULV_NEW_ZERO+adder_OH(used_MAX_POSSIBLE_BIT_opt,
                                                                 S,
                                                                 P,
                                                                 NORMALIZED_HIGH);
   constant OUT_LOW         : natural  := SULV_NEW_ZERO+adder_OL(used_TRUNCATE_TO_BIT_opt,
                                                                 NORMALIZED_LOW);


   --IN--
   signal input        : sulv_v(1 to P)(IN_HIGH downto IN_LOW);
   signal clk          : std_ulogic := '1';
   signal start        : std_ulogic;
   signal valid_input  : std_ulogic;

   --OUT--
   signal output       : std_ulogic_vector(OUT_HIGH downto OUT_LOW);
   signal valid_output : std_ulogic;

----------------------------------------------------------------------------------------------------

   signal aux_counter1 : unsigned(0 to 29) := to_unsigned(1, 30);
   signal aux_counter2 : unsigned(0 to 29) := to_unsigned(2, 30);

/*================================================================================================*/
/*================================================================================================*/

begin

   msg_debug("adder_tb_IN_HIGH: " & image(IN_HIGH));
   msg_debug("adder_tb_IN_LOW: " & image(IN_LOW));
   msg_debug("adder_tb_OUT_HIGH: " & image(OUT_HIGH));
   msg_debug("adder_tb_OUT_LOW: " & image(OUT_LOW));

   adder1:
   entity work.adder
      generic map(
         UNSIGNED_2COMP_opt       => used_UNSIGNED_2COMP_opt,
         DATA_IMM_AFTER_START_opt => used_DATA_IMM_AFTER_START_opt,
         SPEED_opt                => used_SPEED_opt,
         MAX_POSSIBLE_BIT_opt     => used_MAX_POSSIBLE_BIT_opt,
         TRUNCATE_TO_BIT_opt      => used_TRUNCATE_TO_BIT_opt,
         S                        => S
      )
      port map(
         input        => input,
         clk          => clk,
         start        => start,
         valid_input  => valid_input,
         output       => output,
         valid_output => valid_output
      );

   --pragma translate off

   process (clk)
   begin
      if rising_edge(clk) then
         aux_counter1 <= aux_counter1 + to_unsigned(1, 30);
         aux_counter2 <= aux_counter2 + to_unsigned(1, 30);
      end if;
   end process;

   process (clk)
   begin
      clk <= not clk after 2 ps;
   end process;

   --generates pseudorandom values for the input
   process (clk)
      variable real_number : real;
      variable seed1 : positive := to_integer(aux_counter1);
      variable seed2 : positive := to_integer(aux_counter2);
   begin
      if rising_edge (clk) then
         for i in 1 to P loop
            uniform(seed1, seed2, real_number);
            input(i) <= to_sulv(to_ufixed(real_number, -1, -1 -IN_HIGH + IN_LOW));
         end loop;
      end if;
   end process;

   --pragma translate on

end architecture;