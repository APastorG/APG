/***************************************************************************************************
/  Author:     Antonio Pastor González
/  ¯¯¯¯¯¯
/
/  Date        
/  ¯¯¯¯
/
/  Version:    
/  ¯¯¯¯¯¯¯
/
/  Notes:
/  ¯¯¯¯¯
/     This design makes use of some features from VHDL-2008, all of which have been implemented in
/  Xilinx's Vivado
/     A 3 space tab is used throughout the document
/
/  Description:
/  ¯¯¯¯¯¯¯¯¯¯¯
/     This package contains necessary types, constants, and functions for the parameterized
/  int_const_mult design.
/
 **************************************************************************************************/

library ieee;
   use ieee.std_logic_1164.all;
   use ieee.math_real.all;
   use ieee.numeric_std.all;

library work;
   use work.common_data_types_pkg.all;
   use work.common_pkg.all;
   use work.fixed_generic_pkg.all;
   use work.fixed_float_types.all;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

package real_const_mult_pkg is

/* function used to check the consistency and correctness of generics                           1 */
/**************************************************************************************************/

   function real_const_mult_CHECKS(
      data_high          : integer;
      data_low           : integer;
      unsigned_2comp_opt : boolean;
      round_to_bit_opt   : integer_exc;
      max_error_pct      : real_exc;
      constants          : real_v)
   return integer;


/* functions for corrected generics and internal/external port signals                          2 */
/**************************************************************************************************/
   --returns a vector with the high index of each of the partial outputs
   function calculate_high(
      mult_fundamental : positive;
      input_high       : integer;
      is_signed        : boolean)
   return integer;

   --returns the output signals' low index, which is the lowest of the low indexes of the partial output signals
   function real_const_mult_OL(
      round_style_opt   : T_round_style;
      round_to_bit_opt  : integer_exc;
      max_error_pct_opt : real_exc;
      constants         : real_v;
      input_low         : integer;
      is_signed         : boolean)
   return integer;

   --returns the output signals' high index, which is the highest of the high indexes of the partial output signals
   function real_const_mult_OH(
      round_style_opt   : T_round_style;
      round_to_bit_opt  : integer_exc;
      max_error_pct_opt : real_exc;
      constants         : real_v;
      input_high        : integer;
      input_low         : integer;
      is_signed         : boolean)
   return integer;

   --applies the assigned parameters of round style, round to bit, and max error percentage to transform
   --the constants to the correct fixed point form.
   function fixed_from_real_constants(
      round_style_opt   : T_round_style;
      round_to_bit_opt  : integer_exc;
      max_error_pct_opt : real_exc;
      constants         : real_v;
      input_high        : integer;
      input_low         : integer;
      is_signed         : boolean)
   return u_ufixed_v;


/* functions to obtain the integer factors from the real multiplicands                          3 */
/**************************************************************************************************/
   --returns true if all the values in the boolean vector are true
   function all_positive(
      vector : boolean_v)
   return boolean;

   --returns a boolean vector which indicates whether the constants are positive
   function is_positive_vector_from_constants(
      constants : real_v)
   return boolean_v;

   --calculates the needed shift to convert the fixed point constants to an odd natural number
   function calculate_pre_vp_shift(
      mult_fixed : u_ufixed_v)
   return integer_v;

   --calculates the positive odd numbers from the vector of fixed point ones
   function calculate_mult_fundamental(
      mult_fixed   : u_ufixed_v;
      pre_vp_shift : integer_v)
   return positive_v;


/* function to generate file names                                                              4 */
/**************************************************************************************************/
   --generates a name from hashing the parameters of the module real_const_int to obtain different
   --names for each instantiation
   function generate_file_name(
      round_style_opt   : T_round_style;
      round_to_bit_opt  : integer_exc;
      max_error_pct_opt : real_exc;
      constants         : positive_v)
   return string;

end package;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

package body real_const_mult_pkg is

/********************************************************************************************** 1 */

   function real_const_mult_CHECKS(
      data_high          : integer;
      data_low           : integer;
      unsigned_2comp_opt : boolean;
      round_to_bit_opt   : integer_exc;
      max_error_pct      : real_exc;
      constants          : real_v)
   return integer is
      variable output_inter_w : positive;
      variable output_w       : positive;
   begin
