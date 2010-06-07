library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

architecture beh of alu is
	signal	start_operation_old		:	std_logic := '0';
	signal	start_operation_old_next	:	std_logic := '0';
	signal	sum_tmp				:	signed(62 downto 0);
	signal	sum_tmp_next			:	signed(62 downto 0);

	type	ALU_STATE_TYPE is (READY, BUSY, DONE);	
	signal 	alu_state			:	ALU_STATE_TYPE;
	signal 	alu_state_next			:	ALU_STATE_TYPE;
begin

	process(sys_clk, sys_res_n)
	begin
		if(sys_res_n = '0')
		then
			start_operation_old <= '0';
			alu_state <= READY;
			sum_tmp <= "000000000000000000000000000000000000000000000000000000000000000";
		elsif(rising_edge(sys_clk))
		then
			start_operation_old <= start_operation_old_next;
			alu_state <= alu_state_next;
			sum_tmp <= sum_tmp_next;
		end if;
	end process;

	process(start_operation, start_operation_old, alu_state, operand_1, operand_2, operator, sum_tmp)
	begin
		start_operation_old_next <= start_operation;
		alu_state_next <= alu_state;
		sum_tmp_next <= sum_tmp;
		sum <= "000000000000000000000000000000000000000000000000000000000000000";
		operation_done <= '0';

		case alu_state is
		when	READY =>
		
			operation_done <= '0';	
			err_div_by_zero <= '0';
			err_overflow <= '0';
			if(start_operation /= start_operation_old and start_operation = '1')
			then
				alu_state_next <= BUSY;
			end if;

		when	BUSY =>
				if(operator = "00")
				then
					sum_tmp_next <= resize(operand_1, 63) + resize(operand_2, 63);
					alu_state_next <= DONE;
				elsif(operator = "01")
				then
					sum_tmp_next <= resize(operand_1, 63) - resize(operand_2, 63);
					alu_state_next <= DONE;
				elsif(operator = "10")
				then
					sum_tmp_next <= resize(operand_1 * operand_2, 63);
					alu_state_next <= DONE;
				elsif(operator = "11")
				then
					if(operand_2 = 0)
					then
						err_div_by_zero <= '1';
					else
						-- TODO: dividierer:
					end if;
				end if;

		when	DONE =>	
			alu_state_next <= READY;
			if(sum_tmp >= RESULT_MIN and sum_tmp <= RESULT_MAX)
			then
				operation_done <= '1';
				sum <= sum_tmp;
			else					-- result is too big(or too small) --> overflow
				err_overflow <= '1';
			end if;

		end case;
	end process;

end architecture beh;
