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
/     This is a design of a parameterized adder which allows the addition of signed numbers
/  with high fexibility and control over the way data is introduced and the level of pipelining it
/  will be used
/                   ┌ ┌───────┐
/                   │ │ i e a │
/        input:    P│ │ j f b │        _______
/                   │ │ k g c │ ----> | adder | ----> result
/                   │ │ l h d │        ───────
/                   └ └───────┘
/                     └───────┘
/                         S
/     The clock cycles it takes to produce a result from the input can also be specified with the
/  SPEED_opt parameter. The higher this parameter, the shorter, in general, the delay path 
/  between each register and thus, the higher the frequency the design is able to reach.
/
 **************************************************************************************************/

library ieee;
   use ieee.numeric_std.all;
   use ieee.std_logic_1164.all;
   use ieee.math_real.all;

library work;
   use work.common_data_types_pkg.all;
   use work.common_pkg.all;
   use work.adder_pkg.all;
   use work.counter_pkg.all;
   use work.fixed_generic_pkg.all;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

entity adder_core_u is

   generic(
      DATA_IMM_AFTER_START_opt : boolean     := false;       --default
      SPEED_opt                : T_speed     := t_min;       --exception: value not set
      MAX_POSSIBLE_BIT_opt     : integer_exc := integer'low; --exception: value not set
      TRUNCATE_TO_BIT_opt      : integer_exc := integer'low; --exception: value not set
      S                        : positive;                   --compulsory
      P                        : positive;                   --compulsory
      input_high               : integer;
      input_low                : integer
   );

   port(
      input        : in  u_ufixed_v(1 to P); --unconstrained array
      clk          : in  std_ulogic;
      start        : in  std_ulogic;
      valid_input  : in  std_ulogic;

      output       : out u_ufixed(adder_OH(MAX_POSSIBLE_BIT_opt,
                                           S,
                                           P,
                                           input_high)
                                  downto
                                  adder_OL(TRUNCATE_TO_BIT_opt,
                                           input_low)
                                  );
      valid_output : out std_ulogic
   );

end entity;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

architecture adder_core_u_1 of adder_core_u is

