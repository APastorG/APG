

   --pragma translate off
   --vhdl_comp_off
   /*
   --vhdl_comp_on
library aldec;
   use aldec.matlab.all;
   --vhdl_comp_off
   */
   --vhdl_comp_on
   --pragma translate on

library ieee;
   use ieee.std_logic_1164.all;
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
/*================================================================================================*/

entity permutation_core is

   generic (
      INPUT_INDEXES  : integer_v;
      OUTPUT_INDEXES : integer_v;
      INPUT_HIGH     : natural;
      INPUT_LOW      : natural
   );
   port(
      Clk          : in  std_ulogic;
      input        : in  sulv_v;
      start        : in  std_ulogic;

      output       : out sulv_v(INPUT_HIGH downto INPUT_LOW);
      finish       : out std_ulogic
   );

end entity;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

architecture permutation_core_1 of permutation_core is

   constant INPUT_LENGTH : positive := input'length;

   constant CHECKS     : boolean  := permutation_checks(INPUT_LENGTH,
                                                        INPUT_INDEXES,
                                                        OUTPUT_INDEXES);
   
   constant DIMENSIONS : positive := OUTPUT_INDEXES'length;

   constant PARALLEL_DIMENSIONS : natural := integer(log2(real(INPUT_LENGTH)));

   
   /* file constants                                                                              */
   /***********************************************************************************************/

   constant FILE_PATH_M : string := DATA_FILE_DIRECTORY_M & "\\" & generate_perm_file_name(PARALLEL_DIMENSIONS,
                                                                                           INPUT_INDEXES,
                                                                                           OUTPUT_INDEXES); --for Matlab
   constant FILE_PATH : string := DATA_FILE_DIRECTORY & "\"/*"*/ & generate_perm_file_name(PARALLEL_DIMENSIONS,
                                                                                           INPUT_INDEXES,
                                                                                           OUTPUT_INDEXES); 
   file solution_input : text;

   --pragma translate off
   --vhdl_comp_off
   /*
   --vhdl_comp_on
----------------------------------------------------------------------------------------------------
   function execute_Matlab_script
      return integer is
         variable in_indexes_id : integer := 0;
         variable out_indexes_id : integer := 0;
         variable size_i : TDims(1 to 1) := (1 => DIMENSIONS);
   begin
      ml_setup(desktop => false);
      --send data to Matlab: path name, number of parallel dimensions, input and output indexes
      put_variable("file_path", FILE_PATH_M);
      put_variable("p", PARALLEL_DIMENSIONS);
      out_indexes_id := create_array("Po", 1, size_i);
      for i in 1 to DIMENSIONS loop
         put_item (OUTPUT_INDEXES(i-1), out_indexes_id, (1 => i));
      end loop;
      hdl2ml(out_indexes_id);
      in_indexes_id := create_array("Pi", 1, size_i);
      for i in 1 to DIMENSIONS loop
         put_item (INPUT_INDEXES(i-1), in_indexes_id, (1 => i));
      end loop;
      hdl2ml(in_indexes_id);
      ml_start_dir(ACTIVE_HDL_PROJECT_PATH & "\src");
      eval_string("optPerm_interface");
      destroy_array(in_indexes_id);
      destroy_array(out_indexes_id);
      return 0;
   end function;

   constant DUMMY : integer := execute_Matlab_script;
----------------------------------------------------------------------------------------------------
   --vhdl_comp_off
   */
   --vhdl_comp_on
   --pragma translate on

   --reads the number of elemental bit-exchange opertations in the solution that is in the file.
   --Produces an error if the file doesn't exist and we are in synthesis trying to read it
   impure function read_elemental_ops
   return natural is
      variable currentline : line;
      variable currentchar : character;
      variable solution    : natural := 0;
   begin
      --read solution file
      file_open(solution_input, FILE_PATH, READ_MODE);
      if endfile(solution_input) then
         assert false
            report "The values needed to generate optimum permutations have not yet been " &
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

   constant ELEMENTAL_OPS : natural := read_elemental_ops;

   --reads the solution vertexes and returns a static structure with the data
   impure function read_optimal_perm
   return integer_vv is
      variable result : integer_vv(1 to ELEMENTAL_OPS)(1 to 2);
      variable currentline : line;
      variable currentchar : character;
      variable aux : natural := 0;
   begin
      file_open(solution_input, FILE_PATH, READ_MODE);
      if not endfile(solution_input) then
         readline(solution_input, currentline);--discard first line
         if not endfile(solution_input) then
            for i in 1 to ELEMENTAL_OPS loop
               readline(solution_input, currentline);
               for j in 1 to currentline'length loop
                  read(currentline, currentchar);
                  if currentchar = ' ' then
                     result(i)(1) := aux;
                     aux := 0;
                  else
                     aux := 10*aux + (character'pos(currentchar)-character'pos('0'));
                  end if;
               end loop;
               --add the last read member
               result(i)(2) := aux;
               aux := 0;
            end loop;
         end if;
      end if;
      file_close(solution_input);
      return result;
   end function;
   
   constant OPTIMAL_PERM : integer_vv(1 to ELEMENTAL_OPS)(1 to 2) := read_optimal_perm;


   /* signals                                                                                     */
   /***********************************************************************************************/

   signal inter : sulv_vv(0 to ELEMENTAL_OPS)(INPUT_LENGTH-1 downto 0)(input'element'length-1 downto 0);

   signal start_delayed : std_ulogic_vector(0 to ELEMENTAL_OPS);

