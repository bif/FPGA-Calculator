library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

architecture beh of debounce_fsm is
  type DEBOUNCE_FSM_STATE_TYPE is
    (IDLE0, TIMEOUT0, IDLE1, TIMEOUT1);
  signal debounce_fsm_state, debounce_fsm_state_next : DEBOUNCE_FSM_STATE_TYPE;
begin
  next_state : process(debounce_fsm_state, i, cnt)
  begin
    debounce_fsm_state_next <= debounce_fsm_state;	--wenn sich nichts ändert bleibe im gleichen Zustand
    case debounce_fsm_state is
      when IDLE0 =>
        if i = '1' then
          debounce_fsm_state_next <= TIMEOUT0;
        end if;
      when TIMEOUT0 =>
        if i = '0' then
          debounce_fsm_state_next <= IDLE0;
        elsif to_integer(unsigned(cnt)) = CNT_MAX then
          debounce_fsm_state_next <= IDLE1;
        end if;
      when IDLE1 =>
        if i = '0' then
          debounce_fsm_state_next <= TIMEOUT1;
        end if;
      when TIMEOUT1 =>
        if i = '1' then
          debounce_fsm_state_next <= IDLE1;
        elsif to_integer(unsigned(cnt)) = CNT_MAX then
          debounce_fsm_state_next <= IDLE0;
        end if;
    end case;
  end process next_state;

  output : process(debounce_fsm_state)
  begin
    o <= RESET_VALUE;
    clear_cnt <= '1';

    case debounce_fsm_state is
      when IDLE0 =>
        o <= '0';
      when TIMEOUT0 =>
        o <= '0';
        clear_cnt <= '0';
      when IDLE1 =>
        o <= '1';
      when TIMEOUT1 =>
        o <= '1';
        clear_cnt <= '0';
    end case;
  end process output;

  assert RESET_VALUE = '0' or RESET_VALUE = '1' report
    "RESET_VALUE may only be 0 or 1!" severity failure;

  sync : process(sys_clk, sys_res_n)
  begin
    if sys_res_n = '0' then
      if RESET_VALUE = '0' then
        debounce_fsm_state <= IDLE0;
      else
        debounce_fsm_state <= IDLE1;
      end if;
    elsif rising_edge(sys_clk) then
      debounce_fsm_state <= debounce_fsm_state_next;
    end if;
  end process sync;
end architecture beh;
