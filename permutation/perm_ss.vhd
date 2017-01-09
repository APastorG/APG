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

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

entity perm_ss is

   generic(
      indexes    : integer_v(1 to 2);
      dimensions : positive
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

architecture perm_ss_1 of perm_ss is
   --highest serial index
   constant J : positive := maximum(indexes(1), indexes(2));
   --lowest serial index
   constant K : positive := minimum(indexes(1), indexes(2));
   --parallel dimensions
   constant P : natural  := integer(log2(real(input'length)));
   --serial dimensions
   constant S : natural  := dimensions - P;

   constant LATENCY : positive := integer((2.0**J-2**K)/(2.0*P));

   signal count_is_not_zero : std_ulogic;

   signal counter_out : std_ulogic;

   signal count : std_ulogic_vector(counter_CW(true, --UNSIGNED_2COMP_opt,
                                               0, --COUNTER_WIDTH_dep,
                                               true, --TARGET_MODE,
                                               (2 ** S)- 1, --TARGET_dep,
                                               true, --TARGET_WITH_COUNT_opt = t_true,
                                               false, --USE_SET,
                                               1) - 1 --SET_TO_dep)
                                    downto 0); --only the serial indexes (N downto P) mapped to downto 0

   signal control : std_ulogic;

   signal start_delayed : std_ulogic_vector(0 to LATENCY);

/*================================================================================================*/
/*================================================================================================*/

begin


   count_is_not_zero <= unsigned(count) ?/= 0;

   counter:
   entity work.counter
      generic map(
         UNSIGNED_2COMP_opt     => true,
         OVERFLOW_BEHAVIOR_opt  => t_wrap,
         --COUNT_MODE_opt         => t_up,
         --COUNTER_WIDTH_dep      => ,
         TARGET_MODE            => true,
         TARGET_dep             => (2 ** S)- 1,
         TARGET_WITH_COUNT_opt  => t_true,
         TARGET_BLOCKING_opt    => t_false,
         USE_SET                => false,
         --SET_TO_dep             => ,
         USE_RESET              => true,
         --SET_RESET_PRIORITY_opt => ,
         USE_LOAD               => false
      )
      port map(
         clk                  => clk,
         enable               => count_is_not_zero or start_delayed(0),
         --set                  => ,
         reset                => counter_out,
         --load                 => ,
         --count_mode_signal    => ,
         --value_to_load        => ,
         count                => count,
         count_is_TARGET(1)   => counter_out
      );

   control <= not(count(J-P)) or count(K-P);

   generate_serial_serial_permutation:
   for i in input'range generate
         signal inter : sulv_v(0 to LATENCY-1)(input(input'left)'range);
      begin
         process(clk) is
         begin
            if rising_edge(clk) then
               inter(0) <= inter(LATENCY-1) when control='0' else
                           input(i);
            end if;
         end process;
         output(i) <= input(i) when control='0' else
                      inter(LATENCY-1);

         more_than_one_register:
         if LATENCY > 1 generate
            begin
               process (clk) is
               begin
                  if rising_edge(clk) then
                     inter(1 to LATENCY-1) <= inter(0 to LATENCY-2);
                  end if;
               end process;
            end;
         end generate;

      end;
   end generate;


   finish <= start_delayed(LATENCY);
   start_delayed(0) <= start;

   process (clk) is
   begin
      if rising_edge(clk) then
         if LATENCY > 0 then
            start_delayed(1 to LATENCY) <= start_delayed(0 to LATENCY-1);
         END IF;
      end if;
   end process;


end architecture;