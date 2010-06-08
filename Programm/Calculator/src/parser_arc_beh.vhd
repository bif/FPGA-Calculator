library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.parser_pkg.all;

architecture beh of parser is
  type SC_H_FSM_STATE_TYPE is
    (IDLE, RESET_SIGNALS, CHECK_UNSIGNED_PREE, CHECK_UNSIGNED, CHECK_OPERAND, CHECK_OPERAND_PREE, CONVERT,  RESET_LINECOUNT, ERROR_STATE);

  signal parser_fsm_state, parser_fsm_state_next : SC_H_FSM_STATE_TYPE;
	signal error_sig_old, error_sig_next : std_logic_vector(2 downto 0) := "000";
	signal operator_next, last_operator : std_logic_vector(1 downto 0) := "00";
	signal operand_next, last_operand, current_number, current_number_next : signed(31 downto 0) := (others => '0');
	signal leading_sign_next, leading_sign_old, end_of_op_next, parse_ready_next, check_unsigned_ready, check_unsigned_ready_next, check_op_ready, check_op_ready_next : std_logic := '0';
	signal	read_next_n_o_old, read_next_n_o_old_next	:	std_logic := '0';
	signal space, space_next, num, num_next : std_logic := '0';
	signal mem_ready, mem_ready_next : std_logic := '0';
	signal once, once_next, do_convert, do_convert_next, ready, ready_next, first_round, first_round_next : std_logic := '0';

	signal addr_lb_next, addr_lb_old, line_count, line_count_next : std_logic_vector(ADDR_WIDTH - 1 downto 0) := (others => '0');



