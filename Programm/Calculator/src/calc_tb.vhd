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
	error_parser      :	in     std_logic;
	decode_ready_calc    :	out	std_logic;
	bcd_buf		:	out	unsigned(39 downto 0)

    );
  end component calc;
  
	signal sys_clk, sys_res_n, start_calc, decode_ready_calc, parse_ready, need_input, error_calc, error_parser, operation_end : std_logic;
	signal stop : boolean := false;
	signal operand	:	signed(31 downto 0);
	signal operator	:	std_logic_vector(1 downto 0);
	signal bcd_buf	:	 unsigned(39 downto 0);
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
	decode_ready_calc => decode_ready_calc,
	error_calc => error_calc,
	error_parser => error_parser,
	bcd_buf => bcd_buf
	
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
	operator <= "00";
	operand <= "00000000000000001000001000000001";		-- 33281 +
    wait for 1000 ns;
	parse_ready <= '1';
    wait for 50 ns;
	parse_ready <= '0';

    wait for 3000 ns;
	operator <= "00";
	operand <= "00000000000000000000000000001110";		-- 14 + 		(33295)
    wait for 100 ns;
	parse_ready <= '1';
    wait for 50 ns;
	parse_ready <= '0';

    wait for 3000 ns;
	operator <= "01";
	operand <= "00000000000000000000000000000010";		-- 2 - 			(33297)
    wait for 100 ns;
	parse_ready <= '1';
    wait for 50 ns;
	parse_ready <= '0';

    wait for 3000 ns;
	operator <= "00";
	operand <= "00000000000000000000000100001000";		-- 264 +		(33033)
    wait for 100 ns;
	parse_ready <= '1';
    wait for 50 ns;
	parse_ready <= '0';

    wait for 3000 ns;
	operator <= "00";
	operand <= "00000000000000000000000000111001";		-- 57 + 		(33090)
    wait for 100 ns;
	parse_ready <= '1';
    wait for 50 ns;
	parse_ready <= '0';

    wait for 3000 ns;
	operator <= "01";
	operand <= "00000000000000000000100000111001";		-- 2105 - 		(35195)
    wait for 100 ns;
	parse_ready <= '1';
    wait for 50 ns;
	parse_ready <= '0';

    wait for 3000 ns;
	operator <= "01";
	operand <= "00000000000000000010000111110001";		-- 8689 -		(26506)
    wait for 100 ns;
	parse_ready <= '1';
    wait for 50 ns;
	parse_ready <= '0';

    wait for 3000 ns;
	operator <= "00";
	operand <= "00000000000000000000101010000011";		-- 2691 +		(23815)
    wait for 100 ns;
	parse_ready <= '1';
    wait for 50 ns;
	parse_ready <= '0';

    wait for 3000 ns;
	operator <= "01";
	operand <= "00000000000000000000000000111001";		-- 57 -			(23872)
    wait for 100 ns;
	parse_ready <= '1';
    wait for 50 ns;
	parse_ready <= '0';

    wait for 3000 ns;
	operator <= "00";
	operand <= "00000000000000000000000000111001";		-- 57 EOP		(23815)
    wait for 100 ns;
	parse_ready <= '1';
	operation_end <= '1';

    wait for 100 ns;
	parse_ready <= '0';
	operation_end <= '0';
	start_calc <= '0';


----------------------------------------------------------------

    wait for 1200 ns;
	start_calc <= '1';
	operator <= "00";
	operand <= "00000000000000000000000000000011";		-- 3 +
    wait for 100 ns;
	parse_ready <= '1';
	start_calc <= '0';
    wait for 100 ns;
	parse_ready <= '0';

    wait for 100 ns;
	operator <= "10";
	operand <= "00000000000000000000000000010000";		-- 16 *
    wait for 100 ns;
	parse_ready <= '1';
    wait for 100 ns;
	parse_ready <= '0';

    wait for 100 ns;
	operator <= "00";
	operand <= "00000000000000000000000000000101";		-- 5 +
    wait for 100 ns;
	parse_ready <= '1';
    wait for 100 ns;
	parse_ready <= '0';

    wait for 100 ns;
	operator <= "01";
	operand <= "00000000000000000000000000010001";		-- 17 -
    wait for 100 ns;
	parse_ready <= '1';
    wait for 100 ns;
	parse_ready <= '0';

    wait for 100 ns;
	operator <= "00";
	operand <= "00000000000000000000000000000101";		-- 5 EOP
    wait for 100 ns;
	parse_ready <= '1';
	operation_end <= '1';
    wait for 100 ns;
	parse_ready <= '0';
	operation_end <= '0';


    wait for 100 ns;
	stop <= true;
    wait;
  end process;
end architecture sim;
