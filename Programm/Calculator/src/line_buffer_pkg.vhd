library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.textmode_vga_pkg.all;


package line_buffer_pkg is
	component line_buffer is
--	  generic
--		(
--			RESET_VALUE : std_logic;
-- 	    ADDR_WIDTH : integer range 1 to integer‘high;
-- 	    DATA_WIDTH : integer range 1 to integer‘high
--  	);
  	port
  	(
--			led_a: out std_logic;
			sys_clk : in std_logic;
			sys_res_n : in std_logic;
--			address : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
--     	data_out : out std_logic_vector(DATA_WIDTH - 1 downto 0);
--     	wr       : in std_logic;
--	   	data_in : in std_logic_vector(DATA_WIDTH - 1 downto 0)
			vga_free : in std_logic;
			vga_command : out std_logic_vector(COMMAND_SIZE - 1 downto 0);
 		 	vga_command_data : out std_logic_vector(3 * COLOR_SIZE + CHAR_SIZE - 1 downto 0);
			new_ascii_in : in std_logic;
			ascii_sign_in : in std_logic_vector(7 downto 0)
--			start_clac : out std_logic
		);
	end component line_buffer;
end package line_buffer_pkg;

