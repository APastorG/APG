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

entity perm_sp_core is

   generic(
      dimensions       : positive;
      p_dimensions     : positive;
      serial_dim       : natural;
      parallel_dim     : natural;
      left_ps_latency  : natural;
      right_ps_latency : natural;
      input_high       : natural;
      input_low        : natural
   );

   port(
      clk    : in  std_ulogic;
      start  : in  std_ulogic;
      input  : in  sulv_v;
      finish : out std_ulogic;
      output : out sulv_v(input_high downto input_low)
   );

end entity;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

architecture perm_sp_core_1 of perm_sp_core is
   --parallel dimensions
   constant P : natural  := p_dimensions;
   --serial dimensions
   constant S : natural  := dimensions - P;

   constant LATENCY : positive := integer((2.0**serial_dim)/(2.0**P));

   --latencies after removing delays whenever there are 2 consecutive sp permutations
   constant LATENCY_0 : natural := LATENCY - minimum(right_ps_latency, LATENCY);
   constant LATENCY_1 : natural := LATENCY - minimum(left_ps_latency, LATENCY);

   constant common_LATENCY : natural := LATENCY_0;

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

   signal start_delayed : std_ulogic_vector(0 to common_LATENCY);

/*================================================================================================*/
/*================================================================================================*/

begin


   count_is_not_zero <= '1' when to_integer(unsigned(count)) /= 0 else
                        '0';

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

   control <= count(serial_dim - P);

   generate_serial_parallel_permutation:
   for i in 1 to 2**(P-1) generate
         constant index0 : natural := calculate_indexes(integer(i-1), P, parallel_dim, 0);
         constant index1 : natural := calculate_indexes(integer(i-1), P, parallel_dim, 1);
         signal in0, in1 : std_ulogic_vector(input(input'left)'range);
         signal inter0   : sulv_v(0 to LATENCY_0-1)(input(input'left)'range);
         signal inter1   : sulv_v(0 to LATENCY_1-1)(input(input'left)'range);
      begin

         in0  <= input(index0);
         in1  <= input(index1);

         more_than_one_register_in_0:
         if LATENCY_0 > 0 generate
            begin
               process (clk) is
               begin
                  if rising_edge(clk) then
                     if LATENCY_1 > 0 then
                        inter0(0) <= in0 when control='0' else
                                     inter1(LATENCY_1 - 1);
                        inter1(0) <= in1;
                        if LATENCY_1 > 1 then
                           inter1(1 to LATENCY_1 - 1) <= inter1(0 to LATENCY_1 - 2);
                        end if;
                     end if;
                     if LATENCY_0 > 1 then
                        inter0(1 to LATENCY_0 - 1) <= inter0(0 to LATENCY_0 - 2);
                     end if;
                  end if;
               end process;
               output(index0) <= inter0(LATENCY_0 - 1);
               latency_1_is_not_zero:
               if LATENCY_1 > 0 generate
                  begin
                     output(index1) <= inter1(LATENCY_1 - 1) when control = '0' else
                                       in0;
                  end;
               else generate
                  begin
                     output(index1) <= in1 when control='0' else
                                       in0;
                  end;
               end generate;
            end;
         else generate
            begin
               more_than_one_register_in_1:
               if LATENCY_1 > 0 generate
                  begin
                     process (clk) is
                     begin
                        if rising_edge(clk) then
                           inter1(0) <= in1;
                           inter1(1 to LATENCY_1 - 1) <= inter1(0 to LATENCY_1 - 2);
                        end if;
                     end process;
                     output(index1) <= inter1(LATENCY_1 - 1) when control = '0' else
                                       in0;
                     output(index0) <= in0 when control='0' else
                                       inter1(LATENCY_1 - 1);
                  end;
               else generate
                  begin
                     output(index1) <= in1 when control='0' else
                                       in0;
                     output(index0) <= in0 when control='0' else
                                       in1; 
                  end;
               end generate;
            end;
         end generate;

      end;
   end generate;


   finish <= start_delayed(common_LATENCY);
   start_delayed(0) <= start;

   process (clk) is
   begin
      if rising_edge(clk) then
         if common_LATENCY > 0 then
            start_delayed(1 to common_LATENCY) <= start_delayed(0 to common_LATENCY-1);
         end if;
      end if;
   end process;


end architecture;