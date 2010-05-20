library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.parser_pkg.all;

architecture beh of parser is
  type SC_H_FSM_STATE_TYPE is
    (READY, ERROR_STATE, CHECK_UNSIGNED, CHECK_OPERAND, CONVERT_TO_INT);

  signal parser_fsm_state, parser_fsm_state_next : SC_H_FSM_STATE_TYPE;
	signal error_sig, error_sig_next : std_logic;
	signal convert_count, convert_count_next, line_count, line_count_next, start_pos, start_pos_next, end_pos, end_pos_next : std_logic_vector(ADDR_WIDTH - 1 downto 0);
	signal data : std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal operator_next : std_logic_vector(1 downto 0);
	signal operand_next, last_operand : std_logic_vector(31 downto 0);
	signal once, once_next, space, space_next, leading_sign, leading_sign_next, end_of_op_next, parse_ready_next, state_ready, state_ready_next : std_logic;

begin

  next_state : process(parser_fsm_state, read_next_n_o, error_sig, state_ready)
  begin
    parser_fsm_state_next <= parser_fsm_state;


    case parser_fsm_state is
			when READY =>
				if read_next_n_o = '1' then
					parser_fsm_state_next <= CHECK_UNSIGNED;
				end if;
			when CHECK_UNSIGNED =>
				if error_sig = '0' then
					parser_fsm_state_next <= CHECK_OPERAND;
				elsif error_sig = '1' then
					parser_fsm_state_next <= ERROR_STATE;
				end if;
			when ERROR_STATE =>
--TODO:
				null;	
			when CHECK_OPERAND =>
				if state_ready = '1' and error_sig = '0' then
					parser_fsm_state_next <= CONVERT_TO_INT;
				elsif error_sig = '1' then
					parser_fsm_state_next <= ERROR_STATE;
				end if;
			when CONVERT_TO_INT =>
				if state_ready = '1' then
					parser_fsm_state_next <= READY;
				end if;
		end case;
  end process next_state;



	output : process(parser_fsm_state, data, once, space, line_count, leading_sign, state_ready, start_pos, error_sig, convert_count, last_operand)

--	variable i : unsigned range 1000000000 to 0 := 0;

  begin
		leading_sign_next <= leading_sign;
		start_pos_next <= start_pos;
		once_next <= once;
		error_sig_next <= '0';
		line_count_next <= line_count;
		parse_ready_next <= '0';
		space_next <= space;
		state_ready_next <= '0';
		operator_next <= "00";
		end_of_op_next <= '0';
		convert_count_next <= convert_count;
		operand_next <= last_operand;

		case parser_fsm_state is
			when READY =>
				if state_ready = '1' then
					state_ready_next <= '0';
				end if;
				start_pos_next <= line_count;

			when CHECK_UNSIGNED =>
				case data(7 downto 0) is
					when x"2D" =>
						-- "-"
						leading_sign_next <= '1';
						line_count_next <= std_logic_vector(unsigned(line_count) + 1);
						start_pos_next <= line_count;

					when x"2B" =>
						-- "+"
						leading_sign_next <= '0';
						line_count_next <= std_logic_vector(unsigned(line_count) + 1);
						start_pos_next <= line_count;

					when x"30" | x"31" | x"32" | x"33" | x"34" | x"35" | x"36" | x"37" | x"38" | x"39" =>
						-- "0 ... 9"
						leading_sign_next <= '0';
				
					when others =>
						error_sig_next <= '1';
			
				end case;	

			when CHECK_OPERAND =>			
				--erstes Zeichen muss eine Ziffer sein sonst Fehler
				if once = '0' then
					case data(7 downto 0) is
						when x"30" | x"31" | x"32" | x"33" | x"34" | x"35" | x"36" | x"37" | x"38" | x"39" =>
							null;
						when others =>
							error_sig_next <= '1';
					end case;
					once_next <= '1';
					line_count_next <= std_logic_vector(unsigned(line_count) + 1);
				elsif error_sig = '0' then	
					case data(7 downto 0) is
						when x"2B" =>
							-- next operator = '+' located 
							if line_count >= x"45" then
								error_sig_next <= '1';
							else
								operator_next <= "00";	
								if space = '0' then
									-- calc length of operand
									convert_count_next <= std_logic_vector((unsigned(line_count) - 1) - unsigned(start_pos));
								end if; 
								state_ready_next <= '1';
							end if; 
							line_count_next <= std_logic_vector(unsigned(line_count) + 1);

						when x"2D" =>
							-- next operator = '-'located 
							if line_count >= x"45" then
								error_sig_next <= '1';
							else
								operator_next <= "01";	
								if space = '0' then
									-- calc length of operand
									convert_count_next <= std_logic_vector((unsigned(line_count) - 1) - unsigned(start_pos));
								end if;  
								state_ready_next <= '1';
							end if; 
							line_count_next <= std_logic_vector(unsigned(line_count) + 1);

						when x"2A" =>
							-- next operator = '*' located 
							if line_count >= x"45" then
								error_sig_next <= '1';
							else
								operator_next <= "10";	
								if space = '0' then
									-- calc length of operand
									convert_count_next <= std_logic_vector((unsigned(line_count) - 1) - unsigned(start_pos));
								end if;  
								state_ready_next <= '1';
							end if; 
							line_count_next <= std_logic_vector(unsigned(line_count) + 1);

						when x"2F" =>
							-- next operator = '/' located 
							if line_count >= x"45" then
								error_sig_next <= '1';
							else
								operator_next <= "11";	
								if space = '0' then
									-- calc length of operand
									convert_count_next <= std_logic_vector((unsigned(line_count) - 1) - unsigned(start_pos));
								end if;  
								state_ready_next <= '1';
							end if; 
							line_count_next <= std_logic_vector(unsigned(line_count) + 1);

						when x"20" =>
							-- space located 
							if line_count >= x"45" then
								-- end off buffer, last value still not converted
								end_of_op_next <= '1';
								state_ready_next <= '1';
							elsif space = '0' then	
								-- calc length of operand
								convert_count_next <= std_logic_vector((unsigned(line_count) - 1) - unsigned(start_pos));
							end if;
							space_next <= '1'; 
							line_count_next <= std_logic_vector(unsigned(line_count) + 1);

						when others =>
							if space = '1' then
								error_sig_next <= '1';
							elsif line_count >= x"45" then
								-- end of buffer, last value still not converted
								end_of_op_next <= '1';
								state_ready_next <= '1';
								-- calc length of operand
								convert_count_next <= std_logic_vector(unsigned(line_count) - unsigned(start_pos));
							end if;
							line_count_next <= std_logic_vector(unsigned(line_count) + 1);
				
					end case;
				end if;
			when CONVERT_TO_INT =>
				if state_ready = '1' then
					state_ready_next <= '0';
				end if;
				-- Start of Operand = start_pos, End of Operand = end_pos
