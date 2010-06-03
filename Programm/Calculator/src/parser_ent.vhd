library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity parser is
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
		operand		:	out	signed(31 downto 0);
		operator : out std_logic_vector(1 downto 0);
		leading_sign : out std_logic;
		end_of_operation : out std_logic;
		parse_ready : out std_logic;
		-- error_sig = 00 ... no error
		-- error_sig = 01 ... dedection of leading sign failed, '/' or '*' were dedected
		-- error_sig = 10 ... spaces between two signs of the operand were dedected
		-- error_sig = 11 ... dedecation of leading sign was correct but operator follwoed (next sign after leading sign must be a number)
		error_sig : out std_logic_vector(1 downto 0)
	);
end entity parser;
