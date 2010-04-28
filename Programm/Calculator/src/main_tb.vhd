library ieee;
use ieee.std_logic_1164.all;

entity main_tb is
end entity main_tb;

architecture sim of main_tb is
  component calculator_top is
    port
    (
	sys_clk : in std_logic;
	sys_res_n : in std_logic;
	btn_a : in std_logic;
	vga_r0 : out std_logic;
	vga_r1 : out std_logic;
	vga_r2 : out std_logic;
	vga_g0 : out std_logic;
	vga_g1 : out std_logic;
	vga_g2 : out std_logic;
	vga_b0 : out std_logic;
	vga_b1 : out std_logic;
	vga_hsync_n : out std_logic;
	vga_vsync_n : out std_logic;
	ps2_clk : inout std_logic;
	ps2_data : inout std_logic;
	uart_txd : out  std_logic
    );
  end component calculator_top;
  
  signal sys_clk, sys_res_n : std_logic;
  signal btn_a : std_logic;
  signal stop : boolean := false;
begin
  uut : calculator_top
    port map
    (
      sys_clk => sys_clk,
      sys_res_n => sys_res_n,
      btn_a => btn_a
    );
    
  process
  begin
    sys_clk <= '0';
    wait for 15 ns;
    sys_clk <= '1';
    if stop = true then
      wait;
    end if;
    wait for 15 ns;
  end process;
  
  process
  begin
    sys_res_n <= '0';
    btn_a <= '0';
    wait for 10 us;
    sys_res_n <= '1';
    wait for 2 ms;
    btn_a <= '0';
    wait for 100 ns;
    btn_a <= '1';
    wait for 50 us;
    btn_a <= '0';
    wait for 150 us;
    btn_a <= '1';
    wait for 25 us;
    btn_a <= '0';
    wait for 175 us;
    btn_a <= '1';
    wait for 1 us;
    btn_a <= '0';
    wait for 2 ms;
    btn_a <= '1';
    wait for 100 us;
    btn_a <= '0';
    wait for 50 us;
    btn_a <= '1';
    wait for 150 us;
    btn_a <= '0';
    wait for 25 us;
    btn_a <= '1';
    wait for 175 us;
    btn_a <= '0';
    wait for 1 us;
    btn_a <= '1';
    wait for 2 ms;
    btn_a <= '0';
    wait for 100 us;
    btn_a <= '1';
    wait for 50 us;
    btn_a <= '0';
    wait for 150 us;
    btn_a <= '1';
    wait for 25 us;
    btn_a <= '0';
    wait for 175 us;
    btn_a <= '1';
    wait for 1 us;
    btn_a <= '0';
    wait for 2 ms;
    stop <= true;
    wait;
  end process;
end architecture sim;