/* corrected generics and internal/external ports' sizes                                          */
/**************************************************************************************************/
   constant CHECKS        : integer := adder_CHECKS(MAX_POSSIBLE_BIT_opt,
                                                    TRUNCATE_TO_BIT_opt,
                                                    S,
                                                    P,
                                                    input(1)'high,
                                                    input(1)'low);
   constant DATA_WIDTH           : positive  := input(1)'length;

   constant DATA_HIGH            : integer   := input(1)'high;

   constant DATA_LOW             : integer   := input(1)'low;

   constant OUTPUT_HIGH          : integer   := adder_OH(MAX_POSSIBLE_BIT_opt,
                                                         S,
                                                         P,
                                                         DATA_HIGH);

   constant OUTPUT_LOW           : integer   := adder_OL(TRUNCATE_TO_BIT_opt,
                                                         DATA_LOW);

   constant DATA_IMM_AFTER_START : boolean   := DATA_IMM_AFTER_START_opt;

   constant MAX_POSSIBLE_BIT     : integer   := ite(MAX_POSSIBLE_BIT_opt=integer'low,
                                                    integer'high - SULV_NEW_ZERO,
                                                    MAX_POSSIBLE_BIT_opt);

   constant ADD_LEVELS           : positive  := 1 + log2ceil(P);
   constant PIPELINE_POSITIONS   : natural   := ite(S = 1,
                                                    ADD_LEVELS,
                                                    ADD_LEVELS + 1);

   constant PIPELINES_2_INTRODUCE : natural := number_of_pipelines(PIPELINE_POSITIONS,
                                                                   SPEED_opt);
   constant CONDITION_EXC        : boolean := (not DATA_IMM_AFTER_START)
                                              and
                                              ((S = 1 and PIPELINES_2_INTRODUCE=0)
                                               or
                                               PIPELINES_2_INTRODUCE < 2);

   function is_pipelines_exc(
      s : positive;
      pipeline_positions : natural)
   return boolean_v is
      variable result : boolean_v(1 to pipeline_positions) := (others => false);
   begin
      result(ite(s = 1,
                 pipeline_positions,
                 pipeline_positions-1)) := true;
      return result;
   end function;

   constant IS_PIPELINED_EXC     : boolean_v := is_pipelines_exc(S,
                                                                 PIPELINE_POSITIONS);
   constant IS_PIPELINED         : boolean_v := ite(CONDITION_EXC,
                                                    IS_PIPELINED_EXC,
                                                    generate_pipelines(PIPELINE_POSITIONS,
                                                                       SPEED_opt)
                                                   );
   constant OUTPUT_BUFFER        : boolean   := ite(S = 1,
                                                    false,
                                                    ite(CONDITION_EXC,
                                                        false,
                                                        IS_PIPELINED(PIPELINE_POSITIONS))
                                                   );

   constant ACC_PIPELINES        : natural   := S - 1;
   constant ADD_PIPELINES        : natural   := ite(CONDITION_EXC,
                                                    1,
                                                    PIPELINES_2_INTRODUCE - ite(OUTPUT_BUFFER, 1, 0)
                                                    );
   constant PIPELINES            : natural   := ADD_PIPELINES + ACC_PIPELINES + ite(OUTPUT_BUFFER,
                                                                                    1,
                                                                                    0);


/* other constants                                                                                */
/**************************************************************************************************/

   constant INTER_HIGH          : integer  := minimum(DATA_HIGH + log2ceil(P),
                                                      MAX_POSSIBLE_BIT);


/* data signals                                                                                   */
/**************************************************************************************************/

   signal input_resolved : ufixed_v(1 to P)(input(1)'range); --where the input is converted to resolved
   signal inter          : u_ufixed(INTER_HIGH downto DATA_LOW);
   signal output_inter   : u_ufixed(OUTPUT_HIGH downto DATA_LOW);
   signal start_sh       : std_ulogic_vector(1 to ADD_PIPELINES);
   signal valid_input_sh : std_ulogic_vector(1 to ADD_PIPELINES);


/* control signals                                                                                */
/**************************************************************************************************/

   signal start_delayed       : std_ulogic;
   signal valid_input_delayed : std_ulogic;
   signal counter_out         : std_ulogic;


/* structures to store and manipulate data of the adder tree (ADD)                                */
/**************************************************************************************************/

   function T_ADD_state_data_high(
      index : natural)
   return integer is
   begin
      if DATA_HIGH+index > MAX_POSSIBLE_BIT then
         return MAX_POSSIBLE_BIT;
      else
         return DATA_HIGH + index;
      end if;
   end function;

   type T_ADD_state is record
      level0  : ufixed_v(1 to signals_per_level(P, 0 ))(T_ADD_state_data_high(0) downto DATA_LOW);
      level1  : ufixed_v(1 to signals_per_level(P, 1 ))(T_ADD_state_data_high(1) downto DATA_LOW);
      level2  : ufixed_v(1 to signals_per_level(P, 2 ))(T_ADD_state_data_high(2) downto DATA_LOW);
      level3  : ufixed_v(1 to signals_per_level(P, 3 ))(T_ADD_state_data_high(3) downto DATA_LOW);
      level4  : ufixed_v(1 to signals_per_level(P, 4 ))(T_ADD_state_data_high(4) downto DATA_LOW);
      level5  : ufixed_v(1 to signals_per_level(P, 5 ))(T_ADD_state_data_high(5) downto DATA_LOW);
      level6  : ufixed_v(1 to signals_per_level(P, 6 ))(T_ADD_state_data_high(6) downto DATA_LOW);
      level7  : ufixed_v(1 to signals_per_level(P, 7 ))(T_ADD_state_data_high(7) downto DATA_LOW);
      level8  : ufixed_v(1 to signals_per_level(P, 8 ))(T_ADD_state_data_high(8) downto DATA_LOW);
      level9  : ufixed_v(1 to signals_per_level(P, 9 ))(T_ADD_state_data_high(9) downto DATA_LOW);
      level10 : ufixed_v(1 to signals_per_level(P, 10))(T_ADD_state_data_high(10)downto DATA_LOW);
      level11 : ufixed_v(1 to signals_per_level(P, 11))(T_ADD_state_data_high(11)downto DATA_LOW);
   end record;
   
-- in Vivado and ModelSim
   -- this constant is used because even driving only one member of a structure implies driving the
   -- whole structure. So with resolved signals the analysis takes places without problems and the
   -- subsequent synthesis generates the desired structure.
   constant ADD_Z : T_ADD_state:=(level0  => (others=>(others=>'Z')),
                                  level1  => (others=>(others=>'Z')),
                                  level2  => (others=>(others=>'Z')),
                                  level3  => (others=>(others=>'Z')),
                                  level4  => (others=>(others=>'Z')),
                                  level5  => (others=>(others=>'Z')),
                                  level6  => (others=>(others=>'Z')),
                                  level7  => (others=>(others=>'Z')),
                                  level8  => (others=>(others=>'Z')),
                                  level9  => (others=>(others=>'Z')),
                                  level10 => (others=>(others=>'Z')),
                                  level11 => (others=>(others=>'Z')));
   -- ADD_in stores the signals entering the levels of the adder tree
   -- ADD_out stores the signals leaving
   signal ADD_in  : T_ADD_state := ADD_Z;
   signal ADD_out : T_ADD_state := ADD_Z;


/* functions to read and procedures to write from/to T_ADD_state                                  */
/**************************************************************************************************/

   function T_ADD_state_read(
         state : T_ADD_state;
         level : natural)
   return ufixed_v is
   begin
      case level is
         when 0      => return state.level0;
         when 1      => return state.level1;
         when 2      => return state.level2;
         when 3      => return state.level3;
         when 4      => return state.level4;
         when 5      => return state.level5;
         when 6      => return state.level6;
         when 7      => return state.level7;
         when 8      => return state.level8;
         when 9      => return state.level9;
         when 10     => return state.level10;
         when others => return state.level11;
      end case;
   end function;

   function T_ADD_state_read(
         state          : T_ADD_state;
         level          : natural;
         signal_number  : integer)
   return u_ufixed is
   begin
      case level is
         when 0      => return state.level0(signal_number);
         when 1      => return state.level1(signal_number);
         when 2      => return state.level2(signal_number);
         when 3      => return state.level3(signal_number);
         when 4      => return state.level4(signal_number);
         when 5      => return state.level5(signal_number);
         when 6      => return state.level6(signal_number);
         when 7      => return state.level7(signal_number);
         when 8      => return state.level8(signal_number);
         when 9      => return state.level9(signal_number);
         when 10     => return state.level10(signal_number);
         when others => return state.level11(signal_number);
      end case;
   end function;

   procedure T_ADD_state_write(
         signal   state     : inout T_ADD_state;
         constant level     : in    natural;
         constant new_value : in    ufixed_v) is
   begin
      --for loop introduced because of obscure error in Active-HDL:
      --Error DAGGEN_0700: Fatal error : INTERNAL CODE GENERATOR ERROR
      for i in new_value'range loop
         case level is
            when 0      => state.level0(i)  <= new_value(i);
            when 1      => state.level1(i)  <= new_value(i);
            when 2      => state.level2(i)  <= new_value(i);
            when 3      => state.level3(i)  <= new_value(i);
            when 4      => state.level4(i)  <= new_value(i);
            when 5      => state.level5(i)  <= new_value(i);
            when 6      => state.level6(i)  <= new_value(i);
            when 7      => state.level7(i)  <= new_value(i);
            when 8      => state.level8(i)  <= new_value(i);
            when 9      => state.level9(i)  <= new_value(i);
            when 10     => state.level10(i) <= new_value(i);
            when others => state.level11(i) <= new_value(i);
         end case;
      end loop;
   end procedure;

   procedure T_ADD_state_write(
         signal   state         : inout T_ADD_state;
         constant level         : in    natural;
         constant signal_number : in    integer;
         constant new_value     : in    ufixed) is
   begin
      case level is
         when 0      => state.level0(signal_number)  <= new_value;
         when 1      => state.level1(signal_number)  <= new_value;
         when 2      => state.level2(signal_number)  <= new_value;
         when 3      => state.level3(signal_number)  <= new_value;
         when 4      => state.level4(signal_number)  <= new_value;
         when 5      => state.level5(signal_number)  <= new_value;
         when 6      => state.level6(signal_number)  <= new_value;
         when 7      => state.level7(signal_number)  <= new_value;
         when 8      => state.level8(signal_number)  <= new_value;
         when 9      => state.level9(signal_number)  <= new_value;
         when 10     => state.level10(signal_number) <= new_value;
         when others => state.level11(signal_number) <= new_value;
      end case;
   end procedure;

   procedure T_ADD_state_copy(
         signal   from_state : in    T_ADD_state;
         signal   to_state   : inout T_ADD_state;
         constant level      : in    natural) is
   begin
      case level is
         when 0      => to_state.level0  <= from_state.level0;
         when 1      => to_state.level1  <= from_state.level1;
         when 2      => to_state.level2  <= from_state.level2;
         when 3      => to_state.level3  <= from_state.level3;
         when 4      => to_state.level4  <= from_state.level4;
         when 5      => to_state.level5  <= from_state.level5;
         when 6      => to_state.level6  <= from_state.level6;
         when 7      => to_state.level7  <= from_state.level7;
         when 8      => to_state.level8  <= from_state.level8;
         when 9      => to_state.level9  <= from_state.level9;
         when 10     => to_state.level10 <= from_state.level10;
         when others => to_state.level11 <= from_state.level11;
      end case;
   end procedure;


/*================================================================================================*/
/*================================================================================================*/

begin

   msg_debug("adder_core_s : OUTPUT_HIGH: " & image(OUTPUT_HIGH));
   msg_debug("adder_core_s : OUTPUT_LOW: " & image(OUTPUT_LOW));
   msg_debug("adder_core_s : DATA_HIGH: " & image(DATA_HIGH));
   msg_debug("adder_core_s : DATA_LOW: " & image(DATA_LOW));
   msg_debug("adder_core_s : MAX_POSSIBLE_BIT_opt: " & image(MAX_POSSIBLE_BIT_opt));
   msg_debug("adder_core_s : MAX_POSSIBLE_BIT: " & image(MAX_POSSIBLE_BIT));


/* Introduction of the input to the ADD structure, and extraction of the signal inter from it     */
/**************************************************************************************************/

   generate_input_resolved_signal:
   for i in 1 to P generate
      begin
         input_resolved(i) <= input(i);
      end;
   end generate;
   T_ADD_state_write(ADD_in, 0, input_resolved);
   inter <= T_ADD_state_read(ADD_out, ADD_LEVELS-1, 1);


/* Generation and management of the control signals                                               */
/**************************************************************************************************/

   generate_start_control:
   if ADD_PIPELINES>0 generate
      begin
         start_delayed <= start_sh(ADD_PIPELINES);

         process (clk) is
         begin
            if rising_edge(clk) then
               start_sh(1) <= start;
               if ADD_PIPELINES>1 then
                  start_sh(2 to ADD_PIPELINES) <= start_sh(1 to ADD_PIPELINES-1);
               end if;
            end if;
         end process;

      end;
   else generate
      begin
         start_delayed <= start;
      end;
   end generate;


   generate_valid_input_control:
   if DATA_IMM_AFTER_START=false generate
      begin

         when_ADD_PIPELINES_is_0:
         if ADD_PIPELINES=0 generate
            begin
               valid_input_delayed<= valid_input;
            end;
         else generate
            begin
               valid_input_delayed <= valid_input_sh(ADD_PIPELINES);

               process (clk) is
               begin
                  if rising_edge(clk) then
                     valid_input_sh(1) <= valid_input;
                     if ADD_PIPELINES>1 then
                        valid_input_sh(2 to ADD_PIPELINES) <= valid_input_sh(1 to ADD_PIPELINES-1);
                     end if;
                  end if;
               end process;

            end;
         end generate;

      end;
   end generate;


   when_ACC_PIPELINES_greater_than_0:
   if S>1 generate
      begin

         generate_counter:
         if DATA_IMM_AFTER_START generate
               signal aux   : std_ulogic;
               signal count : std_ulogic_vector(counter_CW(true, --UNSIGNED_2COMP_opt,
                                                           0, --COUNTER_WIDTH_dep,
                                                           true, --TARGET_MODE,
                                                           ACC_PIPELINES, --TARGET_dep,
                                                           true, --TARGET_WITH_COUNT_opt = t_true,
                                                           true, --USE_SET,
                                                           1) --SET_TO_dep)
                                                downto 1);
            begin
               aux <= unsigned(count) ?/= 0;

               counter:
               entity work.counter
                  generic map(
                     UNSIGNED_2COMP_opt     => true,
                     OVERFLOW_BEHAVIOR_opt  => t_wrap,
                     --COUNT_MODE_opt         => t_up,
                     --COUNTER_WIDTH_dep      => ,
                     TARGET_MODE            => true,
                     TARGET_dep             => ACC_PIPELINES,
                     TARGET_WITH_COUNT_opt  => t_true,
                     TARGET_BLOCKING_opt    => t_false,
                     USE_SET                => true,
                     SET_TO_dep             => 1,
                     USE_RESET              => true,
                     SET_RESET_PRIORITY_opt => t_set,
                     USE_LOAD               => false
                  )
                  port map(
                     clk                  => clk,
                     enable               => aux,
                     set                  => start_delayed,
                     reset                => counter_out,
                     --load                 => ,
                     --count_mode_signal    => ,
                     --value_to_load        => ,
                     count                => count,
                     count_is_TARGET(1)   => counter_out
                  );

            end;
         else generate
               signal count : std_ulogic_vector(counter_CW(true, --UNSIGNED_2COMP_opt,
                                                           0, --COUNTER_WIDTH_dep,
                                                           true, --TARGET_MODE,
                                                           ACC_PIPELINES, --TARGET_dep,
                                                           false, --TARGET_WITH_COUNT_opt = t_true,
                                                           true, --USE_SET,
                                                           1) --SET_TO_dep)
                                                downto 1);
            begin

               counter:
               entity work.counter
                  generic map(
                     UNSIGNED_2COMP_opt     => true,
                     OVERFLOW_BEHAVIOR_opt  => t_saturate,
                     --COUNT_MODE_opt         => t_up,
                     --COUNTER_WIDTH_dep      => ,
                     TARGET_MODE            => true,
                     TARGET_dep             => ACC_PIPELINES,
                     TARGET_WITH_COUNT_opt  => t_false,
                     TARGET_BLOCKING_opt    => t_true,
                     USE_SET                => true,
                     SET_TO_dep             => 1,
                     USE_RESET              => true,
                     SET_RESET_PRIORITY_opt => t_set,
                     USE_LOAD               => false
                  )
                  port map(
                     clk                  => clk,
                     enable               => valid_input_delayed,
                     set                  => start_delayed,
                     reset                => counter_out and valid_input_delayed,
                     --load                 => ,
                     --count_mode_signal    => ,
                     --value_to_load        => ,
                     count                => count, --not used
                     count_is_TARGET(1)   => counter_out
                  );

            end;
         end generate;

      end;
   elsif DATA_IMM_AFTER_START generate
      begin
         counter_out <= start_delayed;
      end;
   else generate
      begin
         counter_out <= valid_input_delayed;
      end;
   end generate;


   generate_valid_output:
   if OUTPUT_BUFFER generate
      begin

         process (clk) is
         begin
            if rising_edge(clk) then
               if DATA_IMM_AFTER_START then
                  valid_output <= counter_out;
               else
                  valid_output <= counter_out and valid_input_delayed;
               end if;
            end if;
         end process;

      end;
   elsif DATA_IMM_AFTER_START generate
      begin
         valid_output <= counter_out;
      end;
   else generate
      begin
         valid_output <= counter_out and valid_input_delayed;
      end;
   end generate;


