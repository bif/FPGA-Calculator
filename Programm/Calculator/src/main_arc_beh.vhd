library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.memarray_pkg.all;


architecture beh of main is

	constant LINES          : integer := 50;
	constant LINE_LENGTH    : integer := 80;
	constant DATA_WIDTH     : integer := 7;

	signal sense_old, sense_old_next		: std_logic := '0';
	signal start_calc_old, start_calc_old_next	: std_logic := '0';
	signal copy_lb, copy_lb_next			: std_logic := '0';
	signal btn_a_sig 				: std_logic := '0';
	signal uart_main_tx_sig 			: std_logic := '0';
	signal uart_main_rx_sig 			: std_logic := '0';
	signal byte_data				: std_logic_vector(7 downto 0) := "00000000";
	signal byte_data_next				: std_logic_vector(7 downto 0) := "00000000";
	signal tx_busy_main				: std_logic := '0';
	signal tx_busy_main_old				: std_logic := '0';
	signal tx_busy_main_old_next			: std_logic := '0';
	signal send_byte_main				: std_logic := '0';
	signal send_byte_main_next			: std_logic := '0';
	signal block_tx					: std_logic := '0';
	signal block_tx_next				: std_logic := '0';
	signal trigger_main_tx_sig			: std_logic := '0';
	
	signal init_sent				: integer range 0 to 5;
	signal init_sent_next				: integer range 0 to 5;

	-- memarray - signale
	signal wr_main					: std_logic;
	signal wr_main_next				: std_logic;
	signal ram_offset				: integer range 0 to 4000;
	signal ram_offset_next				: integer range 0 to 4000;
	signal data_in_main, data_in_main_next		: std_logic_vector(7 downto 0);
	signal data_out_main				: std_logic_vector(7 downto 0);
	signal mem_pointer, mem_pointer_next		: integer range 0 to 51;

	signal ram_line					: integer range 0 to 90;
	signal ram_line_next				: integer range 0 to 90;
	signal ram_tmp					: integer range 0 to 5;
	signal ram_tmp_next				: integer range 0 to 5;

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
		block_tx <= '0';
		init_sent <= 0;
		start_calc_old <= '0';
		wr_main <= '0';
		copy_lb <= '0';
		data_in_main <= x"00";
		mem_pointer <= 0;
		ram_line <= 0;
		ram_tmp <= 0;
	elsif rising_edge(sys_clk)
	then
		sense_old <= sense_old_next;
		tx_busy_main_old <= tx_busy_main_old_next;
		byte_data <= byte_data_next;
		ram_offset <= ram_offset_next;
		send_byte_main <= send_byte_main_next;
		block_tx <= block_tx_next;
		init_sent <= init_sent_next;
		start_calc_old <= start_calc_old_next;
		wr_main <= wr_main_next;
		copy_lb <= copy_lb_next;
		data_in_main <= data_in_main_next;
		mem_pointer <= mem_pointer_next;
		ram_line <= ram_line_next;
		ram_tmp <= ram_tmp_next;
	end if;
end process;

process(ram_offset, ram_tmp, ram_line, tx_busy_main_old, tx_busy_main, send_byte_main, byte_data, sense, sense_old, trigger_main_tx_sig, block_tx, init_sent, data_out_main, start_calc, start_calc_old, copy_lb, wr_main, data_in_main, lb_data, mem_pointer)
begin
	sense_old_next <= sense;
	ram_offset_next <= ram_offset;
	ram_line_next <= ram_line;
	ram_tmp_next <= ram_tmp;
	send_byte_main_next <= send_byte_main;
	byte_data_next <= byte_data;
	tx_busy_main_old_next <= tx_busy_main;
	block_tx_next <= block_tx;
	init_sent_next <= init_sent;
	copy_lb_next <= copy_lb;
	data_in_main_next <= data_in_main;
	wr_main_next <= wr_main;
	start_calc_old_next <= start_calc;
	mem_pointer_next <= mem_pointer;

	lb_addr <= x"00";

	-- transmit of ringbuffer triggered:
	if(((sense_old /= sense and sense = '0') or trigger_main_tx_sig = '1') and (block_tx = '0'))	
	then

		send_byte_main_next <= '1';
		byte_data_next <= "00001101";
		block_tx_next <= '1';
		init_sent_next <= 0;
		ram_offset_next <= 0;			-- get lines from proper start-adress(last_line_written + 1 = mem_pointer)
		--ram_offset_next <= mem_pointer * 80;			-- get lines from proper start-adress(last_line_written + 1 = mem_pointer)
	end if;

	-- start of calculation triggered - block TX, copy the inputline from linebuffer to memory, start calculation, enable TX again
	if(start_calc_old /= start_calc and start_calc = '1')	-- valid line in linebuffer
	then							-->copy this line into memory and trigger calculation
		copy_lb_next <= '1';
		block_tx_next <= '1';				-- disable TX while copying the last inputline into ringbuffer
		wr_main_next <= '1';		
		ram_offset_next <= 0;
	end if;

	if(tx_busy_main_old /= tx_busy_main and tx_busy_main = '0')
	then
		if(init_sent < 5)					-- send initial newlines
		then
			byte_data_next <= "00001010";
			send_byte_main_next <= '1';
			init_sent_next <= init_sent + 1;
			
		else
			if(ram_line = 80)				-- 2nd-last char of the line: send a newline
			then
				if(ram_tmp = 0)
				then
					byte_data_next <= "00001010";
					send_byte_main_next <= '1';
					ram_tmp_next <= 1;
				elsif(ram_tmp = 1)
				then
					ram_tmp_next <= 0;
					ram_line_next <= 0;
					byte_data_next <= "00001101";
					send_byte_main_next <= '1';
					
					if(ram_offset > 3871)	-- there are still lines to be sent - so go on...
					then
						send_byte_main_next <= '0';		-- last line was sent right now - no more TX-triggering...
						ram_offset_next <= 0;
						ram_line_next <= 0;
						block_tx_next <= '0';
					end if;
				end if;
			else								-- send the rest of the line
				ram_offset_next <= ram_offset + 1;
				ram_line_next <= ram_line + 1;
				if(data_out_main /= x"00")
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

	if(copy_lb = '1')
	then
		if(ram_offset < 70)
		then
			data_in_main_next <= lb_data;
			lb_addr <= std_logic_vector(to_unsigned(ram_offset * 80, ADR_WIDTH));
			ram_offset_next <= ram_offset + 1;
		else
			copy_lb_next <= '0';
			block_tx_next <= '0';			-- enable TX unit again
			mem_pointer_next <= mem_pointer + 1;
			if(mem_pointer = 50)
			then
				mem_pointer_next <= 0;
			end if;
		end if;
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
