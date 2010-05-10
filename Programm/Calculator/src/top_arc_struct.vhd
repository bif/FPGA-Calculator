library ieee;
use ieee.std_logic_1164.all;
use work.debounce_pkg.all;
use work.sync_pkg.all;
use work.textmode_vga_platform_dependent_pkg.all;
use work.textmode_vga_component_pkg.all;
use work.pll_wrapper_pkg.all;
use work.ps2_keyboard_controller_pkg.all;
use work.scancode_handler_pkg.all;
use work.line_buffer_pkg.all;
use work.sp_ram_pkg.all;

architecture struct of calculator_top is
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
	
	signal sys_res_n_sync, btn_a_sync, vga_free_sig, pll_clk_sig : std_logic;
	signal command_sig : std_logic_vector(COMMAND_SIZE - 1 downto 0);
	signal command_data_sig : std_logic_vector(3 * COLOR_SIZE + CHAR_SIZE - 1 downto 0);
	signal ps2_data_sig, ps2_data_conect, ascii_sign_sig : std_logic_vector(7 downto 0);
	signal ps2_new_data_sig, new_ascii_sig : std_logic;
	signal uart_top_tx_sig	: std_logic;
	signal uart_top_rx_sig	: std_logic;

	signal lb_addr_sig : std_logic_vector(LB_ADDR_WIDTH - 1 downto 0);
	signal lb_data_in_sig, lb_data_out_sig : std_logic_vector(LB_DATA_WIDTH - 1  downto 0);
	signal lb_wr_sig, enable_lb_sig, start_calc_sig : std_logic;
	signal operand_sig std_logic_vector(31 downto 0);
	signal operator_sig : std_logic_vector(2 downto 0);
	signal end_of_op_sig : out std_logic;
	signal parse_ready_sig : out std_logic

component main is
	generic
(
		RESET_VALUE : std_logic
	);
	port
	(
		sys_clk : in std_logic;
		sys_res_n : in std_logic;
		sense : in std_logic;
		uart_main_tx    : out   std_logic;
		uart_main_rx    : in    std_logic;
		trigger_main_tx	: out    std_logic
	);

end component main;


  function to_seg(value : in std_logic_vector(3 downto 0)) return std_logic_vector is
  begin
    case value is
      when x"0" => return "1000000";
      when x"1" => return "1111001";
      when x"2" => return "0100100";
      when x"3" => return "0110000";
      when x"4" => return "0011001";
      when x"5" => return "0010010";
      when x"6" => return "0000010";
      when x"7" => return "1111000";
      when x"8" => return "0000000";
      when x"9" => return "0010000";
      when x"A" => return "0001000";
      when x"B" => return "0000011";
      when x"C" => return "1000110";
      when x"D" => return "0100001";
      when x"E" => return "0000110";
      when x"F" => return "0001110";
      when others => return "1111111";
    end case;
  end function;  



begin

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

	ps2_inst : ps2_keyboard_controller
	generic map
	(
		CLK_FREQ => CLK_FREQ,
		SYNC_STAGES => SYNC_STAGES
	)
	port map
	(
		sys_clk => sys_clk,
		sys_res_n => sys_res_n_sync,
		ps2_clk => ps2_clk,
		ps2_data => ps2_data,
		new_data => ps2_new_data_sig,
		data => ps2_data_sig
	);

	scancode_handler_inst : scancode_handler
	generic map
	(
		RESET_VALUE => RES_N_DEFAULT_VALUE
	)
	port map
	(
		sys_clk => sys_clk,
		sys_res_n => sys_res_n_sync,
		new_data => ps2_new_data_sig,
		data => ps2_data_sig,
		new_ascii => new_ascii_sig,
		ascii_sign => ascii_sign_sig
	);

	line_buffer_ram_inst : sp_ram
	generic map
	(
		ADDR_WIDTH => LB_ADDR_WIDTH,
		DATA_WIDTH => LB_DATA_WIDTH
	)
	port map
	(
		clk => sys_clk,
		address => lb_addr_sig,
		data_out => lb_data_out_sig,
		wr => lb_wr_sig,
		data_in => lb_data_in_sig
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
		lb_addr => lb_addr_sig,
		lb_data => lb_data_in_sig,
		start_calc => start_calc_sig, 
		enable => enable_lb_sig
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
		read_next_n_o => read_next_n_o_sig,
		data_in => lb_data_in_sig, 
		addr_lb => lb_addr_sig,
		operand => operand_sig; 
		operator operator_sig; 
		end_of_op_sig => end_of_op_sig;
		parse_ready => parse_ready_sig
	);


	main_inst : main
	generic map
	(
		RESET_VALUE => RES_N_DEFAULT_VALUE
	)
	port map
	(
		sys_clk => sys_clk,
		sys_res_n => sys_res_n_sync,
		sense => btn_a_sync,
		uart_main_rx => uart_top_rx_sig,
		uart_main_tx => uart_top_tx_sig
	);

	uart_tx <= uart_top_tx_sig;
	uart_top_rx_sig <= uart_rx;
	enable_lb_sig <= '1';	


  seg_a <= to_seg(lb_addr_sig(3 downto 0));
  seg_b <= to_seg(lb_addr_sig(7 downto 4));


end architecture struct;