/* Generation of the adder tree                                                                   */
/**************************************************************************************************/

   generate_ADD_PIPELINES:
   for level in 0 to ADD_LEVELS-1 generate
      begin

         except_in_first_level:
         if level > 0 generate
            begin

               when_more_than_two_signals:
               if signals_per_level(P, level-1) > 1 generate
                  begin

                     add_pairs:
                     for i in 1 to integer(floor(real(signals_per_level(P, level-1))/2.0)) generate
                        begin
                           T_ADD_state_write(ADD_in,
                                             level,
                                             i,
                                             resize(T_ADD_state_read(ADD_out,
                                                                     level-1,
                                                                     2*i-1)
                                                    +
                                                    T_ADD_state_read(ADD_out,
                                                                     level-1,
                                                                     2*i),
                                                    minimum(DATA_HIGH+level,
                                                            MAX_POSSIBLE_BIT),
                                                    DATA_LOW));
                        end;
                     end generate;

                  end;
               end generate;

               transport_last_signal_when_odd_number_of_signals:
               if (signals_per_level(P, level-1) mod 2)=1 generate
                  begin
                     T_ADD_state_write(ADD_in,
                                       level,
                                       signals_per_level(P, level),
                                       resize(T_ADD_state_read(ADD_out,
                                                     level-1,
                                                     signals_per_level(P, level-1)),
                                              minimum(DATA_HIGH+level,
                                                      MAX_POSSIBLE_BIT),
                                              DATA_LOW));
                  end;
               end generate;

            end;
         end generate;

         generate_pipelines_or_connect_cables:
         if IS_PIPELINED(level+1) generate
            begin

               process (clk) is
               begin
                  if rising_edge(clk) then
                     T_ADD_state_copy(from_state=>ADD_in, to_state=>ADD_out, level=>level);
                  end if;
               end process;

            end;
         else generate
            begin
               T_ADD_state_copy(from_state=>ADD_in, to_state=>ADD_out, level=>level);
            end;
         end generate;

      end;
   end generate;


