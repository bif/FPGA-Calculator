library ieee;
use ieee.std_logic_1164.all;

package pll_wrapper_pkg is
	component pll is
		port
		(
			inclk0 : in std_logic;
			c0 : out std_logic	
		);
	end component pll;

	component pll_wrapper is 
    port
    (
      sys_clk : in std_logic;
      pll_clk : out std_logic
    );
  end component pll_wrapper;
end package pll_wrapper_pkg;
