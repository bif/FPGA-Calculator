library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.memarray_pkg.all;
use work.error_msg_pkg.all;

architecture beh of main is

	constant	LINES          : integer := 50;
	constant	LINE_LENGTH    : integer := 81;
	constant	DATA_WIDTH     : integer := 7;
	
	type 		MAIN_STATE_TYPE is (READY, SEND_UART, COPY_LB, COPY_SUM, WAIT4SUM);
        signal		main_state				: MAIN_STATE_TYPE;
        signal		main_state_next				: MAIN_STATE_TYPE;

	signal		btn_a_sig 				: std_logic := '0';
	signal		sense_old, sense_old_next		: std_logic := '0';
	signal		start_calc_old, start_calc_old_next	: std_logic := '0';

	signal		goto_nextstate				: std_logic := '0';
	signal		goto_nextstate_next			: std_logic := '0';
	signal		decode_ready_old, decode_ready_old_next	: std_logic := '0';

	-- uart - related:	
	signal		uart_main_tx_sig 			: std_logic := '0';
	signal		uart_main_rx_sig 			: std_logic := '0';
	signal		tx_busy_main				: std_logic := '0';
	signal		tx_busy_main_old			: std_logic := '0';
	signal		tx_busy_main_old_next			: std_logic := '0';
	signal		send_byte_main				: std_logic := '0';
	signal		send_byte_main_next			: std_logic := '0';
	signal		trigger_main_tx_sig			: std_logic := '0';
	signal		init_sent				: integer range 0 to 5;
	signal		init_sent_next				: integer range 0 to 5;

	-- memarray - related:
	signal		byte_data				: std_logic_vector(7 downto 0) := "00000000";
	signal		byte_data_next				: std_logic_vector(7 downto 0) := "00000000";
	signal		wr_main					: std_logic := '0';
	signal		wr_main_next				: std_logic := '0';
	signal		ram_offset				: integer range 0 to 4095;
	signal		ram_offset_next				: integer range 0 to 4095;
	signal		data_in_main, data_in_main_next		: std_logic_vector(7 downto 0);
	signal		data_out_main				: std_logic_vector(7 downto 0);
	signal		mem_pointer, mem_pointer_next		: integer range 0 to 51;
	signal		ram_line				: integer range 0 to 90;
	signal		ram_line_next				: integer range 0 to 90;
	signal		line_count, line_count_next		: integer range 0 to 50;
	signal		rbuf_overflow, rbuf_overflow_next	: std_logic := '0';
	signal		addr, addr_next				: std_logic_vector(7 downto 0) := "00000000";
	signal		lb_enable_next				: std_logic := '0';


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
		ram_offset <= 0;
		send_byte_main <= '0';
		tx_busy_main_old <= '0';
		init_sent <= 0;
		start_calc_old <= '0';
		wr_main <= '0';
		data_in_main <= x"00";
		mem_pointer <= 0;
		ram_line <= 0;
		line_count <= 0;
		data_in_main <= "00000000";
		--lb_addr <= "00000000";
		lb_enable <= '0';
		rbuf_overflow <= '0';
		addr <= "00000000";
		decode_ready_old <= '0';
		main_state <= READY;
		goto_nextstate <= '0';
	elsif rising_edge(sys_clk)
	then
		sense_old <= sense_old_next;
		tx_busy_main_old <= tx_busy_main_old_next;
		byte_data <= byte_data_next;
		ram_offset <= ram_offset_next;
		send_byte_main <= send_byte_main_next;
		init_sent <= init_sent_next;
		start_calc_old <= start_calc_old_next;
		wr_main <= wr_main_next;
		data_in_main <= data_in_main_next;
		mem_pointer <= mem_pointer_next;
		ram_line <= ram_line_next;
		line_count <= line_count_next;
		--lb_addr <= lb_addr_next;
		lb_enable <= lb_enable_next;
		rbuf_overflow <= rbuf_overflow_next;
		addr <= addr_next;
		decode_ready_old <= decode_ready_old_next;
		main_state <= main_state_next;
		goto_nextstate <= goto_nextstate_next;
	end if;
