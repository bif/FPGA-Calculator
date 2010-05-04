library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.math_pkg.all;

architecture beh of uart_rcv is
	type RXD_STATE_TYPE is (READY, STARTBIT, DATABITS, STOPBIT);
	signal baud_cnt		: integer range 0 to 291;
	signal baud_cnt_next	: integer range 0 to 292;
	signal bit_cnt		: integer range 0 to 10;
	signal bit_cnt_next	: integer range 0 to 10;
	signal enable_rx	: std_logic := '0';
	signal enable_rx_next	: std_logic := '0';
	signal byte_in		: std_logic_vector(7 downto 0) := "00000000";
	signal byte_in_next	: std_logic_vector(7 downto 0) := "00000000";
	signal trigger_tx_next	: std_logic := '0';
	signal uart_rx_old	: std_logic := '1';
	signal uart_rx_old_next	: std_logic := '1';
begin
	process(sys_clk, sys_res_n)
	begin
		if(sys_res_n = '0')
		then
			baud_cnt <= 0;
			bit_cnt <= 0;
--			trigger_tx <= '0';
			uart_rx_old <= '0';
		else
			if(sys_clk'event and sys_clk = '1')
			then
				byte_in <= byte_in_next;
				bit_cnt <= bit_cnt_next;
				baud_cnt <= baud_cnt_next;
				enable_rx <= enable_rx_next;
				uart_rx_old <= uart_rx_old_next;
--				trigger_tx <= trigger_tx_next;
			end if;
		end if;
	end process;

	process(uart_rcv_rx, uart_rx_old,bit_cnt, baud_cnt, enable_rx, byte_in)
	begin
		uart_rx_old_next <= uart_rcv_rx;
		bit_cnt_next <= bit_cnt;
		trigger_tx <= '0';
		enable_rx_next <= enable_rx;
		byte_in_next <= byte_in;

		if(uart_rcv_rx /= uart_rx_old and uart_rcv_rx = '0')
		then
			enable_rx_next <= '1';
		end if;

		if(bit_cnt = 9)
		then
			enable_rx_next <= '0';
			if(byte_in = "01010101")		-- ASCII 's'
			then
				trigger_tx <= '1';
			end if;
		end if;

		if(enable_rx = '1')
		then
			if(baud_cnt = 290)
			then
				baud_cnt_next <= 0;
				bit_cnt_next <= bit_cnt + 1;
			elsif(baud_cnt = 145)
			then
				if(bit_cnt > 0)	-- ignore startbit
				then
					byte_in_next(bit_cnt - 1) <= uart_rcv_rx;
				end if;
				baud_cnt_next <= baud_cnt + 1;
			else
				baud_cnt_next <= baud_cnt + 1;
			end if;
		else
			baud_cnt_next <= 0;
			bit_cnt_next <= 0;
		end if;
	
	end process;

end architecture;
