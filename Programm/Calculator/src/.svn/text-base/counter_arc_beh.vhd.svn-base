library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.math_pkg.all;

architecture beh of counter is
  signal cnt_int, cnt_next : integer range 0 to CNT_MAX;
begin
  cnt <= std_logic_vector(to_unsigned(cnt_int, log2c(CNT_MAX)));

  process(sys_clk, sys_res_n)
  begin
    if sys_res_n = '0' then
      cnt_int <= 0;
    elsif rising_edge(sys_clk) then
      cnt_int <= cnt_next;
    end if;
  end process;

  process(cnt_int, clear_cnt)
  begin
    cnt_next <= cnt_int;

    if clear_cnt = '1' then
      cnt_next <= 0;
    elsif cnt_int < CNT_MAX then
      cnt_next <= cnt_int + 1;
    end if;
  end process;
end architecture beh;
