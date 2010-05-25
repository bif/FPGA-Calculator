library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.parser_pkg.all;

architecture beh of parser is
  type SC_H_FSM_STATE_TYPE is
    (READY, ERROR_STATE, CHECK_UNSIGNED, CHECK_OPERAND, PLUS, MINUS, MUL, DIV, SPACE_BAR, NUMBER, CONVERT_TO_INT, CONVERT_POST_STATE);

  signal parser_fsm_state, parser_fsm_state_next : SC_H_FSM_STATE_TYPE;
	signal error_sig, error_sig_next : std_logic;
	signal addr_lb_next, addr_lb_old, convert_count, convert_count_next, line_count, line_count_next, start_pos, start_pos_next, end_pos, end_pos_next : std_logic_vector(ADDR_WIDTH - 1 downto 0);
	signal old_operator, operator_next : std_logic_vector(1 downto 0);
	signal operand_next, last_operand : std_logic_vector(31 downto 0);
	signal once, once_next, negative, negative_next, space, space_next, leading_sign, leading_sign_next, end_of_op_next, parse_ready_next, check_op_ready, check_op_ready_next, convert_ready, convert_ready_next : std_logic;
	
	signal debug_sig_next, debug_sig :integer := 0;

begin

  next_state : process(parser_fsm_state, data_in, read_next_n_o, error_sig, check_op_ready, convert_ready)
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
				case data_in(7 downto 0) is
					when x"2B" =>
						-- next operator = '+' located 
						parser_fsm_state_next <= PLUS;
					when x"2D" =>
						-- next operator = '-'located 
						parser_fsm_state_next <= MINUS;
					when x"2A" =>
						-- next operator = '*' located 
						parser_fsm_state_next <= MUL;
					when x"2F" =>
						-- next operator = '/' located
						parser_fsm_state_next <= DIV; 
					when x"61" =>
						parser_fsm_state_next <= SPACE_BAR;
					when others =>
						parser_fsm_state_next <= NUMBER;
				end case;
	
				if check_op_ready = '1' and error_sig = '0' then
					parser_fsm_state_next <= CONVERT_TO_INT;
				elsif error_sig = '1' then
					parser_fsm_state_next <= ERROR_STATE;
				end if;

			when PLUS => 
				parser_fsm_state_next <= CHECK_OPERAND;

			when MINUS => 
				parser_fsm_state_next <= CHECK_OPERAND;

			when MUL => 
				parser_fsm_state_next <= CHECK_OPERAND;

			when DIV => 
				parser_fsm_state_next <= CHECK_OPERAND;

			when SPACE_BAR => 
				parser_fsm_state_next <= CHECK_OPERAND;

			when NUMBER => 
				parser_fsm_state_next <= CHECK_OPERAND;

			when CONVERT_TO_INT =>
				parser_fsm_state_next <= CONVERT_POST_STATE;
			
			when CONVERT_POST_STATE =>
				if convert_ready = '1' then
					parser_fsm_state_next <= READY;
				else
					parser_fsm_state_next <= CONVERT_TO_INT;
				end if;

		end case;
  end process next_state;



	output : process(parser_fsm_state, once, data_in, space, line_count, leading_sign, check_op_ready, convert_ready, start_pos, error_sig, convert_count, last_operand)

  begin
		leading_sign_next <= leading_sign;
		start_pos_next <= start_pos;
		negative_next <= negative;
		error_sig_next <= '0';
		line_count_next <= line_count;
		parse_ready_next <= '0';
		space_next <= space;
		check_op_ready_next <= '0';
		convert_ready_next <= '0';
		operator_next <= old_operator;
		end_of_op_next <= '0';
		convert_count_next <= convert_count;
		operand_next <= last_operand;
		debug_sig_next <= debug_sig;
		once_next <= once;
		addr_lb_next <= addr_lb_old;

		case parser_fsm_state is
			when READY =>
				check_op_ready_next <= '0';
				convert_ready_next <= '0';			
