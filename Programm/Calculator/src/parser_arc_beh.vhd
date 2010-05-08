library ieee;
use ieee.std_logic_1164.all;
use work.parser_pkg.all;

architecture beh of parser is
  type SC_H_FSM_STATE_TYPE is
    (READY, ERROR_STATE, CHECK_UNSIGNED, CHECK_NUMBER, READ_BUFFER);

  signal parser_fsm_state, parser_fsm_state_next : SC_H_FSM_STATE_TYPE;
	signal error_sig : std_logic;
	signal line_count, line_count_next, start_pos : std_logic_vector(ADDR_WIDTH - 1 downto 0);
	signal data : std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal check_unsigned_ready, check_unsigned_ready_next, leading_sign : std_logic;

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
					parser_fsm_state_next <= CHECK_NUMBER;
				elsif check_unsigned_ready = '1' and error_sig = '1' then
					parser_fsm_state_next <= ERROR_STATE;
				end if;
			when ERROR_STATE =>
--TODO:
				null;	
			when CHECK_NUMBER =>
				if number_ok = '1' and error_sig = '0' then
					parser_fsm_state_next <= READ_BUFFER;
				elsif number_ok = '1' and error_sig = '1' then
					parser_fsm_state_next <= ERROR_STATE;
				end if;
			when READ_BUFFER =>
			
		end case;
  end process next_state;

  output : process(parser_fsm_state, data)
  begin
		check_unsigned_ready_next <= '0';
		leading_sign <= '0';
		number_ok <= '0';

		case parser_fsm_state is
			when READY =>
				start_pos <= line_count;
			when CHECK_UNSIGNED =>
--TODO:
				-- Signal leading_sign ist  asynchron
				-- da es aber nur im State CHECK UNSIGNED bzw wenn data
				-- sich ändert gesetzt wird und data sich erst im 
				-- state READ_BUFFER ändert, kann es zu keinem 
				-- unkontroolierten Verhalten kommen
				case data is
					when x"2D" =>
						-- "-"
						leading_sign <= '1';
						error_sig <= '0';
						check_unsigned_ready_next <= '1';
					when x"2B" =>
						-- "+"
						leading_sign <= '0';
						error_sig <= '0';
						check_unsigned_ready_next <= '1';
					when x"30" | x"31" | x"32" | x"33" | x"34" | x"35" | x"36" | x"37" | x"38" | x"39" =>
						leading_sign <= '0';
						error_sig <= '0';
						check_unsigned_ready_next <= '1';
					when others =>
						error_sig <= '1';
						check_unsigned_ready_next <= '1';
				end case;	
				line_count_next <= (line_count + '1');
			when ERROR_STATE =>
--TODO:						
				null;
			when CHECK_NUMBER =>
				case data is
					when x"30" | x"31" | x"32" | x"33" | x"34" | x"35" | x"36" | x"37" | x"38" | x"39" =>
						error_sig <= '0';
--					Zeichen speichern
						i_sign <= atoi(data);
						number_ok <= '1';
					when others =>
						error_sig <= '1';
						number_ok <= '1';
				end case;
			when READ_BUFFER =>
				case data is
					when x"30" | x"31" | x"32" | x"33" | x"34" | x"35" | x"36" | x"37" | x"38" | x"39" =>

					when 

				end case;
				i_sign <= atoi(data);
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
