library ieee;
use ieee.std_logic_1164.all;
use work.math_pkg.all;

entity uart_send is
	generic
	(
		constant Log_0          : std_logic := '0';
		constant Log_1          : std_logic := '1'
	);
	port
        (
		sys_clk		: in std_logic;
		sys_res_n	: in std_logic;
		byte_out	: in std_logic_vector(7 downto 0) := "00000000";
		send_byte	: in std_logic := '0';
		tx_busy		: buffer std_logic := '0';
                uart_send_tx	: buffer std_logic := '1'
	);

end entity uart_send;
