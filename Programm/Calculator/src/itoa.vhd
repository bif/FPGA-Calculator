library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity itoa is
	port
	(
		sys_clk		: in std_logic;
		sys_res_n	: in std_logic;
		int_in		: in integer range -2147483647 to 2147483647 := 0;
--		int_in		: in signed(31 downto 0);
		start_decode	: in std_logic;
		out_0		: buffer unsigned(3 downto 0) := "0000";
		out_1		: buffer unsigned(3 downto 0) := "0000";
		out_2		: buffer unsigned(3 downto 0) := "0000";	
		out_3		: buffer unsigned(3 downto 0) := "0000";
		out_4		: buffer unsigned(3 downto 0) := "0000";	
		out_5		: buffer unsigned(3 downto 0) := "0000";
		out_6		: buffer unsigned(3 downto 0) := "0000";
		out_7		: buffer unsigned(3 downto 0) := "0000";
		out_8		: buffer unsigned(3 downto 0) := "0000";
		out_9		: buffer unsigned(3 downto 0) := "0000";
		decode_ready	: out std_logic := '0';
		sign		: buffer std_logic := '0'
	);
end entity itoa;
