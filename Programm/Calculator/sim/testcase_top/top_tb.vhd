library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.line_buffer_pkg.all;
use work.textmode_vga_pkg.all;
use work.sp_ram_pkg.all;library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.debounce_pkg.all;
use work.sync_pkg.all;
use work.textmode_vga_platform_dependent_pkg.all;
use work.textmode_vga_component_pkg.all;
use work.pll_wrapper_pkg.all;
--use work.ps2_keyboard_controller_pkg.all;
--use work.scancode_handler_pkg.all;
use work.line_buffer_pkg.all;
use work.sp_ram_pkg.all;
use work.parser_pkg.all;
use work.main_pkg.all;

entity line_buffer_tb is

end line_buffer_tb;

architecture sim of line_buffer_tb is

	constant CLK_FREQ : integer := 33330000;
	constant TIMEOUT : time := 1 ms;
	constant RES_N_DEFAULT_VALUE : std_logic := '1';
	constant SYNC_STAGES : integer := 2;
	constant BTN_A_RESET_VALUE : std_logic := '0';	-- changed from 1 --> 0
	constant COMMAND_SIZE : integer := 8;
	constant COLOR_SIZE : integer := 8;
	constant CHAR_SIZE : integer := 8;
	constant LB_DATA_WIDTH : integer := 8;
	constant LB_ADDR_WIDTH : integer := 8;
	-- calc_inst - signals / constants
	constant	OPERAND_MAX		:	signed(31 downto 0) := "01111111111111111111111111111111";
	constant	OPERAND_MIN		:	signed(31 downto 0) := "10000000000000000000000000000001";
	constant	RESULT_MAX		:	signed(62 downto 0) := "011111111111111111111111111111111111111111111111111111111111111";
	constant	RESULT_MIN		:	signed(62 downto 0) := "100000000000000000000000000000000000000000000000000000000000001";
  constant QUARTZ_PERIOD : time := 33 ns;
	constant QUARTZ_PLL_PERIOD : time := 40 ns;



	signal test_string : string(1 to 71);
	signal index : integer range 1 to 80 := 1;


	signal sys_clk, pss_clk_sig, sys_reset_n, sys_res_n_sync, btn_a_sync, vga_free_sig, pll_clk_sig : std_logic;
	signal command_sig : std_logic_vector(COMMAND_SIZE - 1 downto 0);
	signal command_data_sig : std_logic_vector(3 * COLOR_SIZE + CHAR_SIZE - 1 downto 0);
	signal ps2_data_sig, ps2_data_conect, ascii_sign_sig : std_logic_vector(7 downto 0);
	signal ps2_new_data_sig, new_ascii_sig : std_logic;
	signal uart_top_tx_sig	: std_logic;
	signal uart_top_rx_sig	: std_logic;

	signal lb_addr_out_sig, lb_addr_wr_sig, main_lb_addr_sig : std_logic_vector(LB_ADDR_WIDTH - 1 downto 0);
	signal lb_data_wr_sig, lb_data_out_sig, main_lb_data_sig : std_logic_vector(LB_DATA_WIDTH - 1  downto 0);
	signal lb_wr_sig, enable_lb_sig, start_calc_sig : std_logic := '0';
	signal operand_sig : signed(31 downto 0);
	signal operator_sig : std_logic_vector(1 downto 0);
	signal negative, end_of_op_sig, parse_ready_sig, read_next_n_o_sig : std_logic;
 	signal error_number : std_logic_vector(1 downto 0) := "00";


	signal bcd_buf_sig			:	unsigned(39 downto 0);
	signal decode_ready_sig			:	std_logic := '0';

	signal 		operator_top		:	std_logic_vector(1 downto 0);
	signal		need_input_top		:	std_logic;
	signal		operation_end_top	:	std_logic;
	signal		error_parser_top	:	std_logic;
	signal		error_calc_top		:	std_logic;
	signal		calc_ready_top		:	std_logic;
	signal		sign_bcd_top		:	std_logic;



