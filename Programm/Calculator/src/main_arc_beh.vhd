library ieee;
use ieee.std_logic_1164.all;

architecture beh of main is

	signal sense_old, sense_old_next : std_logic;
	signal btn_a_sig : std_logic;
	signal uart_main_tx_sig : std_logic;
	signal uart_main_rx_sig : std_logic;
	signal more_tx_data	: std_logic;
	signal more_tx_data_next: std_logic := '0';
	signal byte_data	: std_logic_vector(7 downto 0) := "00000000";
	signal byte_data_next	: std_logic_vector(7 downto 0) := "00000000";
	signal line_counter	: integer range 0 to 51;
	signal line_counter_next: integer range 0 to 51;
	signal char_counter	: integer range 0 to 51;
	signal char_counter_next: integer range 0 to 51;
	signal tx_busy_main	: std_logic := '0';
	signal tx_busy_main_old	: std_logic := '0';
	signal tx_busy_main_old_next	: std_logic := '0';
	signal send_byte_main	: std_logic := '0';
	signal send_byte_main_next	: std_logic := '0';
	signal trigger_main_tx_sig	: std_logic := '0';

	component uart is
	port
	(
		sys_clk		:	in std_logic;
		sys_res_n	:	in std_logic;
		send_byte_uart	:	in std_logic;
		tx_busy_uart	:	out std_logic;
		byte_data	:	in std_logic_vector := "00000000";
		uart_inst_tx	:	out std_logic;
		uart_inst_rx	:	in std_logic := '1';
		trigger_uart_tx	:	out std_logic := '1'
	);
	end component uart;

begin

process(sys_clk, sys_res_n)
	begin
	if sys_res_n = '0'
	then
		sense_old <= RESET_VALUE;
		byte_data <= "00000000";
		line_counter <= 0;
		char_counter <= 0;
		more_tx_data <= '0';
		send_byte_main <= '0';
		tx_busy_main_old <= '0';
	elsif rising_edge(sys_clk)
	then
		sense_old <= sense_old_next;
		tx_busy_main_old <= tx_busy_main_old_next;
		byte_data <= byte_data_next;
		line_counter <= line_counter_next;
		char_counter <= char_counter_next;
		more_tx_data <= more_tx_data_next;
		send_byte_main <= send_byte_main_next;
	end if;
  end process;
  
process(sense, sense_old, line_counter, more_tx_data, trigger_main_tx_sig)
begin
	sense_old_next <= sense;
	more_tx_data_next <= more_tx_data;

	if sense_old /= sense and sense = '0' 
	then	--sense = '0' ... weil button low aktiv
		more_tx_data_next <= '1';
	end if;

	if(line_counter = 5)
	then
		more_tx_data_next <= '0';
	end if;

	if(trigger_main_tx_sig = '1')
	then
		more_tx_data_next <= '1';
	end if;
end process;

process(more_tx_data, line_counter, char_counter, tx_busy_main_old, tx_busy_main, send_byte_main, byte_data)
begin
	line_counter_next <= line_counter;
	char_counter_next <= char_counter;
	send_byte_main_next <= send_byte_main;
	byte_data_next <= byte_data;
	tx_busy_main_old_next <= tx_busy_main;

	if(more_tx_data = '1')
	then
		if(line_counter = 0 and char_counter = 0)
		then
			byte_data_next <= "00001010";
			char_counter_next <= char_counter + 1;
			send_byte_main_next <= '1';
		elsif(tx_busy_main_old /= tx_busy_main and tx_busy_main = '0')
		then
			if(char_counter = 0)
			then
				char_counter_next <= char_counter + 1;
				byte_data_next <= "00001010";
				send_byte_main_next <= '1';
			elsif(char_counter = 1)
			then
				char_counter_next <= char_counter + 1;
				byte_data_next <= "00001101";
				send_byte_main_next <= '1';
			elsif(char_counter = 10)
			then
				line_counter_next <= line_counter + 1;
				char_counter_next <= 0;
				byte_data_next <= "01010001";
				send_byte_main_next <= '1';
			else
				char_counter_next <= char_counter + 1;
				byte_data_next <= "01010000";
				send_byte_main_next <= '1';
			end if;
		else
			send_byte_main_next <= '0';
		end if;
	else
		line_counter_next <= 0;
	end if;
end process;

	uart_inst : uart
	port map
	(
		sys_clk  => sys_clk,
		sys_res_n => sys_res_n,
		uart_inst_tx => uart_main_tx_sig,
		uart_inst_rx => uart_main_rx_sig,
		send_byte_uart => send_byte_main,
		byte_data => byte_data,
		tx_busy_uart => tx_busy_main,
		trigger_uart_tx => trigger_main_tx_sig
	);

	uart_main_tx <= uart_main_tx_sig;
	uart_main_rx_sig <= uart_main_rx;
	trigger_main_tx <= trigger_main_tx_sig;

end architecture beh;
