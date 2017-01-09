
library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;
   use ieee.math_real.all;
   use std.textio.all;

library work;
   use work.fixed_float_types.all;
   use work.fixed_generic_pkg.all;
   use work.common_pkg.all;
   use work.common_data_types_pkg.all;
   use work.permutation_pkg.all;

/*================================================================================================*/
/*================================================================================================*/

entity permutation_tb is

end entity;

/*================================================================================================*/
/*================================================================================================*/

architecture permutation_tb_1 of permutation_tb is


/* constants                                                                                      */
/**************************************************************************************************/

   constant INPUT_INDEXES  : integer_v := (2, 0, 3, 1); --optional
   constant OUTPUT_INDEXES : integer_v := (0, 2, 3, 1); --compulsory

/* signals                                                                                        */
/**************************************************************************************************/

   constant PARALLEL_DIMENSIONS : positive := 3;


   constant INPUT_LENGTH : positive := integer(2**PARALLEL_DIMENSIONS);
   constant INPUT_SIZE   : positive := OUTPUT_INDEXES'length;

   --IN
   signal clk          : std_ulogic := '1';
   signal input        : u_sfixed_v(0 to INPUT_LENGTH-1)(INPUT_SIZE-1 downto 0);
   signal start        : std_ulogic := '0';
   --OUT
   signal output       : u_sfixed_v(0 to INPUT_LENGTH-1)(INPUT_SIZE-1 downto 0);
   signal finish       : std_ulogic;

----------------------------------------------------------------------------------------------------

   signal aux_counter1 : unsigned(0 to 29) := to_unsigned(1, 30);
   signal aux_counter2 : unsigned(0 to 29) := to_unsigned(2, 30);

   signal aux_counter3 : unsigned(0 to OUTPUT_INDEXES'length-1) := to_unsigned(0, INPUT_SIZE);

/*================================================================================================*/
/*================================================================================================*/


begin

   permutation_s:
   entity work.permutation_s
      generic map(
         INPUT_INDEXES  => INPUT_INDEXES,
         OUTPUT_INDEXES => OUTPUT_INDEXES
      )
      port map(
         clk          => clk,
         input        => input,
         start        => start,
         output       => output,
         finish       => finish
      );

   --pragma translate off

   process (clk)
   begin
      clk <= not clk after 2 ps;
   end process;

   process
   begin
      wait for 36 ps;
      start <= '1';
      wait for 4 ps;
      start <= '0';
      wait;
   end process;

   --generates pseudorandom values for the input
   --process (clk)
   --   variable real_number : real;
   --   variable seed1 : positive := to_integer(aux_counter1);
   --   variable seed2 : positive := to_integer(aux_counter2);
   --begin
   --   if rising_edge (clk) then
   --      for i in input'range loop
   --         uniform(seed1, seed2, real_number);
   --         input(i) <= to_sulv(to_ufixed(real_number, -1, -INPUT_SIZE));
   --      end loop;
   --      aux_counter1 <= aux_counter1 + to_unsigned(1, 30);
   --      aux_counter2 <= aux_counter2 + to_unsigned(1, 30);
   --   end if;
   --end process;

   --generates values for the input that equal their index
   process (clk)
   begin
      if rising_edge (clk) then
         for i in input'range loop
            input(i) <= to_sfixed(to_integer(aux_counter3) + i, input(i));
         end loop;
         aux_counter3 <= aux_counter3 + input'length;
      end if;
   end process;

   --pragma translate on

end architecture;