begin  -- behav

 
	sys_res_n_debounce_inst : debounce
	generic map
	(
		CLK_FREQ => CLK_FREQ,
		TIMEOUT => TIMEOUT,
		RESET_VALUE => RES_N_DEFAULT_VALUE,
		SYNC_STAGES => SYNC_STAGES
	)
	port map
	(
		sys_clk => sys_clk,
		sys_res_n => '1',
		data_in => sys_res_n,
		data_out => sys_res_n_sync
	);

	btn_a_debounce_inst : debounce
	generic map
	(
		CLK_FREQ => CLK_FREQ,
		TIMEOUT => TIMEOUT,
		RESET_VALUE => BTN_A_RESET_VALUE,
		SYNC_STAGES => SYNC_STAGES
	)
	
	port map
	(
		sys_clk => sys_clk,
		sys_res_n => sys_res_n_sync,
		data_in => btn_a,
		data_out => btn_a_sync
	);

	pll_wrapper_inst : pll_wrapper
	port map
	(
		pll_clk => pll_clk_sig,
		sys_clk => sys_clk
	);

	vga_modul_inst : textmode_vga 
	generic map
	(
		SYNC_STAGES => SYNC_STAGES,
		VGA_CLK_FREQ => 25000000,
		BLINK_INTERVAL_MS => 1000
	)
	port map
	(
		sys_clk => sys_clk,
		sys_res_n => sys_res_n_sync,
		command => command_sig,
		command_data => command_data_sig,
		free => vga_free_sig,
		vga_clk => pll_clk_sig,
		vga_res_n => sys_res_n_sync,
		vsync_n => vga_vsync_n,
		hsync_n => vga_hsync_n,
--		r(RED_BITS - 1 downto 0) => r_sig(RED_BITS - 1 downto 0),
		r(0) => vga_r0,
		r(1) => vga_r1,
		r(2) => vga_r2,
		g(0) => vga_g0,
		g(1) => vga_g1,
		g(2) => vga_g2,
		b(0) => vga_b0,
		b(1) => vga_b1
	);


--	scancode_handler_inst : scancode_handler
--	generic map
--	(
--		RESET_VALUE => RES_N_DEFAULT_VALUE
--	)
--	port map
--	(
--		sys_clk => sys_clk,
--		sys_res_n => sys_res_n_sync,
--		new_data => ps2_new_data_sig,
--		data => ps2_data_sig,
--		new_ascii => new_ascii_sig,
--		ascii_sign => ascii_sign_sig
--	);

	line_buffer_ram_inst : sp_ram
	generic map
	(
		ADDR_WIDTH => LB_ADDR_WIDTH,
		DATA_WIDTH => LB_DATA_WIDTH
	)
	port map
	(
		clk		=>	sys_clk,
		data_out	=>	lb_data_out_sig,
		data_out_1	=>	main_lb_data_sig,	-- data-connection lb --> main
		address_out	=>	lb_addr_out_sig,
		address_out_1	=>	main_lb_addr_sig,	-- addr-connection lb <-- main
		address_wr	=>	lb_addr_wr_sig,
		wr		=>	lb_wr_sig,
		data_wr		=>	lb_data_wr_sig
	);

	line_buffer_inst : line_buffer
	generic map
	(
		ADDR_WIDTH => LB_ADDR_WIDTH,
		DATA_WIDTH => LB_DATA_WIDTH
	)
	port map
	(
		sys_clk => sys_clk,
		sys_res_n => sys_res_n_sync,
		vga_free => vga_free_sig,
		vga_command => command_sig,
		vga_command_data => command_data_sig,
		new_ascii_in => new_ascii_sig,
		ascii_sign_in => ascii_sign_sig,
		wr_enable => lb_wr_sig,
		lb_addr => lb_addr_wr_sig,
		lb_data => lb_data_wr_sig,
		start_calc => start_calc_sig, 
		enable => enable_lb_sig,				-- <-- main(rising edge)
		bcd_result => std_logic_vector(bcd_buf_sig)
	--	debug => debug_sig
	);

	parser_inst : parser
  generic map
	(
    RESET_VALUE => '0',
    ADDR_WIDTH => LB_ADDR_WIDTH,
    DATA_WIDTH => LB_DATA_WIDTH
  )  
	port map 
	(
		sys_clk => sys_clk,
		sys_res_n => sys_res_n_sync, 
		read_next_n_o => read_next_n_o_sig,		-- when rising edge -> parse new unit
		data_in => lb_data_out_sig, 
		addr_lb => lb_addr_out_sig,
		operand => operand_sig, 
		operator => operator_sig,
		leading_sign => negative,
		end_of_operation => end_of_op_sig,		-- last operand found - calculation ends here
		parse_ready => parse_ready_sig,			-- 1 unit(operand + operator) is ready
		error_sig => error_number
	);


	main_inst : main
	generic map
	(
		RESET_VALUE	=>	RES_N_DEFAULT_VALUE,
		ADR_WIDTH	=>	LB_ADDR_WIDTH,
		DAT_WIDTH	=>	LB_DATA_WIDTH
	)
	port map
	(
		sys_clk		=>	sys_clk,
		sys_res_n	=>	sys_res_n_sync,
		sense		=>	btn_a_sync,
		uart_main_rx	=>	uart_top_rx_sig,
		uart_main_tx	=>	uart_top_tx_sig,
		start_calc	=>	start_calc_sig,
		lb_addr		=>	main_lb_addr_sig,
		lb_data		=>	main_lb_data_sig,
		decode_ready_main	=>	decode_ready_sig,
		lb_enable	=>	enable_lb_sig,
		bcd_buf		=>	bcd_buf_sig,
		sign_bcd_main	=>	sign_bcd_top,
		error_parser	=>	error_parser_top,
		error_calc	=>	error_calc_top
	);

	calc_inst : calc
	generic map
	(
		OPERAND_MAX	=>	OPERAND_MAX,
		OPERAND_MIN	=>	OPERAND_MIN,	
		RESULT_MAX	=>	RESULT_MAX,
		RESULT_MIN	=>	RESULT_MIN
	)
	port map
	(
		sys_clk			=>	sys_clk,
		sys_res_n		=>	sys_res_n,
		parse_ready		=>	parse_ready_sig,	-- IN:	new unit(operand + operator) is ready to be read
		start_calc		=>	start_calc_sig,
		operation_end		=>	end_of_op_sig,
		operand			=>	operand_sig,
		operator		=>	operator_sig,
		need_input		=>	read_next_n_o_sig,	-- OUT: triggers new parse 
		error_parser		=>	error_parser_top,
		error_calc		=>	error_calc_top,
		decode_ready_calc	=>	decode_ready_sig,
		bcd_buf			=>	bcd_buf_sig,
		sign_bcd_calc		=>	sign_bcd_top
	);	



  process
  begin  -- process
    sys_clk <= '0';
    wait for QUARTZ_PERIOD / 2;
    sys_clk <= '1';
    wait for QUARTZ_PERIOD / 2;
  end process;

	process
	begin
		pll_clk_sig <= '0';
		wait for QUARTZ_PLL_PERIOD / 2;
		pll_clk_sig <= '1';
		wait for QUARTZ_PLL_PERIOD / 2;
	end process;


	process
