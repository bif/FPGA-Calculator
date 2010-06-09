library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.line_buffer_pkg.all;
use work.textmode_vga_pkg.all;
use work.sp_ram_pkg.all;

entity line_buffer_tb is

end line_buffer_tb;

architecture sim of line_buffer_tb is

	constant LB_DATA_WIDTH : integer := 8;
	constant LB_ADDR_WIDTH : integer := 8;
	

  signal clk, pll_clk, vga_free_sig : std_logic;
  signal reset : std_logic;
  signal command_sig : std_logic_vector(COMMAND_SIZE - 1 downto 0) := (others => '0'); 
  signal command_data_sig : std_logic_vector(3 * COLOR_SIZE + CHAR_SIZE - 1 downto 0) := (others => '0'); 
  signal new_ascii_sig : std_logic := '0';
  signal ascii_sign_sig : std_logic_vector(7 downto 0) := (others => '0');
	signal lb_addr_sig, lb_addr_out_sig, mem_debug_addr : std_logic_vector(LB_ADDR_WIDTH - 1 downto 0) := (others => '0');
	signal lb_data_in_sig, lb_data_out_sig, mem_debug_data : std_logic_vector(LB_DATA_WIDTH - 1 downto 0) := (others => '0');
	signal wr_enable_sig, enable_sig, start_calc_sig : std_logic := '0';
	signal bcd_result_sig : std_logic_vector(39 downto 0) := (others => '0');
	signal test_string : string(1 to 71);
	signal index : integer range 1 to 80 := 1;

  constant QUARTZ_PERIOD : time := 33 ns;
	constant QUARTZ_PLL_PERIOD : time := 2*40 ns;


--	function scancode_return(value : in character) return std_logic_vector is 
--		case value is
--			when "1" =>
--				return <= x"31";
--			when "2" =>
--				return <= x"32";
--			when "3" =>
--				return <= x"33";
--			when "4" =>
--				return <= x"34";
--			when "5" =>
--				return <= x"35";
--			when "6" =>
--				return <= x"36";
--			when "7" =>
--				return <= x"37";
--			when "8" =>
--				return <= x"38";
--			when "9" =>
--				return <= x"39";
--			when "0" =>
--				return <= x"30";
--			when "+" =>
--				return <= x"2B";
--			when "-" =>
--				return <= x"2D";
--			when "*" =>
--				return <= x"2A";
--			when "/" =>
--				return <= x"2F";
--			when "=" =>
--				return <= x"03";
--			when others =>
--				return <= x"20";
--		end case;
--	end function;



begin  -- behav

  uut: line_buffer
  	generic map
	  (
			ADDR_WIDTH => LB_ADDR_WIDTH,
			DATA_WIDTH => LB_DATA_WIDTH
		)
	  port map 
		(
      sys_clk   => clk,
      sys_res_n => reset,
			vga_free => vga_free_sig,
      vga_command => command_sig,
      vga_command_data => command_data_sig,
      new_ascii_in => new_ascii_sig,
      ascii_sign_in => ascii_sign_sig,
			wr_enable => wr_enable_sig,
			lb_addr => lb_addr_sig,
			lb_data => lb_data_in_sig,
			start_calc => start_calc_sig,
			enable => enable_sig,
			bcd_result => bcd_result_sig
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
		address_wr => lb_addr_sig,
		wr => wr_enable_sig,
		data_wr => lb_data_in_sig
	);



  process
  begin  -- process
    clk <= '0';
    wait for QUARTZ_PERIOD / 2;
    clk <= '1';
    wait for QUARTZ_PERIOD / 2;
  end process;

	process
	begin
		pll_clk <= '0';
		wait for QUARTZ_PLL_PERIOD / 2;
		pll_clk <= '1';
		wait for QUARTZ_PLL_PERIOD / 2;
	end process;


	process
--		variable i, j :  integer range 1 to 80 := 1;
		variable c : character := ' ';

  begin

    reset <= '0';
    wait for 10 ns;
    reset <= '1';
    wait for 5 us;

		mem_debug_addr <= (others => '0');
    
		vga_free_sig <= '1';
		-- wait until clearscreen is ready
		wait for 9 us;


		--simulate scancode handler and vga
--		test_string <= "123456789_123456789_123456789_123456789_123456789_123456789_123456789_1";
			test_string <= "6+1=                                                                   ";
		wait for 200 ns;
		while c /= '=' loop
			-- convert chars from string into scancodehandler output
			if index <= 71 then
				c := test_string(index);
				mem_debug_addr <= std_logic_vector(to_unsigned((index - 1), 8)); 
				index <= (index + 1);
