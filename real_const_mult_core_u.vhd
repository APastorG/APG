/***************************************************************************************************
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
/  Xilinx's Vivado
/     3 space tabs are used throughout the document
/
/  Description:
/  ¯¯¯¯¯¯¯¯¯¯¯
/     This design of a parameterized real constant multiplier implements the multiplierless multiple
/  constants multiplier by Voronenko-Püschel.
/     The input signal is multiplied by the multiplicands and the result is sent to the output on
/  each clk cycle.
/
 **************************************************************************************************/

library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;
   use ieee.math_real.all;
   use std.textio.all;

library work;
   use work.common_data_types_pkg.all;
   use work.common_pkg.all;
   use work.fixed_float_types.all;
   use work.fixed_generic_pkg.all;
   use work.real_const_mult_pkg.all;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

entity real_const_mult_core_u is

   generic(
      SPEED_opt         : T_speed       := t_exc;          --exception: value not set
      ROUND_STYLE_opt   : T_round_style := fixed_truncate; --default
      ROUND_TO_BIT_opt  : integer_exc   := integer'low;    --exception: value not set
      MAX_ERROR_PCT_opt : real_exc      := real'low;       --exception: value not set
      CONSTANTS         : real_v;                          --compulsory
      input_high        : integer;
      input_low         : integer
    );

   port(
      input        : in  u_ufixed;
      clk          : in  std_ulogic;
      valid_input  : in  std_ulogic;

      output       : out u_ufixed_v(1 to CONSTANTS'length)
                               (real_const_mult_OH(ROUND_STYLE_opt,
                                                   ROUND_TO_BIT_opt,
                                                   MAX_ERROR_PCT_opt,
                                                   CONSTANTS,
                                                   input_high,
                                                   input_low,
                                                   is_signed => false)
                                downto
                                real_const_mult_OL(ROUND_STYLE_opt,
                                                   ROUND_TO_BIT_opt,
                                                   MAX_ERROR_PCT_opt,
                                                   CONSTANTS,
                                                   input_low,
                                                   is_signed => false)
                                );
      valid_output : out std_ulogic
   );

end entity;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

architecture real_const_mult_core_u_1 of real_const_mult_core_u is

   /* corrected generics and internal/external ports' signals                                     */
   /***********************************************************************************************/

   constant CHECKS : integer := real_const_mult_CHECKS(input_high,
                                                       input_low,
                                                       false, --unsigned_2comp_opt
                                                       ROUND_TO_BIT_opt,
                                                       MAX_ERROR_PCT_opt,
                                                       CONSTANTS);

   /* constants for the calculation of port sizes                                                 */
   /***********************************************************************************************/
   --the common output size
   constant OUT_HIGH  : integer := real_const_mult_OH(ROUND_STYLE_opt,
                                                      ROUND_TO_BIT_opt,
                                                      MAX_ERROR_PCT_opt,
                                                      CONSTANTS,
                                                      input_high,
                                                      input_low,
                                                      is_signed => false);
   constant OUT_LOW   : integer := real_const_mult_OL(ROUND_STYLE_opt,
                                                      ROUND_TO_BIT_opt,
                                                      MAX_ERROR_PCT_opt,
                                                      CONSTANTS,
                                                      input_low,
                                                      is_signed => false);


   /* constants related to the multiplicands                                                      */
   /***********************************************************************************************/
   --vector to preserve the sign of each constant
   constant MULT_SIGN_POSITIVE : boolean_v  := is_positive_vector_from_constants(CONSTANTS);
   --vector with the values of the constants in fixed point (applying parameters of error percentage, 
   --round style and bit to which to round)
   constant NO_NEGATIONS       : boolean    := all_positive(MULT_SIGN_POSITIVE);
   constant MULT_FIXED         : u_ufixed_v := fixed_from_real_constants(ROUND_STYLE_opt,
                                                                         ROUND_TO_BIT_opt,
                                                                         MAX_ERROR_PCT_opt,
                                                                         abs(CONSTANTS),
                                                                         input_high,
                                                                         input_low,
                                                                         is_signed => false);
   --vector with the left shift needed(possibly negative) to transform the constants to odd natural values
   constant PRE_VP_SHIFT       : integer_v  := calculate_pre_vp_shift(MULT_FIXED);
   --maximum left shift needed
   constant MAX_PRE_VP_SHIFT   : integer    := maximum(PRE_VP_SHIFT);
   --vector with the constants in positive odd form, ready for the Voronenko-Püschel algorithm
   constant MULT_FUNDAMENTAL   : positive_v := calculate_mult_fundamental(MULT_FIXED, PRE_VP_SHIFT);

   constant INTER_LOW          : integer    := input_low - MAX_PRE_VP_SHIFT;


   /* file constants                                                                              */
   /***********************************************************************************************/

   constant FILE_NAME : string := generate_file_name(ROUND_STYLE_opt,
                                                     ROUND_TO_BIT_opt,
                                                     MAX_ERROR_PCT_opt,
                                                     MULT_FUNDAMENTAL);

   constant FILE_PATH : string := DATA_FILE_DIRECTORY & "\" /*"*/ & FILE_NAME; --comment inserted to prevent nonsense syntax highlighting on sublime text 3

   file solution_input : text;


   /* constants obtained from files                                                               */
   /***********************************************************************************************/
   --carries out the Voronenko_Püschel algorithm and saves the solution to a file
   procedure generate_solutions_file
   is
      --pragma translate off
      --synthesis translate_off
      package mmcm is new work.mmcm_pkg
         generic map(
            MAX_TARGET => maximum(MULT_FUNDAMENTAL),
            FILE_PATH  => FILE_PATH
         );
      --pragma translate on
      --synthesis translate_on
   begin
      --pragma translate off
      --synthesis translate_off
      mmcm.VorPus(MULT_FUNDAMENTAL);
      --pragma translate on
      --synthesis translate_on
   end procedure;

   --reads the number of vertexes in the solution that is in the file. Additionally, as it is the first
   --function that is called in the module, the file with the solutions is also generated, or produces
   --an error if the file doesn't exist and we are in synthesis trying to read it
   impure function read_number_of_vertexes
   return natural is
      variable currentline : line;
      variable currentchar : character;
      variable solution    : natural := 0;
      variable exists      : file_open_status;
   begin
      --pragma translate off
      --synthesis translate_off
      file_open(solution_input, FILE_PATH, WRITE_MODE);
      file_close(solution_input);
      generate_solutions_file;
      --pragma translate on
      --synthesis translate_on
      file_open(solution_input, FILE_PATH, READ_MODE);
      if endfile(solution_input) then
         assert false
            report "The values needed to generate multiplication/divisions have not yet been " &
            "generated. It is first required to launch the simulation in order to achieve this"
            severity error;
      end if;
      if not endfile(solution_input) then
         readline(solution_input, currentline);
         for i in 1 to currentline'length loop
            read(currentline, currentchar);
            solution := 10*solution + (character'pos(currentchar)-character'pos('0'));
         end loop;
      end if;
      file_close(solution_input);
      return solution;
   end function;

   constant NUMBER_OF_VERTEXES : natural := read_number_of_vertexes;

   type T_solutions is record 
      fundamental      : positive;
      u                : positive;
      l1               : natural;
      v                : positive;
      l2               : natural;
      s                : boolean;     --true: v is positive, false: v is negative
      is_target        : boolean;
      flevel           : natural;
      max_child_flevel : natural;
      high             : integer;
   end record;

   type T_solutions_v is array(natural range <>) of T_solutions;

   procedure insert(
      vector : inout T_solutions_v;
      index  : in positive;
      member : in natural;
      value  : in natural)
   is
   begin
      case member is
         when 0 => vector(index).fundamental := value;
         when 1 => vector(index).u := value;
         when 2 => vector(index).l1 := value;
         when 3 => vector(index).v := value;
         when 4 => vector(index).l2 := value;
         when others => vector(index).s := ite(value=1, true, false);
      end case;
   end procedure;

   function contains(
      vector : positive_v;
      number : positive)
   return boolean is
   begin
      for i in vector'range loop
         if vector(i) = number then
            return true;
         end if;
      end loop;
      return false;
   end function;

   function index_from_fund(
      vertexes : T_solutions_v;
      fund     : positive)
   return natural is
      variable result : natural := 0;
   begin
      for1:
      for i in 1 to NUMBER_OF_VERTEXES loop
         if vertexes(i).fundamental = fund then
            return i;
         end if;
      end loop;
      return result;
   end function;

   function calculate_max_flevel(
      vertexes : T_solutions_v)
   return natural is
      variable vertex : T_solutions_v(vertexes'range) := vertexes;
      variable max_f : natural := 0;
      variable aux : natural;
   begin
      --calculate max_flevel
      if NUMBER_OF_VERTEXES > 0 then
         vertex(1).flevel := 0;
      end if;
      if NUMBER_OF_VERTEXES > 1 then
         for i in 2 to NUMBER_OF_VERTEXES loop
            aux := 1 + maximum(vertex(index_from_fund(vertexes, vertexes(i).u)).flevel,
                               vertex(index_from_fund(vertexes, vertexes(i).v)).flevel);
            vertex(i).flevel := aux;
            max_f := maximum(max_f, aux);
         end loop;
      end if;
      return max_f;
   end function;

   procedure populate_vertexes(
      vertexes   : inout T_solutions_v;
      max_flevel : in natural)
   is
      variable aux : natural;
      variable lowest_child_flevel : natural_v(1 to NUMBER_OF_VERTEXES) := (others => natural'high);
   begin
      if NUMBER_OF_VERTEXES>0 then
         vertexes(1).flevel := 0;
         vertexes(1).high   := OUT_LOW + input_high - input_low;
      end if;
      if NUMBER_OF_VERTEXES>1 then
         --generate high values for all fundamentals but the first
         for i in 2 to NUMBER_OF_VERTEXES loop
            vertexes(i).high := calculate_high(vertexes(i).fundamental,
                                               vertexes(1).high,
                                               is_signed => false);
         end loop;
         --assign values of flevel for all fundamentals' parents but the first
         for i in 2 to NUMBER_OF_VERTEXES loop
            aux := 1 + maximum(vertexes(index_from_fund(vertexes, vertexes(i).u)).flevel,
                               vertexes(index_from_fund(vertexes, vertexes(i).v)).flevel);
            vertexes(i).flevel := aux;
         end loop;
         --increase the flevel value of each fundamental to the highest possible(so as to delay the
         --operations the most and reduce the registers used in the pipelining)
         for j in 1 to NUMBER_OF_VERTEXES loop
            --update the lowest flevel of the children for each vertex
            for i in 2 to NUMBER_OF_VERTEXES loop
               aux := index_from_fund(vertexes, vertexes(i).u);
               lowest_child_flevel(aux) := minimum(lowest_child_flevel(aux), vertexes(i).flevel);
               aux := index_from_fund(vertexes, vertexes(i).v);
               lowest_child_flevel(aux) := minimum(lowest_child_flevel(aux), vertexes(i).flevel);
            end loop;
            --then increase the flevel when possible
            for i in NUMBER_OF_VERTEXES downto 2 loop
               if lowest_child_flevel(i) = natural'high then
                  vertexes(i).flevel := max_flevel;
               else
                  vertexes(i).flevel := lowest_child_flevel(i) - 1;
               end if;
            end loop;
         end loop;
         --assign values to max_child_flevel for all fundamentals
         for i in 2 to NUMBER_OF_VERTEXES loop
            aux := index_from_fund(vertexes, vertexes(i).u);
            vertexes(aux).max_child_flevel := maximum(vertexes(aux).max_child_flevel, vertexes(i).flevel);
            aux := index_from_fund(vertexes, vertexes(i).v);
            vertexes(aux).max_child_flevel := maximum(vertexes(aux).max_child_flevel, vertexes(i).flevel);
         end loop;
         --if the fundamental is a target increase the max_child_flevel to max_flevel
         for i in 1 to NUMBER_OF_VERTEXES loop
            if vertexes(i).is_target then
               vertexes(i).max_child_flevel := max_flevel + 1;
            end if;
         end loop;
      end if;
   end procedure;

   --reads the solution vertexes and returns a static structure with the data
   impure function read_vertexes
   return T_solutions_v is
      variable result : T_solutions_v(1 to NUMBER_OF_VERTEXES);
      variable currentline : line;
      variable currentchar : character;
      variable aux : natural := 0;
      variable member : natural := 0;
      variable max_f : natural;
   begin
      file_open(solution_input, FILE_PATH, READ_MODE);
      if not endfile(solution_input) then
         readline(solution_input, currentline);--discard first line
         if not endfile(solution_input) then
            for i in 1 to NUMBER_OF_VERTEXES loop
               readline(solution_input, currentline);
               member := 0;
               for j in 1 to currentline'length loop
                  read(currentline, currentchar);
                  if currentchar = ' ' then
                     insert(result, i, member, aux);
                     aux := 0;
                     member := member + 1;
                  else
                     aux := 10*aux + (character'pos(currentchar)-character'pos('0'));
                  end if;
               end loop;
               --add the last read member
               insert(result, i, member, aux);
               --add whether the actual fundamental is a target (which is not read from the file)
               result(i).is_target := contains(MULT_FUNDAMENTAL, result(i).fundamental);
               aux := 0;
            end loop;
         end if;
      end if;
      file_close(solution_input);
      max_f := calculate_max_flevel(result);
      populate_vertexes(result, max_f);
      return result;
   end function;

   constant VERTEXES : T_solutions_v(1 to NUMBER_OF_VERTEXES) := read_vertexes;

   --same as before but referred directly to the constant VERTEXES
   function index_from_fund(
      fund : positive)
   return natural is
   begin
      for1:
      for i in 1 to NUMBER_OF_VERTEXES loop
         if VERTEXES(i).fundamental = fund then
            return i;
         end if;
      end loop;
      return 0;   --when not found return 0
   end function;

   constant MAX_FLEVEL : natural := calculate_max_flevel(VERTEXES);


   /* constants related to pipelines                                                              */
   /***********************************************************************************************/
   --number of possible positions to place pipelines
   constant PIPELINE_POSITIONS : natural := MAX_FLEVEL + 1;
   --boolean vector which indicates whether a pipeline is placed or not on each possible position
   constant IS_PIPELINED : boolean_v(0 to PIPELINE_POSITIONS-1) := generate_pipelines(PIPELINE_POSITIONS,
                                                                                      SPEED_opt);
   --number of pipelines
   constant PIPELINES    : natural := number_of_pipelines(PIPELINE_POSITIONS,
                                                          SPEED_opt);

   /* signals                                                                                     */
   /***********************************************************************************************/
   signal fundamental_signals : u_ufixed_vv(1 to NUMBER_OF_VERTEXES)(0 to MAX_FLEVEL)(OUT_HIGH downto INTER_LOW);

   signal valid_input_sh : std_ulogic_vector(1 to PIPELINES);

   signal pre_output     : u_ufixed_v(1 to MULT_FUNDAMENTAL'length)(OUT_HIGH downto OUT_LOW);

/*================================================================================================*/
/*================================================================================================*/

begin

   generate_valid_output:
   if PIPELINES > 0 generate
      begin
         valid_output <= valid_input_sh(PIPELINES);
         process(clk) is
         begin
            if rising_edge(clk) then
               valid_input_sh <= valid_input_sh srl 1;
               valid_input_sh(1) <= valid_input;
            end if;
         end process;
      end;
   else generate
      begin
         valid_output <= valid_input;
      end;
   end generate;


   msg_debug("real_const_mult_core_u FILE_PATH: " & string'(FILE_PATH));
   msg_debug("real_const_mult_core_u NUMBER_OF_VERTEXES: " & image(NUMBER_OF_VERTEXES));
   msg_debug("real_const_mult_core_u OUT_HIGH: " & image(OUT_HIGH));
   msg_debug("real_const_mult_core_u OUT_LOW: " & image(OUT_LOW));
   generate_each_constant:
   for i in 1 to CONSTANTS'length generate
   begin
      msg_debug("real_const_mult_core_u CONSTANTS(" & image(i) & "): " & image(CONSTANTS(i)));
      msg_debug("real_const_mult_core_u MULT_FUNDAMENTAL(" & image(i) & "): " & image(MULT_FUNDAMENTAL(i)));
      msg_debug("real_const_mult_core_u PRE_VP_SHIFT(" & image(i) & "): " & image(PRE_VP_SHIFT(i)));
   end generate;


   pipeline_or_connection_of_input:
   if IS_PIPELINED(0) generate
      begin
         process(clk) is
         begin
            if rising_edge(clk) then
               fundamental_signals(1)(0)(VERTEXES(1).high downto OUT_LOW) <= input;
            end if;
         end process;
      end;
   else generate
      fundamental_signals(1)(0)(VERTEXES(1).high downto OUT_LOW) <= input;
   end generate;

   if_max_child_of_input_is_higher_than_1:
   if VERTEXES(1).max_child_flevel > 1 generate
      generate_pipelines_fundamental_for_1_for_each_flevel:
      for j in 1 to VERTEXES(1).max_child_flevel - 1 generate
            constant high : integer := VERTEXES(1).high;
         begin
            pipeline_or_connection:
            if IS_PIPELINED(j) generate
               begin
                  process(clk) is
                  begin
                     if rising_edge(clk) then
                        fundamental_signals(1)(j)(high downto OUT_LOW) 
                           <= fundamental_signals(1)(j-1)(high downto OUT_LOW);
                     end if;
                  end process;
               end;
            else generate
               fundamental_signals(1)(j)(high downto OUT_LOW)
                  <= fundamental_signals(1)(j-1)(high downto OUT_LOW);
            end generate;
         end;
      end generate;
   end generate;

   generate_pipelines_for_other_fundamentals:
   for i in 2 to NUMBER_OF_VERTEXES generate
         constant first : natural := VERTEXES(i).flevel;
         constant last  : natural := VERTEXES(i).max_child_flevel - 1;
         constant high  : integer := vertexes(i).high;
      begin
         if_last_greater_than_first:
         if last > first generate
            for_each_flevel:
            for j in first+1 to last generate
               pipeline_or_connection:
               if IS_PIPELINED(j) generate
                  begin
                     process(clk) is
                     begin
                        if rising_edge(clk) then
                           fundamental_signals(i)(j)(high downto OUT_LOW)
                           <= fundamental_signals(i)(j-1)(high downto OUT_LOW);
                        end if;
                     end process;
                  end;
               else generate
                  fundamental_signals(i)(j)(high downto OUT_LOW)
                  <= fundamental_signals(i)(j-1)(high downto OUT_LOW);
               end generate;
            end generate;
         end generate;
      end;
   end generate;


   generate_fundamental_signals:
   for i in 2 to NUMBER_OF_VERTEXES generate
         constant current : T_solutions := VERTEXES(i);
         constant u      : positive := current.u;
         constant l1     : natural  := current.l1;
         constant v      : positive := current.v;
         constant l2     : natural  := current.l2;
         constant s      : boolean  := current.s;
         constant flevel : natural  := current.flevel;
         constant high   : integer  := current.high;
         constant u_high : integer := vertexes(index_from_fund(u)).high;
         constant v_high : integer := vertexes(index_from_fund(v)).high;
         signal signal1  : u_ufixed(u_high downto OUT_LOW);
         signal signal2  : u_ufixed(v_high downto OUT_LOW);
         signal signal3  : u_ufixed(u_high+1 downto OUT_LOW);
         signal aux1     : u_ufixed(high downto OUT_LOW);
         signal aux2     : u_ufixed(high downto OUT_LOW);
         signal aux3     : u_ufixed(high+1 downto OUT_LOW);
         signal result1  : u_ufixed(high downto OUT_LOW);
         signal result2  : u_ufixed(high+1 downto OUT_LOW);
      begin
         signal1 <= fundamental_signals(index_from_fund(u))(flevel-1)(u_high downto OUT_LOW);
         signal2 <= fundamental_signals(index_from_fund(v))(flevel-1)(v_high downto OUT_LOW);
         signal3 <= resize(fundamental_signals(index_from_fund(u))(flevel-1)(u_high downto OUT_LOW), signal3);
         aux1    <= resize(signal1, aux1) sll l1;
         aux2    <= resize(signal2, aux2) sll l2;
         aux3    <= resize(signal3, aux3) sll l1;
         result1 <= resize(aux1 + aux2, result1);
         result2 <= resize(aux3 - resize(aux2, aux3), result2);
         pipeline_or_connection:
         if IS_PIPELINED(flevel) generate
            begin
               process(clk) is
               begin
                  if rising_edge(clk) then
                     fundamental_signals(i)(flevel)(high downto OUT_LOW)
                             <= result1(high downto OUT_LOW) when s else
                                result2(high downto OUT_LOW);
                  end if;
               end process;
            end;
         else generate
            begin
               positive_or_negative:
               if s generate
                  fundamental_signals(i)(flevel)(high downto OUT_LOW)
                          <= result1(high downto OUT_LOW);
               else generate
                  fundamental_signals(i)(flevel)(high downto OUT_LOW)
                          <= result2(high downto OUT_LOW);
               end generate;
            end;
         end generate;
      end;
   end generate;


   invert_output:
   for i in 1 to CONSTANTS'length generate
         constant index   : integer := index_from_fund(MULT_FUNDAMENTAL(i));
         constant high    : integer := VERTEXES(index).high;
         signal   aux     : u_ufixed(high downto OUT_LOW);
         signal   result1 : u_ufixed(high downto OUT_LOW);
      begin
         aux <= fundamental_signals(index)(MAX_FLEVEL)(high downto OUT_LOW);
         result1 <= resize(aux, result1);
         pre_output(i)(result1'range) <= result1;
      end;
   end generate;

   generate_output_shifts:
   for i in 1 to CONSTANTS'length generate
         constant index : integer := index_from_fund(MULT_FUNDAMENTAL(i));
         constant high  : integer := VERTEXES(index).high;
         constant adjustment : integer := -PRE_VP_SHIFT(i) - (OUT_LOW - input_low);
      begin
         depending_on_adjustment_value:
         if adjustment > 0 generate
            output(i) <= resize(pre_output(i)(high downto OUT_LOW),
                                output(i))
                         sll
                         adjustment;
         else generate
            output(i) <= resize(pre_output(i)(high downto OUT_LOW),
                                output(i))
                         sra
                         abs(adjustment); --to introduce the leftmost bit when shifting to the right
         end generate;
      end;
   end generate;


end architecture;