begin

  next_state : process(parser_fsm_state, read_next_n_o, read_next_n_o_old, error_sig_old, check_unsigned_ready, check_op_ready, mem_ready, ready)
  begin
    parser_fsm_state_next <= parser_fsm_state;	
		read_next_n_o_old_next <= read_next_n_o;
		mem_ready_next <= '0';

    case parser_fsm_state is
			when IDLE =>
				mem_ready_next <= '0';
				if(read_next_n_o /= read_next_n_o_old and read_next_n_o = '1') then
					parser_fsm_state_next <= RESET_SIGNALS;
				end if;

			when RESET_SIGNALS =>
					parser_fsm_state_next <= CHECK_UNSIGNED_PREE;

			-- the pree state must be executed twice => memory-data valid in the next state
			when CHECK_UNSIGNED_PREE => 
				if error_sig_old /= "000" then
					parser_fsm_state_next <= ERROR_STATE;
				else	
					if mem_ready = '1' then
						if check_unsigned_ready = '1' then
							parser_fsm_state_next <= CHECK_OPERAND_PREE;
						else 
							parser_fsm_state_next <= CHECK_UNSIGNED;
						end if;
						mem_ready_next <= '0';
					else
						parser_fsm_state_next <= CHECK_UNSIGNED_PREE;
						mem_ready_next <= '1';
					end if;
				end if;

			when CHECK_UNSIGNED =>
				parser_fsm_state_next <= CHECK_UNSIGNED_PREE;

			-- the pree state must be executed twice => memory-data valid in the next state
			when CHECK_OPERAND_PREE => 
				if error_sig_old /= "000" then
					parser_fsm_state_next <= ERROR_STATE;
				else	
					if mem_ready = '1' then
						parser_fsm_state_next <= CHECK_OPERAND;
						mem_ready_next <= '0';
					else
						parser_fsm_state_next <= CHECK_OPERAND_PREE;
						mem_ready_next <= '1';
					end if;
				end if;

			when CHECK_OPERAND =>		
				parser_fsm_state_next <= CONVERT;

			when CONVERT =>
				if error_sig_old /= "000" then				
					parser_fsm_state_next <= ERROR_STATE;
				elsif check_op_ready = '1' and ready = '0' then 
						parser_fsm_state_next <= IDLE;
				elsif check_op_ready = '1' and ready = '1' then 
						parser_fsm_state_next <= RESET_LINECOUNT;
				else
					parser_fsm_state_next <= CHECK_OPERAND_PREE;
				end if;

			when RESET_LINECOUNT =>
				parser_fsm_state_next <= IDLE;

			when ERROR_STATE =>
				parser_fsm_state_next <= IDLE;

		end case;
  end process next_state;



	output : process(parser_fsm_state, data_in, line_count, once, check_unsigned_ready, check_op_ready, last_operand, last_operator, num, space, error_sig_old,  addr_lb_old, leading_sign_old, current_number, do_convert, ready, first_round)

  begin
		first_round_next <= first_round;
		parse_ready_next <= '0';
		end_of_op_next <= '0';
		check_op_ready_next <= '0';
		check_unsigned_ready_next <= check_unsigned_ready;
		check_op_ready_next <= check_op_ready;
		line_count_next <= line_count;
		operand_next <= last_operand;
		operator_next <= last_operator;
		once_next <= once;
		num_next <= num;
		space_next <= space;
		error_sig_next <= error_sig_old;
		addr_lb_next <= addr_lb_old;
		leading_sign_next <= leading_sign_old;
		current_number_next <= current_number;
		do_convert_next <= '0';
		ready_next <= '0';

    case parser_fsm_state is
			when IDLE =>
				if first_round /= '1' then
					first_round_next <= '1';
					addr_lb_next <= (others => '0');
				end if;

			when RESET_SIGNALS =>
				operand_next <= to_signed(0, 32);
				operator_next <= "00";
				num_next <= '0';
				space_next <= '0';
				once_next <= '0';
				error_sig_next <= "000";
				end_of_op_next <= '0';
				parse_ready_next <= '0';
				leading_sign_next <= '0';
				ready_next <= '0';
				current_number_next <= to_signed(0, 32);
				check_op_ready_next <= '0';
				check_unsigned_ready_next <= '0';

			when CHECK_UNSIGNED_PREE =>
				addr_lb_next <= line_count; 	

			when CHECK_UNSIGNED =>
				case data_in(7 downto 0) is
					when x"2D" =>
						-- "-"
						leading_sign_next <= '1';
						check_unsigned_ready_next <= '1';
						line_count_next <= std_logic_vector(unsigned(line_count) + 1);

					when x"2B" =>
						-- "+"
						leading_sign_next <= '0';
						check_unsigned_ready_next <= '1';
						line_count_next <= std_logic_vector(unsigned(line_count) + 1);

					when x"30" | x"31" | x"32" | x"33" | x"34" | x"35" | x"36" | x"37" | x"38" | x"39" =>
						-- "0 ... 9"
						-- linecount don't become incremented because occurrence of 
						-- first number must be detected in state CHECK_OPERAND
						leading_sign_next <= '0';
						check_unsigned_ready_next <= '1';

					when x"20" =>
						-- ignore spaces before leading sign or first number
						line_count_next <= std_logic_vector(unsigned(line_count) + 1);

					when others =>
						--if '/' or '*' detected => ERROR
						error_sig_next <= "001";

				end case;

			when CHECK_OPERAND_PREE =>	
				addr_lb_next <= line_count; 	

			when CHECK_OPERAND =>
				case data_in(7 downto 0) is
					when x"20" =>
						if num = '1' then
							space_next <= '1';
						end if; 

					when x"31" =>
						if num = '1' and space = '1' then
							error_sig_next <= "010";
						end if; 
						current_number_next <= to_signed(1, 32);		
						num_next <= '1'; 
						do_convert_next <= '1'; 

					when x"32" =>
						if num = '1' and space = '1' then
							error_sig_next <= "010";
						end if; 
						current_number_next <= to_signed(2, 32);		
						num_next <= '1';  
						do_convert_next <= '1';

					when x"33" =>
						if num = '1' and space = '1' then
							error_sig_next <= "010";
						end if; 
						current_number_next <= to_signed(3, 32);		
						num_next <= '1';  
						do_convert_next <= '1';

					when x"34" =>
						if num = '1' and space = '1' then
							error_sig_next <= "010";
						end if; 
						current_number_next <= to_signed(4, 32);		
						num_next <= '1';  
						do_convert_next <= '1';

					when x"35" =>
						if num = '1' and space = '1' then
							error_sig_next <= "010";
						end if; 
						current_number_next <= to_signed(5, 32);		
						num_next <= '1';  
						do_convert_next <= '1';

					when x"36" =>
						if num = '1' and space = '1' then
							error_sig_next <= "010";
						end if; 
						current_number_next <= to_signed(6, 32);		
						num_next <= '1';  
						do_convert_next <= '1';

					when x"37" =>
						if num = '1' and space = '1' then
							error_sig_next <= "010";
						end if; 
						current_number_next <= to_signed(7, 32);		
						num_next <= '1';  
						do_convert_next <= '1';

					when x"38" =>
						if num = '1' and space = '1' then
							error_sig_next <= "010";
						end if; 
						current_number_next <= to_signed(8, 32);		
						num_next <= '1';  
						do_convert_next <= '1';

					when x"39" =>
						if num = '1' and space = '1' then
							error_sig_next <= "010";
						end if; 
						current_number_next <= to_signed(9, 32);		
						num_next <= '1';  
						do_convert_next <= '1';

					when x"30" =>
						if num = '1' and space = '1' then
							error_sig_next <= "010";
						end if; 
						current_number_next <= to_signed(0, 32);		
						num_next <= '1'; 
						do_convert_next <= '1';

					when x"2B" =>
						-- '+' dedected
						if num = '0' then
							error_sig_next <= "011";
						else 
							operator_next <= "00";
							check_op_ready_next <= '1';
						end if; 

					when x"2D" =>
						-- '-' dedected
						if num = '0' then
							error_sig_next <= "011";
						else 
							operator_next <= "01";
							check_op_ready_next <= '1';
						end if; 

					when x"2A" =>
						-- '*' dedected
						if num = '0' then
							error_sig_next <= "011";
						else 
							operator_next <= "10";
							check_op_ready_next <= '1';
						end if; 

					when x"2F" =>
						-- '/' dedected
						if num = '0' then
							error_sig_next <= "011";
						else 
							operator_next <= "11";
							check_op_ready_next <= '1';
						end if;
 
					when x"3D" =>
						-- seperator '=' dedected
						if num = '0' then
							error_sig_next <= "011";
						else
							check_op_ready_next <= '1';
							ready_next <= '1';
						end if;
					
					when others =>
						null;
			
				end case;
				line_count_next <= std_logic_vector(unsigned(line_count) + 1);

			when CONVERT =>
			if resize(last_operand, 63) > OPERAND_MAX or resize(last_operand, 63) < OPERAND_MIN then
				error_sig_next <= "100";
			end if;
			if check_op_ready = '1' and ready = '0' then 
					parse_ready_next <= '1';
				elsif check_op_ready = '1' and ready = '1' then 
					parse_ready_next <= '1';
					end_of_op_next <= '1';
				end if;
				if do_convert = '1' then
					if once = '0' then
						once_next <= '1';
						operand_next <= current_number;
					else
						operand_next <= resize((last_operand * 10 + current_number), 32);	
					end if;
				end if;

			when RESET_LINECOUNT =>
				line_count_next <= (others => '0');

			when ERROR_STATE =>
				leading_sign_next <= '0';
				error_sig_next <= "000";
				line_count_next <= (others => '0');
				parse_ready_next <= '1';
				space_next <= '0';
				num_next <= '0';
				check_op_ready_next <= '0';
				end_of_op_next <= '1';
				addr_lb_next <= (others => '0');
				once_next <= '0';

		end case;

  end process output; 

  sync : process(sys_clk, sys_res_n)
  begin
    if sys_res_n = '0' then
      parser_fsm_state <= IDLE;
			line_count <= (others => '0');
			last_operand <= (others => '0');
			error_sig <= "000";
			addr_lb_old <= (others => '0');
			addr_lb <= (others => '0');
			read_next_n_o_old <= '0';
			first_round <= '0';
		elsif (sys_clk'event and sys_clk = '1') then
			check_unsigned_ready <= check_unsigned_ready_next;
			parser_fsm_state <= parser_fsm_state_next;
			check_op_ready <= check_op_ready_next;
			line_count <= line_count_next;
			addr_lb <= addr_lb_next;
			addr_lb_old <= addr_lb_next;
			ready <= ready_next;
			end_of_operation <= end_of_op_next;
			parse_ready <= parse_ready_next;
			operator <= operator_next;
			last_operator <= operator_next;
			operand <= operand_next;	
			last_operand <= operand_next;
			leading_sign <= leading_sign_next;
			leading_sign_old <= leading_sign_next;
			read_next_n_o_old <= read_next_n_o_old_next;
			space <= space_next;
			num <= num_next;
			error_sig <= error_sig_next;
			error_sig_old <= error_sig_next;
			mem_ready <= mem_ready_next;
			once <= once_next;
			current_number <= current_number_next;
			do_convert <= do_convert_next;
			ready <= ready_next;
			first_round <= first_round_next;	
	end if;
  end process sync;
end architecture beh;
