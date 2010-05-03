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
	uart_tx : out  std_logic;
	uart_rx : in  std_logic
    );
  end component calculator_top;
  
  signal sys_clk, sys_res_n : std_logic;
  signal btn_a : std_logic;
  signal uart_rx : std_logic;
  signal stop : boolean := false;
begin
  uut : calculator_top
    port map
    (
      sys_clk => sys_clk,
      sys_res_n => sys_res_n,
      btn_a => btn_a,
	uart_rx => uart_rx
    );
    
  process
  begin
    sys_clk <= '0';
    wait for 15 ns;
    sys_clk <= '1';
  --  if stop = true then
  --    wait;
  --  end if;
    wait for 15 ns;
  end process;
  
  process
  begin
    sys_res_n <= '0';
    btn_a <= '0';
    uart_rx <= '1';
    wait for 100 ns;
    sys_res_n <= '1';	-- RESET END
    wait for 1 ms;
    btn_a <= '0';	-- btn_a = Log 0
    wait for 100 ns;
    btn_a <= '1';	-- btn_a --> HIGH
    wait for 3 ms;
    btn_a <= '0';
    wait for 2 ms;			-- byte: 01010101
	uart_rx <= '0';	-- startbit
    wait for 8730 ns;
	uart_rx <= '1';	-- data0
    wait for 8730 ns;
	uart_rx <= '0'; -- data1
    wait for 8730 ns;
	uart_rx <= '1'; -- data2
    wait for 8730 ns;
	uart_rx <= '0'; -- data3
    wait for 8730 ns;
	uart_rx <= '1'; --data4
    wait for 8730 ns;
	uart_rx <= '0'; --data5
    wait for 8730 ns;
	uart_rx <= '1'; --data6
    wait for 8730 ns;
	uart_rx <= '0'; --data7
    wait for 8730 ns;
	uart_rx <= '0'; --stopbit
    wait for 8730 ns;
	uart_rx <= '1'; --idle
    stop <= true;
    wait;
  end process;
end architecture sim;
