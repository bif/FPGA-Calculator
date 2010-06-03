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

	signal test_string : string(1 to 71);
  signal clk : std_logic;
  signal reset : std_logic;
	signal lb_addr_out_sig, lb_addr_wr_sig, mem_debug_addr : std_logic_vector(LB_ADDR_WIDTH - 1 downto 0);
	signal lb_data_wr_sig, lb_data_out_sig, mem_debug_data : std_logic_vector(LB_DATA_WIDTH - 1  downto 0);
	signal lb_wr_sig, enable_lb_sig, start_calc_sig : std_logic;
	signal operand_sig : signed(31 downto 0);
	signal operator_sig : std_logic_vector(1 downto 0);
	signal end_parse, end_parse_next, end_of_op_sig, parse_ready_sig, read_next_n_o_sig, get_next : std_logic ;
	signal continue : std_logic := '0';
	signal run_always : std_logic := '1';
	signal error_number : std_logic_vector(1 downto 0) := "00";

--	procedure sim_line_buf(array_width : in integer; test_string : in string) is 

--		variable i :  std_logic_vector(LB_ADDR_WIDTH - 1 downto 0) := (others => '0');
--		variable c : character;
--		while i < x"46" loop
--			mem_debug_addr <= i;
--			lb_addr_wr_sig <= i;
--			lb_wr_sig <= '1';
--			if i <= array_width then
				-- Test- String in Speicher schreiben 
				-- lb_data_wr_sig <= test_array(i);
--				c := test_string(i);
--				lb_data_wr_sig <= std_logic_vector(to_unsigned(character'pos(c),8));
--				wait for 200 ns;
--			else
--				lb_data_wr_sig <= x"20";
--				wait for 200 ns;
--			end if;
--			i <= std_logic_vector(to_unsigned((i + 1), 8));
--		end loop;

 --   i := (others => '0');
--		lb_wr_sig <= '0';
--	end procedure; 

begin

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
		parse_ready => parse_ready_sig,
		error_sig => error_number
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


  process
  begin  -- process
    clk <= '0';
    wait for QUARTZ_PERIOD / 2;
    clk <= '1';
    wait for QUARTZ_PERIOD / 2;
  end process;


	
	process
		variable i :  integer range 1 to 80;
		variable c : character;

  begin

    reset <= '0';
    wait for 10 ns;
    reset <= '1';
    wait for 10 ns;

--simulate line buffer
--		test_string <= "123456789_123456789_123456789_123456789_123456789_123456789_123456789_1";
			test_string <= "6+1=                                                                   ";
		wait for 200 ns;
		for i in 1 to 71 loop
			mem_debug_addr <= std_logic_vector(to_unsigned((i - 1), 8));
			lb_addr_wr_sig <= std_logic_vector(to_unsigned((i - 1), 8));
			lb_wr_sig <= '1';
			-- Test-String in Speicher schreiben 
			c := test_string(i);
			lb_data_wr_sig <= std_logic_vector(to_unsigned(character'pos(c),8));
			wait for 200 ns;
		end loop;
		lb_wr_sig <= '0';
		continue <= '1';
		wait until end_of_op_sig = '1';
		continue <= '0';

--simulate line buffer
--		test_string <= "123456789_123456789_123456789_123456789_123456789_123456789_123456789_1";
			test_string <= "7+   -   *   = 333                                                     ";
		wait for 200 ns;
		for i in 1 to 71 loop
			mem_debug_addr <= std_logic_vector(to_unsigned((i - 1), 8));
			lb_addr_wr_sig <= std_logic_vector(to_unsigned((i - 1), 8));
			lb_wr_sig <= '1';
			-- Test-String in Speicher schreiben 
			c := test_string(i);
			lb_data_wr_sig <= std_logic_vector(to_unsigned(character'pos(c),8));
			wait for 200 ns;
		end loop;
		lb_wr_sig <= '0';
		continue <= '1';
		wait until end_of_op_sig = '1';
		continue <= '0';

--simulate line buffer
--		test_string <= "123456789_123456789_123456789_123456789_123456789_123456789_123456789_1";
			test_string <= "    -  932*  453/ +2234  =                                             ";
		wait for 200 ns;
		for i in 1 to 71 loop
			mem_debug_addr <= std_logic_vector(to_unsigned((i - 1), 8));
			lb_addr_wr_sig <= std_logic_vector(to_unsigned((i - 1), 8));
			lb_wr_sig <= '1';
			-- Test-String in Speicher schreiben 
			c := test_string(i);
			lb_data_wr_sig <= std_logic_vector(to_unsigned(character'pos(c),8));
			wait for 200 ns;
		end loop;
		lb_wr_sig <= '0';
		continue <= '1';
		wait until end_of_op_sig = '1';
		continue <= '0';

--simulate line buffer
--		test_string <= "123456789_123456789_123456789_123456789_123456789_123456789_123456789_1";
			test_string <= "   -  934 + 546 * 0 --32--0-+32                              =         ";
		wait for 200 ns;
		for i in 1 to 71 loop
			mem_debug_addr <= std_logic_vector(to_unsigned((i - 1), 8));
			lb_addr_wr_sig <= std_logic_vector(to_unsigned((i - 1), 8));
			lb_wr_sig <= '1';
			-- Test-String in Speicher schreiben 
			c := test_string(i);
			lb_data_wr_sig <= std_logic_vector(to_unsigned(character'pos(c),8));
			wait for 200 ns;
		end loop;
		lb_wr_sig <= '0';
		continue <= '1';
		wait until end_of_op_sig = '1';
		continue <= '0';


   wait;
  end process;


	process
	begin
	  if reset = '0' then
			get_next <= '0';
		end if;

		if continue = '1' then
			mem_debug_addr <= lb_addr_out_sig;
			get_next <= '1';
			wait for 100 ns;
			get_next <= '0';
			wait for 400 ns;
		else 
			run_always <= '1';
		end if;
		wait for 1 ns;
	end process;


  process(clk)

  begin

   if (clk'event and clk = '1') then
    if get_next = '1' then
			read_next_n_o_sig <= '1';
		else
			read_next_n_o_sig <= '0';
    end if; 
	end if;
  end process;
end architecture sim;

