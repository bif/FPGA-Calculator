library ieee;
use ieee.std_logic_1164.all;
use work.math_pkg.all;

package debounce_pkg is
  component debounce_fsm is
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
  end component debounce_fsm;

  component counter is
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
  end component counter;

  component debounce is
    generic
    (
      CLK_FREQ    : integer;
      TIMEOUT     : time range 100 us to 100 ms := 1 ms;
      RESET_VALUE : std_logic := '0';
      SYNC_STAGES : integer range 2 to integer'high
    );
    port
    (
      sys_clk : in std_logic;
      sys_res_n : in std_logic;

      data_in : in std_logic;
      data_out : out std_logic
    );
  end component debounce;
end package debounce_pkg;