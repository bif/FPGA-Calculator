library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.math_pkg.all;

architecture beh of uart_send is
	type UART_SEND_STATE_TYPE is ( STARTBIT, DATABIT0, DATABIT1, DATABIT2, DATABIT3, DATABIT4, DATABIT5, DATABIT6, DATABIT7, STOPBIT, IDLE);
	signal uart_send_state : UART_SEND_STATE_TYPE;
	signal uart_send_state_next : UART_SEND_STATE_TYPE;
	signal enable_TX		:	std_logic := '0';
	signal enable_TX_next		:	std_logic := '0';
	signal baud_cnt			:	integer range 0 to 291 := 0;
	signal baud_cnt_next		:	integer range 0 to 291 := 0;
	signal uart_send_tx_next	:	std_logic := '1';
	signal uart_send_tx_old_next	:	std_logic := '1';
	signal send_byte_old		:	std_logic := '0';
	signal send_byte_old_next	:	std_logic := '0';
	signal tx_busy_next		:	std_logic := '0';
begin

	process(sys_clk, sys_res_n)
	begin
		if(sys_res_n = '0')
		then
			uart_send_state <= STARTBIT;
			baud_cnt	<= 0;
			enable_TX <= '0';
			send_byte_old <= '0';
			tx_busy <= '0';
		elsif(sys_clk'event and sys_clk = '1')
		then
			uart_send_state <= uart_send_state_next;
			enable_TX <= enable_TX_next;
			baud_cnt <= baud_cnt_next;
			uart_send_tx <= uart_send_tx_next;
			send_byte_old <= send_byte_old_next;
			tx_busy <= tx_busy_next;
		end if;
	end process;

	process(baud_cnt, enable_TX, send_byte, send_byte_old, uart_send_state, byte_out, uart_send_tx, tx_busy)
	begin
		uart_send_state_next <= uart_send_state;
		baud_cnt_next <= baud_cnt;
		send_byte_old_next <= send_byte;
		uart_send_tx_next <= uart_send_tx;
		tx_busy_next <= tx_busy;
		enable_TX_next <= enable_TX;

		if(enable_TX = '1')
		then
			baud_cnt_next <= baud_cnt + 1;
			if(baud_cnt = 290)
			then
				case uart_send_state is
				when STARTBIT   =>
					uart_send_tx_next <= '0';
					uart_send_state_next <= DATABIT0;
				when DATABIT0   =>
					uart_send_tx_next <= byte_out(0);
					uart_send_state_next <= DATABIT1;
				when DATABIT1   =>
					uart_send_tx_next <= byte_out(1);
					uart_send_state_next <= DATABIT2;
				when DATABIT2   =>
					uart_send_tx_next <= byte_out(2);
					uart_send_state_next <= DATABIT3;
				when DATABIT3   =>
					uart_send_tx_next <= byte_out(3);
					uart_send_state_next <= DATABIT4;
				when DATABIT4   =>
					uart_send_tx_next <= byte_out(4);
					uart_send_state_next <= DATABIT5;
				when DATABIT5   =>
					uart_send_tx_next <= byte_out(5);
					uart_send_state_next <= DATABIT6;
				when DATABIT6   =>
					uart_send_tx_next <= byte_out(6);
					uart_send_state_next <= DATABIT7;
				when DATABIT7   =>
					uart_send_tx_next <= byte_out(7);
					uart_send_state_next <= STOPBIT;
				when STOPBIT    =>
					uart_send_tx_next <= '1';
					uart_send_state_next <= IDLE;
				when IDLE       =>
					uart_send_tx_next <= '1';
				end case;
				baud_cnt_next <= 0;
			end if;
		end if;
		if(send_byte_old /= send_byte and send_byte = '1')
		then
			enable_TX_next <= '1';
			tx_busy_next <= '1';
		end if;	
		if(uart_send_state = IDLE)
		then
			enable_TX_next <= '0';
			tx_busy_next <= '0';
					uart_send_state_next <= STARTBIT;
		end if;
		
	end process;

end architecture beh;

