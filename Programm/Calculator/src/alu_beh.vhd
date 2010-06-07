library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

architecture beh of alu is
	constant ALL_ZERO : std_Logic_vector(31 downto 0) := "00000000000000000000000000000000";
	
	signal ni : std_logic_vector(63 downto 0) := (others => '0');
	signal sub : std_logic_vector(63 downto 0) := (others => '0');
	signal n : std_logic_vector(63 downto 0) := (others => '0');
	signal i : std_logic_vector(63 downto 0) := (others => '0');
	signal d : std_logic_vector(63 downto 0) := (others => '0');
	signal d_int : std_logic_vector(31 downto 0) := (others => '0');
	signal counter : std_logic_vector(5 downto 0) := (others => '0');
	-- attribute syn_keep : boolean;
	-- attribute syn_keep of d_int, N : signal is true;
	signal div_ready : Std_Logic := '0'; 
	signal load, load_next, load_old : std_logic := '0';
	signal Quotient : signed(31 downto 0) := (others => '0');
	signal rest : std_logic_vector(31 downto 0) := (others => '0');
	signal tmp_var : std_logic_vector(31 downto 0) := (others => '0');

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
			counter <= "111111";
			div_ready <= '0';
			div_ready <= '0';
			start_operation_old <= '0';
			alu_state <= READY;
			sum_tmp <= "000000000000000000000000000000000000000000000000000000000000000";
		elsif(rising_edge(sys_clk))
		then
			start_operation_old <= start_operation_old_next;
			alu_state <= alu_state_next;
			sum_tmp <= sum_tmp_next;
			
			--devider
			load <= load_next;
			load_old <= load_next;
			if load = '1' then
				Counter <= (others=>'0');
				div_ready <= '0';
			else
				if counter="011111" then
					counter <="111111";
					div_ready <= '1';
				elsif counter="011110" then
					counter <= std_Logic_vector(unsigned(counter) + 1);
					div_ready <= '0';
				elsif counter="111111" then
					div_ready <='1';
				else
					counter <= std_Logic_vector(unsigned(counter) + 1);
					div_ready <='0';
				end if;
			end if;
		end if;
	end process;

	process(div_ready, load ,start_operation, start_operation_old, alu_state, operand_1, operand_2, operator, sum_tmp)
	begin
		start_operation_old_next <= start_operation;
		alu_state_next <= alu_state;
		sum_tmp_next <= sum_tmp;
		sum <= "000000000000000000000000000000000000000000000000000000000000000";
		operation_done <= '0';
		load_next <= '0';

		case alu_state is
		when	READY =>
		
			operation_done <= '0';	
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
					if load = '0' then
						load_next <= '1';	
					end if;				
					if div_ready = '1' then
						alu_state_next <= DONE;
						sum_tmp_next <= resize(Quotient, 63);
					end if;				
				end if;

		when	DONE =>	
			alu_state_next <= READY;
			operation_done <= '1';
			sum <= sum_tmp;

		end case;
	end process;


-- processes for divider
	process(sys_res_n, div_ready, n ,d )
	begin
		if sys_res_n = '1' then
			sub <= (others=>'0');
		elsif div_ready = '0' then
			sub <= std_logic_vector(signed(n) - signed(d));
		else
			sub <= (others=>'0');
		end if;
	end process;

	process(sys_clk, sys_res_n, div_ready)
	begin
		if sys_res_n = '1' then
			n(63 downto 0) <= (others=>'0');
			D_Int(31 downto 0) <= (others=>'0');
		elsif rising_edge(sys_clk) then
			if load /= load_old and load = '1' then
				n(63 downto 0) <= NI(63 downto 0);
				D_int(31 downto 0) <= std_Logic_vector(operand_2);
			else
				if div_ready ='0' then
					n(63 downto 0) <= I(63 downto 0);
				end if;
			end if;
		end if;
	end process;

	process(sys_res_n, sub, n, div_ready)
	begin
		if sys_res_n = '1' then
			I <= (others =>'0');
		elsif div_ready ='0' then
			if sub(47) = '1' then
				I(0) <='0';
				I(63 downto 1) <= N(62 downto 0);
			else
				I(0) <= '1';
				I(63 downto 1) <= sub(62 downto 0);
			end if;
		else
			I <= (others=>'0');
		end if;
	end process;


	NI(63 downto 0) <= ALL_ZERO & std_logic_vector(operand_1);
	D(30 downto 0) <= "0000000000000000000000000000000";
	D(62 downto 31) <= d_int;
	D(63) <= '0';
	tmp_var <= n(31 downto 0);
	Quotient <= signed(tmp_var);
	rest <=n(63 downto 32); 

end architecture beh;