--			ascii_sign_sig <=  scancode_ascii_sign_sig(c); -- scancode handler simulation function
				case c is
					when '1' =>
						ascii_sign_sig <= x"31";
					when '2' =>
						ascii_sign_sig <= x"32";
					when '3' =>
						ascii_sign_sig <= x"33";
					when '4' =>
						ascii_sign_sig <= x"34";
					when '5' =>
						ascii_sign_sig <= x"35";
					when '6' =>
						ascii_sign_sig <= x"36";
					when '7' =>
						ascii_sign_sig <= x"37";
					when '8' =>
						ascii_sign_sig <= x"38";
					when '9' =>
						ascii_sign_sig <= x"39";
					when '0' =>
						ascii_sign_sig <= x"30";
					when '+' =>
						ascii_sign_sig <= x"2B";
					when '-' =>
						ascii_sign_sig <= x"2D";
					when '*' =>
						ascii_sign_sig <= x"2A";
					when '/' =>
						ascii_sign_sig <= x"2F";
					when '=' =>
						ascii_sign_sig <= x"03";
					when others =>
						ascii_sign_sig <= x"20";
				end case;
				wait for 20 ns;
				new_ascii_sig <= '1';
				wait for QUARTZ_PERIOD; -- new_ascii_sig is '1' for one clk period 
				new_ascii_sig <= '0';
				wait for (QUARTZ_PERIOD); -- wait some time until vga modul locked
				vga_free_sig <= '0';
				wait for 20 ns; -- some time until vga is free again
				vga_free_sig <= '1';
				wait for 200 ns; -- wait until line buffer is ready
			end if;
		end loop;
		--simulate vga for last sign
		wait for QUARTZ_PERIOD; -- wait some time until vga modul locked
		vga_free_sig <= '0';
		wait for 20 ns; -- some time until vga is free again
		vga_free_sig <= '1';
		wait for 200 ns; -- wait until line buffer is ready
		c := ' ';
		index <= 1;


		--wait some time to enable line buffer again
		wait for 100 ns;
--		wait until start_calc_sig = '1';
		enable_sig <= '1'; 
		wait for QUARTZ_PERIOD;
		enable_sig <= '0';
		-- wait for WRITE_RESULT finished
		wait for 1 us;
		vga_free_sig <= '0';
		wait for (2 * QUARTZ_PERIOD);
		vga_free_sig <= '1';
			-- wait for ENTER1 finished
		wait for 1 us;
		vga_free_sig <= '0';
		wait for (2 * QUARTZ_PERIOD);
		vga_free_sig <= '1';
			-- wait for ENTER2 finished
		wait for 1 us;
		vga_free_sig <= '0';
		wait for (2 * QUARTZ_PERIOD);
		vga_free_sig <= '1';
		-- wait for clear line buffer memmory
		wait for 5 us;


		

		wait for (QUARTZ_PERIOD /2);
		--simulate scancode handler and vga
--		test_string <= "123456789_123456789_123456789_123456789_123456789_123456789_123456789_1";
			test_string <= "9+1*8  =                                                               ";
		wait for 200 ns;
		while c /= '=' loop
			if index <= 71 then
				-- convert chars from string into scancodehandler output
				c := test_string(index);
				mem_debug_addr <= std_logic_vector(to_unsigned((index - 1), 8)); 
				index <= (index + 1);
	--			ascii_sign_sig <=  scancode_ascii_sign_sig(c); -- scancode handler simulation function
				case c is
					when '1' =>
						ascii_sign_sig <= x"31";
					when '2' =>
						ascii_sign_sig <= x"32";
					when '3' =>
						ascii_sign_sig <= x"33";
					when '4' =>
						ascii_sign_sig <= x"34";
					when '5' =>
						ascii_sign_sig <= x"35";
					when '6' =>
						ascii_sign_sig <= x"36";
					when '7' =>
						ascii_sign_sig <= x"37";
					when '8' =>
						ascii_sign_sig <= x"38";
					when '9' =>
						ascii_sign_sig <= x"39";
					when '0' =>
						ascii_sign_sig <= x"30";
					when '+' =>
						ascii_sign_sig <= x"2B";
					when '-' =>
						ascii_sign_sig <= x"2D";
					when '*' =>
						ascii_sign_sig <= x"2A";
					when '/' =>
						ascii_sign_sig <= x"2F";
					when '=' =>
						ascii_sign_sig <= x"03";
					when others =>
						ascii_sign_sig <= x"20";
				end case;
				wait for 20 ns;	
				new_ascii_sig <= '1';
				wait for QUARTZ_PERIOD; -- new_ascii_sig is '1' for one clk period 
				new_ascii_sig <= '0';
				wait for QUARTZ_PERIOD; -- wait some time until vga modul locked
				vga_free_sig <= '0';
				wait for 20 ns; -- some time until vga is free again
				vga_free_sig <= '1';
				wait for 200 ns; -- wait until line buffer is ready
			end if;
		end loop;
		-- siulate vga for last sign
		wait for (QUARTZ_PERIOD); -- wait some time until vga modul locked
		vga_free_sig <= '0';
		wait for 20 ns; -- some time until vga is free again
		vga_free_sig <= '1';
		wait for 200 ns; -- wait until line buffer is ready
		c := ' ';
		index <= 1;

		--wait some time to enable line buffer again
		wait for 100 ns;
--		wait until start_calc_sig = '1';
		enable_sig <= '1'; 
		wait for QUARTZ_PERIOD;
		enable_sig <= '0';
		-- wait for WRITE_RESULT finished
		wait for 1 us;
		vga_free_sig <= '0';
		wait for (2 * QUARTZ_PERIOD);
		vga_free_sig <= '1';
			-- wait for ENTER1 finished
		wait for 20 ns;
		vga_free_sig <= '0';
		wait for (2 * QUARTZ_PERIOD);
		vga_free_sig <= '1';
			-- wait for ENTER2 finished
		wait for 20 ns;
		vga_free_sig <= '0';
		wait for (2 * QUARTZ_PERIOD);
		vga_free_sig <= '1';
		-- wait for clear line buffer memmory
		wait for 5 us;

-- test bcd ausgabe
--		wait for 30 ns;
--		bcd_result_sig <= x"1234567890";
--		enable_sig <= '1';
	
--		for i in 1 to 46 loop
--			vga_free_sig <= '1';
--			wait for 200 ns;
--			wait for QUARTZ_PERIOD / 2; 
--			vga_free_sig <= '0';
--			wait for 20 ns;
--		end loop;

    wait;
  end process;


end architecture sim;



