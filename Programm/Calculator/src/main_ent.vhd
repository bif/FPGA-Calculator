library ieee;
use ieee.std_logic_1164.all;
use work.memarray_pkg.all;

entity main is
	generic
	(
		RESET_VALUE : std_logic
	);
	port
	(
		sys_clk			: in	std_logic;
		sys_res_n		: in	std_logic;
		sense			: in	std_logic;
		uart_main_tx		: out	std_logic;
		uart_main_rx		: in	std_logic := '1';
		trigger_main_tx		: out	std_logic := '0'
	);
end entity main;
