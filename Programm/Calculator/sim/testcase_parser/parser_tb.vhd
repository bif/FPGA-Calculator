library ieee;
use ieee.std_logic_1164.all;
use work.parser_pkg.all;
use work.sp_ram_pkg.all;
use ieee.numeric_std.all;

entity parser_tb is

end parser_tb;

architecture sim of parser_tb is

	constant LB_DATA_WIDTH : integer := 8;
	constant LB_ADDR_WIDTH : integer := 8;
	constant QUARTZ_PERIOD : time := 33 ns;
	constant QUARTZ_PLL_PERIOD : time := 2*40 ns;
	constant TEST_ARRAY_WIDTH : integer := 5;

	-- subtype TEST_ARRAY_CELL is std_logic_vector(1 downto 0); -- 8 bit for every ram cell(7 would be enough, but its easier this way(casting...))
	-- type TEST_ARRAY is array (TEST_ARRAY_WIDTH - 1 downto 0) of TEST_ARRAY_CELL;

  --signal test_array : TEST_ARRAY := (x"00", x"01", others => xW "5+8-3";

	signal test_string : string(1 to (TEST_ARRAY_WIDTH)) := "5+8-3";
  signal clk : std_logic;
  signal reset : std_logic;
	signal lb_addr_out_sig, lb_addr_wr_sig : std_logic_vector(LB_ADDR_WIDTH - 1 downto 0);
	signal lb_data_wr_sig, lb_data_out_sig : std_logic_vector(LB_DATA_WIDTH - 1  downto 0);
	signal lb_wr_sig, enable_lb_sig, start_calc_sig : std_logic;
	signal operand_sig : std_logic_vector(31 downto 0);
	signal operator_sig : std_logic_vector(1 downto 0);
	signal end_of_op_sig, parse_ready_sig, read_next_n_o_sig, old : std_logic;


begin  -- behav

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
		address_wr => lb_addr_wr_sig,
		wr => lb_wr_sig,
		data_wr => lb_data_wr_sig
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
  begin
    reset <= '0';
    wait for 10 ns;
    reset <= '1';
    wait for 10 ns;

--		test_array(0) <= x"35"; 
-- 		test_array(1) <= x"2B"; 
--		test_array(2) <= x"38"; 
--		test_array(3) <= x"2D"; 
--		test_array(4) <= x"33"; 

		for i in 1 to 70 loop
			lb_wr_sig <= '1';
			lb_addr_wr_sig <= std_logic_vector(to_unsigned((i - 1), 8));
			if i <= TEST_ARRAY_WIDTH then
				-- Test- String in Speicher schreiben 
				-- lb_data_wr_sig <= test_array(i);
				c := test_string(i);
				lb_data_wr_sig <= std_logic_vector(to_unsigned(character'pos(c),8));
			else
				lb_data_wr_sig <= x"29";
			end if;
		end loop;

		

		i := (others => '0');
   wait;
  end process;


--  process(clk)

--  begin
 --   if (clk'event and clk = '1') then
--			if old = '0' then
--				read_next_n_o_sig <= '1';
--				old <= '1';
--			else 
--				read_next_n_o_sig <= '0';
--				wait for 200 ns;			
--		end if;
--  end process sync;
--end architecture sim;