--TODO
--					i := (10 * unsigned(convert_count));
					convert_count_next <= std_logic_vector(unsigned(convert_count) - 1);
					start_pos_next <= std_logic_vector(unsigned(start_pos) + 1);
					if unsigned(convert_count) >= 10 then
									case data(7 downto 0) is							
										when x"31" =>
											operand_next <= std_logic_vector(unsigned(last_operand) + unsigned(convert_count));

										when x"32" =>
											operand_next <= std_logic_vector(unsigned(last_operand) + (unsigned(convert_count) * 20));

										when x"33" => 
											operand_next <= std_logic_vector(unsigned(last_operand) + (unsigned(convert_count) * 30));

										when x"34" => 
											operand_next <= std_logic_vector(unsigned(last_operand) + (unsigned(convert_count) * 40));

										when x"35" => 
											operand_next <= std_logic_vector(unsigned(last_operand) + (unsigned(convert_count) * 50));

										when x"36" => 
											operand_next <= std_logic_vector(unsigned(last_operand) + (unsigned(convert_count) * 60));

										when x"37" => 
											operand_next <= std_logic_vector(unsigned(last_operand) + (unsigned(convert_count) * 70));

										when x"38" => 
											operand_next <= std_logic_vector(unsigned(last_operand) + (unsigned(convert_count) * 80));

										when x"39" => 
											operand_next <= std_logic_vector(unsigned(last_operand) + (unsigned(convert_count) * 90));

										when others =>
											null;
									end case;
						elsif unsigned(convert_count) = 0 then
									case data(7 downto 0) is							
										when x"31" =>
											operand_next <= std_logic_vector(unsigned(last_operand) + 1);

										when x"32" =>
											operand_next <= std_logic_vector(unsigned(last_operand) + 2);

										when x"33" => 
											operand_next <= std_logic_vector(unsigned(last_operand) + 3);

										when x"34" => 
											operand_next <= std_logic_vector(unsigned(last_operand) + 4);

										when x"35" => 
											operand_next <= std_logic_vector(unsigned(last_operand) + 5);

										when x"36" => 
											operand_next <= std_logic_vector(unsigned(last_operand) + 6);

										when x"37" => 
											operand_next <= std_logic_vector(unsigned(last_operand) + 7);

										when x"38" => 
											operand_next <= std_logic_vector(unsigned(last_operand) + 8);

										when x"39" => 
											operand_next <= std_logic_vector(unsigned(last_operand) + 9);

										when others =>
											null;
									end case;
						state_ready_next <= '1';
					end if;
			when ERROR_STATE =>
			--TODO:						
				null;

		end case;


   end process output;

  assert RESET_VALUE = '0' or RESET_VALUE = '1' report
    "RESET_VALUE may only be 0 or 1!" severity failure;

  sync : process(sys_clk, sys_res_n, parser_fsm_state)
  begin
    if sys_res_n = '0' then
      parser_fsm_state <= READY;
			line_count <= (others => '0');
			space <= '0';
			last_operand <= x"00000000";
		elsif (sys_clk'event and sys_clk = '1') then
			space <= space_next;
			parser_fsm_state <= parser_fsm_state_next;
			error_sig <= error_sig_next;
			once <= once_next;
			data <= data_in;
			line_count <= line_count_next;
			case parser_fsm_state is
				when CONVERT_TO_INT =>
					addr_lb <= start_pos;
				when others =>
					addr_lb <= line_count;
			end case;
			end_of_operation <= end_of_op_next;
			parse_ready <= parse_ready_next;
			operator <= operator_next;
			operand <= operand_next;	
			last_operand <= operand_next;
			state_ready <= state_ready_next;
			leading_sign <= leading_sign_next;
			start_pos <= start_pos_next;
			convert_count <= convert_count_next;
		end if;
  end process sync;
end architecture beh;
