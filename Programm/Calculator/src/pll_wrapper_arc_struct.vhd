library ieee;
use ieee.std_logic_1164.all;
use work.pll_wrapper_pkg.all;

architecture struct of pll_wrapper is
	signal pll_clk_sig, sys_clk_sig : std_logic;


begin

	pll_inst : pll 
	port map	
	(
		inclk0 <= sys_clk_sig,	-- in
		c0 => pll_clk_sig		-- out
	);

	pll_wrapper_inst : pll_wrapper
	port map
	(
		sys_clk <= sys_clk_sig,
		pll_clk => pll_clk_sig
	);

end architecture struct;	

