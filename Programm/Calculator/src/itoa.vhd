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
		out_0		: out unsigned(3 downto 0) := "0000";
		out_1		: out unsigned(3 downto 0) := "0000";
		out_2		: out unsigned(3 downto 0) := "0000";	
		out_3		: out unsigned(3 downto 0) := "0000";
		out_4		: out unsigned(3 downto 0) := "0000";	
		out_5		: out unsigned(3 downto 0) := "0000";
		out_6		: out unsigned(3 downto 0) := "0000";
		out_7		: out unsigned(3 downto 0) := "0000";
		out_8		: out unsigned(3 downto 0) := "0000";
		out_9		: out unsigned(3 downto 0) := "0000";
		decode_ready	: out std_logic := '0';
		sign		: buffer std_logic := '0'
	);
end entity itoa;
