library ieee;
use ieee.std_logic_1164.all;
use work.math_pkg.all;

entity counter is
  generic
  (
    CNT_MAX : integer range 2 to integer'high
  );
  port
  (
    sys_clk : in std_logic;
    sys_res_n : in std_logic;
    clear_cnt : in std_logic;
    cnt : out std_logic_vector(log2c(CNT_MAX) - 1 downto 0)
  );
end entity counter;
