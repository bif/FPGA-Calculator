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
	signal once, once_next, num_and_space, num_and_space_next, space, space_next, num, num_next, leading_sign_old, leading_sign_next, debug_end_of_op, end_of_op_next, parse_ready_next, check_op_ready, check_op_ready_next, convert_ready, convert_ready_next : std_logic;
	
--	signal debug_sig_next, debug_sig :integer := 0;

	-- look up table functions to convert ascii to integer
	function foo_1(value : in unsigned) return unsigned is
		begin
			if value = 9 then
				return to_unsigned(1000000000, 10);
			elsif value = 8 then
				return to_unsigned(100000000, 10);
			elsif value = 7 then
				return to_unsigned(10000000, 10);
			elsif value = 6 then
				return to_unsigned(1000000, 10);
			elsif value = 5 then
				return to_unsigned(100000, 10);
			elsif value = 4 then
				return to_unsigned(10000, 10);
			elsif value = 3 then
				return to_unsigned(1000, 10);
			elsif value = 2 then
				return to_unsigned(100, 10);
			else 
				return to_unsigned(10, 10);
			end if;
	end function;  
	function foo_2(value : in unsigned) return unsigned is
		begin
			if value = 9 then
				return to_unsigned(2000000000, 10);
			elsif value = 8 then
				return to_unsigned(200000000, 10);
			elsif value = 7 then
				return to_unsigned(20000000, 10);
			elsif value = 6 then
				return to_unsigned(2000000, 10);
			elsif value = 5 then
				return to_unsigned(200000, 10);
			elsif value = 4 then
				return to_unsigned(20000, 10);
			elsif value = 3 then
				return to_unsigned(2000, 10);
			elsif value = 2 then
				return to_unsigned(200, 10);
			else
				return to_unsigned(20, 10);
			end if;
	end function;
	function foo_3(value : in unsigned) return unsigned is
		begin
			if value = 8 then
				return to_unsigned(300000000, 10);
			elsif value = 7 then
				return to_unsigned(30000000, 10);
			elsif value = 6 then
				return to_unsigned(3000000, 10);
			elsif value = 5 then
				return to_unsigned(300000, 10);
			elsif value = 4 then
				return to_unsigned(30000, 10);
			elsif value = 3 then
				return to_unsigned(3000, 10);
			elsif value = 2 then
				return to_unsigned(300, 10);
			else
				return to_unsigned(30, 10);
			end if;
	end function;
	function foo_4(value : in unsigned) return unsigned is
		begin
			if value = 8 then
				return to_unsigned(400000000, 10);
			elsif value = 7 then
				return to_unsigned(40000000, 10);
			elsif value = 6 then
				return to_unsigned(4000000, 10);
			elsif value = 5 then
				return to_unsigned(400000, 10);
			elsif value = 4 then
				return to_unsigned(40000, 10);
			elsif value = 3 then
				return to_unsigned(4000, 10);
			elsif value = 2 then
				return to_unsigned(400, 10);
			else
				return to_unsigned(40, 10);
			end if;
	end function;
	function foo_5(value : in unsigned) return unsigned is
		begin
			if value = 8 then
				return to_unsigned(500000000, 10);
			elsif value = 7 then
				return to_unsigned(50000000, 10);
			elsif value = 6 then
				return to_unsigned(5000000, 10);
			elsif value = 5 then
				return to_unsigned(500000, 10);
			elsif value = 4 then
				return to_unsigned(50000, 10);
			elsif value = 3 then
				return to_unsigned(5000, 10);
			elsif value = 2 then
				return to_unsigned(500, 10);
			else
				return to_unsigned(50, 10);
			end if;
	end function;
	function foo_6(value : in unsigned) return unsigned is
		begin
			if value = 8 then
				return to_unsigned(600000000, 10);
			elsif value = 7 then
				return to_unsigned(60000000, 10);
			elsif value = 6 then
				return to_unsigned(6000000, 10);
			elsif value = 5 then
				return to_unsigned(600000, 10);
			elsif value = 4 then
				return to_unsigned(60000, 10);
			elsif value = 3 then
				return to_unsigned(6000, 10);
			elsif value = 2 then
				return to_unsigned(600, 10);
			else 
				return to_unsigned(60, 10);
			end if;
	end function;
	function foo_7(value : in unsigned) return unsigned is
		begin
			if value = 8 then
				return to_unsigned(700000000, 10);
			elsif value = 7 then
				return to_unsigned(70000000, 10);
			elsif value = 6 then
				return to_unsigned(7000000, 10);
			elsif value = 5 then
				return to_unsigned(700000, 10);
			elsif value = 4 then
				return to_unsigned(70000, 10);
			elsif value = 3 then
				return to_unsigned(7000, 10);
			elsif value = 2 then
				return to_unsigned(700, 10);
			else
				return to_unsigned(70, 10);
			end if;
	end function;
	function foo_8(value : in unsigned) return unsigned is
		begin
			if value = 8 then
				return to_unsigned(800000000, 10);
			elsif value = 7 then
				return to_unsigned(80000000, 10);
			elsif value = 6 then
				return to_unsigned(8000000, 10);
			elsif value = 5 then
				return to_unsigned(800000, 10);
			elsif value = 4 then
				return to_unsigned(80000, 10);
			elsif value = 3 then
				return to_unsigned(8000, 10);
			elsif value = 2 then
				return to_unsigned(800, 10);
			else
				return to_unsigned(80, 10);
			end if;
	end function;
	function foo_9(value : in unsigned) return unsigned is
		begin
			if value = 8 then
				return to_unsigned(900000000, 10);
			elsif value = 7 then
				return to_unsigned(90000000, 10);
			elsif value = 6 then
				return to_unsigned(9000000, 10);
			elsif value = 5 then
				return to_unsigned(900000, 10);
			elsif value = 4 then
				return to_unsigned(90000, 10);
			elsif value = 3 then
				return to_unsigned(9000, 10);
			elsif value = 2 then
				return to_unsigned(900, 10);
			else
				return to_unsigned(90, 10);
			end if;
	end function;

