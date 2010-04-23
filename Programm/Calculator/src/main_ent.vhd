library ieee;
use ieee.std_logic_1164.all;

entity main is
  generic
  (
    RESET_VALUE : std_logic;
		COMMAND_SIZE : integer;
		COLOR_SIZE : integer;
		CHAR_SIZE : integer
  );
  port
  (
    sys_clk : in std_logic;
    sys_res_n : in std_logic;
    sense : in std_logic;
		vga_free : in std_logic;
		vga_command : out std_logic_vector(COMMAND_SIZE - 1 downto 0);
  	vga_command_data : out std_logic_vector(3 * COLOR_SIZE + CHAR_SIZE - 1 downto 0);
		new_ascii_in : in std_logic;
		ascii_sign_in : in std_logic_vector(7 downto 0)
	);
end entity main;
