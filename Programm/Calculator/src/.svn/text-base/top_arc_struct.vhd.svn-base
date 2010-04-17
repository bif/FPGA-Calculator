library ieee;
use ieee.std_logic_1164.all;
use work.debounce_pkg.all;
use work.sync_pkg.all;
use work.led_pkg.all;

architecture struct of calculator_top is
	constant CLK_FREQ : integer := 33330000;
	constant TIMEOUT : time := 1 ms;
	constant RES_N_DEFAULT_VALUE : std_logic := '1';
	constant SYNC_STAGES : integer := 2;
	constant BTN_A_RESET_VALUE : std_logic := '1';

	signal sys_res_n_sync, btn_a_sync : std_logic;


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

end architecture struct;