begin

  next_state : process(parser_fsm_state, data_in, read_next_n_o, error_sig, check_op_ready, convert_ready, debug_end_of_op)
  begin
    parser_fsm_state_next <= parser_fsm_state;	

    case parser_fsm_state is
			when READY =>
				if read_next_n_o = '1' and debug_end_of_op = '0' then
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
					when x"20" =>
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



	output : process(parser_fsm_state, data_in, space, num, num_and_space, line_count, check_op_ready, convert_ready, start_pos, error_sig, convert_count, last_operand, once, old_operator, addr_lb_old, leading_sign_old)

  begin
		leading_sign_next <= leading_sign_old;
		start_pos_next <= start_pos;
--		negative_next <= negative;
		error_sig_next <= '0';
		line_count_next <= line_count;
		parse_ready_next <= '0';
		space_next <= space;
		num_next <= num;
		check_op_ready_next <= '0';
		convert_ready_next <= '0';
		operator_next <= old_operator;
		end_of_op_next <= '0';
		convert_count_next <= convert_count;
		operand_next <= last_operand;
--		debug_sig_next <= debug_sig;
		addr_lb_next <= addr_lb_old;
		once_next <= once;
		num_and_space_next <= num_and_space;

		case parser_fsm_state is
			when READY =>
				leading_sign_next <= '0';
				num_and_space_next <= '0';
				space_next <= '0';
				num_next <= '0';
				once_next <= '0';
				check_op_ready_next <= '0';
				convert_ready_next <= '0';		
--debug_sig_next <= 0;

			when CHECK_UNSIGNED =>
				-- set saved operand to zero
				operand_next <= (others => '0');	
				case data_in(7 downto 0) is
					when x"2D" =>
						-- "-"
						leading_sign_next <= '1';
--						negative_next <= '1';
						line_count_next <= std_logic_vector(unsigned(line_count) + 1);
						start_pos_next <= std_logic_vector(unsigned(line_count) + 1);
						addr_lb_next <= std_logic_vector(unsigned(line_count) + 1); 					

					when x"2B" =>
						-- "+"
						leading_sign_next <= '0';
--						negative_next <= '0';
						line_count_next <= std_logic_vector(unsigned(line_count) + 1);
						start_pos_next <= std_logic_vector(unsigned(line_count) + 1);
						addr_lb_next <= std_logic_vector(unsigned(line_count) + 1); 	

					when x"30" | x"31" | x"32" | x"33" | x"34" | x"35" | x"36" | x"37" | x"38" | x"39" | x"20"=>
						-- "0 ... 9"
						leading_sign_next <= '0';