debug_sig_next <= 0;

			when CHECK_UNSIGNED =>
				-- set saved operand to zero
				operand_next <= (others => '0');	
				case data_in(7 downto 0) is
					when x"2D" =>
						-- "-"
						leading_sign_next <= '1';
						negative_next <= '1';
						line_count_next <= std_logic_vector(unsigned(line_count) + 1);
						start_pos_next <= std_logic_vector(unsigned(line_count) + 1);
						addr_lb_next <= std_logic_vector(unsigned(line_count) + 1); 					

					when x"2B" =>
						-- "+"
						leading_sign_next <= '1';
						negative_next <= '0';
						line_count_next <= std_logic_vector(unsigned(line_count) + 1);
						start_pos_next <= std_logic_vector(unsigned(line_count) + 1);
						addr_lb_next <= std_logic_vector(unsigned(line_count) + 1); 	

					when x"30" | x"31" | x"32" | x"33" | x"34" | x"35" | x"36" | x"37" | x"38" | x"39" =>
						-- "0 ... 9"
						leading_sign_next <= '0';
						negative_next <= '0';
						start_pos_next <= line_count;			

					when others =>
						error_sig_next <= '1';
			
				end case;	

			when CHECK_OPERAND =>		
				if check_op_ready /= '1' then 
					addr_lb_next <= std_logic_vector(unsigned(line_count) + 1);	
					line_count_next <= std_logic_vector(unsigned(line_count) + 1);
				else
					convert_count_next <= std_logic_vector(unsigned(line_count) - 2);
					addr_lb_next <= start_pos;	
				end if;
			
			when PLUS =>
				-- next operator = '+' located 
				if (line_count >= x"46" or (unsigned(line_count) - 1)  = unsigned(start_pos)) then
						-- first sign after signed check is an operator or last sign is an operator
						error_sig_next <= '1';
				else
					operator_next <= "00";	
					if space = '0' then
						-- calc length of operand
--						convert_count_next <= std_logic_vector(unsigned(line_count) - 1);
					end if;  
					addr_lb_next <= start_pos;
					check_op_ready_next <= '1';
				end if; 

			when MINUS =>
				-- next operator = '-' located 
				if (line_count >= x"46" or (unsigned(line_count) - 1)  = unsigned(start_pos)) then
						-- first sign after signed check is an operator or last sign is an operator
						error_sig_next <= '1';
				else
					operator_next <= "01";	
					if space = '0' then
						-- calc length of operand
--						convert_count_next <= std_logic_vector(unsigned(line_count) - 1);
					end if;  
					addr_lb_next <= start_pos;
					check_op_ready_next <= '1';
				end if; 

			when MUL =>
				-- next operator = '*' located 
				if (line_count >= x"46" or (unsigned(line_count) - 1)  = unsigned(start_pos)) then
						-- first sign after signed check is an operator or last sign is an operator
						error_sig_next <= '1';
				else
					operator_next <= "10";	
					if space = '0' then
						-- calc length of operand
--						convert_count_next <= std_logic_vector(unsigned(line_count) - 1);
					end if;  
					addr_lb_next <= start_pos;
					check_op_ready_next <= '1';
				end if; 

			when DIV =>
				-- next operator = '/' located 
				if (line_count >= x"46" or (unsigned(line_count) - 1)  = unsigned(start_pos)) then
						-- first sign after signed check is an operator or last sign is an operator
						error_sig_next <= '1';
				else
					operator_next <= "11";	
					if space = '0' then
						-- calc length of operand
--						convert_count_next <= std_logic_vector(unsigned(line_count) - 1);
					end if;  
					addr_lb_next <= start_pos;
					check_op_ready_next <= '1';
				end if; 

--TODO ... zu Beginn sprich vor operanden abfangen (start_pos hinaufzählen) und wie  bei +,-,*,/ vergleichen
--TODO ... wenn lincount 0 dann Fehler beio convert count
			when SPACE_BAR =>
				-- space located 
				if line_count >= x"46" then
					-- end off buffer, last value still not converted
					end_of_op_next <= '1';
					check_op_ready_next <= '1';
				elsif space = '0' then	
					-- calc length of operand
