library ieee;
use ieee.std_logic_1164.all;


entity pll_wrapper is

	port	
	(
		sys_clk : in std_logic;	
		pll_clk : out std_logic
	);

end entity pll_wrapper;	