--						negative_next <= '0';
						start_pos_next <= line_count;			

					when others =>
						error_sig_next <= '1';
			
				end case;	

			when CHECK_OPERAND =>		
				if check_op_ready /= '1' then 
					addr_lb_next <= std_logic_vector(unsigned(line_count) + 1);	
					line_count_next <= std_logic_vector(unsigned(line_count) + 1);
					if num_and_space = '1' and once = '0' then
						once_next <= '1';
						convert_count_next <= std_logic_vector(unsigned(line_count) - 2); 
						start_pos_next <= std_logic_vector(unsigned(start_pos) - 1); 
					end if;
				else
					if space = '0' then
						convert_count_next <= std_logic_vector(unsigned(line_count) - 2);
					end if;						
					addr_lb_next <= start_pos;	
				end if;
			
			when PLUS =>
				-- next operator = '+' located 
				if (line_count >= x"46" or (unsigned(line_count) - 1)  = unsigned(start_pos)) then
						-- first sign after signed check is an operator or last sign is an operator
						error_sig_next <= '1';
				else
					operator_next <= "00";	
					addr_lb_next <= start_pos;
					check_op_ready_next <= '1';
				end if; 

			when MINUS =>
				-- next operator = '-' located 
				if (line_count >= x"46" or (unsigned(line_count) - 1)  = unsigned(start_pos)) then
					-- first sign after signed check is an operator or last sign is an operator
					error_sig_next <= '1';
				elsif space = '1' and num = '0' then
					leading_sign_next <= '1';
				else
					operator_next <= "01";	
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
					addr_lb_next <= start_pos;
					check_op_ready_next <= '1';
				end if; 

			when SPACE_BAR =>

				-- space located 
				if line_count >= x"46" then
					addr_lb_next <= start_pos;
					check_op_ready_next <= '1';
				end if;
				if num = '1' and space = '1' then
					num_and_space_next <= '1';
				end if;
				space_next <= '1'; 

			when NUMBER =>
				num_next <= '1';
				if num_and_space = '1' then
					error_sig_next <= '1';
				elsif space = '1' and num = '0' then
					start_pos_next <= line_count;
				elsif line_count >= x"46" then
					check_op_ready_next <= '1';
				end if;
			
			when CONVERT_POST_STATE =>
					if convert_ready /= '1' then
						addr_lb_next <= start_pos;		
					else
						if line_count >= x"46" then
							end_of_op_next <= '1';
							-- if end of operation set operator to + or - => Calculator can finish if last operator is + or -
							operator_next <= "00";
							line_count_next <= (others => '0');
							addr_lb_next <= (others => '0');
							start_pos_next <= (others => '0');
						end if;
						addr_lb_next <= line_count;	
						start_pos_next <= line_count;
						convert_ready_next <= '1';
						parse_ready_next <= '1';
					end if;	

			when CONVERT_TO_INT =>
				start_pos_next <= std_logic_vector(unsigned(start_pos) + 1);
--				if space = '0' then
					addr_lb_next <= std_logic_vector(unsigned(start_pos) + 1);
--				end if;		
				-- convert ascii to integer
				if (unsigned(convert_count) - unsigned(start_pos)) >= 1 then
					case data_in(7 downto 0) is							
						when x"31" => 
							operand_next <= std_logic_vector(unsigned(last_operand) + foo_1((unsigned(convert_count) - unsigned(start_pos))));

						when x"32" => 
							operand_next <= std_logic_vector(unsigned(last_operand) + foo_2((unsigned(convert_count) - unsigned(start_pos))));

						when x"33" => 
							operand_next <= std_logic_vector(unsigned(last_operand) + foo_3((unsigned(convert_count) - unsigned(start_pos)))); 

						when x"34" => 
							operand_next <= std_logic_vector(unsigned(last_operand) + foo_4((unsigned(convert_count) - unsigned(start_pos)))); 

						when x"35" => 
							operand_next <= std_logic_vector(unsigned(last_operand) + foo_5((unsigned(convert_count) - unsigned(start_pos)))); 

						when x"36" => 
							operand_next <= std_logic_vector(unsigned(last_operand) + foo_6((unsigned(convert_count) - unsigned(start_pos)))); 

						when x"37" => 
							operand_next <= std_logic_vector(unsigned(last_operand) + foo_7((unsigned(convert_count) - unsigned(start_pos)))); 

						when x"38" => 
							operand_next <= std_logic_vector(unsigned(last_operand) + foo_8((unsigned(convert_count) - unsigned(start_pos)))); 

						when x"39" => 
							operand_next <= std_logic_vector(unsigned(last_operand) + foo_9((unsigned(convert_count) - unsigned(start_pos)))); 

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
			addr_lb_old <= (others => '0');
			error_sig <= '0';
			debug_end_of_op <= '0';
--debug_sig <= 0;
		elsif (sys_clk'event and sys_clk = '1') then
			check_op_ready <= check_op_ready_next;
			convert_ready <= convert_ready_next;
			space <= space_next;
			num <= num_next;
			num_and_space <= num_and_space_next;
			once <= once_next;
			parser_fsm_state <= parser_fsm_state_next;
			error_sig <= error_sig_next;
--			negative <= negative_next;
			line_count <= line_count_next;
			addr_lb_old <= addr_lb_next;
			addr_lb <= addr_lb_next;
			debug_end_of_op <= end_of_op_next;
			end_of_operation <= end_of_op_next;
			parse_ready <= parse_ready_next;
			old_operator <= operator_next;
			operator <= operator_next;
			operand <= signed(operand_next);	
			last_operand <= operand_next;
			leading_sign <= leading_sign_next;
			leading_sign_old <= leading_sign_next;
			start_pos <= start_pos_next;
			convert_count <= convert_count_next;
--debug_sig <= debug_sig_next;
		end if;
  end process sync;
end architecture beh;