end process;

process(ram_offset, ram_line, tx_busy_main_old, tx_busy_main, send_byte_main, byte_data, sense, sense_old, trigger_main_tx_sig, init_sent, data_out_main, start_calc, start_calc_old, wr_main, data_in_main, lb_data, mem_pointer, line_count, rbuf_overflow, addr, decode_ready_main, decode_ready_old, main_state, bcd_buf, sign_bcd_main, goto_nextstate)
begin
	sense_old_next <= sense;
	ram_offset_next <= ram_offset;
	ram_line_next <= ram_line;
	send_byte_main_next <= send_byte_main;
	byte_data_next <= byte_data;
	tx_busy_main_old_next <= tx_busy_main;
	init_sent_next <= init_sent;
	data_in_main_next <= data_in_main;
	wr_main_next <= wr_main;
	start_calc_old_next <= start_calc;
	mem_pointer_next <= mem_pointer;
	line_count_next <= line_count;
	lb_enable_next <= '0';
	rbuf_overflow_next <= rbuf_overflow;
	--lb_addr_next <= lb_addr;
	lb_addr <= "00000000";
	addr_next <= addr;
	decode_ready_old_next <= decode_ready_main;
	main_state_next <= main_state;
	goto_nextstate_next <= goto_nextstate;
	
	case main_state is
		when READY =>

			lb_enable_next <= '0';
			-- transmit of ringbuffer triggered:
			if((sense_old /= sense and sense = '0') or trigger_main_tx_sig = '1')	
			then
				main_state_next <= SEND_UART;
				send_byte_main_next <= '1';
				byte_data_next <= "00001101";
				init_sent_next <= 0;
				line_count_next <= 0;

				if(rbuf_overflow = '0')				-- fewer than 50 lines input so far
				then
					ram_offset_next <= 0;
				else
					ram_offset_next <= mem_pointer * 81;	-- get lines from proper startadress(ringbuf was wrapped around)
				end if;
			end if;

			-- start of calculation triggered(calc will be done by calc_inst): block TX, copy the inputline from linebuffer to memory, enable TX again
			if(start_calc_old /= start_calc and start_calc = '1')	
			then
				addr_next <= "00000000";			-- set next adress for reading from linebuffer
				ram_offset_next <= 81 * mem_pointer;		-- set destination address(ringbuffer)
				main_state_next <= COPY_LB;
			end if;


		when SEND_UART =>
			if(tx_busy_main_old /= tx_busy_main and tx_busy_main = '0')
			then
				if(init_sent < 5)					-- send initial newlines
				then
					byte_data_next <= "00001010";
					send_byte_main_next <= '1';
					init_sent_next <= init_sent + 1;
					
				else
					if(ram_line = 70)				-- 2nd-last char of the line: send a newline
					then
						byte_data_next <= x"3d";
						send_byte_main_next <= '1';
						ram_line_next <= ram_line + 1;
					elsif(ram_line = 82)				-- 2nd-last char of the line: send a newline
					then
						byte_data_next <= "00001010";
						send_byte_main_next <= '1';
						ram_line_next <= ram_line + 1;
					elsif(ram_line = 83)
					then
						ram_line_next <= 0;
						byte_data_next <= "00001101";
						send_byte_main_next <= '1';
						line_count_next <= line_count + 1;					
		
						if(line_count = 49)				-- there are no more lines to be sent
						then
							send_byte_main_next <= '0';
							ram_line_next <= 0;
							main_state_next <= READY;
						end if;
					else								-- send the rest of the line
						ram_offset_next <= ram_offset + 1;
						ram_line_next <= ram_line + 1;
						if(data_out_main /= x"00" and data_out_main /= x"3D")
						then
							byte_data_next <= data_out_main;
						else
							byte_data_next <= x"20";
						end if;
						send_byte_main_next <= '1';
					end if;
				end if;
				elsif(tx_busy_main = '1')	-- TX of last byte not finished yet
				then
					send_byte_main_next <= '0';
				end if;

		when COPY_LB =>
			if(unsigned(addr) < 70)
			then
				wr_main_next <= '1';		
				data_in_main_next <= lb_data;		-- .. write actual data to ringbuffer

				ram_offset_next <= ram_offset + 1;
				lb_addr <= addr;
				addr_next <= std_logic_vector(unsigned(addr) + 1);
			else
				main_state_next <= WAIT4SUM;
				wr_main_next <= '0';
				if(mem_pointer = 50)
				then
					mem_pointer_next <= 0;
					rbuf_overflow_next <= '1';
				end if;
			end if;
			
			if(decode_ready_old /= decode_ready_main and decode_ready_main = '1')	-- BCD - conversion of calculation is DONE --> copy sum into ringbuffer
			then									-- FIXME: this happens because no error_sig_handling from parser so far
				goto_nextstate_next <= '1';
			end if;

		when WAIT4SUM =>

			if((decode_ready_old /= decode_ready_main and decode_ready_main = '1') or(goto_nextstate = '1')) -- or: see FI	
			then
				ram_line_next <= 0;
				main_state_next <= COPY_SUM;
				goto_nextstate_next <= '0';
		
				if(bcd_buf(3 downto 0) = "1100")
				then
					data_in_main_next <= err_str_divbyzero(0);
				elsif(bcd_buf(3 downto 0) = "1110")
				then
					data_in_main_next <= err_str_parsererror(0);
				elsif(bcd_buf(3 downto 0) = "1111")
				then
					data_in_main_next <= err_str_overflow(0);
				else
					if(sign_bcd_main = '0')
					then
						data_in_main_next <= x"2b";				-- '+'
					else
						data_in_main_next <= x"2d";				-- '-'
					end if;
				end if;
			end if;
			
		when COPY_SUM =>
			if(ram_line = 0)		-- send <+> or <->
			then
				wr_main_next <= '1';
				ram_line_next <= ram_line + 1;
				ram_offset_next <= mem_pointer * 81 + ram_line + 71;
			elsif(ram_line < 11)
			then
				wr_main_next <= '1';
				ram_offset_next <= ram_offset + 1;
				ram_line_next <= ram_line + 1;
				
				if(bcd_buf(3 downto 0)= "1100")			-- calculator found no error
				then
					data_in_main_next <= err_str_divbyzero(ram_line);
				elsif(bcd_buf(3 downto 0) = "1110")
				then
					data_in_main_next <= err_str_parsererror(ram_line);
				elsif(bcd_buf(3 downto 0) = "1111")
				then
					data_in_main_next <= err_str_overflow(ram_line);
				else
					data_in_main_next <= std_logic_vector(unsigned(resize(bcd_buf((ram_line*4-1) downto ((ram_line-1)*4)), 8)) + 48);
				end if;
			else
				lb_enable_next <= '1';			-- wake up linebuffer-module again
				wr_main_next <= '0';
				mem_pointer_next <= mem_pointer + 1;
				ram_line_next <= 0;
				main_state_next <= READY;
			end if;
	
	end case;

--	if(ram_offset = 4050)					-- overflow(mem_pointer /= 0x00)	FIXME
--	then
--		ram_offset_next <= 0;
--	end if;


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

	memarray_inst : memarray                -- this is the ringbuffer: 50 x 81 x 8 bit
	generic map
	(
		LINES           =>      LINES,
		LINE_LENGTH     =>      LINE_LENGTH,
		DATA_WIDTH      =>      DATA_WIDTH
	)
	port map
	(
		sys_clk         =>      sys_clk,
		sys_res_n       =>      sys_res_n,
		wr              =>      wr_main,
		ram_offset      =>      ram_offset,
		data_in         =>      data_in_main,
		data_out        =>      data_out_main
	);

end architecture beh;
