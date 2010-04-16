library ieee;
use ieee.std_logic_1164.all;
use work.math_pkg.all;

entity debounce_fsm is
  generic
  (
    RESET_VALUE : std_logic;
    CNT_MAX : integer range 2 to integer'high
  );
  port
  (
    sys_clk : in std_logic;
    sys_res_n : in std_logic;
    i : in std_logic;
    cnt : in std_logic_vector(log2c(CNT_MAX) - 1 downto 0);
    clear_cnt : out std_logic;
    o : out std_logic
  );
end entity debounce_fsm;
