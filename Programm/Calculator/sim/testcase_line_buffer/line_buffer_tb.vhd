library ieee;
use ieee.std_logic_1164.all;
use work.line_buffer_pkg.all;
use work.textmode_vga_pkg.all;


entity line_buffer_tb is

end line_buffer_tb;

architecture sim of line_buffer_tb is

	constant LB_DATA_WIDTH : integer := 8;
	constant LB_ADDR_WIDTH : integer := 7;
	

  component line_buffer is
		generic
	  (
			ADDR_WIDTH : integer range 1 to integer'high;
 	    DATA_WIDTH : integer range 1 to integer'high
		);
    port 
		(
			sys_clk : in std_logic;
      sys_res_n : in std_logic;
      vga_free : in std_logic;
      vga_command : out std_logic_vector(COMMAND_SIZE - 1 downto 0); 
      vga_command_data : out std_logic_vector(3 * COLOR_SIZE + CHAR_SIZE - 1 downto 0); 
      new_ascii_in : in std_logic;
      ascii_sign_in : in std_logic_vector(7 downto 0);
			lb_addr : out std_logic_vector(ADDR_WIDTH - 1 downto 0);
   		lb_data : out std_logic_vector(DATA_WIDTH - 1 downto 0);
   		wr_enable : out std_logic;
			start_calc : out std_logic;
	    enable : in std_logic
		);
  end component line_buffer;


  signal clk, pll_clk, vga_free_sig : std_logic;
  signal reset : std_logic;
  signal command_sig : std_logic_vector(COMMAND_SIZE - 1 downto 0); 
  signal command_data_sig : std_logic_vector(3 * COLOR_SIZE + CHAR_SIZE - 1 downto 0); 
  signal new_ascii_sig : std_logic;
  signal ascii_sign_sig : std_logic_vector(7 downto 0);
	signal lb_addr_sig : std_logic_vector(LB_ADDR_WIDTH - 1 downto 0);
	signal lb_data_in_sig : std_logic_vector(LB_DATA_WIDTH - 1 downto 0);
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

--  process
--  begin  -- process
--  	if vga_free_sig = '1' then
--			wait for QUARTZ_PLL_PERIOD;
--			vga_free_sig <= '0';
--		end if;	
--	end process;

	process
		variable i : integer := 1;

  begin
    reset <= '0';
    wait for 10 ns;
    reset <= '1';
    wait for 10 ns;
    
		vga_free_sig <= '1';
		wait for 2.2 us;
    new_ascii_sig <= '1';
		ascii_sign_sig <= x"31";
    wait for QUARTZ_PERIOD / 2; 
    new_ascii_sig <= '0';
--	wait for 40 ns;
		vga_free_sig <= '0';
		wait for 20 ns;
		vga_free_sig <= '1';
    wait for 200 ns;
    new_ascii_sig <= '1';
		ascii_sign_sig <= x"32";
    wait for QUARTZ_PERIOD / 2; 
    new_ascii_sig <= '0';
--		wait for 40 ns;
		vga_free_sig <= '0';
		wait for 20 ns;
		vga_free_sig <= '1';
    wait for 200 ns;
    new_ascii_sig <= '1';
		ascii_sign_sig <= x"03";
		wait for QUARTZ_PERIOD / 2; 
    new_ascii_sig <= '0';
--		wait for 40 ns;
		vga_free_sig <= '0';
		wait for 200 ns;


-- reset
		reset <= '0';
    wait for 10 ns;
    reset <= '1';
    wait for 10 ns;




		for i in 1 to 70 loop
			vga_free_sig <= '1';
			wait for 200 ns;
			new_ascii_sig <= '1';
			ascii_sign_sig <= x"37"; 
			wait for QUARTZ_PERIOD; 
			new_ascii_sig <= '0';
--			wait for 40 ns;
			vga_free_sig <= '0';
			wait for 20 ns;
		end loop;

		vga_free_sig <= '1';
	  wait for 200 ns;
    new_ascii_sig <= '1';
		ascii_sign_sig <= x"08";
    wait for QUARTZ_PERIOD / 2; 
    new_ascii_sig <= '0';
-- 		wait for 40 ns;
		vga_free_sig <= '0';
		wait for 20 ns;
		vga_free_sig <= '1';
	  wait for 200 ns;
    new_ascii_sig <= '1';
		ascii_sign_sig <= x"08";
    wait for QUARTZ_PERIOD / 2; 
    new_ascii_sig <= '0';
--		wait for 40 ns;
		vga_free_sig <= '0';
		wait for 20 ns;

    wait;
  end process;
end architecture sim;



