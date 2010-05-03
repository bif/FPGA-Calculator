library ieee;
use ieee.std_logic_1164.all;
use work.math_pkg.all;

entity uart_rcv is
	port
	(
		sys_clk : 	in std_logic := '0';
		sys_res_n : 	in std_logic := '0';
		uart_rcv_rx   : in std_logic := '0';
		trigger_tx	: buffer std_logic := '0'
	);
end entity uart_rcv;