/* Generation of the accumulator                                                                  */
/**************************************************************************************************/

   generate_accumulator:
   if S>1 generate
         signal previous_output_inter : u_ufixed(output_inter'range);
         signal inter_resized         : u_ufixed(output_inter'range);
         signal addition              : u_ufixed(output_inter'range);
         signal selector              : std_ulogic;
      begin

         inter_resized <= resize(inter, output_inter);
         addition      <= resize(previous_output_inter + inter_resized, addition);
         output_inter  <= addition      when selector='0' else
                          inter_resized when selector='1' else
                          (others => 'X');
         selector      <= start_delayed;

         process (clk) is
         begin
            if rising_edge(clk) then
               if DATA_IMM_AFTER_START=false then
                  if valid_input_delayed = '1' then
                     previous_output_inter <= output_inter;
                  end if;
               else
                  previous_output_inter <= output_inter;
               end if;
            end if;
         end process;

      end;
   else generate
      begin
         output_inter <= inter;
      end;
   end generate;


/* Generation of the output pipeline                                                              */
/**************************************************************************************************/

   generate_output_pipeline:
   if OUTPUT_BUFFER generate
      begin

         process (clk)
         begin
            if rising_edge(clk) then
               if OUTPUT_LOW<DATA_LOW then
                  output <= resize(output_inter, OUTPUT_HIGH, OUTPUT_LOW);
               else
                  output <= (OUTPUT_HIGH downto OUTPUT_LOW => 
                                    output_inter(OUTPUT_HIGH downto OUTPUT_LOW));
               end if;
            end if;
         end process;

      end;
   else generate
      begin

         generate_no_output_pipeline:
         if OUTPUT_LOW<DATA_LOW generate
            begin
               output <= resize(output_inter, OUTPUT_HIGH, OUTPUT_LOW);
            end;
         else generate
            begin
               output <= (OUTPUT_HIGH downto OUTPUT_LOW => 
                                 output_inter(OUTPUT_HIGH downto OUTPUT_LOW));
            end;
         end generate;

      end;
   end generate;


end architecture;
