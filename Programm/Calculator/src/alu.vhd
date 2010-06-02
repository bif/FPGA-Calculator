library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
	port
	(
		sys_clk			:	in	std_logic := '0';
		sys_res_n		:	in	std_logic := '0';
		start_operation		:	in	std_logic := '0';
		operation_done		:	out	std_logic := '0';
		operand_1		:	in	signed(31 downto 0);
		operand_2		:	in	signed(31 downto 0);
		sum			:	out	signed(62 downto 0);
		operator		:	in	std_logic_vector(1 downto 0) := "00"
	);

end entity alu;
