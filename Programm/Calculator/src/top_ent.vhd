library ieee;
use ieee.std_logic_1164.all;

entity calculator_top is
	port
	(
		sys_clk : in std_logic;
		sys_res_n : in std_logic;
		btn_a: in std_logic;
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
		uart_rx : in  std_logic;
    seg_a : out std_logic_vector(6 downto 0);
    seg_b : out std_logic_vector(6 downto 0)
 
	);
end entity calculator_top;
