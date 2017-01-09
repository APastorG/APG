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
    use ieee.numeric_std.all;
    use ieee.std_logic_1164.all;
    use ieee.math_real.all;

library work;
   use work.fixed_generic_pkg.all;
   use work.fixed_float_types.all;
   use work.common_data_types_pkg.all;
   use work.common_pkg.all;
   use work.complex_const_mult_pkg.all;
   use work.real_const_mult_pkg.all;
 
 /*================================================================================================*/
 /*================================================================================================*/
 /*================================================================================================*/
 
 entity complex_const_mult_core_s is
 
   generic(
      SPEED_opt          : T_speed       := t_exc;
      ROUND_STYLE_opt    : T_round_style := fixed_truncate;
      ROUND_TO_BIT_opt   : integer_exc   := integer'low;
      MAX_ERROR_PCT_opt  : real_exc      := real'low;
      MIN_OUTPUT_BIT     : integer       := integer'low;
      MAX_OUTPUT_BIT     : integer       := integer'low;
      MULTIPLICAND_REAL  : real;
      MULTIPLICAND_IMAG  : real;
      INPUT_HIGH         : integer;
      INPUT_LOW          : integer
   );
   port(
      clk          : in  std_ulogic;
      input_real   : in  u_sfixed;
      input_imag   : in  u_sfixed;
      valid_input  : in  std_ulogic;
      output_real  : out u_sfixed(complex_const_mult_OH(round_style_opt   => ROUND_STYLE_OPT,
                                                        round_to_bit_opt  => ROUND_TO_BIT_OPT,
                                                        max_error_pct_opt => MAX_ERROR_PCT_OPT,
                                                        max_output_bit    => MAX_OUTPUT_BIT,
                                                        constants(0 to 1) => (MULTIPLICAND_REAL,
                                                                              MULTIPLICAND_IMAG),
                                                        input_high        => INPUT_HIGH,
                                                        input_low         => INPUT_LOW,
                                                        is_signed         => true)
                                  downto 
                                  complex_const_mult_OL(round_style_opt   => ROUND_STYLE_OPT,
                                                        round_to_bit_opt  => ROUND_TO_BIT_OPT,
                                                        max_error_pct_opt => MAX_ERROR_PCT_OPT,
                                                        min_output_bit    => MIN_OUTPUT_BIT,
                                                        constants(0 to 1) => (MULTIPLICAND_REAL,
                                                                              MULTIPLICAND_IMAG),
                                                        input_low         => INPUT_LOW,
                                                        is_signed         => true)
                                  );
      output_imag  : out u_sfixed(complex_const_mult_OH(round_style_opt   => ROUND_STYLE_OPT,
                                                        round_to_bit_opt  => ROUND_TO_BIT_OPT,
                                                        max_error_pct_opt => MAX_ERROR_PCT_OPT,
                                                        max_output_bit    => MAX_OUTPUT_BIT,
                                                        constants(0 to 1) => (MULTIPLICAND_REAL,
                                                                              MULTIPLICAND_IMAG),
                                                        input_high        => INPUT_HIGH,
                                                        input_low         => INPUT_LOW,
                                                        is_signed         => true)
                                  downto 
                                  complex_const_mult_OL(round_style_opt   => ROUND_STYLE_OPT,
                                                        round_to_bit_opt  => ROUND_TO_BIT_OPT,
                                                        max_error_pct_opt => MAX_ERROR_PCT_OPT,
                                                        min_output_bit    => MIN_OUTPUT_BIT,
                                                        constants(0 to 1) => (MULTIPLICAND_REAL,
                                                                              MULTIPLICAND_IMAG),
                                                        input_low         => INPUT_LOW,
                                                        is_signed         => true)
                                  );
      valid_output : out std_ulogic
   );

 end entity;

 /*================================================================================================*/
 /*================================================================================================*/
 /*================================================================================================*/
 
 architecture complex_const_mult_core_s_1 of complex_const_mult_core_s is
 
   signal inter : u_sfixed_v(1 to 4)(real_const_mult_OH(round_style_opt   => ROUND_STYLE_OPT,
                                                        round_to_bit_opt  => ROUND_TO_BIT_OPT,
                                                        max_error_pct_opt => MAX_ERROR_PCT_OPT,
                                                        constants         => (MULTIPLICAND_REAL,
                                                                              MULTIPLICAND_IMAG),
                                                        input_high        => INPUT_HIGH,
                                                        input_low         => INPUT_LOW,
                                                        is_signed         => true)
                                    downto
                                    real_const_mult_OL(round_style_opt   => ROUND_STYLE_OPT,
                                                       round_to_bit_opt  => ROUND_TO_BIT_OPT,
                                                       max_error_pct_opt => MAX_ERROR_PCT_OPT,
                                                       constants         => (MULTIPLICAND_REAL,
                                                                             MULTIPLICAND_IMAG),
                                                       input_low         => INPUT_LOW,
                                                       is_signed         => true)
                                    );

   signal valid_input_inter : std_ulogic;

 /*================================================================================================*/
 /*================================================================================================*/
 
 begin
 
   msg_debug("input_real'high: " & image(input_real'high));
   msg_debug("input_real'low: " & image(input_real'low));
   msg_debug("inter(1)'high: " & image(inter(1)'high));
   msg_debug("inter(1)'low: " & image(inter(1)'low));

   constants_are_zero_or_not:
   if MULTIPLICAND_IMAG=0.0 and MULTIPLICAND_REAL=0.0 generate
      begin
         valid_output <= valid_input;
         --output will be zero, so we leave both real_out and imag_out open
      end;
   elsif MULTIPLICAND_IMAG=0.0 xor MULTIPLICAND_REAL=0.0 generate
         constant CONSTANTS : real_v := (1 => ite(MULTIPLICAND_REAL=0.0,
                                                  MULTIPLICAND_IMAG,
                                                  MULTIPLICAND_REAL));
      begin
         const_mult_real_part:
         entity work.real_const_mult_s
            generic map(
               SPEED_opt         => SPEED_opt,
               ROUND_STYLE_opt   => ROUND_STYLE_opt,
               ROUND_TO_BIT_opt  => ROUND_TO_BIT_opt,
               MAX_ERROR_PCT_opt => MAX_ERROR_PCT_opt,
               MULTIPLICANDS     => CONSTANTS
            )
            port map(
               input        => input_real,
               clk          => clk,
               valid_input  => valid_input,
               output(1)    => inter(1),
               valid_output => valid_input_inter
            );

         const_mult_imag_part:
         entity work.real_const_mult_s
            generic map(
               SPEED_opt         => SPEED_opt,
               ROUND_STYLE_opt   => ROUND_STYLE_opt,
               ROUND_TO_BIT_opt  => ROUND_TO_BIT_opt,
               MAX_ERROR_PCT_opt => MAX_ERROR_PCT_opt,
               MULTIPLICANDS     => CONSTANTS
            )
            port map(
               input        => input_imag,
               clk          => clk,
               valid_input  => valid_input,
               output(1)    => inter(3),
               valid_output => open
            );

         generate_addition:
         if MULTIPLICAND_REAL=0.0 generate
            begin
               generate_output:
               if is_pipelined(1, SPEED_opt, 1) generate
                  begin
                     process (clk) is
                     begin
                        if rising_edge(clk) then
                           output_imag <= resize(inter(1), output_imag);
                           output_real <= resize(-inter(3), output_real);
                        end if;
                     end process;
                  end;
               else generate
                  begin
                     output_imag <= resize(inter(1), output_imag);
                     output_real <= resize(-inter(3), output_real);
                  end;
               end generate;

               control_logic:
               entity work.pipelines
                  generic map(
                     LENGTH => number_of_pipelines(1, SPEED_opt)
                  )
                  port map(
                     clk       => clk,
                     input     => (1 => valid_input_inter),
                     output(1) => valid_output
                  );
            end;
         elsif MULTIPLICAND_IMAG=0.0 generate
            begin
               output_real <= resize(inter(1), output_real);
               output_imag <= resize(inter(3), output_imag);
               control_logic:
               entity work.pipelines
                  generic map(
                     LENGTH => 0
                  )
                  port map(
                     clk       => clk,
                     input     => (1 => valid_input_inter),
                     output(1) => valid_output
                  );
            end;
         end generate;
      end;
   else generate
         constant CONSTANTS : real_v := (MULTIPLICAND_REAL, MULTIPLICAND_IMAG);
      begin
         const_mult_real_part:
         entity work.real_const_mult_s
            generic map(
               SPEED_opt         => SPEED_opt,
               ROUND_STYLE_opt   => ROUND_STYLE_opt,
               ROUND_TO_BIT_opt  => ROUND_TO_BIT_opt,
               MAX_ERROR_PCT_opt => MAX_ERROR_PCT_opt,
               MULTIPLICANDS     => CONSTANTS
            )
            port map(
               input          => input_real,
               clk            => clk,
               valid_input    => valid_input,
               output(1 to 2) => inter(1 to 2),
               valid_output   => valid_input_inter
            );

         const_mult_imag_part:
         entity work.real_const_mult_s
            generic map(
               SPEED_opt         => SPEED_opt,
               ROUND_STYLE_opt   => ROUND_STYLE_opt,
               ROUND_TO_BIT_opt  => ROUND_TO_BIT_opt,
               MAX_ERROR_PCT_opt => MAX_ERROR_PCT_opt,
               MULTIPLICANDS     => CONSTANTS
            )
            port map(
               input        => input_imag,
               clk          => clk,
               valid_input  => valid_input,
               output       => inter(3 to 4),
               valid_output => open
            );

         generate_output:
         if is_pipelined(1, SPEED_opt, 1) generate
            begin
               process (clk) is
               begin
                  if rising_edge(clk) then
                     output_real <= resize(inter(1)-inter(4), output_real);
                     output_imag <= resize(inter(2)+inter(3), output_imag);
                  end if;
               end process;
            end;
         else generate
            begin
               output_real <= resize(inter(1)-inter(4), output_real);
               output_imag <= resize(inter(2)+inter(3), output_imag);
            end;
         end generate;
         
         control_logic:
         entity work.pipelines
            generic map(
               LENGTH => number_of_pipelines(1, SPEED_opt)
            )
            port map(
               clk       => clk,
               input     => (1 => valid_input_inter),
               output(1) => valid_output
            );
      end;
   end generate;
 
 
 end architecture;