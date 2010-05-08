library ieee;
use ieee.std_logic_1164.all;
use work.parser_pkg.all;

architecture beh of parser is
  type SC_H_FSM_STATE_TYPE is
    (READY, ERROR_STATE, CHECK_UNSIGNED, READ_BUFFER);

  signal parser_fsm_state, parser_fsm_state_next : SC_H_FSM_STATE_TYPE;
	signal error_sig : std_logic;
	signal line_count, line_count_next, start_pos : std_logic_vector(ADDR_WIDTH - 1 downto 0);
	signal data : std_logic_vector(DATA_WIDTH - 1 downto 0);


begin

  next_state : process(parser_fsm_state, read_next_n_o, check_unsigned_ready)
  begin
    parser_fsm_state_next <= parser_fsm_state;
		error_sig <= '0';
		check_unsigned_ready_next <= check_unsigned_ready;
		line_count_next <= line_count;

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
  end process next_state;

  output : process(parser_fsm_state)
  begin
		
		case parser_fsm_state is
			when READY =>
				start_pos <= line_count;
			when CHECK_UNSIGNED =>
				
				
			when ERROR_STATE =>

			when READ_BUFFER =>

				while data 
		end case;


   end process output;

  assert RESET_VALUE = '0' or RESET_VALUE = '1' report
    "RESET_VALUE may only be 0 or 1!" severity failure;

  sync : process(sys_clk, sys_res_n)
  begin
    if sys_res_n = '0' then
      parser_fsm_state <= READY;
			line_count <= (other => '0');
		elsif rising_edge(sys_clk) then
			parser_fsm_state <= parser_fsm_state_next;
			error_sig <= error_sig_next;
			check_unsigned_ready <= check_unsigned_ready_next;
			data <= data_in;
			addr_lb <= line_count;
			line_count <= line_count_next;
		end if;
  end process sync;
end architecture beh;
