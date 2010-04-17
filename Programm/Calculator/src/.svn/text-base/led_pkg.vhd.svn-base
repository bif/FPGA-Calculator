library ieee;
use ieee.std_logic_1164.all;

package led_pkg is
  component led is
    generic
    (
      RESET_VALUE : std_logic
    );
    port
    (
      sys_clk : in std_logic;
      sys_res_n : in std_logic;
      sense : in std_logic;
    	led_on_off : out std_logic
		);
  end component led;
end package led_pkg;
