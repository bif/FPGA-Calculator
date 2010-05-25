library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.math_pkg.all;

package uart_pkg is
	component uart_send is
		port
		(
			uart_send_tx		: out std_logic;
			sys_clk			: in std_logic := '0';
			sys_res_n		: in std_logic := '0';
			send_byte		: in std_logic := '0';
			tx_busy			: buffer std_logic := '0';
			byte_out	        : in std_logic_vector(7 downto 0) := "01000010"
		);
	end component uart_send;

	component uart_rcv is
		port
		(	
			sys_clk			: in std_logic := '0';
			sys_res_n		: in std_logic := '0';
			trigger_tx		: out std_logic := '0';
			uart_rcv_rx		: in std_logic := '0'
		);
	end component uart_rcv;
	
end package uart_pkg;

architecture beh of uart is
	signal uart_tx_sig 			: std_logic;
	signal uart_rx_sig 			: std_logic;
	signal send_byte_uart_sig		: std_logic := '0';
	signal tx_busy_uart_sig			: std_logic := '0';
	signal trigger_uart_tx_sig		: std_logic := '0';
	signal byte_out_sig			: std_logic_vector(7 downto 0) := "00000000";

begin
	process(sys_res_n, sys_clk)
	begin
		if(sys_res_n = '0')
		then
			null;
		elsif(sys_clk'event and sys_clk = '1')
		then
			null;
		end if;
	end process;
			
	uart_send_inst : uart_send
	port map
	(
		sys_clk => sys_clk,
		sys_res_n => sys_res_n,
		uart_send_tx => uart_tx_sig,
		send_byte => send_byte_uart_sig,
		byte_out => byte_out_sig,
		tx_busy => tx_busy_uart_sig
	);

	uart_rcv_inst : uart_rcv
	port map
	(
		sys_clk => sys_clk,
		sys_res_n => sys_res_n,
		uart_rcv_rx => uart_rx_sig,
		trigger_tx => trigger_uart_tx_sig
	);
	
	uart_inst_tx <= uart_tx_sig;
	uart_rx_sig <= uart_inst_rx;
	send_byte_uart_sig <= send_byte_uart;
	tx_busy_uart <= tx_busy_uart_sig;
	byte_out_sig <= byte_data;
	trigger_uart_tx <= trigger_uart_tx_sig;
end architecture beh;
	
