library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package alu_pkg is
	component alu is
		generic
		(
			RESULT_MAX : signed(62 downto 0);
			RESULT_MIN : signed(62 downto 0)
		);
		port
		(
			sys_clk			:	in	std_logic := '0';
			sys_res_n		:	in	std_logic := '0';
			start_operation         :	in      std_logic := '0';
			operation_done          :	out     std_logic := '0';
			err_div_by_zero_alu	:	out     std_logic := '0';
			err_overflow		:	out     std_logic := '0';
			operand_1               :	in      signed(31 downto 0);
			operand_2               :	in      signed(31 downto 0);
			sum                     :	out     signed(62 downto 0);
			operator                :	in      std_logic_vector(1 downto 0) := "00"
		);
	end component alu;
end package alu_pkg;
