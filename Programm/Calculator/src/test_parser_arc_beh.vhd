library ieee;
use ieee.std_logic_1164.all;
use work.parser_pkg.all;

architecture beh of parser is
  type SC_H_FSM_STATE_TYPE is
    (READY, ERROR_STATE, CHECK_UNSIGNED, CHECK_NUMBER, READ_BUFFER);

  signal parser_fsm_state, parser_fsm_state_next : SC_H_FSM_STATE_TYPE;
	signal error_sig : std_logic;
	signal start_pos : std_logic_vector(ADDR_WIDTH - 1 downto 0);
	signal data : std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal end_of_op_next, parse_ready_next, read, convert : std_logic;
	signal operand_next : std_logic_vector(31 downto 0);
	signal operator_next : std_logic_vector(2 downto 0);
	
begin

  output : process(read_next_n_o, convert) 
		variable space, leading_sign : std_logic := '0';
		variable pos_count, tmp, pos_end_op : std_logic_vector(ADDR_WIDTH - 1 downto 0) := start_pos;
		variable operand_tmp : std_logic_vector(31 downto 0);

  begin
		-- 2 while loops to make the design shorter
		--while loop for finding position of next operator
		while convert = '0' and error_sig = '0' and parse_ready_next = '0' loop
			if read = '0' then
				addr_lb <= pos_count;
				data <= data_in;
			else
				--check unsigned
				if pos_count = start_pos then
					case data is
						when x"2D" =>
							-- "-"
							leading_sign := '1';
							error_sig <= '0';
						when x"2B" =>
							-- "+"
							leading_sign := '0';
							error_sig <= '0';
						when x"30" | x"31" | x"32" | x"33" | x"34" | x"35" | x"36" | x"37" | x"38" | x"39" =>
							leading_sign := '0';
							error_sig <= '0';
						when others =>
							error_sig <= '1';
					end case;
				--check if next sign is number
				elsif pos_count = (start_pos + '1') then
					case data is
						when x"30" | x"31" | x"32" | x"33" | x"34" | x"35" | x"36" | x"37" | x"38" | x"39" =>
							null;
						when others =>
							error_sig <= '1';
					end case;
				elsif pos_count > (start_pos + '1') then
					-- if a space was dedected only operator or space must be next
					if space = '1' then
						if data /= x"20" and 
						(data /= x"2B" or data /= x"2D" or data /= "2A" or data /= x"2F")
 						then
							error_sig <= '1';
						end if;
					end if;
					-- dedect space
					if data = x"20" then
						space := '1';
						pos_end_op := pos_count;
					end if;
					if error_sig = '0' then
						-- operand bigger then integer 
						if (pos_end_op - start_pos > "0000FFFF" then
							error_sig >= '1';
						end if;		
						-- dedect operator if no error was dedected
						case data is
							-- "+"
							when x"2B" =>
								operator_next <= x"00";
								convert <= '1'; 
							-- "-"
							when x"2D" =>
								operator_next <= x"01";
								convert <= '1'; 
							-- "*"
							when x"2A" =>
								operator <= x"10";
								convert <= '1'; 
							-- "/"
					 		when x"2F" =>
								operator_next <= x"11";
								convert <= '1'; 
						end case;
						pos_end_op := (pos_count - '1');		
					end if;
				end if; 
				pos_count := (pos_count + '1');	
			end if;
		end loop;
		tmp := pos_count;
		pos_count := start_pos;
		start_pos <= tmp; 

		--	while loop for converting operand (ascii to integer) & interpret operator
		while convert = '1' and  pos_count =< pos_end_op and parse_ready_next = '0' loop
			if read = '0' then
				addr_lb <= pos_count;
				data <= data_in;
			else
				
				pos_count := (pos_count + '1');
				if pos_count > pos_end_op then
					operand_next <= operand_tmp;
				 	parse_ready_next <= '1';	
				end if;
			end if;
		end loop;
	end process output;

--TODO : extra error prozess ... error_sig unterschiedliche Werte => unterschiedliche Fehlerausgaben ans VGA Modul
--oder auch mit assert möglich???
--	assert RESET_VALUE = '0' or RESET_VALUE = '1' report
--    "RESET_VALUE may only be 0 or 1!" severity failure;

  sync : process(sys_clk, sys_res_n)
  begin
    if sys_res_n = '0' then
			read <= '0';
			start_pos <= '0';
			error_sig <= '0';
		elsif (sys_clk'event and sys_clk = '1') then
			read <= '0';
			end_of_operation <= end_of_op_next;
			parse_ready <= parse_ready_next;
			operator <= operator_next;
			operand <= operand_next;
		elsif (sys_clk'event and sys_clk = '0') then
			read <= '1';
		end if;
  end process sync;
end architecture beh;
