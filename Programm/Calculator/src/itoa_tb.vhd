library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity itoa_tb is
end entity itoa_tb;

architecture sim of itoa_tb is
  component itoa is
  
        port
        (
                sys_clk         :       in std_logic;
                sys_res_n       :       in std_logic;
                int_in          :       in integer range -2147483647 to 2147483647 := 0;

		out_0, out_1, out_2, out_3, out_4, out_5, out_6, out_7, out_8, out_9, out_10 : out unsigned(0 to 3);
		start_decode	:	in std_logic;
		decode_ready	:	out std_logic;
		sign		:	out std_logic
        );

end component itoa;
  
	signal sys_clk, sys_res_n	: std_logic;
	signal stop			: boolean := false;
	--signal int_in			: signed(0 to 31);
	signal int_in			: integer range -2147483647 to 2147483647 := 0;
	signal start_decode		: std_logic;
	signal decode_ready		: std_logic;
	signal sign			: std_logic;
	signal out_0, out_1, out_2, out_3, out_4, out_5, out_6, out_7, out_8, out_9, out_10 : unsigned(0 to 3);
begin
  uut : itoa
    port map
    (
      sys_clk => sys_clk,
      sys_res_n => sys_res_n,
	int_in => int_in,
	start_decode => start_decode,
	out_0 => out_0,
	out_1 => out_1,
	out_2 => out_2,
	out_3 => out_3,
	out_4 => out_4,
	out_5 => out_5,
	out_6 => out_6,
	out_7 => out_7,
	out_8 => out_8,
	out_9 => out_9,
	out_10 => out_10,
	decode_ready => decode_ready,
	sign => sign
    );
    
  process
  begin
    sys_clk <= '0';
    wait for 15 ns;
    sys_clk <= '1';
    wait for 15 ns;
  end process;
  
  process
  begin
	sys_res_n <= '0';
	start_decode <= '0';
    wait for 100 ns;
	sys_res_n <= '1';	-- RESET END
    wait for 1 ms;
	int_in <= -254231984;
    wait for 1 ms;
	start_decode <= '1';
    wait for 1730 ns;
	start_decode <= '0';
    wait for 1730 ns;
	int_in <= 042219143;
    wait for 1730 ns;
	start_decode <= '1';
    wait for 1730 ns;
	stop <= true;
    wait;
  end process;
end architecture sim;
