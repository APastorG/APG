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
/  Xilinx's Vivado
/     A 3 space tab is used throughout the document
/
/
/  Description:
/  ¯¯¯¯¯¯¯¯¯¯¯
/     This is the interface between the instantiation of an int_const_DIV an its content. It exists
/  to circumvent the impossibility of reading the attributes of an unconstrained port signal inside
/  the port declaration of an entity. (so as to declare the output's size, which depends on the
/  input's size).
/
 **************************************************************************************************/

library ieee;
   use ieee.std_logic_1164.all;

library work;
   use work.common_pkg.all;
   use work.common_data_types_pkg.all;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

entity int_const_div is

   generic(
      UNSIGNED_2COMP_opt : boolean   := false;  --default
      SPEED_opt          : T_speed   := t_min;     --exception: value not set
      DIVISORS           : integer_v            --compulsory
   );

   port(
      input        : in  std_ulogic_vector;
      clk          : in  std_ulogic;
      valid_input  : in  std_ulogic;

      output       : out sulv_v;
      valid_output : out std_ulogic
   );

end entity;

/*================================================================================================*/
/*================================================================================================*/
/*================================================================================================*/

architecture int_const_div1 of int_const_div is

   function to_real_and_invert(
      vector : integer_v)
   return real_v is
      variable result : real_v(vector'range);
   begin
      for i in vector'range loop
         result(i) := 1.0/real(vector(i));
      end loop;
      return result;
   end function;

   constant MULTIPLICANDS_real : real_v(DIVISORS'range) := to_real_and_invert(DIVISORS);

/*================================================================================================*/
/*================================================================================================*/

begin


   real_const_mult2:
   entity work.real_const_mult
      generic map(
         SPEED_opt     => SPEED_opt,
         --ROUND_STYLE_opt   => ROUND_STYLE_opt,
         --ROUND_TO_BIT_opt  => ROUND_TO_BIT_opt,
         --MAX_ERROR_PCT_opt => MAX_ERROR_PCT_opt,
         MULTIPLICANDS => MULTIPLICANDS_real
      )
      port map(
         input        => input,
         clk          => clk,
         valid_input  => valid_input,
         output       => output,
         valid_output => valid_output
      );


end architecture;