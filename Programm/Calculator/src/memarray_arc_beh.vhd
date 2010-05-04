library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;

architecture beh of memarray is
	subtype RAM_CELL is std_logic_vector(DATA_WIDTH - 1 downto 0);		-- 7 bit are enough for used ASCII-chars
	type MEM_ARRAY is array (LINES - 1 downto 0, LINE_LENGTH - 1 downto 0) of RAM_CELL;
	signal ram : MEM_ARRAY;
	--signal ram : MEM_ARRAY := (others => x"00");

begin
	process(sys_clk, sys_res_n)
	begin
		if(sys_res_n = '0')
		then
			data_out <= "0000000";
		elsif(rising_edge(sys_clk))
		then
			data_out <= ram(to_integer(unsigned(ram_bank)), to_integer(unsigned(ram_offset)));
			if wr = '1' then
				ram(to_integer(unsigned(ram_bank)), to_integer(unsigned(ram_offset))) <= data_in;
			end if;
		end if;
	end process;
end architecture beh;
