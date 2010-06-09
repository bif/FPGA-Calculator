library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


architecture beh of alu is
	constant SIZE : integer := 32;

	signal	start_operation_old		:	std_logic := '0';
	signal	start_operation_old_next	:	std_logic := '0';
	signal	sum_tmp				:	signed(62 downto 0) := (others => '0');
	signal	sum_tmp_next			:	signed(62 downto 0) := (others => '0');

	type	ALU_STATE_TYPE is (READY, BUSY, DONE_POST, DONE);	
	signal 	alu_state			:	ALU_STATE_TYPE;
	signal 	alu_state_next			:	ALU_STATE_TYPE;

	--signlas for devider
	signal buf, buf_next : std_logic_vector((2 * SIZE - 1) downto 0) := (others => '0');
	signal dbuf, dbuf_next : std_logic_vector((SIZE - 1) downto 0) := (others => '0');
	signal sm , sm_next: integer range 0 to SIZE := 0;
	signal once, once_next : std_logic := '0';
	signal neg_tmp : std_logic;
	signal neg_tmp_next : std_logic;

begin

	process(sys_clk, sys_res_n)
	begin
		if(sys_res_n = '0')
		then
			start_operation_old <= '0';
			alu_state <= READY;
			sum_tmp <= "000000000000000000000000000000000000000000000000000000000000000";
			-- for divider	
			sm <= 0;
			neg_tmp <= '0';
		elsif(rising_edge(sys_clk))
		then
			start_operation_old <= start_operation_old_next;
			alu_state <= alu_state_next;
			sum_tmp <= sum_tmp_next;
			-- devider
			buf <= buf_next;
			dbuf <= dbuf_next;
			sm <= sm_next;
			once <= once_next;
			neg_tmp <= neg_tmp_next;
		end if;
	end process;

	process(start_operation, start_operation_old, alu_state, operand_1, operand_2, operator, sum_tmp, buf, dbuf, sm, once, neg_tmp)
	variable	op1_tmp, op2_tmp	:	signed(31 downto 0);
	begin
		start_operation_old_next <= start_operation;
		alu_state_next <= alu_state;
		sum_tmp_next <= sum_tmp;
		sum <= "000000000000000000000000000000000000000000000000000000000000000";
		operation_done <= '0';
		-- devider
		buf_next <= buf;
		dbuf_next <= dbuf;
		sm_next <= sm;
		once_next <= once;
		err_div_by_zero_alu <= '0';
		err_overflow <= '0';
		op1_tmp := "00000000000000000000000000000000";
		op2_tmp := "00000000000000000000000000000000";
		neg_tmp_next <= neg_tmp;

		case alu_state is
		when	READY =>
			buf_next <= (others => '0');
			dbuf_next <= (others => '0');
			sm_next <= 0;
			once_next <= '0';
			neg_tmp_next <= '0';
	
			operation_done <= '0';	
			err_div_by_zero_alu <= '0';
			err_overflow <= '0';
			sum_tmp_next <= "000000000000000000000000000000000000000000000000000000000000000";
			sum <= "000000000000000000000000000000000000000000000000000000000000000";
			op1_tmp := "00000000000000000000000000000000";
			op2_tmp := "00000000000000000000000000000000";
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
						err_div_by_zero_alu <= '1';
						alu_state_next <= READY;
				
					else
						if(operand_1 < 0 and operand_2 < 0)
						then
							neg_tmp_next <= '0';	
							op1_tmp := resize(operand_1 * (-1), 32);
							op2_tmp := resize(operand_2 * (-1), 32);
						elsif(operand_1 < 0)
						then
							neg_tmp_next <= '1';	
							op1_tmp := resize(operand_1 * (-1), 32);
							op2_tmp := operand_2;
						elsif(operand_2 < 0)
						then
							neg_tmp_next <= '1';	
							op1_tmp := operand_1;
							op2_tmp := resize(operand_2 * (-1), 32);
						else
							op1_tmp := operand_1;
							op2_tmp := operand_2;
						end if;
						if once = '0' then
								once_next <= '1';
								case sm is
									when 0 =>
								buf_next(63 downto 32) <= (others => '0');
							--	buf_next(31 downto 0) <= std_logic_vector(operand_1);
							--	dbuf_next <= std_logic_vector(operand_2);
								buf_next(31 downto 0) <= std_logic_vector(op1_tmp);
								dbuf_next <= std_logic_vector(op2_tmp);
										sm_next <= sm + 1;
									when others =>
										if buf((2 * SIZE - 2) downto (SIZE - 1)) >= dbuf then
					buf_next(63 downto 32) <= '0' & std_logic_vector(signed(buf((2 * SIZE - 3) downto (SIZE - 1))) - signed(dbuf((SIZE - 2) downto 0)));
					buf_next(31 downto 0) <= buf(30 downto 0) & '1';
										else
											buf_next <= std_logic_vector(buf((2 * SIZE - 2) downto 0)) & '0';
										end if;
										if sm /= SIZE then
											sm_next <= sm + 1;
										else
											alu_state_next <= DONE_POST;
											sm_next <= 0;
											buf_next(63 downto 32) <= (others => '0');
										end if;
								end case;
							else
								once_next <= '0';
							end if;
						end if;
				end if;
	
		when DONE_POST =>
			alu_state_next <= DONE;
			if(neg_tmp = '0')
			then
				sum_tmp_next <= resize(signed(buf(31 downto 0)), 63);
			else
				sum_tmp_next <= resize(signed(buf(31 downto 0)) * (-1), 63);
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
