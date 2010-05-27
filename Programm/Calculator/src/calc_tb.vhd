library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity calc_tb is
end entity calc_tb;

architecture sim of calc_tb is
  component calc is
    port
    (
	sys_clk		:	in	std_logic;
	sys_res_n	:	in	std_logic;
	start_calc	:	in	std_logic;
	parse_ready	:	in	std_logic;
	operation_end   :	in      std_logic;
	operand		:	in	signed(31 downto 0);
	operator        :       in      std_logic_vector(1 downto 0)  := "00";
	need_input	:	out	std_logic := '0';
	error_calc      :	out     std_logic;
	decode_ready    :	out	std_logic;
	nibble_0        :       out     unsigned(3 downto 0) := "0000";         -- calculation nibble 0 (einerstelle)
	nibble_1        :       out     unsigned(3 downto 0) := "0000";         -- ...
	nibble_2        :       out     unsigned(3 downto 0) := "0000";
	nibble_3        :       out     unsigned(3 downto 0) := "0000";
	nibble_4        :       out     unsigned(3 downto 0) := "0000";
	nibble_5        :       out     unsigned(3 downto 0) := "0000";
	nibble_6        :       out     unsigned(3 downto 0) := "0000";
	nibble_7        :       out     unsigned(3 downto 0) := "0000";
	nibble_8        :       out     unsigned(3 downto 0) := "0000";
	nibble_9        :       out     unsigned(3 downto 0) := "0000"         -- ... most significant nibble

    );
  end component calc;
  
	signal sys_clk, sys_res_n, start_calc, decode_ready, parse_ready, need_input, error_calc, operation_end : std_logic;
	signal stop : boolean := false;
	signal operand	:	signed(31 downto 0);
	signal operator	:	std_logic_vector(1 downto 0);
	signal nib0	: unsigned(3 downto 0) := "0000";
	signal nib1	: unsigned(3 downto 0) := "0000";
	signal nib2	: unsigned(3 downto 0) := "0000";
	signal nib3	: unsigned(3 downto 0) := "0000";
	signal nib4	: unsigned(3 downto 0) := "0000";
	signal nib5	: unsigned(3 downto 0) := "0000";
	signal nib6	: unsigned(3 downto 0) := "0000";
	signal nib7	: unsigned(3 downto 0) := "0000";
	signal nib8	: unsigned(3 downto 0) := "0000";
	signal nib9	: unsigned(3 downto 0) := "0000";
begin
  uut : calc
    port map
    (
      sys_clk => sys_clk,
      sys_res_n => sys_res_n,
      start_calc => start_calc,
	parse_ready => parse_ready,
	need_input => need_input,
	operand => operand,
	operator => operator,
	operation_end	=>	operation_end,
	decode_ready => decode_ready,
	error_calc => error_calc,
	nibble_0 => nib0,
	nibble_1 => nib1,
	nibble_2 => nib2,
	nibble_3 => nib3,
	nibble_4 => nib4,
	nibble_5 => nib5,
	nibble_6 => nib6,
	nibble_7 => nib7,
	nibble_8 => nib8,
	nibble_9 => nib9
	
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
	start_calc <= '0';
	parse_ready <= '0';
	operation_end <= '0';
    wait for 100 ns;
	sys_res_n <= '1';	-- RESET END
    wait for 1 ms;
	start_calc <= '1';
    wait for 100 ns;
	start_calc <= '0';
	operator <= "10";
	operand <= "00000000000000001000001000000001";		-- 33281 *
    wait for 1000 ns;
	parse_ready <= '1';
    wait for 100 ns;
	parse_ready <= '0';

    wait for 1000 ns;
	operator <= "00";
	operand <= "00000000000000000000000000001110";		-- 14 + 
    wait for 8730 ns;
	parse_ready <= '1';
    wait for 100 ns;
	parse_ready <= '0';

    wait for 1000 ns;
	operator <= "01";
	operand <= "00000000000000000000000000000010";		-- 2 - 
    wait for 100 ns;
	parse_ready <= '1';
    wait for 100 ns;
	parse_ready <= '0';

    wait for 100 ns;
	operator <= "10";
	operand <= "00000000000000000000000100001000";		-- 264 * 
    wait for 100 ns;
	parse_ready <= '1';
    wait for 100 ns;
	parse_ready <= '0';

    wait for 100 ns;
	operator <= "10";
	operand <= "00000000000000000000000000111001";		-- 57 * 
    wait for 100 ns;
	parse_ready <= '1';
    wait for 100 ns;
	parse_ready <= '0';

    wait for 100 ns;
	operator <= "01";
	operand <= "00000000000000000000100000111001";		-- 2105 - 
    wait for 100 ns;
	parse_ready <= '1';
    wait for 100 ns;
	parse_ready <= '0';

    wait for 100 ns;
	operator <= "10";
	operand <= "00000000000000000010000111110001";		-- 8689 * 
    wait for 100 ns;
	parse_ready <= '1';
    wait for 100 ns;
	parse_ready <= '0';

    wait for 100 ns;
	operator <= "00";
	operand <= "00000000000000000000101010000011";		-- 2691 +
    wait for 100 ns;
	parse_ready <= '1';
    wait for 100 ns;
	parse_ready <= '0';

    wait for 100 ns;
	operator <= "10";
	operand <= "00000000000000000000000000111001";		-- 57 *
    wait for 100 ns;
	parse_ready <= '1';
    wait for 100 ns;
	parse_ready <= '0';

    wait for 100 ns;
	operator <= "00";
	operand <= "00000000000000000000000000111001";		-- 57 EOP
    wait for 100 ns;
	parse_ready <= '1';
    wait for 100 ns;
	parse_ready <= '0';

    wait for 100 ns;
	operation_end <= '1';
    wait for 100 ns;
	operation_end <= '0';
	start_calc <= '0';


----------------------------------------------------------------

    wait for 1000 ns;
	start_calc <= '1';
	operator <= "10";
	operand <= "00000000000000000000000000000011";		-- 3 *
    wait for 100 ns;
	parse_ready <= '1';
    wait for 100 ns;
	parse_ready <= '0';

    wait for 100 ns;
	operator <= "00";
	operand <= "00000000000000000000000000010000";		-- 16 EOP
    wait for 100 ns;
	parse_ready <= '1';
    wait for 100 ns;
	parse_ready <= '0';

    wait for 100 ns;
	operator <= "00";
	operand <= "00000000000000000000000000000101";		-- 5 EOP
    wait for 100 ns;
	parse_ready <= '1';
    wait for 100 ns;
	parse_ready <= '0';

    wait for 100 ns;
	operation_end <= '1';
    wait for 100 ns;
	operation_end <= '0';


    wait for 100 ns;
	stop <= true;
    wait;
  end process;
end architecture sim;
