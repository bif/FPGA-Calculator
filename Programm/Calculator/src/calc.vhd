library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity calc is
	generic
	(
		RESULT_MAX	:	signed(62 downto 0);
		RESULT_MIN	:	signed(62 downto 0)
	);
	port
	(
		sys_clk		:	in	std_logic;
		sys_res_n	:	in	std_logic;
		parse_ready	:	in	std_logic;
		start_calc	:	in	std_logic;
		decode_ready_calc	: out	std_logic;
		sign_bcd_calc		: out	std_logic;
		bcd_buf		:	buffer	unsigned(39 downto 0);
		operation_end	:	in	std_logic;
		operand		:	in	signed(31 downto 0);
		operator	:	in	std_logic_vector(1 downto 0)  := "00";
		need_input	:	out	std_logic;
		calc_ready	:	out	std_logic;
		errcode_parser	:	in	std_logic_vector(2 downto 0)		-- inputsignal from PARSER
	);
end entity calc;
