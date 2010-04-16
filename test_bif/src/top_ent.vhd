library ieee;
use ieee.std_logic_1164.all;

entity calculator_top is
	port
	(
		sys_clk : in std_logic;
		sys_res_n : in std_logic;
		btn_a : in std_logic;
		led_a : out std_logic;
		led_b : out std_logic
		--seg_a : out std_logic_vector(6 downto 0);
		--:seg_b : out std_logic_vector(6 downto 0)
	);
end entity calculator_top;
