library ieee;
use ieee.std_logic_1164.all;

package parser_pkg is

component parser is
	generic
  (
    RESET_VALUE : std_logic;
		ADDR_WIDTH : integer range 1 to integer'high;
    DATA_WIDTH : integer range 1 to integer'high

  );
  port
  (
    sys_clk : in std_logic;
    sys_res_n : in std_logic;
		read_next_n_o : in std_logic;
		data_in : in std_logic_vector(DATA_WIDTH - 1 downto 0);
		addr_lb : out std_logic_vector(ADDR_WIDTH - 1 downto 0);
		operand : out std_logic_vector(31 downto 0);
		operator : out std_logic_vector(1 downto 0);
		end_of_operation : out std_logic;
		parse_ready : out std_logic
		
	);
end component parser;

end package parser_pkg;
