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

architecture struct of calculator_top is
	constant CLK_FREQ : integer := 33330000;
	constant TIMEOUT : time := 1 ms;
	constant RES_N_DEFAULT_VALUE : std_logic := '1';
	constant SYNC_STAGES : integer := 2;
	constant BTN_A_RESET_VALUE : std_logic := '1';
	constant COMMAND_SIZE : integer := 8;
	constant COLOR_SIZE : integer := 8;
	constant CHAR_SIZE : integer := 8;
	
	signal sys_res_n_sync, btn_a_sync, vga_free_sig, pll_clk_sig : std_logic;
	signal command_sig : std_logic_vector(COMMAND_SIZE - 1 downto 0);
  signal command_data_sig : std_logic_vector(3 * COLOR_SIZE + CHAR_SIZE - 1 downto 0);
	signal ps2_data_sig, ps2_data_conect, ascii_sign_sig : std_logic_vector(7 downto 0);
	signal ps2_new_data_sig, new_ascii_sig : std_logic;

--component main is
--	generic
--  (
--    RESET_VALUE : std_logic;
--		COMMAND_SIZE : integer;
--		COLOR_SIZE : integer;
--		CHAR_SIZE : integer
--  );
--  port
--  (
--    sys_clk : in std_logic;
--    sys_res_n : in std_logic;
--    sense : in std_logic;
--		vga_free : in std_logic;
--		vga_command : out std_logic_vector(COMMAND_SIZE - 1 downto 0);
--  	vga_command_data : out std_logic_vector(3 * COLOR_SIZE + CHAR_SIZE - 1 downto 0);
--		new_ascii_in : in std_logic;
--		ascii_sign_in : in std_logic_vector(7 downto 0)
--	);
--
--end component main;

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

--	btn_a_debounce_inst : debounce
--    generic map
--    (
--      CLK_FREQ => CLK_FREQ,
--      TIMEOUT => TIMEOUT,
--      RESET_VALUE => BTN_A_RESET_VALUE,
--      SYNC_STAGES => SYNC_STAGES
--    )
--    port map
--    (
--      sys_clk => sys_clk,
--      sys_res_n => sys_res_n_sync,
--      data_in => btn_a,
--      data_out => btn_a_sync
--    );

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

  line_buffer_inst : line_buffer
--    generic map
--    (
--      RESET_VALUE => RES_N_DEFAULT_VALUE,
--			COMMAND_SIZE =>	COMMAND_SIZE,
--			COLOR_SIZE => COLOR_SIZE,
--			CHAR_SIZE	=> CHAR_SIZE	
--		)
    port map
    (
      sys_clk => sys_clk,
      sys_res_n => sys_res_n_sync,
			vga_free => vga_free_sig,
			vga_command => command_sig,
			vga_command_data => command_data_sig,
			new_ascii_in => new_ascii_sig,
			ascii_sign_in => ascii_sign_sig
--			led_a => led_a
	);


end architecture struct;
