library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.textmode_vga_pkg.all;


package line_buffer_pkg is
	component line_buffer is
  	port
  	(
			sys_clk : in std_logic;
			sys_res_n : in std_logic;
			lb_addr : out std_logic_vector(6 downto 0);
     	lb_data : out std_logic_vector(7 downto 0);
     	wr_enable : out std_logic;
			vga_free : in std_logic;
			vga_command : out std_logic_vector(COMMAND_SIZE - 1 downto 0);
 		 	vga_command_data : out std_logic_vector(3 * COLOR_SIZE + CHAR_SIZE - 1 downto 0);
			new_ascii_in : in std_logic;
			ascii_sign_in : in std_logic_vector(7 downto 0)
--			start_clac : out std_logic
		);
	end component line_buffer;
end package line_buffer_pkg;

