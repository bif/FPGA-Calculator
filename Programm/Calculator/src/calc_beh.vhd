library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.itoa_pkg.all;

architecture beh of calc is
	type CALC_STATE_TYPE is (READY, MANAGE, FINISH, WAIT4PARSER, OP_PUNKT, OP_STRICH, INVALID);
	signal calc_state		: CALC_STATE_TYPE;
	signal calc_state_next		: CALC_STATE_TYPE;
	signal start_calc_old		: std_logic;
	signal start_calc_old_next	: std_logic;
	signal need_input_next		: std_logic;
	signal parse_ready_old		: std_logic;
	signal parse_ready_old_next	: std_logic;
	signal operation_end_old	: std_logic;
	signal operation_end_old_next	: std_logic;
	signal error_calc_next		: std_logic;
	signal start_decode_bcd		: std_logic;
	
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

	signal calculation		: integer range -2147483647 to 2147483647 := 0;

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
			error_calc	<= '0';
			buffer_punkt <= "000000000000000000000000000000000000000000000000000000000000000";
			buffer_strich <= "000000000000000000000000000000000000000000000000000000000000000";
			operator_strich <= "00";
			operator_punkt <= "00";
			op_punkt_flag <= '0';
			op_strich_flag <= '0';
		elsif(sys_clk'event and sys_clk = '1')
		then
			calc_state <= calc_state_next;
			start_calc_old <= start_calc_old_next;
			need_input <= need_input_next;
			parse_ready_old <= parse_ready_old_next;
			operation_end_old <= operation_end_old_next;
			error_calc <= error_calc_next;
			buffer_punkt <= buffer_punkt_next;
			buffer_strich <= buffer_strich_next;
			operator_strich <= operator_strich_next;
			operator_punkt <= operator_punkt_next;
			op_punkt_flag <= op_punkt_flag_next;
			op_strich_flag <= op_strich_flag_next;
		end if;

	end process;

	nextstate : process(calc_state, start_calc, start_calc_old, parse_ready, parse_ready_old, operator, operation_end, operation_end_old, buffer_punkt, buffer_strich, operator_strich, operator_punkt, op_punkt_flag, op_strich_flag, operand)
	variable erg_tmp	:	signed(62 downto 0) := "000000000000000000000000000000000000000000000000000000000000000";
	begin
		erg_tmp := "000000000000000000000000000000000000000000000000000000000000000";
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

		case calc_state is
			when READY =>
				if(start_calc /= start_calc_old and start_calc = '1')
				then
					calc_state_next <= MANAGE;
				end if;
				op_punkt_flag_next <= '0';
				op_strich_flag_next <= '0';

			when MANAGE =>
				
				if(buffer_punkt > OPERAND_MAX or buffer_punkt < OPERAND_MIN or buffer_strich > OPERAND_MAX or buffer_strich < OPERAND_MIN)
				then
					calc_state_next <= INVALID;	-- overflow
				else
					calc_state_next <= WAIT4PARSER;
				end if;

			when WAIT4PARSER =>
				if(parse_ready /= parse_ready_old and parse_ready = '1')
				then
					if(operator = "00" or operator = "01")	
					then
						calc_state_next <= OP_STRICH;
					elsif(operator = "10" or operator = "11")	
					then
						calc_state_next <= OP_PUNKT;
					end if;
				end if;
				
				if(operation_end /= operation_end_old and operation_end = '1')
				then
					calc_state_next <= FINISH;
				end if;

			when OP_PUNKT =>
				if(op_punkt_flag = '0')		-- keine operation vorgemerkt
				then
					buffer_punkt_next <= resize(operand, 63);
					operator_punkt_next <= operator;
					op_punkt_flag_next <= '1';
					calc_state_next <= MANAGE;
				elsif(op_punkt_flag = '1')
				then
					operator_punkt_next <= operator;
					if(operator_punkt = "10")		-- multiplikation
					then
						buffer_punkt_next <= resize(buffer_punkt * operand, 63);
						calc_state_next <= MANAGE;
					elsif(operator_punkt = "11")			-- division
					then
						if(operand = 0)
						then
							calc_state_next <= INVALID;
						else
--							buffer_punkt_next <= resize(buffer_punkt / operand, 63);
							calc_state_next <= MANAGE;
						end if;
					
					end if;
				end if;
								
			when OP_STRICH =>

				if(op_strich_flag = '0' and op_punkt_flag = '0')	-- nichts vorgemerkt
				then
					buffer_strich_next <= resize(operand, 63);
					operator_punkt_next <= operator;
					op_strich_flag_next <= '1';
					calc_state_next <= MANAGE;

				elsif(op_strich_flag = '0' and op_punkt_flag = '1')	-- punktrechnung vorgemerkt
				then
					op_strich_flag_next <= '1';
					op_punkt_flag_next <= '0';
					if(operator_punkt = "10")			-- multiplikation vorgemerkt
					then
						buffer_strich_next <= resize(buffer_punkt * operand, 63);
						calc_state_next <= MANAGE;
					elsif(operator_punkt = "11")			-- division vorgemerkt
					then
						if(operand = 0)
						then
							calc_state_next <= INVALID;
						else
--							buffer_strich_next <= resize(buffer_punkt / operand, 63);
							calc_state_next <= MANAGE;
						end if;
					end if;

				elsif(op_strich_flag = '1' and op_punkt_flag = '0')	-- strichrechchnung vorgemerkt
				then
					if(operator_strich = "00")
					then
						buffer_strich_next <= resize(buffer_strich + operand, 63);
					elsif(operator_strich = "01")
					then
						buffer_strich_next <= resize(buffer_strich - operand, 63);
					end if;
					calc_state_next <= MANAGE;

				elsif(op_strich_flag = '1' and op_punkt_flag = '1')	-- punkt UND strichrechnung vorgemerkt
				then
					-- zuerst punktrechnung auflösen...
					if(operator_punkt = "10")			
					then					
						erg_tmp := resize(buffer_punkt, 31) * operand;
					elsif(operator_punkt = "11")
					then
						if(operand = 0)
						then
							calc_state_next <= INVALID;		
						else
--							erg_tmp := buffer_punkt / operand;
						end if;
					end if;
					
					-- danach strichrechnung auflösen
					if(erg_tmp < OPERAND_MIN or erg_tmp > OPERAND_MAX)
					then
						calc_state_next <= INVALID;
					elsif(operator_strich = "00")
					then
						buffer_strich_next <= buffer_strich + erg_tmp;
						calc_state_next <= MANAGE;
					elsif(operator_strich = "01")
					then
						buffer_strich_next <= buffer_strich - erg_tmp;
						calc_state_next <= MANAGE;
					end if;
					op_punkt_flag_next <= '0';
					
				end if;
				operator_strich_next <= operator;

			when INVALID =>
				calc_state_next <= READY;
			when FINISH =>
				calc_state_next <= READY;

		end case;	
	end process;

	process(calc_state, buffer_strich)
	begin
		calculation <= 0;
		start_decode_bcd <= '0';
		error_calc_next <= '0';
		need_input_next <= '0';
		case calc_state is
		when READY => 
			need_input_next <= '0';
			error_calc_next <= '0';
			start_decode_bcd <= '0';
		when MANAGE =>
			need_input_next <= '1';
		when WAIT4PARSER =>
			need_input_next <= '0';
		when OP_PUNKT =>
			need_input_next <= '0';
		when OP_STRICH =>
			need_input_next <= '0';
		when INVALID =>
			need_input_next <= '0';
			error_calc_next <= '1';
		when FINISH =>
			need_input_next <= '0';
			calculation <= to_integer(buffer_strich);
			start_decode_bcd <= '1';
		end case;
	end process;

	itoa_inst :     itoa
	port map
	(
		sys_clk         =>      sys_clk,
		sys_res_n       =>      sys_res_n,
		int_in          =>	calculation,
		start_decode    =>	start_decode_bcd
--		out_0           =>
--		out_1           =>
--		out_2           =>
--		out_3           =>
--		out_4           =>
--		out_5           =>
--		out_6           =>
--		out_7           =>
--		out_8           =>
--		out_9           =>
--		out_10          =>
--		decode_ready    =>
--		sign            =>
	);

end architecture beh;
