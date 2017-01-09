

library ieee;
   use ieee.math_real.all;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;

library work;
   use work.fixed_float_types.all;
   use work.fixed_generic_pkg.all;
   use work.common_data_types_pkg.all;
   use work.common_pkg.all;

package permutation_pkg is

   function permutation_checks(
      input_length   : integer;
      input_indexes  : integer_v;
      output_indexes : integer_v)
   return boolean;

   function is_pp_perm(
      elem_bit_exchange   : integer_v;
      parallel_dimensions : natural)
   return boolean;

   function is_sp_perm(
      elem_bit_exchange   : integer_v;
      parallel_dimensions : natural)
   return boolean;

   function is_ss_perm(
      elem_bit_exchange   : integer_v;
      parallel_dimensions : natural)
   return boolean;   

   function contiguous_ps_latency(
      optimal_perm        : integer_vv;
      parallel_dimensions : positive;
      i                   : natural;
      left                : boolean)
   return natural;

   function calculate_indexes(
      i      : integer;
      P      : natural;
      K      : natural;
      offset : natural)
   return natural;

   function generate_perm_file_name(
      parallel_dimensions : positive;
      input_indexes       : integer_v;
      output_indexes      : integer_v)
   return string;

end package;

package body permutation_pkg is

   function permutation_checks(
      input_length   : integer;
      input_indexes  : integer_v;
      output_indexes : integer_v)
   return boolean is
      variable dimensions         : integer := output_indexes'length;
      variable par_dimensions     : real    := log2(real(input_length));
      variable par_dimensions_int : integer := integer(par_dimensions);
   begin
      --The number of inputs is not a power of 2
      assert (integer(par_dimensions) mod 1) = 0
         report "(1) " &
         "ERROR in module permutation: The number of inputs(" & 
         image(input_length) & ") must be a power of 2 " & image(par_dimensions mod 1.0)
         severity error;
      --The generic OUTPUT_INDEXES and the number of inputs do not agree, as the value of dimensions
      --is smaller than the parallel dimensions
      assert dimensions >= par_dimensions_int
         report "(2) " &
         "ERROR in module permutation: For the length of the assigned output indexes (" &
         image(dimensions) & ") the number of inputs (" & image(input_length) & ") " &
         "cannot be greater than (" & image(integer(2.0**dimensions)) & ")"
         severity error;
      --The generics INPUT_INDEXES and OUTPUT_INDEXES don't have the same size
      assert output_indexes'length >= input_indexes'length
         report "(3) " &
         "ERROR in module permutation: The sizes of the parameters INPUT_INDEXES(" &
         image(integer'(input_indexes'length)) & ") and OUTPUT_INDEXES(" &
         image(integer'(output_indexes'length)) &
         ") must be equal."
         severity error;
      --The input_indexes vector doesn't contain all the indexes from 0 to dimensions-1
      ext_loop_in: for i in 0 to dimensions - 1 loop
         for j in 0 to dimensions - 1 loop
            if input_indexes(j) = i then
               next ext_loop_in;
            end if;
         end loop;
         assert false
            report "(4) " &
            "ERROR in module permutation: The values of INPUT_INDEXES must contain the " &
            "values from 0 to " & image(dimensions-1) & " but " & image(i) & " is missing"
            severity error;
      end loop;
      --The output_indexes vector doesn't contain all the indexes from 0 to dimensions-1
      ext_loop_out: for i in 0 to dimensions - 1 loop
         for j in 0 to dimensions - 1 loop
            if output_indexes(j) = i then
               next ext_loop_out;
            end if;
         end loop;
         assert false
            report "(5) " &
            "ERROR in module permutation: The values of OUTPUT_INDEXES must contain the " &
            "values from 0 to " & image(dimensions-1) & " but " & image(i) & " is missing"
            severity error;
      end loop;

      return true;
   end function;

   function is_parallel(
      index               : natural;
      parallel_dimensions : natural)
   return boolean is
   begin
      return  index < parallel_dimensions;
   end function;

   function is_pp_perm(
      elem_bit_exchange   : integer_v;
      parallel_dimensions : natural)
   return boolean is
   begin
      assert elem_bit_exchange'length = 2
         report "ERROR in module permutation: function is_pp called with parameter " &
         "elem_bit_exchange of illegal length (" & image(integer'(elem_bit_exchange'length)) &")."
         severity error;
      return is_parallel(elem_bit_exchange(1), parallel_dimensions)
             and
             is_parallel(elem_bit_exchange(2), parallel_dimensions);
   end function;

   function is_sp_perm(
      elem_bit_exchange   : integer_v;
      parallel_dimensions : natural)
   return boolean is
   begin
      assert elem_bit_exchange'length = 2
         report "ERROR in module permutation: function is_sp called with parameter " &
         "elem_bit_exchange of illegal length (" & image(integer'(elem_bit_exchange'length)) &")."
         severity error;
      return is_parallel(elem_bit_exchange(1), parallel_dimensions)
             xor
             is_parallel(elem_bit_exchange(2), parallel_dimensions);
   end function;

   function is_ss_perm(
      elem_bit_exchange   : integer_v;
      parallel_dimensions : natural)
   return boolean is
   begin
      assert elem_bit_exchange'length = 2
         report "ERROR in module permutation: function is_ss called with parameter " &
         "elem_bit_exchange of illegal length (" & image(integer'(elem_bit_exchange'length)) &")."
         severity error;
      return not(is_parallel(elem_bit_exchange(1), parallel_dimensions)
                 or
                 is_parallel(elem_bit_exchange(2), parallel_dimensions));
   end function;

   function contiguous_ps_latency(
      optimal_perm        : integer_vv;
      parallel_dimensions : positive;
      i                   : natural;
      left                : boolean)
   return natural is
   begin
      if left and i > 1 then
         if is_sp_perm(optimal_perm(i-1), parallel_dimensions) then             --previous elementary bit exchange is serial-parallel
            if minimum(optimal_perm(i-1)) = minimum(optimal_perm(i)) then       --they share the lowest dimension(the parallel one)
               return (2**maximum(optimal_perm(i-1)))/(2**parallel_dimensions); --return latency of previous ps permutation block
            end if;
         end if;
      elsif (not left) and (i < optimal_perm'length) then
         if is_sp_perm(optimal_perm(i+1), parallel_dimensions) then             --next elementary bit exchange is serial-parallel
            if minimum(optimal_perm(i+1)) = minimum(optimal_perm(i)) then       --they share the lowest dimension(the parallel one)
               return (2**maximum(optimal_perm(i+1)))/(2**parallel_dimensions); --return latency of next ps permutation block
            end if;
         end if;
      end if;
      return 0;
   end function;

   function calculate_indexes(
      i      : integer;
      P      : natural;
      K      : natural;
      offset : natural)
   return natural is
      variable aux : std_ulogic_vector(P-1 downto 0);
   begin
      aux := std_ulogic_vector(to_unsigned(abs(i), P));
      aux := aux sll 1;
      if K > 0 then
         aux(K-1 downto 0) := aux(K downto 1);
      end if;
      aux(K) := '1' when offset = 1 else
                '0';
      return to_integer(unsigned(aux));
   end function;

   --designed for at most 99 indexes
   function calculate_file_name_length(
      parallel_dimensions : positive;
      input_indexes       : integer_v;
      output_indexes      : integer_v)
   return positive is
      constant number_of_indexes  : positive := input_indexes'length;
      constant one_digit_indexes  : natural  := minimum(10, number_of_indexes);
      constant two_digit_indexes  : natural  := ite(number_of_indexes > 10,
                                                    number_of_indexes-10,
                                                    0);
      variable is_input_in_order  : boolean  := true;
      variable is_output_in_order : boolean  := true;
      variable result : natural := 0;
   begin
      if parallel_dimensions > 9 then               --"10_"
         result := result + 3;
      elsif parallel_dimensions > 0 then            --"9_"
         result := result + 2;
      end if;
      floop1:
      for i in 0 to number_of_indexes-1 loop
         if input_indexes(i) /= number_of_indexes-1-i then
            is_input_in_order := false;
            exit floop1;
         end if;
      end loop;
      floop2:
      for i in 0 to number_of_indexes-1 loop
         if output_indexes(i) /= number_of_indexes-1-i then
            is_output_in_order := false;
            exit floop2;
         end if;
      end loop;
      if is_input_in_order then
         result := result + 2;                     --"00"
      else
         result := result + one_digit_indexes;        --"1"
         result := result + 2*two_digit_indexes;      --"a1" (11)
      end if;
      result := result + 1;                        --"_"
      if is_output_in_order then
         result := result + 2;                     --"00"
      else
         result := result + one_digit_indexes;        --"1"
         result := result + 2*two_digit_indexes;      --"a1" (11)
      end if;
      result := result + 4;                        --".txt"
      return result;
   end function;

   --string used as this function should be static to work when called in synthesis and thus cannot
   --contain line data types(which would more flexible as the size wouldn't need to be predefined)
   --designed for at most 99 indexes
   function generate_perm_file_name(
      parallel_dimensions : positive;
      input_indexes       : integer_v;
      output_indexes      : integer_v)
   return string is
      constant letters : string(1 to 9) := "abcdefghi";
      constant file_name_length   : positive := calculate_file_name_length(parallel_dimensions,
                                                                           input_indexes,
                                                                           output_indexes);
      variable is_input_in_order  : boolean  := true;
      variable is_output_in_order : boolean  := true;
      variable counter : natural := 1;

      variable result : string(1 to file_name_length);
   begin
      if parallel_dimensions > 9 then
         result(counter to counter+1) := image(parallel_dimensions);
         counter := counter + 2;
      elsif parallel_dimensions > 0 then
         result(counter to counter) := image(parallel_dimensions);
         counter := counter + 1;
      end if;

      result(counter to counter) := "_";
      counter := counter + 1;

      floop1:
      for i in 0 to input_indexes'length-1 loop
         if input_indexes(i) /= input_indexes'length-1-i then
            is_input_in_order := false;
            exit floop1;
         end if;
      end loop;
      floop2:
      for i in 0 to output_indexes'length-1 loop
         if output_indexes(i) /= output_indexes'length-1-i then
            is_output_in_order := false;
            exit floop2;
         end if;
      end loop;

      if is_input_in_order then
         result(counter to counter+1) := "00";
         counter := counter + 2;
      else
         for i in 0 to input_indexes'length-1 loop
            if input_indexes(i)>9 then
               result(counter) := letters(integer(real(input_indexes(i))/10.0));
               counter := counter + 1;
            end if;
            result(counter) := integer'image(input_indexes(i) rem 10)(1);
            counter := counter + 1;
         end loop;
      end if;

      result(counter) := '_';
      counter := counter + 1;

      if is_output_in_order then
         result(counter to counter+1) := "00";
         counter := counter + 2;
      else
         for i in 0 to output_indexes'length-1 loop
            if output_indexes(i)>9 then
               result(counter) := letters(integer(real(output_indexes(i))/10.0));
               counter := counter + 1;
            end if;
            result(counter) := integer'image(output_indexes(i) rem 10)(1);
            counter := counter + 1;
         end loop;
      end if;

      result(counter to counter + 3) := string'(".txt");
      return result;
   end function;

end package body;