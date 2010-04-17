library ieee;
use ieee.std_logic_1164.all;
use work.debounce_pkg.all;
use work.sync_pkg.all;
use work.led_pkg.all;
use work.textmode_vga_platform_dependent_pkg.all;
use work.textmode_vga_component_pkg.all;


architecture struct of calculator_top is
	constant CLK_FREQ : integer := 33330000;
	constant TIMEOUT : time := 1 ms;
	constant RES_N_DEFAULT_VALUE : std_logic := '1';
	constant SYNC_STAGES : integer := 2;
	constant BTN_A_RESET_VALUE : std_logic := '1';

	signal sys_res_n_sync, btn_a_sync : std_logic;


begin
	inclk0_sig <= sys_clk;


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

  led_inst_a : led
    generic map
    (
      RESET_VALUE => BTN_A_RESET_VALUE
    )
    port map
    (
      sys_clk => sys_clk,
      sys_res_n => sys_res_n_sync,
      sense => btn_a_sync,
			led_on_off => led_a
	);
	led_inst_b : led
    generic map
    (
      RESET_VALUE => BTN_A_RESET_VALUE
    )
    port map
    (
      sys_clk => sys_clk,
      sys_res_n => sys_res_n_sync,
      sense => btn_a_sync,
			led_on_off => led_b
		);
	vga_modul_inst : textmode_vga 
    generic map
    (
      SYNC_STAGES => SYNC_STAGES
    )
    port map
    (
      sys_clk => sys_clk,
			sys_res_n => sys_res_n_sync,
      command : in std_logic_vector(COMMAND_SIZE - 1 downto 0);
      command_data : in std_logic_vector(3 * COLOR_SIZE + CHAR_SIZE - 1 downto 0);
      free : out std_logic;
      vga_clk <= c0_sig; 
			vga_res_n => sys_res_n_sync;    
      vsync_n : out std_logic;
      hsync_n : out std_logic;
      r : out std_logic_vector(RED_BITS - 1 downto 0);
      g : out std_logic_vector(GREEN_BITS - 1 downto 0);
      b : out std_logic_vector(BLUE_BITS - 1 downto 0)
    );



end architecture struct;
