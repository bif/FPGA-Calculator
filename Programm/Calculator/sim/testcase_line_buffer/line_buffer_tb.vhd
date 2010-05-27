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
	constant LB_ADDR_WIDTH : integer := 7;
	

  signal clk, pll_clk, vga_free_sig : std_logic;
  signal reset : std_logic;
  signal command_sig : std_logic_vector(COMMAND_SIZE - 1 downto 0); 
  signal command_data_sig : std_logic_vector(3 * COLOR_SIZE + CHAR_SIZE - 1 downto 0); 
  signal new_ascii_sig : std_logic;
  signal ascii_sign_sig : std_logic_vector(7 downto 0);
	signal lb_addr_sig, lb_addr_out_sig, mem_debug_addr : std_logic_vector(LB_ADDR_WIDTH - 1 downto 0);
	signal lb_data_in_sig, lb_data_out_sig, mem_debug_data : std_logic_vector(LB_DATA_WIDTH - 1 downto 0);
	signal wr_enable_sig, enable_sig, start_calc_sig : std_logic;

	


  constant QUARTZ_PERIOD : time := 33 ns;
	constant QUARTZ_PLL_PERIOD : time := 2*40 ns;

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
--			vga_free => '1',
      vga_command => command_sig,
      vga_command_data => command_data_sig,
      new_ascii_in => new_ascii_sig,
      ascii_sign_in => ascii_sign_sig,
			wr_enable => wr_enable_sig,
			lb_addr => lb_addr_sig,
			lb_data => lb_data_in_sig,
			start_calc => start_calc_sig,
			enable => enable_sig
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
		variable i : integer := 1;
		variable u :  std_logic_vector(LB_ADDR_WIDTH - 1 downto 0) := (others => '0');

  begin

    reset <= '0';
    wait for 10 ns;
    reset <= '1';
    wait for 5 us;

		enable_sig <= '0';
		mem_debug_addr <= (others => '0');
    
		vga_free_sig <= '1';
		-- wait until clearscreen is ready
		wait for 14 us;
		ascii_sign_sig <= x"31";
		new_ascii_sig <= '1';
    wait for QUARTZ_PERIOD / 2; 
    new_ascii_sig <= '0';
		vga_free_sig <= '0';
		wait for 20 ns;

		vga_free_sig <= '1';
    wait for 200 ns;
		ascii_sign_sig <= x"32";
    new_ascii_sig <= '1';
    wait for QUARTZ_PERIOD / 2; 
    new_ascii_sig <= '0';
		vga_free_sig <= '0';
		wait for 20 ns;

		vga_free_sig <= '1';
    wait for 200 ns;
		ascii_sign_sig <= x"33";
    new_ascii_sig <= '1';
		wait for QUARTZ_PERIOD / 2; 
    new_ascii_sig <= '0';
		vga_free_sig <= '0';
		wait for 20 ns;


		for i in 3 to 10 loop
			vga_free_sig <= '1';
			wait for 200 ns;
			ascii_sign_sig <= x"37"; 
			new_ascii_sig <= '1';
			wait for QUARTZ_PERIOD / 2; 
			new_ascii_sig <= '0';
			vga_free_sig <= '0';
			wait for 20 ns;
		end loop;

		vga_free_sig <= '1';
    wait for 200 ns;
    new_ascii_sig <= '1';
		ascii_sign_sig <= x"03";
		wait for QUARTZ_PERIOD / 2; 
    new_ascii_sig <= '0';
--		wait for 40 ns;
		vga_free_sig <= '0';
		wait for 200 ns;
		vga_free_sig <= '1';
		wait for 200 ns;
		vga_free_sig <= '0';
		wait for 200 ns;
		vga_free_sig <= '1';
		wait for 200 ns;
		vga_free_sig <= '0';
		wait for 200 ns;
		vga_free_sig <= '1';
		
	

		while unsigned(u) < 20 loop
			wait for 200 ns;
			mem_debug_addr <= u;
			u := std_logic_vector(unsigned(u) + 1 );
			wait for 200 ns;
		end loop;

		wait for 30 ns;
		enable_sig <= '1';
	

    wait;
  end process;
end architecture sim;



