library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package parser_pkg is

component parser is
	generic
  (
    RESET_VALUE : std_logic;
		ADDR_WIDTH : integer range 1 to integer'high;
    DATA_WIDTH : integer range 1 to integer'high; 
		OPERAND_MAX : signed(62 downto 0);
		OPERAND_MIN : signed(62 downto 0)
  );
  port
  (
    sys_clk : in std_logic;
    sys_res_n : in std_logic;
		read_next_n_o : in std_logic;
		data_in : in std_logic_vector(DATA_WIDTH - 1 downto 0);
		addr_lb : out std_logic_vector(ADDR_WIDTH - 1 downto 0);
		operand		:	out	signed(31 downto 0);
		operator : out std_logic_vector(1 downto 0);
		leading_sign : out std_logic;
		end_of_operation : out std_logic;
		parse_ready : out std_logic;
		-- error_sig = 000 ... no error
		-- error_sig = 001 ... dedection of leading sign failed, '/' or '*' were dedected
		-- error_sig = 010 ... spaces between two signs of the operand were dedected
		-- error_sig = 011 ... dedecation of leading sign was correct but operator follwoed (next sign after leading sign must be a number) 
		-- error_sig = 100 ... input operand to tall => overflow
		error_sig : out std_logic_vector(2 downto 0)	
	);
end component parser;

end package parser_pkg;
