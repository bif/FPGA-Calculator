library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.itoa_pkg.all;
use work.alu_pkg.all;

architecture beh of calc is
	type CALC_STATE_TYPE is (READY, MANAGE, FINISH, WAIT4PARSER, OP_PUNKT, OP_STRICH, INVALID, ERR_DIVBYZERO, ERR_OVERFLOW, ERR_PARSER, WAIT4ALU_STRICH, WAIT4ALU_PUNKT, WAIT4ALU_TMP, WAIT4ALU_TMP_2);
	signal calc_state		: CALC_STATE_TYPE;
	signal calc_state_next		: CALC_STATE_TYPE;
	signal start_calc_old		: std_logic;
	signal start_calc_old_next	: std_logic;
	signal need_input_next		: std_logic;
	signal parse_ready_old		: std_logic;
	signal parse_ready_old_next	: std_logic;
	signal operation_end_old	: std_logic;
	signal operation_end_old_next	: std_logic;
	signal start_decode_bcd		: std_logic;
	signal decode_ready_old		: std_logic;
	signal decode_ready_old_next	: std_logic;
	signal decode_ready_sig		: std_logic;

	signal bcd_buf_next		: unsigned(39 downto 0);
	signal operator_calc		: std_logic_vector(1 downto 0) := "00";
	signal operator_calc_next	: std_logic_vector(1 downto 0) := "00";
	signal start_operation_calc	: std_logic := '0';
	signal start_operation_calc_next: std_logic := '0';
	signal operation_done_sig	: std_logic := '0';
	signal operation_done_old	: std_logic := '0';
	signal operation_done_old_next	: std_logic := '0';
	signal err_div_by_zero_calc	: std_logic := '0';
	signal err_div_by_zero_calc_old	: std_logic := '0';
	signal err_div_by_zero_calc_old_next	: std_logic := '0';
	signal err_overflow_calc	: std_logic := '0';
	signal err_overflow_old		: std_logic := '0';
	signal err_overflow_old_next	: std_logic := '0';
	signal sum_tmp			: signed(62 downto 0);
	signal sum_tmp_next		: signed(62 downto 0);
	signal operand_1		: signed(31 downto 0);
	signal operand_1_next		: signed(31 downto 0);
	signal operand_2		: signed(31 downto 0);
	signal operand_2_next		: signed(31 downto 0);
	signal operand_tmp		: signed(31 downto 0);
	signal operand_tmp_next		: signed(31 downto 0);
	signal buffer_strich		: signed(62 downto 0);
	signal buffer_strich_next	: signed(62 downto 0);
	signal buffer_punkt		: signed(62 downto 0);
	signal buffer_punkt_next	: signed(62 downto 0);
	signal operator_punkt		: std_logic_vector(1 downto 0);
	signal operator_punkt_next	: std_logic_vector(1 downto 0);
	signal operator_strich		: std_logic_vector(1 downto 0);
	signal operator_strich_next	: std_logic_vector(1 downto 0);
	signal op_strich_flag		: std_logic;
	signal op_strich_flag_next	: std_logic;
	signal op_punkt_flag		: std_logic;
	signal op_punkt_flag_next	: std_logic;
	signal calc_ready_next		: std_logic;

	signal calculation		: integer range -2147483647 to 2147483647 := 0;

	signal out_0_sig		: unsigned(3 downto 0) := "0000";
	signal out_1_sig		: unsigned(3 downto 0) := "0000";
	signal out_2_sig		: unsigned(3 downto 0) := "0000";
	signal out_3_sig		: unsigned(3 downto 0) := "0000";
	signal out_4_sig		: unsigned(3 downto 0) := "0000";
	signal out_5_sig		: unsigned(3 downto 0) := "0000";
	signal out_6_sig		: unsigned(3 downto 0) := "0000";
	signal out_7_sig		: unsigned(3 downto 0) := "0000";
	signal out_8_sig		: unsigned(3 downto 0) := "0000";
	signal out_9_sig		: unsigned(3 downto 0) := "0000";
	signal sign_bcd_sig		: std_logic := '0';
	signal ready_flag		: std_logic := '0';
	signal ready_flag_next		: std_logic := '0';

