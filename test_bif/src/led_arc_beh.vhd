library ieee;
use ieee.std_logic_1164.all;

architecture beh of led is
  signal sense_old, sense_old_next : std_logic;
	signal led_next, led_old : std_logic;
begin
	led_on_off <= led_old;

  process(sys_clk, sys_res_n)
  begin
    if sys_res_n = '0' then
      led_old <= '0';
      sense_old <= RESET_VALUE;
    elsif rising_edge(sys_clk) then
      led_old <= led_next;
      sense_old <= sense_old_next;
    end if;
  end process;
  
  process(sense, sense_old, led_old)
  begin
    sense_old_next <= sense;
		led_next <= led_old;

    if sense_old /= sense and sense = '0' then	--sense = '0' ... weil button low aktiv
			if led_old /= '1' then
				led_next <= '1';
			elsif led_old /= '0' then
				led_next <= '0';
			end if;
    end if;
  end process;
end architecture beh;