/*
      --trying to multiply by 0
      assert
         report
            " ILLEGAL PARAMETERS in entity const_multiplier: the absolute value of the " &
            "constants must be greater than 1"
         severity error;

      --using unsigned but multiplicating by negative constant
      assert not(constants<0 and unsigned_2comp_opt)
         report 
            "ILLEGAL PARAMETERS in entity const_multiplier: the design is set to use unsigned" &
            " format but the constants is negative. Whenever this happens the parameter "&
            "unsigned_2comp_opt can only be false."
         severity error;

      output_inter_w := int_const_mult_OIW(data_width,
                                           unsigned_2comp_opt,
                                           constants);

      output_w       := int_const_mult_OW(data_width,
                                          unsigned_2comp_opt,
                                          output_width_opt,
                                          constants);

      --selected output width is not enough for the result
      assert not(output_w < output_inter_w)
         report 
            "ILLEGAL PARAMETERS in entity const_multiplier: The selected output width (" &
            image(output_w) & ") is not enough to represent all possible " &
            "results from the multiplication. At least " & image(output_inter_w) &
            " bits are needed."
         severity error;

*/
      return 0;
   end function;


/********************************************************************************************** 2 */
   --used to calculate the output'high from each individual mult_fundamentals from the output'high
   --of the previous fundamentals
   function calculate_high(
      mult_fundamental : positive;
      input_high       : integer;
      is_signed        : boolean)
   return integer is
      variable result : integer;
   begin
      if is_signed then
         --(a downto b)*(c downto d) = (a+c downto b+d), (with exception: see below)
         --example: -2(1,0)*-3(2,0)=6(3,0)
         result := input_high + min_bits(mult_fundamental, is_signed) - 1;
         --having one input(multiplicand) fixed and the other variable:
         --when the multiplicand is 10...0 we have a special case in signed:
         --the output will need 1 bit more than any other multiplicand which is representable in
         --   the same (and not fewer) number of bits
         --example: for an input of 3 bits:
         --multipicand = -4(100) . When the input is 100(-4), the result is 16, which in signed
         --   needs 6 bits (010000). Meanwhile, for a multiplicand = -3(101), the result (12)
         --   only needs 5 bits (01100)
         if is_signed and ("mod"(log2(real(mult_fundamental)), 1.0) = 0.0) then
            result := result + 1;
         end if;
      else
         --(a downto b)*(c downto d) = (a+c downto b+d), (with exception: see below)
         --example: 2(1,0)*3(1,0)=6(2,0)
         result := input_high + min_bits(mult_fundamental, is_signed) - 1;
         --having one input(multiplicand) fixed and the other variable:
         --when the multiplicand is 11...1 we have a special case in unsigned:
         --the output will need 1 bit less than any other multiplicand which is representable in
         --   the same (and not fewer) number of bits
         --example: for an input of 3 bits:
         --multipicand = 4(100) . When the input is 111(7), the result is 28, which in unsigned
         --   needs 5 bits (11100). Meanwhile, for a multiplicand = 7(111), the result (49)
         --   needs 6 bits (110001)
         if find_rightmost(unsigned(sulv_from_int(mult_fundamental)), '0') = integer'high + 1
         then
            result := result + 1;
         end if;
      end if;
      return result;
   end function;

   function output_low(
      round_style_opt   : T_round_style;
      round_to_bit_opt  : integer_exc;
      max_error_pct_opt : real_exc;
      constants         : real_v;
      input_low         : integer;
      is_signed         : boolean)
   return integer_v is
      variable result : integer_v(constants'range);
      variable u_sat : u_ufixed(75 downto -75);
      variable s_sat : u_sfixed(75 downto -75);
   begin
      if round_to_bit_opt = integer'low then
         for i in constants'range loop
            u_sat := resize(to_ufixed(abs(constants(i)),
                                       max_error_pct => ite(max_error_pct_opt=real'low, --max_error_pct_opt was not assigned a value
                                                             0.0,
                                                             max_error_pct_opt),
                                       round_style => round_style_opt),
                            u_sat);
            s_sat := resize(to_sfixed(constants(i),
                                      max_error_pct => ite(max_error_pct_opt=real'low, --max_error_pct_opt was not assigned a value
                                                           0.0,
                                                           max_error_pct_opt),
                                      round_style => round_style_opt),
                            s_sat);
            if is_signed then
               result(i) := sfixed_low(0, --irrelevant
                                       input_low,
                                       '*',
                                       0, --irrelevant
                                       maximum(find_rightmost(u_sat, '1'), -FRACTIONAL_LIMIT)
                                       );
            else
               result(i) := ufixed_low(0, --irrelevant
                                       input_low,
                                       '*',
                                       0, --irrelevant
                                       maximum(find_rightmost(u_sat, '1'), FRACTIONAL_LIMIT)
                                       );
            end if;
         end loop;
      else
         --result := (others => round_to_bit_opt);
         for i in constants'range loop
            u_sat := resize(to_ufixed(abs(constants(i)),
                                      max_error_pct => 0.0,
                                      round_style => round_style_opt),
                            u_sat);
            u_sat := resize(to_ufixed(abs(constants(i)),
                                      u_sat'high,
                                      round_to_bit_opt,
                                      round_style => round_style_opt),
                            u_sat);
            s_sat := resize(to_sfixed(constants(i),
                                      max_error_pct => 0.0,
                                      round_style => round_style_opt),
                            s_sat);
            s_sat := resize(to_sfixed(constants(i),
                                      s_sat'high,
                                      round_to_bit_opt,
                                      round_style => round_style_opt),
                            s_sat);
            if is_signed then
               result(i) := sfixed_low(0, --irrelevant
                                       input_low,
                                       '*',
                                       0, --irrelevant
                                       find_rightmost(s_sat, '1')
                                       );
            else
               result(i) := ufixed_low(0, --irrelevant
                                       input_low,
                                       '*',
                                       0, --irrelevant
                                       find_rightmost(u_sat, '1')
                                       );
            end if;
         end loop;
      end if;
      return result;
   end function;

   function real_const_mult_OL(
      round_style_opt   : T_round_style;
      round_to_bit_opt  : integer_exc;
      max_error_pct_opt : real_exc;
      constants         : real_v;
      input_low         : integer;
      is_signed         : boolean)
   return integer is
      variable aux    : integer_v(constants'range) := output_low(round_style_opt,
                                                                 round_to_bit_opt,
                                                                 max_error_pct_opt,
                                                                 constants,
                                                                 input_low,
                                                                 is_signed);
      variable result : integer := integer'high;
   begin
      for i in aux'range loop
         if aux(i) < result then
            result := aux(i);
         end if;
      end loop;
      return result;
   end function;

   function output_high(
      round_style_opt   : T_round_style;
      round_to_bit_opt  : integer_exc;
      max_error_pct_opt : real_exc;
      constants         : real_v;
      input_high        : integer;
      input_low         : integer;
      is_signed         : boolean)
   return integer_v is
      variable result : integer_v(constants'range);
      variable out_consants_low : integer_v(constants'range) := output_low(round_style_opt,
                                                                           round_to_bit_opt,
                                                                           max_error_pct_opt,
                                                                           constants,
                                                                           input_low,
                                                                           is_signed);
      variable u_sat : u_ufixed(75 downto -75);
      variable s_sat : u_sfixed(75 downto -75);
   begin
      for i in constants'range loop
         u_sat := resize(to_ufixed(abs(constants(i))), u_sat);      --convert with ~0% error
         s_sat := resize(to_sfixed(constants(i)), s_sat);      --convert with ~0% error
         if is_signed then
            --(a downto b)*(c downto d) = (a+c downto b+d), (with exception: see below)
            --example: -2(1,0)*-3(2,0)=6(3,0)
            result(i) := input_high + find_leftmost(s_sat, ite(constants(i) < 0.0, '0', '1')) + 1;
            --having one input(multiplicand) fixed and the other variable:
            --when the multiplicand is 10...0 we have a special case in signed:
            --the output will need 1 bit more than any other multiplicand which is representable in
            --   the same (and not fewer) number of bits
            --example: for an input of 3 bits:
            --multipicand = -4(100) . When the input is 100(-4), the result is 16, which in signed
            --   needs 6 bits (010000). Meanwhile, for a multiplicand = -3(101), the result (12)
            --   only needs 5 bits (01100)
            if constants(i) < 0.0 and find_leftmost(u_sat, '1') = find_rightmost(u_sat, '1') then
               result(i) := result(i) + 1;
            end if;
            --when the multiplicand is the same special case as in unsigned:
            --example: -2(1,0)*2(2,0)=-4(2,0)
            if constants(i) > 0.0 and find_leftmost(u_sat, '1') = find_rightmost(u_sat, '1') then
               result(i) := result(i) - 1;
            end if;
         else
            --(a downto b)*(c downto d) = (a+c downto b+d), (with exception: see below)
            --example: 2(1,0)*3(1,0)=6(2,0)
            result(i) := input_high + find_leftmost(u_sat, '1');
            --having one input(multiplicand) fixed and the other variable:
            --when the multiplicand is 11...1 we have a special case in unsigned:
            --the output will need 1 bit less than any other multiplicand which is representable in
            --   the same (and not fewer) number of bits
            --example: for an input of 3 bits:
            --multipicand = 4(100) . When the input is 111(7), the result is 28, which in unsigned
            --   needs 5 bits (11100). Meanwhile, for a multiplicand = 7(111), the result (49)
            --   needs 6 bits (110001)
            if find_rightmost(resize(u_sat,
                                     u_sat'high,
                                     out_consants_low(i),
                                     round_style => round_style_opt),
                              '0') = integer'high + 1
            then
               result(i) := result(i) + 1;
            end if;
         end if;
      end loop;
      return result;
   end function;

   function real_const_mult_OH(
      round_style_opt   : T_round_style;
      round_to_bit_opt  : integer_exc;
      max_error_pct_opt : real_exc;
      constants         : real_v;
      input_high        : integer;
      input_low         : integer;
      is_signed         : boolean)
   return integer is
      variable aux    : integer_v(constants'range) := output_high(round_style_opt,
                                                                  round_to_bit_opt,
                                                                  max_error_pct_opt,
                                                                  constants,
                                                                  input_high,
                                                                  input_low,
                                                                  is_signed);
      variable result : integer := integer'low;
   begin
      for i in aux'range loop
         if aux(i) > result then
            result := aux(i);
         end if;
      end loop;
      return result;
   end function;

   function fixed_from_real_constants(
      round_style_opt   : T_round_style;
      round_to_bit_opt  : integer_exc;
      max_error_pct_opt : real_exc;
      constants         : real_v;
      input_high        : integer;
      input_low         : integer;
      is_signed         : boolean)
   return u_ufixed_v is
      constant max_error_pct    : real      := ite(max_error_pct_opt = real'low,
                                                   0.0,
                                                   max_error_pct_opt);
      constant individual_highs : integer_v := output_high(round_style_opt,
                                                           round_to_bit_opt,
                                                           max_error_pct_opt,
                                                           constants,
                                                           input_high,
                                                           input_low,
                                                           is_signed);
      constant individual_lows  : integer_v := output_low(round_style_opt,
                                                          round_to_bit_opt,
                                                          max_error_pct_opt,
                                                          constants,
                                                          input_low,
                                                          is_signed);
      constant result_high      : integer   := real_const_mult_OH(round_style_opt,
                                                                  round_to_bit_opt,
                                                                  max_error_pct_opt,
                                                                  constants,
                                                                  input_high,
                                                                  input_low,
                                                                  is_signed);
      constant result_low       : integer   := real_const_mult_OL(round_style_opt,
                                                                  round_to_bit_opt,
                                                                  max_error_pct_opt,
                                                                  constants,
                                                                  input_low,
                                                                  is_signed);
      variable result           : u_ufixed_v(1 to constants'length)(result_high downto result_low);
      variable constant_high, constant_low : integer;
   begin
      for i in constants'range loop
         --the transformation to the desired size range
         constant_high := individual_highs(i) - input_high;
         constant_low  := individual_lows(i) - input_low;
         --assert false
         --   report "constant_high: " & image(constant_high)
         --   severity warning;
         --assert false
         --   report "constant_low: " & image(constant_low)
         --   severity warning;
         result(i) := resize(to_ufixed(constants(i),
                                       constant_high,
                                       constant_low,
                                       round_style => round_style_opt),
                             result_high,
                             result_low);
      end loop;
      return result;
   end function;


/********************************************************************************************** 3 */

   function all_positive(
      vector : boolean_v)
   return boolean is
   begin
      for i in vector'range loop
         if not vector(i) then
            return false;
         end if;
      end loop;
      return true;
   end function;

   function is_positive_vector_from_constants(
      constants : real_v)
   return boolean_v is
      variable result : boolean_v(constants'range);
   begin
      for i in constants'range loop
         result(i) := constants(i) >= 0.0;
      end loop;
      return result;
   end function;

   function calculate_pre_vp_shift(
      mult_fixed : u_ufixed_v)
   return integer_v is
      variable result : integer_v(mult_fixed'range);
   begin
      for i in mult_fixed'range loop
         result(i) := -find_rightmost(mult_fixed(i), '1');
      end loop;
      return result;
   end function;

   function calculate_mult_fundamental(
      mult_fixed   : u_ufixed_v;
      pre_vp_shift : integer_v)
   return positive_v is
      variable result : positive_v(1 to mult_fixed'length);
   begin
      for i in mult_fixed'range loop
         result(i) := positive(to_real(scalb(mult_fixed(i), pre_vp_shift(i))));
      end loop;
      return result;
   end function;


/********************************************************************************************** 4 */
   --string used as this function should be static to work when called in synthesis and thus cannot
   --contain line data types(which would more flexible as the size wouldn't need to be predefined)
   function generate_file_name(
      round_style_opt   : T_round_style;
      round_to_bit_opt  : integer_exc;
      max_error_pct_opt : real_exc;
      constants         : positive_v)
   return string is
      constant high             : integer := 60;
      constant low              : integer := -10;
      variable size_for_numeric_part, actual_numeric_part_size : positive;
      variable accumulative     : u_ufixed(high downto low) := to_ufixed(1, high, low);
      variable aux              : u_ufixed(high downto low) := to_ufixed(1, high, low);
      variable result           : string(1 to FILE_NAME_LENGTH);
      variable temporal         : positive;
      variable counter          : positive := 1;
   begin
      case round_style_opt is
         when fixed_round    => result(counter to counter+1) := "r_";
         when fixed_truncate => result(counter to counter+1) := "t_";
      end case;
      counter := counter + 2;
      if round_to_bit_opt = integer'low then
         result(counter to counter+1) := "0_";
         counter := counter + 2;
      elsif round_to_bit_opt > 0 then
         result(counter) := 'p';  --positive
         counter := counter + 1;
         temporal := integer(ceil(log10(real(round_to_bit_opt)+1)));
         result(counter to counter+temporal-1) := image(round_to_bit_opt);
         counter := counter + temporal;
         result(counter) := '_';  --positive
         counter := counter + 1;
      else
         result(counter) := 'n';  --negative
         counter := counter + 1;
         temporal := integer(ceil(log10(abs(real(round_to_bit_opt))+1)));
         result(counter to counter+temporal-1) := image(abs(round_to_bit_opt));
         counter := counter + temporal;
         result(counter) := '_';  --positive
         counter := counter + 1;
      end if;
      size_for_numeric_part := FILE_NAME_LENGTH - counter - 4; --the total length minus the already existing part minus 4 from ".txt"
      for i in constants'range loop
         if abs(constants(i))<1 then
            accumulative := resize(accumulative * to_ufixed(1/abs(constants(i)), high, low),
                                   accumulative);
         else
            accumulative := resize(accumulative * to_ufixed(abs(constants(i)), high, low),
                                   accumulative);
         end if;
      end loop;
      if max_error_pct_opt /= real'low then
         accumulative := resize(accumulative + to_ufixed(1000*max_error_pct_opt, high, low),
                                accumulative);
      end if;
      accumulative := resize(accumulative*2**10, accumulative);
      for i in 1 to size_for_numeric_part loop
         aux := resize(aux * 10.0, aux);
      end loop;
      accumulative := modulo(accumulative, aux);
      actual_numeric_part_size := integer(ceil(log10(to_real(accumulative)+1)));
      if actual_numeric_part_size < size_for_numeric_part then
         result(counter to counter + (size_for_numeric_part-actual_numeric_part_size) - 1) := (others => '0');
         counter := counter + (size_for_numeric_part-actual_numeric_part_size);
      end if;
      result(counter to counter + actual_numeric_part_size - 1):= image(integer(to_real(accumulative)));
      counter := counter + actual_numeric_part_size;
      result(counter to counter + 3) := string'(".txt");
      return result;
   end function;

end package body;
