library ieee;
use ieee.std_logic_1164.all;

package scancode_handler_pkg is

component scancode_handler is
	generic
  (
    RESET_VALUE : std_logic
  );
  port
  (
    sys_clk : in std_logic;
    sys_res_n : in std_logic;
		new_data : in std_logic;
		data : in std_logic_vector(7 downto 0);
		new_ascii : out std_logic;
		ascii_sign : out std_logic_vector(7 downto 0)
	);
end component scancode_handler;

end package scancode_handler_pkg;
