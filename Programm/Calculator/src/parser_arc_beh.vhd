library ieee;
use ieee.std_logic_1164.all;


architecture beh of parser is
  type SC_H_FSM_STATE_TYPE is
    (READY, ERROR_STATE, CHECK_UNSIGNED, READ_BUFFER);

  signal parser_fsm_state, parser_fsm_state_next : SC_H_FSM_STATE_TYPE;
	signal error_sig : std_logic;


begin

  next_state : process(parser_fsm_state, start, check_unsigned_ready)
  begin
    parser_fsm_state_next <= parser_fsm_state;
		error_sig <= '0';
		check_unsigned_ready_next <= check_unsigned_ready;

    case parser_fsm_state is
			when READY =>
				if start = '1' then
					parser_fsm_state_next <= CHECK_UNSIGNED;
				end if;
			when CHECK_UNSIGNED =>
				if check_unsigned_ready = '1' and error_sig = '0' then
					parser_fsm_state_next <= READ_BUFFER;
				elsif check_unsigned_ready = '1' and error_sig = '1' then
					parser_fsm_state_next <= ERROR_STATE;
				end if;
			when ERROR_STATE =>

			when READ_BUFFER =>
			
		end case;
  end process next_state;

  output : process(parser_fsm_state)
  begin
	
		case parser_fsm_state is
			when READY =>
				if read_next_n_o = '1' then
					parser_fsm_state_next <= CHECK_UNSIGNED;
				end if;
			when CHECK_UNSIGNED =>
				if check_unsigned_ready = '1' and error_sig = '0' then
					parser_fsm_state_next <= READ_BUFFER;
				elsif check_unsigned_ready = '1' and error_sig = '1' then
					parser_fsm_state_next <= ERROR_STATE;
				end if;
			when ERROR_STATE =>

			when READ_BUFFER =>
			
		end case;


   end process output;

  assert RESET_VALUE = '0' or RESET_VALUE = '1' report
    "RESET_VALUE may only be 0 or 1!" severity failure;

  sync : process(sys_clk, sys_res_n)
  begin
    if sys_res_n = '0' then
      parser_fsm_state <= READY;
    elsif rising_edge(sys_clk) then
			if read_next_n_o = '1' then
				start <= '1';
			else
				start <= '0';
			end if;
	    parser_fsm_state <= parser_fsm_state_next;
			error_sig <= error_sig_next;
			check_unsigned_ready <= check_unsigned_ready_next;
		end if;
  end process sync;
end architecture beh;