--					convert_count_next <= std_logic_vector(unsigned(line_count) - 1);
				end if;
				space_next <= '1'; 

			when NUMBER =>
				if space = '1' then
					error_sig_next <= '1';
				elsif line_count >= x"46" then
					-- end of buffer, last value still not converted
					end_of_op_next <= '1';
					check_op_ready_next <= '1';
				end if;
			
			when CONVERT_POST_STATE =>
					if convert_ready /= '1' then
						addr_lb_next <= start_pos;		
					else
						addr_lb_next <= line_count;	
						start_pos_next <= line_count;
						convert_ready_next <= '1';
						parse_ready_next <= '1';
					end if;	

			when CONVERT_TO_INT =>
				start_pos_next <= std_logic_vector(unsigned(start_pos) + 1);
				addr_lb_next <= std_logic_vector(unsigned(start_pos) + 1);
				-- convert ascii to integer
				if (unsigned(convert_count) - unsigned(start_pos)) >= 1 then
					case data_in(7 downto 0) is							
						when x"31" => 
							operand_next <= std_logic_vector(unsigned(last_operand) + ((unsigned(convert_count) - unsigned(start_pos)) * 10));

						when x"32" => 
							operand_next <= std_logic_vector(unsigned(last_operand) + ((unsigned(convert_count) - unsigned(start_pos)) * 20));

						when x"33" =>  
							operand_next <= std_logic_vector(unsigned(last_operand) + ((unsigned(convert_count) - unsigned(start_pos)) * 30));

						when x"34" =>  
							operand_next <= std_logic_vector(unsigned(last_operand) + ((unsigned(convert_count) - unsigned(start_pos)) * 40));

						when x"35" =>  
							operand_next <= std_logic_vector(unsigned(last_operand) + ((unsigned(convert_count) - unsigned(start_pos)) * 50));

						when x"36" =>  
							operand_next <= std_logic_vector(unsigned(last_operand) + ((unsigned(convert_count) - unsigned(start_pos)) * 60));

						when x"37" =>  
							operand_next <= std_logic_vector(unsigned(last_operand) + ((unsigned(convert_count) - unsigned(start_pos)) * 70));

						when x"38" =>  
							operand_next <= std_logic_vector(unsigned(last_operand) + ((unsigned(convert_count) - unsigned(start_pos)) * 80));

						when x"39" =>  
							operand_next <= std_logic_vector(unsigned(last_operand) + ((unsigned(convert_count) - unsigned(start_pos)) * 90));

						when others =>
							null;
					end case;

				else
					case data_in(7 downto 0) is							
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
			
					convert_ready_next <= '1';
				end if;
			
			when ERROR_STATE =>
			--TODO:						
				null;

		end case;


   end process output;

  assert RESET_VALUE = '0' or RESET_VALUE = '1' report
    "RESET_VALUE may only be 0 or 1!" severity failure;

  sync : process(sys_clk, sys_res_n)
  begin
    if sys_res_n = '0' then
      parser_fsm_state <= READY;
			line_count <= (others => '0');
			convert_count <= (others => '0');
			space <= '0';
			last_operand <= x"00000000";
			once <= '0';
			addr_lb_old <= (others => '0');
debug_sig <= 0;
		elsif (sys_clk'event and sys_clk = '1') then
			check_op_ready <= check_op_ready_next;
			convert_ready <= convert_ready_next;
			space <= space_next;
			parser_fsm_state <= parser_fsm_state_next;
			error_sig <= error_sig_next;
			negative <= negative_next;
			line_count <= line_count_next;
			addr_lb_old <= addr_lb_next;
			addr_lb <= addr_lb_next;
			end_of_operation <= end_of_op_next;
			parse_ready <= parse_ready_next;
			old_operator <= operator_next;
			operator <= operator_next;
			operand <= operand_next;	
			last_operand <= operand_next;
			leading_sign <= leading_sign_next;
			start_pos <= start_pos_next;
			convert_count <= convert_count_next;
			once <= once_next;
debug_sig <= debug_sig_next;
		end if;
  end process sync;
end architecture beh;