/*================================================================================================*/
/*================================================================================================*/

begin

   check_if_permutations_are_needed:
   if ELEMENTAL_OPS > 0 generate
      begin
         --control part
         start_delayed(0) <= start;
         finish           <= start_delayed(ELEMENTAL_OPS);

         --signal part
         inter(0) <= input;
         output <= inter(ELEMENTAL_OPS);

         generate_elemental_operations:
         for i in 1 to ELEMENTAL_OPS generate
            begin
               parallel_parallel:
               if is_pp_perm(OPTIMAL_PERM(i), PARALLEL_DIMENSIONS) generate
                  begin
                     perm_pp:
                     entity work.perm_pp
                        generic map(
                           indexes => OPTIMAL_PERM(i)
                        )
                        port map(
                           input  => inter(i-1),
                           start  => start_delayed(i-1),
                           output => inter(i),
                           finish => start_delayed(i)
                        );
                  end;
               end generate;
               serial_parallel:
               if is_sp_perm(OPTIMAL_PERM(i), PARALLEL_DIMENSIONS) generate
                     constant aux_left  : natural := contiguous_ps_latency(OPTIMAL_PERM,
                                                                           PARALLEL_DIMENSIONS,
                                                                           i,
                                                                           left => true);
                     constant aux_right : natural := contiguous_ps_latency(OPTIMAL_PERM,
                                                                           PARALLEL_DIMENSIONS,
                                                                           i,
                                                                           left => false);
                  begin
                     perm_sp:
                     entity work.perm_sp
                        generic map(
                           dimensions       => DIMENSIONS,
                           p_dimensions     => PARALLEL_DIMENSIONS,
                           serial_dim       => maximum(OPTIMAL_PERM(i)),
                           parallel_dim     => minimum(OPTIMAL_PERM(i)),
                           left_ps_latency  => aux_left,
                           right_ps_latency => aux_right
                        )
                        port map(
                           clk    => clk,
                           input  => inter(i-1),
                           start  => start_delayed(i-1),
                           output => inter(i),
                           finish => start_delayed(i)
                        );
                  end;
               end generate;
               serial_serial:
               if is_ss_perm(OPTIMAL_PERM(i), PARALLEL_DIMENSIONS) generate
                  begin
                     perm_ss:
                     entity work.perm_ss
                        generic map(
                           indexes    => OPTIMAL_PERM(i),
                           dimensions => DIMENSIONS
                        )
                        port map(
                           clk    => clk,
                           input  => inter(i-1),
                           start  => start_delayed(i-1),
                           output => inter(i),
                           finish => start_delayed(i)
                        );
                  end;
               end generate;
            end;
         end generate;

      end;
   else generate
      begin
         output <= input;
         finish <= start;
      end;
   end generate;

end architecture;

