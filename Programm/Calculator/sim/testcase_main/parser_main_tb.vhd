library ieee;
use ieee.std_logic_1164.all;
use work.parser_pkg.all;
use work.sp_ram_pkg.all;
use ieee.numeric_std.all;
use work.main_pkg.all;



entity parser_tb is

end parser_tb;

architecture sim of parser_tb is

	constant LB_DATA_WIDTH : integer := 8;
	constant LB_ADDR_WIDTH : integer := 8;
	constant QUARTZ_PERIOD : time := 33 ns;
	constant QUARTZ_PLL_PERIOD : time := 2*40 ns;
	constant TEST_ARRAY_WIDTH : integer := 12;

	-- subtype TEST_ARRAY_CELL is std_logic_vector(1 downto 0); -- 8 bit for every ram cell(7 would be enough, but its easier this way(casting...))
	-- type TEST_ARRAY is array (TEST_ARRAY_WIDTH - 1 downto 0) of TEST_ARRAY_CELL;

  --signal test_array : TEST_ARRAY := (x"00", x"01", others => xW "5+8-3";

	signal test_string : string(1 to (TEST_ARRAY_WIDTH)) := "1           ";
	--signal test_string : string(1 to (TEST_ARRAY_WIDTH)) := "590+ 777 * 4";
	signal clk : std_logic;
	signal reset : std_logic;
	signal lb_addr_out_sig, lb_addr_wr_sig, mem_debug_addr : std_logic_vector(LB_ADDR_WIDTH - 1 downto 0);
	signal lb_data_wr_sig, lb_data_out_sig, mem_debug_data : std_logic_vector(LB_DATA_WIDTH - 1  downto 0);
	signal operand_sig : signed(31 downto 0);
	signal operator_sig : std_logic_vector(1 downto 0);
	signal end_parse, end_parse_next, end_of_op_sig, parse_ready_sig, read_next_n_o_sig, get_next, enable_lb_sig, start_calc_sig : std_logic := '0';
	signal btn_a_sync : std_logic := '1';
	signal lb_wr_sig, uart_top_rx_sig, uart_top_tx_sig : std_logic;

	signal bcd_buf_sig			:	unsigned(39 downto 0);
	signal decode_ready_sig			:	std_logic := '0';

	-- calc_inst - signals / constants
	constant	OPERAND_MAX		:	signed(31 downto 0) := "01111111111111111111111111111111";
	constant	OPERAND_MIN		:	signed(31 downto 0) := "10000000000000000000000000000001";
	constant	RESULT_MAX		:	signed(62 downto 0) := "011111111111111111111111111111111111111111111111111111111111111";
	constant	RESULT_MIN		:	signed(62 downto 0) := "100000000000000000000000000000000000000000000000000000000000001";

	signal 		operator_top		:	std_logic_vector(1 downto 0);
	signal		operation_end_top	:	std_logic;
	signal		error_calc_top		:	std_logic;
	signal		error_parser_top		:	std_logic;
	signal		negative		:	std_logic;
	signal		calc_ready_top		:	std_logic;
	signal		sign_bcd_top		:	std_logic;



component calc is
	generic
	(
		OPERAND_MAX	:	signed(31 downto 0) := "01111111111111111111111111111111";
		OPERAND_MIN	:	signed(31 downto 0) := "10000000000000000000000000000001";
		RESULT_MAX      :       signed(62 downto 0) := "011111111111111111111111111111111111111111111111111111111111111";
		RESULT_MIN      :       signed(62 downto 0) := "100000000000000000000000000000000000000000000000000000000000001"
	);
	port
	(
		sys_clk         :       in	std_logic;
		sys_res_n       :       in	std_logic;
		parse_ready	:       in	std_logic;
		start_calc	:       in	std_logic;
		sign_bcd_calc           : out   std_logic;
		operation_end	:       in	std_logic;
		operand         :       in	signed(31 downto 0);
		operator        :       in	std_logic_vector(1 downto 0)  := "00";
		need_input	:	out	std_logic;
		calc_ready	:	out	std_logic;
		error_calc		:	out	std_logic;
		error_parser		:	in	std_logic;
		decode_ready_calc	:       out     std_logic;
		bcd_buf			:	out	unsigned(39 downto 0)
	);
end component calc;

begin  -- behav


	calc_inst : calc
	generic map
	(
		OPERAND_MAX	=>	OPERAND_MAX,
		OPERAND_MIN	=>	OPERAND_MIN,	
		RESULT_MAX	=>	RESULT_MAX,
		RESULT_MIN	=>	RESULT_MIN
	)
	port map
	(
		sys_clk		=>	clk,
		sys_res_n	=>	reset,
		parse_ready	=>	parse_ready_sig,	-- IN:	new unit(operand + operator) is ready to be read
		decode_ready_calc =>	decode_ready_sig,
		start_calc	=>	start_calc_sig,
		operation_end	=>	end_of_op_sig,
		operand		=>	operand_sig,
		operator	=>	operator_sig,
		need_input	=>	read_next_n_o_sig,	-- OUT: triggers new parse 
		error_calc	=>	error_calc_top,
		error_parser	=>	error_parser_top,
		sign_bcd_calc   =>	sign_bcd_top,
		bcd_buf		=>	bcd_buf_sig
	);




  tp_parser: parser
	generic map
	(
    RESET_VALUE => '0',
    ADDR_WIDTH => LB_ADDR_WIDTH,
    DATA_WIDTH => LB_DATA_WIDTH
  )  
	port map 
	(
		sys_clk => clk,
		sys_res_n => reset, 
		read_next_n_o => read_next_n_o_sig,
		data_in => lb_data_out_sig, 
		addr_lb => lb_addr_out_sig,
		operand => operand_sig, 
		operator => operator_sig,
		leading_sign => negative,
		end_of_operation => end_of_op_sig,
		parse_ready => parse_ready_sig
	);

	tb_line_buf_ram : sp_ram
	generic map
	(
		ADDR_WIDTH => LB_ADDR_WIDTH,
		DATA_WIDTH => LB_DATA_WIDTH
	)
	port map
	(
		clk => clk,
		address_out => lb_addr_out_sig,
		data_out => lb_data_out_sig,
		address_out_1 => mem_debug_addr,
		data_out_1 => mem_debug_data,
		address_wr => lb_addr_wr_sig,
		wr => lb_wr_sig,
		data_wr => lb_data_wr_sig
	);



	main_inst : main
	generic map
	(
		RESET_VALUE	=>	'0',
		ADR_WIDTH	=>	LB_ADDR_WIDTH,
		DAT_WIDTH	=>	LB_DATA_WIDTH
	)
	port map
	(
		sys_clk		=>	clk,
		sys_res_n	=>	reset,
		sense		=>	btn_a_sync,
		uart_main_rx	=>	uart_top_rx_sig,
		uart_main_tx	=>	uart_top_tx_sig,
		start_calc	=>	start_calc_sig,
		lb_addr		=>	mem_debug_addr,
		lb_data		=>	mem_debug_data,
		--decode_ready	=>	calc_ready_top,
		decode_ready_main	=>	decode_ready_sig,
		lb_enable	=>	enable_lb_sig,
		sign_bcd_main	=>	sign_bcd_top,
		bcd_buf		=>	bcd_buf_sig,
		error_parser	=>	error_parser_top,
		error_calc	=>	error_calc_top
	);


  process
  begin  -- process
    clk <= '0';
    wait for QUARTZ_PERIOD / 2;
    clk <= '1';
    wait for QUARTZ_PERIOD / 2;
  end process;


	process
		variable i :  std_logic_vector(LB_ADDR_WIDTH - 1 downto 0) := (others => '0');
		variable c : character;
--		variable u :  std_logic_vector(4096 - 1 downto 0) := (others => '0');

  begin

    reset <= '0';
    wait for 10 ns;
    reset <= '1';
		get_next <= '0';
    wait for 10 ns;

		for i in 1 to 71 loop
			mem_debug_addr <= std_logic_vector(to_unsigned((i - 1), 8));
			lb_addr_wr_sig <= std_logic_vector(to_unsigned((i - 1), 8));
			lb_wr_sig <= '1';
			if i <= TEST_ARRAY_WIDTH then
				-- Test-String in Speicher schreiben 
				c := test_string(i);
				lb_data_wr_sig <= std_logic_vector(to_unsigned(character'pos(c),8));
				wait for 200 ns;
			else
				lb_data_wr_sig <= x"20";
				wait for 200 ns;
			end if;
		end loop;

    i := (others => '0');
		lb_wr_sig <= '0';


		start_calc_sig <= '1';
		wait for QUARTZ_PERIOD;
		start_calc_sig <= '0'; 
-- wait until calc ready
		wait for 500 us;

		start_calc_sig <= '1';
		wait for QUARTZ_PERIOD;
		start_calc_sig <= '0'; 
-- wait until calc ready
		wait for 500 us;

		start_calc_sig <= '1';
		wait for QUARTZ_PERIOD;
		start_calc_sig <= '0'; 
-- wait until calc ready
		wait for 500 us;


		




--to simulate the calculator 
--		while end_parse = '0' loop
--			mem_debug_addr <= lb_addr_out_sig;
--			get_next <= '1';
--			wait for 100 ns;
--			get_next <= '0';
--			wait for 400 ns;
--		end loop;

-- Memarray augeben

--		while unsigned(u) < 20 loop
--			wait for 200 ns;
--			mem_debug_addr <= u;
--			u := std_logic_vector(unsigned(u) + 1 );
--			wait for 200 ns;
--		end loop;


   wait;
  end process;

-- to stop simulaton of calculator
--	process(end_of_op_sig)
--	begin
--		if end_of_op_sig = '1' then
--			end_parse_next <= '1';
--		end if;
--	end process;


--  process(clk)

--  begin

--   if (clk'event and clk = '1') then
    -- synchrone part to simulate teh calculator
--		if get_next = '1' then
--			read_next_n_o_sig <= '1';
--		else
--			read_next_n_o_sig <= '0';
--    end if; 
--		end_parse <= end_parse_next;
--	end if;
--  end process;


end architecture sim;

