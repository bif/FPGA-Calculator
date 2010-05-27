library ieee;
use ieee.std_logic_1164.all;
use work.memarray_pkg.all;

entity main is
	generic
	(
		RESET_VALUE : std_logic;
		DAT_WIDTH : integer range 1 to integer'high;
		ADR_WIDTH : integer range 1 to integer'high
	);
	port
	(
		sys_clk			: in	std_logic;
		sys_res_n		: in	std_logic;
		sense			: in	std_logic;
		uart_main_tx		: out	std_logic;
		uart_main_rx		: in	std_logic := '1';
		trigger_main_tx		: out	std_logic := '0';
		lb_enable		: out	std_logic := '0';
		start_calc		: in	std_logic := '0';
		lb_data			: in	std_logic_vector(DAT_WIDTH - 1 downto 0);
		lb_addr			: buffer	std_logic_vector(ADR_WIDTH - 1 downto 0)
	);
end entity main;