--		variable i, j :  integer range 1 to 80 := 1;
		variable c : character := ' ';

  begin

    reset <= '0';
    wait for 10 ns;
    reset <= '1';
    wait for 5 us;

    
		-- wait until clearscreen is ready
		wait for 9 us;


		--simulate scancode handler and vga
--		test_string <= "123456789_123456789_123456789_123456789_123456789_123456789_123456789_1";
			test_string <= "6+1=                                                                   ";
		wait for 200 ns;
		while c /= '=' loop
			-- convert chars from string into scancodehandler output
			if index <= 71 then
				c := test_string(index);
				index <= (index + 1);
--			ascii_sign_sig <=  scancode_ascii_sign_sig(c); -- scancode handler simulation function
				case c is
					when '1' =>
						ascii_sign_sig <= x"31";
					when '2' =>
						ascii_sign_sig <= x"32";
					when '3' =>
						ascii_sign_sig <= x"33";
					when '4' =>
						ascii_sign_sig <= x"34";
					when '5' =>
						ascii_sign_sig <= x"35";
					when '6' =>
						ascii_sign_sig <= x"36";
					when '7' =>
						ascii_sign_sig <= x"37";
					when '8' =>
						ascii_sign_sig <= x"38";
					when '9' =>
						ascii_sign_sig <= x"39";
					when '0' =>
						ascii_sign_sig <= x"30";
					when '+' =>
						ascii_sign_sig <= x"2B";
					when '-' =>
						ascii_sign_sig <= x"2D";
					when '*' =>
						ascii_sign_sig <= x"2A";
					when '/' =>
						ascii_sign_sig <= x"2F";
					when '=' =>
						ascii_sign_sig <= x"03";
					when others =>
						ascii_sign_sig <= x"20";
				end case;
				wait for 20 ns;
				new_ascii_sig <= '1';
				wait for QUARTZ_PERIOD; -- new_ascii_sig is '1' for one clk period 
				new_ascii_sig <= '0';
				-- simulate wait until next button pressed	
				wait for 20 us;
			end if;
		end loop;
    wait;
  end process;


end architecture sim;