begin
	process(sys_clk, sys_res_n)
	begin
		if(sys_res_n = '0')
		then
			calc_state <= READY;
			start_calc_old <= '0';
			need_input <= '0';
			parse_ready_old <= '0';
			operation_end_old <= '0';
			buffer_punkt <= "000000000000000000000000000000000000000000000000000000000000000";
			buffer_strich <= "000000000000000000000000000000000000000000000000000000000000000";
			operator_strich <= "00";
			operator_punkt <= "00";
			op_punkt_flag <= '0';
			op_strich_flag <= '0';
			decode_ready_old <= '0';
			calc_ready <= '0';
			ready_flag <= '0';
			operand_1 <= "00000000000000000000000000000000";
			operand_2 <= "00000000000000000000000000000000";
			operation_done_old <= '0';
			operator_calc <= "00";
			start_operation_calc <= '0';
			err_div_by_zero_calc_old <= '0';
			err_overflow_old <= '0';
			bcd_buf <= (others => '0');
			operand_tmp <= (others => '0');
		elsif(sys_clk'event and sys_clk = '1')
		then
			calc_state <= calc_state_next;
			start_calc_old <= start_calc_old_next;
			need_input <= need_input_next;
			parse_ready_old <= parse_ready_old_next;
			operation_end_old <= operation_end_old_next;
			buffer_punkt <= buffer_punkt_next;
			buffer_strich <= buffer_strich_next;
			operator_strich <= operator_strich_next;
			operator_punkt <= operator_punkt_next;
			op_punkt_flag <= op_punkt_flag_next;
			op_strich_flag <= op_strich_flag_next;
			decode_ready_old <= decode_ready_old_next;
			calc_ready <= calc_ready_next;
			ready_flag <= ready_flag_next;
			operand_1 <= operand_1_next;
			operand_2 <= operand_2_next;
			operation_done_old <= operation_done_old_next;
			operator_calc <= operator_calc_next;
			start_operation_calc <= start_operation_calc_next;
			err_div_by_zero_calc_old <= err_div_by_zero_calc_old_next;
			err_overflow_old <= err_overflow_old_next;
			bcd_buf <= bcd_buf_next;
			operand_tmp <= operand_tmp_next;
		end if;

	end process;

	nextstate : process(calc_state, start_calc, start_calc_old, parse_ready, parse_ready_old, operation_end, operation_end_old, buffer_punkt, buffer_strich, operator_strich, operator_punkt, op_punkt_flag, op_strich_flag, operand, decode_ready_sig, decode_ready_old, ready_flag, operand_1, operand_2, operation_done_sig, operation_done_old, sum_tmp, operator_calc, operator, err_div_by_zero_calc, err_div_by_zero_calc_old, err_overflow_calc, err_overflow_old, errcode_parser, negative, operand_tmp)
	begin
		calc_state_next <= calc_state;
		start_calc_old_next <= start_calc;		
		parse_ready_old_next <= parse_ready;
		operation_end_old_next <= operation_end;
		operator_strich_next <= operator_strich;
		operator_punkt_next <= operator_punkt;
		buffer_punkt_next <= buffer_punkt;
		buffer_strich_next <= buffer_strich;
		op_punkt_flag_next <= op_punkt_flag;
		op_strich_flag_next <= op_strich_flag;
		decode_ready_old_next <= decode_ready_sig;
		ready_flag_next <= ready_flag;
		calc_ready_next <= '0';
		operand_1_next <= operand_1;
		operand_2_next <= operand_2;
		operation_done_old_next <= operation_done_sig;
		operator_calc_next <= operator_calc;
		decode_ready_calc <= '0';
		err_div_by_zero_calc_old_next <= err_div_by_zero_calc;
		err_overflow_old_next <= err_overflow_calc;
		operand_tmp_next <= operand_tmp;

		case calc_state is
			when READY =>
				op_punkt_flag_next <= '0';
				op_strich_flag_next <= '0';
				calc_ready_next <= '0';
				ready_flag_next <= '0';
				buffer_punkt_next <= "000000000000000000000000000000000000000000000000000000000000000";
				buffer_strich_next <= "000000000000000000000000000000000000000000000000000000000000000";
				operator_strich_next <= "00";
				operator_punkt_next <= "00";

				if(start_calc /= start_calc_old and start_calc = '1')
				then
					calc_state_next <= MANAGE;
				end if;

			when MANAGE =>
				calc_state_next <= WAIT4PARSER;

			when WAIT4PARSER =>
				if(errcode_parser = "00")
				then
					if(parse_ready /= parse_ready_old and parse_ready = '1')
					then
						if(negative = '1')
						then
							operand_tmp_next <= resize(operand * (-1), 32);
						else
							operand_tmp_next <= operand;
						end if;
					
						if(operator = "00" or operator = "01")	
						then
							calc_state_next <= OP_STRICH;
						elsif(operator = "10" or operator = "11")	
						then
							calc_state_next <= OP_PUNKT;
						end if;
					elsif(ready_flag = '1')
					then
							calc_state_next <= FINISH;
					end if;
				
					if(operation_end /= operation_end_old and operation_end = '1')		-- just got the LAST operand - remember it!
					then
						ready_flag_next <= '1';
					end if;
				else
					calc_state_next <= ERR_PARSER;
				end if;

			when OP_PUNKT =>
				if(op_punkt_flag = '0')		-- keine operation vorgemerkt
				then
			--buffer_punkt_next <= resize(operand, 63);
			buffer_punkt_next <= resize(operand_tmp, 63);
					op_punkt_flag_next <= '1';
					calc_state_next <= MANAGE;
					operator_punkt_next <= operator;
				elsif(op_punkt_flag = '1')
				then
						operand_1_next <= resize(buffer_punkt, 32);
			--operand_2_next <= operand;
			operand_2_next <= operand_tmp;
						operator_calc_next <= operator_punkt;
						calc_state_next <= WAIT4ALU_PUNKT;
				end if;
								
			when OP_STRICH =>

				if(op_strich_flag = '0' and op_punkt_flag = '0')	-- nichts vorgemerkt
				then
			--buffer_strich_next <= resize(operand, 63);
			buffer_strich_next <= resize(operand_tmp, 63);
					op_strich_flag_next <= '1';
					operator_strich_next <= operator;
					calc_state_next <= MANAGE;						-- ACHTUNG, KOENNTE PROBLEME MACHEN WENN START_OPERATION = '1' 

				elsif(op_strich_flag = '0' and op_punkt_flag = '1')	-- punktrechnung vorgemerkt
				then
					op_strich_flag_next <= '1';
					op_punkt_flag_next <= '0';

					operand_1_next <= resize(buffer_punkt, 32);
			--operand_2_next <= operand;
			operand_2_next <= operand_tmp;
					operator_calc_next <= operator_punkt;
					calc_state_next <= WAIT4ALU_STRICH;
					operator_strich_next <= operator;

				elsif(op_strich_flag = '1' and op_punkt_flag = '0')	-- strichrechchnung vorgemerkt
				then
					operand_1_next <= resize(buffer_strich, 32);
			--operand_2_next <= operand;
			operand_2_next <= operand_tmp;
					operator_calc_next <= operator_strich;
					calc_state_next <= WAIT4ALU_STRICH;
					operator_strich_next <= operator;


				elsif(op_strich_flag = '1' and op_punkt_flag = '1')	-- punkt UND strichrechnung vorgemerkt
				then
					operand_1_next <= resize(buffer_punkt, 32);
			--operand_2_next <= operand;
			operand_2_next <= operand_tmp;
					operator_calc_next <= operator_punkt;
					calc_state_next <= WAIT4ALU_TMP;					
					op_punkt_flag_next <= '0';
				end if;

			when WAIT4ALU_PUNKT =>
				if(err_div_by_zero_calc /= err_div_by_zero_calc_old and err_div_by_zero_calc = '1')
				then
					calc_state_next <= ERR_DIVBYZERO;
				end if;

				if(err_overflow_calc /= err_overflow_old and err_overflow_calc = '1')
				then
					calc_state_next <= ERR_OVERFLOW;
				end if;

				if(operation_done_sig /= operation_done_old and operation_done_sig = '1')
				then
					buffer_punkt_next <= sum_tmp;	
					calc_state_next <= MANAGE;
				end if;

			when WAIT4ALU_STRICH =>
				if(err_div_by_zero_calc /= err_div_by_zero_calc_old and err_div_by_zero_calc = '1')
				then
					calc_state_next <= ERR_DIVBYZERO;
				end if;

				if(err_overflow_calc /= err_overflow_old and err_overflow_calc = '1')
				then
					calc_state_next <= ERR_OVERFLOW;
				end if;

				if(operation_done_sig /= operation_done_old and operation_done_sig = '1')
				then
					buffer_strich_next <= sum_tmp;	
					calc_state_next <= MANAGE;
				end if;

			when WAIT4ALU_TMP =>				
				if(err_div_by_zero_calc /= err_div_by_zero_calc_old and err_div_by_zero_calc = '1')
				then
					calc_state_next <= ERR_DIVBYZERO;
				end if;

				if(err_overflow_calc /= err_overflow_old and err_overflow_calc = '1')
				then
					calc_state_next <= ERR_OVERFLOW;
				end if;

				if(operation_done_sig /= operation_done_old and operation_done_sig = '1')
				then
					--if(sum_tmp < OPERAND_MIN or sum_tmp > OPERAND_MAX)
					--if(sum_tmp > OPERAND_MAX)
					--then
					--	calc_state_next <= ERR_OVERFLOW;
					--else
						operand_1_next <= resize(buffer_strich, 32);
						operand_2_next <= resize(sum_tmp, 32);
						operator_calc_next <= operator_strich;
						calc_state_next <= WAIT4ALU_TMP_2;
					--end if;
				end if;
				
			when WAIT4ALU_TMP_2 =>
--				operator_strich_next <= operator;
				calc_state_next <= WAIT4ALU_STRICH;
				operator_strich_next <= operator;

			when ERR_OVERFLOW =>
				calc_state_next <= READY;
				calc_ready_next <= '1';
				decode_ready_calc <= '1';
			when ERR_DIVBYZERO =>
				calc_state_next <= READY;
				calc_ready_next <= '1';
				decode_ready_calc <= '1';
			when ERR_PARSER =>
				calc_state_next <= READY;
				calc_ready_next <= '1';
				decode_ready_calc <= '1';
			when INVALID =>
				calc_state_next <= READY;
				calc_ready_next <= '1';
				decode_ready_calc <= '1';
			when FINISH =>
				if(decode_ready_old /= decode_ready_sig and decode_ready_sig = '1')
				then
					calc_state_next <= READY;
					calc_ready_next <= '1';
					decode_ready_calc <= '1';
				end if;

		end case;	
	end process;

	process(calc_state, buffer_strich, ready_flag, bcd_buf, out_0_sig, out_1_sig, out_2_sig, out_3_sig, out_4_sig, out_5_sig, out_6_sig, out_7_sig, out_8_sig, out_9_sig, op_punkt_flag)
	begin
		calculation <= 0;
		start_decode_bcd <= '0';
		need_input_next <= '0';
		start_operation_calc_next <= '0';
		
		bcd_buf_next(3 downto 0) <= bcd_buf(3 downto 0);		-- ATTENTION: '1er-stelle' steht GANZ LINKS, danach '10er-stelle', danach 100-er-stelle, ...
		bcd_buf_next(7 downto 4) <= bcd_buf(7 downto 4);
		bcd_buf_next(11 downto 8) <= bcd_buf(11 downto 8);
		bcd_buf_next(15 downto 12) <= bcd_buf(15 downto 12);
		bcd_buf_next(19 downto 16) <= bcd_buf(19 downto 16);
		bcd_buf_next(23 downto 20) <= bcd_buf(23 downto 20);
		bcd_buf_next(27 downto 24) <= bcd_buf(27 downto 24);
		bcd_buf_next(31 downto 28) <= bcd_buf(31 downto 28);
		bcd_buf_next(35 downto 32) <= bcd_buf(35 downto 32);
		bcd_buf_next(39 downto 36) <= bcd_buf(39 downto 36);

		case calc_state is
			when READY => 
				need_input_next <= '0';
				start_decode_bcd <= '0';
			when MANAGE =>
				bcd_buf_next(3 downto 0) <= "0000";		-- ATTENTION: '1er-stelle' steht GANZ LINKS, danach '10er-stelle', danach 100-er-stelle, ...
				bcd_buf_next(7 downto 4) <= "0000";
				bcd_buf_next(11 downto 8) <= "0000";
				bcd_buf_next(15 downto 12) <= "0000";
				bcd_buf_next(19 downto 16) <= "0000";
				bcd_buf_next(23 downto 20) <= "0000";
				bcd_buf_next(27 downto 24) <= "0000";
				bcd_buf_next(31 downto 28) <= "0000";
				bcd_buf_next(35 downto 32) <= "0000";
				bcd_buf_next(39 downto 36) <= "0000";
				start_operation_calc_next <= '0';
				if(ready_flag /= '1')
				then
					need_input_next <= '1';
				end if;
			when WAIT4PARSER =>
				need_input_next <= '0';
			when WAIT4ALU_STRICH =>
			when WAIT4ALU_PUNKT =>
				start_operation_calc_next <= '0';
			when WAIT4ALU_TMP =>				
				start_operation_calc_next <= '0';
			when WAIT4ALU_TMP_2 =>				
				start_operation_calc_next <= '1';
			when OP_PUNKT =>
				need_input_next <= '0';
				start_operation_calc_next <= '1';
			when OP_STRICH =>
				need_input_next <= '0';
				start_operation_calc_next <= '1';
			when INVALID =>
				bcd_buf_next(3 downto 0) <= "1101";			
			when ERR_DIVBYZERO =>
				bcd_buf_next(3 downto 0) <= "1100";			
			when ERR_PARSER =>
				bcd_buf_next(3 downto 0) <= "1110";			
			when ERR_OVERFLOW =>
				bcd_buf_next(3 downto 0) <= "1111";			
		
			when FINISH =>
				need_input_next <= '0';
				start_decode_bcd <= '1';
				calculation <= to_integer(buffer_strich);
			
				bcd_buf_next(3 downto 0) <= out_9_sig;		-- ATTENTION: '1er-stelle' steht GANZ LINKS, danach '10er-stelle', danach 100-er-stelle, ...
				bcd_buf_next(7 downto 4) <= out_8_sig;
				bcd_buf_next(11 downto 8) <= out_7_sig;
				bcd_buf_next(15 downto 12) <= out_6_sig;
				bcd_buf_next(19 downto 16) <= out_5_sig;
				bcd_buf_next(23 downto 20) <= out_4_sig;
				bcd_buf_next(27 downto 24) <= out_3_sig;
				bcd_buf_next(31 downto 28) <= out_2_sig;
				bcd_buf_next(35 downto 32) <= out_1_sig;
				bcd_buf_next(39 downto 36) <= out_0_sig;
		end case;
	end process;

	alu_in	:	alu
	port map
	(
		sys_clk			=>	sys_clk,
		sys_res_n		=>	sys_res_n,
		operand_1		=>	operand_1,
		operand_2		=>	operand_2,
		operator		=>	operator_calc,
		start_operation		=>	start_operation_calc,
		operation_done		=>	operation_done_sig,
		sum			=>	sum_tmp,
		err_div_by_zero_alu	=>	err_div_by_zero_calc,
		err_overflow		=>	err_overflow_calc
	);

	itoa_inst :     itoa
	port map
	(
		sys_clk         =>      sys_clk,
		sys_res_n       =>      sys_res_n,
		int_in          =>	calculation,
		start_decode    =>	start_decode_bcd,
		decode_ready    =>	decode_ready_sig,
		sign            =>	sign_bcd_sig,

		out_0           =>	out_0_sig,
		out_1           =>	out_1_sig,
		out_2           =>	out_2_sig,
		out_3           =>	out_3_sig,
		out_4           =>	out_4_sig,
		out_5           =>	out_5_sig,
		out_6           =>	out_6_sig,
		out_7           =>	out_7_sig,
		out_8           =>	out_8_sig,
		out_9           =>	out_9_sig
	);
	sign_bcd_calc <= sign_bcd_sig;

end architecture beh;
