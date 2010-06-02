library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_tb is
end entity alu_tb;

architecture sim of alu_tb is
  component alu is
    port
    (
	sys_clk		:	in	std_logic;
	sys_res_n	:	in	std_logic;
	start_operation	:	in	std_logic;
	operation_done	:	out	std_logic;
	operand_1	:	in	signed(31 downto 0);
	operand_2	:	in	signed(31 downto 0);
	operator	:	in	std_logic_vector(1 downto 0);
	sum		:	out	signed(62 downto 0)

    );
  end component alu;
  
	signal sys_clk, sys_res_n, operation_done, start_operation : std_logic;
	signal stop : boolean := false;
	signal operand_1	:	signed(31 downto 0);
	signal operand_2	:	signed(31 downto 0);
	signal operator	:	std_logic_vector(1 downto 0);
begin
	uut : alu
	port map
	(
		sys_clk		=>	sys_clk,
		sys_res_n	=>	sys_res_n,
		start_operation	=>	start_operation,
		operand_1	=>	operand_1,
		operand_2	=>	operand_2,
		operator	=>	operator
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
		start_operation <= '0';

	wait for 10 ns;
		sys_res_n <= '1';

	wait for 100 ns;
		operand_1 <= "00000000000000001000001000000001";
		operand_2 <= "00000000000000000000000110110000";
		operator <= "00";
	wait for 10 ns;
		start_operation <= '1';
	wait for 100 ns;
		start_operation <= '0';

	wait for 100 ns;
		operand_1 <= "00000000000000001000000000000000";
		operand_2 <= "00000000000000001000001000000001";
		operator <= "01";
	wait for 10 ns;
		start_operation <= '1';
	wait for 100 ns;
		start_operation <= '0';

	wait for 100 ns;
		operand_1 <= "00000000000000001000001000000001";
		operand_2 <= "00000000000000000000000000000111";
		operator <= "10";
	wait for 10 ns;
		start_operation <= '1';
	wait for 100 ns;
		start_operation <= '0';

	wait for 100 ns;
		stop <= true;
	wait;

	end process;
end architecture sim;
