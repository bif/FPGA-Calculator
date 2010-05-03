library ieee;
use ieee.std_logic_1164.all;
use work.math_pkg.all;
use work.uart_pkg.all;

entity uart is
	port
	(
		sys_clk		:	in std_logic;
		sys_res_n	:	in std_logic;
		send_byte_uart	:	in std_logic;
		byte_data	:	in std_logic_vector := "00000000";
		tx_busy_uart	:	out std_logic;
                uart_inst_tx	:	out std_logic := '0';
		uart_inst_rx	:	in  std_logic := '1';
		trigger_uart_tx	:	out std_logic := '0'
	);
end entity uart;
