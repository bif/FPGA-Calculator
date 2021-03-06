library ieee;
use ieee.std_logic_1164.all;
use work.memarray_pkg.all;
use ieee.numeric_std.all;

entity main is
	generic
	(
		RESET_VALUE		: std_logic;
		DAT_WIDTH		: integer range 1 to integer'high;
		ADR_WIDTH		: integer range 1 to integer'high
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
		decode_ready_main	: in	std_logic := '0';				
		main_lb_data		: in	std_logic_vector(DAT_WIDTH - 1 downto 0);
		main_lb_addr		: out	std_logic_vector(ADR_WIDTH - 1 downto 0) := "00000000";
		bcd_buf			: in	unsigned(39 downto 0);
		sign_bcd_main		: in	std_logic
	);
end entity main;
