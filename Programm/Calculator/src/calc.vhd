library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity calc is
	generic
	(
		OPERAND_MAX	:	signed(31 downto 0) := "01111111111111111111111111111111";
		OPERAND_MIN	:	signed(31 downto 0) := "10000000000000000000000000000001";
		RESULT_MAX	:	signed(62 downto 0) := "011111111111111111111111111111111111111111111111111111111111111";
		RESULT_MIN	:	signed(62 downto 0) := "100000000000000000000000000000000000000000000000000000000000001"
	);
	port
	(
		sys_clk		:	in	std_logic;
		sys_res_n	:	in	std_logic;
		parse_ready	:	in	std_logic;
		start_calc	:	in	std_logic;
		decode_ready	:	out	std_logic;
		nibble_0	:	out	unsigned(3 downto 0) := "0000";		-- calculation nibble 0 (einerstelle)
		nibble_1	:	out	unsigned(3 downto 0) := "0000";		-- ...
		nibble_2	:	out	unsigned(3 downto 0) := "0000";
		nibble_3	:	out	unsigned(3 downto 0) := "0000";
		nibble_4	:	out	unsigned(3 downto 0) := "0000";
		nibble_5	:	out	unsigned(3 downto 0) := "0000";
		nibble_6	:	out	unsigned(3 downto 0) := "0000";
		nibble_7	:	out	unsigned(3 downto 0) := "0000";
		nibble_8	:	out	unsigned(3 downto 0) := "0000";
		nibble_9	:	out	unsigned(3 downto 0) := "0000";		-- ... most significant nibble
		operation_end	:	in	std_logic;
		operand		:	in	signed(31 downto 0);
		operator	:	in	std_logic_vector(1 downto 0)  := "00";
		need_input	:	out	std_logic;
		calc_ready	:	out	std_logic;
		error_calc	:	out	std_logic
	);
end entity calc;
